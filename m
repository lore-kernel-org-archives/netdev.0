From: Micha Nelissen <micha@neli.hopto.org>
Subject: (unknown)
Date: Sat, 14 May 2011 22:20:48 +0200
Message-ID: <1305404448-24068-1-git-send-email-micha@neli.hopto.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-01.edutel.nl ([88.159.1.175]:46667 "EHLO
	edu-smtp-01.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab1ENUbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 16:31:09 -0400
Received: from neli.hopto.org (50-231.ftth.onsbrabantnet.nl [88.159.231.50])
	by edu-smtp-01.edutel.nl (Postfix) with ESMTPSA id 743283841D
	for <netdev@vger.kernel.org>; Sat, 14 May 2011 22:21:09 +0200 (CEST)
Received: from conroe.local
	([90.0.0.126] helo=localhost.localdomain ident=micha)
	by neli.hopto.org with esmtp (Exim 4.69)
	(envelope-from <micha@neli.hopto.org>)
	id 1QLLKn-0004XA-SM
	for netdev@vger.kernel.org; Sat, 14 May 2011 22:21:09 +0200
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 /* Define the friendly delay before and after opening net devices */
-#define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
-#define CONF_POST_OPEN		1	/* After opening: 1 second */
+#define CONF_POST_OPEN		10	/* After opening: 10 msecs */
+#define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
@@ -187,11 +187,22 @@
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
+static int __init ic_is_init_dev(struct net_device *dev)
+{
+	if (dev->flags & IFF_LOOPBACK)
+		return 0;
+	return user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
+	    (!(dev->flags & IFF_LOOPBACK) &&
+	     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
+	     strncmp(dev->name, "dummy", 5));
+}
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
 	struct net_device *dev;
 	unsigned short oflags;
+	unsigned long start;
 
 	last = &ic_first_dev;
 	rtnl_lock();
@@ -205,12 +216,7 @@
 	}
 
 	for_each_netdev(&init_net, dev) {
-		if (dev->flags & IFF_LOOPBACK)
-			continue;
-		if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
-		    (!(dev->flags & IFF_LOOPBACK) &&
-		     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
-		     strncmp(dev->name, "dummy", 5))) {
+		if (ic_is_init_dev(dev)) {
 			int able = 0;
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
@@ -244,6 +250,17 @@
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
@@ -1325,15 +1342,12 @@
 #ifdef IPCONFIG_DYNAMIC
  try_try_again:
 #endif
-	/* Give hardware a chance to settle */
-	msleep(CONF_PRE_OPEN);
-
 	/* Setup all network devices */
 	if (ic_open_devs() < 0)
 		return -1;
 
 	/* Give drivers a chance to settle */
-	ssleep(CONF_POST_OPEN);
+	msleep(CONF_POST_OPEN);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
