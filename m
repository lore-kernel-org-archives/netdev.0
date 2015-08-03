From: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Subject: RE: [PATCH net] udp: fix dst races with multicast early demux
Date: Mon, 3 Aug 2015 22:43:52 +0000
Message-ID: <1fa79ac335ff41f28709f1c794948a3c@svr-chch-ex1.atlnz.lc>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
	 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
	 <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>,<1438424073.2748.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexgartrell@gmail.com" <alexgartrell@gmail.com>,
	=?iso-8859-2?Q?Michal_Kube=E8ek?= <mkubecek@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:33730 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbbHCWoA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 18:44:00 -0400
In-Reply-To: <1438424073.2748.28.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-NZ
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have included this patch into my code and re-run our tests overnight,=
 out of 644 iterations we did not see the kernel crash. Previous reprod=
uction rate we would have expected 4-6 crashes in this time.

So I think this fixes the issue we are seeing.

Thanks,
Greg

________________________________________
=46rom: netdev-owner@vger.kernel.org <netdev-owner@vger.kernel.org> on =
behalf of Eric Dumazet <eric.dumazet@gmail.com>
Sent: Saturday, 1 August 2015 10:14 p.m.
To: Gregory Hoggarth
Cc: Shawn Bohrer; netdev@vger.kernel.org; alexgartrell@gmail.com; Micha=
l Kube=E8ek
Subject: [PATCH net] udp: fix dst races with multicast early demux

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
Cc: Michal Kube=E8ek <mkubecek@suse.cz>
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

        skb->sk =3D sk;
        skb->destructor =3D sock_efree;
-       dst =3D sk->sk_rx_dst;
+       dst =3D READ_ONCE(sk->sk_rx_dst);

        if (dst)
                dst =3D dst_check(dst, 0);
-       if (dst)
-               skb_dst_set_noref(skb, dst);
+       if (dst) {
+               /* DST_NOCACHE can not be used without taking a referen=
ce */
+               if (dst->flags & DST_NOCACHE) {
+                       if (likely(atomic_inc_not_zero(&dst->__refcnt))=
)
+                               skb_dst_set(skb, dst);
+               } else {
+                       skb_dst_set_noref(skb, dst);
+               }
+       }
 }

 int udp_rcv(struct sk_buff *skb)


