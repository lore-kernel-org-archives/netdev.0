From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] vti: Simplify error handling in module init and exit
Date: Wed, 30 Jul 2014 13:12:27 +0200
Message-ID: <1406718748-21144-3-git-send-email-steffen.klassert@secunet.com>
References: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43736 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbaG3LNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 07:13:01 -0400
In-Reply-To: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The error handling in the module init and exit functions can be
shortened to safe us some code.

1/ Remove the code duplications in the init function, jump straight to
the existing cleanup code by adding some labels. Also give the error
message some more value by telling the reason why loading the module has
failed. Furthermore fix the "IPSec" typo -- it should be "IPsec" instead.

2/ Remove the error handling in the exit function as the only legitimate
reason xfrm4_protocol_deregister() might fail is inet_del_protocol()
returning -1. That, in turn, means some other protocol handler had been
registered for this very protocol in the meantime. But that essentially
means we haven't been handling that protocol any more, anyway. What it
definitely means not is that we "can't deregister tunnel". Therefore
just get rid of that bogus warning. It's plain wrong.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c | 54 +++++++++++++++++++++---------------------------------
 1 file changed, 21 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index b8960f3..e453cb7 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -534,40 +534,28 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 
 static int __init vti_init(void)
 {
+	const char *msg;
 	int err;
 
-	pr_info("IPv4 over IPSec tunneling driver\n");
+	pr_info("IPv4 over IPsec tunneling driver\n");
 
+	msg = "tunnel device";
 	err = register_pernet_device(&vti_net_ops);
 	if (err < 0)
-		return err;
-	err = xfrm4_protocol_register(&vti_esp4_protocol, IPPROTO_ESP);
-	if (err < 0) {
-		unregister_pernet_device(&vti_net_ops);
-		pr_info("vti init: can't register tunnel\n");
-
-		return err;
-	}
+		goto pernet_dev_failed;
 
+	msg = "tunnel protocols";
+	err = xfrm4_protocol_register(&vti_esp4_protocol, IPPROTO_ESP);
+	if (err < 0)
+		goto xfrm_proto_esp_failed;
 	err = xfrm4_protocol_register(&vti_ah4_protocol, IPPROTO_AH);
-	if (err < 0) {
-		xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
-		unregister_pernet_device(&vti_net_ops);
-		pr_info("vti init: can't register tunnel\n");
-
-		return err;
-	}
-
+	if (err < 0)
+		goto xfrm_proto_ah_failed;
 	err = xfrm4_protocol_register(&vti_ipcomp4_protocol, IPPROTO_COMP);
-	if (err < 0) {
-		xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
-		xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
-		unregister_pernet_device(&vti_net_ops);
-		pr_info("vti init: can't register tunnel\n");
-
-		return err;
-	}
+	if (err < 0)
+		goto xfrm_proto_comp_failed;
 
+	msg = "netlink interface";
 	err = rtnl_link_register(&vti_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -576,23 +564,23 @@ static int __init vti_init(void)
 
 rtnl_link_failed:
 	xfrm4_protocol_deregister(&vti_ipcomp4_protocol, IPPROTO_COMP);
+xfrm_proto_comp_failed:
 	xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
+xfrm_proto_ah_failed:
 	xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
+xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti_net_ops);
+pernet_dev_failed:
+	pr_err("vti init: failed to register %s\n", msg);
 	return err;
 }
 
 static void __exit vti_fini(void)
 {
 	rtnl_link_unregister(&vti_link_ops);
-	if (xfrm4_protocol_deregister(&vti_ipcomp4_protocol, IPPROTO_COMP))
-		pr_info("vti close: can't deregister tunnel\n");
-	if (xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH))
-		pr_info("vti close: can't deregister tunnel\n");
-	if (xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP))
-		pr_info("vti close: can't deregister tunnel\n");
-
-
+	xfrm4_protocol_deregister(&vti_ipcomp4_protocol, IPPROTO_COMP);
+	xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
+	xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti_net_ops);
 }
 
-- 
1.9.1
