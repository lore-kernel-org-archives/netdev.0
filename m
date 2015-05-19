From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: [PATCH] Experimental new bonding driver mode=batman
Date: Tue, 19 May 2015 02:09:43 -0400
Message-ID: <555AD3A7.7050202@netscape.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080506080704070806000801"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m02.mx.aol.com ([64.12.143.76]:53907 "EHLO
	omr-m02.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbbESGJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 02:09:46 -0400
Received: from mtaout-aaf02.mx.aol.com (mtaout-aaf02.mx.aol.com [172.26.127.98])
	by omr-m02.mx.aol.com (Outbound Mail Relay) with ESMTP id 52452700000BB
	for <netdev@vger.kernel.org>; Tue, 19 May 2015 02:09:45 -0400 (EDT)
Received: from [192.168.1.15] (pool-71-164-139-83.dllstx.fios.verizon.net [71.164.139.83])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mtaout-aaf02.mx.aol.com (MUA/Third Party Client Interface) with ESMTPSA id D700238000081
	for <netdev@vger.kernel.org>; Tue, 19 May 2015 02:09:44 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080506080704070806000801
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hello,

I've written a new mode for the kernel bonding driver.  It's similar to
the round-robin mode, but it keeps statistics on TCP resends so as to
favor slave devices with more bandwidth when choosing where to send
packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
to work okay, but it should be considered experimental.

Still, it should be safe to apply this patch as it doesn't do anything
unless you specify "mode=batman" on the driver command line.

Signed-off-by: Patrick Simmons <linuxrocks123@netscape.net>

-- 
If I'm not here, I've gone out to find myself.  If I get back before I
return, please keep me here.

--------------080506080704070806000801
Content-Type: text/x-patch;
 name="bond_mode_batman.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="bond_mode_batman.patch"

--- tree_a/include/uapi/linux/if_bonding.h	2015-05-06 16:04:23.000000000 -0400
+++ tree_b/include/uapi/linux/if_bonding.h	2015-05-18 14:49:16.916558030 -0400
@@ -70,6 +70,7 @@
 #define BOND_MODE_8023AD        4
 #define BOND_MODE_TLB           5
 #define BOND_MODE_ALB		6 /* TLB + RLB (receive load balancing) */
+#define BOND_MODE_BATMAN        7
 
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
--- tree_a/include/net/bonding.h	2015-05-06 16:04:23.000000000 -0400
+++ tree_b/include/net/bonding.h	2015-05-18 16:54:46.452900354 -0400
@@ -15,6 +15,7 @@
 #ifndef _NET_BONDING_H
 #define _NET_BONDING_H
 
+#include <linux/kthread.h>
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
@@ -241,6 +242,7 @@ struct bonding {
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
 	struct rtnl_link_stats64 bond_stats;
+    struct task_struct* battimer_task;
 };
 
 #define bond_slave_get_rcu(dev) \
@@ -650,6 +652,22 @@ static inline int bond_get_targets_ip(__
 	return -1;
 }
 
+struct batnode
+{
+     struct batnode* next_batnode;
+     char slvname[IFNAMSIZ];
+     unsigned long jiffiestamp;
+     u32 tcp_seq_num;
+     u16 port_id;
+};
+
+struct slave_congestion_node
+{
+     struct slave_congestion_node* next_slave;
+     char this_slave[IFNAMSIZ];
+     u32 congestion_counter;
+};
+
 /* exported from bond_main.c */
 extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
@@ -660,6 +678,58 @@ extern const struct bond_parm_tbl fail_o
 extern const struct bond_parm_tbl pri_reselect_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
 
