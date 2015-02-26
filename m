From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 07:39:49 -0800
Message-ID: <54EF3E45.3070103@intel.com>
References: <20150226074214.GF2074@nanopsycho.orion>	<20150226083758.GA15139@vergenet.net>	<20150226091628.GA4059@nanopsycho.orion>	<20150226133326.GC23050@casper.infradead.org> <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com>
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
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>
To: Shrijeet Mukherjee <shrijeet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20960 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbbBZPkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:40:12 -0500
In-Reply-To: <CAGpadYGrjfkZqe0k7D05+cy3pY=1hXZtQqtV0J-8ogU80K7BUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 07:25 AM, Shrijeet Mukherjee wrote:
>     However, for certain datacenter server use cases we actually have the
>     full user intent in user space as we configure all of the kernel
>     subsystems from a single central management agent running locally
>     on the server (OpenStack, Kubernetes, Mesos, ...), i.e. we do know
>     exactly what the user wants on the system as a whole. This intent is
>     then split into small configuration pieces to configure iptables, tc,
>     routes on multiple net namespaces (for example to implement VRF).
> 
>     E.g. A VRF in software would make use of net namespaces which holds
>     tenant specific ACLs, routes and QoS settings. A separate action
>     would fwd packets to the namespace. Easy and straight forward in
>     software. OTOH, the hardware, capable of implementing the ACLs,
>     would also need to know about the tc action which selected the
>     namespace when attempting to offload the ACL as it would otherwise
>     ACLs to wrong packets.
> 
> 
> This is a new angle that I believe we have talked around in the context of user space policy, but not really considered.
> 
> So the issue is what if you have a classifier and forward action which points to a device which the element doing the classification does not have access to right ?
> 
> This problem obliquely showed up in the context of route table entries not in the "external" table but present in the software tables as well.
> 
> Maybe the scheme requires an implicit "send to software" device which then diverts traffic to the right place ? Would creating an implicit, un-offload device address these concerns ?

So I think there is a relatively simple solution for this. Assuming
I read the description correctly namely packet ingress' nic/switch
and you want it to land in a namespace.

Today we support offloaded macvlan's and SR-IOV. What I would expect
is user creates a set of macvlan's that are "offloaded" this just means
they are bound to a set of hardware queues and do not go through the
normal receive path. Then assigning these to a namespace is the same
as any other netdev.

Hardware has an action to forward to "VSI" (virtual station interface)
which matches on a packet and forwards it to either a VF or set of 
queues bound to a macvlan. Or you can do the forwarding using standards
based protocols such as EVB (edge virtual bridging).

So its a simple set of steps with the flow api,

	1. create macvlan with dfwd_offload set
	2. push netdev into namespace
	3. add flow rule to match traffic and send to VSI
		./flow -i ethx set_rule match xyz action fwd_vsi 3

The VSI# is reported by ip link today its a bit clumsy so that interface
could be cleaned up.

Here is a case where trying to map this onto a 'tc' action in software
is a bit awkward and you convoluted what is really a simple operation.
Anyways this is not really an "offload" in the sense that your taking
something that used to run in software and moving it 1:1 into hardware.
Adding SR-IOV/VMDQ support requries new constructs. By the way if you
don't like my "flow" tool and you want to move it onto "tc" that could
be done as well but the steps are the same.

.John
