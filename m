From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 04 Dec 2005 23:06:02 +0100
Message-ID: <4393684A.8030208@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<20051201012711.GA2527@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051201012711.GA2527@gondor.apana.org.au>
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

Herbert Xu wrote:
> On Sun, Nov 20, 2005 at 04:31:36PM +0000, Patrick McHardy wrote:
> 
>>@@ -145,7 +149,17 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
>> 		netif_rx(skb);
>> 		return 0;
>> 	} else {
>>+#ifdef CONFIG_NETFILTER
>>+		__skb_push(skb, skb->data - skb->nh.raw);
>>+		skb->nh.iph->tot_len = htons(skb->len);
>>+		ip_send_check(skb->nh.iph);
>>+
>>+		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
>>+		        ip_xfrm_transport_hook);
>>+		return 0;
>>+#else
>> 		return -skb->nh.iph->protocol;
>>+#endif
> 
> 
> I'm worried about this bit.  This looks like it'll go back to the top
> of the IP stack with the existing call chain.  So could grow as the
> number of transforms increase.

Its not so bad. It adds ip_xfrm_transport_hook and
ip_local_deliver_finish to the call stack, but since two subsequent
transport mode SAs are always processed at once it can't take this
path again without calling netif_rx in between.

> Perhaps we need to play a dst_input/netif_rx trick here.
> 
> Actually, was there a problem with your original netif_rx approach
> apart from the issue with double counting?

Besides the double counting, packets also appear on the packet sockets
after transport mode decapsulation with the original approach. For
IPv6 there's also the double-parsing of extension header issue.
