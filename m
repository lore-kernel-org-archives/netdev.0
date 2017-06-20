From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dccp: call inet_add_protocol after register_pernet_subsys in dccp_v6_init
Date: Tue, 20 Jun 2017 15:44:44 +0800
Message-ID: <50ab32d7b798e943090fc86b3c96181507907704.1497944684.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33442 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdFTHox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 03:44:53 -0400
Received: by mail-pg0-f68.google.com with SMTP id u62so14231947pgb.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 00:44:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch "call inet_add_protocol after register_pernet_subsys in dccp_v4_init"
fixed a null pointer dereference issue for dccp_ipv4 module.

The same fix is needed for dccp_ipv6 module.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/dccp/ipv6.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9926211..4fccc0c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1098,33 +1098,33 @@ static int __init dccp_v6_init(void)
 {
 	int err = proto_register(&dccp_v6_prot, 1);
 
-	if (err != 0)
+	if (err)
 		goto out;
 
-	err = inet6_add_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
-	if (err != 0)
-		goto out_unregister_proto;
-
 	inet6_register_protosw(&dccp_v6_protosw);
 
 	err = register_pernet_subsys(&dccp_v6_ops);
-	if (err != 0)
+	if (err)
 		goto out_destroy_ctl_sock;
+
+	err = inet6_add_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
+	if (err)
+		goto out_unregister_proto;
+
 out:
 	return err;
-
+out_unregister_proto:
+	unregister_pernet_subsys(&dccp_v6_ops);
 out_destroy_ctl_sock:
-	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
-out_unregister_proto:
 	proto_unregister(&dccp_v6_prot);
 	goto out;
 }
 
 static void __exit dccp_v6_exit(void)
 {
-	unregister_pernet_subsys(&dccp_v6_ops);
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
+	unregister_pernet_subsys(&dccp_v6_ops);
 	inet6_unregister_protosw(&dccp_v6_protosw);
 	proto_unregister(&dccp_v6_prot);
 }
-- 
2.1.0
