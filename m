From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/02: nf_conntrack_proto_gre: switch to register_pernet_gen_subsys()
Date: Thu, 30 Oct 2008 08:31:47 +0100 (MET)
Message-ID: <20081030073146.14487.64303.sendpatchset@x2.localnet>
References: <20081030073143.14487.24299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081030073143.14487.24299.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit fd0e558a126650fa335acaacc42e697cc84deb12
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Thu Oct 30 08:15:36 2008 +0100

    netfilter: nf_conntrack_proto_gre: switch to register_pernet_gen_subsys()
    
    register_pernet_gen_device() can't be used is nf_conntrack_pptp module is
    also used (compiled in or loaded).
    
    Right now, proto_gre_net_exit() is called before nf_conntrack_pptp_net_exit().
    The former shutdowns and frees GRE piece of netns, however the latter
    absolutely needs it to flush keymap. Oops is inevitable.
    
    Switch to shiny new register_pernet_gen_subsys() to get correct ordering in
    netns ops list.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a2cdbcb..4ab62ad 100644
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
