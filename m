From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/3] dev_ioctl: copy only the smaller struct iwreq for wext
Date: Wed, 14 Jun 2017 13:55:23 +0200
Message-ID: <20170614115523.16379-4-johannes@sipsolutions.net>
References: <20170614115523.16379-1-johannes@sipsolutions.net>
Cc: Robert O'Callahan <robert@ocallahan.org>,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37332 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752167AbdFNLzj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:55:39 -0400
In-Reply-To: <20170614115523.16379-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Unfortunately, struct iwreq isn't a proper subset of struct ifreq,
but is still handled by the same code path. Robert reported that
then applications may (randomly) fault if the struct iwreq they
pass happens to land within 8 bytes of the end of a mapping (the
struct is only 32 bytes, vs. struct ifreq's 40 bytes).

To fix this, pull out the code handling wireless extension ioctls
and copy only the smaller structure in this case.

This bug goes back a long time, I tracked that it was introduced
into mainline in 2.1.15, over 20 years ago!

This fixes https://bugzilla.kernel.org/show_bug.cgi?id=195869

Reported-by: Robert O'Callahan <robert@ocallahan.org>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/wext.h       |  4 ++--
 net/core/dev_ioctl.c     | 19 ++++++++++++++++---
 net/wireless/wext-core.c |  6 +++---
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/net/wext.h b/include/net/wext.h
index 345911965dbb..454ff763eeba 100644
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -6,7 +6,7 @@
 struct net;
 
 #ifdef CONFIG_WEXT_CORE
-int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+int wext_handle_ioctl(struct net *net, struct iwreq *iwr, unsigned int cmd,
 		      void __user *arg);
 int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 			     unsigned long arg);
@@ -14,7 +14,7 @@ int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
 struct iw_statistics *get_wireless_stats(struct net_device *dev);
 int call_commit_handler(struct net_device *dev);
 #else
-static inline int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+static inline int wext_handle_ioctl(struct net *net, struct iwreq *iwr, unsigned int cmd,
 				    void __user *arg)
 {
 	return -EINVAL;
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index b94b1d293506..27fad31784a8 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -410,6 +410,22 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	if (cmd == SIOCGIFNAME)
 		return dev_ifname(net, (struct ifreq __user *)arg);
 
+	/*
+	 * Take care of Wireless Extensions. Unfortunately struct iwreq
+	 * isn't a proper subset of struct ifreq (it's 8 byte shorter)
+	 * so we need to treat it specially, otherwise applications may
+	 * fault if the struct they're passing happens to land at the
+	 * end of a mapped page.
+	 */
+	if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) {
+		struct iwreq iwr;
+
+		if (copy_from_user(&iwr, arg, sizeof(iwr)))
+			return -EFAULT;
+
+		return wext_handle_ioctl(net, &iwr, cmd, arg);
+	}
+
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
 
@@ -559,9 +575,6 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 				ret = -EFAULT;
 			return ret;
 		}
-		/* Take care of Wireless Extensions */
-		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
-			return wext_handle_ioctl(net, &ifr, cmd, arg);
 		return -ENOTTY;
 	}
 }
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 12949c8d3e5f..6cdb054484d6 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -1035,18 +1035,18 @@ static int ioctl_standard_call(struct net_device *	dev,
 }
 
 
-int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+int wext_handle_ioctl(struct net *net, struct iwreq *iwr, unsigned int cmd,
 		      void __user *arg)
 {
 	struct iw_request_info info = { .cmd = cmd, .flags = 0 };
 	int ret;
 
-	ret = wext_ioctl_dispatch(net, (void *)ifr, cmd, &info,
+	ret = wext_ioctl_dispatch(net, iwr, cmd, &info,
 				  ioctl_standard_call,
 				  ioctl_private_call);
 	if (ret >= 0 &&
 	    IW_IS_GET(cmd) &&
-	    copy_to_user(arg, ifr, sizeof(struct iwreq)))
+	    copy_to_user(arg, iwr, sizeof(struct iwreq)))
 		return -EFAULT;
 
 	return ret;
-- 
2.11.0
