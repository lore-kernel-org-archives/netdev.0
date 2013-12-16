From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 2/3] packet: fill the gap of TPACKET_ALIGNMENT with
 zeros
Date: Mon, 16 Dec 2013 11:09:52 +0100
Message-ID: <52AED170.9020604@redhat.com>
References: <87ob4h6wq1.wl%atzm@stratosphere.co.jp>
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
Received: from mx1.redhat.com ([209.132.183.28]:11511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab3LPKKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:10:06 -0500
In-Reply-To: <87ob4h6wq1.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 09:12 AM, Atzm Watanabe wrote:
> struct tpacket{2,3}_hdr is aligned to a multiple of TPACKET_ALIGNMENT.
> Explicitly defining and zeroing the gap of this makes additional changes
> easier.

I think these structure changes are okay.

What is the reason behind the memset? I don't think it's necessary and we
should try to avoid this additional overhead that is don for *each* packet.
We would signal availability for future structure members in the status
bits anyway.

Otherwise looks good.

> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
> ---
>   include/uapi/linux/if_packet.h | 3 ++-
>   net/packet/af_packet.c         | 5 ++++-
>   2 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 1e24aa7..9185dc9 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -133,7 +133,7 @@ struct tpacket2_hdr {
>   	__u32		tp_sec;
>   	__u32		tp_nsec;
>   	__u16		tp_vlan_tci;
> -	__u16		tp_padding;
> +	__u8		tp_padding[6];
>   };
>
>   struct tpacket_hdr_variant1 {
> @@ -154,6 +154,7 @@ struct tpacket3_hdr {
>   	union {
>   		struct tpacket_hdr_variant1 hv1;
>   	};
> +	__u8		tp_padding[12];
>   };
>
>   struct tpacket_bd_ts {
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1c8b982..5c75a1d 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1929,8 +1929,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>   		} else {
>   			h.h2->tp_vlan_tci = 0;
>   		}
> -		h.h2->tp_padding = 0;
>   		hdrlen = sizeof(*h.h2);
> +		memset(h.h2->tp_padding, 0,
> +		       hdrlen - offsetof(struct tpacket2_hdr, tp_padding));
>   		break;
>   	case TPACKET_V3:
>   		/* tp_nxt_offset,vlan are already populated above.
> @@ -1944,6 +1945,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>   		h.h3->tp_sec  = ts.tv_sec;
>   		h.h3->tp_nsec = ts.tv_nsec;
>   		hdrlen = sizeof(*h.h3);
> +		memset(h.h3->tp_padding, 0,
> +		       hdrlen - offsetof(struct tpacket3_hdr, tp_padding));
>   		break;
>   	default:
>   		BUG();
>
