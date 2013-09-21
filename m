From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] ipv6: do not allow ipv6 module to be removed
Date: Sat, 21 Sep 2013 11:12:21 +0800
Message-ID: <1379733141-10643-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066Ab3IUDMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 23:12:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

There was some bug report on ipv6 module removal path before.
Also, as Stephen pointed out, after vxlan module gets ipv6 support,
the ipv6 stub it used is not safe against this module removal either.
So, let's just remove inet6_exit() so that ipv6 module will not be
able to be unloaded.

Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7c96100..4966b12 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1028,52 +1028,4 @@ out_unregister_tcp_proto:
 }
 module_init(inet6_init);
 
-static void __exit inet6_exit(void)
-{
-	if (disable_ipv6_mod)
-		return;
-
-	/* First of all disallow new sockets creation. */
-	sock_unregister(PF_INET6);
-	/* Disallow any further netlink messages */
-	rtnl_unregister_all(PF_INET6);
-
-	udpv6_exit();
-	udplitev6_exit();
-	tcpv6_exit();
-
-	/* Cleanup code parts. */
-	ipv6_packet_cleanup();
-	ipv6_frag_exit();
-	ipv6_exthdrs_exit();
-	addrconf_cleanup();
-	ip6_flowlabel_cleanup();
-	ndisc_late_cleanup();
-	ip6_route_cleanup();
-#ifdef CONFIG_PROC_FS
-
-	/* Cleanup code parts. */
-	if6_proc_exit();
-	ipv6_misc_proc_exit();
-	udplite6_proc_exit();
-	raw6_proc_exit();
-#endif
-	ipv6_netfilter_fini();
-	ipv6_stub = NULL;
-	igmp6_cleanup();
-	ndisc_cleanup();
-	ip6_mr_cleanup();
-	icmpv6_cleanup();
-	rawv6_exit();
-
-	unregister_pernet_subsys(&inet6_net_ops);
-	proto_unregister(&rawv6_prot);
-	proto_unregister(&udplitev6_prot);
-	proto_unregister(&udpv6_prot);
-	proto_unregister(&tcpv6_prot);
-
-	rcu_barrier(); /* Wait for completion of call_rcu()'s */
-}
-module_exit(inet6_exit);
-
 MODULE_ALIAS_NETPROTO(PF_INET6);
