From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Fri, 06 Jan 2012 13:33:25 -0800
Message-ID: <7449.1325885605@death>
References: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	Cong Wang <amwang@redhat.com>
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:59195 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756924Ab2AFVfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 16:35:12 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 6 Jan 2012 16:35:11 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q06LXSPp290838
	for <netdev@vger.kernel.org>; Fri, 6 Jan 2012 16:33:28 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q06LXSDJ020093
	for <netdev@vger.kernel.org>; Fri, 6 Jan 2012 19:33:28 -0200
In-reply-to: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Uvarov <maxim.uvarov@oracle.com> wrote:

>No need to lock soft irqs under bond_alb_xmit()
>which already has softirq disabled.

	In commit:

commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:50 2007 -0700

    bonding: Convert more locks to _bh, acquire rtnl, for new locking
    
        Convert more lock acquisitions to _bh flavor to avoid deadlock
    with workqueue activity and add acquisition of RTNL in appropriate places.
    Affects ALB mode, as well as core bonding functions and sysfs.
    
    Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

	the _lock_tx_hashtbl was upgraded from regular to _bh to prevent
deadlocks.  I don't recall right offhand what deadlock this prevented,
but are we sure there are no possible issues with converting this lock
back to a non-_bh acquisition?  A lot has changed since then, so I'm
willing to believe it's no longer an issue, but I think a bit of
research is warranted.

	Also, unlike my log message from the above commit, it would be
useful for future reference to describe the actual problem that this is
fixing.

	-J

>Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
>Signed-off-by: Cong Wang <amwang@redhat.com>
>---
> drivers/net/bonding/bond_alb.c |   40 +++++++++++++++++++++++++++-------------
> 1 files changed, 27 insertions(+), 13 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 106b88a..42d4286 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -135,7 +135,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
> 	struct tlb_client_info *tx_hash_table;
> 	u32 index;
>
>-	_lock_tx_hashtbl(bond);
>+	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>
> 	/* clear slave from tx_hashtbl */
> 	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
>@@ -152,7 +152,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
>
> 	tlb_init_slave(slave);
>
>-	_unlock_tx_hashtbl(bond);
>+	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
> }
>
> /* Must be called before starting the monitor timer */
>@@ -226,15 +226,13 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
> 	return least_loaded;
> }
>
>-/* Caller must hold bond lock for read */
>-static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
>+static struct slave *__tlb_choose_channel(struct bonding *bond, u32 hash_index,
>+						u32 skb_len)
> {
> 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> 	struct tlb_client_info *hash_table;
> 	struct slave *assigned_slave;
>
>-	_lock_tx_hashtbl(bond);
>-
> 	hash_table = bond_info->tx_hashtbl;
> 	assigned_slave = hash_table[hash_index].tx_slave;
> 	if (!assigned_slave) {
>@@ -263,11 +261,27 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
> 		hash_table[hash_index].tx_bytes += skb_len;
> 	}
>
>-	_unlock_tx_hashtbl(bond);
>-
> 	return assigned_slave;
> }
>
>+/* Caller must hold bond lock for read */
>+static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index,
>+					u32 skb_len)
>+{
>+	struct slave *tx_slave;
>+	/*
>+	 * We don't need to disable softirq here, becase
>+	 * tlb_choose_channel() is only called by bond_alb_xmit()
>+	 * which already has softirq disabled.
>+	 */
>+	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>+	tx_slave = __tlb_choose_channel(bond, hash_index, skb_len);
>+	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>+	return tx_slave;
>+}
>+
>+
>+
> /*********************** rlb specific functions ***************************/
> static inline void _lock_rx_hashtbl(struct bonding *bond)
> {
>@@ -548,7 +562,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
> 	struct rlb_client_info *client_info;
> 	u32 hash_index;
>
>-	_lock_rx_hashtbl(bond);
>+	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>
> 	hash_index = bond_info->rx_hashtbl_head;
> 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>@@ -572,7 +586,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
> 		}
> 	}
>
>-	_unlock_rx_hashtbl(bond);
>+	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
> }
>
> /* Caller must hold both bond and ptr locks for read */
>@@ -584,7 +598,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 	struct rlb_client_info *client_info;
> 	u32 hash_index = 0;
>
>-	_lock_rx_hashtbl(bond);
>+	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>
> 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
> 	client_info = &(bond_info->rx_hashtbl[hash_index]);
>@@ -600,7 +614,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>
> 			assigned_slave = client_info->slave;
> 			if (assigned_slave) {
>-				_unlock_rx_hashtbl(bond);
>+				spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
> 				return assigned_slave;
> 			}
> 		} else {
>@@ -652,7 +666,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 		}
> 	}
>
>-	_unlock_rx_hashtbl(bond);
>+	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>
> 	return assigned_slave;
> }
>-- 
>1.7.4.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
