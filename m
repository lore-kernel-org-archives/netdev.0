From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] gre: fix netns vs proto registration ordering
Date: Tue, 16 Feb 2010 19:57:44 +0200
Message-ID: <20100216175744.GA4685@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:57685 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933164Ab0BPR5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 12:57:46 -0500
Received: by fxm7 with SMTP id 7so7493795fxm.28
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 09:57:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE protocol receive hook can be called right after protocol addition is done.
If netns stuff is not yet initialized, we're going to oops in
net_generic().

This is remotely oopsable if ip_gre is compiled as module and packet
comes at unfortunate moment of module loading.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ip_gre.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1665,14 +1665,15 @@ static int __init ipgre_init(void)
 
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
 
-	if (inet_add_protocol(&ipgre_protocol, IPPROTO_GRE) < 0) {
-		printk(KERN_INFO "ipgre init: can't add protocol\n");
-		return -EAGAIN;
-	}
-
 	err = register_pernet_device(&ipgre_net_ops);
 	if (err < 0)
-		goto gen_device_failed;
+		return err;
+
+	err = inet_add_protocol(&ipgre_protocol, IPPROTO_GRE);
+	if (err < 0) {
+		printk(KERN_INFO "ipgre init: can't add protocol\n");
+		goto add_proto_failed;
+	}
 
 	err = rtnl_link_register(&ipgre_link_ops);
 	if (err < 0)
@@ -1688,9 +1689,9 @@ out:
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	unregister_pernet_device(&ipgre_net_ops);
-gen_device_failed:
 	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+add_proto_failed:
+	unregister_pernet_device(&ipgre_net_ops);
 	goto out;
 }
 
@@ -1698,9 +1699,9 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
-	unregister_pernet_device(&ipgre_net_ops);
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
+	unregister_pernet_device(&ipgre_net_ops);
 }
 
 module_init(ipgre_init);
