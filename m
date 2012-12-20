From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is permitted
 on ingress
Date: Thu, 20 Dec 2012 10:41:28 -0500
Message-ID: <50D331A8.3080206@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com> <1355939304-21804-4-git-send-email-vyasevic@redhat.com> <20121220160713.30cdfc05@pixies.home.jungo.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab2LTPld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 10:41:33 -0500
In-Reply-To: <20121220160713.30cdfc05@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 09:07 AM, Shmulik Ladkani wrote:
> Hi Vlad,
>
> On Wed, 19 Dec 2012 12:48:14 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>> +static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
>> +{
>> +	struct net_port_vlan *pve;
>> +	u16 vid;
>> +
>> +	/* If there are no vlan in the permitted list, all packets are
>> +	 * permitted.
>> +	 */
>> +	if (list_empty(&p->vlan_list))
>> +		return true;
>
> I assumed the default policy would be Drop in such case, otherwise
> leaking between vlan domains is possible.
> Or maybe, ingress policy when port isn't a member of ingress VID should
> be configurable (drop/allow).

We have have to default to allow since we want to retain original bridge 
functionality if there is no configuration.

>
>> +	vid = br_get_vlan(skb);
>> +	pve = nbp_vlan_find(p, vid);
>
> Why search by iterating through NBP's vlan_list?
> You know the VID (hence may fetch the net_bridge_vlan from the hash), so
> why don't you directly consult the net_bridge_vlan's port_bitmap?

It's an alternative...  I am betting that this port isn't in too many 
vlans and that searching the list might be faster.

>
>> @@ -54,6 +74,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
>>   	if (!p || p->state == BR_STATE_DISABLED)
>>   		goto drop;
>>
>> +	if (!br_allowed_ingress(p, skb))
>> +		goto drop;
>> +
>
> This condition should be also encorporated upon "ingress" at the "bridge
> master port" (that is, early at br_dev_xmit).
> Think of the "bridge master port" as yet another port:
> upon "ingress" (meaning, tx packets from the ip stack), we should
> also enforce any ingress permission rules.
>

I've tried that before and now can't think of a reason why I rejected 
it.  I'll try to remember...

Thanks
-vlad

> Regards,
> Shmulik
>
