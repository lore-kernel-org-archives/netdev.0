From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Fri, 28 Aug 2009 19:26:04 +0200
Message-ID: <4A98132C.8090105@gmail.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>  <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908271139450.14277@gentwo.org> <alpine.DEB.1.10.0908271621260.28029@gentwo.org> <alpine.DEB.1.10.0908280948320.3747@gentwo.org> <4A97F2B4.7030900@gmail.com> <alpine.DEB.1.10.0908281211150.7317@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, Michael Kerrisk <mtk.manpages@gmail.com>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58449 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbZH1R0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 13:26:16 -0400
In-Reply-To: <alpine.DEB.1.10.0908281211150.7317@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Fri, 28 Aug 2009, Eric Dumazet wrote:
>> Only change you want is eventually to account for the UDP drop (Sndb=
ufErrors).
>=20
> That is only a counter at the UDP layer. That one does not allow you =
to
> identify which NIC it was nor which application caused it.

We dont have per-application SNMP counters, so application is responsib=
le
to get proper syscall return check logic / accounting if necessary.

NIC level, just forget it, it makes no sense.

>=20
> But its already a big improvement to see TX drops at all. Could we ge=
t
> your latest patch merged soon?

I officially submit it, but David have to take it or reject it :)

Thanks

[PATCH] ip: Report qdisc packet drops

Christoph Lameter pointed out that packet drops at qdisc level where no=
t
accounted in SNMP counters. Only if application sets IP_RECVERR, drops
are reported to user and SNMP counters updated.

IP_RECVERR is used to enable extended reliable error message passing.
In case of tx drops at qdisc level, no error packet will be generated.
It seems un-necessary to hide the qdisc drops for non IP_RECVERR enable=
d
sockets (as probably most sockets are)

By removing the check of IP_RECVERR enabled sockets in ip_push_pending_=
frames()/
raw_send_hdrinc() / ip6_push_pending_frames() / rawv6_send_hdrinc(),
we can properly update IPSTATS_MIB_OUTDISCARDS, and in case of UDP, upd=
ate
UDP_MIB_SNDBUFERRORS SNMP counters.

Application send() syscalls, instead of returning an OK status (thus ly=
ing),
will return -ENOBUFS error.

Note : send() manual page explicitly says for -ENOBUFS error :

 "The output queue for a network interface was full.
  This generally indicates that the interface has stopped sending,
  but may be caused by transient congestion.
  (Normally, this does not occur in Linux. Packets are just silently
  dropped when a device queue overflows.) "

This was not true for IP_RECVERR enabled sockets for < 2.6.32 linuxes,
and starting from linux 2.6.32, last part wont be true at all.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
---
 net/ipv4/ip_output.c  |    2 +-
 net/ipv4/raw.c        |    2 +-
 net/ipv6/ip6_output.c |    2 +-
 net/ipv6/raw.c        |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

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
index 2979f14..80ff607 100644
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
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6ad5aad..537e8cf 100644
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
index 5068410..1f7ee61 100644
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
