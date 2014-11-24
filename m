From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Mon, 24 Nov 2014 15:00:04 -0800
Message-ID: <5473B874.1010005@cumulusnetworks.com>
References: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCDp2Cf=azOJvnm3_YRdsD5vwCafbcVFuseUaPuYKDA1g@mail.gmail.com> <547346EB.7060302@cumulusnetworks.com> <CAE4R7bAY2zMy4SiuwhdXyH2Swqv1KfkrBJ_ZwU_RYdCW3k+Mvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	John Linville <linville@tuxdriver.com>, nhorman@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	vyasevic@redhat.com, Florian Fainelli <f.fainelli@gmail.com>,
	buytenh@wantstofly.org, Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40041 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaKXXAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 18:00:10 -0500
In-Reply-To: <CAE4R7bAY2zMy4SiuwhdXyH2Swqv1KfkrBJ_ZwU_RYdCW3k+Mvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/14, 12:48 PM, Scott Feldman wrote:
> On Mon, Nov 24, 2014 at 4:55 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 11/24/14, 2:18 AM, Scott Feldman wrote:
>>> Hi Roopa,
>>>
>>> I have a patch pending against Jiri's v2 that's uses existing
>>> ndo_bridge_setlink/getlink to push policy settings down to port driver
>>> for controlling HW offload.  I had to make a few tweaks, but for the
>>> most part setlink/getlink already has the master/self semantics so
>>> users can set policy flags on bridge's SW version of the port (master)
>>> or on the offloaded version of the port (self).
>>>     I added the new
>>> hwmode option "swdev" to the existing "vepa"|"veb" choices.  When you
>>> specify hwmode, SELF is set and the port driver's setlink get's
>>> called.  Did you look at setlink/getlink?  It looks like the kernel
>>> and iproute2 where going down this route of using setlink/getlink for
>>> SELF policy, so I'm wondering if we need more?
>> If i understand you correctly, this will mean the port driver implements the
>> setlink/getlink with the  bridge port flags and attributes. And, it also
>> means
>> the port driver will parse the netlink msg instead of the bridge driver
>> parsing all attributes and then calling offloads.
> Yes, exactly, the port driver parses/fills bridge_setlink/getlink
> netlink msg to set/get port settings.  It's basically a passthru for
> rtnl_bridge_setlink/getlink handling RTM_GETLNK/RTM_SETLINK on
> PF_BRIDGE.
This will duplicate msg parsing code and validation code in the kernel 
bridge driver and in all the port drivers.
If this is the path we plan to go down on,...it will also mean we will 
do the same thing
for bonds, vxlans and maybe others in the future.

In the mode where kernel and hw state need to remain in sync,
I am also concerned about how we handle failure cases.

I think we will have cases where the kernel will set the attribute and 
hw will fail. In which case can we rollback ?

>> But, in cases where we want bridge port flags and attributes set both in hw
>> and sw,
>> the user (iproute2) will have to set both MASTER and SELF flags, and the
>> netlink parsing will now happen in two places, the bridge driver and the
>> bridge port
>> driver ?
> Yes, that's correct.  That seems to be the intent of the current
> design based on the existing code.  I had to do minor changes to get
> brport flags passed back up in getlink, but for the most part the
> kernel code and iproute2 code where already setup to support this dual
> master/self model.  As an example, let's consider the flags
> IFLA_BRPORT_LEARNING.  User can set learning on/off on bridge's port
> (master) and can independently set learning on/off on port driver
> (self) in HW.  So for typical swdev setups, the port driver would
> default to learning ON and the bridge would default to learning ON.
> The user would probably want to turn learning OFF on the bridge, but
> all combinations of ON/OFF are available.  A better example is
> IFLA_BRPORT_FLOOD.  If we had a single flag that applied to both
> master and self, we'd run into trouble in the flooding ON case.  We
> don't want both the HW and bridge driver flooding as this would result
> in duplicate egress pkts.  If we turn flooding OFF, then neither HW or
> SW flood and our bridge is broken.  So we want SW bridge (master)
> flooding OFF and port driver (self) have flooding ON, for the
> optimized HW-offload case.
>
>> For bridge stp state updates, the bridge driver will call the ports->setlink
>> ndo op ?
> No, we added a new ndo op to communicate STP state changes to port
> driver.  STP state transitions don't really fit into the
> setlink/getlink model, although you reminded me there was a request
> for a policy flag to turn STP pushes down to port driver ON/OFF.
>
>> (We should probably rename the ndo_bridge_setlink to ndo_setlink)
> The name seems correct as they're specific to RTM_GETLNK/SETLNK for PF_BRIDGE.

But, SETLINK/GETLINK Is general across all link objects. It can be bonds 
and vxlan interfaces too.

>
>>> On FDB entries, using master/self semantics that exist, it's clear
>>> which are owned by offloaded device and which are owned by bridge.
>>> The one missing annotation was a flag indicating FDB entry in bridge
>>> was synced from device.  And a policy flag to turn on/off syncing from
>>> the device.  The policy flag is just another IFLA_BRPORT flags passed
>>> with setlink/getlink.
>>>
>>> The setlink/getlink patch will go out in v3 once I finish testing it
>>> and push it to Jiri.  Hopefully tomorrow.
>>
>> In my patches, I used newlink..., but in most cases all attributes set via
>> newlink can be
>> used with setlink and hence getlink. So, i think we are close here.
>>
>> But, Oh wait, i am talking about rtnl_link_ops
>> ->newlink/changelink/getlink/dellink. I did not
>> realize there was a parallel ndo op to this. But thats probably because,
>> rtnl_link_ops can be
>> used only for logical devices. But, i see bridge driver implementing both
>> the
>> rtnl_link_ops changelink and ndo op setlink. hmm..seems like a lot of
>> duplication.
>> Will look closely some more.
>>
>>
>> Coming back to my series, i was trying to get a common set of flags for all
>> netdevs
>> (bridge, bond, vxlans so far), and hence the common flag in 'struct
>> ifiinfomsg'.
>>
>> But, I am all for using existing infrastructure if it fits well.
> Jiri updated his net-next-rocker tree with my latest but hasn't pushed
> out v3 yet.  You can see for bridging at least we now have the policy
> flag support for master/self without much heavy lifting in kernel or
> iproute2 code.  It seems like the right move at this time, with low
> chance of regressions or breaking backward compat.
>
>> For the fdb offloads, the NTF_SELF and NTF_MASTER is in 'struct
>> ndmsg->ndm_flags', which is also
>> what i was proposing. So, ack there.
> Ya, for FDB, the master/self model works slick and support is already
> there so we should use it.
>
>> For the bridge netdev, using the flag in IFLA_BRIDGE_FLAGS, is also ok.
> Agreed.
>
>> I will look at your patches when they are out.
> v3 is imminent.  You can pull net-next-rocker now to look it over.
>
>
ok, thanks.
