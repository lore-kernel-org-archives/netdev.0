From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Linux the best hardware for routing with 10 and 40G network adapter
Date: Thu, 19 Mar 2015 10:53:51 -0700
Message-ID: <CAA93jw7Me8YrB4-mOT6CR6TAVMy3EMUFAUCtMCJDyhw8NsdB-A@mail.gmail.com>
References: <46dc0ac83067ee5d171997854bac2e1d@justnet.pl>
	<CAANLjFq2yKfvH0Z3TyNPc6mim6-Thc1M6NB9uC+Xu-4FRhkoEQ@mail.gmail.com>
	<CAA93jw7+ctbWDER9Wx5po_amxEq-PH=0Gb0xUWLSoBTidszyHQ@mail.gmail.com>
	<CAANLjFoOq7evqCbWxREFzxnKSvYHL+jS-MMxJZc1HKQfVoddXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: adam.niescierowicz@justnet.pl,
	"lartc@vger.kernel.org" <lartc@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert LeBlanc <robert@leblanc.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35997 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbCSRxv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 13:53:51 -0400
In-Reply-To: <CAANLjFoOq7evqCbWxREFzxnKSvYHL+jS-MMxJZc1HKQfVoddXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 10:21 AM, Robert LeBlanc <robert@leblanc.us> wr=
ote:
>
> I'm not familiar with fq_codel, but it doesn't look to have priority
> queues which is one of our primary concerns.

You generally don't need priority queues per se' with fq_codel. See
more below. You CAN, if you wish, use specialized tc rules for priority
traffic.

We have generally found that by using fair queueing (flow queuing), and
an AQM to keep queue lengths short, that nearly all of the perceived ne=
ed
for explicit prioritization vanishes.

try it. you are a single sysctl away from trying it.

> 40 Gb is pretty fast,

Well, an ongoing problem much discussed at the netconf01 conference,
is the tx path is now capable of 40Gbit but the rx path is not.

>
> but
> we are concerned about run away processes in our cluster that could
> saturate uplinks or even the PCI bus at these speeds.

Well, fq_codel is best on your saturated uplinks, to be sure, and it
is very helpful against simple malbehaved loads. For example, we had a
bug in dhcpdv6 that happened after 51 days, totally saturating the
cable uplink with requests. The fq_codel users - never noticed it! The
link was mildly slower, that's all.

http://www.bufferbloat.net/issues/441

I am sure I still have older users of cerowrt out there flooding
comcast with dhcpv6 requests from that particular bug, and not
noticing it.

> We need to keep
> heartbeats and management traffic alive to be able to solve these
> problems.

Heartbeats and management traffic are naturally sparse, and thus
automagically prioritized by fq_codel.

It also uses ECN if you choose, which allows for low latency without
packet loss on hosts that use ecn by default. The relevant sysctls
are:

net.ipv4.tcp_ecn=3D1
net.core.default_qdisc=3Dfq_codel

Which I usually put in a file in /etc/sysctl.d

and there is also now support for enabling ecn on a per route basis in
the latest kernels, as people are still dubious about being able to
use ecn everywhere. But ecn is not required to be fully enabled for
fq_codel to work it's magic.

But: I know of at least one large web service provider enabling ecn
AND fq_codel by default, everywhere now ( archive.org ) and there are
no doubt countless others.

In your case, with the 10+GigE hardware queues running mq, you can
have a top level tc filter to redirect stuff based on markings into
the "right" hardware queues, and have fq_codel or sch_fq attached
underneath it for each hardware queue to further manage the  traffic.
The latter part of that happens automagically with the first sysctl
above, the tc part is kind of expensive to write rules for, I wish we
had an explicit "diffserv" filter to use instead of one tc rule per
diffserv codepoint you cared about.

sch_fq, is a host only solution, mostly targetted at tcp traffic, and
that *does* support explicit prioritization. It's pretty amazing what
it does...

All I have ever argued on these fronts is merely that people try these
new qdiscs in *their* realistic scenarios and with tools like
netperf-wrapper, to see if they help or not, and (hopefully) share
their results so we can further improve matters.

