From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 09:20:50 +0200
Message-ID: <20090521072050.GA2892@ami.dom.local>
References: <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090516141430.GB3013@ami.dom.local> <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com> <1242688479.9558.60.camel@hazard2.francoudi.com> <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladimir Ivashchenko <hazard@francoudi.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:57647 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbZEUHU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 03:20:59 -0400
Received: by bwz22 with SMTP id 22so835967bwz.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 00:20:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A148838.8010809@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2009 at 12:46:16AM +0200, Eric Dumazet wrote:
> Vladimir Ivashchenko a =E9crit :
> >>>> I guess you should send some logs. Your previous report seem to =
show
> >>> Can you give some hints on which logs you would like to see?
> >> Similarly to Antonio's: ifconfigs and tc -s for qdiscs and classes=
 at
> >> the beginning and at the end of testing.
> >=20
> > Ok, it seems that I finally found what is causing my HTB on 2.6.29 =
not
> > to reach full throughput: dst hashing on sfq with high divisor valu=
e.
> >=20
> > 2.6.21 esfq divisor 13 depth 4096 hash dst - 680 mbps
> > 2.6.29 sfq WITHOUT "flow hash keys dst ... " (default sfq) - 680 mb=
ps
> > 2.6.29 sfq + "flow hash keys dst divisor 64" filter - 680 mbps
> > 2.6.29 sfq + "flow hash keys dst divisor 256" filter - 660 mbps
> > 2.6.29 sfq + "flow hash keys dst divisor 2048" filters - 460 mbps
> >=20
> > I'm using high sfq hash divisor in order to decrease the number of
> > collisions, there are several thousands of hosts behind each of the
> > classes.=20
> >=20
> > Any ideas why increasing the sfq divisor size results in drop of
> > throughput ?
> >=20
> > Attached are diagnostics gathered in case of divisor 2048.
> >=20
>=20
>=20
> But... it appears sfq currently supports a fixed divisor of 1024
>=20
> net/sched/sch_sfq.c
>=20
>  IMPLEMENTATION:
>  This implementation limits maximal queue length to 128;
>  maximal mtu to 2^15-1; number of hash buckets to 1024.
>  The only goal of this restrictions was that all data
>  fit into one 4K page :-). Struct sfq_sched_data is
>  organized in anti-cache manner: all the data for a bucket
>  are scattered over different locations. This is not good,
>  but it allowed me to put it into 4K.
>=20
>  It is easy to increase these values, but not in flight.  */
>=20
> #define SFQ_DEPTH   128
> #define SFQ_HASH_DIVISOR    1024
>=20
>=20
> Apparently Corey Hickey 2007 work on SFQ was not merged.
>=20
> http://kerneltrap.org/mailarchive/linux-netdev/2007/9/28/325048

Yes, sfq has its design limits, and as a matter of fact, because of
max length (127) it should be treated as a toy or "personal" qdisc.

I don't know why more of esfq wasn't merged, anyway similar
functionality could be achieved in current kernels with sch_drr +
cls_flow, alas not enough documented. Here is some hint:
http://markmail.org/message/h24627xkrxyqxn4k

Jarek P.

PS: I guess, you wasn't very consistent if your main problem was
exceeding or not reaching htb rate, and there is quite a difference.

Vladimir Ivashchenko wrote, On 05/08/2009 10:46 PM:

> Exporting HZ=3D1000 doesn't help. However, even if I recompile the ke=
rnel
> to 1000 Hz and the burst is calculated correctly, for some reason HTB=
 on
> 2.6.29 is still worse at rate control than 2.6.21.
>=20
> With 2.6.21, ceil of 775 mbits, burst 99425b -> actual rate 825 mbits=
=2E
> With 2.6.29, same ceil/burst -> actual rate 890 mbits.
=2E..

Vladimir Ivashchenko wrote, On 05/17/2009 10:29 PM:

> Hi Antonio,
>=20
> FYI, these are exactly the same problems I get in real life.
> Check the later posts in "bond + tc regression" thread.
=2E..
