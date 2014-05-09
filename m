From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH ipsec 2/3] vti6: Simplify error handling in module init and exit
Date: Fri,  9 May 2014 23:43:41 +0200
Message-ID: <1399671822-12842-3-git-send-email-minipli@googlemail.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:56338 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbaEIVoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 17:44:05 -0400
Received: by mail-ee0-f44.google.com with SMTP id c41so2956211eek.31
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 14:44:03 -0700 (PDT)
In-Reply-To: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error handling in the module init and exit functions can be
shortened to safe us some code.

1/ Remove the code duplications in the init function, jump straight to
the existing cleanup code by adding some labels. Also give the error
message some more value by telling the reason why loading the module has
failed.

2/ Remove the error handling in the exit function as the only legitimate
reason xfrm6_protocol_deregister() might fail is inet6_del_protocol()
returning -1. That, in turn, means some other protocol handler had been
registered for this very protocol in the meantime. But that essentially
means we haven't been handling that protocol any more, anyway. What it
definitely means not is that we "can't deregister protocol". Therefore
just get rid of that bogus warning. It's plain wrong.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/ipv6/ip6_vti.c |   51 +++++++++++++++++---------------------------
 1 file changed, 20 insertions(+), 31 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index a51100379f..59201ffc17 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1089,36 +1089,26 @@ static struct xfrm6_protocol vti_ipcomp6_protocol __read_mostly = {
  **/
 static int __init vti6_tunnel_init(void)
 {
-	int  err;
+	const char *msg;
+	int err;
 
+	msg = "tunnel device";
 	err = register_pernet_device(&vti6_net_ops);
 	if (err < 0)
-		goto out_pernet;
+		goto pernet_dev_failed;
 
+	msg = "tunnel protocols";
 	err = xfrm6_protocol_register(&vti_esp6_protocol, IPPROTO_ESP);
-	if (err < 0) {
-		pr_err("%s: can't register vti6 protocol\n", __func__);
-
-		goto out;
-	}
-
+	if (err < 0)
+		goto xfrm_proto_esp_failed;
 	err = xfrm6_protocol_register(&vti_ah6_protocol, IPPROTO_AH);
-	if (err < 0) {
-		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
-		pr_err("%s: can't register vti6 protocol\n", __func__);
-
-		goto out;
-	}
-
+	if (err < 0)
+		goto xfrm_proto_ah_failed;
 	err = xfrm6_protocol_register(&vti_ipcomp6_protocol, IPPROTO_COMP);
-	if (err < 0) {
-		xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
-		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
-		pr_err("%s: can't register vti6 protocol\n", __func__);
-
-		goto out;
-	}
+	if (err < 0)
+		goto xfrm_proto_comp_failed;
 
+	msg = "netlink interface";
 	err = rtnl_link_register(&vti6_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -1127,11 +1117,14 @@ static int __init vti6_tunnel_init(void)
 
 rtnl_link_failed:
 	xfrm6_protocol_deregister(&vti_ipcomp6_protocol, IPPROTO_COMP);
+xfrm_proto_comp_failed:
 	xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
+xfrm_proto_ah_failed:
 	xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
-out:
+xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti6_net_ops);
-out_pernet:
+pernet_dev_failed:
+	pr_err("vti6 init: failed to register %s\n", msg);
 	return err;
 }
 
@@ -1141,13 +1134,9 @@ out_pernet:
 static void __exit vti6_tunnel_cleanup(void)
 {
 	rtnl_link_unregister(&vti6_link_ops);
-	if (xfrm6_protocol_deregister(&vti_ipcomp6_protocol, IPPROTO_COMP))
-		pr_info("%s: can't deregister protocol\n", __func__);
-	if (xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH))
-		pr_info("%s: can't deregister protocol\n", __func__);
-	if (xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP))
-		pr_info("%s: can't deregister protocol\n", __func__);
-
+	xfrm6_protocol_deregister(&vti_ipcomp6_protocol, IPPROTO_COMP);
+	xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
+	xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti6_net_ops);
 }
 
-- 
1.7.10.4
