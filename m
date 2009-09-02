From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 02 Sep 2009 16:43:38 +0200
Message-ID: <4A9E849A.30105@gmail.com>
References: <4A98132C.8090105@gmail.com>	<20090828.233858.256193304.davem@davemloft.net>	<4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39428 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbZIBOnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:43:49 -0400
In-Reply-To: <20090901.184121.06750444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 31 Aug 2009 14:09:50 +0200
>=20
>> Re-reading again this stuff, I realized ip6_push_pending_frames()
>> was not updating IPSTATS_MIB_OUTDISCARDS, even if IP_RECVERR was set=
=2E
>>
>> May I suggest following path :
>>
>> 1) Correct ip6_push_pending_frames() to properly
>> account for dropped-by-qdisc frames when IP_RECVERR is set
>=20
> Your patch is  applied to net-next-2.6, thanks!
>=20
>> 2) Submit a patch to account for qdisc-dropped frames in SNMP counte=
rs
>> but still return a OK to user application, to not break them ?
>=20
> Sounds good.
>=20
> I think if you sample random UDP applications, you will find that suc=
h
> errors will upset them terribly, make them log tons of crap to
> /var/log/messages et al., and consume tons of CPU.
>=20
> And in such cases silent ignoring of drops is entirely appropriate an=
d
> optimal, which supports our current behavior.
>=20
> If we are to make such applications "more sophisticated" such
> converted apps can be indicated simply their use of IP_RECVERR.
>=20
> If you want to be notified of all asynchronous errors we can detect,
> you use this, end of story.  It is the only way to handle this
> situation without breaking the world.
>=20
> As usual, Alexey Kuznetsov's analysis of this situation is timeless,
> accurate, and wise.  And he understood all of this 10+ years ago.

Thanks David, here is the 2nd patch then :


[PATCH net-next-2.6] ip: Report qdisc packet drops

Christoph Lameter pointed out that packet drops at qdisc level where no=
t
accounted in SNMP counters. Only if application sets IP_RECVERR, drops
are reported to user (-ENOBUFS errors) and SNMP counters updated.

IP_RECVERR is used to enable extended reliable error message passing,
but these are not needed to update system wide SNMP stats.

This patch changes things a bit to allow SNMP counters to be updated,
regardless of IP_RECVERR being set or not on the socket.

Example after an UDP tx flood
# netstat -s=20
=2E..
IP:
    1487048 outgoing packets dropped
=2E..
Udp:
=2E..
    SndbufErrors: 1487048


send() syscalls, do however still return an OK status, to not
break applications.

Note : send() manual page explicitly says for -ENOBUFS error :

 "The output queue for a network interface was full.
  This generally indicates that the interface has stopped sending,
  but may be caused by transient congestion.
  (Normally, this does not occur in Linux. Packets are just silently
  dropped when a device queue overflows.) "

This is not true for IP_RECVERR enabled sockets : a send() syscall
that hit a qdisc drop returns an ENOBUFS error.

Many thanks to Christoph, David, and last but not least, Alexey !

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h      |    2 +-
 include/net/ipv6.h    |    2 +-
 include/net/udp.h     |    2 +-
 net/ipv4/icmp.c       |    2 +-
 net/ipv4/ip_output.c  |   19 ++++++++++---------
 net/ipv4/raw.c        |   14 ++++++++++----
 net/ipv4/udp.c        |   20 +++++++++++++-------
 net/ipv6/icmp.c       |    2 +-
 net/ipv6/ip6_output.c |   18 +++++++++++-------
 net/ipv6/raw.c        |   15 ++++++++++-----
 net/ipv6/udp.c        |   14 ++++++++++----
 11 files changed, 69 insertions(+), 41 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 72c3692..9dd19a8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -116,7 +116,7 @@ extern int		ip_append_data(struct sock *sk,
 extern int		ip_generic_getfrag(void *from, char *to, int offset, int l=
en, int odd, struct sk_buff *skb);
 extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
 				int offset, size_t size, int flags);
-extern int		ip_push_pending_frames(struct sock *sk);
+extern int		ip_push_pending_frames(struct sock *sk, int recverr);
 extern void		ip_flush_pending_frames(struct sock *sk);
=20
 /* datagram.c */
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ad9a511..f514257 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -498,7 +498,7 @@ extern int			ip6_append_data(struct sock *sk,
 						struct rt6_info *rt,
 						unsigned int flags);
=20
-extern int			ip6_push_pending_frames(struct sock *sk);
+extern int			ip6_push_pending_frames(struct sock *sk, int recverr);
=20
 extern void			ip6_flush_pending_frames(struct sock *sk);
=20
diff --git a/include/net/udp.h b/include/net/udp.h
index 5fb029f..a60ef10 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -145,7 +145,7 @@ extern int 	udp_lib_getsockopt(struct sock *sk, int=
 level, int optname,
 			           char __user *optval, int __user *optlen);
 extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname=
