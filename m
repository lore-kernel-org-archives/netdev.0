From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/12]: wext: Pull ioctl permission checking out into helper
 function.
Date: Tue, 17 Jun 2008 00:53:45 -0700 (PDT)
Message-ID: <20080617.005345.175709521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno@sm.sony.co.jp, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756782AbYFQHxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:53:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


wext: Pull ioctl permission checking out into helper function.

Signed-off-by: David S. Miller <davem@davemloft.net>
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

