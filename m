From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 5/9] wext: cleanup early ioctl call path
Date: Tue, 24 Apr 2007 20:07:37 +0200
Message-ID: <20070424180848.814070000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=wext-cleanup.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the code in wireless_process_ioctl somewhat more readable.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 net/wireless/wext.c |   73 ++++++++++++++++++----------------------------------
 1 file changed, 26 insertions(+), 47 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 19:05:57.648804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 19:10:51.038804911 +0200
@@ -1035,53 +1035,31 @@ static int wireless_process_ioctl(struct
 	/* A bunch of special cases, then the generic case...
 	 * Note that 'cmd' is already filtered in dev_ioctl() with
 	 * (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) */
-	switch (cmd) {
-	case SIOCGIWSTATS:
-		/* Get Wireless Stats */
-		return ioctl_standard_call(dev,
-					   ifr,
-					   cmd,
+	if (cmd == SIOCGIWSTATS)
+		return ioctl_standard_call(dev, ifr, cmd,
 					   &iw_handler_get_iwstats);
 
-	case SIOCGIWPRIV:
-		/* Check if we have some wireless handlers defined */
-		if (dev->wireless_handlers != NULL) {
-			/* We export to user space the definition of
-			 * the private handler ourselves */
-			return ioctl_standard_call(dev,
-						   ifr,
-						   cmd,
-						   &iw_handler_get_private);
-		}
-		// ## Fall-through for old API ##
-	default:
-		/* Generic IOCTL */
-		/* Basic check */
-		if (!netif_device_present(dev))
-			return -ENODEV;
-		/* New driver API : try to find the handler */
-		handler = get_handler(dev, cmd);
-		if (handler != NULL) {
-			/* Standard and private are not the same */
-			if (cmd < SIOCIWFIRSTPRIV)
-				return ioctl_standard_call(dev,
-							   ifr,
-							   cmd,
-							   handler);
-			else
-				return ioctl_private_call(dev,
-							  ifr,
-							  cmd,
-							  handler);
-		}
-		/* Old driver API : call driver ioctl handler */
-		if (dev->do_ioctl) {
-			return dev->do_ioctl(dev, ifr, cmd);
-		}
-		return -EOPNOTSUPP;
+	if (cmd == SIOCGIWPRIV && dev->wireless_handlers)
+		return ioctl_standard_call(dev, ifr, cmd,
+					   &iw_handler_get_private);
+
+	/* Basic check */
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	/* New driver API : try to find the handler */
+	handler = get_handler(dev, cmd);
+	if (handler) {
+		/* Standard and private are not the same */
+		if (cmd < SIOCIWFIRSTPRIV)
+			return ioctl_standard_call(dev, ifr, cmd, handler);
+		else
+			return ioctl_private_call(dev, ifr, cmd, handler);
 	}
-	/* Not reached */
-	return -EINVAL;
+	/* Old driver API : call driver ioctl handler */
+	if (dev->do_ioctl)
+		return dev->do_ioctl(dev, ifr, cmd);
+	return -EOPNOTSUPP;
 }
 
 /* entry point from dev ioctl */
@@ -1093,9 +1071,10 @@ int wext_handle_ioctl(struct ifreq *ifr,
 	/* If command is `set a parameter', or
 	 * `get the encoding parameters', check if
 	 * the user has the right to do it */
-	if (IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
+	if ((IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
+	    && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	dev_load(ifr->ifr_name);
 	rtnl_lock();
 	ret = wireless_process_ioctl(ifr, cmd);

--