,
 				   char __user *optval, int optlen,
-				   int (*push_pending_frames)(struct sock *));
+				   int (*push_pending_frames)(struct sock *, int));
=20
 extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __b=
e16 sport,
 				    __be32 daddr, __be16 dport,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 97c410e..f46a53c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -345,7 +345,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_p=
aram,
 						 icmp_param->head_len, csum);
 		icmph->checksum =3D csum_fold(csum);
 		skb->ip_summed =3D CHECKSUM_NONE;
-		ip_push_pending_frames(sk);
+		ip_push_pending_frames(sk, 0);
 	}
 }
=20
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d08210..8f81dab 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1216,7 +1216,7 @@ static void ip_cork_release(struct inet_sock *ine=
t)
  *	Combined all pending IP fragments on the socket as one IP datagram
  *	and push them out.
  */
-int ip_push_pending_frames(struct sock *sk)
+int ip_push_pending_frames(struct sock *sk, int recverr)
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
@@ -1301,19 +1301,20 @@ int ip_push_pending_frames(struct sock *sk)
 	/* Netfilter gets whole the not fragmented skb. */
 	err =3D ip_local_out(skb);
 	if (err) {
-		if (err > 0)
-			err =3D inet->recverr ? net_xmit_errno(err) : 0;
+		if (err > 0) {
+			err =3D net_xmit_errno(err);
+			if (err && !recverr) {
+				IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+				err =3D 0;
+			}
+		}
 		if (err)
-			goto error;
+			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 	}
=20
 out:
 	ip_cork_release(inet);
 	return err;
-
-error:
-	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
 }
=20
 /*
@@ -1412,7 +1413,7 @@ void ip_send_reply(struct sock *sk, struct sk_buf=
f *skb, struct ip_reply_arg *ar
 			  arg->csumoffset) =3D csum_fold(csum_add(skb->csum,
 								arg->csum));
 		skb->ip_summed =3D CHECKSUM_NONE;
-		ip_push_pending_frames(sk);
+		ip_push_pending_frames(sk, 0);
 	}
=20
 	bh_unlock_sock(sk);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2979f14..444c465 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -374,8 +374,13 @@ static int raw_send_hdrinc(struct sock *sk, void *=
from, size_t length,
=20
 	err =3D NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
-	if (err > 0)
-		err =3D inet->recverr ? net_xmit_errno(err) : 0;
+	if (err > 0) {
+		err =3D net_xmit_errno(err);
+		if (!inet->recverr && err) {
+			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+			err =3D 0;
+		}
+	}
 	if (err)
 		goto error;
 out:
@@ -576,8 +581,9 @@ back_from_confirm:
 					&ipc, &rt, msg->msg_flags);
 		if (err)
 			ip_flush_pending_frames(sk);
-		else if (!(msg->msg_flags & MSG_MORE))
-			err =3D ip_push_pending_frames(sk);
+		else if (!(msg->msg_flags & MSG_MORE)) {
+			err =3D ip_push_pending_frames(sk, inet->recverr);
+		}
 		release_sock(sk);
 	}
 done:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 29ebb0d..6a6bf1d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -513,7 +513,7 @@ static void udp4_hwcsum_outgoing(struct sock *sk, s=
truct sk_buff *skb,
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
-static int udp_push_pending_frames(struct sock *sk)
+static int udp_push_pending_frames(struct sock *sk, int recverr)
 {
 	struct udp_sock  *up =3D udp_sk(sk);
 	struct inet_sock *inet =3D inet_sk(sk);
@@ -560,7 +560,7 @@ static int udp_push_pending_frames(struct sock *sk)
 		uh->check =3D CSUM_MANGLED_0;
=20
 send:
-	err =3D ip_push_pending_frames(sk);
+	err =3D ip_push_pending_frames(sk, recverr);
 out:
 	up->len =3D 0;
 	up->pending =3D 0;
@@ -752,8 +752,14 @@ do_append_data:
 			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_flush_pending_frames(sk);
-	else if (!corkreq)
-		err =3D udp_push_pending_frames(sk);
+	else if (!corkreq) {
+		err =3D udp_push_pending_frames(sk, 1);
+		if (err =3D=3D -ENOBUFS && !inet->recverr) {
+			UDP_INC_STATS_USER(sock_net(sk),
+					   UDP_MIB_SNDBUFERRORS, is_udplite);
+			err =3D 0;
+		}
+	}
 	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
 		up->pending =3D 0;
 	release_sock(sk);
@@ -826,7 +832,7 @@ int udp_sendpage(struct sock *sk, struct page *page=
, int offset,
=20
 	up->len +=3D size;
 	if (!(up->corkflag || (flags&MSG_MORE)))
-		ret =3D udp_push_pending_frames(sk);
+		ret =3D udp_push_pending_frames(sk, inet_sk(sk)->recverr);
 	if (!ret)
 		ret =3D size;
 out:
@@ -1354,7 +1360,7 @@ void udp_destroy_sock(struct sock *sk)
  */
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, int optlen,
-		       int (*push_pending_frames)(struct sock *))
+		       int (*push_pending_frames)(struct sock *, int))
 {
 	struct udp_sock *up =3D udp_sk(sk);
 	int val;
@@ -1374,7 +1380,7 @@ int udp_lib_setsockopt(struct sock *sk, int level=
, int optname,
 		} else {
 			up->corkflag =3D 0;
 			lock_sock(sk);
-			(*push_pending_frames)(sk);
+			(*push_pending_frames)(sk, 0);
 			release_sock(sk);
 		}
 		break;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index e2325f6..a9c54c2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -253,7 +253,7 @@ static int icmpv6_push_pending_frames(struct sock *=
sk, struct flowi *fl, struct
 						      len, fl->proto,
 						      tmp_csum);
 	}
