From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 08:33:18 -0500
Message-ID: <54F0721E.1030703@mojatatu.com>
References: <20150226074214.GF2074@nanopsycho.orion>	<20150226083758.GA15139@vergenet.net>	<20150226091628.GA4059@nanopsycho.orion>	<20150226133326.GC23050@casper.infradead.org> <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com> <54EF3E45.3070103@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
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
To: John Fastabend <john.r.fastabend@intel.com>,
	Shrijeet Mukherjee <shrijeet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36409 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbB0NdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 08:33:21 -0500
Received: by ierx19 with SMTP id x19so30830400ier.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 05:33:20 -0800 (PST)
In-Reply-To: <54EF3E45.3070103@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 10:39, John Fastabend wrote:

> So I think there is a relatively simple solution for this. Assuming
> I read the description correctly namely packet ingress' nic/switch
> and you want it to land in a namespace.
>
> Today we support offloaded macvlan's and SR-IOV. What I would expect
> is user creates a set of macvlan's that are "offloaded" this just means
> they are bound to a set of hardware queues and do not go through the
> normal receive path. Then assigning these to a namespace is the same
> as any other netdev.
>
> Hardware has an action to forward to "VSI" (virtual station interface)
> which matches on a packet and forwards it to either a VF or set of
> queues bound to a macvlan. Or you can do the forwarding using standards
> based protocols such as EVB (edge virtual bridging).
>
> So its a simple set of steps with the flow api,
>
> 	1. create macvlan with dfwd_offload set
> 	2. push netdev into namespace
> 	3. add flow rule to match traffic and send to VSI
> 		./flow -i ethx set_rule match xyz action fwd_vsi 3
>
> The VSI# is reported by ip link today its a bit clumsy so that interface
> could be cleaned up.
>
> Here is a case where trying to map this onto a 'tc' action in software
> is a bit awkward and you convoluted what is really a simple operation.
> Anyways this is not really an "offload" in the sense that your taking
> something that used to run in software and moving it 1:1 into hardware.
> Adding SR-IOV/VMDQ support requries new constructs. By the way if you
> don't like my "flow" tool and you want to move it onto "tc" that could
> be done as well but the steps are the same.
>

Sorry for the top post - just wanted to leave the context intact.
TU (that is a "thumbs up" from an anti +1 person) on what you said
above. But i dont see the issue you bring up in step #3. If i was to
say:

tc filter add ingress ethx classifier foo priority X \
match xyz action redirect macvlan3 offload

where "offload" sets the netlink or classifier specific instruction
to offload.

You can easily map macvlan3 to vsi 3.

cheers,
jamal
