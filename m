From: David Miller <davem@davemloft.net>
Subject: Re: problem with kernel ipconfig over usb ethernet on v.2.6.33-rc3
Date: Wed, 10 Mar 2010 14:33:23 -0800 (PST)
Message-ID: <20100310.143323.248163124.davem@davemloft.net>
References: <cabda6421001100027u1ca339a6ka46470431caa21ba@mail.gmail.com>
	<20100110.133848.200626367.davem@davemloft.net>
	<cabda6421001102318m972e0bdw3f44962b5307d4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chripell@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757373Ab0CJWdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 17:33:07 -0500
In-Reply-To: <cabda6421001102318m972e0bdw3f44962b5307d4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: christian pellegrin <chripell@gmail.com>
Date: Mon, 11 Jan 2010 08:18:13 +0100

> I can try more elaborate schemes like: if the ethX specified by ip=
> is not present at the first try just wait 10 seconds and try again
> (perhaps repeat this two time just to be sure).

Please let me know if this patch makes your setup work
properly.

It loops one second at a time, for up to 12 seconds, waiting
for a usable non-loopback device to appear.

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 10a6a60..6789092 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -187,6 +187,16 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
+static bool __init ic_device_match(struct net_device *dev)
+{
+	if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
+	    (!(dev->flags & IFF_LOOPBACK) &&
+	     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
+	     strncmp(dev->name, "dummy", 5)))
+		return true;
+	return false;
+}
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
@@ -207,10 +217,7 @@ static int __init ic_open_devs(void)
 	for_each_netdev(&init_net, dev) {
 		if (dev->flags & IFF_LOOPBACK)
 			continue;
-		if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
-		    (!(dev->flags & IFF_LOOPBACK) &&
-		     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
-		     strncmp(dev->name, "dummy", 5))) {
+		if (ic_device_match(dev)) {
 			int able = 0;
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
@@ -228,7 +235,7 @@ static int __init ic_open_devs(void)
 			}
 			if (!(d = kmalloc(sizeof(struct ic_device), GFP_KERNEL))) {
 				rtnl_unlock();
-				return -1;
+				return -ENOMEM;
 			}
 			d->dev = dev;
 			*last = d;
@@ -253,7 +260,7 @@ static int __init ic_open_devs(void)
 			printk(KERN_ERR "IP-Config: Device `%s' not found.\n", user_dev_name);
 		else
 			printk(KERN_ERR "IP-Config: No network devices available.\n");
-		return -1;
+		return -ENODEV;
 	}
 	return 0;
 }
@@ -1303,6 +1310,32 @@ __be32 __init root_nfs_parse_addr(char *name)
 	return addr;
 }
 
+#define DEVICE_WAIT_MAX		12 /* 12 seconds */
+
+static int __init wait_for_devices(void)
+{
+	int i;
+
+	msleep(CONF_PRE_OPEN);
+	for (i = 0; i < DEVICE_WAIT_MAX; i++) {
+		struct net_device *dev;
+		int found = 0;
+
+		rtnl_lock();
+		for_each_netdev(&init_net, dev) {
+			if (ic_device_match(dev)) {
+				found = 1;
+				break;
+			}
+		}
+		rtnl_unlock();
+		if (found)
+			return 0;
+		ssleep(1);
+	}
+	return -ENODEV;
+}
+
 /*
  *	IP Autoconfig dispatcher.
  */
@@ -1313,6 +1346,7 @@ static int __init ip_auto_config(void)
 #ifdef IPCONFIG_DYNAMIC
 	int retries = CONF_OPEN_RETRIES;
 #endif
+	int err;
 
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create(&init_net, "pnp", S_IRUGO, &pnp_seq_fops);
@@ -1325,12 +1359,15 @@ static int __init ip_auto_config(void)
 #ifdef IPCONFIG_DYNAMIC
  try_try_again:
 #endif
-	/* Give hardware a chance to settle */
-	msleep(CONF_PRE_OPEN);
+	/* Wait for devices to appear */
+	err = wait_for_devices();
+	if (err)
+		return err;
 
 	/* Setup all network devices */
-	if (ic_open_devs() < 0)
-		return -1;
+	err = ic_open_devs();
+	if (err)
+		return err;
 
 	/* Give drivers a chance to settle */
 	ssleep(CONF_POST_OPEN);