+#define BATTABLE_SIZE 256
+static struct batnode battable[BATTABLE_SIZE];
+static struct slave_congestion_node* slavelist_head_ptr = NULL;
+
+static struct slave_congestion_node* get_slave_congestion_node(char* slvname)
+{
+     //printk("In get_slave_congestion_node: 0x%zx\n",the_slave);
+     struct slave_congestion_node* cur_slave = slavelist_head_ptr;
+     while(cur_slave)
+     {
+          if(strcmp(cur_slave->this_slave,slvname)==0)
+          {
+               //printk("Found a match: 0x%zx\n",cur_slave);
+               return cur_slave;
+          }
+
+          if(!cur_slave->next_slave)
+               break;
+          cur_slave = cur_slave->next_slave;
+     }     
+
+     //Create new slave node
+     if(!cur_slave) //special case head
+     {
+          cur_slave = (struct slave_congestion_node*)(kmalloc(sizeof(struct slave_congestion_node),GFP_ATOMIC));
+          slavelist_head_ptr = cur_slave;
+     }
+     else
+     {
+          cur_slave->next_slave = (struct slave_congestion_node*)(kmalloc(sizeof(struct slave_congestion_node),GFP_ATOMIC));
+          cur_slave = cur_slave->next_slave;
+     }
+
+     //Initialize new slave node
+     cur_slave->next_slave = NULL;
+     strlcpy(cur_slave->this_slave,slvname,IFNAMSIZ);
+     cur_slave->congestion_counter = 1;
+     
+     //printk("Created new congestion node: 0x%zx\n",cur_slave);
+     return cur_slave;
+}
+
+static void slave_congestion_increment(char* the_slave)
+{
+     get_slave_congestion_node(the_slave)->congestion_counter++;
+}
+
+static void slave_congestion_decrement(char* the_slave)
+{
+     get_slave_congestion_node(the_slave)->congestion_counter--;
+}
+
 /* exported from bond_netlink.c */
 extern struct rtnl_link_ops bond_link_ops;
 
--- tree_a/drivers/net/bonding/bond_main.c	2015-05-06 16:04:23.000000000 -0400
+++ tree_b/drivers/net/bonding/bond_main.c	2015-05-18 20:17:46.914627467 -0400
@@ -71,6 +71,8 @@
 #include <linux/if_bonding.h>
 #include <linux/jiffies.h>
 #include <linux/preempt.h>
+#include <linux/spinlock_types.h>
+#include <linux/spinlock.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
@@ -135,7 +137,7 @@ module_param(mode, charp, 0);
 MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
 		       "1 for active-backup, 2 for balance-xor, "
 		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
-		       "6 for balance-alb");
+		 "6 for balance-alb, 7 for batman");
 module_param(primary, charp, 0);
 MODULE_PARM_DESC(primary, "Primary network device to use");
 module_param(primary_reselect, charp, 0);
@@ -205,6 +207,8 @@ static int bond_mode	= BOND_MODE_ROUNDRO
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
 
+static DEFINE_SPINLOCK(batlock);
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static int bond_init(struct net_device *bond_dev);
@@ -225,9 +229,10 @@ const char *bond_mode_name(int mode)
 		[BOND_MODE_8023AD] = "IEEE 802.3ad Dynamic link aggregation",
 		[BOND_MODE_TLB] = "transmit load balancing",
 		[BOND_MODE_ALB] = "adaptive load balancing",
+        [BOND_MODE_BATMAN] = "load balancing (Batman)",
 	};
 
-	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
+	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_BATMAN)
 		return "unknown";
 
 	return names[mode];
@@ -856,7 +861,8 @@ void bond_change_active_slave(struct bon
 	 */
 	if (netif_running(bond->dev) && (bond->params.resend_igmp > 0) &&
 	    ((bond_uses_primary(bond) && new_active) ||
-	     BOND_MODE(bond) == BOND_MODE_ROUNDROBIN)) {
+	     BOND_MODE(bond) == BOND_MODE_ROUNDROBIN ||
+	     BOND_MODE(bond) == BOND_MODE_BATMAN)) {
 		bond->igmp_retrans = bond->params.resend_igmp;
 		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
 	}
@@ -1082,6 +1088,69 @@ static bool bond_should_deliver_exact_ma
 	return false;
 }
 
