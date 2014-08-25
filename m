From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Mon, 25 Aug 2014 15:54:49 +0100
Message-ID: <20140825145449.GB30140@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com>
 <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44168 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbaHYOyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:54:54 -0400
Content-Disposition: inline
In-Reply-To: <53FA01AC.10507@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/14 at 11:15am, Jamal Hadi Salim wrote:
> The focus of the patches is on offloading flows (uses the
> ovs or shall i say the broadcom OF-DPA API, which is one
> vendor's view of the world).

Let's keep vendors out of this discussion. I have no affiliation
with this vendor. In fact I'm personally more interested in the
host use case with the biggest concerns/focus on integration with
existing APIs.

> >It proposes *a* interface which in this case is flow based with mask
> >support to accomodate the typical ntuple filter API in HW. OVS happens
> >to be one of the easiest to use examples as a consumer because it
> >already provides a flat flow representation.
> >
> 
> In other words, there is a direct 1-1 map between this approach and OVS.
> That is a contentious point.

That is simply not the case. The fact that John is using this model
to replace the flow director ioctl API should prove this.

> Not at all.
> I gave an example earlier with u32, but lets pick the other extreme
> of well understood functions, say L3 (I could pick L2 as well).
> This openflow api tries to describe different header

There is not a single bit specific to OpenFlow and there is absolutely
no awareness of OF within the kernel in OVS.

> fields in the packet. That is not the challenge for such an
> API. The challenge is dealing with the quarks.
> Some chips implement FIB and NH conjoined; others implement
> them separately.
> I dont see how this is even being remotely touched on.

First of all, that sounds like exactly like something that should
be handled in the driver specific portion of the API. Secondly,
can you provide additional information on these specific pieces of
hardware so we take it into account?

> You are asking me to go and add a new ndo() every time i have a new network
> function? That is not scalable. I have no problem with
> the approach that was posted - I have a problem that it is it
> focused on flows (and is lacking ability to specify different
> classifiers). It should not be called xxx_flow_xxx

Realistically there will only be a handful, maybe something
like:

flow_insert / flow_remove
p4_add / p4_remove
[...]

Maybe you can share some information the specific API you have
in mind?

> If you looked at all my presentations I have never laid such
> claim but i have always said I want everything described in
> iproute2 to work. I dont think anyone disagreed.
> I dont expect tc to be used as *the interface*; but on the same
> token i dont expect OVS to be used as *the interface*.

Agreed, I don't think anybody expects anything else.

> Lets start with hardware abstraction. Lets map to existing Linux APIs
> and then see where some massaging maybe needed.

That's what's being done. HW offload is being mapped to OVS and
to an existing ioctl interface. Those are existing Linux APIs.
Can you explain why swdev as proposed is not suitable for the
other existing Linux APIs? They don't *have* to use the flow_insert(),
they are free to exted the API to represent more generic programmable
hardware.

> This abstraction gives OVS 1-1 mapping which is something i object to.
> You want to penalize me for the sake of getting the OVS api in place?

I don't understand this.

> Beginning with flows and laying claim to that one would be able to
> cover everything is non-starter.

Nobody claims that. In fact, I'm very interested in seeing the API
extended for non flow based models. I'm actually convinced that flow
based models are not the ultimate answers on HW level but a vast majority
of hardware understands some form of protocol aware exact match or
wildcard filters of limited capacity. This category of hardware is
being addressed with the flow_insert() API.

> I will simplify:
> You cant possibly do the u32 classifier completely using the posted
> hard-coded 15 tuple classifier. It is an NP-complete problem.
> There are *a lot* of use cases which can be specified by u32 that are
> not possible to specify with the tuples the patches posted propose.
> The reverse is not true. You can fully specify the OVS classifier
> with u32.
> So if you want to specify the closest to a universal grammar for
> specifying a classifier - use u32 and create templates for your
> classifier.

Completely agreed, this is why we have cls/act and nftables.

> There are some cases where that approach doesnt make sense:
> example if i wanted to specify a string classifier etc.
> But if we are talking packet header classifier - it is flexible.
> There are also good reasons to specify a universal 5 tuple classifier.
> As there are good reasons to specify your latest OF classifier.
> But that OF classifier being the starting point is not pragmatic.

So you agree that at least on the driver level some form of ntuple
awareness must be given because the hardware has limited capabilities.
This is exactly what flow_insert() is, it is a generic ntuple
classifier which can implement a subset of the 15 tuple in HW. So
instead of adding a separate NDO for each fixed tuple, a generic
NDO can handle the different levels of offloads. Very similar to how
the xmit to the NIC can handle various protocol offloads already.

What is being proposed is a generic ntuple with masking support to
describe filtering needs. What is missing is a capabilities reporting
channel so API users can know in advance what is supported to
implement partial offloads.
