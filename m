From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 0/3] Allow postponed netfilter handling for socket
 matches
Date: Mon, 21 Sep 2015 18:52:04 +0200
Message-ID: <560035B4.9010504@zonque.org>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
 <20150916212100.GT24810@breakpoint.cc> <55FA902F.50006@zonque.org>
 <20150917160008.GA32700@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108030207020701090800"
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:53115 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932395AbbIUQwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 12:52:09 -0400
In-Reply-To: <20150917160008.GA32700@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070108030207020701090800
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hi,

Thanks for your feedback, Florian!

On 09/17/2015 06:00 PM, Florian Westphal wrote:
> Daniel Mack <daniel@zonque.org> wrote:

>> That would be a new netfilter hook then, something that is called after
>> LOCAL_IN, for ingress only? In a sense, it would be called from the
>> protocol handlers, just as my patches do right now, but instead of
>> conditionally re-iterating the same rules again, we would walk a
>> different chain?
> 
> Yes, something like that.  Obviously, you'll need to dru^W brib^W
> convince a LOT of people before that could ever fly.
> 
> I think we should not do this and that this 'match on ingress sk
> properties' is just bad[tm].
> 
> f.e. you'd also have to move all of the stuff you want into
> sock_common ... 8-(

Hmm, I'm not sure whether I understand which problems you see, or which
corner cases I am missing in my assessment. I did a quick test with the
attached 4 patches that

1) Allow hook callbacks to look at the socket passed to nf_hook(), so
   skb->sk does not have to be set

2) Make nft_meta look at pkt->sk rather that skb->sk (only for cgroups
   as proof of concept)

3) Introduce a new POST_DEMUX netfilter chain (the name is not
   perfect, admittedly)

4) Iterate POST_DEMUX chains for v4 TCP and UDP unicast+multicast
   sockets.


With some really trivial modifications to libnftnl/nftables (which just
map strings to the new enum value), this works fine in my tests.
Multicast receivers that match a netclass ID in the ruleset won't see
any packets, while others do.

Some more considerations: if we cannot determine a socket for a packet
and hence don't deliver it, it's IMO perfectly fine not to run the
netfilter rules for them. All we need to achieve with this chain is that
for packets that _are_ delivered to a socket, all the necessary rules
have been processed, at a time when we know who the final receiver of
the skb is.

I'm happy to discuss the side effects of such an approach.


Thanks,
Daniel

--------------070108030207020701090800
Content-Type: text/x-diff;
 name="0001-netfilter-add-socket-to-struct-nft_pktinfo.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0001-netfilter-add-socket-to-struct-nft_pktinfo.patch"

=46rom 808dacb17308c7a1e00a2e6504cbe6468a25f0d1 Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@zonque.org>
Date: Wed, 16 Sep 2015 14:40:26 +0200
Subject: [PATCH RFC 1/4] netfilter: add socket to struct nft_pktinfo

The high-level netfilter hook API already enables users to pass a socket,=

but that information is lost when the chains are walked.

In order to let internal eval callbacks use the passed filter rather than=

skb->sk, add a pointer of type 'struct sock' to 'struct nft_pktinfo' and
set that field via nft_set_pktinfo().

This allows us to run filter chains from situations where skb->sk is unse=
t.
Fall back to skb->sk in case state->sk is NULL, so filter callbacks can b=
e
written in a generic way.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/net/netfilter/nf_tables.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf=
_tables.h
index aa8bee7..05e97ed 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -13,6 +13,7 @@
 #define NFT_JUMP_STACK_SIZE	16
