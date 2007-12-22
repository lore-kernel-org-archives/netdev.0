From: David Miller <davem@davemloft.net>
Subject: [WEXT 6/12]: Parameterize the standard/private handlers.
Date: Fri, 21 Dec 2007 20:55:28 -0800 (PST)
Message-ID: <20071221.205528.53416957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbXLVEz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 23:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[WEXT]: Parameterize the standard/private handlers.

The WEXT standard and private handlers to use are now
arguments to wireless_process_ioctl().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/wireless/wext.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index f183c1d..ad982c0 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1047,11 +1047,17 @@ static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
 }
 
 /* ---------------------------------------------------------------- */
+typedef int (*wext_ioctl_func)(struct net_device *, struct ifreq *,
+			       unsigned int, iw_handler);
+
 /*
  * Main IOCTl dispatcher.
  * Check the type of IOCTL and call the appropriate wrapper...
  */
-static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd)
+static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
+				  unsigned int cmd,
+				  wext_ioctl_func standard,
+				  wext_ioctl_func private)
 {
 	struct net_device *dev;
 	iw_handler	handler;
@@ -1067,12 +1073,12 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
 	 * Note that 'cmd' is already filtered in dev_ioctl() with
 	 * (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) */
 	if (cmd == SIOCGIWSTATS)
-		return ioctl_standard_call(dev, ifr, cmd,
-					   &iw_handler_get_iwstats);
+		return standard(dev, ifr, cmd,
+				&iw_handler_get_iwstats);
 
 	if (cmd == SIOCGIWPRIV && dev->wireless_handlers)
-		return ioctl_standard_call(dev, ifr, cmd,
-					   &iw_handler_get_private);
+		return standard(dev, ifr, cmd,
+				&iw_handler_get_private);
 
 	/* Basic check */
 	if (!netif_device_present(dev))
@@ -1083,9 +1089,9 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
 	if (handler) {
 		/* Standard and private are not the same */
 		if (cmd < SIOCIWFIRSTPRIV)
-			return ioctl_standard_call(dev, ifr, cmd, handler);
+			return standard(dev, ifr, cmd, handler);
 		else
-			return ioctl_private_call(dev, ifr, cmd, handler);
+			return private(dev, ifr, cmd, handler);
 	}
 	/* Old driver API : call driver ioctl handler */
 	if (dev->do_ioctl)
@@ -1116,7 +1122,9 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 
 	dev_load(net, ifr->ifr_name);
 	rtnl_lock();
-	ret = wireless_process_ioctl(net, ifr, cmd);
+	ret = wireless_process_ioctl(net, ifr, cmd,
+				     ioctl_standard_call,
+				     ioctl_private_call);
 	rtnl_unlock();
 	if (IW_IS_GET(cmd) && copy_to_user(arg, ifr, sizeof(struct iwreq)))
 		return -EFAULT;
-- 
1.5.4.rc1