We are well aware of how much sqm-scripts + fq_codel help cable and
DSL modems in particular (see for example:
http://burntchrome.blogspot.com/2014/05/fixing-bufferbloat-on-comcasts-=
blast.html
or http://snapon.lab.bufferbloat.net/~cero2/jimreisert/results.html ),

and we are working on some derivative ideas to improve wifi as part of
the make-wifi-fast effort. (
http://snapon.lab.bufferbloat.net/~d/ieee802.11-sept-17-2014/11-14-1265=
-00-0wng-More-on-Bufferbloat.pdf
)

In other news...

Work is resuming on "sch_cake", which combines htb + fq_codel +
diffserv (and priority) classification into one qdisc (replacing the
sqm-scripts entirely) and I do hope we can get some more testers of
the patches over the next few months. The discussion of "cake" is over
on the codel list on bufferbloat.net where the current patch set is
linked to and the flaws discussed. I do hope this qdisc will also
scale up to 40GigE and be of use in doing traffic engineering at these
speeds, and PLEASE join us in discussing the needed feature set(s) for
your use cases.

And I do generally hope that these algorithms will start appearing the
basic ethernet and switch hardware at some point soon. I am backing a
kickstarter project to get it out there in an FPGA at least... (see:
https://www.kickstarter.com/projects/onetswitch/onetswitch-open-source-=
hardware-for-networking
)

> It seems that fq_codel really helps with latency and
> bufferbloat (which would also be good for us) and it is possible that
> it would be adequate since we are DSCP marking packets and the
> switches are applying L2 COS. I'll have to look over it. If you have
> some information that would be helpful, I'd be happy to have it.


Oy. More talks and documentation than you can shake a stick at.

we have put a collection of the best up here:
http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos

I enjoy Stephen Hemminger's presos a lot, although my modena talks go
into more detail. Van Jacobson's talk is essential, and the shortest
talk I have ever given on these subjects was the uknof talk.

Most of my work has been focused on fixing the edge of the internet,
rather than stuff in the data center, but I am increasingly interested
in what good all this stuff does in these environments, as I do hope
to see these algorithms start showing up soon in Load Balancers,
BRAS's and CMTSes and ISP gear like that.

Certainly sch_fq is rather widely deployed at at least one large web
service provider, in particular. :) I don't have any data as to where
else it is deployed...


>
> On Wed, Mar 18, 2015 at 4:41 PM, Dave Taht <dave.taht@gmail.com> wrot=
e:
> > On Wed, Mar 18, 2015 at 3:03 PM, Robert LeBlanc <robert@leblanc.us>=
 wrote:
> >>
> >> I can't speak for the specific configuration, but we are having
> >> challenges using the mqprio qdisc on the Intel XL710 adapters. We =
have
> >> engaged Intel, but we are still having trouble. If you want priori=
ty
> >> queuing and using the hardware TX queues, you may have problems wi=
th
> >> this family of cards.
> >
> >
> > I am very curious about benchmarks of fq_codel (vs mqprio or
> > pfifo_fast) at these speeds on adaptors like this, preferably drive=
n
> > by repeatable tests like the rrul test in netperf-wrapper.
> >
> > In particular, what happens if only one tx queue is enabled with fq=
_codel?
> >
> >>
> >> On Wed, Mar 18, 2015 at 1:07 PM, Nie=C5=9Bcierowicz Adam
> >> <adam.niescierowicz@justnet.pl> wrote:
> >> > Hi,
> >> >
> >> > in the near future we are planning to purchase new equipment for=
 the router.
> >> >
> >> > Our requirements are:
> >> >
> >> > - four or more 1GbE interfaces
> >> >
> >> > - two-four 10GbE interfaces
> >> >
> >> > - two 40GbE interfaces
> >> >
> >> > - multicast routing with throughput input 1-2 Gb/s output 4x1-2G=
b/s
> >> >
> >> > Can someone share your experience what equipment you choose to s=
uch a
> >> > configuration
> >> >
> >> > ---
> >> > Thanks,
> >> > Adam Nie=C5=9Bcierowicz
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe lartc"=
 in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.ht=
ml
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe lartc" i=
n
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> >
> >
> > --
> > Dave T=C3=A4ht
> > Let's make wifi fast, less jittery and reliable again!
> >
> > https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb




--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
