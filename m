From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: ipset: pernet ops must be unregistered last
Date: Mon,  9 Oct 2017 18:25:38 +0200
Message-ID: <1507566346-32553-5-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Removing the ipset module leaves a small window where one cpu performs
module removal while another runs a command like 'ipset flush'.

ipset uses net_generic(), unregistering the pernet ops frees this
storage area.

Fix it by first removing the user-visible api handlers and the pernet
ops last.

Fixes: 1785e8f473082 ("netfiler: ipset: Add net namespace for ipset")
Reported-by: Li Shuang <shuali@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index e495b5e484b1..a7f049ff3049 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -2072,25 +2072,28 @@ static struct pernet_operations ip_set_net_ops = {
 static int __init
 ip_set_init(void)
 {
-	int ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
+	int ret = register_pernet_subsys(&ip_set_net_ops);
 
+	if (ret) {
+		pr_err("ip_set: cannot register pernet_subsys.\n");
+		return ret;
+	}
+
+	ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
 	if (ret != 0) {
 		pr_err("ip_set: cannot register with nfnetlink.\n");
+		unregister_pernet_subsys(&ip_set_net_ops);
 		return ret;
 	}
+
 	ret = nf_register_sockopt(&so_set);
 	if (ret != 0) {
 		pr_err("SO_SET registry failed: %d\n", ret);
 		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
+		unregister_pernet_subsys(&ip_set_net_ops);
 		return ret;
 	}
-	ret = register_pernet_subsys(&ip_set_net_ops);
-	if (ret) {
-		pr_err("ip_set: cannot register pernet_subsys.\n");
-		nf_unregister_sockopt(&so_set);
-		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
-		return ret;
-	}
+
 	pr_info("ip_set: protocol %u\n", IPSET_PROTOCOL);
 	return 0;
 }
@@ -2098,9 +2101,10 @@ ip_set_init(void)
 static void __exit
 ip_set_fini(void)
 {
-	unregister_pernet_subsys(&ip_set_net_ops);
 	nf_unregister_sockopt(&so_set);
 	nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
+
+	unregister_pernet_subsys(&ip_set_net_ops);
 	pr_debug("these are the famous last words\n");
 }
 
-- 
2.1.4

