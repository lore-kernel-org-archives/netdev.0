From: Mario Kicherer <dev@kicherer.org>
Subject: [PATCH net-next] can: initial support for network namespaces
Date: Thu, 16 Feb 2017 12:39:40 +0100
Message-ID: <40df4f6a-8df1-3b76-c0ed-9ba7800c2dc1@kicherer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zeus06.de ([194.117.254.36]:36366 "EHLO mail.zeus06.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754487AbdBPLq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 06:46:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds initial support for network namespaces. The changes only
enable support in the CAN raw, proc and af_can code. GW and BCM still
have their checks that ensure that they are used only from the main
namespace.

The patch boils down to moving the global structures, i.e. the global
filter list and their /proc stats, into a per-namespace structure and passing
around the corresponding "struct net" in a lot of different places.

Signed-off-by: Mario Kicherer <dev@kicherer.org>
---
 include/linux/can/core.h    |   8 +--
 include/net/net_namespace.h |   4 ++
 include/net/netns/can.h     |  31 ++++++++++
 net/can/af_can.c            | 123 +++++++++++++++++++++----------------
 net/can/af_can.h            |   4 +-
 net/can/bcm.c               |  13 ++--
 net/can/gw.c                |   4 +-
 net/can/proc.c              | 144 +++++++++++++++++++++-----------------------
 net/can/raw.c               |  91 ++++++++++++++++------------
 9 files changed, 242 insertions(+), 180 deletions(-)
 create mode 100644 include/net/netns/can.h

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index a087500..9f961d4 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -45,13 +45,13 @@ struct can_proto {
 extern int  can_proto_register(const struct can_proto *cp);
 extern void can_proto_unregister(const struct can_proto *cp);
 
-extern int  can_rx_register(struct net_device *dev, canid_t can_id,
-                           canid_t mask,
+extern int  can_rx_register(struct net *net, struct net_device *dev,
+                           canid_t can_id, canid_t mask,
                            void (*func)(struct sk_buff *, void *),
                            void *data, char *ident);
 
-extern void can_rx_unregister(struct net_device *dev, canid_t can_id,
-                             canid_t mask,
+extern void can_rx_unregister(struct net *net, struct net_device *dev,
+                             canid_t can_id, canid_t mask,
                              void (*func)(struct sk_buff *, void *),
                              void *data);
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0940598..f0c271e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -27,6 +27,7 @@
 #include <net/netns/nftables.h>
 #include <net/netns/xfrm.h>
 #include <net/netns/mpls.h>
+#include <net/netns/can.h>
 #include <linux/ns_common.h>
 #include <linux/idr.h>
 #include <linux/skbuff.h>
@@ -141,6 +142,9 @@ struct net {
 #if IS_ENABLED(CONFIG_MPLS)
        struct netns_mpls       mpls;
 #endif
+#if IS_ENABLED(CONFIG_CAN)
+       struct netns_can        can;
+#endif
        struct sock             *diag_nlsk;
        atomic_t                fnhe_genid;
 };
diff --git a/include/net/netns/can.h b/include/net/netns/can.h
new file mode 100644
index 0000000..e8beba7
--- /dev/null
+++ b/include/net/netns/can.h
@@ -0,0 +1,31 @@
+/*
+ * can in net namespaces
+ */
+
+#ifndef __NETNS_CAN_H__
+#define __NETNS_CAN_H__
+
+#include <linux/spinlock.h>
+
+struct dev_rcv_lists;
+
+struct netns_can {
+#if IS_ENABLED(CONFIG_PROC_FS)
+       struct proc_dir_entry *proc_dir;
+       struct proc_dir_entry *pde_version;
+       struct proc_dir_entry *pde_stats;
+       struct proc_dir_entry *pde_reset_stats;
+       struct proc_dir_entry *pde_rcvlist_all;
+       struct proc_dir_entry *pde_rcvlist_fil;
+       struct proc_dir_entry *pde_rcvlist_inv;
+       struct proc_dir_entry *pde_rcvlist_sff;
+       struct proc_dir_entry *pde_rcvlist_eff;
+       struct proc_dir_entry *pde_rcvlist_err;
+#endif
+
+       /* receive filters subscribed for 'all' CAN devices */
+       struct dev_rcv_lists *can_rx_alldev_list;
+       spinlock_t can_rcvlists_lock;
+};
+
+#endif /* __NETNS_CAN_H__ */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 1108079..e34e1e6 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -75,9 +75,7 @@ static int stats_timer __read_mostly = 1;
 module_param(stats_timer, int, S_IRUGO);
 MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 
-/* receive filters subscribed for 'all' CAN devices */
-struct dev_rcv_lists can_rx_alldev_list;
-static DEFINE_SPINLOCK(can_rcvlists_lock);
+int can_net_id;
 
 static struct kmem_cache *rcv_cache __read_mostly;
 
@@ -145,9 +143,6 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
        if (protocol < 0 || protocol >= CAN_NPROTO)
                return -EINVAL;
 
-       if (!net_eq(net, &init_net))
-               return -EAFNOSUPPORT;
-
        cp = can_get_proto(protocol);
 
 #ifdef CONFIG_MODULES
@@ -331,10 +326,11 @@ EXPORT_SYMBOL(can_send);
  * af_can rx path
  */
 
-static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
+static struct dev_rcv_lists *find_dev_rcv_lists(struct net *net,
+                                               struct net_device *dev)
 {
        if (!dev)
-               return &can_rx_alldev_list;
+               return net->can.can_rx_alldev_list;
        else
                return (struct dev_rcv_lists *)dev->ml_priv;
 }
@@ -466,9 +462,9 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
  *  -ENOMEM on missing cache mem to create subscription entry
  *  -ENODEV unknown device
  */
-int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
-                   void (*func)(struct sk_buff *, void *), void *data,
-                   char *ident)
+int can_rx_register(struct net *net, struct net_device *dev, canid_t can_id,
+                   canid_t mask, void (*func)(struct sk_buff *, void *),
+                   void *data, char *ident)
 {
        struct receiver *r;
        struct hlist_head *rl;
@@ -480,13 +476,16 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
        if (dev && dev->type != ARPHRD_CAN)
                return -ENODEV;
 
+       if (dev && !net_eq(net, dev_net(dev)))
+               return -ENODEV;
+
        r = kmem_cache_alloc(rcv_cache, GFP_KERNEL);
        if (!r)
                return -ENOMEM;
 
-       spin_lock(&can_rcvlists_lock);
+       spin_lock(&net->can.can_rcvlists_lock);
 
-       d = find_dev_rcv_lists(dev);
+       d = find_dev_rcv_lists(net, dev);
        if (d) {
                rl = find_rcv_list(&can_id, &mask, d);
 
@@ -508,7 +507,7 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
                err = -ENODEV;
        }
 
-       spin_unlock(&can_rcvlists_lock);
+       spin_unlock(&net->can.can_rcvlists_lock);
 
        return err;
 }
@@ -535,8 +534,9 @@ static void can_rx_delete_receiver(struct rcu_head *rp)
  * Description:
  *  Removes subscription entry depending on given (subscription) values.
  */
-void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
-                      void (*func)(struct sk_buff *, void *), void *data)
+void can_rx_unregister(struct net *net, struct net_device *dev, canid_t can_id,
+                      canid_t mask, void (*func)(struct sk_buff *, void *),
+                      void *data)
 {
        struct receiver *r = NULL;
        struct hlist_head *rl;
@@ -545,9 +545,12 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
        if (dev && dev->type != ARPHRD_CAN)
                return;
 
-       spin_lock(&can_rcvlists_lock);
+       if (dev && !net_eq(net, dev_net(dev)))
+               return;
 
-       d = find_dev_rcv_lists(dev);
+       spin_lock(&net->can.can_rcvlists_lock);
+
+       d = find_dev_rcv_lists(net, dev);
        if (!d) {
                pr_err("BUG: receive list not found for "
                       "dev %s, id %03X, mask %03X\n",
@@ -593,7 +596,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
        }
 
  out:
-       spin_unlock(&can_rcvlists_lock);
+       spin_unlock(&net->can.can_rcvlists_lock);
 
        /* schedule the receiver item for deletion */
        if (r)
@@ -688,10 +691,10 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
        rcu_read_lock();
 
        /* deliver the packet to sockets listening on all devices */
-       matches = can_rcv_filter(&can_rx_alldev_list, skb);
+       matches = can_rcv_filter(dev_net(dev)->can.can_rx_alldev_list, skb);
 
        /* find receive list for this device */
-       d = find_dev_rcv_lists(dev);
+       d = find_dev_rcv_lists(dev_net(dev), dev);
        if (d)
                matches += can_rcv_filter(d, skb);
 
@@ -711,9 +714,6 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 {
        struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
 
-       if (unlikely(!net_eq(dev_net(dev), &init_net)))
-               goto drop;
-
        if (WARN_ONCE(dev->type != ARPHRD_CAN ||
                      skb->len != CAN_MTU ||
                      cfd->len > CAN_MAX_DLEN,
@@ -735,9 +735,6 @@ static int canfd_rcv(struct sk_buff *skb, struct net_device *dev,
 {
        struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
 
-       if (unlikely(!net_eq(dev_net(dev), &init_net)))
-               goto drop;
-
        if (WARN_ONCE(dev->type != ARPHRD_CAN ||
                      skb->len != CANFD_MTU ||
                      cfd->len > CANFD_MAX_DLEN,
@@ -827,9 +824,6 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
        struct net_device *dev = netdev_notifier_info_to_dev(ptr);
        struct dev_rcv_lists *d;
 
-       if (!net_eq(dev_net(dev), &init_net))
-               return NOTIFY_DONE;
-
        if (dev->type != ARPHRD_CAN)
                return NOTIFY_DONE;
 
@@ -847,7 +841,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
                break;
 
        case NETDEV_UNREGISTER:
-               spin_lock(&can_rcvlists_lock);
+               spin_lock(&dev_net(dev)->can.can_rcvlists_lock);
 
                d = dev->ml_priv;
                if (d) {
@@ -861,7 +855,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
                        pr_err("can: notifier: receive list not found for dev "
                               "%s\n", dev->name);
 
-               spin_unlock(&can_rcvlists_lock);
+               spin_unlock(&dev_net(dev)->can.can_rcvlists_lock);
 
                break;
        }
@@ -869,6 +863,41 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
        return NOTIFY_DONE;
 }
 
+int can_pernet_init(struct net *net)
+{
+       net->can.can_rcvlists_lock =
+               __SPIN_LOCK_UNLOCKED(net->can.can_rcvlists_lock);
+       net->can.can_rx_alldev_list =
+               kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
+       memset(net->can.can_rx_alldev_list, 0, sizeof(struct dev_rcv_lists));
+
+       if (IS_ENABLED(CONFIG_PROC_FS))
+               can_init_proc(net);
+
+       return 0;
+}
+
+void can_pernet_exit(struct net *net)
+{
+       struct net_device *dev;
+
+       if (IS_ENABLED(CONFIG_PROC_FS))
+               can_remove_proc(net);
+
+       /* remove created dev_rcv_lists from still registered CAN devices */
+       rcu_read_lock();
+       for_each_netdev_rcu(net, dev) {
+               if (dev->type == ARPHRD_CAN && dev->ml_priv) {
+                       struct dev_rcv_lists *d = dev->ml_priv;
+
+                       BUG_ON(d->entries);
+                       kfree(d);
+                       dev->ml_priv = NULL;
+               }
+       }
+       rcu_read_unlock();
+}
+
 /*
  * af_can module init/exit functions
  */
@@ -894,6 +923,13 @@ static struct notifier_block can_netdev_notifier __read_mostly = {
        .notifier_call = can_notifier,
 };
 
+static struct pernet_operations can_pernet_ops __read_mostly = {
+       .init = can_pernet_init,
+       .exit = can_pernet_exit,
+       .id = &can_net_id,
+       .size = 0,
+};
+
 static __init int can_init(void)
 {
        /* check for correct padding to be able to use the structs similarly */
@@ -904,8 +940,6 @@ static __init int can_init(void)
 
        pr_info("can: controller area network core (" CAN_VERSION_STRING ")\n");
 
-       memset(&can_rx_alldev_list, 0, sizeof(can_rx_alldev_list));
-
        rcv_cache = kmem_cache_create("can_receiver", sizeof(struct receiver),
                                      0, 0, NULL);
        if (!rcv_cache)
@@ -917,9 +951,10 @@ static __init int can_init(void)
                        setup_timer(&can_stattimer, can_stat_update, 0);
                        mod_timer(&can_stattimer, round_jiffies(jiffies + HZ));
                }
-               can_init_proc();
        }
 
+       register_pernet_subsys(&can_pernet_ops);
+
        /* protocol register */
        sock_register(&can_family_ops);
        register_netdevice_notifier(&can_netdev_notifier);
@@ -931,13 +966,9 @@ static __init int can_init(void)
 
 static __exit void can_exit(void)
 {
-       struct net_device *dev;
-
        if (IS_ENABLED(CONFIG_PROC_FS)) {
                if (stats_timer)
                        del_timer_sync(&can_stattimer);
-
-               can_remove_proc();
        }
 
        /* protocol unregister */
@@ -946,19 +977,7 @@ static __exit void can_exit(void)
        unregister_netdevice_notifier(&can_netdev_notifier);
        sock_unregister(PF_CAN);
 
-       /* remove created dev_rcv_lists from still registered CAN devices */
-       rcu_read_lock();
-       for_each_netdev_rcu(&init_net, dev) {
-               if (dev->type == ARPHRD_CAN && dev->ml_priv) {
-
-                       struct dev_rcv_lists *d = dev->ml_priv;
-
-                       BUG_ON(d->entries);
-                       kfree(d);
-                       dev->ml_priv = NULL;
-               }
-       }
-       rcu_read_unlock();
+       unregister_pernet_subsys(&can_pernet_ops);
 
        rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
diff --git a/net/can/af_can.h b/net/can/af_can.h
index fca0fe9..2764781 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -113,8 +113,8 @@ struct s_pstats {
 extern struct dev_rcv_lists can_rx_alldev_list;
 
 /* function prototypes for the CAN networklayer procfs (proc.c) */
-void can_init_proc(void);
-void can_remove_proc(void);
+void can_init_proc(struct net *net);
+void can_remove_proc(struct net *net);
 void can_stat_update(unsigned long data);
 
 /* structures and variables from af_can.c needed in proc.c for reading */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 436a753..1fc13ad 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -755,8 +755,8 @@ static void bcm_remove_op(struct bcm_op *op)
 static void bcm_rx_unreg(struct net_device *dev, struct bcm_op *op)
 {
        if (op->rx_reg_dev == dev) {
-               can_rx_unregister(dev, op->can_id, REGMASK(op->can_id),
-                                 bcm_rx_handler, op);
+               can_rx_unregister(&init_net, dev, op->can_id,
+                                 REGMASK(op->can_id), bcm_rx_handler, op);
 
                /* mark as removed subscription */
                op->rx_reg_dev = NULL;
@@ -799,7 +799,7 @@ static int bcm_delete_rx_op(struct list_head *ops, struct bcm_msg_head *mh,
                                        }
                                }
                        } else
-                               can_rx_unregister(NULL, op->can_id,
+                               can_rx_unregister(&init_net, NULL, op->can_id,
                                                  REGMASK(op->can_id),
                                                  bcm_rx_handler, op);
 
@@ -1213,7 +1213,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 
                        dev = dev_get_by_index(&init_net, ifindex);
                        if (dev) {
-                               err = can_rx_register(dev, op->can_id,
+                               err = can_rx_register(&init_net, dev,
+                                                     op->can_id,
                                                      REGMASK(op->can_id),
                                                      bcm_rx_handler, op,
                                                      "bcm");
@@ -1223,7 +1224,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
                        }
 
                } else
-                       err = can_rx_register(NULL, op->can_id,
+                       err = can_rx_register(&init_net, NULL, op->can_id,
                                              REGMASK(op->can_id),
                                              bcm_rx_handler, op, "bcm");
                if (err) {
@@ -1519,7 +1520,7 @@ static int bcm_release(struct socket *sock)
                                }
                        }
                } else
-                       can_rx_unregister(NULL, op->can_id,
+                       can_rx_unregister(&init_net, NULL, op->can_id,
                                          REGMASK(op->can_id),
                                          bcm_rx_handler, op);
 
diff --git a/net/can/gw.c b/net/can/gw.c
index 4551687..56f01f2 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -440,14 +440,14 @@ static void can_can_gw_rcv(struct sk_buff *skb, void *data)
 
 static inline int cgw_register_filter(struct cgw_job *gwj)
 {
-       return can_rx_register(gwj->src.dev, gwj->ccgw.filter.can_id,
+       return can_rx_register(&init_net, gwj->src.dev, gwj->ccgw.filter.can_id,
                               gwj->ccgw.filter.can_mask, can_can_gw_rcv,
                               gwj, "gw");
 }
 
 static inline void cgw_unregister_filter(struct cgw_job *gwj)
 {
-       can_rx_unregister(gwj->src.dev, gwj->ccgw.filter.can_id,
+       can_rx_unregister(&init_net, gwj->src.dev, gwj->ccgw.filter.can_id,
                          gwj->ccgw.filter.can_mask, can_can_gw_rcv, gwj);
 }
 
diff --git a/net/can/proc.c b/net/can/proc.c
index 85ef7bb..9a8d54d 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -62,17 +62,6 @@
 #define CAN_PROC_RCVLIST_EFF "rcvlist_eff"
 #define CAN_PROC_RCVLIST_ERR "rcvlist_err"
 
-static struct proc_dir_entry *can_dir;
-static struct proc_dir_entry *pde_version;
-static struct proc_dir_entry *pde_stats;
-static struct proc_dir_entry *pde_reset_stats;
-static struct proc_dir_entry *pde_rcvlist_all;
-static struct proc_dir_entry *pde_rcvlist_fil;
-static struct proc_dir_entry *pde_rcvlist_inv;
-static struct proc_dir_entry *pde_rcvlist_sff;
-static struct proc_dir_entry *pde_rcvlist_eff;
-static struct proc_dir_entry *pde_rcvlist_err;
-
 static int user_reset;
 
 static const char rx_list_name[][8] = {
@@ -351,20 +340,21 @@ static inline void can_rcvlist_proc_show_one(struct seq_file *m, int idx,
 static int can_rcvlist_proc_show(struct seq_file *m, void *v)
 {
        /* double cast to prevent GCC warning */
-       int idx = (int)(long)m->private;
+       int idx = (int)(long)PDE_DATA(m->file->f_inode);
        struct net_device *dev;
        struct dev_rcv_lists *d;
+       struct net *net = m->private;
 
        seq_printf(m, "\nreceive list '%s':\n", rx_list_name[idx]);
 
        rcu_read_lock();
 
        /* receive list for 'all' CAN devices (dev == NULL) */
-       d = &can_rx_alldev_list;
+       d = net->can.can_rx_alldev_list;
        can_rcvlist_proc_show_one(m, idx, NULL, d);
 
        /* receive list for registered CAN devices */
-       for_each_netdev_rcu(&init_net, dev) {
+       for_each_netdev_rcu(net, dev) {
                if (dev->type == ARPHRD_CAN && dev->ml_priv)
                        can_rcvlist_proc_show_one(m, idx, dev, dev->ml_priv);
        }
@@ -377,7 +367,7 @@ static int can_rcvlist_proc_show(struct seq_file *m, void *v)
 
 static int can_rcvlist_proc_open(struct inode *inode, struct file *file)
 {
-       return single_open(file, can_rcvlist_proc_show, PDE_DATA(inode));
+       return single_open_net(inode, file, can_rcvlist_proc_show);
 }
 
 static const struct file_operations can_rcvlist_proc_fops = {
@@ -417,6 +407,7 @@ static int can_rcvlist_sff_proc_show(struct seq_file *m, void *v)
 {
        struct net_device *dev;
        struct dev_rcv_lists *d;
+       struct net *net = m->private;
 
        /* RX_SFF */
        seq_puts(m, "\nreceive list 'rx_sff':\n");
@@ -424,11 +415,11 @@ static int can_rcvlist_sff_proc_show(struct seq_file *m, void *v)
        rcu_read_lock();
 
        /* sff receive list for 'all' CAN devices (dev == NULL) */
-       d = &can_rx_alldev_list;
+       d = net->can.can_rx_alldev_list;
        can_rcvlist_proc_show_array(m, NULL, d->rx_sff, ARRAY_SIZE(d->rx_sff));
 
        /* sff receive list for registered CAN devices */
-       for_each_netdev_rcu(&init_net, dev) {
+       for_each_netdev_rcu(net, dev) {
                if (dev->type == ARPHRD_CAN && dev->ml_priv) {
                        d = dev->ml_priv;
                        can_rcvlist_proc_show_array(m, dev, d->rx_sff,
@@ -444,7 +435,7 @@ static int can_rcvlist_sff_proc_show(struct seq_file *m, void *v)
 
 static int can_rcvlist_sff_proc_open(struct inode *inode, struct file *file)
 {
-       return single_open(file, can_rcvlist_sff_proc_show, NULL);
+       return single_open_net(inode, file, can_rcvlist_sff_proc_show);
 }
 
 static const struct file_operations can_rcvlist_sff_proc_fops = {
@@ -460,6 +451,7 @@ static int can_rcvlist_eff_proc_show(struct seq_file *m, void *v)
 {
        struct net_device *dev;
        struct dev_rcv_lists *d;
+       struct net *net = m->private;
 
        /* RX_EFF */
        seq_puts(m, "\nreceive list 'rx_eff':\n");
@@ -467,11 +459,11 @@ static int can_rcvlist_eff_proc_show(struct seq_file *m, void *v)
        rcu_read_lock();
 
        /* eff receive list for 'all' CAN devices (dev == NULL) */
-       d = &can_rx_alldev_list;
+       d = net->can.can_rx_alldev_list;
        can_rcvlist_proc_show_array(m, NULL, d->rx_eff, ARRAY_SIZE(d->rx_eff));
 
        /* eff receive list for registered CAN devices */
-       for_each_netdev_rcu(&init_net, dev) {
+       for_each_netdev_rcu(net, dev) {
                if (dev->type == ARPHRD_CAN && dev->ml_priv) {
                        d = dev->ml_priv;
                        can_rcvlist_proc_show_array(m, dev, d->rx_eff,
@@ -487,7 +479,7 @@ static int can_rcvlist_eff_proc_show(struct seq_file *m, void *v)
 
 static int can_rcvlist_eff_proc_open(struct inode *inode, struct file *file)
 {
-       return single_open(file, can_rcvlist_eff_proc_show, NULL);
+       return single_open_net(inode, file, can_rcvlist_eff_proc_show);
 }
 
 static const struct file_operations can_rcvlist_eff_proc_fops = {
@@ -499,81 +491,85 @@ static const struct file_operations can_rcvlist_eff_proc_fops = {
 };
 
 /*
- * proc utility functions
- */
-
-static void can_remove_proc_readentry(const char *name)
-{
-       if (can_dir)
-               remove_proc_entry(name, can_dir);
-}
-
-/*
  * can_init_proc - create main CAN proc directory and procfs entries
  */
-void can_init_proc(void)
+void can_init_proc(struct net *net)
 {
        /* create /proc/net/can directory */
-       can_dir = proc_mkdir("can", init_net.proc_net);
+       net->can.proc_dir = proc_net_mkdir(net, "can", net->proc_net);
 
-       if (!can_dir) {
-               pr_info("can: failed to create /proc/net/can.\n");
+       if (!net->can.proc_dir) {
+               printk(KERN_INFO "can: failed to create /proc/net/can . "
+                          "CONFIG_PROC_FS missing?\n");
                return;
        }
 
        /* own procfs entries from the AF_CAN core */
-       pde_version     = proc_create(CAN_PROC_VERSION, 0644, can_dir,
-                                     &can_version_proc_fops);
-       pde_stats       = proc_create(CAN_PROC_STATS, 0644, can_dir,
-                                     &can_stats_proc_fops);
-       pde_reset_stats = proc_create(CAN_PROC_RESET_STATS, 0644, can_dir,
-                                     &can_reset_stats_proc_fops);
-       pde_rcvlist_err = proc_create_data(CAN_PROC_RCVLIST_ERR, 0644, can_dir,
-                                          &can_rcvlist_proc_fops, (void *)RX_ERR);
-       pde_rcvlist_all = proc_create_data(CAN_PROC_RCVLIST_ALL, 0644, can_dir,
-                                          &can_rcvlist_proc_fops, (void *)RX_ALL);
-       pde_rcvlist_fil = proc_create_data(CAN_PROC_RCVLIST_FIL, 0644, can_dir,
-                                          &can_rcvlist_proc_fops, (void *)RX_FIL);
-       pde_rcvlist_inv = proc_create_data(CAN_PROC_RCVLIST_INV, 0644, can_dir,
-                                          &can_rcvlist_proc_fops, (void *)RX_INV);
-       pde_rcvlist_eff = proc_create(CAN_PROC_RCVLIST_EFF, 0644, can_dir,
-                                     &can_rcvlist_eff_proc_fops);
-       pde_rcvlist_sff = proc_create(CAN_PROC_RCVLIST_SFF, 0644, can_dir,
-                                     &can_rcvlist_sff_proc_fops);
+       net->can.pde_version     = proc_create(CAN_PROC_VERSION, 0644,
+                                              net->can.proc_dir,
+                                              &can_version_proc_fops);
+       net->can.pde_stats       = proc_create(CAN_PROC_STATS, 0644,
+                                              net->can.proc_dir,
+                                              &can_stats_proc_fops);
+       net->can.pde_reset_stats = proc_create(CAN_PROC_RESET_STATS, 0644,
+                                              net->can.proc_dir,
+                                              &can_reset_stats_proc_fops);
+       net->can.pde_rcvlist_err = proc_create_data(CAN_PROC_RCVLIST_ERR, 0644,
+                                                   net->can.proc_dir,
+                                                   &can_rcvlist_proc_fops,
+                                                   (void *)RX_ERR);
+       net->can.pde_rcvlist_all = proc_create_data(CAN_PROC_RCVLIST_ALL, 0644,
+                                                   net->can.proc_dir,
+                                                   &can_rcvlist_proc_fops,
+                                                   (void *)RX_ALL);
+       net->can.pde_rcvlist_fil = proc_create_data(CAN_PROC_RCVLIST_FIL, 0644,
+                                                   net->can.proc_dir,
+                                                   &can_rcvlist_proc_fops,
+                                                   (void *)RX_FIL);
+       net->can.pde_rcvlist_inv = proc_create_data(CAN_PROC_RCVLIST_INV, 0644,
+                                                   net->can.proc_dir,
+                                                   &can_rcvlist_proc_fops,
+                                                   (void *)RX_INV);
+       net->can.pde_rcvlist_eff = proc_create(CAN_PROC_RCVLIST_EFF, 0644,
+                                              net->can.proc_dir,
+                                              &can_rcvlist_eff_proc_fops);
+       net->can.pde_rcvlist_sff = proc_create(CAN_PROC_RCVLIST_SFF, 0644,
+                                              net->can.proc_dir,
+                                              &can_rcvlist_sff_proc_fops);
 }
 
 /*
  * can_remove_proc - remove procfs entries and main CAN proc directory
  */
-void can_remove_proc(void)
+void can_remove_proc(struct net *net)
 {
-       if (pde_version)
-               can_remove_proc_readentry(CAN_PROC_VERSION);
+       if (net->can.pde_version)
+               remove_proc_entry(CAN_PROC_VERSION, net->can.proc_dir);
 
-       if (pde_stats)
-               can_remove_proc_readentry(CAN_PROC_STATS);
+       if (net->can.pde_stats)
+               remove_proc_entry(CAN_PROC_STATS, net->can.proc_dir);
 
-       if (pde_reset_stats)
-               can_remove_proc_readentry(CAN_PROC_RESET_STATS);
+       if (net->can.pde_reset_stats)
+               remove_proc_entry(CAN_PROC_RESET_STATS, net->can.proc_dir);
 
-       if (pde_rcvlist_err)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_ERR);
+       if (net->can.pde_rcvlist_err)
+               remove_proc_entry(CAN_PROC_RCVLIST_ERR, net->can.proc_dir);
 
-       if (pde_rcvlist_all)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_ALL);
+       if (net->can.pde_rcvlist_all)
+               remove_proc_entry(CAN_PROC_RCVLIST_ALL, net->can.proc_dir);
 
-       if (pde_rcvlist_fil)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_FIL);
+       if (net->can.pde_rcvlist_fil)
+               remove_proc_entry(CAN_PROC_RCVLIST_FIL, net->can.proc_dir);
 
-       if (pde_rcvlist_inv)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_INV);
+       if (net->can.pde_rcvlist_inv)
+               remove_proc_entry(CAN_PROC_RCVLIST_INV, net->can.proc_dir);
 
-       if (pde_rcvlist_eff)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_EFF);
+       if (net->can.pde_rcvlist_eff)
+               remove_proc_entry(CAN_PROC_RCVLIST_EFF, net->can.proc_dir);
 
-       if (pde_rcvlist_sff)
-               can_remove_proc_readentry(CAN_PROC_RCVLIST_SFF);
+       if (net->can.pde_rcvlist_sff)
+               remove_proc_entry(CAN_PROC_RCVLIST_SFF, net->can.proc_dir);
 
-       if (can_dir)
-               remove_proc_entry("can", init_net.proc_net);
+       if (net->can.proc_dir)
+               remove_proc_entry("can", net->proc_net);
 }
diff --git a/net/can/raw.c b/net/can/raw.c
index b075f02..e534e7f 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -181,20 +181,21 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
                kfree_skb(skb);
 }
 
-static int raw_enable_filters(struct net_device *dev, struct sock *sk,
-                             struct can_filter *filter, int count)
+static int raw_enable_filters(struct net *net, struct net_device *dev,
+                             struct sock *sk, struct can_filter *filter,
+                             int count)
 {
        int err = 0;
        int i;
 
        for (i = 0; i < count; i++) {
-               err = can_rx_register(dev, filter[i].can_id,
+               err = can_rx_register(net, dev, filter[i].can_id,
                                      filter[i].can_mask,
                                      raw_rcv, sk, "raw");
                if (err) {
                        /* clean up successfully registered filters */
                        while (--i >= 0)
-                               can_rx_unregister(dev, filter[i].can_id,
+                               can_rx_unregister(net, dev, filter[i].can_id,
                                                  filter[i].can_mask,
                                                  raw_rcv, sk);
                        break;
@@ -204,57 +205,62 @@ static int raw_enable_filters(struct net_device *dev, struct sock *sk,
        return err;
 }
 
-static int raw_enable_errfilter(struct net_device *dev, struct sock *sk,
-                               can_err_mask_t err_mask)
+static int raw_enable_errfilter(struct net *net, struct net_device *dev,
+                               struct sock *sk, can_err_mask_t err_mask)
 {
        int err = 0;
 
        if (err_mask)
-               err = can_rx_register(dev, 0, err_mask | CAN_ERR_FLAG,
+               err = can_rx_register(net, dev, 0, err_mask | CAN_ERR_FLAG,
                                      raw_rcv, sk, "raw");
 
        return err;
 }
 
-static void raw_disable_filters(struct net_device *dev, struct sock *sk,
-                             struct can_filter *filter, int count)
+static void raw_disable_filters(struct net *net, struct net_device *dev,
+                               struct sock *sk, struct can_filter *filter,
+                               int count)
 {
        int i;
 
        for (i = 0; i < count; i++)
-               can_rx_unregister(dev, filter[i].can_id, filter[i].can_mask,
-                                 raw_rcv, sk);
+               can_rx_unregister(net, dev, filter[i].can_id,
+                                 filter[i].can_mask, raw_rcv, sk);
 }
 
-static inline void raw_disable_errfilter(struct net_device *dev,
+static inline void raw_disable_errfilter(struct net *net,
+                                        struct net_device *dev,
                                         struct sock *sk,
                                         can_err_mask_t err_mask)
 
 {
        if (err_mask)
-               can_rx_unregister(dev, 0, err_mask | CAN_ERR_FLAG,
+               can_rx_unregister(net, dev, 0, err_mask | CAN_ERR_FLAG,
                                  raw_rcv, sk);
 }
 
-static inline void raw_disable_allfilters(struct net_device *dev,
+static inline void raw_disable_allfilters(struct net *net,
+                                         struct net_device *dev,
                                          struct sock *sk)
 {
        struct raw_sock *ro = raw_sk(sk);
 
-       raw_disable_filters(dev, sk, ro->filter, ro->count);
-       raw_disable_errfilter(dev, sk, ro->err_mask);
+       raw_disable_filters(net, dev, sk, ro->filter, ro->count);
+       raw_disable_errfilter(net, dev, sk, ro->err_mask);
 }
 
-static int raw_enable_allfilters(struct net_device *dev, struct sock *sk)
+static int raw_enable_allfilters(struct net *net, struct net_device *dev,
+                                struct sock *sk)
 {
        struct raw_sock *ro = raw_sk(sk);
        int err;
 
-       err = raw_enable_filters(dev, sk, ro->filter, ro->count);
+       err = raw_enable_filters(net, dev, sk, ro->filter, ro->count);
        if (!err) {
-               err = raw_enable_errfilter(dev, sk, ro->err_mask);
+               err = raw_enable_errfilter(net, dev, sk, ro->err_mask);
                if (err)
-                       raw_disable_filters(dev, sk, ro->filter, ro->count);
+                       raw_disable_filters(net, dev, sk, ro->filter,
+                                           ro->count);
        }
 
        return err;
@@ -267,7 +273,7 @@ static int raw_notifier(struct notifier_block *nb,
        struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
        struct sock *sk = &ro->sk;
 
-       if (!net_eq(dev_net(dev), &init_net))
+       if (!net_eq(dev_net(dev), sock_net(sk)))
                return NOTIFY_DONE;
 
        if (dev->type != ARPHRD_CAN)
@@ -282,7 +288,7 @@ static int raw_notifier(struct notifier_block *nb,
                lock_sock(sk);
                /* remove current filters & unregister */
                if (ro->bound)
-                       raw_disable_allfilters(dev, sk);
+                       raw_disable_allfilters(dev_net(dev), dev, sk);
 
                if (ro->count > 1)
                        kfree(ro->filter);
@@ -358,13 +364,13 @@ static int raw_release(struct socket *sock)
                if (ro->ifindex) {
                        struct net_device *dev;
 
-                       dev = dev_get_by_index(&init_net, ro->ifindex);
+                       dev = dev_get_by_index(sock_net(sk), ro->ifindex);
                        if (dev) {
-                               raw_disable_allfilters(dev, sk);
+                               raw_disable_allfilters(dev_net(dev), dev, sk);
                                dev_put(dev);
                        }
                } else
-                       raw_disable_allfilters(NULL, sk);
+                       raw_disable_allfilters(sock_net(sk), NULL, sk);
        }
 
        if (ro->count > 1)
@@ -404,7 +410,7 @@ static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int len)
        if (addr->can_ifindex) {
                struct net_device *dev;
 
-               dev = dev_get_by_index(&init_net, addr->can_ifindex);
+               dev = dev_get_by_index(sock_net(sk), addr->can_ifindex);
                if (!dev) {
                        err = -ENODEV;
                        goto out;
@@ -420,13 +426,13 @@ static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int len)
                ifindex = dev->ifindex;
 
                /* filters set by default/setsockopt */
-               err = raw_enable_allfilters(dev, sk);
+               err = raw_enable_allfilters(sock_net(sk), dev, sk);
                dev_put(dev);
        } else {
                ifindex = 0;
 
                /* filters set by default/setsockopt */
-               err = raw_enable_allfilters(NULL, sk);
+               err = raw_enable_allfilters(sock_net(sk), NULL, sk);
        }
 
        if (!err) {
@@ -435,13 +441,14 @@ static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int len)
                        if (ro->ifindex) {
                                struct net_device *dev;
 
-                               dev = dev_get_by_index(&init_net, ro->ifindex);
+                               dev = dev_get_by_index(sock_net(sk),
+                                                      ro->ifindex);
                                if (dev) {
-                                       raw_disable_allfilters(dev, sk);
+                                       raw_disable_allfilters(dev_net(dev), dev, sk);
                                        dev_put(dev);
                                }
                        } else
-                               raw_disable_allfilters(NULL, sk);
+                               raw_disable_allfilters(sock_net(sk), NULL, sk);
                }
                ro->ifindex = ifindex;
                ro->bound = 1;
@@ -517,15 +524,16 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
                lock_sock(sk);
 
                if (ro->bound && ro->ifindex)
-                       dev = dev_get_by_index(&init_net, ro->ifindex);
+                       dev = dev_get_by_index(sock_net(sk), ro->ifindex);
 
                if (ro->bound) {
                        /* (try to) register the new filters */
                        if (count == 1)
-                               err = raw_enable_filters(dev, sk, &sfilter, 1);
+                               err = raw_enable_filters(sock_net(sk), dev, sk,
+                                                        &sfilter, 1);
                        else
-                               err = raw_enable_filters(dev, sk, filter,
-                                                        count);
+                               err = raw_enable_filters(sock_net(sk), dev, sk,
+                                                        filter, count);
                        if (err) {
                                if (count > 1)
                                        kfree(filter);
@@ -533,7 +541,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
                        }
 
                        /* remove old filter registrations */
-                       raw_disable_filters(dev, sk, ro->filter, ro->count);
+                       raw_disable_filters(sock_net(sk), dev, sk, ro->filter,
+                                           ro->count);
                }
 
                /* remove old filter space */
@@ -569,18 +578,20 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
                lock_sock(sk);
 
                if (ro->bound && ro->ifindex)
-                       dev = dev_get_by_index(&init_net, ro->ifindex);
+                       dev = dev_get_by_index(sock_net(sk), ro->ifindex);
 
                /* remove current error mask */
                if (ro->bound) {
                        /* (try to) register the new err_mask */
-                       err = raw_enable_errfilter(dev, sk, err_mask);
+                       err = raw_enable_errfilter(sock_net(sk), dev, sk,
+                                                  err_mask);

                        if (err)
                                goto out_err;

                        /* remove old err_mask registration */
-                       raw_disable_errfilter(dev, sk, ro->err_mask);
+                       raw_disable_errfilter(sock_net(sk), dev, sk,
+                                             ro->err_mask);
                }

                /* link new err_mask to the socket */
@@ -741,7 +752,7 @@ static int raw_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
                        return -EINVAL;
        }

-       dev = dev_get_by_index(&init_net, ifindex);
+       dev = dev_get_by_index(sock_net(sk), ifindex);
        if (!dev)
                return -ENXIO;
