From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Sat, 17 Apr 2010 18:10:33 +0200
Message-ID: <1271520633.16881.4754.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
	 <1271443994.16881.4249.camel@edumazet-laptop>
	 <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
	 <1271452358.16881.4486.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:40561 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab0DQQKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 12:10:41 -0400
Received: by bwz25 with SMTP id 25so4090647bwz.28
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 09:10:40 -0700 (PDT)
In-Reply-To: <1271452358.16881.4486.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 23:12 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le vendredi 16 avril 2010 =C3=A0 13:42 -0700, Tom Herbert a =C3=A9cri=
t :
> > On Fri, Apr 16, 2010 at 11:53 AM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> > > Le vendredi 16 avril 2010 =C3=A0 11:35 -0700, Tom Herbert a =C3=A9=
crit :
> > >> Results with "tbench 16" on an 8 core Intel machine.
> > >>
> > >> No RPS/RFS:  2155 MB/sec
> > >> RPS (0ff mask): 1700 MB/sec
> > >> RFS: 1097
> > >>
> >=20
> > Blah, I mistakingly reported that... should have been:
> >=20
> > No RPS/RFS:  2155 MB/sec
> > RPS (0ff mask): 1097 MB/sec
> > RFS: 1700 MB/sec
> >=20
> > Sorry about that!
>=20
> > This was my expectation too, and what my "corrected" numbers show :=
-)
> > But, I take it this is different in your results?
>=20
>=20
> My results are on a "tbench 16" on an dual X5570  @ 2.93GHz.
> (16 logical cpus)
>=20
> No RPS , no RFS : 4448.14 MB/sec=20
> RPS : 2298.00 MB/sec (but lot of variation)
> RFS : 2600 MB/sec
>=20
> Maybe my RFS setup is bad ?
> (8192 flows)
>=20

With attached patch, I reached=20

Throughput 4465.13 MB/sec 16 procs

RFS better than no RPS/RFS :)

So, the old idea to make rxhash consistent (same value in both
directions) is a win for some workloads (Consider connection tracking /
firewalling)=20

port1 =3D ...
port2 =3D ...
addr1 =3D ...
addr2 =3D ...
if (addr1 > addr2)
	exchange(addr1, addr2)
if (port1 > port2)
	exchange(port, port2)

hash =3D jhash(addr1, addr2, (port1<<16)+port2, ...)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7abf959..6b757ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2280,8 +2280,10 @@ static int get_rps_cpu(struct net_device *dev,
struct sk_buff *skb,
        case IPPROTO_AH:
        case IPPROTO_SCTP:
        case IPPROTO_UDPLITE:
-               if (pskb_may_pull(skb, (ihl * 4) + 4))
-                       ports =3D *((u32 *) (skb->data + (ihl * 4)));
+               if (pskb_may_pull(skb, (ihl * 4) + 4)) {
+                       u16 *_ports =3D (u16 *)(skb->data + (ihl * 4));
+                       ports =3D _ports[0] ^ _ports[1];
+               }
                break;
=20
        default:


