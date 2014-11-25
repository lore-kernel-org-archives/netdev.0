From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Mon, 24 Nov 2014 22:43:51 -0800
Message-ID: <54742527.8000506@gmail.com>
References: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCDp2Cf=azOJvnm3_YRdsD5vwCafbcVFuseUaPuYKDA1g@mail.gmail.com> <547346EB.7060302@cumulusnetworks.com> <CAE4R7bAY2zMy4SiuwhdXyH2Swqv1KfkrBJ_ZwU_RYdCW3k+Mvg@mail.gmail.com> <loom.20141125T032621-877@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ronen Arad <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:40626 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaKYGoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 01:44:04 -0500
Received: by mail-oi0-f49.google.com with SMTP id i138so7606462oig.8
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 22:44:03 -0800 (PST)
In-Reply-To: <loom.20141125T032621-877@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2014 07:10 PM, Ronen Arad wrote:
> Scott Feldman <sfeldma <at> gmail.com> writes:
>
>>
>> On Mon, Nov 24, 2014 at 4:55 AM, Roopa Prabhu <roopa <at>
> cumulusnetworks.com> wrote:
>>> On 11/24/14, 2:18 AM, Scott Feldman wrote:
>>>>
>>>> Hi Roopa,
>>>>
>>>> I have a patch pending against Jiri's v2 that's uses existing
>>>> ndo_bridge_setlink/getlink to push policy settings down to port driver
>>>> for controlling HW offload.  I had to make a few tweaks, but for the
>>>> most part setlink/getlink already has the master/self semantics so
>>>> users can set policy flags on bridge's SW version of the port (master)
>>>> or on the offloaded version of the port (self).
>>>>     I added the new
>>>> hwmode option "swdev" to the existing "vepa"|"veb" choices.  When you
>>>> specify hwmode, SELF is set and the port driver's setlink get's
>>>> called.  Did you look at setlink/getlink?  It looks like the kernel
>>>> and iproute2 where going down this route of using setlink/getlink for
>>>> SELF policy, so I'm wondering if we need more?
>>>
>>> If i understand you correctly, this will mean the port driver implements
> the
>>> setlink/getlink with the  bridge port flags and attributes. And, it also
>>> means
>>> the port driver will parse the netlink msg instead of the bridge driver
>>> parsing all attributes and then calling offloads.
>>
>> Yes, exactly, the port driver parses/fills bridge_setlink/getlink
>> netlink msg to set/get port settings.  It's basically a passthru for
>> rtnl_bridge_setlink/getlink handling RTM_GETLNK/RTM_SETLINK on
>> PF_BRIDGE.
>>
>>> But, in cases where we want bridge port flags and attributes set both in
> hw
>>> and sw,
>>> the user (iproute2) will have to set both MASTER and SELF flags, and the
>>> netlink parsing will now happen in two places, the bridge driver and the
>>> bridge port
>>> driver ?
>>
>
> How does VLAN filtering is expected to work with an HW-offloaded bridge?
>
> When MASTER flag is set by iproute2 in the netlink message (or no flag is
>   set), br_setlink - the ndo_bridge_setlink function of the port's master
> bridge is called. It takes care of setting the VLAN policy in the
> net_port_vlans of the net_bridge_port. During this sequence the
> ndo_vlan_rx_add_vid function of the port dev is called. However, it only gets
> the vid. It does not have access to the flags (PVID, UNTAGGED) and those are
> not set in the net_port_vlans struct at that time.
>
> Giving the port driver access to the VLAN policy requires both MASTER and
> SLAVE flags to be set in the IFLA_BRIDGE_FLAGS attribute.
> Is the end user is expected to set both flags in the "bridge vlan add"
> command (Failing to do that will prevent the bridge and HW from being in
> sync)?
>

Correct. My expectation is if the user wants the software and hardware
tables to be in sync they should set both SELF and MASTER. If the user
sets only one of these then it indicates the user _wants_ to have
hw/sw out of sync.

> Even with both MASTER and SLAVE flags being set in a single netlink request,
> the HW and bridge could get out of sync if adding the VLAN policy to the port
> driver would fail after it was added to the bridge netdev.
> Is there any mechanism for keeping both software and HW in-sync?
>

Yep, my proposal to Roopa would be to abort the transaction and send
back an indication of where the failure occurred. This seems to me
to be the easiest option. We could implement a rollback mechanism but
I think that can be done in a second series if its needed.

> -Ronen
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
