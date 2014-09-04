From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Wed, 3 Sep 2014 17:57:20 -0700
Message-ID: <CAF2d9jhck53cHzynjJTJ6pDOXEYbkvybOnZtTA6W_+GTSv8UQw@mail.gmail.com>
References: <1409780851-32081-1-git-send-email-maheshb@google.com> <3024.1409784713@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:38412 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932813AbaIDA5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 20:57:41 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so9605509vcb.8
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 17:57:40 -0700 (PDT)
In-Reply-To: <3024.1409784713@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 3:51 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>>Earlier change to use usable slave array for TLB mode had an additional
>>performance advantage. So extending the same logic to all other modes
>>that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>>Also consolidating this with the earlier TLB change.
>>
>>The main idea is to build the usable slaves array in the control path
>>and use that array for slave selection during xmit operation.
>>
>>Measured performance in a setup with a bond of 4x1G NICs with 200
>>instances of netperf for the modes involved (3ad, xor, tlb)
>>cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>
>>Mode        TPS-Before   TPS-After
>>
>>802.3ad   : 468,694      493,101
>>TLB (lb=0): 392,583      392,965
>>XOR       : 475,696      484,517
>
>         In general I think this is an improvement over traversing linked
> lists; however, I have a couple of comments.
>
>         First, for the 802.3ad mode, is the case within
> bond_3ad_state_machine_handler that runs the ad_agg_selection_logic (if
> the agg_select_timer runs out) handled?  This may change the active
> aggregator, and thus the list of slaves that ought to be in the array,
> and looking at the patch I don't see where this would be taken care of.
>
>         As a practical matter, the usage of the agg_select_timer is such
> that it's unlikely to cause a change of active aggregator (it will
> usually set an active aggregator when there is none, e.g., during open
> processing), but this case should probably either be handled or
> commented to explain why it is safe.
>
Good point. I'll fix that!