-	ip6_push_pending_frames(sk);
+	ip6_push_pending_frames(sk, 0);
 out:
 	return err;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a931229..ade5707 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1440,7 +1440,7 @@ static void ip6_cork_release(struct inet_sock *in=
et, struct ipv6_pinfo *np)
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 }
=20
-int ip6_push_pending_frames(struct sock *sk)
+int ip6_push_pending_frames(struct sock *sk, int recverr)
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
@@ -1510,18 +1510,22 @@ int ip6_push_pending_frames(struct sock *sk)
=20
 	err =3D ip6_local_out(skb);
 	if (err) {
-		if (err > 0)
-			err =3D np->recverr ? net_xmit_errno(err) : 0;
+		if (err > 0) {
+			err =3D net_xmit_errno(err);
+			if (err && !recverr) {
+				IP6_INC_STATS(net, rt->rt6i_idev,
+					      IPSTATS_MIB_OUTDISCARDS);
+				err =3D 0;
+			}
+		}
 		if (err)
-			goto error;
+			IP6_INC_STATS(net, rt->rt6i_idev,
+				      IPSTATS_MIB_OUTDISCARDS);
 	}
=20
 out:
 	ip6_cork_release(inet, np);
 	return err;
-error:
-	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
 }
=20
 void ip6_flush_pending_frames(struct sock *sk)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5068410..d054fa2 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -523,7 +523,7 @@ csum_copy_err:
 }
=20
 static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl=
,
-				     struct raw6_sock *rp)
+				     struct raw6_sock *rp, int recverr)
 {
 	struct sk_buff *skb;
 	int err =3D 0;
@@ -595,7 +595,7 @@ static int rawv6_push_pending_frames(struct sock *s=
k, struct flowi *fl,
 		BUG();
=20
 send:
-	err =3D ip6_push_pending_frames(sk);
+	err =3D ip6_push_pending_frames(sk, recverr);
 out:
 	return err;
 }
@@ -641,8 +641,13 @@ static int rawv6_send_hdrinc(struct sock *sk, void=
 *from, int length,
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->l=
en);
 	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev=
,
 		      dst_output);
-	if (err > 0)
-		err =3D np->recverr ? net_xmit_errno(err) : 0;
+	if (err > 0) {
+		err =3D net_xmit_errno(err);
+		if (!np->recverr && err) {
+			IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS)=
;
+			err =3D 0;
+		}
+	}
 	if (err)
 		goto error;
 out:
@@ -895,7 +900,7 @@ back_from_confirm:
 		if (err)
 			ip6_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE))
-			err =3D rawv6_push_pending_frames(sk, &fl, rp);
+			err =3D rawv6_push_pending_frames(sk, &fl, rp, np->recverr);
 		release_sock(sk);
 	}
 done:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 20d2ffc..963dd0a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -683,7 +683,7 @@ static void udp6_hwcsum_outgoing(struct sock *sk, s=
truct sk_buff *skb,
  *	Sending
  */
=20
-static int udp_v6_push_pending_frames(struct sock *sk)
+static int udp_v6_push_pending_frames(struct sock *sk, int recverr)
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
@@ -723,7 +723,7 @@ static int udp_v6_push_pending_frames(struct sock *=
sk)
 		uh->check =3D CSUM_MANGLED_0;
=20
 send:
-	err =3D ip6_push_pending_frames(sk);
+	err =3D ip6_push_pending_frames(sk, recverr);
 out:
 	up->len =3D 0;
 	up->pending =3D 0;
@@ -975,8 +975,14 @@ do_append_data:
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
-	else if (!corkreq)
-		err =3D udp_v6_push_pending_frames(sk);
+	else if (!corkreq) {
+		err =3D udp_v6_push_pending_frames(sk, 1);
+		if (err =3D=3D -ENOBUFS && !np->recverr) {
+			UDP6_INC_STATS_USER(sock_net(sk),
+					   UDP_MIB_SNDBUFERRORS, is_udplite);
+			err =3D 0;
+		}
+	}
 	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
 		up->pending =3D 0;
=20