=20
 struct nft_pktinfo {
+	struct sock			*sk;
 	struct sk_buff			*skb;
 	const struct net_device		*in;
 	const struct net_device		*out;
@@ -29,6 +30,7 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *=
pkt,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
+	pkt->sk =3D state->sk ?: skb->sk;
 	pkt->skb =3D skb;
 	pkt->in =3D pkt->xt.in =3D state->in;
 	pkt->out =3D pkt->xt.out =3D state->out;
--=20
2.5.0


--------------070108030207020701090800
Content-Type: text/x-diff;
 name="0002-netfilter-nft_meta-look-at-pkt-sk-rather-than-skb-sk.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0002-netfilter-nft_meta-look-at-pkt-sk-rather-than-skb-sk.pa";
 filename*1="tch"

=46rom 1ae058eaedc9d20abcfe7c84496bbf1acb979026 Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@zonque.org>
Date: Fri, 18 Sep 2015 16:55:05 +0200
Subject: [PATCH RFC 2/4] netfilter: nft_meta: look at pkt->sk rather than=

 skb->sk

pkt->sk is set to whatever was passed to nh_hook() by the caller,
and for post demux chains, this is the one that should be looked
at, as skb->sk is still NULL at this point in time.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/netfilter/nft_meta.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index cb2f13e..f195bee 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -29,8 +29,9 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		       const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv =3D nft_expr_priv(expr);
-	const struct sk_buff *skb =3D pkt->skb;
 	const struct net_device *in =3D pkt->in, *out =3D pkt->out;
+	struct sk_buff *skb =3D pkt->skb;
+	struct sock *sk =3D pkt->sk;
 	u32 *dest =3D &regs->data[priv->dreg];
=20
 	switch (priv->key) {
@@ -168,9 +169,9 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		break;
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
-		if (skb->sk =3D=3D NULL || !sk_fullsock(skb->sk))
+		if (sk =3D=3D NULL || !sk_fullsock(sk))
 			goto err;
-		*dest =3D skb->sk->sk_classid;
+		*dest =3D sk->sk_classid;
 		break;
 #endif
 	default:
--=20
2.5.0


--------------070108030207020701090800
Content-Type: text/x-diff;
 name="0003-netfilter-add-NF_INET_POST_DEMUX-chain-type.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0003-netfilter-add-NF_INET_POST_DEMUX-chain-type.patch"

=46rom 661e8f5c6e7f48bb03dbf8fcd7cbccb9ffb5cc5d Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@zonque.org>
Date: Fri, 18 Sep 2015 16:39:16 +0200
Subject: [PATCH RFC 3/4] netfilter: add NF_INET_POST_DEMUX chain type

Add a new chain type NF_INET_POST_DEMUX which is ran after the input demu=
x
is complete and the final destination socket (if any) has been determined=
=2E

This helps filtering packets based on information stored in the destinati=
on
socket, such as cgroup controller supplied net class IDs.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/uapi/linux/netfilter.h      | 1 +
 net/ipv4/netfilter/iptable_filter.c | 1 +
 net/ipv4/netfilter/nf_tables_ipv4.c | 4 +++-
 net/netfilter/nf_tables_inet.c      | 3 ++-
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilte=
r.h
index d93f949..d402679 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -49,6 +49,7 @@ enum nf_inet_hooks {
 	NF_INET_FORWARD,
 	NF_INET_LOCAL_OUT,
 	NF_INET_POST_ROUTING,
+	NF_INET_POST_DEMUX,
 	NF_INET_NUMHOOKS
 };
=20
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/ipt=
able_filter.c
index a0f3bec..55b4795 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -21,6 +21,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.=
org>");
 MODULE_DESCRIPTION("iptables filter table");
=20
 #define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_POST_DEMUX) | \
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
=20
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_=
tables_ipv4.c
index aa180d3..993f302 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -55,6 +55,7 @@ struct nft_af_info nft_af_ipv4 __read_mostly =3D {
 		[NF_INET_FORWARD]	=3D nft_do_chain_ipv4,
 		[NF_INET_PRE_ROUTING]	=3D nft_do_chain_ipv4,
 		[NF_INET_POST_ROUTING]	=3D nft_do_chain_ipv4,
+		[NF_INET_POST_DEMUX]	=3D nft_do_chain_ipv4,
 	},
 };
 EXPORT_SYMBOL_GPL(nft_af_ipv4);
@@ -96,7 +97,8 @@ static const struct nf_chain_type filter_ipv4 =3D {
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING),
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_POST_DEMUX),
 };
=20
 static int __init nf_tables_ipv4_init(void)
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_ine=
t.c
index 9dd2d21..c01db78 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -75,7 +75,8 @@ static const struct nf_chain_type filter_inet =3D {
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING),
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_POST_DEMUX),
 };
=20
 static int __init nf_tables_inet_init(void)
--=20
2.5.0


--------------070108030207020701090800
Content-Type: text/x-diff;
 name="0004-net-tcp_ipv4-udp_ipv4-hook-up-post-demux-netfilter-c.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0004-net-tcp_ipv4-udp_ipv4-hook-up-post-demux-netfilter-c.pa";
 filename*1="tch"

=46rom 1898df7d6a35967972bae412994623a8d7c262cd Mon Sep 17 00:00:00 2001
From: Daniel Mack <daniel@zonque.org>
Date: Wed, 16 Sep 2015 14:58:08 +0200
Subject: [PATCH RFC 4/4] net: tcp_ipv4, udp_ipv4: hook up post demux netf=
ilter
 chains

Run the POST_DEMUX netfilter chain rules after the destination socket
has been looked up.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/ipv4/tcp_ipv4.c |  8 ++++++++
 net/ipv4/udp.c      | 15 +++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93898e0..33f968e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -78,6 +78,7 @@
=20
 #include <linux/inet.h>
 #include <linux/ipv6.h>
+#include <linux/netfilter.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -1594,6 +1595,13 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
=20
+	ret =3D nf_hook(NFPROTO_IPV4, NF_INET_POST_DEMUX, sk,
+		      skb, skb->dev, NULL, NULL);
+	if (ret !=3D 1) {
+		sock_put(sk);
+		return 0;
+	}
+
 process:
 	if (sk->sk_state =3D=3D TCP_TIME_WAIT)
 		goto do_time_wait;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7..0056c20 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -97,6 +97,7 @@
 #include <linux/mm.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter.h>
 #include <linux/slab.h>
 #include <net/tcp_states.h>
 #include <linux/skbuff.h>
@@ -1632,7 +1633,14 @@ static void flush_stack(struct sock **stack, unsig=
ned int count,
 	struct sock *sk;
=20
 	for (i =3D 0; i < count; i++) {
+		int ret;
 		sk =3D stack[i];
+
+		ret =3D nf_hook(NFPROTO_IPV4, NF_INET_POST_DEMUX, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret !=3D 1)
+			continue;
+
 		if (likely(!skb1))
 			skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb, GFP_ATOMIC);
=20
@@ -1819,6 +1827,13 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp=
_table *udptable,
 	if (sk) {
 		int ret;
=20
+		ret =3D nf_hook(NFPROTO_IPV4, NF_INET_POST_DEMUX, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret !=3D 1) {
+			sock_put(sk);
+			return 0;
+		}
+
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 inet_compute_pseudo);
--=20
2.5.0


--------------070108030207020701090800--
