From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 04:47:42 +0200
Message-ID: <1335926862.22133.42.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop> <4FA06A94.8050704@intel.com>
	 <4FA06D7A.6090800@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34848 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757388Ab2EBCrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 22:47:47 -0400
Received: by were53 with SMTP id e53so86406wer.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 19:47:46 -0700 (PDT)
In-Reply-To: <4FA06D7A.6090800@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 16:10 -0700, Alexander Duyck wrote:
> On 05/01/2012 03:58 PM, Alexander Duyck wrote:

> > Eric,
> >
> > I think I have found a bug, although it is not specific to this pat=
ch
> > but it is related.  It looks like the TCP coalesce code is causing
> > tcpdump to fail when using frags.  Based on the comments in the pat=
ch I
> > am assuming you have an ixgbe adapter to test with as that is what =
I
> > reproduced this on.  To reproduce the issue all you need to do is r=
un
> > "tcpdump -i ethX > /dev/null" on one console, and on a second conso=
le
> > run a netperf TCP_MAERTS test to some other server.  Tcpdump will e=
xit
> > out with a message about bad address like this:
> >
> > tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
> > listening on eth1, link-type EN10MB (Ethernet), capture size 96 byt=
es
> > tcpdump: pcap_loop: recvfrom: Bad address
> > 682 packets captured
> > 2357 packets received by filter
> > 1543 packets dropped by kernel
> >
> >
> > A bisect of the issue tracked it down to:
> >
> > 1402d366019fedaa2b024f2bac06b7cc9a8782e1 is first bad commit
> > commit 1402d366019fedaa2b024f2bac06b7cc9a8782e1
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Mon Apr 23 07:11:42 2012 +0000
> >
> >     tcp: introduce tcp_try_coalesce
> >    =20
> >     commit c8628155ece3 (tcp: reduce out_of_order memory use) took =
care of
> >     coalescing tcp segments provided by legacy devices (linear skbs=
)
> >    =20
> >     We extend this idea to fragged skbs, as their truesize can be h=
eavy.
> >    =20
> >     ixgbe for example uses 256+1024+PAGE_SIZE/2 =3D 3328 bytes per =
segment.
> >    =20
> >     Use this coalescing strategy for receive queue too.
> >    =20
> >     This contributes to reduce number of tcp collapses, at minimal =
cost, and
> >     reduces memory overhead and packets drops.
> >    =20
> >     Signed-off-by: Eric Dumazet <edumazet@google.com>
> >     Cc: Neal Cardwell <ncardwell@google.com>
> >     Cc: Tom Herbert <therbert@google.com>
> >     Cc: Maciej =C3=85=C2=BBenczykowski <maze@google.com>
> >     Cc: Ilpo J=C3=83=C2=A4rvinen <ilpo.jarvinen@helsinki.fi>
> >     Acked-by: Neal Cardwell <ncardwell@google.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 8ca3e0b4e6c6a8f375fd800069d24203880623f3 2576d34c5c9=
cfc717a11e2ebe054143956716b93 M	net
> >
> > I suspect we are dealing with either a shared or cloned skb in this
> > case, though I haven't verified which it is yet.
> >
> > Thanks,
> >
> > Alex
> >
> One additional note.  It looks like LRO and GRO need to be disabled t=
o
> trigger the bug.  If either of them are enabled it doesn't seem to
> occur.  Likely due to the fact that they are doing the coalescing bef=
ore
> it gets up to the tcp_try_coalesce call.
>=20

Thanks Alex, I'll take a look.

It seems my tcpdump is different than yours.
