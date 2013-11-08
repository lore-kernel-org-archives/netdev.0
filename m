From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] ip6_output: fragment outgoing reassembled
 skb properly
Date: Fri, 08 Nov 2013 14:49:15 -0500 (EST)
Message-ID: <20131108.144915.635810300359291522.davem@davemloft.net>
References: <1383756740-7392-2-git-send-email-jiri@resnulli.us>
	<20131107.185453.1341640661253119352.davem@davemloft.net>
	<20131108075201.GA2455@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537Ab3KHTtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 14:49:21 -0500
In-Reply-To: <20131108075201.GA2455@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 8 Nov 2013 08:52:01 +0100

> Fri, Nov 08, 2013 at 12:54:53AM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Wed,  6 Nov 2013 17:52:19 +0100
>>
>>> If reassembled packet would fit into outdev MTU, it is not fragmented
>>> according the original frag size and it is send as single big packet.
>>> 
>>> The second case is if skb is gso. In that case fragmentation does not happen
>>> according to the original frag size.
>>> 
>>> This patch fixes these.
>>> 
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ...
>>
>>>  	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
>>> -	    dst_allfrag(skb_dst(skb)))
>>> +	    dst_allfrag(skb_dst(skb)) ||
>>> +	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
>>>  		return ip6_fragment(skb, ip6_finish_output2);
>>
>>Jiri are you sure that you don't need to take GSO into account in the
>>new part you are adding to the test?
> 
> 
> For gso skb, we need co cap outgoing fragments by the original frag size
> as well. So I believe that this code is correct for that case as well.

I'm still not so sure I agree, even after having taken a second look
at this.

Look at ipv4's logic for this same facility:

		if (skb->len > ip_skb_dst_mtu(skb) && !skb_is_gso(skb))
			return ip_fragment(skb, ip_finish_output2);

Strictly, we only call ip_fragment() if skb_is_gso() is false.  And then
in ip_fragment():

	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
		     (IPCB(skb)->frag_max_size &&
		      IPCB(skb)->frag_max_size > dst_mtu(&rt->dst)))) {

And that second branch of this test is what you're trying to duplicate
into ipv6.

Perhaps I don't understand completely the intentions and logic of
dst_allfrag() in the ipv6 case, and maybe you can explain it to me.
