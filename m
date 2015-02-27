From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 07:23:13 -0800
Message-ID: <54F08BE1.1080200@intel.com>
References: <20150226074214.GF2074@nanopsycho.orion>	<20150226083758.GA15139@vergenet.net>	<20150226091628.GA4059@nanopsycho.orion>	<20150226133326.GC23050@casper.infradead.org> <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com> <54EF3E45.3070103@intel.com> <54F0721E.1030703@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Shrijeet Mukherjee <shrijeet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27955 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbbB0PXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 10:23:50 -0500
In-Reply-To: <54F0721E.1030703@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2015 05:33 AM, Jamal Hadi Salim wrote:
> On 02/26/15 10:39, John Fastabend wrote:
> 
>> So I think there is a relatively simple solution for this. Assuming
>> I read the description correctly namely packet ingress' nic/switch
>> and you want it to land in a namespace.
>>
>> Today we support offloaded macvlan's and SR-IOV. What I would expect
>> is user creates a set of macvlan's that are "offloaded" this just means
>> they are bound to a set of hardware queues and do not go through the
>> normal receive path. Then assigning these to a namespace is the same
>> as any other netdev.
>>
>> Hardware has an action to forward to "VSI" (virtual station interface)
>> which matches on a packet and forwards it to either a VF or set of
>> queues bound to a macvlan. Or you can do the forwarding using standards
>> based protocols such as EVB (edge virtual bridging).
>>
>> So its a simple set of steps with the flow api,
>>
>>     1. create macvlan with dfwd_offload set
>>     2. push netdev into namespace
>>     3. add flow rule to match traffic and send to VSI
>>         ./flow -i ethx set_rule match xyz action fwd_vsi 3
>>
>> The VSI# is reported by ip link today its a bit clumsy so that interface
>> could be cleaned up.
>>
>> Here is a case where trying to map this onto a 'tc' action in software
>> is a bit awkward and you convoluted what is really a simple operation.
>> Anyways this is not really an "offload" in the sense that your taking
>> something that used to run in software and moving it 1:1 into hardware.
>> Adding SR-IOV/VMDQ support requries new constructs. By the way if you
>> don't like my "flow" tool and you want to move it onto "tc" that could
>> be done as well but the steps are the same.
>>
> 
> Sorry for the top post - just wanted to leave the context intact.
> TU (that is a "thumbs up" from an anti +1 person) on what you said
> above. But i dont see the issue you bring up in step #3. If i was to
> say:
> 
> tc filter add ingress ethx classifier foo priority X \
> match xyz action redirect macvlan3 offload
> 
> where "offload" sets the netlink or classifier specific instruction
> to offload.
> 
> You can easily map macvlan3 to vsi 3.
> 

This is why I said if you want to map my "flow" tool onto "tc" it can
be done. :) I made a jump from macvlans that have net device representations
to VFs being assigned to user space (VMs) where there is no net device
to "redirect" to. So my explanation wasn't clear. Couple additional notes,

The only issue I have with your 'tc' case is the "ingress" qdisc is per port where
my flow tool is scoped at the switch pipeline so I would modify your cmd
slightly and use a new classifier hook,

 tc filter add sw-pipeline ethx classifier flow priority X \
    match xyz action redirect macvlan3 offload

The other thing to note is "redirect" to macvlan3 doesn't handle the case
where the VF is direct assigned to a VM in this case we don't have a netdev
in the hypervisor to "redirect" to. Using the VSI# allows the hardware
to translate the redirect cmd to the VF.

So one more slight tweak,

 tc filter add sw-pipeline ethx classifier flow priority X \
    match xyz action redirect vsi:2 offload

use the "vsi:" prefix to indicate this is for a hardware mapped VSI this
way the user can use what ever notion is more convenient.

> cheers,
> jamal
> 
> 
> 
