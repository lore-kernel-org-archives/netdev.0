From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 03 Jan 2012 12:57:12 -0500
Message-ID: <1325613432.7219.85.camel@denise.theartistscloset.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325593115.7219.36.camel@denise.theartistscloset.com>
	 <1325593951.2320.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325594716.7219.39.camel@denise.theartistscloset.com>
	 <CAA93jw66gierUSN+gcZYY6L0UVqBdOhRKQwdA8NkhNqJL__uUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:55998 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441Ab2ACR5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 12:57:54 -0500
In-Reply-To: <CAA93jw66gierUSN+gcZYY6L0UVqBdOhRKQwdA8NkhNqJL__uUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 14:00 +0100, Dave Taht wrote:
<snip>
> SFQ as presently implemented (and by presently, I mean, as of yesterday,
> by tomorrow it could be different at the rate eric is going!) is VERY
> suitable for
> sub 100Mbit desktops, wireless stations/laptops other devices,
> home gateways with sub 100Mbit uplinks, and the like. That's a few
> hundred million devices that aren't using it today and defaulting to
> pfifo_fast and suffering for it.
> 
> QFQ is it's big brother and I have hopes it can scale up to 10GigE,
> once suitable techniques are found for managing the sub-queue depth.
> 
> The enhancements to SFQ eric proposed in the other thread might get it
> to where it outperforms (by a lot) pfifo_fast in it's default configuration
> (eg txqueuelen 1000) with few side effects. Scaling further up than that...
> 
> ... I don't have a good picture of gigE performance at the moment with
> any of these advanced qdiscs and have no recomendation.
Hmm . . . that's interesting in light of our thoughts about using SFQ
for iSCSI.  In that case, the links are GbE or 10GbE. Is there a problem
using SFQ on those size links rather than pfifo_fast?
> 
<snip>
> >>       - "Round-robin" -> It introduces larger delays than virtual clock
> >>       based schemes, and should not be used for isolating interactive
> >>       traffic from non-interactive. It means, that this scheduler
> >>       should be used as leaf of CBQ or P3, which put interactive traffic
> >>       to higher priority band.
> 
> These delays are NOTHING compared to what pfifo_fast can induce.
> 
> Very little traffic nowadays is marked as interactive to any statistically
> significant extent, so any FQ method effectively makes more traffic
> interactive than prioritization can.
That may be changing quickly.  I am doing a lot of work with Destkop
Virtualization.  This is all interactive traffic and, unlike terminal
screens over telnet or ssh in the past, these can be fairly large chunks
of data using full sized packets.  They are also bursty rather than
periodic.  I would think we very much need prioritization here combined
with FQ (hence our interest in HFSC + SFQ).
> 
<snip>
> > Hmm . . . although I still wonder about iSCSI SANs . . .   Thanks
> 
> I wonder too. Most of the people running iSCSI seem to have an
> aversion to packet loss, yet are running over TCP. I *think*
> FQ methods will improve latency dramatically for iSCSI
> when iSCSI has multiple initiators....
<snip>
I haven't had a chance to play with this yet but I'll do a little
thinking out loud.  Since these can be very large data transmissions, I
would think it quite possible that a new connection's SYN packet is
stuck behind a pile of full sized iSCSI packets.  On the other hand, I'm
not sure where the bottleneck is in iSCSI and if these queues ever
backlog.  I just ran a quick, simple test on a non-optimized SAN doing a
cat /dev/zero > filename, hit 3.6Gbps throughput with four e1000 NICs
doing multipath multibus and saw no backlog in the pfifo_fast qdiscs.

If we do ever backlog, I would think SFQ would provide for a more
immediate response to new streams whereas users of the bulk downloads
already in process would not even notice the blip when the new stream is
inserted.

I would be a little concerned about iSCSI packets being delivered out of
order when multipath multibus is used, i.e., the iSCSI commands are
round robined around several NICs and thus several queues.  If those
queues are in varying states of backlog, a later packet in one queue
might be delivered before an earlier packet in another queue.  Then
again, I would think pfifo_fast could produce a greater delay than SFQ -
John
