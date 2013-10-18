From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 10:32:09 -0400
Message-ID: <52614669.5040301@redhat.com>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com> <20131017112857.GA11318@localhost> <20131017113735.GB2699@open-mesh.com> <20131018111041.GA10964@localhost> <20131018113555.GK2596@neomailbox.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Antonio Quartulli <antonio@meshcoding.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754829Ab3JROcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 10:32:21 -0400
In-Reply-To: <20131018113555.GK2596@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 07:35 AM, Antonio Quartulli wrote:
> On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
>> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
>>> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
>>>> Hi,
>>>>> +
>>>>> +/**
>>>>> + * br_netfilter_skb_free - clean the NF bridge data in an skb
>>>>> + * @skb: the skb which the data to free belongs to
>>>>> + */
>>>>> +void br_netfilter_skb_free(struct sk_buff *skb)
>>>>> +{
>>>>> +	nf_bridge_put(skb->nf_bridge);
>>>>> +	skb->nf_bridge = NULL;
>>>>> +}
>>>>
>>>> This should be nf_reset.
>>>
>>> You think I should directly use nf_reset instead of this function?
>>>
>>> I see that nf_reset() cleans up the conntrack part too: does it also become
>>> useless once the packet exits the bridge interface?
>>
>> The conntrack should not attached if it's forwarded to another netif,
>> see dev_forward_skb.
>>
>> But I'm not sure what scenario you're trying to handle with this
>> change, if you could please elaborate.
>
>
> This is a sample scenario (nf bridge is on):
>
> [eth0] ---> [br0] ---> [bat0] ---> [br1]
>

Another possible config that is out in the wild is

[eth0] ---> [br0] ---> [vlanX] ----> [br1]


> where the relation '[a] ---> [b]' means 'a is enslaved in b' (bat0 is a
> batman-adv virtual interface..in this situation it should not matter: it
> just removs an header from an incoming skb and delivers it).
>
> The problem I was having was due to an skb entering br0 first and br1 later.
> When reaching br1 skb->nf_bridge was != NULL because of the previous processing
> in br0.
>

Doesn't br_nf_pre_routing already take care of this for you?  It will 
drop the ref on the current nf_bridge and allocate a new one.  Is that
not sufficient?

-vlad

> To clarify, the packet arriving on eth0 is 'delivered' to br0. It is not
> forwarded to another port of the bridge. Therefore I am not sure that we should
> clean the conntrack part too.
>
>>
>> Perhaps your fix is more conservative to avoid breaking strange setups
>> that have been relying on this behaviour. I know of people deploying
>> strange configurations using netfilter bridge.
>>
>
> could be.
>
> Cheers,
>