+static void batman_normalize_congestion(struct bonding* bond, int* congestion)
+{
+     static long unsigned int jiffiestamp = 0;
+     long unsigned int jiffie_temp = jiffies;
+     struct slave* slave;
+     struct list_head* i;
+     if(jiffie_temp!=jiffiestamp && jiffie_temp%1000==0) //every thousand packets, normalize congestion
+     {
+          printk(KERN_DEBUG "batman: congestion normalization has occurred.\n");
+          bond_for_each_slave_rcu(bond,slave,i)
+          {
+               struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+               if(congest_current->congestion_counter > 1)
+               {
+                    (*congestion)--;
+                    congest_current->congestion_counter--;
+               }
+          }
+          jiffiestamp = jiffie_temp;
+     }
+     else if((jiffie_temp - jiffiestamp) / HZ > 60)
+     {
+          printk(KERN_DEBUG "batman: failsafe reset invoked: %lu, %lu, %lu\n",jiffie_temp, jiffiestamp, (jiffie_temp - jiffiestamp) / HZ);
+          *congestion = 0;
+          bond_for_each_slave_rcu(bond,slave,i)
+          {
+               struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+               congest_current->congestion_counter = 1;
+               (*congestion)++;
+          }
+          jiffiestamp = jiffie_temp;
+     }
+}
+
+static int batman_timer_invoke(void* bond_)
+{
+     struct bonding* bond = (struct bonding*)(bond_);
+     struct slave* slave;
+     struct list_head* i;
+
+     while(!kthread_should_stop())
+     {
+          unsigned long batflags;
+          long unsigned int jiffiestamp = jiffies;
+          
+          msleep(10*1000);
+          rcu_read_lock();
+          spin_lock_irqsave(&batlock,batflags);
+          
+          long unsigned int jiffie_temp = jiffies;
+          if(!(jiffie_temp - jiffiestamp < 5 * HZ))
+               bond_for_each_slave_rcu(bond,slave,i)
+               {
+                    struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+                    if(congest_current->congestion_counter >= 2)
+                         congest_current->congestion_counter/=2;
+               }
+
+          spin_unlock_irqrestore(&batlock,batflags);
+          rcu_read_unlock();
+     }
+}
+
 static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
@@ -1100,7 +1169,67 @@ static rx_handler_result_t bond_handle_f
 	slave = bond_slave_get_rcu(skb->dev);
 	bond = slave->bond;
 
