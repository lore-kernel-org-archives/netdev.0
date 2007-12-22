From: David Miller <davem@davemloft.net>
Subject: [WEXT 11/12]: Create IW_REQUEST_FLAG_COMPAT and set it as needed.
Date: Fri, 21 Dec 2007 20:57:40 -0800 (PST)
Message-ID: <20071221.205740.156308612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754226AbXLVE5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 23:57:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[WEXT]: Create IW_REQUEST_FLAG_COMPAT and set it as needed.

Now low-level WEXT ioctl handlers can do compat handling
when necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/iw_handler.h |    2 +-
 net/wireless/wext.c      |   73 +++++++++++++++++++++-------------------------
 2 files changed, 34 insertions(+), 41 deletions(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index 369d50e..c99a8ee 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -256,7 +256,7 @@
 #define EIWCOMMIT	EINPROGRESS
 
 /* Flags available in struct iw_request_info */
-#define IW_REQUEST_FLAG_NONE	0x0000	/* No flag so far */
+#define IW_REQUEST_FLAG_COMPAT	0x0001	/* Compat ioctl call */
 
 /* Type of headers we know about (basically union iwreq_data) */
 #define IW_HEADER_TYPE_NULL	0	/* Not available */
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 5869b70..b7f5973 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -866,10 +866,10 @@ out:
 static int ioctl_standard_call(struct net_device *	dev,
 			       struct iwreq *		iwr,
 			       unsigned int		cmd,
+			       struct iw_request_info	*info,
 			       iw_handler		handler)
 {
 	const struct iw_ioctl_description *	descr;
-	struct iw_request_info			info;
 	int					ret = -EINVAL;
 
 	/* Get the description of the IOCTL */
@@ -877,15 +877,11 @@ static int ioctl_standard_call(struct net_device *	dev,
 		return -EOPNOTSUPP;
 	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
 
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
 	/* Check if we have a pointer to user space data or not */
 	if (descr->header_type != IW_HEADER_TYPE_POINT) {
 
 		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, &(iwr->u), NULL);
+		ret = handler(dev, info, &(iwr->u), NULL);
 
 		/* Generate an event to notify listeners of the change */
 		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
@@ -893,7 +889,7 @@ static int ioctl_standard_call(struct net_device *	dev,
 			wireless_send_event(dev, cmd, &(iwr->u), NULL);
 	} else {
 		ret = ioctl_standard_iw_point(&iwr->u.data, cmd, descr,
-					      handler, dev, &info);
+					      handler, dev, info);
 	}
 
 	/* Call commit handler if needed and defined */
@@ -1016,25 +1012,21 @@ out:
 }
 
 static int ioctl_private_call(struct net_device *dev, struct iwreq *iwr,
-			      unsigned int cmd, iw_handler handler)
+			      unsigned int cmd, struct iw_request_info *info,
+			      iw_handler handler)
 {
 	int extra_size = 0, ret = -EINVAL;
 	const struct iw_priv_args *descr;
-	struct iw_request_info info;
 
 	extra_size = get_priv_descr_and_size(dev, cmd, &descr);
 
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
 	/* Check if we have a pointer to user space data or not. */
 	if (extra_size == 0) {
 		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
+		ret = handler(dev, info, &(iwr->u), (char *) &(iwr->u));
 	} else {
 		ret = ioctl_private_iw_point(&iwr->u.data, cmd, descr,
-					     handler, dev, &info, extra_size);
+					     handler, dev, info, extra_size);
 	}
 
 	/* Call commit handler if needed and defined */
@@ -1046,7 +1038,8 @@ static int ioctl_private_call(struct net_device *dev, struct iwreq *iwr,
 
 /* ---------------------------------------------------------------- */
 typedef int (*wext_ioctl_func)(struct net_device *, struct iwreq *,
-			       unsigned int, iw_handler);
+			       unsigned int, struct iw_request_info *,
+			       iw_handler);
 
 /*
  * Main IOCTl dispatcher.
@@ -1054,6 +1047,7 @@ typedef int (*wext_ioctl_func)(struct net_device *, struct iwreq *,
  */
 static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 				  unsigned int cmd,
