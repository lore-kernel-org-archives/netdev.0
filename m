From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/2] nf_conntrack_proto_gre: switch to
	register_pernet_gen_subsys()
Date: Sun, 26 Oct 2008 02:51:05 +0400
Message-ID: <20081025225104.GB18858@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfiter-devel@vger.kernel.org,
	containters@lists.osdl.org
To: davem@davemloft.net, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:37768 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbYJYWrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 18:47:47 -0400
Received: by ey-out-2122.google.com with SMTP id 6so620704eyi.37
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2008 15:47:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register_pernet_gen_device() can't be used is nf_conntrack_pptp module is
also used (compiled in or loaded).

Right now, proto_gre_net_exit() is called before nf_conntrack_pptp_net_exit().
The former shutdowns and frees GRE piece of netns, however the latter
absolutely needs it to flush keymap. Oops is inevitable.

Switch to shiny new register_pernet_gen_subsys() to get correct ordering in
netns ops list.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_proto_gre.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -335,7 +335,7 @@ static int __init nf_ct_proto_gre_init(void)
 	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
 	if (rv < 0)
 		return rv;
-	rv = register_pernet_gen_device(&proto_gre_net_id, &proto_gre_net_ops);
+	rv = register_pernet_gen_subsys(&proto_gre_net_id, &proto_gre_net_ops);
 	if (rv < 0)
 		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 	return rv;
@@ -344,7 +344,7 @@ static int __init nf_ct_proto_gre_init(void)
 static void nf_ct_proto_gre_fini(void)
 {
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
-	unregister_pernet_gen_device(proto_gre_net_id, &proto_gre_net_ops);
+	unregister_pernet_gen_subsys(proto_gre_net_id, &proto_gre_net_ops);
 }
 
 module_init(nf_ct_proto_gre_init);
