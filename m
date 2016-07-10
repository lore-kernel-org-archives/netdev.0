From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH] tunnels: correct conditional build of MPLS
Date: Sun, 10 Jul 2016 09:20:54 +0900
Message-ID: <1468110054-28646-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36187 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbcGJAVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 20:21:05 -0400
Received: by mail-pf0-f172.google.com with SMTP id t190so24003865pfb.3
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 17:21:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* If MPLS is not enabled then err_mpls is not needed
* If IPV6 is not enabled then unregistering IPPROTO_IPV6 is not
  needed in the error path and err_ipv6 is not needed
* When unregistering IPPROTO_IPV6 the tunnel64_protocol structure
  rather than the tunnel4_protocol structure should be used.
* If neither MPLS nor IPV6 are enabled then unregistering IPPROTO_IPIP
  is not needed in the error path

Fixes: 8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/ipv4/tunnel4.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 45cd4253583a..1dd098b890a7 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -219,12 +219,16 @@ static int __init tunnel4_init(void)
 #endif
 	return 0;
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_MPLS)
 err_mpls:
-	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPV6);
 #endif
+#if IS_ENABLED(CONFIG_IPV6)
+	inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6);
 err_ipv6:
+#endif
+#if IS_ENABLED(CONFIG_MPLS) || IS_ENABLED(CONFIG_IPV6)
 	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+#endif
 err_ipip:
 	pr_err("%s: can't add protocol\n", __func__);
 	return -EAGAIN;
-- 
2.7.0.rc3.207.g0ac5344
