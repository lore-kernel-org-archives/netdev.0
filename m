From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: fix dst races with multicast early demux
Date: Sat, 01 Aug 2015 12:14:33 +0200
Message-ID: <1438424073.2748.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
	 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
	 <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexgartrell@gmail.com" <alexgartrell@gmail.com>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>
To: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36360 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbHAKOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 06:14:37 -0400
Received: by wicgj17 with SMTP id gj17so46745616wic.1
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2015 03:14:36 -0700 (PDT)
In-Reply-To: <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Multicast dst are not cached. They carry DST_NOCACHE.

As mentioned in commit f8864972126899 ("ipv4: fix dst race in
sk_dst_get()"), these dst need special care before caching them
into a socket.

Caching them is allowed only if their refcnt was not 0, ie we
must use atomic_inc_not_zero()

Also, we must use READ_ONCE() to fetch sk->sk_rx_dst, as mentioned
in commit d0c294c53a771 ("tcp: prevent fetching dst twice in early demu=
x
code")

=46ixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Reported-by: Alex Gartrell <agartrell@fb.com>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
---
David : I will be on vacation for following 7 days, no internet access.
Please wait for tests done by Gregory & Alex before merging this ?
Thanks !

 net/ipv4/udp.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604f9273..1b8c5ba7d5f7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1995,12 +1995,19 @@ void udp_v4_early_demux(struct sk_buff *skb)
=20
 	skb->sk =3D sk;
 	skb->destructor =3D sock_efree;
-	dst =3D sk->sk_rx_dst;
+	dst =3D READ_ONCE(sk->sk_rx_dst);
=20
 	if (dst)
 		dst =3D dst_check(dst, 0);
-	if (dst)
-		skb_dst_set_noref(skb, dst);
+	if (dst) {
+		/* DST_NOCACHE can not be used without taking a reference */
+		if (dst->flags & DST_NOCACHE) {
+			if (likely(atomic_inc_not_zero(&dst->__refcnt)))
+				skb_dst_set(skb, dst);
+		} else {
+			skb_dst_set_noref(skb, dst);
+		}
+	}
 }
=20
 int udp_rcv(struct sk_buff *skb)
