From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/6] vti6: Don't unregister pernet ops twice on init errors
Date: Thu, 15 May 2014 09:07:55 +0200
Message-ID: <1400137676-27565-6-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44815 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164AbaEOHIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:24 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

If we fail to register one of the xfrm protocol handlers we will
unregister the pernet ops twice on the error exit path. This will
probably lead to a kernel panic as the double deregistration
leads to a double kfree().

Fix this by removing one of the calls to do it only once.

Fixes: fa9ad96d49 ("vti6: Update the ipv6 side to use its own...")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index b7c0f82..a511003 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1097,7 +1097,6 @@ static int __init vti6_tunnel_init(void)
 
 	err = xfrm6_protocol_register(&vti_esp6_protocol, IPPROTO_ESP);
 	if (err < 0) {
-		unregister_pernet_device(&vti6_net_ops);
 		pr_err("%s: can't register vti6 protocol\n", __func__);
 
 		goto out;
@@ -1106,7 +1105,6 @@ static int __init vti6_tunnel_init(void)
 	err = xfrm6_protocol_register(&vti_ah6_protocol, IPPROTO_AH);
 	if (err < 0) {
 		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
-		unregister_pernet_device(&vti6_net_ops);
 		pr_err("%s: can't register vti6 protocol\n", __func__);
 
 		goto out;
@@ -1116,7 +1114,6 @@ static int __init vti6_tunnel_init(void)
 	if (err < 0) {
 		xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
 		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
-		unregister_pernet_device(&vti6_net_ops);
 		pr_err("%s: can't register vti6 protocol\n", __func__);
 
 		goto out;
-- 
1.7.9.5
