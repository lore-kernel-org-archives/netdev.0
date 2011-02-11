From: David Miller <davem@davemloft.net>
Subject: Re: GRO/GSO hiding PMTU?
Date: Thu, 10 Feb 2011 22:22:16 -0800 (PST)
Message-ID: <20110210.222216.104050992.davem@davemloft.net>
References: <20110210.145555.39165146.davem@davemloft.net>
	<20110210235022.GA25293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751048Ab1BKGVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 01:21:40 -0500
In-Reply-To: <20110210235022.GA25293@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 11 Feb 2011 10:50:22 +1100

> On Thu, Feb 10, 2011 at 02:55:55PM -0800, David Miller wrote:
>>
>> I suspect that the packet arrives on eth1, accumulates into GRO, and
>> thus marked as GSO as well, then GSO/TSO on output to eth0 is
>> re-segmenting things transparently, and we're not getting the ICMP
>> frag-needed message and the packet drop because of the skb_is_gso()
>> check in ip_forward().
>> 
>> 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
>> 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
>> 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
>> 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>> 			  htonl(dst_mtu(&rt->dst)));
>> 		goto drop;
>> 	}
>> 
>> So if that's what is happening, that's cute, but I think we need to
>> fix this :-)
> 
> Yes this is a known problem and we do need to fix this, even if
> it doesn't appear to be the cause of your immediate issue :)

I gave it a shot but it isn't easy.  We can figure out the length of
the IP headers just fine, but the rest of the value we need to add
to the MSS (the TCP header length) is transport specific which kind
of implies a transport dependent gso proto op of some sort.

Or we just hack it, admit that only TCP creates GSO packets, and
directly check for TCP protcol and then inspect the TCP header
length :-)
