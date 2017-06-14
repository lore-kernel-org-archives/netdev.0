From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/3] wireless: wext: use struct iwreq earlier in the call chain
Date: Wed, 14 Jun 2017 13:55:22 +0200
Message-ID: <20170614115523.16379-3-johannes@sipsolutions.net>
References: <20170614115523.16379-1-johannes@sipsolutions.net>
Cc: Robert O'Callahan <robert@ocallahan.org>,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37328 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751608AbdFNLz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:55:57 -0400
In-Reply-To: <20170614115523.16379-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

To make it clear that we never use struct ifreq, cast from it
directly in the wext entrypoint and use struct iwreq from there
on. The next patch will remove the cast again and pass the
correct struct from the beginning.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wireless/wext-core.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 24ba8a99b946..12949c8d3e5f 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -914,13 +914,12 @@ int call_commit_handler(struct net_device *dev)
  * Main IOCTl dispatcher.
  * Check the type of IOCTL and call the appropriate wrapper...
  */
-static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
+static int wireless_process_ioctl(struct net *net, struct iwreq *iwr,
 				  unsigned int cmd,
 				  struct iw_request_info *info,
 				  wext_ioctl_func standard,
 				  wext_ioctl_func private)
 {
-	struct iwreq *iwr = (struct iwreq *) ifr;
 	struct net_device *dev;
 	iw_handler	handler;
 
@@ -928,7 +927,7 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 	 * The copy_to/from_user() of ifr is also dealt with in there */
 
 	/* Make sure the device exist */
-	if ((dev = __dev_get_by_name(net, ifr->ifr_name)) == NULL)
+	if ((dev = __dev_get_by_name(net, iwr->ifr_name)) == NULL)
 		return -ENODEV;
 
 	/* A bunch of special cases, then the generic case...
@@ -974,7 +973,7 @@ static int wext_permission_check(unsigned int cmd)
 }
 
 /* entry point from dev ioctl */
-static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
+static int wext_ioctl_dispatch(struct net *net, struct iwreq *iwr,
 			       unsigned int cmd, struct iw_request_info *info,
 			       wext_ioctl_func standard,
 			       wext_ioctl_func private)
@@ -984,9 +983,9 @@ static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
 	if (ret)
 		return ret;
 
-	dev_load(net, ifr->ifr_name);
+	dev_load(net, iwr->ifr_name);
 	rtnl_lock();
-	ret = wireless_process_ioctl(net, ifr, cmd, info, standard, private);
+	ret = wireless_process_ioctl(net, iwr, cmd, info, standard, private);
 	rtnl_unlock();
 
 	return ret;
@@ -1042,7 +1041,7 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 	struct iw_request_info info = { .cmd = cmd, .flags = 0 };
 	int ret;
 
-	ret = wext_ioctl_dispatch(net, ifr, cmd, &info,
+	ret = wext_ioctl_dispatch(net, (void *)ifr, cmd, &info,
 				  ioctl_standard_call,
 				  ioctl_private_call);
 	if (ret >= 0 &&
@@ -1104,7 +1103,7 @@ int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 	info.cmd = cmd;
 	info.flags = IW_REQUEST_FLAG_COMPAT;
 
-	ret = wext_ioctl_dispatch(net, (struct ifreq *) &iwr, cmd, &info,
+	ret = wext_ioctl_dispatch(net, &iwr, cmd, &info,
 				  compat_standard_call,
 				  compat_private_call);
 
-- 
2.11.0
