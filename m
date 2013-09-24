From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Tue, 24 Sep 2013 13:55:24 -0400
Message-ID: <5241D20C.3060500@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>  <20130912.160033.779509034953932316.davem@davemloft.net>  <1379074013.1678.16.camel@localhost.localdomain>  <523744A6.5090001@redhat.com> <1379405552.6177.31.camel@ubuntu-vm-makita>  <524052FC.5010301@redhat.com> <1380023107.3162.53.camel@ubuntu-vm-makita>  <52419509.1020103@redhat.com> <1380043818.4391.26.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3IXRzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 13:55:36 -0400
In-Reply-To: <1380043818.4391.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2013 01:30 PM, Toshiaki Makita wrote:
> On Tue, 2013-09-24 at 09:35 -0400, Vlad Yasevich wrote:
>> On 09/24/2013 07:45 AM, Toshiaki Makita wrote:
>>> On Mon, 2013-09-23 at 10:41 -0400, Vlad Yasevich wrote:
>>>> On 09/17/2013 04:12 AM, Toshiaki Makita wrote:
>>>>> On Mon, 2013-09-16 at 13:49 -0400, Vlad Yasevich wrote:
>>>>>> On 09/13/2013 08:06 AM, Toshiaki Makita wrote:
>>>>>>> On Thu, 2013-09-12 at 16:00 -0400, David Miller wrote:
>>>>>>>> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>>>>>> Date: Tue, 10 Sep 2013 19:27:54 +0900
>>>>>>>>
>>>>>>>>> There seem to be some undesirable behaviors related with PVID.
>>>>>>>>> 1. It has no effect assigning PVID to a port. PVID cannot be applied
>>>>>>>>> to any frame regardless of whether we set it or not.
>>>>>>>>> 2. FDB entries learned via frames applied PVID are registered with
>>>>>>>>> VID 0 rather than VID value of PVID.
>>>>>>>>> 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
>>>>>>>>> This leads interoperational problems such as sending frames with VID
>>>>>>>>> 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
>>>>>>>>> 0 as they belong to VLAN 0, which is expected to be handled as they have
>>>>>>>>> no VID according to IEEE 802.1Q.
>>>>>>>>>
>>>>>>>>> Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
>>>>>>>>> is fixed, because we cannot activate PVID due to it.
>>>>>>>>
>>>>>>>> Please work out the issues in patch #2 with Vlad and resubmit this
>>>>>>>> series.
>>>>>>>>
>>>>>>>> Thank you.
>>>>>>>
>>>>>>> I'm hovering between whether we should fix the issue by changing vlan 0
>>>>>>> interface behavior in 8021q module or enabling a bridge port to sending
>>>>>>> priority-tagged frames, or another better way.
>>>>>>>
>>>>>>> If you could comment it, I'd appreciate it :)
>>>>>>>
>>>>>>>
>>>>>>> BTW, I think what is discussed in patch #2 is another problem about
>>>>>>> handling priority-tags, and it exists without this patch set applied.
>>>>>>> It looks like that we should prepare another patch set than this to fix
>>>>>>> that problem.
>>>>>>>
>>>>>>> Should I include patches that fix the priority-tags problem in this
>>>>>>> patch set and resubmit them all together?
>>>>>>>
>>>>>>
>>>>>> I am thinking that we might need to do it in bridge and it looks like
>>>>>> the simplest way to do it is to have default priority regeneration table
>>>>>> (table 6-5 from 802.1Q doc).
>>>>>>
>>>>>> That way I think we would conform to the spec.
>>>>>>
>>>>>> -vlad
>>>>>
>>>>> Unfortunately I don't think the default priority regeneration table
>>>>> resolves the problem because IEEE 802.1Q says that a VLAN-aware bridge
>>>>> can transmit untagged or VLAN-tagged frames only (the end of section 7.5
>>>>> and 8.1.7).
>>>>>
>>>>> No mechanism to send priority-tagged frames is found as far as I can see
>>>>> the standard. I think the regenerated priority is used for outgoing PCP
>>>>> field only if egress policy is not untagged (i.e. transmitting as
>>>>> VLAN-tagged), and unused if untagged (Section 6.9.2 3rd/4th Paragraph).
>>>>>
>>>>> If we want to transmit priority-tagged frames from a bridge port, I
>>>>> think we need to implement a new (optional) feature that is above the
>>>>> standard, as I stated previously.
>>>>>
>>>>> How do you feel about adding a per-port policy that enables a bridge to
>>>>> send priority-tagged frames instead of untagged frames when egress
>>>>> policy for the port is untagged?
>>>>> With this change, we can transmit frames for a given vlan as either all
>>>>> untagged, all priority-tagged or all VLAN-tagged.
>>>>
>>>> That would work.  What I am thinking is that we do it by special casing
>>>> the vid 0 egress policy specification.  Let it be untagged by default
>>>> and if it is tagged, then we preserve the priority field and forward
>>>> it on.
>>>>
>>>> This keeps the API stable and doesn't require user/admin from knowing
>>>> exactly what happens.  Default operation conforms to the spec and allows
>>>> simple change to make it backward-compatible.
>>>>
>>>> What do you think.  I've done a simple prototype of this an it seems to
>>>> work with the VMs I am testing with.
>>>
>>> Are you saying that
>>> - by default, set the 0th bit of untagged_bitmap; and
>>> - if we unset the 0th bit and set the "vid"th bit, we transmit frames
>>> classified as belonging to VLAN "vid" as priority-tagged?
>>>
>>> If so, though it's attractive to keep current API, I'm worried about if
>>> it could be a bit confusing and not intuitive for kernel/iproute2
>>> developers that VID 0 has a special meaning only in the egress policy.
>>> Wouldn't it be better to adding a new member to struct net_port_vlans
>>> instead of using VID 0 of untagged_bitmap?
>>>
>>> Or are you saying that we use a new flag in struct net_port_vlans but
>>> use the BRIDGE_VLAN_INFO_UNTAGGED bit with VID 0 in netlink to set the
>>> flag?
>>>
>>> Even in that case, I'm afraid that it might be confusing for developers
>>> for the same reason. We are going to prohibit to specify VID with 0 (and
>>> 4095) in adding/deleting a FDB entry or a vlan filtering entry, but it
>>> would allow us to use VID 0 only when a vlan filtering entry is
>>> configured.
>>> I am thinking a new nlattr is a straightforward approach to configure
>>> it.
>>
>> By making this an explicit attribute it makes vid 0 a special case for
>> any automatic tool that would provision such filtering.  Seeing vid 0
>> would mean that these tools would have to know that this would have to
>> be translated to a different attribute instead of setting the policy
>> values.
>
> Yes, I agree with you that we can do it by the way you explained.
> What I don't understand is the advantage of using vid 0 over another way
> such as adding a new nlattr.
> I think we can indicate transmitting priority-tags explicitly by such a
> nlattr. Using vid 0 seems to be easier to implement than a new nlattr,
> but, for me, it looks less intuitive and more difficult to maintain
> because we have to care about vid 0 instead of simply ignoring it.
>

The point I am trying to make is that regardless of the approach someone
has to know what to do when enabling priority tagged frames.  You 
proposal would require the administrator or config tool to have that 
knowledge.  Example is:
	Admin does: bridge vlan set priority on dev eth0
         Automated app:
		if (vid == 0)
			/* Turn on priority tagged frame support */

My proposal would require the bridge filtering implementation to have it.
	user tool: bridge vlan add vid 0 tagged
	Automated app:  No special case.

IMO its better to have 1 piece code handling the special case then 
putting it multiple places.

Thanks
-vlad

> Thanks,
>
> Toshiaki Makita
>
>>
>> How it is implemented internally in the kernel isn't as big of an issue.
>> We can do it as a separate flag or as part of existing policy.
>>
>> -vlad
>>
>>>
>>> Thanks,
>>>
>>> Toshiaki Makita
>>>
>>>>
>>>> -vlad
>>>>
>>>>>
>>>>> Thanks,
>>>>>
>>>>> Toshiaki Makita
>>>>>
>>>>>>
>>>>>>>
>>>>>>> Thanks,
>>>>>>>
>>>>>>> Toshiaki Makita
>>>>>>>
>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>
>>>
>>
>
>
