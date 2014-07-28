From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next V1 1/2] net: Header length compution function
Date: Mon, 28 Jul 2014 07:50:44 -0700
Message-ID: <53D66344.2050207@intel.com>
References: <1406546881-21863-1-git-send-email-amirv@mellanox.com> <1406546881-21863-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbaG1OvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 10:51:21 -0400
In-Reply-To: <1406546881-21863-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2014 04:28 AM, Amir Vadai wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> This commit is based on Eric Dumazet suggestion.
> Use flow dissector to calculate header length.
> Tested the following with a mlx4, and it indeed speeds up GRE traffic,
> as GRO packets can now contain 17 MSS instead of 8.
> (Pulling payload means GRO had to use 2 'frags' per MSS)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  include/linux/skbuff.h    |  1 +
>  net/core/flow_dissector.c | 24 ++++++++++++++++++++++++
>  2 files changed, 25 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index b613557..1f9af4d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3133,6 +3133,7 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
>  int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
>  
>  u32 __skb_get_poff(const struct sk_buff *skb);
> +u32 eth_frame_headlen(void *data, unsigned int len);
>  
>  /**
>   * skb_head_is_locked - Determine if the skb->head is locked down
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5f362c1..c3afd27 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -343,6 +343,30 @@ u32 __skb_get_poff(const struct sk_buff *skb)
>  	return poff;
>  }
>  
> +
> +/* Helper to find length of headers in an ethernet frame.
> + * This can help drivers to pull exact amount of bytes into
> + * skb->head to get optimal GRO performance.
> + * TODO: Could also return rxhash while we do a complete flow dissection.
> + */
> +u32 eth_frame_headlen(void *data, unsigned int len)
> +{
> +	const struct ethhdr *eth = data;
> +	struct sk_buff skb;
> +
> +	if (unlikely(len < ETH_HLEN))
> +		return len;
> +
> +	skb.protocol = eth->h_proto;
> +	skb.head = data + ETH_HLEN;
> +	skb.data = skb.head;
> +	skb_reset_network_header(&skb);
> +	skb.len = len - ETH_HLEN;
> +	skb.data_len = 0;
> +	return __skb_get_poff(&skb) + ETH_HLEN;
> +}

I'm still not a big fan of allocating an sk_buff on the stack.  Seems
like it isn't maintainable and really opens things up to possible issues
if someone ever extends the __skb_get_poff call.  But I'm not going to
force the issue since for now this isn't impacting igb or ixgbe.

Thanks,

Alex
