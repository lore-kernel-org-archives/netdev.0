From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is permitted
 on ingress
Date: Thu, 20 Dec 2012 11:54:15 -0500
Message-ID: <50D342B7.9010901@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com> <1355939304-21804-4-git-send-email-vyasevic@redhat.com> <20121220160713.30cdfc05@pixies.home.jungo.com> <50D331A8.3080206@redhat.com> <20121220182402.6143fcb1@pixies.home.jungo.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab2LTQyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 11:54:22 -0500
In-Reply-To: <20121220182402.6143fcb1@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 11:24 AM, Shmulik Ladkani wrote:
> On Thu, 20 Dec 2012 10:41:28 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>>>> +static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
>>>> +{
>>>> +	struct net_port_vlan *pve;
>>>> +	u16 vid;
>>>> +
>>>> +	/* If there are no vlan in the permitted list, all packets are
>>>> +	 * permitted.
>>>> +	 */
>>>> +	if (list_empty(&p->vlan_list))
>>>> +		return true;
>>>
>>> I assumed the default policy would be Drop in such case, otherwise
>>> leaking between vlan domains is possible.
>>> Or maybe, ingress policy when port isn't a member of ingress VID should
>>> be configurable (drop/allow).
>>
>> We have have to default to allow since we want to retain original bridge
>> functionality if there is no configuration.
>
> Ok; so having the port not a member of ANY vlan is a "port vlan
> disabled" configuration knob, and as such, it is a member of ANY vlan,
> meaning that:
>
> (1) every "non-vlan port" is connected to any other "non-vlan port"

Technically, it would be connected to every over port.

> (2) frame ingress on a "non-vlan" port may egress on a "vlan enabled"
>    port, depending on the ingress VID and the port-membership map of the
>    egress port
>    (and thus, PVID should be defined even to "non-vlan" ports, for the
>    case where untagged frame is received on the non-vlan port)

Sort of.  The way I did it (testing now), is like this:
    if there is egress policy
	apply policy and forward.
    else if there was ingress policy (pvid)
	apply it and forward
    else
	forward as is (old bridge behavior).

This way if there was a pvid on an ingress port and nothing on egress,
then pvid applies.  If there was nothing configured on ingress port,
but we have a egress policy, we'll apply any vlan information from
the frame to egress policy.  In this case, ingress untagged traffic 
would be assigned vlan 0.


> (3) frame ingress on a "vlan-enabled" port would always egress on
>    "non-vlan" ports

yes and they would egress based on their ingress policy.

>
> Seems ok.
> However this is an additional nuance that might not be expected by the
> user configuring the bridge; maybe this needs some clarification.

I'll try to document things sufficiently.  This hybrid approach may
produce some unintended results.  We could always remove it or introduce
the tunable to change default policy to drop once vlan configuration is
in effect.


>
>>>> +	vid = br_get_vlan(skb);
>>>> +	pve = nbp_vlan_find(p, vid);
>>>
>>> Why search by iterating through NBP's vlan_list?
>>> You know the VID (hence may fetch the net_bridge_vlan from the hash), so
>>> why don't you directly consult the net_bridge_vlan's port_bitmap?
>>
>> It's an alternative...  I am betting that this port isn't in too many
>> vlans and that searching the list might be faster.
>
> I assumed the opposite: finding the hash bucket is just a bitwise mask,
> and number of items in a bucket would rarely be grater than 1.
> I expect such code to be shorter, but this needs to be verified.

I'll try to set something up, but that will probably be next year...

-vlad
>
> Regards,
> Shmulik
>
