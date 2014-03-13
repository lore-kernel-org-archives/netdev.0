From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH RFC 2/3] bridge: Prepare for 802.1ad vlan filtering support
Date: Thu, 13 Mar 2014 09:53:31 -0400
Message-ID: <5321B85B.1020203@redhat.com>
References: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <1394439067-10477-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <532098D2.6050504@redhat.com> <1394714017.4078.51.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbaCMNxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 09:53:37 -0400
In-Reply-To: <1394714017.4078.51.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2014 08:33 AM, Toshiaki Makita wrote:
> On Wed, 2014-03-12 at 13:26 -0400, Vlad Yasevich wrote:
>> On 03/10/2014 04:11 AM, Toshiaki Makita wrote:
>>> This enables a bridge to have vlan protocol informantion and allows vlan
>>> filtering code to take vlan protocols into account.
> ...
>>> @@ -173,16 +174,27 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>>>  		 * ingress frame is considered to belong to this vlan.
>>>  		 */
>>>  		*vid = pvid;
>>> -		if (likely(err))
>>> +		if (likely(err)) {
>>>  			/* Untagged Frame. */
>>> -			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
>>> -		else
>>> +			if (vlan_tx_tag_present(skb)) {
>>> +				/* skb->vlan_proto was different from br->vlan_proto */
>>> +				skb_push(skb, ETH_HLEN);
>>> +				skb = __vlan_put_tag(skb, skb->vlan_proto,
>>> +						     vlan_tx_tag_get(skb));
>>> +				if (unlikely(!skb))
>>> +					return false;
>>> +				skb_pull(skb, ETH_HLEN);
>>> +				skb_reset_mac_len(skb);
>>> +			}
>>> +			__vlan_hwaccel_put_tag(skb, proto, pvid);
>>
>> So this seems to be handling the case where we had a protocol mis-match.
>> My question is why are we hiding this case behind our inability to
>> fetch the vid from the packet.
>>
>> I think it might be clearer to make the protocol check explicit
>> (at least if we were to continue using the approach of defining
>>  the protocol per bridge).
> 
> I didn't intend to handle protocol mismatch, but handle the case where
> the vlan_tci we are about to use happens to be already used.
> In this function, it can occur only if the frame is originally tagged
> with another protocol.
> 
> However, indeed, we seem to need the check of skb->vlan_proto only at
> ingress.
> So it maybe makes sense to check the vid and the protocol separately.
> 
> I'm thinking of changing that code like this.
> 
> 	bool untagged;
> ...
> 	err = br_vlan_get_tag(skb, vid);
> 	if (!err) {
> 		if (skb->vlan_proto != proto) {
> 			...
> 			skb = __vlan_put_tag(...);
> 			...
> 			*vid = 0;
> 			untagged = true;
> 		} else {
> 			untagged = false;
> 		}
> 	} else {
> 		untagged = true;
> 	}
> 
> 	if (!*vid) {
> 		...
> 		if (likely(untagged)) {
> 			/* Untagged Frame. */
> 			...
> 		} else {
> 			/* Priority-tagged Frame.
> 			...
> 		}
> 	}
> 
>>
>> This code also has a side-effect that it would be permit 802.1ad packets
>> on an 802.1Q bridge and possibly forward such packets encapsulated yet
>> again.
> 
> Well, this is an interesting situation.
> But I have no reason to restrict it.
> Users can configure such an environment if they want.

This is almost like tunnel mode that is available on some switches.
Does it make sense to explicitly permit/restrict it?

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
> 
