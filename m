From: Micha Nelissen <micha@neli.hopto.org>
Subject: [PATCH v4] ipconfig wait for carrier
Date: Thu, 19 May 2011 22:14:06 +0200
Message-ID: <1305836046-21136-1-git-send-email-micha@neli.hopto.org>
References: <1305405386-25187-1-git-send-email-micha@neli.hopto.org>
Cc: Micha Nelissen <micha@neli.hopto.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.172]:50595 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933727Ab1ESUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:15:12 -0400
In-Reply-To: <1305405386-25187-1-git-send-email-micha@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev

Currently the ip auto configuration has a hardcoded delay of 1 second.
When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
nfs root may not be found.

Remove the hardcoded delay, and wait for carrier on at least one network
device.

Signed-off-by: Micha Nelissen <micha@neli.hopto.org>
Cc: David Miller <davem@davemloft.net>
---
 net/ipv4/ipconfig.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 2b09775..d2e0bf4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -87,8 +87,8 @@
 #endif
 
 /* Define the friendly delay before and after opening net devices */
-#define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
-#define CONF_POST_OPEN		1	/* After opening: 1 second */
+#define CONF_POST_OPEN		10	/* After opening: 10 msecs */
+#define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
@@ -188,14 +188,14 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
-static bool __init ic_device_match(struct net_device *dev)
+static bool __init ic_is_init_dev(struct net_device *dev)
 {
-	if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
+	if (dev->flags & IFF_LOOPBACK)
+		return false;
+	return user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
 	    (!(dev->flags & IFF_LOOPBACK) &&
 	     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
-	     strncmp(dev->name, "dummy", 5)))
-		return true;
-	return false;
+	     strncmp(dev->name, "dummy", 5));
 }
 
 static int __init ic_open_devs(void)
@@ -203,6 +203,7 @@ static int __init ic_open_devs(void)
 	struct ic_device *d, **last;
 	struct net_device *dev;
 	unsigned short oflags;
+	unsigned long start;
 
 	last = &ic_first_dev;
 	rtnl_lock();
@@ -216,9 +217,7 @@ static int __init ic_open_devs(void)
 	}
 
 	for_each_netdev(&init_net, dev) {
-		if (dev->flags & IFF_LOOPBACK)
-			continue;
-		if (ic_device_match(dev)) {
+		if (ic_is_init_dev(dev)) {
 			int able = 0;
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
@@ -252,6 +251,17 @@ static int __init ic_open_devs(void)
 				dev->name, able, d->xid));
 		}
 	}
+
+	/* wait for a carrier on at least one device */
+	start = jiffies;
+	while (jiffies - start < msecs_to_jiffies(CONF_CARRIER_TIMEOUT)) {
+		for_each_netdev(&init_net, dev)
+			if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
+				goto have_carrier;
+
+		msleep(1);
+	}
+have_carrier:
 	rtnl_unlock();
 
 	*last = NULL;
@@ -1324,14 +1334,13 @@ static int __init wait_for_devices(void)
 {
 	int i;
 
-	msleep(CONF_PRE_OPEN);
 	for (i = 0; i < DEVICE_WAIT_MAX; i++) {
 		struct net_device *dev;
 		int found = 0;
 
 		rtnl_lock();
 		for_each_netdev(&init_net, dev) {
-			if (ic_device_match(dev)) {
+			if (ic_is_init_dev(dev)) {
 				found = 1;
 				break;
 			}
@@ -1378,7 +1387,7 @@ static int __init ip_auto_config(void)
 		return err;
 
 	/* Give drivers a chance to settle */
-	ssleep(CONF_POST_OPEN);
+	msleep(CONF_POST_OPEN);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
-- 
1.7.4.4