>         It may be that the bond_3ad_initialize call to set the
> agg_select_timer to 8 seconds is no longer needed, but for now it's
> there and may change the active aggregator.
>
>         One more comment below.
>
>>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>---
>> drivers/net/bonding/bond_3ad.c  |  77 ++++---------------------------
>> drivers/net/bonding/bond_alb.c  |  43 ++---------------
>> drivers/net/bonding/bond_alb.h  |   8 ----
>> drivers/net/bonding/bond_main.c | 100 ++++++++++++++++++++++++++++++++++++----
>> drivers/net/bonding/bonding.h   |   8 ++++
>> 5 files changed, 113 insertions(+), 123 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>>index ee2c73a9de39..d42fd65fdfa9 100644
>>--- a/drivers/net/bonding/bond_3ad.c
>>+++ b/drivers/net/bonding/bond_3ad.c
>>@@ -1717,6 +1717,8 @@ static void ad_enable_collecting_distributing(struct port *port)
>>                        port->actor_port_number,
>>                        port->aggregator->aggregator_identifier);
>>               __enable_port(port);
>>+              if (bond_update_slave_arr(port->slave->bond, NULL))
>>+                      pr_debug("Failed to build slave-array for 3ad mode.\n");
>>       }
>> }
>>
>>@@ -1733,6 +1735,8 @@ static void ad_disable_collecting_distributing(struct port *port)
>>                        port->actor_port_number,
>>                        port->aggregator->aggregator_identifier);
>>               __disable_port(port);
>>+              if (bond_update_slave_arr(port->slave->bond, NULL))
>>+                      pr_debug("Failed to build slave-array for 3ad mode.\n");
>>       }
>> }
>>
>>@@ -1917,6 +1921,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
>>       __update_lacpdu_from_port(port);
>>       ad_lacpdu_send(port);
>>
>>+      if (bond_update_slave_arr(bond, slave))
>>+              pr_debug("Failed to build slave-array for 3AD mode.\n");
>>+
>>       /* check if this aggregator is occupied */
>>       if (aggregator->lag_ports) {
>>               /* check if there are other ports related to this aggregator
>>@@ -2311,6 +2318,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>>        */
>>       port->sm_vars |= AD_PORT_BEGIN;
>>
>>+      if (bond_update_slave_arr(slave->bond, NULL))
>>+              pr_debug("Failed to build slave-array for 3ad mode.\n");
>>+
>>       __release_state_machine_lock(port);
>> }
>>
>>@@ -2407,73 +2417,6 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>>       return ret;
>> }
>>
>>-int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>-{
>>-      struct bonding *bond = netdev_priv(dev);
>>-      struct slave *slave, *first_ok_slave;
>>-      struct aggregator *agg;
>>-      struct ad_info ad_info;
>>-      struct list_head *iter;
>>-      int slaves_in_agg;
>>-      int slave_agg_no;
>>-      int agg_id;
>>-
>>-      if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>-              netdev_dbg(dev, "__bond_3ad_get_active_agg_info failed\n");
>>-              goto err_free;
>>-      }
>>-
>>-      slaves_in_agg = ad_info.ports;
>>-      agg_id = ad_info.aggregator_id;
>>-
>>-      if (slaves_in_agg == 0) {
>>-              netdev_dbg(dev, "active aggregator is empty\n");
>>-              goto err_free;
>>-      }
>>-
>>-      slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
>>-      first_ok_slave = NULL;
>>-
>>-      bond_for_each_slave_rcu(bond, slave, iter) {
>>-              agg = SLAVE_AD_INFO(slave)->port.aggregator;
>>-              if (!agg || agg->aggregator_identifier != agg_id)
>>-                      continue;
>>-
>>-              if (slave_agg_no >= 0) {
>>-                      if (!first_ok_slave && bond_slave_can_tx(slave))
>>-                              first_ok_slave = slave;
>>-                      slave_agg_no--;
>>-                      continue;
>>-              }
>>-
>>-              if (bond_slave_can_tx(slave)) {
>>-                      bond_dev_queue_xmit(bond, skb, slave->dev);
>>-                      goto out;
>>-              }
>>-      }
>>-
>>-      if (slave_agg_no >= 0) {
>>-              netdev_err(dev, "Couldn't find a slave to tx on for aggregator ID %d\n",
>>-                         agg_id);
>>-              goto err_free;
>>-      }
>>-
>>-      /* we couldn't find any suitable slave after the agg_no, so use the
>>-       * first suitable found, if found.
>>-       */
>>-      if (first_ok_slave)
>>-              bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
>>-      else
>>-              goto err_free;
>>-
>>-out:
>>-      return NETDEV_TX_OK;
>>-err_free:
>>-      /* no suitable interface, frame not sent */
>>-      dev_kfree_skb_any(skb);
>>-      goto out;
>>-}
>>-
>> int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>>                        struct slave *slave)
>> {
>>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>>index 73c21e233131..b2be7b3216d6 100644
>>--- a/drivers/net/bonding/bond_alb.c
>>+++ b/drivers/net/bonding/bond_alb.c
>>@@ -200,7 +200,6 @@ static int tlb_initialize(struct bonding *bond)
>> static void tlb_deinitialize(struct bonding *bond)
>> {
>>       struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>-      struct tlb_up_slave *arr;
>>
>>       _lock_tx_hashtbl_bh(bond);
>>
>>@@ -208,10 +207,6 @@ static void tlb_deinitialize(struct bonding *bond)
>>       bond_info->tx_hashtbl = NULL;
>>
>>       _unlock_tx_hashtbl_bh(bond);
>>-
>>-      arr = rtnl_dereference(bond_info->slave_arr);
>>-      if (arr)
>>-              kfree_rcu(arr, rcu);
>> }
>>
>> static long long compute_gap(struct slave *slave)
>>@@ -1409,39 +1404,9 @@ out:
>>       return NETDEV_TX_OK;
>> }
>>
>>-static int bond_tlb_update_slave_arr(struct bonding *bond,
>>-                                   struct slave *skipslave)
>>-{
>>-      struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>-      struct slave *tx_slave;
>>-      struct list_head *iter;
>>-      struct tlb_up_slave *new_arr, *old_arr;
>>-
>>-      new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>>-                        GFP_ATOMIC);
>>-      if (!new_arr)
>>-              return -ENOMEM;
>>-
>>-      bond_for_each_slave(bond, tx_slave, iter) {
>>-              if (!bond_slave_can_tx(tx_slave))
>>-                      continue;
>>-              if (skipslave == tx_slave)
>>-                      continue;
>>-              new_arr->arr[new_arr->count++] = tx_slave;
>>-      }
>>-
>>-      old_arr = rtnl_dereference(bond_info->slave_arr);
>>-      rcu_assign_pointer(bond_info->slave_arr, new_arr);
>>-      if (old_arr)
>>-              kfree_rcu(old_arr, rcu);
>>-
>>-      return 0;
>>-}
>>-
>> int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>> {
>>       struct bonding *bond = netdev_priv(bond_dev);
>>-      struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>       struct ethhdr *eth_data;
>>       struct slave *tx_slave = NULL;
>>       u32 hash_index;
>>@@ -1462,9 +1427,9 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>                                                             hash_index & 0xFF,
>>                                                             skb->len);
>>                       } else {
>>-                              struct tlb_up_slave *slaves;
>>+                              struct bond_up_slave *slaves;
>>
>>-                              slaves = rcu_dereference(bond_info->slave_arr);
>>+                              slaves = rcu_dereference(bond->slave_arr);
>>                               if (slaves && slaves->count)
>>                                       tx_slave = slaves->arr[hash_index %
>>                                                              slaves->count];
>>@@ -1734,7 +1699,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
>>       }
>>
>>       if (bond_is_nondyn_tlb(bond))
>>-              if (bond_tlb_update_slave_arr(bond, slave))
>>+              if (bond_update_slave_arr(bond, slave))
>>                       pr_err("Failed to build slave-array for TLB mode.\n");
>>
>> }
>>@@ -1762,7 +1727,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
>>       }
>>
>>       if (bond_is_nondyn_tlb(bond)) {
>>-              if (bond_tlb_update_slave_arr(bond, NULL))
>>+              if (bond_update_slave_arr(bond, NULL))
>>                       pr_err("Failed to build slave-array for TLB mode.\n");
>>       }
>> }
>>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>>index aaeac61d03cf..5fc76c01636c 100644
>>--- a/drivers/net/bonding/bond_alb.h
>>+++ b/drivers/net/bonding/bond_alb.h
>>@@ -139,20 +139,12 @@ struct tlb_slave_info {
>>                        */
>> };
>>
>>-struct tlb_up_slave {
>>-      unsigned int    count;
>>-      struct rcu_head rcu;
>>-      struct slave    *arr[0];
>>-};
>>-
>> struct alb_bond_info {
>>       struct tlb_client_info  *tx_hashtbl; /* Dynamically allocated */
>>       spinlock_t              tx_hashtbl_lock;
>>       u32                     unbalanced_load;
>>       int                     tx_rebalance_counter;
>>       int                     lp_counter;
>>-      /* -------- non-dynamic tlb mode only ---------*/
>>-      struct tlb_up_slave __rcu *slave_arr;     /* Up slaves */
>>       /* -------- rlb parameters -------- */
>>       int rlb_enabled;
>>       struct rlb_client_info  *rx_hashtbl;    /* Receive hash table */
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index f0f5eab0fab1..b0e8e7cfa10f 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1693,6 +1693,9 @@ static int __bond_release_one(struct net_device *bond_dev,
>>       if (BOND_MODE(bond) == BOND_MODE_8023AD)
>>               bond_3ad_unbind_slave(slave);
>>
>>+      else if (BOND_MODE(bond) == BOND_MODE_XOR)
>>+              bond_update_slave_arr(bond, slave);
>>+
>>       write_unlock_bh(&bond->lock);
>>
>>       netdev_info(bond_dev, "Releasing %s interface %s\n",
>>@@ -2009,6 +2012,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                               bond_alb_handle_link_change(bond, slave,
>>                                                           BOND_LINK_UP);
>>
>>+                      if (BOND_MODE(bond) == BOND_MODE_XOR)
>>+                              bond_update_slave_arr(bond, NULL);
>>+
>>                       if (!bond->curr_active_slave ||
>>                           (slave == bond->primary_slave))
>>                               goto do_failover;
>>@@ -2037,6 +2043,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                               bond_alb_handle_link_change(bond, slave,
>>                                                           BOND_LINK_DOWN);
>>
>>+                      if (BOND_MODE(bond) == BOND_MODE_XOR)
>>+                              bond_update_slave_arr(bond, slave);
>>+
>>                       if (slave == rcu_access_pointer(bond->curr_active_slave))
>>                               goto do_failover;
>>
>>@@ -3149,6 +3158,7 @@ static int bond_open(struct net_device *bond_dev)
>> static int bond_close(struct net_device *bond_dev)
>> {
>>       struct bonding *bond = netdev_priv(bond_dev);
>>+      struct bond_up_slave *arr;
>>
>>       bond_work_cancel_all(bond);
>>       bond->send_peer_notif = 0;
>>@@ -3156,6 +3166,10 @@ static int bond_close(struct net_device *bond_dev)
>>               bond_alb_deinitialize(bond);
>>       bond->recv_probe = NULL;
>>
>>+      arr = rtnl_dereference(bond->slave_arr);
>>+      if (arr)
>>+          kfree_rcu(arr, rcu);
>>+
>>       return 0;
>> }
>>
>>@@ -3684,15 +3698,84 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>>       return NETDEV_TX_OK;
>> }
>>
>>-/* In bond_xmit_xor() , we determine the output device by using a pre-
>>- * determined xmit_hash_policy(), If the selected device is not enabled,
>>- * find the next active slave.
>>+/* Build the usable slaves array in control path for modes that use xmit-hash
>>+ * to determine the slave interface -
>>+ * (a) BOND_MODE_8023AD
>>+ * (b) BOND_MODE_XOR
>>+ * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>>  */
>>-static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
>>+int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>> {
>>-      struct bonding *bond = netdev_priv(bond_dev);
>>+      struct slave *slave;
>>+      struct list_head *iter;
>>+      struct bond_up_slave *new_arr, *old_arr;
>>+      int slaves_in_agg;
>>+      int agg_id = 0;
>>+      int ret = 0;
>>+
>>+      new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
>>+                        GFP_ATOMIC);
>>+      if (!new_arr) {
>>+              ret = -ENOMEM;
>>+              goto out;
>>+      }
>
>         If this allocation fails, won't the in-place array be left with
> a reference to a slave that has potentially been freed, if, e.g., the
> call came in via the __bond_release_one path?
>
>         I haven't tested it, but it seems plausible that we could
> resolve this by writing over the "disappearing" slave's entry in the
> array, e.g., move the last element of the array to the "disappearing"
> element.
>
Allocation failure could be catastrophic. If such a small alloc
request fails, the machine would have to worrying about lot other
things. Having said that, I think we can fix it by overwriting the
disappearing slave with the last entry (as you have suggested).

One other thing I should do is to treat this as an error and use
pr_err() instead of pr_debug() for these alloc failures.


>         If this is a problem, the same logic exists in the current
> (tlb-only) code, so a fix for stable may be needed as well.
>
Agreed. I'll cook another patch for the stable branch as well.

>         -J
>
>
>>+      if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>+              struct ad_info ad_info;
>>+
>>+              if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>+                      pr_debug("__bond_3ad_get_active_agg_info failed\n");
>>+                      kfree_rcu(new_arr, rcu);
>>+                      ret = -EINVAL;
>>+                      goto out;
>>+              }
>>+              slaves_in_agg = ad_info.ports;
>>+              agg_id = ad_info.aggregator_id;
>>+      }
>>+      bond_for_each_slave(bond, slave, iter) {
>>+              if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>+                      struct aggregator *agg;
>>+
>>+                      agg = SLAVE_AD_INFO(slave)->port.aggregator;
>>+                      if (!agg || agg->aggregator_identifier != agg_id)
>>+                              continue;
>>+              }
>>+              if (!bond_slave_can_tx(slave))
>>+                      continue;
>>+              if (skipslave == slave)
>>+                      continue;
>>+              new_arr->arr[new_arr->count++] = slave;
>>+      }
>>
>>-      bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
>>+      old_arr = rcu_dereference_protected(bond->slave_arr,
>>+                                          lockdep_rtnl_is_held() ||
>>+                                          lockdep_is_held(&bond->lock) ||
>>+                                          lockdep_is_held(&bond->curr_slave_lock));
>>+      rcu_assign_pointer(bond->slave_arr, new_arr);
>>+      if (old_arr)
>>+              kfree_rcu(old_arr, rcu);
>>+
>>+out:
>>+      return ret;
>>+}
>>+
>>+/* Use this Xmit function for 3AD as well as XOR modes. The current
>>+ * usable slave array is formed in the control path. The xmit function
>>+ * just calculates hash and sends the packet out.
>>+ */
>>+int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
>>+{
>>+      struct bonding *bond = netdev_priv(dev);
>>+      struct slave *slave;
>>+      struct bond_up_slave *slaves;
>>+
>>+      slaves = rcu_dereference(bond->slave_arr);
>>+      if (slaves && slaves->count) {
>>+              slave = slaves->arr[bond_xmit_hash(bond, skb) % slaves->count];
>>+              bond_dev_queue_xmit(bond, skb, slave->dev);
>>+      } else {
>>+              dev_kfree_skb_any(skb);
>>+              atomic_long_inc(&dev->tx_dropped);
>>+      }
>>
>>       return NETDEV_TX_OK;
>> }
>>@@ -3794,12 +3877,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>>               return bond_xmit_roundrobin(skb, dev);
>>       case BOND_MODE_ACTIVEBACKUP:
>>               return bond_xmit_activebackup(skb, dev);
>>+      case BOND_MODE_8023AD:
>>       case BOND_MODE_XOR:
>>-              return bond_xmit_xor(skb, dev);
>>+              return bond_3ad_xor_xmit(skb, dev);
>>       case BOND_MODE_BROADCAST:
>>               return bond_xmit_broadcast(skb, dev);
>>-      case BOND_MODE_8023AD:
>>-              return bond_3ad_xmit_xor(skb, dev);
>>       case BOND_MODE_ALB:
>>               return bond_alb_xmit(skb, dev);
>>       case BOND_MODE_TLB:
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>index aace510d08d1..4a6195c0de60 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -177,6 +177,12 @@ struct slave {
>>       struct kobject kobj;
>> };
>>
>>+struct bond_up_slave {
>>+      unsigned int    count;
>>+      struct rcu_head rcu;
>>+      struct slave    *arr[0];
>>+};
>>+
>> /*
>>  * Link pseudo-state only used internally by monitors
>>  */
>>@@ -196,6 +202,7 @@ struct bonding {
>>       struct   slave __rcu *curr_active_slave;
>>       struct   slave __rcu *current_arp_slave;
>>       struct   slave *primary_slave;
>>+      struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>>       bool     force_primary;
>>       s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>>       int     (*recv_probe)(const struct sk_buff *, struct bonding *,
>>@@ -527,6 +534,7 @@ const char *bond_slave_link_status(s8 link);
>> struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>>                                             struct net_device *end_dev,
>>                                             int level);
>>+int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>>
>> #ifdef CONFIG_PROC_FS
>> void bond_create_proc_entry(struct bonding *bond);
>>--
>>2.1.0.rc2.206.gedb03e5
>>
>
> ---
>         -Jay Vosburgh, jay.vosburgh@canonical.com
