From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Thu, 18 Oct 2012 04:55:08 +0200
Message-ID: <20121018025508.GD2867@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:49241 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab2JRCzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 22:55:20 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so1309481wib.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 19:55:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:16AM +0530, Mugunthan V N wrote:
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  include/linux/ptp_classify.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 42 insertions(+), 0 deletions(-)

Sorry, but nak on this one. It is a bit way too long for a static
inline. Also, this driver-specific code, and it doesn't belong here.

Thanks,
Richard
 
> diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
> index 1dc420b..9b3b55b 100644
> --- a/include/linux/ptp_classify.h
> +++ b/include/linux/ptp_classify.h
> @@ -137,4 +137,46 @@ static inline int ptp_filter_init(struct sock_filter *f, int len)
>  	{OP_RETA,	0,   0, 0			}, /*              */ \
>  /*L6x*/	{OP_RETK,	0,   0, PTP_CLASS_NONE		},
>  
> +static inline int ptp_get_skb_event(struct sk_buff *skb, u32 ptp_class,
> +				    u16 *evt_seqid, u8 *evt_msgtype)
> +{
> +	u16 *seqid;
> +	unsigned int offset;
> +	u8 *msgtype, *data = skb->data;
> +
> +	switch (ptp_class) {
> +	case PTP_CLASS_V1_IPV4:
> +	case PTP_CLASS_V2_IPV4:
> +		offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
> +		break;
> +	case PTP_CLASS_V1_IPV6:
> +	case PTP_CLASS_V2_IPV6:
> +		offset = OFF_PTP6;
> +		break;
> +	case PTP_CLASS_V2_L2:
> +		offset = ETH_HLEN;
> +		break;
> +	case PTP_CLASS_V2_VLAN:
> +		offset = ETH_HLEN + VLAN_HLEN;
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID + sizeof(*seqid))
> +		return 0;
> +
> +	if (unlikely(ptp_class & PTP_CLASS_V1))
> +		msgtype = data + offset + OFF_PTP_CONTROL;
> +	else
> +		msgtype = data + offset;
> +
> +	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
> +
> +	*evt_seqid = ntohs(*seqid);
> +	*evt_msgtype = *msgtype & 0xf;
> +
> +	return 0;
> +}
> +
>  #endif
> -- 
> 1.7.0.4
> 
