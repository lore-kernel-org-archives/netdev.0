From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2] tunnels: correct conditional build of MPLS and IPv6
Date: Sun, 10 Jul 2016 10:20:11 +0900
Message-ID: <1468113611-21989-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33381 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809AbcGJBUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 21:20:21 -0400
Received: by mail-pa0-f53.google.com with SMTP id b13so23381638pat.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 18:20:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a combination if #if conditionals and goto labels to unwind
tunnel4_init seems unwieldy. This patch takes a simpler approach of
directly unregistering previously registered protocols when an error
occurs.

This fixes a number of problems with the current implementation
including the potential presence of labels when they are unused
and the potential absence of unregister code when it is needed.

Fixes: 8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/ipv4/tunnel4.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 45cd4253583a..ec35eaa5c029 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -208,24 +208,25 @@ static const struct net_protocol tunnelmpls4_protocol = {
 static int __init tunnel4_init(void)
 {
 	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP))
-		goto err_ipip;
+		goto err;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6))
-		goto err_ipv6;
+	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
+		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+		goto err;
+	}
 #endif
 #if IS_ENABLED(CONFIG_MPLS)
-	if (inet_add_protocol(&tunnelmpls4_protocol, IPPROTO_MPLS))
-		goto err_mpls;
+	if (inet_add_protocol(&tunnelmpls4_protocol, IPPROTO_MPLS)) {
+		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+#if IS_ENABLED(CONFIG_IPV6)
+		inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6);
+#endif
+		goto err;
+	}
 #endif
 	return 0;
 
-#if IS_ENABLED(CONFIG_IPV6)
-err_mpls:
-	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPV6);
-#endif
-err_ipv6:
-	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
-err_ipip:
+err:
 	pr_err("%s: can't add protocol\n", __func__);
 	return -EAGAIN;
 }
-- 
2.7.0.rc3.207.g0ac5344
