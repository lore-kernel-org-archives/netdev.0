From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 3/4] [Net] Support Xen accelerated network
	plugin modules
Date: Fri, 18 May 2007 14:16:48 +0100
Message-ID: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-MBeApUmoyX4/q+RCdNj2"
Cc: muli@il.ibm.com, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


--=-MBeApUmoyX4/q+RCdNj2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add support to Xen netfront for accelerated plugin module

diff -r ce3d5c548e67 linux-2.6-xen-
sparse/drivers/xen/netfront/netfront.c
--- a/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c Thu May 17
09:56:38 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c Fri May 18
10:26:34 2007 +0100
@@ -3,6 +3,7 @@
  *
  * Copyright (c) 2002-2005, K A Fraser
  * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version
2
@@ -47,6 +48,7 @@
#include <linux/if_ether.h>
#include <linux/io.h>
#include <linux/moduleparam.h>
+#include <linux/list.h>
#include <net/sock.h>
#include <net/pkt_sched.h>
#include <net/arp.h>
@@ -73,6 +75,8 @@ struct netfront_cb {
};

#define NETFRONT_SKB_CB(skb) ((struct netfront_cb *)((skb)->cb))
+
+#include "netfront.h"

/*
  * Mutually-exclusive module options to select receive data path:
@@ -144,57 +148,6 @@ static inline int netif_needs_gso(struct

#define GRANT_INVALID_REF 0

-#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0,
PAGE_SIZE)
-#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0,
PAGE_SIZE)
-
-struct netfront_info {
- struct list_head list;
- struct net_device *netdev;
-
- struct net_device_stats stats;
-
- struct netif_tx_front_ring tx;
- struct netif_rx_front_ring rx;
-
- spinlock_t   tx_lock;
- spinlock_t   rx_lock;
-
- unsigned int irq;
- unsigned int copying_receiver;
- unsigned int carrier;
-
- /* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
- unsigned rx_min_target, rx_max_target, rx_target;
- struct sk_buff_head rx_batch;
-
- struct timer_list rx_refill_timer;
-
- /*
- * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
- * is an index into a chain of free entries.
- */
- struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
- struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
-
-#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
- grant_ref_t gref_tx_head;
- grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
- grant_ref_t gref_rx_head;
- grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
- struct xenbus_device *xbdev;
- int tx_ring_ref;
- int rx_ring_ref;
- u8 mac[ETH_ALEN];
-
- unsigned long rx_pfn_array[NET_RX_RING_SIZE];
- struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
- struct mmu_update rx_mmu[NET_RX_RING_SIZE];
-};
-
struct netfront_rx_info {
struct netif_rx_response rx;
struct netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
@@ -278,6 +231,392 @@ static void xennet_sysfs_delif(struct ne
#define xennet_sysfs_delif(dev) do { } while(0)
#endif

+/*
+ * List of all netfront accelerator plugin modules available.  Each
+ * list entry is of type struct netfront_accelerator.
+ */ 
+static struct list_head accelerators_list;
+/*
+ * Lock to protect access to accelerators_list, and also used to
+ * protect the hooks_usecount field in struct netfront_accelerator
+ * against concurrent access 
+ */
+static spinlock_t accelerators_lock;
+
+/* 
+ * Safely remove the accelerator function hooks from a netfront state.
+ * Must only be called when there are no current users of the hooks.
+ */
+static void accelerator_remove_hooks(struct netfront_accelerator
*accelerator)
+{
+        struct netfront_accel_vif_state *vif_state;
+
+        list_for_each_entry( vif_state,
+                             &accelerator->vif_states,
+                             link ) {
+                /* Make sure there are no data path operations going on
*/
+                netif_poll_disable(vif_state->np->netdev);
+                netif_tx_disable(vif_state->np->netdev);
+                
+                /* 
+                 * Remove the hooks, but leave the vif_state on the
+                 * accelerator's list as that signifies this vif is
+                 * interested in using that accelerator if it becomes
+                 * available again
+                 */
+                vif_state->hooks = NULL;
+                
+                netif_wake_queue(vif_state->np->netdev);
+                netif_poll_enable(vif_state->np->netdev);
+        }
+
+        accelerator->hooks = NULL;
+
+        /* Signal that all users of hooks are done */
+        up(&accelerator->exit_semaphore);
+}
+
+
+/*
+ * Compare a frontend description string against an accelerator to see
+ * if they match.  Would ultimately be nice to replace the string with
+ * a unique numeric identifier for each accelerator.
+ */
+static int match_accelerator(const char *frontend, 
+                             struct netfront_accelerator *accelerator)
+{
+        return strcmp(frontend, accelerator->frontend) == 0;
+}
+
+
+/* 
+ * Add a frontend vif to the list of vifs that is using a netfront
+ * accelerator plugin module.
+ */
+static void add_accelerator_vif(struct netfront_accelerator
*accelerator,
+                                struct netfront_info *np,
+                                struct xenbus_device *dev)
+{
+        np->accelerator = accelerator;
+        np->accel_vif_state.np = np;
+        np->accel_vif_state.dev = dev;
+
+        list_add(&np->accel_vif_state.link, &accelerator->vif_states);
+}
+
+/*
+ * Initialise the netfront state of an accelerator plugin module.
+ */ 
+static int init_accelerator(const char *frontend, 
+                            struct netfront_accelerator **result)
+{
+        struct netfront_accelerator *accelerator = 
+                kmalloc(sizeof(struct netfront_accelerator),
GFP_KERNEL);
+        int frontend_len;
+
+        if ( !accelerator ) {
+                DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+                return -ENOMEM;
+        }
+
+        frontend_len = strlen(frontend) + 1;
+        accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+        if ( !accelerator->frontend ) {
+                DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+                kfree(accelerator);
+                return -ENOMEM;
+        }
+        strlcpy(accelerator->frontend, frontend, frontend_len);
+        
+        INIT_LIST_HEAD(&accelerator->vif_states);
+
+        accelerator->hooks = NULL;
+        accelerator->hooks_usecount = 0;
+
+        list_add(&accelerator->link, &accelerators_list);
+
+        *result = accelerator;
+
+        return 0;
+}                                        
+
+/* 
+ * Modify the hooks stored in the per-vif state to match that in the
+ * netfront accelerator's state.
+ */
+static void 
+accelerator_set_vif_state_hooks(struct netfront_accel_vif_state
*vif_state)
+{
+        /* Make sure there are no data path operations going on */
+        netif_poll_disable(vif_state->np->netdev);
+        netif_tx_disable(vif_state->np->netdev);
+        
+        vif_state->hooks = vif_state->np->accelerator->hooks;
+        
+        netif_wake_queue(vif_state->np->netdev);
+        netif_poll_enable(vif_state->np->netdev);
+}
+
+
+/*  
+ * Request that a particular netfront accelerator plugin is loaded.
+ * Usually called as a result of the vif configuration specifying
+ * which one to use.
+ */
+static int netfront_load_accelerator(struct netfront_info *np, 
+                                     struct xenbus_device *dev, 
+                                     const char *frontend)
+{
+        struct netfront_accelerator *accelerator;
+        int rc;
+        unsigned flags;
+        
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        /* 
+         * Look at list of loaded accelerators to see if the requested
+         * one is already there 
+         */
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /*
+                         * Include this frontend device on the
+                         * accelerator's list 
+                         */
+                        add_accelerator_vif(accelerator, np, dev);
+
+                        ++accelerator->hooks_usecount;
+
+                        if ( accelerator->hooks == NULL )
+                                DPRINTK("%s: no hooks set",
__FUNCTION__);
+                        else {
+                                spin_unlock_irqrestore
(&accelerators_lock, flags);
+                                accelerator->hooks->new_device(np-
>netdev, dev);
+                                spin_lock_irqsave(&accelerators_lock,
flags);
+                        }
+
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        /* 
+                         * Hooks will get linked into vif_state by a
+                         * future call by the accelerator to
+                         * netfront_accelerator_ready()
+                         */
+
+                        return 0;
+                }
+        }
+
+        /* Couldn't find it, so create a new one and load the module */
+        if ( ( rc = init_accelerator(frontend, &accelerator) ) < 0 ) {
+                spin_unlock_irqrestore(&accelerators_lock, flags);
+                return rc;
+        }
+
+        /* Include this frontend device on the accelerator's list */
+        add_accelerator_vif(accelerator, np, dev);
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+        DPRINTK("%s: loading module %s\n", __FUNCTION__, frontend);
+
+        /* load module */
+        request_module("%s", frontend);
+
+        /*
+         * Module should now call netfront_accelerator_loaded() once
+         * it's up and running, and we can continue from there 
+         */
+
+        return 0;
+}
+
+/*
+ * Go through all the netfront vifs and see if they have requested
+ * this accelerator.  Notify the accelerator plugin of the relevant
+ * device if so.  Called when an accelerator plugin module is first
+ * loaded and connects to netfront.
+ */
+static void 
+accelerator_probe_vifs_on_load(struct netfront_accelerator
*accelerator)
+{
+        struct netfront_accel_vif_state *accel_vif_state;
+
+        DPRINTK("%s: %p\n", __FUNCTION__, accelerator);
+
+        list_for_each_entry( accel_vif_state, 
+                             &accelerator->vif_states, link ) {
+                struct netfront_info *np = accel_vif_state->np;
+
+                accelerator->hooks->new_device(np->netdev, 
+                                               accel_vif_state->dev);
+
+                /*
+                 * Hooks will get linked into vif_state by a call to
+                 * netfront_accelerator_ready() once accelerator
+                 * plugin is ready for action
+                 */
+        }
+}
+
+
+/* 
+ * Called by the netfront accelerator plugin module when it has loaded 
+ */
+int netfront_accelerator_loaded(const char *frontend, 
+                                struct netfront_accel_hooks *hooks)
+{
+        struct netfront_accelerator *accelerator;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        /* Look through list of accelerators to see if it has already
+           been requested */
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /* 
+                         * Deliberate double inc of usecount here -
+                         * one to initialise it to 1 now hooks is
+                         * being set (which persists until unloaded),
+                         * and one for the use of hooks in this
+                         * function (we don't want an unload to
+                         * succeed in clearing hooks in the middle)
+                         */
+                        BUG_ON(accelerator->hooks != NULL || 
+                               accelerator->hooks_usecount != 0);
+                        accelerator->hooks_usecount = 2;
+
+                        accelerator->hooks = hooks;
+
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        accelerator_probe_vifs_on_load(accelerator);
+
+                        spin_lock_irqsave(&accelerators_lock, flags);
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        return 0;
+                }
+        }
+
+        /* If it wasn't in the list, add it now so that when it is
+           requested the caller will find it */
+        DPRINTK("%s: Couldn't find matching accelerator (%s)\n",
+                __FUNCTION__, frontend);
+
+        init_accelerator(frontend, &accelerator);
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+        return 0;
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_loaded);
+
+
+/* 
+ * Called by the accelerator module after it has been probed with a
+ * network device to say that it is ready to start accelerating
+ * traffic on that device
+ */
+void netfront_accelerator_ready(const char *frontend,
+                                struct xenbus_device *dev)
+{
+        struct netfront_accelerator *accelerator;
+        struct netfront_accel_vif_state *accel_vif_state;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        ++accelerator->hooks_usecount;
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        list_for_each_entry( accel_vif_state,
+                                             &accelerator->vif_states,
link ) {
+                                if ( accel_vif_state->dev == dev )
+                                        accelerator_set_vif_state_hooks
+                                                (accel_vif_state);
+                        }
+
+                        spin_lock_irqsave(&accelerators_lock, flags);
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        return;
+                }
+        }
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_ready);
+
+
+/* 
+ * Called by a netfront accelerator when it is unloaded.  This safely
+ * removes the hooks into the plugin and blocks until all devices have
+ * finished using it, so on return it is safe to unload.
+ */
+void netfront_accelerator_unloaded(const char *frontend)
+{
+        struct netfront_accelerator *accelerator;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /* 
+                         * Use semaphore to ensure we know when all
+                         * uses of hooks are complete
+                         */
+                        sema_init(&accelerator->exit_semaphore, 0);
+
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+
+                        spin_unlock_irqrestore(&accelerators_lock,
flags);
+
+                        /* Wait for hooks to be unused, then return */
+                        down(&accelerator->exit_semaphore);
+                        
+                        return;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_unloaded);
+
+
+/* 
+ * Macro to call one of the accelerator's function hooks.  The use
+ * count for the accelerator's hooks is incremented for the duration
+ * of the call to prevent the accelerator being able to modify the
+ * hooks in the middle (by, for example, unloading)
+ */ 
+#define netfront_call_accelerator_hook(_np, _hook, _args...)
\
+        do {
\
+                if ( (_np)->accel_vif_state.hooks ) {
\
+                        unsigned flags;
\
+                        spin_lock_irqsave(&accelerators_lock, flags);
\
+                        ++(_np)->accelerator->hooks_usecount;
\
+                        spin_unlock_irqrestore(&accelerators_lock,
flags); \
+                        if ( (_np)->accel_vif_state.hooks )
\
+                                (_np)->accel_vif_state.hooks->_hook
(_args); \
+                        spin_lock_irqsave(&accelerators_lock, flags);
\
+                        if ( (--(_np)->accelerator->hooks_usecount) ==
0 ) \
+                                accelerator_remove_hooks((_np)-
>accelerator); \
+                        spin_unlock_irqrestore(&accelerators_lock,
flags); \
+                }
\
+        } while(0)
+
+
static inline int xennet_can_sg(struct net_device *dev)
{
return dev->features & NETIF_F_SG;
@@ -334,6 +673,8 @@ static int __devexit netfront_remove(str

DPRINTK("%s\n", dev->nodename);

+        netfront_call_accelerator_hook(info, remove, dev);
+
netif_disconnect_backend(info);

del_timer_sync(&info->rx_refill_timer);
@@ -358,6 +699,8 @@ static int netfront_resume(struct xenbus
struct netfront_info *info = dev->dev.driver_data;

DPRINTK("%s\n", dev->nodename);
+
+        netfront_call_accelerator_hook(info, resume, dev);

netif_disconnect_backend(info);
return 0;
@@ -577,6 +920,9 @@ static void backend_changed(struct xenbu
xenbus_frontend_closed(dev);
break;
}
+
+        netfront_call_accelerator_hook(np, backend_changed, 
+                                       dev, backend_state);
}

/** Send a packet on a net device to encourage switches to learn the
@@ -633,8 +979,12 @@ static int network_open(struct net_devic
if (netfront_carrier_ok(np)) {
network_alloc_rx_buffers(dev);
np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
- if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+ if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)){
+                        netfront_call_accelerator_hook(np, 
+
stop_napi_interrupts, 
+                                                       dev);
netif_rx_schedule(dev);
+                }
}
spin_unlock_bh(&np->rx_lock);

@@ -702,6 +1052,8 @@ static void rx_refill_timeout(unsigned l
static void rx_refill_timeout(unsigned long data)
{
struct net_device *dev = (struct net_device *)data;
+ struct netfront_info *np = netdev_priv(dev);
+        netfront_call_accelerator_hook(np, stop_napi_interrupts, dev);
netif_rx_schedule(dev);
}

@@ -941,6 +1293,12 @@ static int network_start_xmit(struct sk_
unsigned int offset = offset_in_page(data);
unsigned int len = skb_headlen(skb);

+        /* Check the fast path, if hooks are available */
+        if ( np->accel_vif_state.hooks &&
+             np->accel_vif_state.hooks->start_xmit(skb, dev) ) {
+                return 0;
+        }
+
frags += (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
@@ -1044,8 +1402,12 @@ static irqreturn_t netif_int(int irq, vo
if (likely(netfront_carrier_ok(np))) {
network_tx_buf_gc(dev);
/* Under tx_lock: protects access to rx shared-ring indexes. */
- if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+ if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)) {
+                        netfront_call_accelerator_hook(np, 
+
stop_napi_interrupts, 
+                                                       dev);
netif_rx_schedule(dev);
+                }
}

spin_unlock_irqrestore(&np->tx_lock, flags);
@@ -1305,7 +1667,7 @@ static int netif_poll(struct net_device 
struct netif_extra_info *extras = rinfo.extras;
RING_IDX i, rp;
struct multicall_entry *mcl;
- int work_done, budget, more_to_do = 1;
+ int work_done, budget, more_to_do = 1, accel_more_to_do = 1;
struct sk_buff_head rxq;
struct sk_buff_head errq;
struct sk_buff_head tmpq;
@@ -1472,6 +1834,20 @@ err:

network_alloc_rx_buffers(dev);

+        if (work_done < budget) {
+                /* there's some spare capacity, try the accelerated
path */
+                int accel_budget = budget - work_done;
+                int accel_budget_start = accel_budget;
+
+                if ( np->accel_vif_state.hooks ) {
+                        accel_more_to_do = 
+                                np->accel_vif_state.hooks->netdev_poll
+                                (dev, &accel_budget);
+                        work_done += (accel_budget_start -
accel_budget);
+                } else 
+                        accel_more_to_do = 0;
+        }
+
*pbudget   -= work_done;
dev->quota -= work_done;

@@ -1479,15 +1855,26 @@ err:
local_irq_save(flags);

RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
- if (!more_to_do)
+
+ if (!more_to_do && !accel_more_to_do) {
+                        /* Slow path has nothing more to do, see if
+                           fast path is likewise */
+                        if ( np->accel_vif_state.hooks ) {
+                                accel_more_to_do = 
+                                        np->accel_vif_state.hooks-
>start_napi_interrupts(dev);
+                        }
+                }
+
+ if (!more_to_do && !accel_more_to_do) {
__netif_rx_complete(dev);
+                }

local_irq_restore(flags);
}

spin_unlock(&np->rx_lock);
-
- return more_to_do;
+ 
+        return more_to_do | accel_more_to_do;
}

static void netif_release_tx_bufs(struct netfront_info *np)
@@ -1687,7 +2074,9 @@ static int network_connect(struct net_de
struct sk_buff *skb;
grant_ref_t ref;
netif_rx_request_t *req;
- unsigned int feature_rx_copy, feature_rx_flip;
+ unsigned int feature_rx_copy, feature_rx_flip, feature_accel;
+        char *accel_frontend;
+        int accel_len;

err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
   "feature-rx-copy", "%u", &feature_rx_copy);
@@ -1698,6 +2087,13 @@ static int network_connect(struct net_de
if (err != 1)
feature_rx_flip = 1;

+        feature_accel = 1;
+        accel_frontend = xenbus_read(XBT_NIL, np->xbdev->otherend, 
+                                     "accel", &accel_len);
+        if ( IS_ERR(accel_frontend) ) {
+                feature_accel = 0;
+        }
+
/*
* Copy packets on receive path if:
*  (a) This was requested by user, and the backend supports it; or
@@ -1709,6 +2105,11 @@ static int network_connect(struct net_de
err = talk_to_backend(np->xbdev, np);
if (err)
return err;
+
+        if ( feature_accel ) {
+                netfront_load_accelerator(np, np->xbdev,
accel_frontend);
+                kfree(accel_frontend);
+        }

xennet_set_features(dev);

@@ -1955,6 +2356,7 @@ static struct net_device * __devinit cre

spin_lock_init(&np->tx_lock);
spin_lock_init(&np->rx_lock);
+        np->accel_vif_state.hooks = NULL;

skb_queue_head_init(&np->rx_batch);
np->rx_target     = RX_DFL_MIN_TARGET;
@@ -2110,6 +2512,9 @@ static int __init netif_init(void)
if (is_initial_xendomain())
return 0;

+        INIT_LIST_HEAD(&accelerators_list);
+        spin_lock_init(&accelerators_lock);
+
IPRINTK("Initialising virtual ethernet driver.\n");

(void)register_inetaddr_notifier(&notifier_inetdev);
diff -r ce3d5c548e67 linux-2.6-xen-
sparse/drivers/xen/netfront/netfront.h
--- /dev/null Thu Jan 01 00:00:00 1970 +0000
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.h Thu May 17
09:56:41 2007 +0100
@@ -0,0 +1,190 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person
obtaining a copy
+ * of this source file (the "Software"), to deal in the Software
without
+ * restriction, including without limitation the rights to use, copy,
modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the
Software,
+ * and to permit persons to whom the Software is furnished to do so,
subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be
included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef NETFRONT_H
+#define NETFRONT_H
+
+#include <xen/interface/io/netif.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0,
PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0,
PAGE_SIZE)
+
+#include <xen/xenbus.h>
+/* Function pointer table for hooks into a network acceleration
+   plugin.  These are called at appropriate points from the netfront
+   driver */
+struct netfront_accel_hooks {
+        /* new_device: The plugin is asked to support a new network
interface */
+        int (*new_device)(struct net_device *net_dev, struct
xenbus_device *dev);
+        /* suspend, resume, remove: Equivalent to the normal xenbus_*
callbacks */
+        int (*suspend)(struct xenbus_device *dev);
+        int (*resume)(struct xenbus_device *dev);
+        int (*remove)(struct xenbus_device *dev);
+        /* backend_changed: Callback from watch based on backend's
+           xenbus state changing */
+        void (*backend_changed)(struct xenbus_device *dev,
+                                enum xenbus_state backend_state);
+        /* The net_device is being polled, check the accelerated
+           hardware for any pending packets */
+        int (*netdev_poll)(struct net_device *dev, int *pbudget);
+        /* start_xmit: Used to give the accelerated plugin the option
+           of sending a packet.  Returns non-zero if has done so, or
+           zero to decline and force the packet onto normal send path
*/
+        int (*start_xmit)(struct sk_buff *skb, struct net_device *dev);
+        /* start/stop_napi_interrupts Used by netfront to indicate
+           when napi interrupts should be enabled or disabled */
+        int (*start_napi_interrupts)(struct net_device *dev);
+        void (*stop_napi_interrupts)(struct net_device *dev);
+};
+
+/* Per-netfront device state for the accelerator.  This is used to
+   allow efficient per-netfront device access to the accelerator hooks
*/
+struct netfront_accel_vif_state {
+ struct list_head link;
+
+        struct xenbus_device *dev;
+        struct netfront_info *np;
+        struct netfront_accel_hooks *hooks;
+}; 
+
+/* Per-accelerator state stored in netfront.  These form a list that
+   is used to track which devices are accelerated by which plugins,
+   and what plugins are available/have been requested */
+struct netfront_accelerator {
+        /* Used to make a list */
+ struct list_head link;
+        /* ID of the accelerator */
+        int id;
+        /* String describing the accelerator.  Currently this is the
+           name of the accelerator module.  This is provided by the
+           backend accelerator through xenstore */
+        char *frontend;
+        /* The hooks into the accelerator plugin module */
+        struct netfront_accel_hooks *hooks;
+        /* Protect against removal of hooks while in use, must hold
+           accelerators_lock to change */
+        unsigned hooks_usecount;
+        /* List of per-netfront device state (struct
netfront_accel_vif_state)
+           for each netfront device that is using this accelerator */
+        struct list_head vif_states;
+        /* Semaphore to signal that all users of this accelerator have
+           finished using it before module is unloaded */
+        struct semaphore exit_semaphore; 
+};
+
+
+struct netfront_info {
+ struct list_head list;
+ struct net_device *netdev;
+
+ struct net_device_stats stats;
+
+ struct netif_tx_front_ring tx;
+ struct netif_rx_front_ring rx;
+
+ spinlock_t   tx_lock;
+ spinlock_t   rx_lock;
+
+ unsigned int irq;
+ unsigned int copying_receiver;
+ unsigned int carrier;
+
+ /* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+ unsigned rx_min_target, rx_max_target, rx_target;
+ struct sk_buff_head rx_batch;
+
+ struct timer_list rx_refill_timer;
+
+ /*
+ * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
+ * is an index into a chain of free entries.
+ */
+ struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
+ struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
+
+#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+ grant_ref_t gref_tx_head;
+ grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
+ grant_ref_t gref_rx_head;
+ grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+
+ struct xenbus_device *xbdev;
+ int tx_ring_ref;
+ int rx_ring_ref;
+ u8 mac[ETH_ALEN];
+
+ unsigned long rx_pfn_array[NET_RX_RING_SIZE];
+ struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
+ struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+
+        /* Private pointer to state internal to accelerator module */
+        void *accel_priv;
+        /* The (list of) accelerator(s) used by this netfront device */
+        struct netfront_accelerator *accelerator;
+        /* The accelerator state for this netfront device */
+        struct netfront_accel_vif_state accel_vif_state;
+};
+
+
+/* Called by an accelerator plugin module when it has loaded.
+ *
+ * frontend: the string describing the accelerator, currently the
module name 
+ * hooks: the hooks for netfront to use to call into the accelerator
+ */
+extern int netfront_accelerator_loaded(const char *frontend, 
+                                       struct netfront_accel_hooks
*hooks);
+
+/* Called when an accelerator plugin is ready to accelerate a device *
+ *  that has been passed to it from netfront using the "new_device"
+ *  hook.
+ *
+ *  frontend: the string describing the accelerator. Must match the
+ *  one passed to netfront_accelerator_loaded()
+ *  dev: the xenbus device the plugin was asked to accelerate
+ */
+extern void netfront_accelerator_ready(const char *frontend,
+                                       struct xenbus_device *dev);
+
+/* Called by an accelerator plugin module when it is about to unload.
+ *
+ *  frontend: the string describing the accelerator.  Must match the
+ *  one passed to netfront_accelerator_loaded()
+ */ 
+extern void netfront_accelerator_unloaded(const char *frontend);
+
+#endif /* NETFRONT_H */


--=-MBeApUmoyX4/q+RCdNj2
Content-Disposition: attachment; filename=frontend_accel
Content-Type: text/plain; name=frontend_accel; charset=UTF-8
Content-Transfer-Encoding: 7bit

Frontend net driver acceleration

diff -r ce3d5c548e67 linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c
--- a/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Thu May 17 09:56:38 2007 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Fri May 18 10:26:34 2007 +0100
@@ -3,6 +3,7 @@
  *
  * Copyright (c) 2002-2005, K A Fraser
  * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -47,6 +48,7 @@
 #include <linux/if_ether.h>
 #include <linux/io.h>
 #include <linux/moduleparam.h>
+#include <linux/list.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/arp.h>
@@ -73,6 +75,8 @@ struct netfront_cb {
 };
 
 #define NETFRONT_SKB_CB(skb)	((struct netfront_cb *)((skb)->cb))
+
+#include "netfront.h"
 
 /*
  * Mutually-exclusive module options to select receive data path:
@@ -144,57 +148,6 @@ static inline int netif_needs_gso(struct
 
 #define GRANT_INVALID_REF	0
 
-#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
-#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
-
-struct netfront_info {
-	struct list_head list;
-	struct net_device *netdev;
-
-	struct net_device_stats stats;
-
-	struct netif_tx_front_ring tx;
-	struct netif_rx_front_ring rx;
-
-	spinlock_t   tx_lock;
-	spinlock_t   rx_lock;
-
-	unsigned int irq;
-	unsigned int copying_receiver;
-	unsigned int carrier;
-
-	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
-	struct sk_buff_head rx_batch;
-
-	struct timer_list rx_refill_timer;
-
-	/*
-	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
-	 * is an index into a chain of free entries.
-	 */
-	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
-	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
-
-#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	grant_ref_t gref_tx_head;
-	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
-	grant_ref_t gref_rx_head;
-	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
-	struct xenbus_device *xbdev;
-	int tx_ring_ref;
-	int rx_ring_ref;
-	u8 mac[ETH_ALEN];
-
-	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
-	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
-	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
-};
-
 struct netfront_rx_info {
 	struct netif_rx_response rx;
 	struct netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
@@ -278,6 +231,392 @@ static void xennet_sysfs_delif(struct ne
 #define xennet_sysfs_delif(dev) do { } while(0)
 #endif
 
+/*
+ * List of all netfront accelerator plugin modules available.  Each
+ * list entry is of type struct netfront_accelerator.
+ */ 
+static struct list_head accelerators_list;
+/*
+ * Lock to protect access to accelerators_list, and also used to
+ * protect the hooks_usecount field in struct netfront_accelerator
+ * against concurrent access 
+ */
+static spinlock_t accelerators_lock;
+
+/* 
+ * Safely remove the accelerator function hooks from a netfront state.
+ * Must only be called when there are no current users of the hooks.
+ */
+static void accelerator_remove_hooks(struct netfront_accelerator *accelerator)
+{
+        struct netfront_accel_vif_state *vif_state;
+
+        list_for_each_entry( vif_state,
+                             &accelerator->vif_states,
+                             link ) {
+                /* Make sure there are no data path operations going on */
+                netif_poll_disable(vif_state->np->netdev);
+                netif_tx_disable(vif_state->np->netdev);
+                
+                /* 
+                 * Remove the hooks, but leave the vif_state on the
+                 * accelerator's list as that signifies this vif is
+                 * interested in using that accelerator if it becomes
+                 * available again
+                 */
+                vif_state->hooks = NULL;
+                
+                netif_wake_queue(vif_state->np->netdev);
+                netif_poll_enable(vif_state->np->netdev);
+        }
+
+        accelerator->hooks = NULL;
+
+        /* Signal that all users of hooks are done */
+        up(&accelerator->exit_semaphore);
+}
+
+
+/*
+ * Compare a frontend description string against an accelerator to see
+ * if they match.  Would ultimately be nice to replace the string with
+ * a unique numeric identifier for each accelerator.
+ */
+static int match_accelerator(const char *frontend, 
+                             struct netfront_accelerator *accelerator)
+{
+        return strcmp(frontend, accelerator->frontend) == 0;
+}
+
+
+/* 
+ * Add a frontend vif to the list of vifs that is using a netfront
+ * accelerator plugin module.
+ */
+static void add_accelerator_vif(struct netfront_accelerator *accelerator,
+                                struct netfront_info *np,
+                                struct xenbus_device *dev)
+{
+        np->accelerator = accelerator;
+        np->accel_vif_state.np = np;
+        np->accel_vif_state.dev = dev;
+
+        list_add(&np->accel_vif_state.link, &accelerator->vif_states);
+}
+
+/*
+ * Initialise the netfront state of an accelerator plugin module.
+ */ 
+static int init_accelerator(const char *frontend, 
+                            struct netfront_accelerator **result)
+{
+        struct netfront_accelerator *accelerator = 
+                kmalloc(sizeof(struct netfront_accelerator), GFP_KERNEL);
+        int frontend_len;
+
+        if ( !accelerator ) {
+                DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+                return -ENOMEM;
+        }
+
+        frontend_len = strlen(frontend) + 1;
+        accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+        if ( !accelerator->frontend ) {
+                DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+                kfree(accelerator);
+                return -ENOMEM;
+        }
+        strlcpy(accelerator->frontend, frontend, frontend_len);
+        
+        INIT_LIST_HEAD(&accelerator->vif_states);
+
+        accelerator->hooks = NULL;
+        accelerator->hooks_usecount = 0;
+
+        list_add(&accelerator->link, &accelerators_list);
+
+        *result = accelerator;
+
+        return 0;
+}                                        
+
+/* 
+ * Modify the hooks stored in the per-vif state to match that in the
+ * netfront accelerator's state.
+ */
+static void 
+accelerator_set_vif_state_hooks(struct netfront_accel_vif_state *vif_state)
+{
+        /* Make sure there are no data path operations going on */
+        netif_poll_disable(vif_state->np->netdev);
+        netif_tx_disable(vif_state->np->netdev);
+        
+        vif_state->hooks = vif_state->np->accelerator->hooks;
+        
+        netif_wake_queue(vif_state->np->netdev);
+        netif_poll_enable(vif_state->np->netdev);
+}
+
+
+/*  
+ * Request that a particular netfront accelerator plugin is loaded.
+ * Usually called as a result of the vif configuration specifying
+ * which one to use.
+ */
+static int netfront_load_accelerator(struct netfront_info *np, 
+                                     struct xenbus_device *dev, 
+                                     const char *frontend)
+{
+        struct netfront_accelerator *accelerator;
+        int rc;
+        unsigned flags;
+        
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        /* 
+         * Look at list of loaded accelerators to see if the requested
+         * one is already there 
+         */
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /*
+                         * Include this frontend device on the
+                         * accelerator's list 
+                         */
+                        add_accelerator_vif(accelerator, np, dev);
+
+                        ++accelerator->hooks_usecount;
+
+                        if ( accelerator->hooks == NULL )
+                                DPRINTK("%s: no hooks set", __FUNCTION__);
+                        else {
+                                spin_unlock_irqrestore(&accelerators_lock, flags);
+                                accelerator->hooks->new_device(np->netdev, dev);
+                                spin_lock_irqsave(&accelerators_lock, flags);
+                        }
+
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        /* 
+                         * Hooks will get linked into vif_state by a
+                         * future call by the accelerator to
+                         * netfront_accelerator_ready()
+                         */
+
+                        return 0;
+                }
+        }
+
+        /* Couldn't find it, so create a new one and load the module */
+        if ( ( rc = init_accelerator(frontend, &accelerator) ) < 0 ) {
+                spin_unlock_irqrestore(&accelerators_lock, flags);
+                return rc;
+        }
+
+        /* Include this frontend device on the accelerator's list */
+        add_accelerator_vif(accelerator, np, dev);
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+        DPRINTK("%s: loading module %s\n", __FUNCTION__, frontend);
+
+        /* load module */
+        request_module("%s", frontend);
+
+        /*
+         * Module should now call netfront_accelerator_loaded() once
+         * it's up and running, and we can continue from there 
+         */
+
+        return 0;
+}
+
+/*
+ * Go through all the netfront vifs and see if they have requested
+ * this accelerator.  Notify the accelerator plugin of the relevant
+ * device if so.  Called when an accelerator plugin module is first
+ * loaded and connects to netfront.
+ */
+static void 
+accelerator_probe_vifs_on_load(struct netfront_accelerator *accelerator)
+{
+        struct netfront_accel_vif_state *accel_vif_state;
+
+        DPRINTK("%s: %p\n", __FUNCTION__, accelerator);
+
+        list_for_each_entry( accel_vif_state, 
+                             &accelerator->vif_states, link ) {
+                struct netfront_info *np = accel_vif_state->np;
+
+                accelerator->hooks->new_device(np->netdev, 
+                                               accel_vif_state->dev);
+
+                /*
+                 * Hooks will get linked into vif_state by a call to
+                 * netfront_accelerator_ready() once accelerator
+                 * plugin is ready for action
+                 */
+        }
+}
+
+
+/* 
+ * Called by the netfront accelerator plugin module when it has loaded 
+ */
+int netfront_accelerator_loaded(const char *frontend, 
+                                struct netfront_accel_hooks *hooks)
+{
+        struct netfront_accelerator *accelerator;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        /* Look through list of accelerators to see if it has already
+           been requested */
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /* 
+                         * Deliberate double inc of usecount here -
+                         * one to initialise it to 1 now hooks is
+                         * being set (which persists until unloaded),
+                         * and one for the use of hooks in this
+                         * function (we don't want an unload to
+                         * succeed in clearing hooks in the middle)
+                         */
+                        BUG_ON(accelerator->hooks != NULL || 
+                               accelerator->hooks_usecount != 0);
+                        accelerator->hooks_usecount = 2;
+
+                        accelerator->hooks = hooks;
+
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        accelerator_probe_vifs_on_load(accelerator);
+
+                        spin_lock_irqsave(&accelerators_lock, flags);
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        return 0;
+                }
+        }
+
+        /* If it wasn't in the list, add it now so that when it is
+           requested the caller will find it */
+        DPRINTK("%s: Couldn't find matching accelerator (%s)\n",
+                __FUNCTION__, frontend);
+
+        init_accelerator(frontend, &accelerator);
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+        return 0;
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_loaded);
+
+
+/* 
+ * Called by the accelerator module after it has been probed with a
+ * network device to say that it is ready to start accelerating
+ * traffic on that device
+ */
+void netfront_accelerator_ready(const char *frontend,
+                                struct xenbus_device *dev)
+{
+        struct netfront_accelerator *accelerator;
+        struct netfront_accel_vif_state *accel_vif_state;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        ++accelerator->hooks_usecount;
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        list_for_each_entry( accel_vif_state,
+                                             &accelerator->vif_states, link ) {
+                                if ( accel_vif_state->dev == dev )
+                                        accelerator_set_vif_state_hooks
+                                                (accel_vif_state);
+                        }
+
+                        spin_lock_irqsave(&accelerators_lock, flags);
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        return;
+                }
+        }
+
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_ready);
+
+
+/* 
+ * Called by a netfront accelerator when it is unloaded.  This safely
+ * removes the hooks into the plugin and blocks until all devices have
+ * finished using it, so on return it is safe to unload.
+ */
+void netfront_accelerator_unloaded(const char *frontend)
+{
+        struct netfront_accelerator *accelerator;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+
+        list_for_each_entry( accelerator, &accelerators_list, link ) {
+                if ( match_accelerator(frontend, accelerator) ) {
+                        /* 
+                         * Use semaphore to ensure we know when all
+                         * uses of hooks are complete
+                         */
+                        sema_init(&accelerator->exit_semaphore, 0);
+
+                        if ( (--accelerator->hooks_usecount) == 0 )
+                                accelerator_remove_hooks(accelerator);
+
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                        /* Wait for hooks to be unused, then return */
+                        down(&accelerator->exit_semaphore);
+                        
+                        return;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_unloaded);
+
+
+/* 
+ * Macro to call one of the accelerator's function hooks.  The use
+ * count for the accelerator's hooks is incremented for the duration
+ * of the call to prevent the accelerator being able to modify the
+ * hooks in the middle (by, for example, unloading)
+ */ 
+#define netfront_call_accelerator_hook(_np, _hook, _args...)            \
+        do {                                                            \
+                if ( (_np)->accel_vif_state.hooks ) {                   \
+                        unsigned flags;                                 \
+                        spin_lock_irqsave(&accelerators_lock, flags);   \
+                        ++(_np)->accelerator->hooks_usecount;           \
+                        spin_unlock_irqrestore(&accelerators_lock, flags); \
+                        if ( (_np)->accel_vif_state.hooks )             \
+                                (_np)->accel_vif_state.hooks->_hook(_args); \
+                        spin_lock_irqsave(&accelerators_lock, flags);   \
+                        if ( (--(_np)->accelerator->hooks_usecount) == 0 ) \
+                                accelerator_remove_hooks((_np)->accelerator); \
+                        spin_unlock_irqrestore(&accelerators_lock, flags); \
+                }                                                       \
+        } while(0)
+
+
 static inline int xennet_can_sg(struct net_device *dev)
 {
 	return dev->features & NETIF_F_SG;
@@ -334,6 +673,8 @@ static int __devexit netfront_remove(str
 
 	DPRINTK("%s\n", dev->nodename);
 
+        netfront_call_accelerator_hook(info, remove, dev);
+
 	netif_disconnect_backend(info);
 
 	del_timer_sync(&info->rx_refill_timer);
@@ -358,6 +699,8 @@ static int netfront_resume(struct xenbus
 	struct netfront_info *info = dev->dev.driver_data;
 
 	DPRINTK("%s\n", dev->nodename);
+
+        netfront_call_accelerator_hook(info, resume, dev);
 
 	netif_disconnect_backend(info);
 	return 0;
@@ -577,6 +920,9 @@ static void backend_changed(struct xenbu
 		xenbus_frontend_closed(dev);
 		break;
 	}
+
+        netfront_call_accelerator_hook(np, backend_changed, 
+                                       dev, backend_state);
 }
 
 /** Send a packet on a net device to encourage switches to learn the
@@ -633,8 +979,12 @@ static int network_open(struct net_devic
 	if (netfront_carrier_ok(np)) {
 		network_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)){
+                        netfront_call_accelerator_hook(np, 
+                                                       stop_napi_interrupts, 
+                                                       dev);
 			netif_rx_schedule(dev);
+                }
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -702,6 +1052,8 @@ static void rx_refill_timeout(unsigned l
 static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
+	struct netfront_info *np = netdev_priv(dev);
+        netfront_call_accelerator_hook(np, stop_napi_interrupts, dev);
 	netif_rx_schedule(dev);
 }
 
@@ -941,6 +1293,12 @@ static int network_start_xmit(struct sk_
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 
+        /* Check the fast path, if hooks are available */
+        if ( np->accel_vif_state.hooks &&
+             np->accel_vif_state.hooks->start_xmit(skb, dev) ) {
+                return 0;
+        }
+
 	frags += (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
 		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
@@ -1044,8 +1402,12 @@ static irqreturn_t netif_int(int irq, vo
 	if (likely(netfront_carrier_ok(np))) {
 		network_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)) {
+                        netfront_call_accelerator_hook(np, 
+                                                       stop_napi_interrupts, 
+                                                       dev);
 			netif_rx_schedule(dev);
+                }
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
@@ -1305,7 +1667,7 @@ static int netif_poll(struct net_device 
 	struct netif_extra_info *extras = rinfo.extras;
 	RING_IDX i, rp;
 	struct multicall_entry *mcl;
-	int work_done, budget, more_to_do = 1;
+	int work_done, budget, more_to_do = 1, accel_more_to_do = 1;
 	struct sk_buff_head rxq;
 	struct sk_buff_head errq;
 	struct sk_buff_head tmpq;
@@ -1472,6 +1834,20 @@ err:
 
 	network_alloc_rx_buffers(dev);
 
+        if (work_done < budget) {
+                /* there's some spare capacity, try the accelerated path */
+                int accel_budget = budget - work_done;
+                int accel_budget_start = accel_budget;
+
+                if ( np->accel_vif_state.hooks ) {
+                        accel_more_to_do = 
+                                np->accel_vif_state.hooks->netdev_poll
+                                (dev, &accel_budget);
+                        work_done += (accel_budget_start - accel_budget);
+                } else 
+                        accel_more_to_do = 0;
+        }
+
 	*pbudget   -= work_done;
 	dev->quota -= work_done;
 
@@ -1479,15 +1855,26 @@ err:
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
-		if (!more_to_do)
+
+		if (!more_to_do && !accel_more_to_do) {
+                        /* Slow path has nothing more to do, see if
+                           fast path is likewise */
+                        if ( np->accel_vif_state.hooks ) {
+                                accel_more_to_do = 
+                                        np->accel_vif_state.hooks->start_napi_interrupts(dev);
+                        }
+                }
+
+		if (!more_to_do && !accel_more_to_do) {
 			__netif_rx_complete(dev);
+                }
 
 		local_irq_restore(flags);
 	}
 
 	spin_unlock(&np->rx_lock);
-
-	return more_to_do;
+	
+        return more_to_do | accel_more_to_do;
 }
 
 static void netif_release_tx_bufs(struct netfront_info *np)
@@ -1687,7 +2074,9 @@ static int network_connect(struct net_de
 	struct sk_buff *skb;
 	grant_ref_t ref;
 	netif_rx_request_t *req;
-	unsigned int feature_rx_copy, feature_rx_flip;
+	unsigned int feature_rx_copy, feature_rx_flip, feature_accel;
+        char *accel_frontend;
+        int accel_len;
 
 	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 			   "feature-rx-copy", "%u", &feature_rx_copy);
@@ -1698,6 +2087,13 @@ static int network_connect(struct net_de
 	if (err != 1)
 		feature_rx_flip = 1;
 
+        feature_accel = 1;
+        accel_frontend = xenbus_read(XBT_NIL, np->xbdev->otherend, 
+                                     "accel", &accel_len);
+        if ( IS_ERR(accel_frontend) ) {
+                feature_accel = 0;
+        }
+
 	/*
 	 * Copy packets on receive path if:
 	 *  (a) This was requested by user, and the backend supports it; or
@@ -1709,6 +2105,11 @@ static int network_connect(struct net_de
 	err = talk_to_backend(np->xbdev, np);
 	if (err)
 		return err;
+
+        if ( feature_accel ) {
+                netfront_load_accelerator(np, np->xbdev, accel_frontend);
+                kfree(accel_frontend);
+        }
 
 	xennet_set_features(dev);
 
@@ -1955,6 +2356,7 @@ static struct net_device * __devinit cre
 
 	spin_lock_init(&np->tx_lock);
 	spin_lock_init(&np->rx_lock);
+        np->accel_vif_state.hooks = NULL;
 
 	skb_queue_head_init(&np->rx_batch);
 	np->rx_target     = RX_DFL_MIN_TARGET;
@@ -2110,6 +2512,9 @@ static int __init netif_init(void)
 	if (is_initial_xendomain())
 		return 0;
 
+        INIT_LIST_HEAD(&accelerators_list);
+        spin_lock_init(&accelerators_lock);
+
 	IPRINTK("Initialising virtual ethernet driver.\n");
 
 	(void)register_inetaddr_notifier(&notifier_inetdev);
diff -r ce3d5c548e67 linux-2.6-xen-sparse/drivers/xen/netfront/netfront.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.h	Thu May 17 09:56:41 2007 +0100
@@ -0,0 +1,190 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef NETFRONT_H
+#define NETFRONT_H
+
+#include <xen/interface/io/netif.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
+
+#include <xen/xenbus.h>
+/* Function pointer table for hooks into a network acceleration
+   plugin.  These are called at appropriate points from the netfront
+   driver */
+struct netfront_accel_hooks {
+        /* new_device: The plugin is asked to support a new network interface */
+        int (*new_device)(struct net_device *net_dev, struct xenbus_device *dev);
+        /* suspend, resume, remove: Equivalent to the normal xenbus_* callbacks */
+        int (*suspend)(struct xenbus_device *dev);
+        int (*resume)(struct xenbus_device *dev);
+        int (*remove)(struct xenbus_device *dev);
+        /* backend_changed: Callback from watch based on backend's
+           xenbus state changing */
+        void (*backend_changed)(struct xenbus_device *dev,
+                                enum xenbus_state backend_state);
+        /* The net_device is being polled, check the accelerated
+           hardware for any pending packets */
+        int (*netdev_poll)(struct net_device *dev, int *pbudget);
+        /* start_xmit: Used to give the accelerated plugin the option
+           of sending a packet.  Returns non-zero if has done so, or
+           zero to decline and force the packet onto normal send path */
+        int (*start_xmit)(struct sk_buff *skb, struct net_device *dev);
+        /* start/stop_napi_interrupts Used by netfront to indicate
+           when napi interrupts should be enabled or disabled */
+        int (*start_napi_interrupts)(struct net_device *dev);
+        void (*stop_napi_interrupts)(struct net_device *dev);
+};
+
+/* Per-netfront device state for the accelerator.  This is used to
+   allow efficient per-netfront device access to the accelerator hooks */
+struct netfront_accel_vif_state {
+	struct list_head link;
+
+        struct xenbus_device *dev;
+        struct netfront_info *np;
+        struct netfront_accel_hooks *hooks;
+}; 
+
+/* Per-accelerator state stored in netfront.  These form a list that
+   is used to track which devices are accelerated by which plugins,
+   and what plugins are available/have been requested */
+struct netfront_accelerator {
+        /* Used to make a list */
+	struct list_head link;
+        /* ID of the accelerator */
+        int id;
+        /* String describing the accelerator.  Currently this is the
+           name of the accelerator module.  This is provided by the
+           backend accelerator through xenstore */
+        char *frontend;
+        /* The hooks into the accelerator plugin module */
+        struct netfront_accel_hooks *hooks;
+        /* Protect against removal of hooks while in use, must hold
+           accelerators_lock to change */
+        unsigned hooks_usecount;
+        /* List of per-netfront device state (struct netfront_accel_vif_state)
+           for each netfront device that is using this accelerator */
+        struct list_head vif_states;
+        /* Semaphore to signal that all users of this accelerator have
+           finished using it before module is unloaded */
+        struct semaphore exit_semaphore; 
+};
+
+
+struct netfront_info {
+	struct list_head list;
+	struct net_device *netdev;
+
+	struct net_device_stats stats;
+
+	struct netif_tx_front_ring tx;
+	struct netif_rx_front_ring rx;
+
+	spinlock_t   tx_lock;
+	spinlock_t   rx_lock;
+
+	unsigned int irq;
+	unsigned int copying_receiver;
+	unsigned int carrier;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
+	/*
+	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
+	 * is an index into a chain of free entries.
+	 */
+	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
+	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
+
+#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	grant_ref_t gref_tx_head;
+	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
+	grant_ref_t gref_rx_head;
+	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+
+	struct xenbus_device *xbdev;
+	int tx_ring_ref;
+	int rx_ring_ref;
+	u8 mac[ETH_ALEN];
+
+	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
+	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
+	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+
+        /* Private pointer to state internal to accelerator module */
+        void *accel_priv;
+        /* The (list of) accelerator(s) used by this netfront device */
+        struct netfront_accelerator *accelerator;
+        /* The accelerator state for this netfront device */
+        struct netfront_accel_vif_state accel_vif_state;
+};
+
+
+/* Called by an accelerator plugin module when it has loaded.
+ *
+ * frontend: the string describing the accelerator, currently the module name 
+ * hooks: the hooks for netfront to use to call into the accelerator
+ */
+extern int netfront_accelerator_loaded(const char *frontend, 
+                                       struct netfront_accel_hooks *hooks);
+
+/* Called when an accelerator plugin is ready to accelerate a device *
+ *  that has been passed to it from netfront using the "new_device"
+ *  hook.
+ *
+ *  frontend: the string describing the accelerator. Must match the
+ *  one passed to netfront_accelerator_loaded()
+ *  dev: the xenbus device the plugin was asked to accelerate
+ */
+extern void netfront_accelerator_ready(const char *frontend,
+                                       struct xenbus_device *dev);
+
+/* Called by an accelerator plugin module when it is about to unload.
+ *
+ *  frontend: the string describing the accelerator.  Must match the
+ *  one passed to netfront_accelerator_loaded()
+ */ 
+extern void netfront_accelerator_unloaded(const char *frontend);
+
+#endif /* NETFRONT_H */

--=-MBeApUmoyX4/q+RCdNj2
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xensource.com
http://lists.xensource.com/xen-devel

--=-MBeApUmoyX4/q+RCdNj2--
