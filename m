From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Thu, 07 Feb 2013 00:24:14 +0900
Message-ID: <5112759E.90104@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38253 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755448Ab3BFPYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 10:24:16 -0500
In-Reply-To: <20130206121248.GC10290@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> On Wed, Feb 06, 2013 at 09:49:49AM +0100, Erik Hugne wrote:
>> It seems that packets sent to interface-local scoped multicast
>> addresses (ff01::/16) escape out on the network.
>> According to RFC4291 (section 2.7):
>>     Interface-Local scope spans only a single interface on a node
>>     and is useful only for loopback transmission of multicast.
>>
>> Example program here:
>> https://gist.github.com/Hugne/4721151
> 
> Fixing the output path should be relatively straightforward, please test
> the following patch.
> 
> Looking at the input path, I think there is also no input protection
> for ff01::/16 addresses from the wire if you bind such an address.
> 
> [PATCH net-next] ipv6: don't let node/interface scoped multicast traffic escape on the wire
> 
> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 906b7e6..b21ff3d 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -118,6 +118,12 @@ static int ip6_finish_output2(struct sk_buff *skb)
>  			}
>  		}
>  
> +		if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
> +		    IPV6_ADDR_SCOPE_NODELOCAL) {
> +			kfree_skb(skb);
> +			return 0;
> +		}
> +
>  		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
>  				skb->len);
>  	}
> 

NAK.  I think we should select routes via loopback device here.

--yoshfuji
