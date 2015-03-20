From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: Linux the best hardware for routing with 10 and 40G network
 adapter
Date: Fri, 20 Mar 2015 18:17:12 +0100
Message-ID: <9d3c732e3a671c9140d6d9bc8d4dd302@justnet.pl>
References: <46dc0ac83067ee5d171997854bac2e1d@justnet.pl>
 <CAANLjFq2yKfvH0Z3TyNPc6mim6-Thc1M6NB9uC+Xu-4FRhkoEQ@mail.gmail.com>
 <CAA93jw7+ctbWDER9Wx5po_amxEq-PH=0Gb0xUWLSoBTidszyHQ@mail.gmail.com>
 <CAANLjFoOq7evqCbWxREFzxnKSvYHL+jS-MMxJZc1HKQfVoddXw@mail.gmail.com>
 <CAA93jw7Me8YrB4-mOT6CR6TAVMy3EMUFAUCtMCJDyhw8NsdB-A@mail.gmail.com>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert LeBlanc <robert@leblanc.us>, lartc@vger.kernel.org,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:54042 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbbCTRjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:39:55 -0400
In-Reply-To: <CAA93jw7Me8YrB4-mOT6CR6TAVMy3EMUFAUCtMCJDyhw8NsdB-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

attached information look very interesting. if you are looking for=20
testers I have the opportunity to test in an environment:
- linux router for customers
- 2K active users
- 1xGbE for uplink
- 3xGbE for customer link
- customer use static routing and pppoe


---
Thanks
Adam Nie=C5=9Bcierowicz

W dniu 19.03.2015 18:53, Dave Taht napisa=C5=82(a):

