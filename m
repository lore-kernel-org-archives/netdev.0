From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 5/12]: wext: Pull ioctl permission checking out into helper
 function.
Date: Tue, 03 Jun 2008 13:28:26 -0700 (PDT)
Message-ID: <20080603.132826.197798175.davem@davemloft.net>
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
 net/wireless/wext.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index a1cd19a..e96559e 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1061,18 +1061,26 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned i
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
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
