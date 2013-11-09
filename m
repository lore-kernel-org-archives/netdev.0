From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] ip6_output: fragment outgoing reassembled
 skb properly
Date: Sat, 9 Nov 2013 12:00:53 +0100
Message-ID: <20131109110053.GA2447@minipsycho.orion>
References: <1383756740-7392-2-git-send-email-jiri@resnulli.us>
 <20131107.185453.1341640661253119352.davem@davemloft.net>
 <20131108075201.GA2455@minipsycho.orion>
 <20131108.144915.635810300359291522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:46391 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab3KILA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 06:00:58 -0500
Received: by mail-ee0-f52.google.com with SMTP id e49so1489942eek.39
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 03:00:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131108.144915.635810300359291522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 08, 2013 at 08:49:15PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 8 Nov 2013 08:52:01 +0100
>
>> Fri, Nov 08, 2013 at 12:54:53AM CET, davem@davemloft.net wrote:
>>>From: Jiri Pirko <jiri@resnulli.us>
>>>Date: Wed,  6 Nov 2013 17:52:19 +0100
>>>
>>>> If reassembled packet would fit into outdev MTU, it is not fragmented
>>>> according the original frag size and it is send as single big packet.
>>>> 
>>>> The second case is if skb is gso. In that case fragmentation does not happen
>>>> according to the original frag size.
>>>> 
>>>> This patch fixes these.
>>>> 
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ...
>>>
>>>>  	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
>>>> -	    dst_allfrag(skb_dst(skb)))
>>>> +	    dst_allfrag(skb_dst(skb)) ||
>>>> +	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
>>>>  		return ip6_fragment(skb, ip6_finish_output2);
>>>
>>>Jiri are you sure that you don't need to take GSO into account in the
>>>new part you are adding to the test?
>> 
>> 
>> For gso skb, we need co cap outgoing fragments by the original frag size
>> as well. So I believe that this code is correct for that case as well.
>
>I'm still not so sure I agree, even after having taken a second look
>at this.
>
>Look at ipv4's logic for this same facility:
>
>		if (skb->len > ip_skb_dst_mtu(skb) && !skb_is_gso(skb))
>			return ip_fragment(skb, ip_finish_output2);
>
>Strictly, we only call ip_fragment() if skb_is_gso() is false.  And then
>in ip_fragment():
>
>	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
>		     (IPCB(skb)->frag_max_size &&
>		      IPCB(skb)->frag_max_size > dst_mtu(&rt->dst)))) {
>
>And that second branch of this test is what you're trying to duplicate
>into ipv6.

That is a different check and the same one is already in ip6_fragment().

You cannot compare this to ipv4 directly. In ipv4 if frag skbs are
reassembled into one, they can be forwarded out in different frag sizes
(bigger or smaller) or not in frags at all. Therefore you can lay off
the work to offload.

But for ipv6, the same frags need to go out as they came in. Offload would
not do that as it would try to max the flag sizes to the MTU ->
That is exactly why I add the "skb->len > IP6CB(skb)->frag_max_size" check.

Imagine scenario:

hostA-NIC(MTU1400) ------ NIC(MTU1400)-hostB-NIC(MTU1500) ------ NIC(MTU1500)-hostC

And fragmented packets go hostA->hostB->hostC, and we are doing
forwadring on hostB.

I hope I cleared this out. 
