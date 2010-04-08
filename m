From: Patrick McHardy <kaber@trash.net>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 15:23:34 +0200
Message-ID: <4BBDD8D6.60701@trash.net>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au> <20100408.051144.183699401.davem@davemloft.net> <20100408123025.GA23762@gondor.apana.org.au> <4BBDD0ED.1010203@trash.net> <20100408131254.GA24262@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37200 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758420Ab0DHNXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 09:23:37 -0400
In-Reply-To: <20100408131254.GA24262@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 08, 2010 at 02:49:49PM +0200, Patrick McHardy wrote:
>> Yes, that looks difficult. What might work is to pass the skb->data
>> offsets resulting from those modifications to sk_run_filter to
>> adjust the postition when loading data from the packet. That would
>> allow to run the filter on the original packet before cloning it.
> 
> The thing is we can't express those offsets as constants so we'll
> need to run protocol-specific code (i.e., an indirect function
> call) prior to calling the filter.

Well, we already have some AF_PACKET specific code in
dev_queue_xmit_nit(). It wouldn't be pretty, but for this special
case we could just calculate the offsets in a non-generic way
without indirect function calls. It basically comes down to:

if (ptype->af_packet_priv &&
    dev->header_ops) {
	if (((struct sock *)ptype->af_packet_priv)->sk_type != SOCK_DGRAM)
		offset = skb->data - skb_mac_header(skb);
	else /* always PACKET_OUTGOING in dev_queue_xmit_nit */
		offset = skb_network_offset(skb);
}

> At that point I'd just give up and go back to the skb_share idea :)

That does sound better :)

> If we're concerned about atomic counter performance, we could even
> do a non-atomic version of skb_share and use it here.  We're the
> sole owner of the skb at this point.
> 
>> Regarding your idea of only receiving incoming packets, userspace could
>> use the SKF_AD_PKTTYPE filter with PACKET_HOST. During filter attachment
>> and checks, we could mark the socket as only interested in incoming or
>> outgoing packets.
>>
>> This would require userspace changes of course, but we should be able
>> to avoid passing outgoing packets to af_packet with very low overhead.
> 
> As kernel programmers, we reject in principle any solution that
> involves user-space coding :)
> 
> Seriously, with the number of DHCP clients out there, any solution
> that requires changing the client is not going to achieve the
> objective in a reasonable time-frame.

That's true.
