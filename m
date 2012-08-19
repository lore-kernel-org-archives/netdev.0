From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve fragmentation
 handling
Date: Sun, 19 Aug 2012 21:44:35 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>  
 <1344542943-11588-6-git-send-email-kaber@trash.net>  <1345190795.3069.228.camel@localhost>
  <Pine.GSO.4.63.1208181423050.17600@stinky-local.trash.net>
 <1345405069.3069.241.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345405069.3069.241.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Aug 2012, Jesper Dangaard Brouer wrote:

> On Sat, 2012-08-18 at 14:26 +0200, Patrick McHardy wrote:
>>>
>>> Could you provide an iptables command/rule, that trigger this code path?
>>
>> The easiest way is a large ping with the NAT patches also applied,
>> in that case we also pass the first packet of a connection through
>> the stack reassembled.
>
> So, a fragmented IPv6 ICMPv6 packet, I assume?

Correct.

> Don't I need to load some of the helper modules, or just the
> nf_conntrack_ipv6 module, or perhaps only nf_defrag_ipv6 ?

Not with the entire patchset, just IPv6 conntrack is enough. Aith IPv6 NAT
the first packet of a connection must always be defragemented, independant
of an assigned helper.

>>>> @@ -199,9 +200,13 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
>>>>  static unsigned int __ipv6_conntrack_in(struct net *net,
>>>>  					unsigned int hooknum,
>>>>  					struct sk_buff *skb,
>>>> +					const struct net_device *in,
>>>> +					const struct net_device *out,
>>>>  					int (*okfn)(struct sk_buff *))
>>>>  {
>>>>  	struct sk_buff *reasm = skb->nfct_reasm;
>>>> +	struct nf_conn *ct;
>>>> +	enum ip_conntrack_info ctinfo;
>>>>
>>>>  	/* This packet is fragmented and has reassembled packet. */
>>>>  	if (reasm) {
>>>> @@ -213,6 +218,20 @@ static unsigned int __ipv6_conntrack_in(struct net *net,
>>>>  			if (ret != NF_ACCEPT)
>>>>  				return ret;
>>>>  		}
>>>> +
>>>> +		/* Conntrack helpers need the entire reassembled packet in the
>>>> +		 * POST_ROUTING hook.
>>>> +		 */
>>>> +		ct = nf_ct_get(reasm, &ctinfo);
>>>> +		if (ct != NULL && test_bit(IPS_HELPER_BIT, &ct->status)) {
>>>> +			nf_conntrack_get_reasm(skb);
>>>> +			NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
>>>> +				       (struct net_device *)in,
>>>> +				       (struct net_device *)out,
>>>> +				       okfn, NF_IP6_PRI_CONNTRACK + 1);
>>>
>>> Hook prio change to NF_IP6_PRI_CONNTRACK + 1
>>
>> I didn't get this part, you want to change to PRE_CONNTRACK + 1? What
>> about raw and SELinux?
>
> No - I don't want any changes.
>
> I was just pointing out *where* the changes occur in your patch. This is
> just a "service" to other email readers, so they can spot the changes
> faster, I were referring to.

Could you send me your patch so I get a better picture of what you're 
doing exactly?
