From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Thu, 03 Sep 2009 00:26:27 +0200
Message-ID: <4A9EF113.9030102@gmail.com>
References: <4A98132C.8090105@gmail.com>	<20090828.233858.256193304.davem@davemloft.net>	<4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net> <4A9E849A.30105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39160 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbZIBW0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 18:26:36 -0400
In-Reply-To: <4A9E849A.30105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 31 Aug 2009 14:09:50 +0200
>>
>>> Re-reading again this stuff, I realized ip6_push_pending_frames()
>>> was not updating IPSTATS_MIB_OUTDISCARDS, even if IP_RECVERR was se=
t.
>>>
>>> May I suggest following path :
>>>
>>> 1) Correct ip6_push_pending_frames() to properly
>>> account for dropped-by-qdisc frames when IP_RECVERR is set
>> Your patch is  applied to net-next-2.6, thanks!
>>
>>> 2) Submit a patch to account for qdisc-dropped frames in SNMP count=
ers
>>> but still return a OK to user application, to not break them ?
>> Sounds good.
>>
>> I think if you sample random UDP applications, you will find that su=
ch
>> errors will upset them terribly, make them log tons of crap to
>> /var/log/messages et al., and consume tons of CPU.
>>
>> And in such cases silent ignoring of drops is entirely appropriate a=
nd
>> optimal, which supports our current behavior.
>>
>> If we are to make such applications "more sophisticated" such
>> converted apps can be indicated simply their use of IP_RECVERR.
>>
>> If you want to be notified of all asynchronous errors we can detect,
>> you use this, end of story.  It is the only way to handle this
>> situation without breaking the world.
>>
>> As usual, Alexey Kuznetsov's analysis of this situation is timeless,
>> accurate, and wise.  And he understood all of this 10+ years ago.
>=20
> Thanks David, here is the 2nd patch then :

Here is an updated version of the patch, after Christoph comments.



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
 net/ipv4/ip_output.c  |    2 +-
 net/ipv4/raw.c        |    9 +++++++--
 net/ipv4/udp.c        |   12 +++++++++---
 net/ipv6/ip6_output.c |    2 +-
 net/ipv6/raw.c        |    4 +++-
 net/ipv6/udp.c        |   12 +++++++++---
 6 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d08210..afae0cb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1302,7 +1302,7 @@ int ip_push_pending_frames(struct sock *sk)
 	err =3D ip_local_out(skb);
 	if (err) {
 		if (err > 0)
-			err =3D inet->recverr ? net_xmit_errno(err) : 0;
+			err =3D net_xmit_errno(err);
 		if (err)
 			goto error;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2979f14..ebb1e58 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -375,7 +375,7 @@ static int raw_send_hdrinc(struct sock *sk, void *f=
rom, size_t length,
 	err =3D NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
-		err =3D inet->recverr ? net_xmit_errno(err) : 0;
+		err =3D net_xmit_errno(err);
 	if (err)
 		goto error;
 out:
@@ -386,6 +386,8 @@ error_fault:
 	kfree_skb(skb);
 error:
 	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+	if (err =3D=3D -ENOBUFS && !inet->recverr)
+		err =3D 0;
 	return err;
 }
=20
@@ -576,8 +578,11 @@ back_from_confirm:
 					&ipc, &rt, msg->msg_flags);
 		if (err)
 			ip_flush_pending_frames(sk);
-		else if (!(msg->msg_flags & MSG_MORE))
+		else if (!(msg->msg_flags & MSG_MORE)) {
 			err =3D ip_push_pending_frames(sk);
+			if (err =3D=3D -ENOBUFS && !inet->recverr)
+				err =3D 0;
+		}
 		release_sock(sk);
 	}
 done:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 29ebb0d..ebaaa7f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -561,12 +561,18 @@ static int udp_push_pending_frames(struct sock *s=
k)
=20
 send:
 	err =3D ip_push_pending_frames(sk);
+	if (err) {
+		if (err =3D=3D -ENOBUFS && !inet->recverr) {
+			UDP_INC_STATS_USER(sock_net(sk),
+					   UDP_MIB_SNDBUFERRORS, is_udplite);
+			err =3D 0;
+		}
+	} else
+		UDP_INC_STATS_USER(sock_net(sk),
+				   UDP_MIB_OUTDATAGRAMS, is_udplite);
 out:
 	up->len =3D 0;
 	up->pending =3D 0;
-	if (!err)
-		UDP_INC_STATS_USER(sock_net(sk),
-				UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
=20
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a931229..cd48801 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1511,7 +1511,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	err =3D ip6_local_out(skb);
 	if (err) {
 		if (err > 0)
-			err =3D np->recverr ? net_xmit_errno(err) : 0;
+			err =3D net_xmit_errno(err);
 		if (err)
 			goto error;
 	}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5068410..7d675b8 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -642,7 +642,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void =
*from, int length,
 	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev=
,
 		      dst_output);
 	if (err > 0)
-		err =3D np->recverr ? net_xmit_errno(err) : 0;
+		err =3D net_xmit_errno(err);
 	if (err)
 		goto error;
 out:
@@ -653,6 +653,8 @@ error_fault:
 	kfree_skb(skb);
 error:
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
+	if (err =3D=3D -ENOBUFS && !np->recverr)
+		err =3D 0;
 	return err;
 }
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 20d2ffc..1640406 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -724,12 +724,18 @@ static int udp_v6_push_pending_frames(struct sock=
 *sk)
=20
 send:
 	err =3D ip6_push_pending_frames(sk);
+	if (err) {
+		if (err =3D=3D -ENOBUFS && !inet6_sk(sk)->recverr) {
+			UDP6_INC_STATS_USER(sock_net(sk),
+					    UDP_MIB_SNDBUFERRORS, is_udplite);
+			err =3D 0;
+		}
+	} else
+		UDP6_INC_STATS_USER(sock_net(sk),
+				    UDP_MIB_OUTDATAGRAMS, is_udplite);
 out:
 	up->len =3D 0;
 	up->pending =3D 0;
-	if (!err)
-		UDP6_INC_STATS_USER(sock_net(sk),
-				UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
=20
