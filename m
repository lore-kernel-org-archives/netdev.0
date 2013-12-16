From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 3/3] packet: Deliver VLAN TPID to userspace
Date: Mon, 16 Dec 2013 11:18:09 +0100
Message-ID: <52AED361.2070303@redhat.com>
References: <87mwk16wpy.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	David Laight <David.Laight@ACULAB.COM>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645Ab3LPKST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:18:19 -0500
In-Reply-To: <87mwk16wpy.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 09:12 AM, Atzm Watanabe wrote:
> This enables userspace to get VLAN TPID as well as the VLAN TCI.
>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Looks good, one comment below though:

> ---
>   include/uapi/linux/if_packet.h | 23 +++++++++++++----------
>   net/packet/af_packet.c         | 13 +++++++++----
>   2 files changed, 22 insertions(+), 14 deletions(-)
>
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 9185dc9..22d5192 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -84,17 +84,18 @@ struct tpacket_auxdata {
>   	__u16		tp_mac;
>   	__u16		tp_net;
>   	__u16		tp_vlan_tci;
> -	__u16		tp_padding;
> +	__u16		tp_vlan_tpid;
>   };
>
>   /* Rx ring - header status */
> -#define TP_STATUS_KERNEL	      0
> -#define TP_STATUS_USER		(1 << 0)
> -#define TP_STATUS_COPY		(1 << 1)
> -#define TP_STATUS_LOSING	(1 << 2)
> -#define TP_STATUS_CSUMNOTREADY	(1 << 3)
> -#define TP_STATUS_VLAN_VALID	(1 << 4) /* auxdata has valid tp_vlan_tci */
> -#define TP_STATUS_BLK_TMO	(1 << 5)
> +#define TP_STATUS_KERNEL		      0
> +#define TP_STATUS_USER			(1 << 0)
> +#define TP_STATUS_COPY			(1 << 1)
> +#define TP_STATUS_LOSING		(1 << 2)
> +#define TP_STATUS_CSUMNOTREADY		(1 << 3)
> +#define TP_STATUS_VLAN_VALID		(1 << 4) /* auxdata has valid tp_vlan_tci */
> +#define TP_STATUS_BLK_TMO		(1 << 5)
> +#define TP_STATUS_VLAN_TPID_VALID	(1 << 6) /* auxdata has valid tp_vlan_tpid */
>
>   /* Tx ring - header status */
>   #define TP_STATUS_AVAILABLE	      0
> @@ -133,12 +134,14 @@ struct tpacket2_hdr {
>   	__u32		tp_sec;
>   	__u32		tp_nsec;
>   	__u16		tp_vlan_tci;
> -	__u8		tp_padding[6];
> +	__u16		tp_vlan_tpid;
> +	__u8		tp_padding[4];
>   };
>
>   struct tpacket_hdr_variant1 {
>   	__u32	tp_rxhash;
>   	__u32	tp_vlan_tci;
> +	__u32	tp_vlan_tpid;

Why is this not __u16? If this needs to be __u32 aligned, then
probably we should pad with another __u16. I think we should not
waste any space here in case there are future additions of new
members.

>   };
>
>   struct tpacket3_hdr {
> @@ -154,7 +157,7 @@ struct tpacket3_hdr {
>   	union {
>   		struct tpacket_hdr_variant1 hv1;
>   	};
> -	__u8		tp_padding[12];
> +	__u8		tp_padding[8];
>   };
>
>   struct tpacket_bd_ts {
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 5c75a1d..58d4fd7 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -977,9 +977,11 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
>   {
>   	if (vlan_tx_tag_present(pkc->skb)) {
>   		ppd->hv1.tp_vlan_tci = vlan_tx_tag_get(pkc->skb);
> -		ppd->tp_status = TP_STATUS_VLAN_VALID;
> +		ppd->hv1.tp_vlan_tpid = (__force __u32)ntohs(pkc->skb->vlan_proto);

Nit:                                             ^^^^ one space here, resp. with __u16
                                                       you won't need the cast.

> +		ppd->tp_status = TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
>   	} else {
>   		ppd->hv1.tp_vlan_tci = 0;
> +		ppd->hv1.tp_vlan_tpid = 0;
>   		ppd->tp_status = TP_STATUS_AVAILABLE;
>   	}
>   }
> @@ -1925,9 +1927,11 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>   		h.h2->tp_nsec = ts.tv_nsec;
>   		if (vlan_tx_tag_present(skb)) {
>   			h.h2->tp_vlan_tci = vlan_tx_tag_get(skb);
> -			status |= TP_STATUS_VLAN_VALID;
> +			h.h2->tp_vlan_tpid = ntohs(skb->vlan_proto);
> +			status |= TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
>   		} else {
>   			h.h2->tp_vlan_tci = 0;
> +			h.h2->tp_vlan_tpid = 0;
>   		}
>   		hdrlen = sizeof(*h.h2);
>   		memset(h.h2->tp_padding, 0,
> @@ -2877,11 +2881,12 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
>   		aux.tp_net = skb_network_offset(skb);
>   		if (vlan_tx_tag_present(skb)) {
>   			aux.tp_vlan_tci = vlan_tx_tag_get(skb);
> -			aux.tp_status |= TP_STATUS_VLAN_VALID;
> +			aux.tp_vlan_tpid = ntohs(skb->vlan_proto);
> +			aux.tp_status |= TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
>   		} else {
>   			aux.tp_vlan_tci = 0;
> +			aux.tp_vlan_tpid = 0;
>   		}
> -		aux.tp_padding = 0;
>   		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
>   	}
>
>
