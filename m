From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2x: uses build_skb() in receive path
Date: Mon, 14 Nov 2011 14:22:11 -0500 (EST)
Message-ID: <20111114.142211.330605745315729442.davem@davemloft.net>
References: <1321286734.2272.48.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321289329.3101.7.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, therbert@google.com, hadi@mojatatu.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	herbert@gondor.hengli.com.au, jeffrey.t.kirsher@intel.com,
	pstaszewski@itcare.pl
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1KNTX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:23:28 -0500
In-Reply-To: <1321289329.3101.7.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 14 Nov 2011 18:48:49 +0200

> On Mon, 2011-11-14 at 08:05 -0800, Eric Dumazet wrote:
>> bnx2x uses following formula to compute its rx_buf_sz :
>> 
>> dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8 + 2
>> 
>> Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
>> skb_shared_info))
>> 
>> Final allocated size for skb head on x86_64 (L1_CACHE_BYTES = 64,
>> MTU=1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.
>> 
>> Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot of
>> false sharing because of mem_reclaim in UDP stack.
>> 
>> One possible way to half truesize is to reduce the need by 64 bytes
>> (2112 -> 2048 bytes)
>> 
>> Instead of allocating a full cache line at the end of packet for
>> alignment, we can use the fact that skb_shared_info sits at the end of
>> skb->head, and we can use this room, if we convert bnx2x to new
>> build_skb() infrastructure.
>> 
>> skb_shared_info will be initialized after hardware finished its
>> transfert, so we can eventually overwrite the final padding.
>> 
>> Using build_skb() also reduces cache line misses in the driver, since we
>> use cache hot skb instead of cold ones. Number of in-flight sk_buff
>> structures is lower, they are recycled while still hot.
>> 
>> Performance results :
>> 
>> (820.000 pps on a rx UDP monothread benchmark, instead of 720.000 pps)
> 
> Wow! This is very impressive. The only problem will be to back port this
> driver now... But it is definitely worth the effort :)

Applied.
