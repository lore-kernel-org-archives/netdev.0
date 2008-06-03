From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 8/12]: wext: Pull top-level ioctl dispatch logic into
 helper function.
Date: Tue, 03 Jun 2008 13:28:38 -0700 (PDT)
Message-ID: <20080603.132838.114305874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index b72cdd2..91cf548 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1079,8 +1079,10 @@ static int wext_permission_check(unsigned int cmd)
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
 
@@ -1089,12 +1091,24 @@ int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 
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
+	if (ret >= 0 &&
+	    IW_IS_GET(cmd) &&
+	    copy_to_user(arg, ifr, sizeof(struct iwreq)))
 		return -EFAULT;
+
 	return ret;
 }
 
-- 
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
