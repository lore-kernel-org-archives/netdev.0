From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Thu, 01 May 2003 22:01:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501120815.25BE22C155@lists.samba.org>
References: <20030501.000058.39187964.davem@redhat.com>
Cc: kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Cc: shemminger@osdl.org, netdev@oss.sgi.com, acme@conectiva.com.br,
   Werner Almesberger <wa@almesberger.net>
In-reply-to: Your message of "Thu, 01 May 2003 00:00:58 MST."
             <20030501.000058.39187964.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030501.000058.39187964.davem@redhat.com> you write:
>    From: kuznet@ms2.inr.ac.ru
>    Date: Thu, 1 May 2003 05:10:33 +0400 (MSD)
> 
> [ Rusty, just skip down to "Ok ok ok!", it's something we've
>   discussed before.  Some of these problems are becomming so
>   widespread that we need to implement a fix, I'll probably be
>   the one to end up doing it... ]
> 
>    > 1) dev_get() gets module reference and dev_put() puts is.
>    >    Ugly, as this means dev_get() can fail, but this does
>    >    cover all the possible cases.
>    
>    Seems, you eventually _really_ understood why I histerically moan
>    about bogosity of modules and maybe ready to recongnize that it is
>    not just histerical moaning in some part. :-)
>    
> Yes, I know, and we can talk about this until the cows come
> home... :-)

I agree with Alexey.  Modules are poor-man's microkernel: allowing
them to be unloaded has always been a horror.  But I failed to
convince my collegues of this at the 2002 kernel summit, so I did the
best with what we had.  If I had my way, we would *never* remove
modules (even on failed init: we might re-try init later, but never
free the memory).

But before we redesign module architecture from scratch, let's look at
a solution with what we do have (assuming Linus takes my damn
__module_get() patch some day, see below).

There are 70 calls to dev_hold() in the kernel.  The vast majority of
them already have a reference, they just want another one: dev_hold()
can do __module_get().

There are a few *sources* of devices: dev_get, dev_get_by*.  These
should check and fail, using "try_dev_hold()" or something.
Unfortunately auditing all the __dev_get_by* is quite a task, since
it's used very widely (and I think, sometime erroneously).

Completely untested patch below other patch.

I need more time to digest your proposal in detail, Dave.  Expect
reply w/in 24 hours.

Thanks.
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

Name: __module_get
Author: Rusty Russell
Status: Tested on 2.5.68-bk10

