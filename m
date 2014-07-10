From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in TLB mode.
Date: Thu, 10 Jul 2014 06:39:30 -0700
Message-ID: <7156.1404999570@localhost.localdomain>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44701 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaGJNjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 09:39:35 -0400
In-reply-to: <1404868198-24839-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:

>In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
>group are selected based on the hash distribution. This does not
>exclude dead links which are part of the bond. Also if there is a
>temporary link event which brings down the interface, packets
>hashed on that interface would be dropped too.
>
>This patch fixes these issues and distributes flows across the
>UP links only. Also the array construction of links which are
>capable of sending packets happen in the control path leaving
>only link-selection duing the data-path.
>
>One possible side effect of this is - at a link event; all
>flows will be shuffled to get good distribution. But impact of
>this should be minimum with the assumption that a member or
>members of the bond group are not available is a very temporary
>situation.

	Why limit this to just TLB mode?  Other similar situations,
e.g., the TX slave selection in 802.3ad or balance-xor via
bond_xmit_slave_id, would presumably see a performance gain from using
an array lookup instead of traversing a linked list (even though those
modes do already skip slaves that are down).

	The 802.3ad case is a bit more complex, as an array would have
to include only slaves that are members of the active aggregator, but
the bond_xmit_slave_id case shouldn't be much more difficult than what
you've done below.

	-J

>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>---
> drivers/net/bonding/bond_alb.c | 52 +++++++++++++++++++++++++++++++++++++-----
> drivers/net/bonding/bond_alb.h | 11 +++++++++
> drivers/net/bonding/bonding.h  |  6 +++++
> 3 files changed, 63 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 76c0dade233f..1f39d41fde4b 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -195,6 +195,9 @@ static int tlb_initialize(struct bonding *bond)
> 
> 	_unlock_tx_hashtbl_bh(bond);
> 
>+	/* Initialize the TLB array spin-lock */
>+	spin_lock_init(&bond_info->slave_arr_lock);
>+
> 	return 0;
> }
> 
>@@ -209,6 +212,9 @@ static void tlb_deinitialize(struct bonding *bond)
> 	bond_info->tx_hashtbl = NULL;
> 
> 	_unlock_tx_hashtbl_bh(bond);
>+
>+	if (bond_is_nondyn_tlb(bond) && bond_info->slave_arr)
>+		kfree_rcu(bond_info->slave_arr, rcu);
> }
> 
> static long long compute_gap(struct slave *slave)
>@@ -1406,9 +1412,37 @@ out:
> 	return NETDEV_TX_OK;
> }
> 
>+static int bond_tlb_update_slave_arr(struct bonding *bond)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct slave *tx_slave;
>+	struct list_head *iter;
>+	struct tlb_up_slave *new_arr, *old_arr;
>+
>+	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>+			  GFP_KERNEL);
>+	if (!new_arr)
>+		return -ENOMEM;
>+
>+	bond_for_each_slave(bond, tx_slave, iter) {
>+		if (bond_slave_can_tx(tx_slave))
>+			new_arr->arr[new_arr->count++] = tx_slave;
>+	}
>+
>+	spin_lock(&bond_info->slave_arr_lock);
>+	old_arr = bond_info->slave_arr;
>+	rcu_assign_pointer(bond_info->slave_arr, new_arr);
>+	spin_unlock(&bond_info->slave_arr_lock);
>+	if (old_arr)
>+		kfree_rcu(old_arr, rcu);
>+
>+	return 0;
>+}
>+
> int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> 	struct ethhdr *eth_data;
> 	struct slave *tx_slave = NULL;
> 	u32 hash_index;
>@@ -1429,12 +1463,13 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> 							      hash_index & 0xFF,
> 							      skb->len);
> 			} else {
>-				struct list_head *iter;
>-				int idx = hash_index % bond->slave_cnt;
>-
>-				bond_for_each_slave_rcu(bond, tx_slave, iter)
>-					if (--idx < 0)
>-						break;
>+				struct tlb_up_slave *slaves;
>+				rcu_read_lock();
>+				slaves = rcu_dereference(bond_info->slave_arr);
>+				if (slaves && slaves->count)
>+					tx_slave = slaves->arr[hash_index %
>+							       slaves->count];
>+				rcu_read_unlock();
> 			}
> 			break;
> 		}
>@@ -1721,6 +1756,11 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
> 			 */
> 		}
> 	}
>+
>+	if (bond_is_nondyn_tlb(bond)) {
>+		if (bond_tlb_update_slave_arr(bond))
>+			pr_err("Failed to build slave-array for TLB mode.\n");
>+	}
> }
> 
> /**
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index 5fc76c01636c..731a8e830639 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -139,12 +139,23 @@ struct tlb_slave_info {
> 			 */
> };
> 
>+struct tlb_up_slave {
>+	unsigned int	count;
>+	struct rcu_head rcu;
>+	struct slave	*arr[0];
>+};
>+
> struct alb_bond_info {
> 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
> 	spinlock_t		tx_hashtbl_lock;
> 	u32			unbalanced_load;
> 	int			tx_rebalance_counter;
> 	int			lp_counter;
>+	/* -------- non-dynamic tlb mode only ---------*/
>+	struct tlb_up_slave __rcu *slave_arr;	  /* Up slaves */
>+	spinlock_t		  slave_arr_lock; /* Lock to manage concurrent
>+						   * writers
>+						   */
> 	/* -------- rlb parameters -------- */
> 	int rlb_enabled;
> 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 0b4d9cde0b05..ad9b3dce07d8 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -265,6 +265,12 @@ static inline bool bond_is_lb(const struct bonding *bond)
> 	       BOND_MODE(bond) == BOND_MODE_ALB;
> }
> 
>+static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
>+{
>+	return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
>+	       (bond->params.tlb_dynamic_lb == 0);
>+}
>+
> static inline bool bond_mode_uses_arp(int mode)
> {
> 	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
>-- 
>2.0.0.526.g5318336

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