-	recv_probe = ACCESS_ONCE(bond->recv_probe);
+    //This seems as good a place as any to put this.
+    if(skb->protocol == htons(ETH_P_IP))
+    {
+         struct iphdr* iph = ip_hdr(skb);
+         if(iph->protocol == IPPROTO_TCP)
+         {
+              //printk(KERN_EMERG "batman recv handler Chekpoint 1\n");
+              
+              //Headers
+              struct tcphdr* tcp_header = tcp_hdr(skb);
+              u16 port_id = max(ntohs(tcp_header->source),ntohs(tcp_header->dest)); 
+              u32 ack_seq = ntohl(tcp_header->ack_seq);
+
+              unsigned long batflags;
+              spin_lock_irqsave(&batlock,batflags);
+              
+              //Iterate over hash table, deleting old congestion nodes along the way
+              struct batnode* backptr = NULL;
+              struct batnode* battable_ptr = battable + (port_id % BATTABLE_SIZE);
+              while(battable_ptr && battable_ptr->jiffiestamp)
+              {
+                   if(battable_ptr->port_id == port_id && battable_ptr->tcp_seq_num < ack_seq ||
+                      (jiffies - battable_ptr->jiffiestamp) / HZ > 60)
+                   {
+                        //Special case delete from head
+                        if(!backptr)
+                             if(battable_ptr->next_batnode)
+                             {
+                                  struct batnode* tofree = battable_ptr->next_batnode;
+                                  memcpy(battable_ptr,battable_ptr->next_batnode,sizeof(struct batnode));
+                                  kfree(tofree);
+                             }
+                             else
+                             {
+                                  battable_ptr->jiffiestamp = 0;
+                                  break;
+                             }
+                        else
+                        {
+                             backptr->next_batnode = battable_ptr->next_batnode;
+                             kfree(battable_ptr);
+                             battable_ptr = backptr->next_batnode;
+                        }
+
+                        continue;
+                   }
+                        
+                   //Go to next in sequence
+                   backptr = battable_ptr;
+                   battable_ptr = battable_ptr->next_batnode;
+              }
+
+              int ignored=0;
+              batman_normalize_congestion(bond,&ignored);
+
+              spin_unlock_irqrestore(&batlock,batflags);
+              //printk(KERN_EMERG "batman recv handler Chekpoint 2\n");
+         }
+    }
+    
+    recv_probe = ACCESS_ONCE(bond->recv_probe);
 	if (recv_probe) {
 		ret = recv_probe(skb, bond, slave);
 		if (ret == RX_HANDLER_CONSUMED) {
@@ -3485,7 +3614,6 @@ static int bond_set_mac_address(struct n
 	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		return bond_alb_set_mac_address(bond_dev, addr);
 
-
 	netdev_dbg(bond_dev, "bond=%p\n", bond);
 
 	/* If fail_over_mac is enabled, do nothing and return success.
@@ -3538,6 +3666,224 @@ unwind:
 	return res;
 }
 
+static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
+
+static int bond_xmit_batman(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave = NULL, *backup_slave = NULL;
+	struct list_head* i;
+    int res = 1;
+	struct iphdr *iph = ip_hdr(skb);
+
+	/*
+	 * Start with the curr_active_slave that joined the bond as the
+	 * default for sending IGMP traffic.  For failover purposes one
+	 * needs to maintain some consistency for the interface that will
+	 * send the join/membership reports.  The curr_active_slave found
+	 * will send all of this type of traffic.
+	 */
+	if ((iph->protocol == IPPROTO_IGMP) &&
+	    (skb->protocol == htons(ETH_P_IP))) {
+
+		slave = rcu_dereference(bond->curr_active_slave);
+		if (slave)
+			bond_dev_queue_xmit(bond, skb, slave->dev);
+		else
+			bond_xmit_slave_id(bond, skb, 0);
+	} else {
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 1\n");
+         
+         u32 congestion = 0;
+         struct slave_congestion_node* congest_node = NULL;
+
+         unsigned long flags;
+         spin_lock_irqsave(&batlock,flags);
+         
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 2\n");
+
+         //Choose slave to send
+         bond_for_each_slave_rcu(bond,slave,i)
+         {
+              struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+              congestion+=congest_current->congestion_counter;
+              if(!congest_node || congest_current->congestion_counter > congest_node->congestion_counter)
+                   congest_node = congest_current;
+         }
+         
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 3\n");
+         
+         //If we're not TCP, we do this
+         if(congest_node)
+              bond_for_each_slave_rcu(bond,slave,i)
+                   if(strcmp(slave->dev->name,congest_node->this_slave)==0)
+                        break;
+         else
+              slave = rcu_dereference(bond->curr_active_slave);
+
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 4\n");
+
+         //If we're TCP, update our congestion table
+         if(skb->protocol == htons(ETH_P_IP) && iph->protocol == IPPROTO_TCP)
+         {
+              //Headers
+              struct tcphdr *tcp_header = tcp_hdr(skb);
+              u16 port_id = max(ntohs(tcp_header->source),ntohs(tcp_header->dest));
+              int batidx = port_id % BATTABLE_SIZE;
+              u32 seqnum = ntohl(tcp_header->seq);
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 5\n");
+
+              batman_normalize_congestion(bond,&congestion);
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 6\n");
+              
+              //Find slave
+              u32 ratio_pos = jiffies % congestion;
+              u32 walk_pos = 0;
+              bond_for_each_slave_rcu(bond,slave,i)
+              {
+                   struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+                   walk_pos+=congest_current->congestion_counter;
+                   if(walk_pos > ratio_pos)
+                        break;
+                   backup_slave = slave;
+              }
+
+              if(!slave)
+                   slave = backup_slave;
+              if(!slave)
+              {
+                   printk(KERN_DEBUG "HOLY 13TH AMENDMENT, BATMAN!");
+                   goto end;
+              }    
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 7\n");
+              
+              //Add to hash table
+              struct batnode* backptr = NULL;
+              struct batnode* battable_ptr = battable + batidx;
+              //printk(KERN_DEBUG "battable: 0x%zx\nbattable_ptr: 0x%zx", battable, battable_ptr);
+              while(battable_ptr->jiffiestamp)
+              {
+                   if(battable_ptr->port_id==port_id && battable_ptr->tcp_seq_num == seqnum) //penalize slave that sent packet later retransmitted
+                   {
+                        //printk(KERN_DEBUG "Penalizing %s and favoring %s.\n",battable_ptr->slvname,slave->dev->name);
+                        struct slave_congestion_node* sptr = get_slave_congestion_node(battable_ptr->slvname);
+                        if(sptr->congestion_counter > 1 && strcmp(battable_ptr->slvname,slave->dev->name)!=0)
+                             sptr->congestion_counter--;
+                        if(strcmp(battable_ptr->slvname,slave->dev->name)!=0)
+                             slave_congestion_increment(slave->dev->name);
+                        else //never retransmit on same slave, unless we have no choice
+                        {
+                             struct slave* other_slave = slave;
+                             congest_node = NULL;
+                             bond_for_each_slave_rcu(bond,slave,i)
+                             {
+                                  struct slave_congestion_node* congest_current = get_slave_congestion_node(slave->dev->name);
+                                  if(strcmp(congest_current->this_slave,other_slave->dev->name)!=0 && (!congest_node || congest_current->congestion_counter > congest_node->congestion_counter))
+                                       congest_node = congest_current;
+                             }
+                             if(congest_node)
+                             {
+                                  bond_for_each_slave_rcu(bond,slave,i)
+                                       if(strcmp(congest_node->this_slave,slave->dev->name)==0)
+                                            break;
+                             }
+                             else
+                                  slave = other_slave;
+                        }
+
+                        battable_ptr->port_id = 0;
+                   }
+
+                   //Delete old failures
+                   if(!battable_ptr->port_id || (jiffies - battable_ptr->jiffiestamp) / HZ > 60)
+                   {                        
+                        //Special case delete from head
+                        if(!backptr)
+                        {
+                             if(battable_ptr->next_batnode)
+                             {
+                                  struct batnode* tofree = battable_ptr->next_batnode;
+                                  memcpy(battable_ptr,battable_ptr->next_batnode,sizeof(struct batnode));
+                                  kfree(tofree);
+                             }
+                             else
+                             {
+                                  battable_ptr->jiffiestamp = 0;
+                                  break;
+                             }
+
+                             continue;
+                        }
+                        else
+                        {
+                             backptr->next_batnode = battable_ptr->next_batnode;
+                             kfree(battable_ptr);
+                             battable_ptr = backptr;
+                        }
+                   }
+
+                   //Go to next in sequence
+                   if(battable_ptr->next_batnode)
+                   {
+                        backptr = battable_ptr;
+                        battable_ptr = battable_ptr->next_batnode;
+                   }
+                   else
+                   {
+                        struct batnode* empty = (struct batnode*)(kmalloc(sizeof(struct batnode),GFP_ATOMIC));
+                        empty->jiffiestamp = 0;
+                        empty->next_batnode = NULL;
+                        battable_ptr->next_batnode = empty;
+                        backptr = battable_ptr; //We currently won't use backptr again, but just in case.
+                        battable_ptr = empty;
+                   }
+
+                   //printk(KERN_DEBUG "Old failures natural end: battable_ptr: 0x%zx", battable_ptr);
+              }
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 8\n");
+              
+              //Create congestion packet
+              strlcpy(battable_ptr->slvname,slave->dev->name,IFNAMSIZ);
+              battable_ptr->jiffiestamp = jiffies;
+              if(!battable_ptr->jiffiestamp)
+                   battable_ptr->jiffiestamp++;
+              battable_ptr->tcp_seq_num = seqnum;
+              battable_ptr->port_id = port_id;
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 9\n");
+              
+              if(jiffies%100==0)
+              {
+                   struct slave_congestion_node* cur_slave = slavelist_head_ptr;
+                   while(cur_slave)
+                   {
+                        printk("slave 0x%zx: %s has congestion %d\n",
+                               cur_slave,cur_slave->this_slave,cur_slave->congestion_counter);
+                        cur_slave = cur_slave->next_slave;
+                   }
+              }
+
+              //printk(KERN_DEBUG "xmit_batman Checkpoint 10\n");
+         }
+
+         end:
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 11");
+         spin_unlock_irqrestore(&batlock,flags);
+
+         //printk(KERN_DEBUG "xmit_batman Checkpoint 12");
+         if(slave /*&& bond_slave_is_up(slave)*/)
+              bond_dev_queue_xmit(bond, skb, slave->dev);
+         else
+              bond_xmit_slave_id(bond, skb, 0);
+    }
+
+	return NETDEV_TX_OK;
+}
+
 /**
  * bond_xmit_slave_id - transmit skb through slave with slave_id
  * @bond: bonding device that is transmitting
@@ -3896,6 +4242,8 @@ static netdev_tx_t __bond_start_xmit(str
 	switch (BOND_MODE(bond)) {
 	case BOND_MODE_ROUNDROBIN:
 		return bond_xmit_roundrobin(skb, dev);
+    case BOND_MODE_BATMAN:
+         return bond_xmit_batman(skb,dev);
 	case BOND_MODE_ACTIVEBACKUP:
 		return bond_xmit_activebackup(skb, dev);
 	case BOND_MODE_8023AD:
@@ -4020,6 +4368,9 @@ static void bond_destructor(struct net_d
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
 	free_netdev(bond_dev);
+
+    if(bond_mode==BOND_MODE_BATMAN)
+         kthread_stop(bond->battimer_task);
 }
 
 void bond_setup(struct net_device *bond_dev)
@@ -4068,6 +4419,12 @@ void bond_setup(struct net_device *bond_
 	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	bond_dev->hw_features |= NETIF_F_GSO_ENCAP_ALL;
 	bond_dev->features |= bond_dev->hw_features;
+
+    if(bond_mode == BOND_MODE_BATMAN)
+    {
+         printk(KERN_INFO "%s: I'm Batman.\n",bond_dev->name);
+         bond->battimer_task = kthread_run(batman_timer_invoke,bond,"%s_batman",bond_dev->name);
+    }    
 }
 
 /* Destroy a bonding device.
@@ -4615,6 +4972,9 @@ err_link:
 
 static void __exit bonding_exit(void)
 {
+    int i;
+    struct slave_congestion_node* next_slave;
+    
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 
 	bond_destroy_debugfs();
@@ -4622,6 +4982,27 @@ static void __exit bonding_exit(void)
 	bond_netlink_fini();
 	unregister_pernet_subsys(&bond_net_ops);
 
+    //Batman doesn't leak memory
+    for(i=0; i<BATTABLE_SIZE; i++)
+    {
+         struct batnode* next_batnode = battable[i].next_batnode;
+         while(next_batnode)
+         {
+              struct batnode* next_next_batnode = next_batnode->next_batnode;
+              kfree(next_batnode);
+              next_batnode = next_next_batnode;
+         }
+    }
+    memset(battable,0,sizeof(struct batnode)*BATTABLE_SIZE);
+
+    next_slave = slavelist_head_ptr;
+    while(next_slave)
+    {
+         struct slave_congestion_node* next_next_slave = next_slave->next_slave;
+         kfree(next_slave);
+         next_slave = next_next_slave;
+    }
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* Make sure we don't have an imbalance on our netpoll blocking */
 	WARN_ON(atomic_read(&netpoll_block_tx));
--- tree_a/drivers/net/bonding/bond_options.c	2015-05-06 16:04:23.000000000 -0400
+++ tree_b/drivers/net/bonding/bond_options.c	2015-05-08 23:33:24.850987473 -0400
@@ -80,6 +80,7 @@ static const struct bond_opt_value bond_
 	{ "802.3ad",       BOND_MODE_8023AD,       0},
 	{ "balance-tlb",   BOND_MODE_TLB,          0},
 	{ "balance-alb",   BOND_MODE_ALB,          0},
+    { "batman",        BOND_MODE_BATMAN,       0},
 	{ NULL,            -1,                     0},
 };
 

--------------080506080704070806000801--