+				  struct iw_request_info *info,
 				  wext_ioctl_func standard,
 				  wext_ioctl_func private)
 {
@@ -1072,11 +1066,11 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 	 * Note that 'cmd' is already filtered in dev_ioctl() with
 	 * (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) */
 	if (cmd == SIOCGIWSTATS)
-		return standard(dev, iwr, cmd,
+		return standard(dev, iwr, cmd, info,
 				&iw_handler_get_iwstats);
 
 	if (cmd == SIOCGIWPRIV && dev->wireless_handlers)
-		return standard(dev, iwr, cmd,
+		return standard(dev, iwr, cmd, info,
 				&iw_handler_get_private);
 
 	/* Basic check */
@@ -1088,9 +1082,9 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 	if (handler) {
 		/* Standard and private are not the same */
 		if (cmd < SIOCIWFIRSTPRIV)
-			return standard(dev, iwr, cmd, handler);
+			return standard(dev, iwr, cmd, info, handler);
 		else
-			return private(dev, iwr, cmd, handler);
+			return private(dev, iwr, cmd, info, handler);
 	}
 	/* Old driver API : call driver ioctl handler */
 	if (dev->do_ioctl)
@@ -1112,7 +1106,7 @@ static int wext_permission_check(unsigned int cmd)
 
 /* entry point from dev ioctl */
 static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
-			       unsigned int cmd,
+			       unsigned int cmd, struct iw_request_info *info,
 			       wext_ioctl_func standard,
 			       wext_ioctl_func private)
 {
@@ -1123,7 +1117,7 @@ static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
 
 	dev_load(net, ifr->ifr_name);
 	rtnl_lock();
-	ret = wireless_process_ioctl(net, ifr, cmd, standard, private);
+	ret = wireless_process_ioctl(net, ifr, cmd, info, standard, private);
 	rtnl_unlock();
 
 	return ret;
@@ -1132,10 +1126,12 @@ static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
 int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 		      void __user *arg)
 {
-	int ret = wext_ioctl_dispatch(net, ifr, cmd,
-				      ioctl_standard_call,
-				      ioctl_private_call);
+	struct iw_request_info info = { .cmd = cmd, .flags = 0 };
+	int ret;
 
+	ret = wext_ioctl_dispatch(net, ifr, cmd, &info,
+				  ioctl_standard_call,
+				  ioctl_private_call);
 	if (ret > 0 &&
 	    IW_IS_GET(cmd) &&
 	    copy_to_user(arg, ifr, sizeof(struct iwreq)))
@@ -1148,28 +1144,25 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 static int compat_standard_call(struct net_device *	dev,
 				struct iwreq *		iwr,
 				unsigned int		cmd,
+				struct iw_request_info	*info,
 				iw_handler		handler)
 {
 	const struct iw_ioctl_description *descr;
 	struct compat_iw_point *iwp_compat;
-	struct iw_request_info info;
 	struct iw_point iwp;
 	int err;
 
 	descr = standard_ioctl + (cmd - SIOCIWFIRST);
 
 	if (descr->header_type != IW_HEADER_TYPE_POINT)
-		return ioctl_standard_call(dev, iwr, cmd, handler);
+		return ioctl_standard_call(dev, iwr, cmd, info, handler);
 
 	iwp_compat = (struct compat_iw_point *) &iwr->u.data;
 	iwp.pointer = compat_ptr(iwp_compat->pointer);
 	iwp.length = iwp_compat->length;
 	iwp.flags = iwp_compat->flags;
 
-	info.cmd = cmd;
-	info.flags = 0;
-
-	err = ioctl_standard_iw_point(&iwp, cmd, descr, handler, dev, &info);
+	err = ioctl_standard_iw_point(&iwp, cmd, descr, handler, dev, info);
 
 	iwp_compat->pointer = ptr_to_compat(iwp.pointer);
 	iwp_compat->length = iwp.length;
@@ -1179,22 +1172,18 @@ static int compat_standard_call(struct net_device *	dev,
 }
 
 static int compat_private_call(struct net_device *dev, struct iwreq *iwr,
-			       unsigned int cmd, iw_handler handler)
+			       unsigned int cmd, struct iw_request_info *info,
+			       iw_handler handler)
 {
 	const struct iw_priv_args *descr;
-	struct iw_request_info info;
 	int ret, extra_size;
 
 	extra_size = get_priv_descr_and_size(dev, cmd, &descr);
 
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
 	/* Check if we have a pointer to user space data or not. */
 	if (extra_size == 0) {
 		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
+		ret = handler(dev, info, &(iwr->u), (char *) &(iwr->u));
 	} else {
 		struct compat_iw_point *iwp_compat;
 		struct iw_point iwp;
@@ -1205,7 +1194,7 @@ static int compat_private_call(struct net_device *dev, struct iwreq *iwr,
 		iwp.flags = iwp_compat->flags;
 
 		ret = ioctl_private_iw_point(&iwp, cmd, descr,
-					     handler, dev, &info, extra_size);
+					     handler, dev, info, extra_size);
 
 		iwp_compat->pointer = ptr_to_compat(iwp.pointer);
 		iwp_compat->length = iwp.length;
@@ -1223,6 +1212,7 @@ int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 			     unsigned long arg)
 {
 	void __user *argp = (void __user *)arg;
+	struct iw_request_info info;
 	struct iwreq iwr;
 	char *colon;
 	int ret;
@@ -1235,7 +1225,10 @@ int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 	if (colon)
 		*colon = 0;
 
-	ret = wext_ioctl_dispatch(net, (struct ifreq *) &iwr, cmd,
+	info.cmd = cmd;
+	info.flags = IW_REQUEST_FLAG_COMPAT;
+
+	ret = wext_ioctl_dispatch(net, (struct ifreq *) &iwr, cmd, &info,
 				  compat_standard_call,
 				  compat_private_call);
 
-- 
1.5.4.rc1

