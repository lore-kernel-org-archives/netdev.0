From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 07:59:36 -0500
Message-ID: <20150227125936.GA1611@hmsreliant.think-freely.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org>
 <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
 <20150227084141.GA17240@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48387 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbbB0NAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 08:00:01 -0500
Content-Disposition: inline
In-Reply-To: <20150227084141.GA17240@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 08:41:41AM +0000, Thomas Graf wrote:
> On 02/26/15 at 08:22pm, Neil Horman wrote:
> > Yes, exactly that, for the general traditional networking use case, that is
> > exactly what we want, to opportunistically move traffic faster with less load on
> > the cpu.  We don't nominally care what traffic is offloaded, as long as the
> > hardware does a better job than just software alone.  If we get an occasional
> > miss and have to do stuff in software, so be it.
> 
> Blind random offload of some packets is better than nothing but knowing
> and having control over which packets are offloaded is essential. You
> typically don't want to randomly give one flow priority over another ;-)
> Some software CPUs might not be able to handle the load. I know what
> you mean though and as long as we allow to disable and overwrite this
> behaviour we are good.
> 

Yes, exactly this.  I disagree with your assertion that what I'm proposing is
blind or random (quite the opposite), I'm proposing best effort offload of high
level kernel functions with well defined generic policies for what to do on
resource exhaustion overflow.  You are correct that this might lead to random
(or perhaps better put, arbitrary), flows reaching the cpu occasionally, but
thats the best effort part.  Using canned policies will lead to that, and if
thats intolerable to you as an administrator, then you have the flow api to
offer more fine grained control over what exactly you want to do.

Interestingly, As part of a policy specification, I wonder if we could
incorporate a flow rate aspect that would lead a driver to only offload a
given flow for a given functionality if it sends more than X amount of traffic
through the cpu.

> > So, this is a case in which I think John F.'s low level flow API is more well
> > suited.  OVS has implemented a user space dataplane that circumvents alot of the
> > kernel mechanisms for traffic forwarding.  For that sort of application, the
> > traditional kernel offload "objects" aren't really appropriate.  Instead, OVS
> > can use the low level flow API to construct its own custom offload pipeline
> > using whatever rules and policies that it wants.
> 
> Maybe I'm misunderstanding your statement here but I think it's essential
> that the kernel is able to handle whatever we program in hardware even
> if the hardware tables look differrent than the software tables, no matter
> whether the configuration occurs through OVS or not. A punt to software
> should always work even if it does not happen. So while I believe that
> OVS needs more control over the hardware than available through the
> datapath cache it must program both the hardware and software in parallel
> even though the building blocks for doing so might look different.
> 
I think parallel programming of the hardware and software is essential in _most_
use cases, but possibly not all, and in those cases, I think Johns flow API is
the solution.  Mine makes sense for all the traditional use cases in which we
just want more packets to go faster, and be able to deal with the consequences
in a best effort fashion if the fast path can't do its job.

As an example, lets imagine that a company wishes to build an appliance that
allows ipsec tunneling using a custom assymetric crypto algorithm that they have
codified with a TCM unit in the hardware datapath.  All we can do is program the
public and private keys on the hardware.  In this case we can setup a software
datapath to represent the mirror image of the hardware datapath, but it would be
non-functional, as we don't know what the magic crypto alg is.  In this case
Johns Flow API is essential because its able to setup the datapath in hardware
that has no true software parallel.  Additionaly its imperative to use that API
to ensure that all flows via that tunnel go through hardware, as there is no
point in overflowing the traffic to the cpu.

> > Of course, using the low level flow API is incompatible with the in-kernel
> > object offload idea that I'm proposing, but I see the two as able to co-exist,
> > much like firewalld co-exists with iptables.  You can use both, but you have to
> > be aware that using the lower layer interface might break the others higher
> > level oeprations.  And if that happens, its on you to manage it.
> 
> I think this does not have to be mutually exclusive. An example would
> be a well defined egress qdisc which is offloaded into it's own table.
> If OVS is aware of the table it can make use of it while configuring
> that table through the regular qdisc software API.
> 
Absolutely, I should have said "may be incompatible".  In this case my thought
was that, if you offloaded l2 and l3 forwarding to a device, some of the
dataplane elements to preform those functions would be allocated to that
purpose.  If you then were to use the lower level Flow api to do some sort of
custom datapath manipulation in hardware, the hardware may or may not have
resources to dedicate to that purpose.  In the event that they did not the flow
API would have to fail (or vice versa if you used the flow api first, then tried
to offload l2 forwarding).  If however sufficient resources were available to do
both, then all is well and the two can co-exist.

Regards
Neil
