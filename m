From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] can: Update logging style
Date: Wed, 30 Nov 2011 10:23:58 -0800
Message-ID: <1322677438.10023.7.camel@Joe-Laptop>
References: <30551d0a6a0f7f7799a6981c81c770a528f430d2.1322592708.git.joe@perches.com>
	 <4ED53B47.1030703@pengutronix.de> <4ED6331E.6020005@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ED6331E.6020005@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and pr_<level>_ratelimited.
Coalesce format strings.

V2: Appease Oliver Hartkopp by adding "can" to the banner output.

Signed-off-by: Joe Perches <joe@perches.com>

---

> IMO if you want to use pr_fmt() it should at least look like this:
> can: controller area network core (rev 20090105 abi 8)
> NET: Registered protocol family 29
> can_raw: can raw protocol (rev 20090105)
> can_gw: can netlink gateway (rev 20101209)
> can_bcm: can broadcast manager protocol (rev 20090105 t)
> 
> I'm fine with using pr_fmt() for error/warning output but not for the banner
> in the currently suggested way.

I think it's duplicative, but it's not my code.

 net/can/af_can.c |   31 ++++++++++++++-----------------
 net/can/bcm.c    |   14 ++++++++------
 net/can/gw.c     |    6 ++++--
 net/can/proc.c   |    8 ++++----
 net/can/raw.c    |    8 +++++---
 5 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 0ce2ad0..c4f0da5 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -40,6 +40,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
@@ -62,8 +64,8 @@
 
 #include "af_can.h"
 
-static __initdata const char banner[] = KERN_INFO
-	"can: controller area network core (" CAN_VERSION_STRING ")\n";
+static __initdata const char banner[] =
+	"controller area network core (" CAN_VERSION_STRING ")";
 
 MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -161,8 +163,8 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 		 * return -EPROTONOSUPPORT
 		 */
 		if (err)
-			printk_ratelimited(KERN_ERR "can: request_module "
-			       "(can-proto-%d) failed.\n", protocol);
+			pr_err_ratelimited("request_module (can-proto-%d) failed\n",
+					   protocol);
 
 		cp = can_get_proto(protocol);
 	}
