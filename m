From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: [PATCH v3] l2tp: fix kernel panic when using IPv4-mapped IPv6 addresses
Date: Wed, 02 Oct 2013 10:16:02 +0200
Message-ID: <524BD642.3020102@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:45263 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752823Ab3JBIXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 04:23:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 mapped addresses cause kernel panic.
The patch juste check whether the IPv6 address is an IPv4 mapped
address. If so, use IPv4 API instead of IPv6.

[  940.026915] general protection fault: 0000 [#1]
[  940.026915] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core pppox=
 ppp_generic slhc loop psmouse
[  940.026915] CPU: 0 PID: 3184 Comm: memcheck-amd64- Not tainted 3.11.=
0+ #1
[  940.026915] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  940.026915] task: ffff880007130e20 ti: ffff88000737e000 task.ti: fff=
f88000737e000
[  940.026915] RIP: 0010:[<ffffffff81333780>]  [<ffffffff81333780>] ip6=
_xmit+0x276/0x326
[  940.026915] RSP: 0018:ffff88000737fd28  EFLAGS: 00010286
[  940.026915] RAX: c748521a75ceff48 RBX: ffff880000c30800 RCX: 0000000=
000000000
[  940.026915] RDX: ffff88000075cc4e RSI: 0000000000000028 RDI: ffff880=
0060e5a40
[  940.026915] RBP: ffff8800060e5a40 R08: 0000000000000000 R09: ffff880=
00075cc90
[  940.026915] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880=
00737fda0
[  940.026915] R13: 0000000000000000 R14: 0000000000002000 R15: ffff880=
005d3b580
[  940.026915] FS:  00007f163dc5e800(0000) GS:ffffffff81623000(0000) kn=
lGS:0000000000000000
[  940.026915] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  940.026915] CR2: 00000004032dc940 CR3: 0000000005c25000 CR4: 0000000=
0000006f0
[  940.026915] Stack:
[  940.026915]  ffff88000075cc4e ffffffff81694e90 ffff880000c30b38 0000=
000000000020
[  940.026915]  11000000523c4bac ffff88000737fdb4 0000000000000000 ffff=
880000c30800
[  940.026915]  ffff880005d3b580 ffff880000c30b38 ffff8800060e5a40 0000=
000000000020
[  940.026915] Call Trace:
[  940.026915]  [<ffffffff81356cc3>] ? inet6_csk_xmit+0xa4/0xc4
[  940.026915]  [<ffffffffa0038535>] ? l2tp_xmit_skb+0x503/0x55a [l2tp_=
core]
[  940.026915]  [<ffffffff812b8d3b>] ? pskb_expand_head+0x161/0x214
[  940.026915]  [<ffffffffa003e91d>] ? pppol2tp_xmit+0xf2/0x143 [l2tp_p=
pp]
[  940.026915]  [<ffffffffa00292e0>] ? ppp_channel_push+0x36/0x8b [ppp_=
generic]
[  940.026915]  [<ffffffffa00293fe>] ? ppp_write+0xaf/0xc5 [ppp_generic=
]
[  940.026915]  [<ffffffff8110ead4>] ? vfs_write+0xa2/0x106
[  940.026915]  [<ffffffff8110edd6>] ? SyS_write+0x56/0x8a
[  940.026915]  [<ffffffff81378ac0>] ? system_call_fastpath+0x16/0x1b
[  940.026915] Code: 00 49 8b 8f d8 00 00 00 66 83 7c 11 02 00 74 60 49
8b 47 58 48 83 e0 fe 48 8b 80 18 01 00 00 48 85 c0 74 13 48 8b 80 78 02
00 00 <48> ff 40 28 41 8b 57 68 48 01 50 30 48 8b 54 24 08 49 c7 c1 51
[  940.026915] RIP  [<ffffffff81333780>] ip6_xmit+0x276/0x326
[  940.026915]  RSP <ffff88000737fd28>
[  940.057945] ---[ end trace be8aba9a61c8b7f3 ]---
[  940.058583] Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
---
v3: add panic message
Sorry for the dumb oversight

 net/l2tp/l2tp_core.c |   27 +++++++++++++++++++++++----
 net/l2tp/l2tp_core.h |    3 +++
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index feae495..aedaa2c 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -496,6 +496,7 @@ out:
 static inline int l2tp_verify_udp_checksum(struct sock *sk,
 					   struct sk_buff *skb)
 {
+	struct l2tp_tunnel *tunnel =3D (struct l2tp_tunnel *)sk->sk_user_data=
;
 	struct udphdr *uh =3D udp_hdr(skb);
 	u16 ulen =3D ntohs(uh->len);
 	__wsum psum;
@@ -504,7 +505,7 @@ static inline int l2tp_verify_udp_checksum(struct s=
ock *sk,
 		return 0;
=20
 #if IS_ENABLED(CONFIG_IPV6)
-	if (sk->sk_family =3D=3D PF_INET6) {
+	if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped) {
 		if (!uh->check) {
 			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
 			return 1;
@@ -1128,7 +1129,7 @@ static int l2tp_xmit_core(struct l2tp_session *se=
ssion, struct sk_buff *skb,
 	/* Queue the packet to IP for output */
 	skb->local_df =3D 1;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (skb->sk->sk_family =3D=3D PF_INET6)
+	if (skb->sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 		error =3D inet6_csk_xmit(skb, NULL);
 	else
 #endif
@@ -1255,7 +1256,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, s=
truct sk_buff *skb, int hdr_len
=20
 		/* Calculate UDP checksum if configured to do so */
 #if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family =3D=3D PF_INET6)
+		if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
 		else
 #endif
@@ -1704,6 +1705,24 @@ int l2tp_tunnel_create(struct net *net, int fd, =
int version, u32 tunnel_id, u32
 	if (cfg !=3D NULL)
 		tunnel->debug =3D cfg->debug;
=20
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family =3D=3D PF_INET6) {
+		struct ipv6_pinfo *np =3D inet6_sk(sk);
+
+		if (ipv6_addr_v4mapped(&np->saddr) &&
+		    ipv6_addr_v4mapped(&np->daddr)) {
+			struct inet_sock *inet =3D inet_sk(sk);
+
+			tunnel->v4mapped =3D true;
+			inet->inet_saddr =3D np->saddr.s6_addr32[3];
+			inet->inet_rcv_saddr =3D np->rcv_saddr.s6_addr32[3];
+			inet->inet_daddr =3D np->daddr.s6_addr32[3];
+		} else {
+			tunnel->v4mapped =3D false;
+		}
+	}
+#endif
+
 	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
 	tunnel->encap =3D encap;
 	if (encap =3D=3D L2TP_ENCAPTYPE_UDP) {
@@ -1712,7 +1731,7 @@ int l2tp_tunnel_create(struct net *net, int fd, i=
nt version, u32 tunnel_id, u32
 		udp_sk(sk)->encap_rcv =3D l2tp_udp_encap_recv;
 		udp_sk(sk)->encap_destroy =3D l2tp_udp_encap_destroy;
 #if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family =3D=3D PF_INET6)
+		if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 			udpv6_encap_enable();
 		else
 #endif
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 66a559b..6f251cb 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -194,6 +194,9 @@ struct l2tp_tunnel {
 	struct sock		*sock;		/* Parent socket */
 	int			fd;		/* Parent fd, if tunnel socket
 						 * was created by userspace */
+#if IS_ENABLED(CONFIG_IPV6)
+	bool			v4mapped;
+#endif
=20
 	struct work_struct	del_work;
=20
--=20
1.7.10.4
