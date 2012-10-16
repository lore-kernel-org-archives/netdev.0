From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Wed, 17 Oct 2012 00:10:30 +0100
Message-ID: <1350429030.2649.49.camel@bwh-desktop.uk.solarflarecom.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
	 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31457 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754864Ab2JPXKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 19:10:34 -0400
In-Reply-To: <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 04:15 +0530, Mugunthan V N wrote:
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  include/linux/ptp_classify.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 42 insertions(+), 0 deletions(-)
> 
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

This assumes the skb is linear.  Use skb_header_pointer() to allow for
fragmented skbs.

Ben.

> +	*evt_seqid = ntohs(*seqid);
> +	*evt_msgtype = *msgtype & 0xf;
> +
> +	return 0;
> +}
> +
>  #endif

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
