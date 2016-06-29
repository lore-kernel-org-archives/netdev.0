From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Wed, 29 Jun 2016 17:48:12 +0300
Message-ID: <0327b6de-dfdf-8db2-1354-b7a4144dbc02@mellanox.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
 <577211E2.90802@gmail.com>
 <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com>
 <5772A397.3010905@gmail.com> <5772B18A.9000300@gmail.com>
 <20160628184655.GB2089@nanopsycho.orion> <5772CA20.4030002@intel.com>
 <20160628191230.GC2089@nanopsycho.orion> <5772D091.9030709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0092.outbound.protection.outlook.com ([157.56.112.92]:6638
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751982AbcF2OtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 10:49:13 -0400
In-Reply-To: <5772D091.9030709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2016 10:31 PM, John Fastabend wrote:
> On 16-06-28 12:12 PM, Jiri Pirko wrote:
>>
>> Why?! Please, leave legacy be legacy. Use the new mode for implementing new features. Don't make things any more complicated :(
>>
> OK so how I read this is there are two things going on that are being
> conflated together. Creating VF netdev's is linked to the PCIe
> subsystems and brings VFs into the netdev model. This is a good thing
> but doesn't need to be a global nic policy it can be per port hence
> the ethtool flag vs devlink discussion. I don't actually have a use case
> to have one port with VF netdevs and another without it so I'm not too
> particular on this. Logically it looks like a per port setting because
> the hardware has no issues with making one physical function create
> a netdev for each of its VFs and the other one run without these
> netdevs. This is why I called it out.
>
> How this relates to bridge, tc, etc. is now you have a identifier to
> configure instead of using strange 'ip link set ... vf#' commands. This
> is great. But I see no reason the hardware has to make changes to
> the existing tables or any of this. Before we used 'bridge fdb' and 'ip
> link' now we can use bridge tools more effectively and can deprecate
> the overloaded use of ip. But again I see no reason to thrash the
> forwarding state of the switch because we happen to be adding VFs.
> Having a set of fdb rules to forward MAC/Vlan pairs (as we do now)
> seems like a perfectly reasonable default. Add with this patch now
> when I run 'fdb show' I can see the defaults.
>
> Maybe I'm reading to much into the devlink flag names and if instead
> you use a switch like the following,
>
>    VF representer : enable/disable the creation VF netdev's to represent
>                     the virtual functions on the PF
>
>
> Much less complicated then magic switching between forwarding logic IMO
> and you don't whack a default configuration that an entire stack (e.g.
> libvirt) has been built to use.


John,

I'll try to address here the core questions and arguments you brought.

Re letting the user to observe/modify the rules added by the 
driver/firmware while legacy mode. Even if possible with bridge/fdb, it 
will be really pragmatical and doesn't make sense to get that donefor 
the TC subsystem. So this isn't a well defined solution and anyway, as 
you said, legacy mode enhancements is a different exercise. Personally, 
I agree with Jiri, that we should legacy be legacyand focus on adding 
the new model.

The new model has few building blocks, and by all means, have the VF 
representors is not the full story, which is not magic but rather the 
following:

1. VF (vport) representors netdevices + the needed mechanics 
(send-to-vport rules that makes xmit on VF rep --> recv on VF)

2. handling HW data-patch misses --> send to CPU or drop

3. ability to offload SW rules (tc/bridge/etc) using VF representors and 
ingress qdiscs / bridge fdb rules / switchdev fdb rule, etc

The knob we suggested says that the system is put into a state where 
1,2,3 are needed to make it full performance and functional one. This 
submission includes parts 1 and 2, so the offloading of SW rules will 
done in successive submission which uses TC offloads which are already 
upstream (u32 or flower).

So... we're almost in agreement, do you have another name for the knob 
that goes beyond creation/deletion of VF reps? maybe that would be it 
for making a progress...

Or.
