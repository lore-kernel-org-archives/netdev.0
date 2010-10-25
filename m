From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a
 separate module
Date: Mon, 25 Oct 2010 11:38:32 +0200
Message-ID: <1287999512.2160.25.camel@este.odu>
References: <20101021104709.5192.31249.stgit@este.odu>
	 <20101021104709.5192.64336.stgit@este.odu>  <4CC02456.4050301@trash.net>
	 <1287661385.13326.45.camel@este.odu>  <4CC0486D.60703@trash.net>
	 <1287699558.2607.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brother.balabit.com ([195.70.62.219]:44082 "EHLO
	lists.balabit.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab0JYJij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 05:38:39 -0400
In-Reply-To: <1287699558.2607.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2010-10-22 at 00:19 +0200, Eric Dumazet wrote:
> Le jeudi 21 octobre 2010 =C3=A0 16:04 +0200, Patrick McHardy a =C3=A9=
crit :
> > Am 21.10.2010 13:43, schrieb KOVACS Krisztian:
> > > tproxy: split off ipv6 defragmentation to a separate module
> > >    =20
> > >     Like with IPv4, TProxy needs IPv6 defragmentation but does no=
t
> > >     require connection tracking. Since defragmentation was couple=
d
> > >     with conntrack, I split off the two, creating an nf_defrag_ip=
v6 module,
> > >     similar to the already existing nf_defrag_ipv4.
> >=20
> > Applied, thanks.
>=20
> Hmm...
>=20
> CONFIG_IPV6=3Dm
> CONFIG_NETFILTER_TPROXY=3Dm
>=20
>=20
>   MODPOST 201 modules
> ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_TPROXY.ko] undefined=
!
> ERROR: "ipv6_find_hdr" [net/netfilter/xt_TPROXY.ko] undefined!
>=20
> Sorry, it's late here, I wont fix this ;)

Oops, I guess this is because you do have IPv6 support but don't have
ip6tables enabled in your config. Does the patch below fix the issue fo=
r
you? (For me it now compiles with and without IPv6 conntrack, ip6tables
and IPv6 support, too.)



netfilter: fix module dependency issues with IPv6 defragmentation, ip6t=
ables and xt_TPROXY

One of the previous tproxy related patches split IPv6 defragmentation a=
nd
connection tracking, but did not correctly add Kconfig stanzas to handl=
e the
new dependencies correctly. This patch fixes that by making the config =
options
mirror the setup we have for IPv4: a distinct config option for defragm=
entation
that is automatically selected by both connection tracking and
xt_TPROXY/xt_socket.

The patch also changes the #ifdefs enclosing IPv6 specific code in xt_s=
ocket
and xt_TPROXY: we only compile these in case we have ip6tables support =
enabled.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---
 net/ipv6/netfilter/Kconfig  |    5 +++++
 net/ipv6/netfilter/Makefile |    5 ++++-
 net/netfilter/Kconfig       |    2 ++
 net/netfilter/xt_TPROXY.c   |   10 ++++++----
 net/netfilter/xt_socket.c   |   12 ++++++++----
 5 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 29d643b..e5f6edc 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -5,10 +5,15 @@
 menu "IPv6: Netfilter Configuration"
 	depends on INET && IPV6 && NETFILTER
=20
+config NF_DEFRAG_IPV6
+	tristate
+	default n
+
 config NF_CONNTRACK_IPV6
 	tristate "IPv6 connection tracking support"
 	depends on INET && IPV6 && NF_CONNTRACK
 	default m if NETFILTER_ADVANCED=3Dn
+	select NF_DEFRAG_IPV6
 	---help---
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 3f8e4a3..0a432c9 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -12,11 +12,14 @@ obj-$(CONFIG_IP6_NF_SECURITY) +=3D ip6table_securit=
y.o
=20
 # objects for l3 independent conntrack
 nf_conntrack_ipv6-objs  :=3D  nf_conntrack_l3proto_ipv6.o nf_conntrack=
_proto_icmpv6.o
-nf_defrag_ipv6-objs :=3D nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
=20
 # l3 independent conntrack
 obj-$(CONFIG_NF_CONNTRACK_IPV6) +=3D nf_conntrack_ipv6.o nf_defrag_ipv=
6.o
=20
+# defrag
+nf_defrag_ipv6-objs :=3D nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
+obj-$(CONFIG_NF_DEFRAG_IPV6) +=3D nf_defrag_ipv6.o
+
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) +=3D ip6t_ah.o
 obj-$(CONFIG_IP6_NF_MATCH_EUI64) +=3D ip6t_eui64.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4328825..1534f2b 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -525,6 +525,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	select NF_DEFRAG_IPV4
+	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
 	  This option adds a `TPROXY' target, which is somewhat similar to
 	  REDIRECT.  It can only be used in the mangle table and is useful
@@ -927,6 +928,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DEFRAG_IPV4
+	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
 	  This option adds a `socket' match, which can be used to match
 	  packets for which a TCP or UDP socket lookup finds a valid socket.
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 19c482c..640678f 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -21,7 +21,9 @@
 #include <linux/netfilter_ipv4/ip_tables.h>
=20
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#define XT_TPROXY_HAVE_IPV6 1
 #include <net/if_inet6.h>
 #include <net/addrconf.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
@@ -172,7 +174,7 @@ tproxy_tg4_v1(struct sk_buff *skb, const struct xt_=
action_param *par)
 	return tproxy_tg4(skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi=
->mark_value);
 }
=20
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_TPROXY_HAVE_IPV6
=20
 static inline const struct in6_addr *
 tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
@@ -372,7 +374,7 @@ static struct xt_target tproxy_tg_reg[] __read_most=
ly =3D {
 		.hooks		=3D 1 << NF_INET_PRE_ROUTING,
 		.me		=3D THIS_MODULE,
 	},
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_TPROXY_HAVE_IPV6
 	{
 		.name		=3D "TPROXY",
 		.family		=3D NFPROTO_IPV6,
@@ -391,7 +393,7 @@ static struct xt_target tproxy_tg_reg[] __read_most=
ly =3D {
 static int __init tproxy_tg_init(void)
 {
 	nf_defrag_ipv4_enable();
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_TPROXY_HAVE_IPV6
 	nf_defrag_ipv6_enable();
 #endif
=20
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 2dbd4c8..d94a858 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -14,7 +14,6 @@
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/icmp.h>
@@ -22,7 +21,12 @@
 #include <net/inet_sock.h>
 #include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#define XT_SOCKET_HAVE_IPV6 1
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+#endif
=20
 #include <linux/netfilter/xt_socket.h>
=20
@@ -186,7 +190,7 @@ socket_mt4_v1(const struct sk_buff *skb, struct xt_=
action_param *par)
 	return socket_match(skb, par, par->matchinfo);
 }
=20
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_SOCKET_HAVE_IPV6
=20
 static int
 extract_icmp6_fields(const struct sk_buff *skb,
@@ -331,7 +335,7 @@ static struct xt_match socket_mt_reg[] __read_mostl=
y =3D {
 				  (1 << NF_INET_LOCAL_IN),
 		.me		=3D THIS_MODULE,
 	},
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_SOCKET_HAVE_IPV6
 	{
 		.name		=3D "socket",
 		.revision	=3D 1,
@@ -348,7 +352,7 @@ static struct xt_match socket_mt_reg[] __read_mostl=
y =3D {
 static int __init socket_mt_init(void)
 {
 	nf_defrag_ipv4_enable();
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef XT_SOCKET_HAVE_IPV6
 	nf_defrag_ipv6_enable();
 #endif
=20





