From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Wed, 29 Jun 2016 09:35:24 -0700
Message-ID: <5773F8CC.4090300@gmail.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
 <577211E2.90802@gmail.com>
 <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com>
 <5772A397.3010905@gmail.com> <5772B18A.9000300@gmail.com>
 <20160628184655.GB2089@nanopsycho.orion> <5772CA20.4030002@intel.com>
 <20160628191230.GC2089@nanopsycho.orion> <5772D091.9030709@gmail.com>
 <0327b6de-dfdf-8db2-1354-b7a4144dbc02@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33080 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbcF2Qmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:42:35 -0400
Received: by mail-ob0-f179.google.com with SMTP id xn17so33788702obc.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 09:42:18 -0700 (PDT)
In-Reply-To: <0327b6de-dfdf-8db2-1354-b7a4144dbc02@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-29 07:48 AM, Or Gerlitz wrote:
> On 6/28/2016 10:31 PM, John Fastabend wrote:
>> On 16-06-28 12:12 PM, Jiri Pirko wrote:
>>>
>>> Why?! Please, leave legacy be legacy. Use the new mode for
>>> implementing new features. Don't make things any more complicated :(
>>>
>> OK so how I read this is there are two things going on that are being
>> conflated together. Creating VF netdev's is linked to the PCIe
>> subsystems and brings VFs into the netdev model. This is a good thing
>> but doesn't need to be a global nic policy it can be per port hence
>> the ethtool flag vs devlink discussion. I don't actually have a use case
>> to have one port with VF netdevs and another without it so I'm not too
>> particular on this. Logically it looks like a per port setting because
>> the hardware has no issues with making one physical function create
>> a netdev for each of its VFs and the other one run without these
>> netdevs. This is why I called it out.
>>
>> How this relates to bridge, tc, etc. is now you have a identifier to
>> configure instead of using strange 'ip link set ... vf#' commands. This
>> is great. But I see no reason the hardware has to make changes to
>> the existing tables or any of this. Before we used 'bridge fdb' and 'ip
>> link' now we can use bridge tools more effectively and can deprecate
>> the overloaded use of ip. But again I see no reason to thrash the
>> forwarding state of the switch because we happen to be adding VFs.
>> Having a set of fdb rules to forward MAC/Vlan pairs (as we do now)
>> seems like a perfectly reasonable default. Add with this patch now
>> when I run 'fdb show' I can see the defaults.
>>
>> Maybe I'm reading to much into the devlink flag names and if instead
>> you use a switch like the following,
>>
>>    VF representer : enable/disable the creation VF netdev's to represent
>>                     the virtual functions on the PF
>>
>>
>> Much less complicated then magic switching between forwarding logic IMO
>> and you don't whack a default configuration that an entire stack (e.g.
>> libvirt) has been built to use.
> 
> 
> John,
> 
> I'll try to address here the core questions and arguments you brought.
> 

thanks. Also just to reiterate I really like the series just a few
details here.

> Re letting the user to observe/modify the rules added by the
> driver/firmware while legacy mode. Even if possible with bridge/fdb, it
> will be really pragmatical and doesn't make sense to get that donefor
> the TC subsystem. So this isn't a well defined solution and anyway, as
> you said, legacy mode enhancements is a different exercise. Personally,
> I agree with Jiri, that we should legacy be legacyand focus on adding
> the new model.
> 

The ixgbe driver already supports bridge and tc commands without the VF
representer.  Adding the VF representer to these drivers just extends
the existing support so we have an identifier for VFs and now the
redirect action works and the fdb commands can specify the VF netdevs.
I don't see this as a problem because we already do it today with
'ip' and bridge tools.

We are also slightly in disagreement about what the default should be
with VF netdevs. I think the default should be the same L2 mac/vlan
switch behavior and see no reason to change it by default just because
we added VF netdevs. The infrastructure libvirt/openstack/etc are built
around this default today. But I guess nothing in this series specifies
what the defaults of any given driver will be. VF netdevs are still
useful even on older hardware that only supports mac/vlan forwarding to
expose statistics and send/receive control frames such as lldp.

> The new model has few building blocks, and by all means, have the VF
> representors is not the full story, which is not magic but rather the
> following:
> 
> 1. VF (vport) representors netdevices + the needed mechanics
> (send-to-vport rules that makes xmit on VF rep --> recv on VF)
> 

We all agree on this. For me this should be its own knob VF netdevs or
no VF netdevs.

There is also my point that this is really a port attribute of the PCIe
configuration not a switch attribute.

> 2. handling HW data-patch misses --> send to CPU or drop

Yep need this also but we have a standard way to configure this already
with bridge and 'tc' so why have a toggle for it? Also you don't know
in the driver where I want to send missed packets. In some use cases I
have the VM is managing the system and in these cases I want to send
missed packets to a VF.

In ixgbe we get this for free (with the vf identifier netdevs) because
we have 'tc' and 'bridge' already hooked up. With 'tc' you can define
a wild card match with low priority and with 'bridge' model you can
setup the flood ports to do this.

> 
> 3. ability to offload SW rules (tc/bridge/etc) using VF representors and
> ingress qdiscs / bridge fdb rules / switchdev fdb rule, etc
> 
> The knob we suggested says that the system is put into a state where
> 1,2,3 are needed to make it full performance and functional one. This
> submission includes parts 1 and 2, so the offloading of SW rules will
> done in successive submission which uses TC offloads which are already
> upstream (u32 or flower).
> 
> So... we're almost in agreement, do you have another name for the knob
> that goes beyond creation/deletion of VF reps? maybe that would be it
> for making a progress...

The sticking point for me is (2) is not needed if you do (3)
correctly. So once you have implemented bridge and one of the 'tc'
classifiers that can be used to specify the policy in (2) and you don't
have a chunk policy being defined by the driver writer.

Just to put out an alternative if you add an ethtool feature flag 'VF
representer' so that I can specify enable/disable of VFs per port that
would resolve my concerns.

If you have this additional switch in devlink to hammer the datapath
between two switch modes that seems OK but I'm not sure who else other
than mlx drivers would use it. Additionally if you just used this
devlink hook to set the feature flag on each port and made it 'fixed'
from an ethtool perspective that would work for me as well. Then on
my devices that support VF representers per port I can configure it
and on the devices that can only do it globally it is configured with
this devlink thing.

Why I think the VF representer is a per port ethtool flag and not a
devlink option is my use case might be to assign a PF into a VM or
namespace where I don't want VF netdevs.

Thanks,
.John


> 
> Or.
> 
