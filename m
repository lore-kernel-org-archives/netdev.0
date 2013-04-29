From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/3] cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated
 in a CPL_FW4_MSG
Date: Mon, 29 Apr 2013 22:55:43 +0400
Message-ID: <517EC22F.9020102@cogentembedded.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com> <1367244281-23043-4-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com
To: Vipul Pandya <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:64001 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758539Ab3D2S4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:56:17 -0400
Received: by mail-lb0-f177.google.com with SMTP id x10so5907045lbi.8
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:56:15 -0700 (PDT)
In-Reply-To: <1367244281-23043-4-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/29/2013 06:04 PM, Vipul Pandya wrote:

> Newer firmware can post CPL_SGE_EGR_UPDATE message encapsulated in a
> CPL_FW4_MSG as follows
>
> flit0 rss_header (if DropRSS == 0 in IQ context)
> flit1 CPL_FW4_MSG cpl
> flit2 rss_header w/opcode CPL_SGE_EGR_UPDATE
> flit3 CPL_SGE_EGR_UPDATE cpl
>
> So FW4_MSG CPLs with a newly created type of FW_TYPE_RSSCPL have the
> CPL_SGE_EGR_UPDATE CPL message in flit 2 of the FW4_MSG. Firmware can still
> post regular CPL_SGE_EGR_UPDATE messages, so the drivers need to handle
> both.
>
> This patch also writes a new parameter to firmware requesting encapsulated
> EGR_UPDATE. This allows firmware with this support to not break older drivers.
>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

[...]

> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> index 73aef76..40c22e7 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> @@ -409,6 +409,20 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
>   		break;
>   	}
>   
> +	case CPL_FW4_MSG: {
> +		/* FW can send EGR_UPDATEs encapsulated in a CPL_FW4_MSG.
> +		 */
> +		const struct cpl_sge_egr_update *p = (void *)(rsp + 3);

     Empty line wouldn't hurt here, after the declaration.

> +		opcode = G_CPL_OPCODE(ntohl(p->opcode_qid));
> +		if (opcode != CPL_SGE_EGR_UPDATE) {
> +			dev_err(adapter->pdev_dev, "unexpected FW4/CPL %#x on FW event queue\n"
> +				, opcode);
> +			break;
> +		}
> +		cpl = (void *)p;
> +		/*FALLTHROUGH*/

    Rather pointless comment at end of *switch*. Adn you forgot to add 
spaced before */ and after /*.

> +	}
> +
>   	case CPL_SGE_EGR_UPDATE: {
>   		/*
>   		 * We've received an Egress Queue Status Update message.  We
[...]

WBR, Sergei
