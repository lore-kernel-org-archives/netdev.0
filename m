From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Tue, 29 Nov 2005 08:02:34 +0100
Message-ID: <438BFD0A.5040105@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163137.16666.924.sendpatchset@localhost.localdomain>
	<20051128210628.GA15057@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051128210628.GA15057@gondor.apana.org.au>
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
> On Sun, Nov 20, 2005 at 04:31:37PM +0000, Patrick McHardy wrote:
> 
>>diff --git a/include/net/ip.h b/include/net/ip.h
>>index 9f09882..377036b 100644
>>--- a/include/net/ip.h
>>+++ b/include/net/ip.h
>>@@ -45,6 +45,7 @@ struct inet_skb_parm
>> #define IPSKB_TRANSLATED	2
>> #define IPSKB_FORWARDED		4
>> #define IPSKB_XFRM_TUNNEL_SIZE	8
>>+#define IPSKB_XFRM_TRANSFORMED	16
>> };
> 
> 
> My only question about this patch is where should we clear these flags?
> For instance, when ipip/gre transmits a packet, should this flag (and
> perhaps other flags here) be cleared?


Good point. This specific flags should be cleared when a packet
(re-)enters the IP stack, I guess by definition of the cb, this
holds for the other flags as well. Looking at the other flags:

- IPSKB_MASQUERADED is unused
- IPSKB_TRANSLATED is unused
- IPSKB_FORWARDED is used by ipmr in a way that looks broken,
   it expects the flags on the input path to be the same it set
   on the output path.
- IPSKB_XFRM_TUNNEL_SIZE should be cleared when a packet enters
   the IP stack

It seems in most places where only IPCB(skb)->opt is cleared
the entire CB should be cleared. A couple of spots also look
completely unnecessary, for example all places clearing the CB
before passing the packet to netif_rx. I would expect the next
user beeing responsible for clearing the space he needs if
neccessary.
