From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [WEXT 8/12]: Pull top-level ioctl dispatch logic into helper
 function.
Date: Fri, 21 Dec 2007 20:56:23 -0800 (PST)
Message-ID: <20071221.205623.141035851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


[WEXT]: Pull top-level ioctl dispatch logic into helper function.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 18fa13c..03b0051 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1111,8 +1111,10 @@ static int wext_permission_check(unsigned int cmd)
 }
 
 /* entry point from dev ioctl */
-int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
-		      void __user *arg)
+static int wext_ioctl_dispatch(struct net *net, struct ifreq *ifr,
+			       unsigned int cmd,
+			       wext_ioctl_func standard,
+			       wext_ioctl_func private)
 {
 	int ret = wext_permission_check(cmd);
 
@@ -1121,12 +1123,24 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 
 	dev_load(net, ifr->ifr_name);
 	rtnl_lock();
-	ret = wireless_process_ioctl(net, ifr, cmd,
-				     ioctl_standard_call,
-				     ioctl_private_call);
+	ret = wireless_process_ioctl(net, ifr, cmd, standard, private);
 	rtnl_unlock();
-	if (IW_IS_GET(cmd) && copy_to_user(arg, ifr, sizeof(struct iwreq)))
+
+	return ret;
+}
+
+int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+		      void __user *arg)
+{
+	int ret = wext_ioctl_dispatch(net, ifr, cmd,
+				      ioctl_standard_call,
+				      ioctl_private_call);
+
+	if (ret > 0 &&
+	    IW_IS_GET(cmd) &&
+	    copy_to_user(arg, ifr, sizeof(struct iwreq)))
 		return -EFAULT;
+
 	return ret;
 }
 
-- 
1.5.4.rc1
