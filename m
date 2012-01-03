From: Dave Taht <dave.taht@gmail.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 3 Jan 2012 14:00:16 +0100
Message-ID: <CAA93jw66gierUSN+gcZYY6L0UVqBdOhRKQwdA8NkhNqJL__uUA@mail.gmail.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	<21734335.uCtjXOcSpA@alaris>
	<CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	<1325593115.7219.36.camel@denise.theartistscloset.com>
	<1325593951.2320.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325594716.7219.39.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41732 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab2ACNAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 08:00:17 -0500
Received: by iaeh11 with SMTP id h11so30863772iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 05:00:16 -0800 (PST)
In-Reply-To: <1325594716.7219.39.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 1:45 PM, John A. Sullivan III
<jsullivan@opensourcedevel.com> wrote:
> On Tue, 2012-01-03 at 13:32 +0100, Eric Dumazet wrote:
>> Le mardi 03 janvier 2012 =E0 07:18 -0500, John A. Sullivan III a =E9=
crit :
>> > On Tue, 2012-01-03 at 10:36 +0100, Dave Taht wrote:
>> > <snip>
>> > > I'd go into more detail, but after what I hope are the final two
>> > > fixes to sfq and qfq land in the net-next kernel (after some mor=
e
>> > > testing), I like to think I have a more valid approach than this
>> > > in the works, but that too will require some more development
>> > > and testing.
>> > >
>> > > http://www.teklibre.com/~d/bloat/pfifo_fast_vs_sfq_qfq_linear.pn=
g
>> > >
>> > <snip>
>> > Hmmm . . . certainly shattered my concerns about replacing pfifo_f=
ast
>> > with SFQ! Thanks - John

SFQ as presently implemented (and by presently, I mean, as of yesterday=
,
by tomorrow it could be different at the rate eric is going!) is VERY
suitable for
sub 100Mbit desktops, wireless stations/laptops other devices,
home gateways with sub 100Mbit uplinks, and the like. That's a few
hundred million devices that aren't using it today and defaulting to
pfifo_fast and suffering for it.

QFQ is it's big brother and I have hopes it can scale up to 10GigE,
once suitable techniques are found for managing the sub-queue depth.

The enhancements to SFQ eric proposed in the other thread might get it
to where it outperforms (by a lot) pfifo_fast in it's default configura=
tion
(eg txqueuelen 1000) with few side effects. Scaling further up than tha=
t...

=2E.. I don't have a good picture of gigE performance at the moment wit=
h
any of these advanced qdiscs and have no recomendation.

I do recomend highly that you fiddle with this stuff! I do have to
note that the graph above had GSO/TSO turned off.

>> Before you do, take the time to read the warning in sfq source :
>>
>>
>> =A0 =A0 =A0 ADVANTAGE:
>>
>> =A0 =A0 =A0 - It is very cheap. Both CPU and memory requirements are=
 minimal.
>>
>> =A0 =A0 =A0 DRAWBACKS:
>>
>> =A0 =A0 =A0 - "Stochastic" -> It is not 100% fair.
>> =A0 =A0 =A0 When hash collisions occur, several flows are considered=
 as one.

This is in part the benefit of SFQ vs QFQ in that the maximum queue
depth is well managed.

>> =A0 =A0 =A0 - "Round-robin" -> It introduces larger delays than virt=
ual clock
>> =A0 =A0 =A0 based schemes, and should not be used for isolating inte=
ractive
>> =A0 =A0 =A0 traffic from non-interactive. It means, that this schedu=
ler
>> =A0 =A0 =A0 should be used as leaf of CBQ or P3, which put interacti=
ve traffic
>> =A0 =A0 =A0 to higher priority band.

These delays are NOTHING compared to what pfifo_fast can induce.

Very little traffic nowadays is marked as interactive to any statistica=
lly
significant extent, so any FQ method effectively makes more traffic
interactive than prioritization can.

>> SFQ (as a direct replacement of dev root qdisc) is fine if most of y=
our trafic
>> is of same kind/priority.

Which is the case for most desktops, laptops, gws, wireless, etc.

> Yes, I suppose I should have been more specific, replacing pfifo_fast
> when I am using something else to prioritize and shape my traffic lik=
e
> HFSC.

I enjoyed getting your HFSC experience secondhand. It would be
very interesting getting your feedback on trying this stuff.

More data is needed to beat the bloat.

> Hmm . . . although I still wonder about iSCSI SANs . . . =A0 Thanks

I wonder too. Most of the people running iSCSI seem to have an
aversion to packet loss, yet are running over TCP. I *think*
=46Q methods will improve latency dramatically for iSCSI
when iSCSI has multiple initiators....


> - John
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
