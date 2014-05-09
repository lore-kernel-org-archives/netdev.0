From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH ipsec 3/3] vti: Simplify error handling in module init and exit
Date: Fri,  9 May 2014 23:43:42 +0200
Message-ID: <1399671822-12842-4-git-send-email-minipli@googlemail.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:36966 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757771AbaEIVoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 17:44:06 -0400
Received: by mail-ee0-f52.google.com with SMTP id e53so3014526eek.39
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 14:44:04 -0700 (PDT)
In-Reply-To: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/ipv4/ip_vti.c |   54 ++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index afcee51b90..d8d2cbe6d4 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -525,40 +525,28 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 
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
@@ -567,23 +555,23 @@ static int __init vti_init(void)
 
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
1.7.10.4
