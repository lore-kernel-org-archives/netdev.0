From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH ipsec 1/3] vti6: Don't unregister pernet ops twice on init errors
Date: Fri,  9 May 2014 23:43:40 +0200
Message-ID: <1399671822-12842-2-git-send-email-minipli@googlemail.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:59118 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757573AbaEIVoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 17:44:03 -0400
Received: by mail-ee0-f53.google.com with SMTP id c13so3012069eek.40
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 14:44:02 -0700 (PDT)
In-Reply-To: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to register one of the xfrm protocol handlers we will
unregister the pernet ops twice on the error exit path. This will
probably lead to a kernel panic as the double deregistration
leads to a double kfree().

Fix this by removing one of the calls to do it only once.

Fixes: fa9ad96d49 ("vti6: Update the ipv6 side to use its own...")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/ipv6/ip6_vti.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index b7c0f82714..a51100379f 100644
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
1.7.10.4
