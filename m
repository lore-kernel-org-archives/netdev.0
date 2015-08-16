From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] inet: Move VRF table lookup to inlined function
Date: Sun, 16 Aug 2015 17:13:27 -0600
Message-ID: <1439766807-3821-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33988 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbbHPXNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 19:13:34 -0400
Received: by paccq16 with SMTP id cq16so51217314pac.1
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2015 16:13:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Table lookup compiles out when VRF is not enabled.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/vrf.h  | 24 ++++++++++++++++++++++++
 net/ipv4/af_inet.c | 10 +---------
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/net/vrf.h b/include/net/vrf.h
index 0484d29d4589..40e3793c7a05 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -81,6 +81,25 @@ static inline int vrf_dev_table(const struct net_device *dev)
 	return tb_id;
 }
 
+static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	int tb_id = 0;
+
+	if (!ifindex)
+		return 0;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (dev)
+		tb_id = vrf_dev_table_rcu(dev);
+
+	rcu_read_unlock();
+
+	return tb_id;
+}
+
 /* called with rtnl */
 static inline int vrf_dev_table_rtnl(const struct net_device *dev)
 {
@@ -125,6 +144,11 @@ static inline int vrf_dev_table(const struct net_device *dev)
 	return 0;
 }
 
+static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
+{
+	return 0;
+}
+
 static inline int vrf_dev_table_rtnl(const struct net_device *dev)
 {
 	return 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c8b855882fa5..675e88cac2b4 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -450,15 +450,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	if (sk->sk_bound_dev_if) {
-		struct net_device *dev;
-
-		rcu_read_lock();
-		dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
-		if (dev)
-			tb_id = vrf_dev_table_rcu(dev) ? : tb_id;
-		rcu_read_unlock();
-	}
+	tb_id = vrf_dev_table_ifindex(net, sk->sk_bound_dev_if) ? : tb_id;
 	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
 
 	/* Not specified by any standard per-se, however it breaks too
-- 
2.3.2 (Apple Git-55)