D: Introduces __module_get for places where we know we already hold
D: a reference and ignoring the fact that the module is being "rmmod --wait"ed
D: is simpler.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .5001-linux-2.5.67-bk5/fs/filesystems.c .5001-linux-2.5.67-bk5.updated/fs/filesystems.c
--- .5001-linux-2.5.67-bk5/fs/filesystems.c	2003-04-14 13:45:44.000000000 +1000
+++ .5001-linux-2.5.67-bk5.updated/fs/filesystems.c	2003-04-14 15:44:36.000000000 +1000
@@ -32,17 +32,7 @@ static rwlock_t file_systems_lock = RW_L
 /* WARNING: This can be used only if we _already_ own a reference */
 void get_filesystem(struct file_system_type *fs)
 {
-	if (!try_module_get(fs->owner)) {
-#ifdef CONFIG_MODULE_UNLOAD
-		unsigned int cpu = get_cpu();
-		local_inc(&fs->owner->ref[cpu].count);
-		put_cpu();
-#else
-		/* Getting filesystem while it's starting up?  We're
-                   already supposed to have a reference. */
-		BUG();
-#endif
-	}
+	__module_get(fs->owner);
 }
 
 void put_filesystem(struct file_system_type *fs)
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .5001-linux-2.5.67-bk5/include/linux/module.h .5001-linux-2.5.67-bk5.updated/include/linux/module.h
--- .5001-linux-2.5.67-bk5/include/linux/module.h	2003-04-08 11:15:01.000000000 +1000
+++ .5001-linux-2.5.67-bk5.updated/include/linux/module.h	2003-04-14 15:45:15.000000000 +1000
@@ -255,6 +255,7 @@ struct module *module_text_address(unsig
 
 #ifdef CONFIG_MODULE_UNLOAD
 
+unsigned int module_refcount(struct module *mod);
 void __symbol_put(const char *symbol);
 #define symbol_put(x) __symbol_put(MODULE_SYMBOL_PREFIX #x)
 void symbol_put_addr(void *addr);
@@ -265,6 +266,17 @@ void symbol_put_addr(void *addr);
 #define local_dec(x) atomic_dec(x)
 #endif
 
+/* Sometimes we know we already have a refcount, and it's easier not
+   to handle the error case (which only happens with rmmod --wait). */
+static inline void __module_get(struct module *module)
+{
+	if (module) {
+		BUG_ON(module_refcount(module) == 0);
+		local_inc(&module->ref[get_cpu()].count);
+		put_cpu();
+	}
+}
+
 static inline int try_module_get(struct module *module)
 {
 	int ret = 1;
@@ -300,6 +317,9 @@ static inline int try_module_get(struct 
 static inline void module_put(struct module *module)
 {
 }
+static inline void __module_get(struct module *module)
+{
+}
 #define symbol_put(x) do { } while(0)
 #define symbol_put_addr(p) do { } while(0)
 
@@ -357,6 +377,10 @@ static inline struct module *module_text
 #define symbol_put(x) do { } while(0)
 #define symbol_put_addr(x) do { } while(0)
 
+static inline void __module_get(struct module *module)
+{
+}
+
 static inline int try_module_get(struct module *module)
 {
 	return 1;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .5001-linux-2.5.67-bk5/kernel/module.c .5001-linux-2.5.67-bk5.updated/kernel/module.c
--- .5001-linux-2.5.67-bk5/kernel/module.c	2003-04-14 13:45:46.000000000 +1000
+++ .5001-linux-2.5.67-bk5.updated/kernel/module.c	2003-04-14 15:44:36.000000000 +1000
@@ -431,7 +431,7 @@ static inline void restart_refcounts(voi
 }
 #endif
 
-static unsigned int module_refcount(struct module *mod)
+unsigned int module_refcount(struct module *mod)
 {
 	unsigned int i, total = 0;
 
@@ -439,6 +439,7 @@ static unsigned int module_refcount(stru
 		total += atomic_read(&mod->ref[i].count);
 	return total;
 }
+EXPORT_SYMBOL(module_refcount);
 
 /* This exists whether we can unload or not */
 static void free_module(struct module *mod);


================

Name: try_dev_hold
Author: Rusty Russell
Status: Experimental
Depends: Module/module_dup.patch.gz

D: Make dev_hold() actually duplicate the module reference count, and
D: introduce try_dev_hold() for where refcount may be zero.  Some
D: places seemed to use dev_hold() to initialize the device reference
D: count to 1.
D:
D: Lots of fixmes caused by quick audit of __dev_get_by* and
D: dev_getbyhwaddr.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/drivers/net/shaper.c working-2.5.68-bk10-netdevice/drivers/net/shaper.c
--- linux-2.5.68-bk10/drivers/net/shaper.c	2003-04-08 11:14:26.000000000 +1000
+++ working-2.5.68-bk10-netdevice/drivers/net/shaper.c	2003-05-01 21:21:46.000000000 +1000
@@ -526,6 +526,7 @@ static int shaper_neigh_setup_dev(struct
 
 static int shaper_attach(struct net_device *shdev, struct shaper *sh, struct net_device *dev)
 {
+	/* FIXME: No reference to dev --RR */
 	sh->dev = dev;
 	sh->hard_start_xmit=dev->hard_start_xmit;
 	sh->get_stats=dev->get_stats;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/drivers/net/wan/dlci.c working-2.5.68-bk10-netdevice/drivers/net/wan/dlci.c
--- linux-2.5.68-bk10/drivers/net/wan/dlci.c	2003-03-18 05:01:46.000000000 +1100
+++ working-2.5.68-bk10-netdevice/drivers/net/wan/dlci.c	2003-05-01 21:20:31.000000000 +1000
@@ -457,6 +457,7 @@ int dlci_add(struct dlci_add *dlci)
 	*(short *)(master->dev_addr) = dlci->dlci;
 
 	dlp = (struct dlci_local *) master->priv;
+	/* FIXME: We have no reference to slave here.  --RR */
 	dlp->slave = slave;
 
 	flp = slave->priv;
@@ -484,6 +485,7 @@ int dlci_del(struct dlci_add *dlci)
 
 	/* validate slave device */
 	master = __dev_get_by_name(dlci->devname);
+	/* FIXME: No lock, no reference held to master. --RR */
 	if (!master)
 		return(-ENODEV);
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/include/linux/netdevice.h working-2.5.68-bk10-netdevice/include/linux/netdevice.h
--- linux-2.5.68-bk10/include/linux/netdevice.h	2003-04-08 11:15:01.000000000 +1000
+++ working-2.5.68-bk10-netdevice/include/linux/netdevice.h	2003-05-01 20:03:27.000000000 +1000
@@ -29,6 +29,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
 #include <linux/kobject.h>
+#include <linux/module.h>
 
 #include <asm/atomic.h>
 #include <asm/cache.h>
@@ -634,7 +635,25 @@ static inline void dev_put(struct net_de
 }
 
 #define __dev_put(dev) atomic_dec(&(dev)->refcnt)
-#define dev_hold(dev) atomic_inc(&(dev)->refcnt)
+
+/* If you already have a reference, and are duplicating it. */
+#define dev_hold(dev)				\
+do {						\
+	atomic_inc(&(dev)->refcnt);		\
+	__module_get((dev)->owner);		\
+} while(0)
+
+/* If you need a new reference, or will be holding it for a long time.
+   If this returns 0, pretend dev doesn't exist (it's being removed now). */
+#define try_dev_hold(dev)			\
+({						\
+	int __ret = 1;				\
+	if (try_module_get((dev)->owner))	\
+		atomic_inc(&(dev)->refcnt);	\
+	else					\
+		__ret = 0;			\
+	__ret;					\
+})
 
 /* Carrier loss detection, dial on demand. The functions netif_carrier_on
  * and _off may be called from IRQ context, but it is caller
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/802/tr.c working-2.5.68-bk10-netdevice/net/802/tr.c
--- linux-2.5.68-bk10/net/802/tr.c	2003-02-07 19:21:54.000000000 +1100
+++ working-2.5.68-bk10-netdevice/net/802/tr.c	2003-05-01 21:24:46.000000000 +1000
@@ -479,6 +479,7 @@ static int rif_get_info(char *buffer,cha
 	for(i=0;i < RIF_TABLE_SIZE;i++) 
 	{
 		for(entry=rif_table[i];entry;entry=entry->next) {
+			/* FIXME: No lock, and no reference to dev. --RR */
 			struct net_device *dev = __dev_get_by_index(entry->iface);
 
 			size=sprintf(buffer+len,"%s %02X:%02X:%02X:%02X:%02X:%02X %7li ",
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/appletalk/ddp.c working-2.5.68-bk10-netdevice/net/appletalk/ddp.c
--- linux-2.5.68-bk10/net/appletalk/ddp.c	2003-05-01 09:29:34.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/appletalk/ddp.c	2003-05-01 21:28:03.000000000 +1000
@@ -920,6 +920,7 @@ static int atrtr_ioctl(unsigned int cmd,
 			 * space, isn't it?
 			 */
 			if (rt.rt_dev) {
+				/* FIXME: No lock, and no reference to dev --RR */
 				dev = __dev_get_by_name(rt.rt_dev);
 				if (!dev)
 					return -ENODEV;
@@ -1217,6 +1218,7 @@ static __inline__ int is_ip_over_ddp(str
 
 static int handle_ip_over_ddp(struct sk_buff *skb)
 {
+	/* FIXME: No lock, and no reference held to dev. --RR */
         struct net_device *dev = __dev_get_by_name("ipddp0");
 	struct net_device_stats *stats;
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/core/dev.c working-2.5.68-bk10-netdevice/net/core/dev.c
--- linux-2.5.68-bk10/net/core/dev.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/core/dev.c	2003-05-01 20:19:24.000000000 +1000
@@ -440,8 +440,8 @@ struct net_device *dev_get_by_name(const
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_name(name);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !try_dev_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -513,8 +513,8 @@ struct net_device *dev_get_by_index(int 
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_index(ifindex);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !try_dev_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -563,8 +563,8 @@ struct net_device * dev_get_by_flags(uns
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_flags(if_flags, mask);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !try_dev_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -2611,7 +2611,7 @@ int register_netdevice(struct net_device
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
 	*dp = dev;
-	dev_hold(dev);
+	atomic_set(&dev->refcnt, 1);
 	dev->deadbeaf = 0;
 	write_unlock_bh(&dev_base_lock);
 
@@ -2899,7 +2899,7 @@ static int __init net_dev_init(void)
 #endif
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
-		dev_hold(dev);
+		atomic_set(&dev->refcnt, 1);
 
 		/*
 		 * Allocate name. If the init() fails
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/core/pktgen.c working-2.5.68-bk10-netdevice/net/core/pktgen.c
--- linux-2.5.68-bk10/net/core/pktgen.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/core/pktgen.c	2003-05-01 21:31:45.000000000 +1000
@@ -226,21 +226,20 @@ static struct net_device *setup_inject(s
 {
 	struct net_device *odev;
 
-	rtnl_lock();
-	odev = __dev_get_by_name(info->outdev);
+	odev = dev_get(info->outdev);
 	if (!odev) {
 		sprintf(info->result, "No such netdevice: \"%s\"", info->outdev);
-		goto out_unlock;
+		return NULL;
 	}
 
 	if (odev->type != ARPHRD_ETHER) {
 		sprintf(info->result, "Not ethernet device: \"%s\"", info->outdev);
-		goto out_unlock;
+		goto out_put;
 	}
 
 	if (!netif_running(odev)) {
 		sprintf(info->result, "Device is down: \"%s\"", info->outdev);
-		goto out_unlock;
+		goto out_put;
 	}
 
 	/* Default to the interface's mac if not explicitly set. */
@@ -281,14 +280,11 @@ static struct net_device *setup_inject(s
 	info->cur_daddr = info->daddr_min;
 	info->cur_udp_dst = info->udp_dst_min;
 	info->cur_udp_src = info->udp_src_min;
-	
-	atomic_inc(&odev->refcnt);
-	rtnl_unlock();
 
 	return odev;
 
-out_unlock:
-	rtnl_unlock();
+out_put:
+	dev_put(odev);
 	return NULL;
 }
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/decnet/dn_dev.c working-2.5.68-bk10-netdevice/net/decnet/dn_dev.c
--- linux-2.5.68-bk10/net/decnet/dn_dev.c	2003-04-20 18:05:16.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/decnet/dn_dev.c	2003-05-01 21:35:29.000000000 +1000
@@ -312,9 +312,7 @@ struct net_device *dn_dev_get_default(vo
 	read_lock(&dndev_lock);
 	dev = decnet_default_device;
 	if (dev) {
-		if (dev->dn_ptr)
-			dev_hold(dev);
-		else
+		if (!dev->dn_ptr || !try_dev_hold(dev))
 			dev = NULL;
 	}
 	read_unlock(&dndev_lock);
@@ -584,6 +582,8 @@ int dn_dev_ioctl(unsigned int cmd, void 
 		goto done;
 	}
 
+	/* FIXME: if cmd == SIOCGIFADDR, don't hold lock, and don't
+           have reference to dev. --RR */
 	if ((dn_db = dev->dn_ptr) != NULL) {
 		for (ifap = &dn_db->ifa_list; (ifa=*ifap) != NULL; ifap = &ifa->ifa_next)
 			if (strcmp(ifr->ifr_name, ifa->ifa_label) == 0)
@@ -677,6 +677,7 @@ static int dn_dev_rtm_newaddr(struct sk_
 	if (rta[IFA_LOCAL-1] == NULL)
 		return -EINVAL;
 
+	/* FIXME: Don't have lock, and don't hold reference to dev. --RR */
 	if ((dev = __dev_get_by_index(ifm->ifa_index)) == NULL)
 		return -ENODEV;
 
@@ -1189,9 +1190,10 @@ void dn_dev_up(struct net_device *dev)
 	 * configured ethernet card in the system.
 	 */
 	if (maybe_default) {
-		dev_hold(dev);
-		if (dn_dev_set_default(dev, 0))
-			dev_put(dev);
+		if (try_dev_hold(dev)) {
+			if (dn_dev_set_default(dev, 0))
+				dev_put(dev);
+		}
 	}
 }
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/decnet/dn_fib.c working-2.5.68-bk10-netdevice/net/decnet/dn_fib.c
--- linux-2.5.68-bk10/net/decnet/dn_fib.c	2003-04-20 18:05:16.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/decnet/dn_fib.c	2003-05-01 21:43:34.000000000 +1000
@@ -218,7 +218,9 @@ static int dn_fib_check_nh(const struct 
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
 			nh->nh_dev = dev;
-			atomic_inc(&dev->refcnt);
+			/* FIXME:  Must hold lock, or use dev_get_by_index.
+			   --RR */
+			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
 		}
@@ -262,7 +264,7 @@ out:
 		if (!(dev->flags&IFF_UP))
 			return -ENETDOWN;
 		nh->nh_dev = dev;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(&nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
 	}
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/decnet/dn_route.c working-2.5.68-bk10-netdevice/net/decnet/dn_route.c
--- linux-2.5.68-bk10/net/decnet/dn_route.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/decnet/dn_route.c	2003-05-01 20:58:08.000000000 +1000
@@ -891,7 +891,9 @@ static int dn_route_output_slow(struct d
 		read_unlock(&dev_base_lock);
 		if (dev_out == NULL)
 			goto out;
-		dev_hold(dev_out);
+		/* FIXME: Shouldn't this be inside the lock? --RR */
+		if (!try_dev_hold(dev_out))
+			goto out;
 source_ok:
 		;
 	}
@@ -960,8 +962,10 @@ source_ok:
 					} else {
 						dev_out = neigh->dev;
 					}
-					dev_hold(dev_out);
-					goto select_source;
+					if (try_dev_hold(dev_out))
+						goto select_source;
+					else
+						dev_out = NULL;
 				}
 			}
 		}
@@ -1035,7 +1039,10 @@ select_source:
 	if (dev_out)
 		dev_put(dev_out);
 	dev_out = DN_FIB_RES_DEV(res);
-	dev_hold(dev_out);
+	if (!try_dev_hold(dev_out)) {
+		dev_out = NULL;
+		goto e_addr;
+	}
 	fl.oif = dev_out->ifindex;
 	gateway = DN_FIB_RES_GW(res);
 
@@ -1231,7 +1238,8 @@ static int dn_route_input_slow(struct sk
 						 "No output device\n");
 			goto e_inval;
 		}
-		dev_hold(out_dev);
+		if (!try_dev_hold(out_dev))
+			goto e_inval;
 
 		if (res.r)
 			src_map = dn_fib_rules_policy(fl.fld_src, &res, &flags);
@@ -1349,8 +1357,12 @@ make_route:
 			rt->u.dst.input = dn_blackhole;
 	}
 	rt->rt_flags = flags;
-	if (rt->u.dst.dev)
-		dev_hold(rt->u.dst.dev);
+	if (rt->u.dst.dev) {
+		if (!try_dev_hold(rt->u.dst.dev)) {
+			dst_free(&rt->u.dst);
+			goto e_inval;
+		}
+	}
 
 	if (dn_rt_set_next_hop(rt, &res))
 		goto e_neighbour;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/decnet/dn_rules.c working-2.5.68-bk10-netdevice/net/decnet/dn_rules.c
--- linux-2.5.68-bk10/net/decnet/dn_rules.c	2003-04-20 18:05:16.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/decnet/dn_rules.c	2003-05-01 21:37:58.000000000 +1000
@@ -173,6 +173,7 @@ int dn_fib_rtm_newrule(struct sk_buff *s
 		memcpy(new_r->r_ifname, RTA_DATA(rta[RTA_IIF-1]), IFNAMSIZ);
 		new_r->r_ifname[IFNAMSIZ-1] = 0;
 		new_r->r_ifindex = -1;
+		/* FIXME: Don't hold lock, and don't get reference. --RR */
 		dev = __dev_get_by_name(new_r->r_ifname);
 		if (dev)
 			new_r->r_ifindex = dev->ifindex;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/fib_frontend.c working-2.5.68-bk10-netdevice/net/ipv4/fib_frontend.c
--- linux-2.5.68-bk10/net/ipv4/fib_frontend.c	2003-05-01 20:36:37.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv4/fib_frontend.c	2003-01-02 12:30:47.000000000 +1100
@@ -115,8 +115,8 @@ struct net_device * ip_dev_find(u32 addr
 	if (res.type != RTN_LOCAL)
 		goto out;
 	dev = FIB_RES_DEV(res);
-	if (dev && !try_dev_get(dev))
-		dev = NULL;
+	if (dev)
+		atomic_inc(&dev->refcnt);
 
 out:
 	fib_res_put(&res);
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/fib_semantics.c working-2.5.68-bk10-netdevice/net/ipv4/fib_semantics.c
--- linux-2.5.68-bk10/net/ipv4/fib_semantics.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv4/fib_semantics.c	2003-05-01 21:39:20.000000000 +1000
@@ -405,6 +405,8 @@ static int fib_check_nh(const struct rtm
 				return -ENODEV;
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
+			/* FIXME:  Must hold lock, or use dev_get_by_index.
+			   --RR */
 			nh->nh_dev = dev;
 			atomic_inc(&dev->refcnt);
 			nh->nh_scope = RT_SCOPE_LINK;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/ip_gre.c working-2.5.68-bk10-netdevice/net/ipv4/ip_gre.c
--- linux-2.5.68-bk10/net/ipv4/ip_gre.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv4/ip_gre.c	2003-05-01 21:50:07.000000000 +1000
@@ -289,7 +289,7 @@ static struct ip_tunnel * ipgre_tunnel_l
 	if (register_netdevice(dev) < 0)
 		goto failed;
 
-	dev_hold(dev);
+	atomic_set(&dev->refcnt, 1);
 	ipgre_tunnel_link(nt);
 	/* Do not decrement MOD_USE_COUNT here. */
 	return nt;
@@ -1205,6 +1205,7 @@ static int ipgre_tunnel_init(struct net_
 	}
 
 	if (!tdev && tunnel->parms.link)
+		/* FIXME: Don't hold lock, don't grab reference. --RR */
 		tdev = __dev_get_by_index(tunnel->parms.link);
 
 	if (tdev) {
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/ipip.c working-2.5.68-bk10-netdevice/net/ipv4/ipip.c
--- linux-2.5.68-bk10/net/ipv4/ipip.c	2003-04-20 18:05:16.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv4/ipip.c	2003-05-01 21:51:47.000000000 +1000
@@ -259,7 +259,7 @@ static struct ip_tunnel * ipip_tunnel_lo
 	if (register_netdevice(dev) < 0)
 		goto failed;
 
-	dev_hold(dev);
+	atomic_set(&dev->refcnt, 1);
 	ipip_tunnel_link(nt);
 	/* Do not decrement MOD_USE_COUNT here. */
 	return nt;
@@ -841,6 +841,7 @@ static int ipip_tunnel_init(struct net_d
 	}
 
 	if (!tdev && tunnel->parms.link)
+		/* FIXME: Don't hold lock, don't grab reference. --RR */
 		tdev = __dev_get_by_index(tunnel->parms.link);
 
 	if (tdev) {
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/ipmr.c working-2.5.68-bk10-netdevice/net/ipv4/ipmr.c
--- linux-2.5.68-bk10/net/ipv4/ipmr.c	2003-03-25 12:17:32.000000000 +1100
+++ working-2.5.68-bk10-netdevice/net/ipv4/ipmr.c	2003-05-01 20:39:29.000000000 +1000
@@ -443,7 +443,6 @@ static int vif_add(struct vifctl *vifc, 
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-	dev_hold(dev);
 	v->dev=dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
@@ -1441,8 +1440,8 @@ int pim_rcv_v1(struct sk_buff * skb)
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
 		reg_dev = vif_table[reg_vif_num].dev;
-	if (reg_dev)
-		dev_hold(reg_dev);
+	if (reg_dev && !try_dev_hold(reg_dev))
+		reg_dev = NULL;
 	read_unlock(&mrt_lock);
 
 	if (reg_dev == NULL) {
@@ -1508,8 +1507,8 @@ int pim_rcv(struct sk_buff * skb)
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
 		reg_dev = vif_table[reg_vif_num].dev;
-	if (reg_dev)
-		dev_hold(reg_dev);
+	if (reg_dev && !try_dev_hold(reg_dev))
+		reg_dev = NULL;
 	read_unlock(&mrt_lock);
 
 	if (reg_dev == NULL) {
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv4/route.c working-2.5.68-bk10-netdevice/net/ipv4/route.c
--- linux-2.5.68-bk10/net/ipv4/route.c	2003-05-01 09:29:35.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv4/route.c	2003-05-01 20:41:28.000000000 +1000
@@ -1992,7 +1992,8 @@ int ip_route_output_slow(struct rtable *
 	if (dev_out)
 		dev_put(dev_out);
 	dev_out = FIB_RES_DEV(res);
-	dev_hold(dev_out);
+	if (!try_dev_hold(dev_out))
+		goto e_inval;
 	fl.oif = dev_out->ifindex;
 
 make_route:
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/ipv6/sit.c working-2.5.68-bk10-netdevice/net/ipv6/sit.c
--- linux-2.5.68-bk10/net/ipv6/sit.c	2003-04-20 18:05:17.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/ipv6/sit.c	2003-05-01 21:55:21.000000000 +1000
@@ -197,7 +197,7 @@ static struct ip_tunnel * ipip6_tunnel_l
 	if (register_netdevice(dev) < 0)
 		goto failed;
 
-	dev_hold(dev);
+	atomic_set(&dev->refcount, 1);
 	ipip6_tunnel_link(nt);
 	/* Do not decrement MOD_USE_COUNT here. */
 	return nt;
@@ -778,6 +778,7 @@ static int ipip6_tunnel_init(struct net_
 	}
 
 	if (!tdev && tunnel->parms.link)
+		/* FIXME: Don't hold lock, don't grab reference. --RR */
 		tdev = __dev_get_by_index(tunnel->parms.link);
 
 	if (tdev) {
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/llc/af_llc.c working-2.5.68-bk10-netdevice/net/llc/af_llc.c
--- linux-2.5.68-bk10/net/llc/af_llc.c	2003-05-01 09:29:36.000000000 +1000
+++ working-2.5.68-bk10-netdevice/net/llc/af_llc.c	2003-05-01 21:13:49.000000000 +1000
@@ -256,6 +256,7 @@ static int llc_ui_autobind(struct socket
 		rc = -ENETUNREACH;
 		if (!dev)
 			goto out;
+		/* FIXME: We don't hold a reference to dev --RR */
 		llc->dev = dev;
 	}
 	/* bind to a specific sap, optional. */
@@ -419,6 +420,7 @@ static int llc_ui_connect(struct socket 
 		rtnl_unlock();
 		if (!dev)
 			goto out;
+		/* FIXME: We don't hold a reference to dev --RR */
 		llc->dev = dev;
 	} else
 		dev = llc->dev;
@@ -764,6 +766,7 @@ static int llc_ui_sendmsg(struct kiocb *
 		dev = dev_getbyhwaddr(addr->sllc_arphrd, addr->sllc_smac);
 		rtnl_unlock();
 		rc = -ENETUNREACH;
+		/* FIXME: We don't hold a reference to dev --RR */
 		if (!dev)
 			goto release;
 	} else
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/netrom/nr_route.c working-2.5.68-bk10-netdevice/net/netrom/nr_route.c
--- linux-2.5.68-bk10/net/netrom/nr_route.c	2003-01-02 12:27:51.000000000 +1100
+++ working-2.5.68-bk10-netdevice/net/netrom/nr_route.c	2003-05-01 20:51:51.000000000 +1000
@@ -567,8 +567,8 @@ struct net_device *nr_dev_get(ax25_addre
 	read_lock(&dev_base_lock);
 	for (dev = dev_base; dev != NULL; dev = dev->next) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM && ax25cmp(addr, (ax25_address *)dev->dev_addr) == 0) {
-			dev_hold(dev);
-			goto out;
+			if (try_dev_hold(dev))
+				goto out;
 		}
 	}
 out:
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.68-bk10/net/rose/rose_route.c working-2.5.68-bk10-netdevice/net/rose/rose_route.c
--- linux-2.5.68-bk10/net/rose/rose_route.c	2003-03-18 12:21:41.000000000 +1100
+++ working-2.5.68-bk10-netdevice/net/rose/rose_route.c	2003-05-01 20:51:59.000000000 +1000
@@ -629,8 +629,8 @@ struct net_device *rose_dev_get(rose_add
 	read_lock(&dev_base_lock);
 	for (dev = dev_base; dev != NULL; dev = dev->next) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE && rosecmp(addr, (rose_address *)dev->dev_addr) == 0) {
-			dev_hold(dev);
-			goto out;
+			if (try_dev_hold(dev))
+				goto out;
 		}
 	}
 out:
