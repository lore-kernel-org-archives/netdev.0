From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 05/11] ipv6: export a stub for IPv6 symbols used by vxlan
Date: Mon, 27 May 2013 12:16:27 +0800
Message-ID: <1369628193-14925-6-git-send-email-amwang@redhat.com>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab3E0ERd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:17:33 -0400
In-Reply-To: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <amwang@redhat.com>

In case IPv6 is compiled as a module, introduce a stub
for ipv6_sock_mc_join and ipv6_sock_mc_drop etc.. It will
be used by vxlan module.

This is an ugly but easy solution for now.

Suggested-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/addrconf.h   |   14 ++++++++++++++
 net/ipv6/addrconf_core.c |    3 +++
 net/ipv6/af_inet6.c      |   11 +++++++++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..d09d42c 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -140,6 +140,20 @@ extern bool inet6_mc_check(struct sock *sk,
 			   const struct in6_addr *mc_addr,
 			   const struct in6_addr *src_addr);
=20
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
 extern int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_ad=
dr *addr);
 extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_=
addr *addr);
 extern int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_ad=
dr *addr);
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 7210456..3807a79 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -97,3 +97,6 @@ int inet6addr_notifier_call_chain(unsigned long val, =
void *v)
 	return atomic_notifier_call_chain(&inet6addr_chain, val, v);
 }
 EXPORT_SYMBOL(inet6addr_notifier_call_chain);
+
+const struct ipv6_stub *ipv6_stub __read_mostly;
+EXPORT_SYMBOL_GPL(ipv6_stub);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a5ac969..cf34d4a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -809,6 +809,13 @@ static struct pernet_operations inet6_net_ops =3D =
{
 	.exit =3D inet6_net_exit,
 };
=20
+static const struct ipv6_stub ipv6_stub_impl =3D {
+	.ipv6_sock_mc_join =3D ipv6_sock_mc_join,
+	.ipv6_sock_mc_drop =3D ipv6_sock_mc_drop,
+	.ipv6_dst_lookup =3D ip6_dst_lookup,
+	.udpv6_encap_enable =3D udpv6_encap_enable,
+};
+
 static int __init inet6_init(void)
 {
 	struct list_head *r;
@@ -883,6 +890,9 @@ static int __init inet6_init(void)
 	err =3D igmp6_init();
 	if (err)
 		goto igmp_fail;
+
+	ipv6_stub =3D &ipv6_stub_impl;
+
 	err =3D ipv6_netfilter_init();
 	if (err)
 		goto netfilter_fail;
@@ -1039,6 +1049,7 @@ static void __exit inet6_exit(void)
 	raw6_proc_exit();
 #endif
 	ipv6_netfilter_fini();
+	ipv6_stub =3D NULL;
 	igmp6_cleanup();
 	ndisc_cleanup();
 	ip6_mr_cleanup();
--=20
1.7.7.6
