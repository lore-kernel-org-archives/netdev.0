From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [WEXT 5/12]: Pull ioctl permission checking out into helper
 function.
Date: Fri, 21 Dec 2007 20:54:56 -0800 (PST)
Message-ID: <20071221.205456.259648428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


[WEXT]: Pull ioctl permission checking out into helper function.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 9c3d83f..f183c1d 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1093,18 +1093,26 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
 	return -EOPNOTSUPP;
 }
 
+/* If command is `set a parameter', or `get the encoding parameters',
+ * check if the user has the right to do it.
+ */
+static int wext_permission_check(unsigned int cmd)
+{
+	if ((IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
+	    && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return 0;
+}
+
 /* entry point from dev ioctl */
 int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
 		      void __user *arg)
 {
-	int ret;
+	int ret = wext_permission_check(cmd);
 
-	/* If command is `set a parameter', or
-	 * `get the encoding parameters', check if
-	 * the user has the right to do it */
-	if ((IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
-	    && !capable(CAP_NET_ADMIN))
-		return -EPERM;
+	if (ret)
+		return ret;
 
 	dev_load(net, ifr->ifr_name);
 	rtnl_lock();
-- 
1.5.4.rc1
