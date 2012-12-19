From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 17:59:27 -0500
Message-ID: <50D246CF.90009@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com> <20121219101006.7086faef@pixies.home.jungo.com> <50D1CB76.50202@redhat.com> <20121219213716.778d6449.shmulik.ladkani@gmail.com> <50D21D98.7020907@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab2LSW7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 17:59:31 -0500
In-Reply-To: <50D21D98.7020907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 03:03 PM, Vlad Yasevich wrote:
> On 12/19/2012 02:37 PM, Shmulik Ladkani wrote:
>> Hi Vlad,
>>
>> On Wed, 19 Dec 2012 09:13:10 -0500 Vlad Yasevich <vyasevic@redhat.com>
>> wrote:
>>>> Why the "untagged vlan" is per-bridge global?
>>> It's not.  There is a per port untagged pointer where you can designate
>>> which VLAN is untagged/native on a port.
>>
>> Ok (misinterpreted the text in the cover letter).
>>
>>>> 802.1q switches usually allow conifguring per-vlan, per-port
>>>> tagged/untagged egress policy: each vid has its port membership map and
>>>> an accompanying port egress-policy map.
>>>> This gives great flexibility defining all sorts of configurations.
>>>
>>> Right, and that's what's provided here.
>>>    * Each VLAN has port membership map (net_bridge_vlan.portgroup).
>>>    * Each port has a list of vlans configured as well
>>> (net_port_vlan.vlan_list).
>>>    * Each port also has a single vlan that can be untagged
>>> (net_bridge_port.untagged).
>>>    * The bridge also has a single untagged vlan (net_bridge.untagged)
>>>
>>> The limitation (in switches as well) is that only a single VLAN
>>> may be untagged on any 1 port.
>>
>> Switches usually allow you to configure each port's egress policy per
>> vlan, and allow you to configure multiple vlans to _egress_ untagged
>> on a port.
>>
>>> If you have more then 1, you don't know
>>> which VLAN the untagged traffic belongs to.
>>
>> The port's PVID uniquely determines VID to associate with the frame
>> during _ingress_ on that port - in the case frame arrived untagged.
>>
>> This is unrelated to whether a frame having a specific VID would _egress_
>> tagged or untagged on that port.
>>
>
>
> Ahh...  I see what you mean.  You would like to separate
> ingress policy and egress policy with regard to how tags are applied...
> I haven't seen that type of config before.
>
> I did say "Basic VLAN support". :)
>
> In this set of patches ingress and egress policies are hardcoded the
> same...
>
> So, consider that what I am calling "untagged" in this series is
> really vlan associated with PVID.  To change the egress policy, we
> could add an untagged bitmap into the vlan.  Then the bitmap from the
> vlan would determine the egress policy.  If the port is in the "tagged"
> bitmap, frame leaves tagged. If the port is in the "untagged" bitmap,
> frame leaves untagged.
>
> The code to make this would would be simple enough.  The more
> interesting part would be the configuration :)


Actually, this looks much simpler then I originally thought.  I think I 
might have something half-baked tomorrow.

-vlad

>
>
>>>> Personally, I'd prefer a fully flexible vlan bridge allowing all sorts
>>>> of configurations (as available in 802.1q switches).
>>>>
>>>> What's the reason limiting such configurations?
>>>
>>> So, what do you see that's missing?
>>
>
> [ snip good example ]
>
>>
>> The bridge constructs needed for supporting such setups are:
>> - per port: PVID
>> - per VLAN: port membership map
>> - per VLAN: port egress policy map
>
> Ok, so from above, membership map is the exiting port_bitmap.  Egress
> policy map could be new untagged_bitmap.  We wouldn't need a tagged
> policy map since a port can't be "in egress policy, but not in
> membership map".
>
> Membership port_bitmap is consulted on egress for basic forward/drop
> decision (just as it is now).  Egress policy (untagged bitmap) is
> consulted to see how the forwarding is done.
>
> Sounds about right?  If so, I could probably work something up.
> Will probably leave the configuration for later as that might take a bit
> longer to figure out.
>
> -vlad
>
>>
>> I agree, tools other than a vlan bridge may implement such setups, but
>> using the vlan bridge would be preferred, mainly due to the simplicity.
>>
>> Regards,
>> Shmulik
>>
>
