From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: [PATCH net-2.6.23 take 3] Per-datagram TTL and TOS via sendmsg()
Date: Sun, 8 Jul 2007 11:13:09 +0300
Message-ID: <200707081113.10203@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:3711 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbXGHINN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 04:13:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Hmm, stupid me. Right this time. Sorry for the line noise.]

This patch adds support for specifying IPv4 Time-To-Live (IP_TTL) and/o=
r=20
Type-Of-Service (IP_TOS) values on a per datagram basis through=20
sendmsg() ancilliary data. Until then, it only worked for IPv6 sockets=20
(using IPV6_HOPLIMIT and IPV6_TCLASS).

Signed-off-by: R=C3=A9mi Denis-Courmont <rdenis@simphalempin.com>

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 62daf21..7a6dc33 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -140,6 +140,8 @@ struct inet_sock {
 		int			length; /* Total length of all frames */
 		__be32			addr;
 		struct flowi		fl;
+		__s16			ttl;
+		__s16			tos;
 	} cork;
 };
=20
diff --git a/include/net/ip.h b/include/net/ip.h
index abf2820..dcfdb41 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -54,6 +54,8 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	__s16			ttl;
+	__s16			tos;
 };
=20
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 02a899b..e10852d 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -392,8 +392,9 @@ static void icmp_reply(struct icmp_bxm *icmp_param,=
 struct sk_buff *skb)
 	icmp_param->data.icmph.checksum =3D 0;
 	icmp_out_count(icmp_param->data.icmph.type);
=20
-	inet->tos =3D ip_hdr(skb)->tos;
 	daddr =3D ipc.addr =3D rt->rt_src;
+	ipc.tos =3D ip_hdr(skb)->tos;
+	ipc.ttl =3D MULTICAST(daddr) ? inet->mc_ttl : inet->uc_ttl;
 	ipc.opt =3D NULL;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt =3D &icmp_param->replyopts;
@@ -438,7 +439,6 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 	struct rtable *rt =3D (struct rtable *)skb_in->dst;
 	struct ipcm_cookie ipc;
 	__be32 saddr;
-	u8  tos;
=20
 	if (!rt)
 		goto out;
@@ -526,9 +526,9 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 			saddr =3D 0;
 	}
=20
-	tos =3D icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
-					   IPTOS_PREC_INTERNETCONTROL) :
-					  iph->tos;
+	ipc.tos =3D icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) =
|
+					       IPTOS_PREC_INTERNETCONTROL) :
+					      iph->tos;
=20
 	if (ip_options_echo(&icmp_param.replyopts, skb_in))
 		goto out_unlock;
@@ -545,7 +545,7 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 	icmp_param.skb	  =3D skb_in;
 	icmp_param.offset =3D skb_network_offset(skb_in);
 	icmp_out_count(icmp_param.data.icmph.type);
-	inet_sk(icmp_socket->sk)->tos =3D tos;
+	ipc.ttl =3D -1;
 	ipc.addr =3D iph->saddr;
 	ipc.opt =3D &icmp_param.replyopts;
=20
@@ -557,7 +557,7 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 						icmp_param.replyopts.faddr :
 						iph->saddr,
 					.saddr =3D saddr,
-					.tos =3D RT_TOS(tos)
+					.tos =3D RT_TOS(ipc.tos)
 				}
 			},
 			.proto =3D IPPROTO_ICMP,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 34ea454..67ce657 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -806,6 +806,8 @@ int ip_append_data(struct sock *sk,
 					    dst_mtu(rt->u.dst.path);
 		inet->cork.rt =3D rt;
 		inet->cork.length =3D 0;
+		inet->cork.ttl =3D ipc->ttl;
+		inet->cork.tos =3D ipc->tos;
 		sk->sk_sndmsg_page =3D NULL;
 		sk->sk_sndmsg_off =3D 0;
 		if ((exthdrlen =3D rt->u.dst.header_len) !=3D 0) {
@@ -1233,7 +1235,9 @@ int ip_push_pending_frames(struct sock *sk)
 	if (inet->cork.flags & IPCORK_OPT)
 		opt =3D inet->cork.opt;
=20
-	if (rt->rt_type =3D=3D RTN_MULTICAST)
+	if (inet->cork.ttl !=3D -1)
+		ttl =3D inet->cork.ttl;
+	else if (rt->rt_type =3D=3D RTN_MULTICAST)
 		ttl =3D inet->mc_ttl;
 	else
 		ttl =3D ip_select_ttl(inet, &rt->u.dst);
@@ -1245,7 +1249,7 @@ int ip_push_pending_frames(struct sock *sk)
 		iph->ihl +=3D opt->optlen>>2;
 		ip_options_build(skb, opt, inet->cork.addr, rt, 0);
 	}
-	iph->tos =3D inet->tos;
+	iph->tos =3D (inet->cork.tos !=3D -1) ? inet->cork.tos : inet->tos;
 	iph->tot_len =3D htons(skb->len);
 	iph->frag_off =3D df;
 	ip_select_ident(iph, &rt->u.dst, sk);
@@ -1343,6 +1347,8 @@ void ip_send_reply(struct sock *sk, struct sk_buf=
f *skb, struct ip_reply_arg *ar
=20
 	daddr =3D ipc.addr =3D rt->rt_src;
 	ipc.opt =3D NULL;
+	ipc.tos =3D ip_hdr(skb)->tos;
+	ipc.ttl =3D inet->uc_ttl;
=20
 	if (replyopts.opt.optlen) {
 		ipc.opt =3D &replyopts.opt;
@@ -1374,7 +1380,6 @@ void ip_send_reply(struct sock *sk, struct sk_buf=
f *skb, struct ip_reply_arg *ar
 	   with locally disabled BH and that sk cannot be already spinlocked.
 	 */
 	bh_lock_sock(sk);
-	inet->tos =3D ip_hdr(skb)->tos;
 	sk->sk_priority =3D skb->priority;
 	sk->sk_protocol =3D ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if =3D arg->bound_dev_if;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 4d54457..02c47ff 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -190,6 +190,16 @@ int ip_cmsg_send(struct msghdr *msg, struct ipcm_c=
ookie *ipc)
 			ipc->addr =3D info->ipi_spec_dst.s_addr;
 			break;
 		}
+		case IP_TTL:
+			if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(int)))
+				return -EINVAL;
+			ipc->ttl =3D *(int *)CMSG_DATA(cmsg);
+			break;
+		case IP_TOS:
+			if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(int)))
+				return -EINVAL;
+			ipc->tos =3D *(int *)CMSG_DATA(cmsg);
+			break;
 		default:
 			return -EINVAL;
 		}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 24d7c9f..035bb37 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -436,6 +436,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct s=
ock *sk, struct msghdr *msg,
 	ipc.addr =3D inet->saddr;
 	ipc.opt =3D NULL;
 	ipc.oif =3D sk->sk_bound_dev_if;
+	ipc.ttl =3D MULTICAST(daddr) ? inet->mc_ttl : inet->uc_ttl;
+	ipc.tos =3D inet->tos;
=20
 	if (msg->msg_controllen) {
 		err =3D ip_cmsg_send(msg, &ipc);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index facb7e2..d7d6a02 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -581,6 +581,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 	}
 	ipc.addr =3D inet->saddr;
=20
+	ipc.ttl =3D MULTICAST(daddr) ? inet->mc_ttl : inet->uc_ttl;
+	ipc.tos =3D inet->tos;
 	ipc.oif =3D sk->sk_bound_dev_if;
 	if (msg->msg_controllen) {
 		err =3D ip_cmsg_send(msg, &ipc);


--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