> On Thu, Mar 19, 2015 at 10:21 AM, Robert LeBlanc <robert@leblanc.us>=20
> wrote:
>=20
>> I'm not familiar with fq_codel, but it doesn't look to have priority
>> queues which is one of our primary concerns.
>=20
> You generally don't need priority queues per se' with fq_codel. See
> more below. You CAN, if you wish, use specialized tc rules for priori=
ty
> traffic.
>=20
> We have generally found that by using fair queueing (flow queuing), a=
nd
> an AQM to keep queue lengths short, that nearly all of the perceived=20
> need
> for explicit prioritization vanishes.
>=20
> try it. you are a single sysctl away from trying it.
>=20
>> 40 Gb is pretty fast,
>=20
> Well, an ongoing problem much discussed at the netconf01 conference,
> is the tx path is now capable of 40Gbit but the rx path is not.
>=20
>> but
>> we are concerned about run away processes in our cluster that could
>> saturate uplinks or even the PCI bus at these speeds.
>=20
> Well, fq_codel is best on your saturated uplinks, to be sure, and it
> is very helpful against simple malbehaved loads. For example, we had =
a
> bug in dhcpdv6 that happened after 51 days, totally saturating the
> cable uplink with requests. The fq_codel users - never noticed it! Th=
e
> link was mildly slower, that's all.
>=20
> http://www.bufferbloat.net/issues/441 [1]
>=20
> I am sure I still have older users of cerowrt out there flooding
> comcast with dhcpv6 requests from that particular bug, and not
> noticing it.
>=20
>> We need to keep
>> heartbeats and management traffic alive to be able to solve these
>> problems.
>=20
> Heartbeats and management traffic are naturally sparse, and thus
> automagically prioritized by fq_codel.
>=20
> It also uses ECN if you choose, which allows for low latency without
> packet loss on hosts that use ecn by default. The relevant sysctls
> are:
>=20
> net.ipv4.tcp_ecn=3D1
> net.core.default_qdisc=3Dfq_codel
>=20
> Which I usually put in a file in /etc/sysctl.d
>=20
> and there is also now support for enabling ecn on a per route basis i=
n
> the latest kernels, as people are still dubious about being able to
> use ecn everywhere. But ecn is not required to be fully enabled for
> fq_codel to work it's magic.
>=20
> But: I know of at least one large web service provider enabling ecn
> AND fq_codel by default, everywhere now ( archive.org ) and there are
> no doubt countless others.
>=20
> In your case, with the 10+GigE hardware queues running mq, you can
> have a top level tc filter to redirect stuff based on markings into
> the "right" hardware queues, and have fq_codel or sch_fq attached
> underneath it for each hardware queue to further manage the traffic.
> The latter part of that happens automagically with the first sysctl
> above, the tc part is kind of expensive to write rules for, I wish we
> had an explicit "diffserv" filter to use instead of one tc rule per
> diffserv codepoint you cared about.
>=20
> sch_fq, is a host only solution, mostly targetted at tcp traffic, and
> that *does* support explicit prioritization. It's pretty amazing what
> it does...
>=20
> All I have ever argued on these fronts is merely that people try thes=
e
> new qdiscs in *their* realistic scenarios and with tools like
> netperf-wrapper, to see if they help or not, and (hopefully) share
> their results so we can further improve matters.
>=20
> We are well aware of how much sqm-scripts + fq_codel help cable and
> DSL modems in particular (see for example:
> http://burntchrome.blogspot.com/2014/05/fixing-bufferbloat-on-comcast=
s-blast.html=20
> [2]
> or http://snapon.lab.bufferbloat.net/~cero2/jimreisert/results.html [=
3]=20
> ),
>=20
> and we are working on some derivative ideas to improve wifi as part o=
f
> the make-wifi-fast effort. (
> http://snapon.lab.bufferbloat.net/~d/ieee802.11-sept-17-2014/11-14-12=
65-00-0wng-More-on-Bufferbloat.pdf=20
> [4]
> )
>=20
> In other news...
>=20
> Work is resuming on "sch_cake", which combines htb + fq_codel +
> diffserv (and priority) classification into one qdisc (replacing the
> sqm-scripts entirely) and I do hope we can get some more testers of
> the patches over the next few months. The discussion of "cake" is ove=
r
> on the codel list on bufferbloat.net where the current patch set is
> linked to and the flaws discussed. I do hope this qdisc will also
> scale up to 40GigE and be of use in doing traffic engineering at thes=
e
> speeds, and PLEASE join us in discussing the needed feature set(s) fo=
r
> your use cases.
>=20
> And I do generally hope that these algorithms will start appearing th=
e
> basic ethernet and switch hardware at some point soon. I am backing a
> kickstarter project to get it out there in an FPGA at least... (see:
> https://www.kickstarter.com/projects/onetswitch/onetswitch-open-sourc=
e-hardware-for-networking=20
> [5]
> )
>=20
>> It seems that fq_codel really helps with latency and
>> bufferbloat (which would also be good for us) and it is possible tha=
t
>> it would be adequate since we are DSCP marking packets and the
>> switches are applying L2 COS. I'll have to look over it. If you have
>> some information that would be helpful, I'd be happy to have it.
>=20
> Oy. More talks and documentation than you can shake a stick at.
>=20
> we have put a collection of the best up here:
> http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos [6]
>=20
> I enjoy Stephen Hemminger's presos a lot, although my modena talks go
> into more detail. Van Jacobson's talk is essential, and the shortest
> talk I have ever given on these subjects was the uknof talk.
>=20
> Most of my work has been focused on fixing the edge of the internet,
> rather than stuff in the data center, but I am increasingly intereste=
d
> in what good all this stuff does in these environments, as I do hope
> to see these algorithms start showing up soon in Load Balancers,
> BRAS's and CMTSes and ISP gear like that.
>=20
> Certainly sch_fq is rather widely deployed at at least one large web
> service provider, in particular. :) I don't have any data as to where
> else it is deployed...
>=20
> On Wed, Mar 18, 2015 at 4:41 PM, Dave Taht <dave.taht@gmail.com> wrot=
e:=20
> On Wed, Mar 18, 2015 at 3:03 PM, Robert LeBlanc <robert@leblanc.us>=20
> wrote:
> I can't speak for the specific configuration, but we are having
> challenges using the mqprio qdisc on the Intel XL710 adapters. We hav=
e
> engaged Intel, but we are still having trouble. If you want priority
> queuing and using the hardware TX queues, you may have problems with
> this family of cards.
>=20
> I am very curious about benchmarks of fq_codel (vs mqprio or
> pfifo_fast) at these speeds on adaptors like this, preferably driven
> by repeatable tests like the rrul test in netperf-wrapper.
>=20
> In particular, what happens if only one tx queue is enabled with=20
> fq_codel?
>=20
> On Wed, Mar 18, 2015 at 1:07 PM, Nie=C5=9Bcierowicz Adam
> <adam.niescierowicz@justnet.pl> wrote: Hi,
>=20
> in the near future we are planning to purchase new equipment for the=20
> router.
>=20
> Our requirements are:
>=20
> - four or more 1GbE interfaces
>=20
> - two-four 10GbE interfaces
>=20
> - two 40GbE interfaces
>=20
> - multicast routing with throughput input 1-2 Gb/s output 4x1-2Gb/s
>=20
> Can someone share your experience what equipment you choose to such a
> configuration
>=20
> ---
> Thanks,
> Adam Nie=C5=9Bcierowicz
> --
> To unsubscribe from this list: send the line "unsubscribe lartc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html [7]=
=20
> --
> To unsubscribe from this list: send the line "unsubscribe lartc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html [7]

  --
  Dave T=C3=A4ht
  Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb [8]



Links:
------
[1] http://www.bufferbloat.net/issues/441
[2]=20
http://burntchrome.blogspot.com/2014/05/fixing-bufferbloat-on-comcasts-=
blast.html
[3] http://snapon.lab.bufferbloat.net/~cero2/jimreisert/results.html
[4]=20
http://snapon.lab.bufferbloat.net/~d/ieee802.11-sept-17-2014/11-14-1265=
-00-0wng-More-on-Bufferbloat.pdf
[5]=20
https://www.kickstarter.com/projects/onetswitch/onetswitch-open-source-=
hardware-for-networking
[6] http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos
[7] http://vger.kernel.org/majordomo-info.html
[8] https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
