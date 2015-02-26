From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 13:11:23 -0800
Message-ID: <54EF8BFB.5050608@intel.com>
References: <20150226074214.GF2074@nanopsycho.orion> <20150226083758.GA15139@vergenet.net> <20150226091628.GA4059@nanopsycho.orion> <20150226133326.GC23050@casper.infradead.org> <54EF3A78.9020507@intel.com> <20150226201635.GA366@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	jpettit@nicira.com, joestringer@nicira.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11738 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbbBZVL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 16:11:26 -0500
In-Reply-To: <20150226201635.GA366@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 12:16 PM, Neil Horman wrote:
> On Thu, Feb 26, 2015 at 07:23:36AM -0800, John Fastabend wrote:
>> On 02/26/2015 05:33 AM, Thomas Graf wrote:
>>> On 02/26/15 at 10:16am, Jiri Pirko wrote:
>>>> Well, on netdev01, I believe that a consensus was reached that for every
>>>> switch offloaded functionality there has to be an implementation in
>>>> kernel.
>>>
>>> Agreed. This should not prevent the policy being driven from user
>>> space though.
>>>
>>>> What John's Flow API originally did was to provide a way to
>>>> configure hardware independently of kernel. So the right way is to
>>>> configure kernel and, if hw allows it, to offload the configuration to hw.
>>>>
>>>> In this case, seems to me logical to offload from one place, that being
>>>> TC. The reason is, as I stated above, the possible conversion from OVS
>>>> datapath to TC.
>>>
>>> Offloading of TC definitely makes a lot of sense. I think that even in
>>> that case you will already encounter independent configuration of
>>> hardware and kernel. Example: The hardware provides a fixed, generic
>>> function to push up to n bytes onto a packet. This hardware function
>>> could be used to implement TC actions "push_vlan", "push_vxlan",
>>> "push_mpls". You would you would likely agree that TC should make use
>>> of such a function even if the hardware version is different from the
>>> software version. So I don't think we'll have a 1:1 mapping for all
>>> configurations, regardless of whether the how is decided in kernel or
>>> user space.
>>
>> Just to expand slightly on this. I don't think you can get to a 1:1
>> mapping here. One reason is hardware typically has a TCAM and limited
>> size. So you need a _policy_ to determine when to push rules into the
>> hardware. The kernel doesn't know when to do this and I don't believe
>> its the kernel's place to start enforcing policy like this. One thing I likely
>> need to do is get some more "worlds" in rocker so we aren't stuck only
>> thinking about the infinite size OF_DPA world. The OF_DPA world is only
>> one world and not a terribly flexible one at that when compared with the
>> NPU folk. So minimally you need a flag to indicate rules go into hardware
>> vs software.
>>
>> That said I think the bigger mismatch between software and hardware is
>> you program it differently because the data structures are different. Maybe
>> a u32 example would help. For parsing with u32 you might build a parse
>> graph with a root and some leaf nodes. In hardware you want to collapse
>> this down onto the hardware. I argue this is not a kernel task because
>> there are lots of ways to do this and there are trade-offs made with
>> respect to space and performance and which table to use when it could be
>> handled by a set of tables. Another example is a virtual switch possibly
>> OVS but we have others. The software does some "unmasking" (there term)
>> before sending the rules into the software dataplane cache. Basically this
>> means we can ignore priority in the hash lookup. However this is not how you
>> would optimally use hardware. Maybe I should do another write up with
>> some more concrete examples.
>>
>> There are also lots of use cases to _not_ have hardware and software in
>> sync. A flag allows this.
>>
>> My only point is I think we need to allow users to optimally use there
>> hardware either via 'tc' or my previous 'flow' tool. Actually in my
>> opinion I still think its best to have both interfaces.
>>
>> I'll go get some coffee now and hopefully that is somewhat clear.
> 
> 
> I've been thinking about the policy apect of this, and the more I think about
> it, the more I wonder if not allowing some sort of common policy in the kernel
> is really the right thing to do here.  I know thats somewhat blasphemous, but
> this isn't really administrative poilcy that we're talking about, at least not
> 100%.  Its more of a behavioral profile that we're trying to enforce.  That may
> be splitting hairs, but I think theres precidence for the latter.  That is to
> say, we configure qdiscs to limit traffic flow to certain rates, and configure
> policies which drop traffic that violates it (which includes random discard,
> which is the antithesis of deterministic policy).  I'm not sure I see this as
> any different, espcially if we limit its scope.  That is to say, why couldn't we
> allow the kernel to program a predetermined set of policies that the admin can
> set (i.e. offload routing to a hardware cache of X size with an lru
> victimization).  If other well defined policies make sense, we can add them and
> exposes options via iproute2 or some such to set them.  For the use case where
> such pre-packaged policies don't make sense, we have things like the flow api to
> offer users who want to be able to control their hardware in a more fine grained
> approach.
> 
> Neil
> 

Hi Neil,

I actually like this idea a lot. I might tweak a bit in that we could have some
feature bits or something like feature bits that expose how to split up the
hardware cache and give sizes.

So the hypervisor (see I think of end hosts) or administrators could come in and
say I want a route table and a nft table. This creates a "flavor" over how the
hardware is going to be used. Another use case may not be doing routing at all
but have an application that wants to manage the hardware at a more fine grained
level with the exception of some nft commands so it could have a "nft"+"flow"
flavor. Insert your favorite use case here.

.John