@@ -505,8 +507,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 
 	d = find_dev_rcv_lists(dev);
 	if (!d) {
-		printk(KERN_ERR "BUG: receive list not found for "
-		       "dev %s, id %03X, mask %03X\n",
+		pr_err("BUG: receive list not found for dev %s, id %03X, mask %03X\n",
 		       DNAME(dev), can_id, mask);
 		goto out;
 	}
@@ -532,8 +533,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	 */
 
 	if (!next) {
-		printk(KERN_ERR "BUG: receive list entry not found for "
-		       "dev %s, id %03X, mask %03X\n",
+		pr_err("BUG: receive list entry not found for dev %s, id %03X, mask %03X\n",
 		       DNAME(dev), can_id, mask);
 		r = NULL;
 		goto out;
@@ -701,8 +701,7 @@ int can_proto_register(const struct can_proto *cp)
 	int err = 0;
 
 	if (proto < 0 || proto >= CAN_NPROTO) {
-		printk(KERN_ERR "can: protocol number %d out of range\n",
-		       proto);
+		pr_err("protocol number %d out of range\n", proto);
 		return -EINVAL;
 	}
 
@@ -713,8 +712,7 @@ int can_proto_register(const struct can_proto *cp)
 	mutex_lock(&proto_tab_lock);
 
 	if (proto_tab[proto]) {
-		printk(KERN_ERR "can: protocol %d already registered\n",
-		       proto);
+		pr_err("protocol %d already registered\n", proto);
 		err = -EBUSY;
 	} else
 		RCU_INIT_POINTER(proto_tab[proto], cp);
@@ -769,8 +767,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 		/* create new dev_rcv_lists for this device */
 		d = kzalloc(sizeof(*d), GFP_KERNEL);
 		if (!d) {
-			printk(KERN_ERR
-			       "can: allocation of receive list failed\n");
+			pr_err("allocation of receive list failed\n");
 			return NOTIFY_DONE;
 		}
 		BUG_ON(dev->ml_priv);
@@ -790,8 +787,8 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 				dev->ml_priv = NULL;
 			}
 		} else
-			printk(KERN_ERR "can: notifier: receive list not "
-			       "found for dev %s\n", dev->name);
+			pr_err("notifier: receive list not found for dev %s\n",
+			       dev->name);
 
 		spin_unlock(&can_rcvlists_lock);
 
@@ -824,7 +821,7 @@ static struct notifier_block can_netdev_notifier __read_mostly = {
 
 static __init int can_init(void)
 {
-	printk(banner);
+	pr_info("%s\n", banner);
 
 	memset(&can_rx_alldev_list, 0, sizeof(can_rx_alldev_list));
 
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 151b773..540c804 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -39,6 +39,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
@@ -77,8 +79,8 @@
 		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
 
 #define CAN_BCM_VERSION CAN_VERSION
-static __initdata const char banner[] = KERN_INFO
-	"can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n";
+static __initdata const char banner[] =
+	"can broadcast manager protocol (rev " CAN_BCM_VERSION " t)";
 
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -729,8 +731,8 @@ static void bcm_rx_unreg(struct net_device *dev, struct bcm_op *op)
 		/* mark as removed subscription */
 		op->rx_reg_dev = NULL;
 	} else
-		printk(KERN_ERR "can-bcm: bcm_rx_unreg: registered device "
-		       "mismatch %p %p\n", op->rx_reg_dev, dev);
+		pr_err("%s: registered device mismatch %p %p\n",
+		       __func__, op->rx_reg_dev, dev);
 }
 
 /*
@@ -1606,11 +1608,11 @@ static int __init bcm_module_init(void)
 {
 	int err;
 
-	printk(banner);
+	pr_info("%s\n", banner);
 
 	err = can_proto_register(&bcm_can_proto);
 	if (err < 0) {
-		printk(KERN_ERR "can: registration of bcm protocol failed\n");
+		pr_err("registration of bcm protocol failed\n");
 		return err;
 	}
 
diff --git a/net/can/gw.c b/net/can/gw.c
index 3d79b12..e17253f 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -39,6 +39,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -59,7 +61,7 @@
 
 #define CAN_GW_VERSION "20101209"
 static __initdata const char banner[] =
-	KERN_INFO "can: netlink gateway (rev " CAN_GW_VERSION ")\n";
+	"can netlink gateway (rev " CAN_GW_VERSION ")";
 
 MODULE_DESCRIPTION("PF_CAN netlink gateway");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -913,7 +915,7 @@ static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 
 static __init int cgw_module_init(void)
 {
-	printk(banner);
+	pr_info("%s\n", banner);
 
 	cgw_cache = kmem_cache_create("can_gw", sizeof(struct cgw_job),
 				      0, 0, NULL);
diff --git a/net/can/proc.c b/net/can/proc.c
index ba873c3..c3aedf5 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -39,6 +39,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/proc_fs.h>
 #include <linux/list.h>
@@ -118,8 +120,7 @@ static unsigned long calc_rate(unsigned long oldjif, unsigned long newjif,
 
 	/* see can_stat_update() - this should NEVER happen! */
 	if (count > (ULONG_MAX / HZ)) {
-		printk(KERN_ERR "can: calc_rate: count exceeded! %ld\n",
-		       count);
+		pr_err("%s: count exceeded! %ld\n", __func__, count);
 		return 99999999;
 	}
 
@@ -475,8 +476,7 @@ void can_init_proc(void)
 	can_dir = proc_mkdir("can", init_net.proc_net);
 
 	if (!can_dir) {
-		printk(KERN_INFO "can: failed to create /proc/net/can . "
-		       "CONFIG_PROC_FS missing?\n");
+		pr_info("failed to create /proc/net/can . CONFIG_PROC_FS missing?\n");
 		return;
 	}
 
diff --git a/net/can/raw.c b/net/can/raw.c
index cde1b4a..2875c55 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -39,6 +39,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/uio.h>
@@ -56,7 +58,7 @@
 
 #define CAN_RAW_VERSION CAN_VERSION
 static __initdata const char banner[] =
-	KERN_INFO "can: raw protocol (rev " CAN_RAW_VERSION ")\n";
+	"can raw protocol (rev " CAN_RAW_VERSION ")";
 
 MODULE_DESCRIPTION("PF_CAN raw protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -783,11 +785,11 @@ static __init int raw_module_init(void)
 {
 	int err;
 
-	printk(banner);
+	pr_info("%s\n", banner);
 
 	err = can_proto_register(&raw_can_proto);
 	if (err < 0)
-		printk(KERN_ERR "can: registration of raw protocol failed\n");
+		pr_err("registration of raw protocol failed\n");
 
 	return err;
 }




