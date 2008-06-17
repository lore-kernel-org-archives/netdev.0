From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 6/12]: wext: Parameterize the standard/private handlers.
Date: Tue, 17 Jun 2008 00:53:56 -0700 (PDT)
Message-ID: <20080617.005356.50875125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


wext: Parameterize the standard/private handlers.

The WEXT standard and private handlers to use are now
arguments to wireless_process_ioctl().

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index e96559e..929d241 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1015,11 +1015,17 @@ static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
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
@@ -1035,12 +1041,12 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
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
@@ -1051,9 +1057,9 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
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
@@ -1084,7 +1090,9 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 
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
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
