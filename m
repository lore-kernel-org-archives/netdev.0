From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 03/11] ipv6: export a stub for IPv6 symbols used by vxlan
Date: Wed, 28 Aug 2013 13:22:51 +0800
Message-ID: <1377667379-2315-4-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441Ab3H1FXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:44 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

In case IPv6 is compiled as a module, introduce a stub
for ipv6_sock_mc_join and ipv6_sock_mc_drop etc.. It will be used
by vxlan module. Suggested by Ben.

This is an ugly but easy solution for now.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/addrconf.h   |   15 +++++++++++++++
 net/ipv6/addrconf_core.c |    3 +++
 net/ipv6/af_inet6.c      |   11 +++++++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 43fa31a..5339cab 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -141,6 +141,21 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 			 const struct in6_addr *src_addr);
 
 void ipv6_mc_dad_complete(struct inet6_dev *idev);
+
+/* A stub used by vxlan module. This is ugly, ideally these
+ * symbols should be built into the core kernel.
+ */
+struct ipv6_stub {
+	int (*ipv6_sock_mc_join)(struct sock *sk, int ifindex,
+				 const struct in6_addr *addr);
+	int (*ipv6_sock_mc_drop)(struct sock *sk, int ifindex,
+				 const struct in6_addr *addr);
+	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
+				struct flowi6 *fl6);
+	void (*udpv6_encap_enable)(void);
+};
+extern const struct ipv6_stub *ipv6_stub __read_mostly;
+
 /*
  * identify MLD packets for MLD filter exceptions
  */
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d2f8742..93b24c6 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -98,3 +98,6 @@ int inet6addr_notifier_call_chain(unsigned long val, void *v)
 	return atomic_notifier_call_chain(&inet6addr_chain, val, v);
 }
 EXPORT_SYMBOL(inet6addr_notifier_call_chain);
+
+const struct ipv6_stub *ipv6_stub __read_mostly;
+EXPORT_SYMBOL_GPL(ipv6_stub);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0d1a9b1..0c9c22f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -810,6 +810,13 @@ static struct pernet_operations inet6_net_ops = {
 	.exit = inet6_net_exit,
 };
 
+static const struct ipv6_stub ipv6_stub_impl = {
+	.ipv6_sock_mc_join = ipv6_sock_mc_join,
+	.ipv6_sock_mc_drop = ipv6_sock_mc_drop,
+	.ipv6_dst_lookup = ip6_dst_lookup,
+	.udpv6_encap_enable = udpv6_encap_enable,
+};
+
 static int __init inet6_init(void)
 {
 	struct list_head *r;
@@ -884,6 +891,9 @@ static int __init inet6_init(void)
 	err = igmp6_init();
 	if (err)
 		goto igmp_fail;
+
+	ipv6_stub = &ipv6_stub_impl;
+
 	err = ipv6_netfilter_init();
 	if (err)
 		goto netfilter_fail;
@@ -1040,6 +1050,7 @@ static void __exit inet6_exit(void)
 	raw6_proc_exit();
 #endif
 	ipv6_netfilter_fini();
+	ipv6_stub = NULL;
 	igmp6_cleanup();
 	ndisc_cleanup();
 	ip6_mr_cleanup();
-- 
1.7.7.6
