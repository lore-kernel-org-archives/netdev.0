From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Mon, 17 Oct 2005 03:24:25 +0200
Message-ID: <4352FD49.4090201@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20051017.094919.56989341.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> In article <4352EEC8.9000602@trash.net> (at Mon, 17 Oct 2005 02:22:32 +0200), Patrick McHardy <kaber@trash.net> says:
> 
> 
>>[NETFILTER]: Make IPsec input processing symetrical to output
> 
> 
> I think this comment is not appropriate.
>  1. They are not "NETFILTER" but rather "CORE" IPv4/6 stack.
>  2. There are several known bad side effects.
>     They should be described.

The patches are work in progress, so I didn't spent much time
on descriptive changelog entries. The sideeffects of posting
packets to the stack again are incorrect statistics and
packet sockets see packets on each pass through the stack.
Which is actually not a bad sideeffect because it only affects
pure transport mode bundles with which the plain text packet is
currently not visible for tcpdump at all.

>>diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
>>--- a/net/ipv6/xfrm6_input.c
>>+++ b/net/ipv6/xfrm6_input.c
>>@@ -121,16 +121,21 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
>> 	skb->sp->len += xfrm_nr;
>> 	skb->ip_summed = CHECKSUM_NONE;
>> 
>>-	if (decaps) {
>>-		if (!(skb->dev->flags&IFF_LOOPBACK)) {
>>-			dst_release(skb->dst);
>>-			skb->dst = NULL;
>>-		}
>>-		netif_rx(skb);
>>-		return -1;
>>-	} else {
>>-		return 1;
>>+	if (!decaps) {
>>+		if (skb_cloned(skb) &&
>>+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
>>+			goto drop;
>>+		/* FIXME: Jumbo payload option */
>>+		skb->nh.ipv6h->payload_len = htons(skb->len);
>>+		__skb_push(skb, skb->data - skb->nh.raw);
>> 	}
>>+	if (!(skb->dev->flags&IFF_LOOPBACK)) {
>>+		dst_release(skb->dst);
>>+		skb->dst = NULL;
>>+	}
>>+	nf_reset(skb);
>>+	netif_rx(skb);
>>+	return -1;
>> 
>> drop_unlock:
>> 	spin_unlock(&x->lock);
> 
> 
> I diagree.
> Stack should process the packet just once if it is of transport mode.
> (It is okay to process one twice if it is of tunnel mode.)

For IPv6 this probably can be changed, I just kept the code in sync
for now. For IPv4 it is necessary to pass it through the entire stack
again to make netfilter fully usable without lots of code duplication
or unusual limitations, especially for NAT. So the question is whether
we want to keep the code and behaviour of IPv4 and IPv6 in sync or
not. I think we should.
