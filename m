From: Daniel Mack <daniel@zonque.org>
Subject: cgroup matches in INPUT chain
Date: Thu, 19 Mar 2015 19:41:22 +0100
Message-ID: <550B1852.2020209@zonque.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020900000507060102040602"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:38706 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbbCSSl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 14:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020900000507060102040602
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hi,

I'm currently looking into the netclass CGroup controller and its
netfilter module in order to build a per-application firewall with it.
I'm having trouble understanding the commit log of a00e76349f35
("netfilter: x_tables: allow to use cgroup match for LOCAL_IN nf
hooks"), especially the following paragraph:

> It's possible to get classified sk_buff after PREROUTING, due to
> socket lookup being done in early_demux (tcp_v4_early_demux). Also
> it works for udp as well.

What is "after PREROUTING" supposed to mean exactly? After all, the
examples in the commit log put the rules into the "INPUT" chain.

In my tests, however, NF_INET_LOCAL_IN is iterated before early_demux()
is called, and for skbs that do not have a socket assigned, the cgroup
match code bails out early, making the rules ineffective. Hence,
NF_INET_LOCAL_IN can't work reliably for these matches IMO, as the
cgroup rules don't apply to at least every first packet in a TCP stream.
Am I missing something?

It would also possible to do something similar to what the "socket"
module does, and look up a listening socket directly from cgroup_mt() in
case skb->sk == NULL. I've attached a patch that implements that and
which works for me, but I'm not sure if that's a sane way to go.


Thanks,
Daniel

--------------020900000507060102040602
Content-Type: text/x-diff;
 name="0001-netfilter-x_tables-implement-matching-for-skb-sk-NUL.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-netfilter-x_tables-implement-matching-for-skb-sk-NUL.pa";
 filename*1="tch"

=46rom 7562d97b6090a36395f0c95b54f5d5ecd6bfc01f Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@zonque.org>
Date: Fri, 13 Mar 2015 15:48:41 +0100
Subject: [PATCH RFC] netfilter: x_tables: implement cgroup matching for s=
kb->sk =3D=3D NULL

For skbs which do not have a socket assigned (which is at least the case
for every first packet in a stream), the cgroup matching code currently
bails out early, which makes cgroup rules ineffective. Only subsequently
received packets of the stream (if any) are caught.

In order to use this type of matches for a per-application firewall, we
need to make sure to catch all packets, including the first one.

This patch adds code to look up listening TCP and UDP sockets in case
the skb does not have a socket assigned yet. If one is found, the
cgroup match is done against the class ID of the found socket. As this
makes the implementation specific to tcp/udp, the module now has to
implement match functions for both IPv4 and IPv6.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/netfilter/xt_cgroup.c | 141 ++++++++++++++++++++++++++++++++++++++++=
------
 1 file changed, 124 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index 7198d66..766732f 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -16,7 +16,10 @@
 #include <linux/module.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_cgroup.h>
+#include <net/inet6_hashtables.h>
 #include <net/sock.h>
+#include <net/tcp.h>
+#include <net/udp.h>
=20
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
@@ -35,37 +38,141 @@ static int cgroup_mt_check(const struct xt_mtchk_par=
am *par)
 }
=20
 static bool
-cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
+cgroup_mt_ipv4(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_cgroup_info *info =3D par->matchinfo;
+	struct sock *sk =3D skb->sk;
+	bool ret;
=20
-	if (skb->sk =3D=3D NULL)
-		return false;
+	if (!sk) {
+		const struct iphdr *iph =3D ip_hdr(skb);
+		struct udphdr hdr, *hp;
=20
-	return (info->id =3D=3D skb->sk->sk_classid) ^ info->invert;
+		hp =3D skb_header_pointer(skb, ip_hdrlen(skb), sizeof(hdr), &hdr);
+		if (!hp)
+			return false;
+
+		switch (iph->protocol) {
+		case IPPROTO_UDP:
+			sk =3D udp4_lib_lookup(dev_net(skb->dev),
+					     iph->saddr, hp->source,
+					     iph->daddr, hp->dest,
+					     par->in->ifindex);
+			break;
+
+		case IPPROTO_TCP:
+			sk =3D __inet_lookup(dev_net(skb->dev), &tcp_hashinfo,
+					   iph->saddr, hp->source,
+					   iph->daddr, hp->dest,
+					   par->in->ifindex);
+			break;
+
+		default:
+			break;
+		}
+
+		if (!sk)
+			return false;
+	}
+
+	ret =3D (info->id =3D=3D sk->sk_classid) ^ info->invert;
+
+	if (sk !=3D skb->sk)
+		sock_gen_put(sk);
+
+	return ret;
+}
+
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+static bool
+cgroup_mt_ipv6(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cgroup_info *info =3D par->matchinfo;
+	struct sock *sk =3D skb->sk;
+	bool ret;
+
+	if (!sk) {
+		const struct ipv6hdr *iph =3D ipv6_hdr(skb);
+		struct udphdr hdr, *hp;
+		int tproto, thoff =3D 0;
+
+		tproto =3D ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
+		if (tproto < 0)
+			return false;
+
+		hp =3D skb_header_pointer(skb, thoff, sizeof(hdr), &hdr);
+		if (!hp)
+			return false;
+
+		switch (tproto) {
+		case IPPROTO_UDP:
+			sk =3D udp6_lib_lookup(dev_net(skb->dev),
+					     &iph->saddr, hp->source,
+					     &iph->daddr, hp->dest,
+					     par->in->ifindex);
+			break;
+
+		case IPPROTO_TCP:
+			sk =3D inet6_lookup(dev_net(skb->dev), &tcp_hashinfo,
+					  &iph->saddr, hp->source,
+					  &iph->daddr, hp->dest,
+					  par->in->ifindex);
+			break;
+
+		default:
+			break;
+		}
+
+		if (!sk)
+			return false;
+	}
+
+	ret =3D (info->id =3D=3D sk->sk_classid) ^ info->invert;
+
+	if (sk !=3D skb->sk)
+		sock_gen_put(sk);
+
+	return ret;
 }
+#endif
=20
-static struct xt_match cgroup_mt_reg __read_mostly =3D {
-	.name       =3D "cgroup",
-	.revision   =3D 0,
-	.family     =3D NFPROTO_UNSPEC,
-	.checkentry =3D cgroup_mt_check,
-	.match      =3D cgroup_mt,
-	.matchsize  =3D sizeof(struct xt_cgroup_info),
-	.me         =3D THIS_MODULE,
-	.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
-		      (1 << NF_INET_POST_ROUTING) |
-		      (1 << NF_INET_LOCAL_IN),
+static struct xt_match cgroup_mt_reg[] __read_mostly =3D {
+	{
+		.name       =3D "cgroup",
+		.revision   =3D 0,
+		.family     =3D NFPROTO_IPV4,
+		.checkentry =3D cgroup_mt_check,
+		.match      =3D cgroup_mt_ipv4,
+		.matchsize  =3D sizeof(struct xt_cgroup_info),
+		.me         =3D THIS_MODULE,
+		.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
+			      (1 << NF_INET_POST_ROUTING) |
+			      (1 << NF_INET_LOCAL_IN),
+	},
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	{
+		.name       =3D "cgroup",
+		.revision   =3D 0,
+		.family     =3D NFPROTO_IPV6,
+		.checkentry =3D cgroup_mt_check,
+		.match      =3D cgroup_mt_ipv6,
+		.matchsize  =3D sizeof(struct xt_cgroup_info),
+		.me         =3D THIS_MODULE,
+		.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
+			      (1 << NF_INET_POST_ROUTING) |
+			      (1 << NF_INET_LOCAL_IN),
+	},
+#endif
 };
=20
 static int __init cgroup_mt_init(void)
 {
-	return xt_register_match(&cgroup_mt_reg);
+	return xt_register_matches(cgroup_mt_reg, ARRAY_SIZE(cgroup_mt_reg));
 }
=20
 static void __exit cgroup_mt_exit(void)
 {
-	xt_unregister_match(&cgroup_mt_reg);
+	xt_unregister_matches(cgroup_mt_reg, ARRAY_SIZE(cgroup_mt_reg));
 }
=20
 module_init(cgroup_mt_init);
--=20
2.3.2


--------------020900000507060102040602--
