From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 7/12]: wext: Pass iwreq pointer down into standard/private
 handlers.
Date: Tue, 17 Jun 2008 00:54:09 -0700 (PDT)
Message-ID: <20080617.005409.37355710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


wext: Pass iwreq pointer down into standard/private handlers.

They have no need to see the object as an ifreq.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 929d241..e9c8817 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -832,11 +832,10 @@ out:
  * user space and kernel space.
  */
 static int ioctl_standard_call(struct net_device *	dev,
-			       struct ifreq *		ifr,
+			       struct iwreq		*iwr,
 			       unsigned int		cmd,
 			       iw_handler		handler)
 {
-	struct iwreq *				iwr = (struct iwreq *) ifr;
 	const struct iw_ioctl_description *	descr;
 	struct iw_request_info			info;
 	int					ret = -EINVAL;
@@ -984,10 +983,9 @@ out:
 	return err;
 }
 
-static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
+static int ioctl_private_call(struct net_device *dev, struct iwreq *iwr,
 			      unsigned int cmd, iw_handler handler)
 {
-	struct iwreq *iwr = (struct iwreq *) ifr;
 	int extra_size = 0, ret = -EINVAL;
 	const struct iw_priv_args *descr;
 	struct iw_request_info info;
@@ -1015,7 +1013,7 @@ static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
 }
 
 /* ---------------------------------------------------------------- */
-typedef int (*wext_ioctl_func)(struct net_device *, struct ifreq *,
+typedef int (*wext_ioctl_func)(struct net_device *, struct iwreq *,
 			       unsigned int, iw_handler);
 
 /*
@@ -1027,6 +1025,7 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 				  wext_ioctl_func standard,
 				  wext_ioctl_func private)
 {
+	struct iwreq *iwr = (struct iwreq *) ifr;
 	struct net_device *dev;
 	iw_handler	handler;
 
@@ -1041,11 +1040,11 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 	 * Note that 'cmd' is already filtered in dev_ioctl() with
 	 * (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) */
 	if (cmd == SIOCGIWSTATS)
-		return standard(dev, ifr, cmd,
+		return standard(dev, iwr, cmd,
 				&iw_handler_get_iwstats);
 
 	if (cmd == SIOCGIWPRIV && dev->wireless_handlers)
-		return standard(dev, ifr, cmd,
+		return standard(dev, iwr, cmd,
 				&iw_handler_get_private);
 
 	/* Basic check */
@@ -1057,9 +1056,9 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 	if (handler) {
 		/* Standard and private are not the same */
 		if (cmd < SIOCIWFIRSTPRIV)
-			return standard(dev, ifr, cmd, handler);
+			return standard(dev, iwr, cmd, handler);
 		else
-			return private(dev, ifr, cmd, handler);
+			return private(dev, iwr, cmd, handler);
 	}
 	/* Old driver API : call driver ioctl handler */
 	if (dev->do_ioctl)
-- 
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
