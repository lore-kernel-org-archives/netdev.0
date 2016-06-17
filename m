From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 13/18] net: Add offload kernel net stack packet
 type
Date: Fri, 17 Jun 2016 17:15:10 +0200
Message-ID: <576413FE.3010703@iogearbox.net>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com> <1466174639-14576-14-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, ast@fb.com
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53708 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932486AbcFQPPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 11:15:17 -0400
In-Reply-To: <1466174639-14576-14-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2016 04:43 PM, Saeed Mahameed wrote:
> From: Maor Gottlieb <maorg@mellanox.com>
>
> Add new packet type to skip kernel specific protocol handlers.
>
> This is needed so device drivers can pass packets up to user space
> (af_packet/tcpdump, etc..) without the need for them to go through
> the whole kernel data path.
>
> Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>   include/linux/skbuff.h         | 6 +++---
>   include/uapi/linux/if_packet.h | 1 +
>   net/core/dev.c                 | 4 ++++
>   3 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index dc0fca7..359724e 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -694,14 +694,14 @@ struct sk_buff {
>
>   /* if you move pkt_type around you also must adapt those constants */
>   #ifdef __BIG_ENDIAN_BITFIELD
> -#define PKT_TYPE_MAX	(7 << 5)
> +#define PKT_TYPE_MAX	(8 << 5)
>   #else
> -#define PKT_TYPE_MAX	7
> +#define PKT_TYPE_MAX	8
>   #endif

Aehm ... did you actually test this with BPF ?!

PKT_TYPE_MAX is a mask (naming could be better no doubt), see also function
convert_skb_access():

[...]
	case SKF_AD_PKTTYPE:
		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_TYPE_OFFSET());
		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, PKT_TYPE_MAX);
#ifdef __BIG_ENDIAN_BITFIELD
		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 5);
#endif
		break;
[...]

Also, dunno if it's worth burning a skb bit for one driver.

>   #define PKT_TYPE_OFFSET()	offsetof(struct sk_buff, __pkt_type_offset)
>
>   	__u8			__pkt_type_offset[0];
> -	__u8			pkt_type:3;
> +	__u8			pkt_type:4;
>   	__u8			pfmemalloc:1;
>   	__u8			ignore_df:1;
>   	__u8			nfctinfo:3;
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 9e7edfd..93a9f13 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -29,6 +29,7 @@ struct sockaddr_ll {
>   #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
>   #define PACKET_USER		6		/* To user space	*/
>   #define PACKET_KERNEL		7		/* To kernel space	*/
> +#define PACKET_OFFLOAD_KERNEL	8		/* Offload NET stack	*/
>   /* Unused, PACKET_FASTROUTE and PACKET_LOOPBACK are invisible to user space */
>   #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d40593b..f300f1a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4113,6 +4113,9 @@ another_round:
>   		pt_prev = ptype;
>   	}
>
> +	if (unlikely(skb->pkt_type == PACKET_OFFLOAD_KERNEL))
> +		goto done;
> +
>   skip_taps:
>   #ifdef CONFIG_NET_INGRESS
>   	if (static_key_false(&ingress_needed)) {
> @@ -4190,6 +4193,7 @@ ncls:
>   				       &skb->dev->ptype_specific);
>   	}
>
> +done:
>   	if (pt_prev) {
>   		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>   			goto drop;
>
