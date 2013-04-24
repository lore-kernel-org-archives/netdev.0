From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v6 2/5] ipv6: export a stub for ipv6_sock_mc_join and ipv6_sock_mc_drop
Date: Wed, 24 Apr 2013 13:54:31 +0800
Message-ID: <1366782874-18700-3-git-send-email-amwang@redhat.com>
References: <1366782874-18700-1-git-send-email-amwang@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:21071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610Ab3DXFzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 01:55:17 -0400
In-Reply-To: <1366782874-18700-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <amwang@redhat.com>

In case IPv6 is compiled as a module, introduce a stub
for ipv6_sock_mc_join and ipv6_sock_mc_drop. It will be used
by vxlan module. Suggested by Ben.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/addrconf.h   |    9 +++++++++
 net/ipv6/addrconf_core.c |    3 +++
 net/ipv6/mcast.c         |    7 +++++++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..c82e00f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -140,6 +140,15 @@ extern bool inet6_mc_check(struct sock *sk,
 			   const struct in6_addr *mc_addr,
 			   const struct in6_addr *src_addr);
=20
+/* A stub used by vxlan module */
+struct ipv6_mcast_ops {
+	int (*ipv6_sock_mc_join)(struct sock *sk, int ifindex,
+				 const struct in6_addr *addr);
+	int (*ipv6_sock_mc_drop)(struct sock *sk, int ifindex,
+				 const struct in6_addr *addr);
+};
+extern const struct ipv6_mcast_ops *ipv6_mcast_ops __read_mostly;
+
 extern int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_ad=
dr *addr);
 extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_=
addr *addr);
 extern int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_ad=
dr *addr);
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 7210456..8c7cb63 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -97,3 +97,6 @@ int inet6addr_notifier_call_chain(unsigned long val, =
void *v)
 	return atomic_notifier_call_chain(&inet6addr_chain, val, v);
 }
 EXPORT_SYMBOL(inet6addr_notifier_call_chain);
+
+const struct ipv6_mcast_ops *ipv6_mcast_ops __read_mostly;
+EXPORT_SYMBOL_GPL(ipv6_mcast_ops);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..cfa31d2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2665,12 +2665,19 @@ static struct pernet_operations igmp6_net_ops =3D=
 {
 	.exit =3D igmp6_net_exit,
 };
=20
+static const struct ipv6_mcast_ops ipv6_mcast_ops_impl =3D {
+	.ipv6_sock_mc_join =3D ipv6_sock_mc_join,
+	.ipv6_sock_mc_drop =3D ipv6_sock_mc_drop,
+};
+
 int __init igmp6_init(void)
 {
+	ipv6_mcast_ops =3D &ipv6_mcast_ops_impl;
 	return register_pernet_subsys(&igmp6_net_ops);
 }
=20
 void igmp6_cleanup(void)
 {
+	ipv6_mcast_ops =3D NULL;
 	unregister_pernet_subsys(&igmp6_net_ops);
 }
--=20
1.7.7.6
