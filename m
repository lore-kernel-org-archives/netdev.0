From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6/l3mdev: Move host route on saved address if necessary
Date: Sat, 27 Feb 2016 09:59:17 -0800
Message-ID: <1456595957-29477-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36028 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756590AbcB0R73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 12:59:29 -0500
Received: by mail-pf0-f176.google.com with SMTP id t66so1892307pfb.3
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 09:59:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f1705ec197e70 allows IPv6 addresses to be retained on a link down.
The address can have a cached host route which can point to the wrong
FIB table if the L3 enslavement is changed (e.g., route can point to local
table instead of VRF table if device is added to an L3 domain).

On link up check the table of the cached host route against the FIB
table associated with the device and correct if needed.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Normally the 'if CONFIG_NET_L3_MASTER_DEV is enabled' checks are all
done in l3mdev.h. In this case putting the functions in the l3mdev
header requires adding ipv6 header files which blows up compiles.

 net/ipv6/addrconf.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a2d6f6c242af..afab4c359b5b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3170,9 +3170,35 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+/* If the host route is cached on the addr struct make sure it is associated
+ * with the proper table. e.g., enslavement can change and if so the cached
+ * host route needs to move to the new table.
+ */
+static void l3mdev_check_host_rt(struct inet6_dev *idev,
+				  struct inet6_ifaddr *ifp)
+{
+	if (ifp->rt) {
+		u32 tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
+
+		if (tb_id != ifp->rt->rt6i_table->tb6_id) {
+			ip6_del_rt(ifp->rt);
+			ifp->rt = NULL;
+		}
+	}
+}
+#else
+static void l3mdev_check_host_rt(struct inet6_dev *idev,
+				  struct inet6_ifaddr *ifp)
+{
+}
+#endif
+
 static int fixup_permanent_addr(struct inet6_dev *idev,
 				struct inet6_ifaddr *ifp)
 {
+	l3mdev_check_host_rt(idev, ifp);
+
 	if (!ifp->rt) {
 		struct rt6_info *rt;
 
-- 
2.1.4
