From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V2 7/8] net: fec: don't transfer ownership until
 descriptor write is complete
Date: Sat, 6 Feb 2016 14:52:12 +0300
Message-ID: <56B5DE6C.9080407@cogentembedded.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
 <1454709170-19527-8-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35597 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbcBFLwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 06:52:16 -0500
Received: by mail-lf0-f52.google.com with SMTP id l143so71972373lfe.2
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 03:52:15 -0800 (PST)
In-Reply-To: <1454709170-19527-8-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/6/2016 12:52 AM, Troy Kisky wrote:

> If you don't own it, you shouldn't write to it.
>
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>   drivers/net/ethernet/freescale/fec_main.c | 14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index ca2708d..97ca72a 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -390,6 +390,10 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
>
>   		bdp->cbd_bufaddr = cpu_to_fec32(addr);
>   		bdp->cbd_datlen = cpu_to_fec16(frag_len);
> +		/* Make sure the updates to rest of the descriptor are
> +		 * performed before transferring ownership.
> +		 */
> +		wmb();
>   		bdp->cbd_sc = cpu_to_fec16(status);
>   	}
>
> @@ -499,6 +503,10 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
>
>   	bdp->cbd_datlen = cpu_to_fec16(buflen);
>   	bdp->cbd_bufaddr = cpu_to_fec32(addr);
> +	/* Make sure the updates to rest of the descriptor are performed before
> +	 * transferring ownership.
> +	 */
> +	wmb();
>
>   	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
>   	 * it's the last BD of the frame, and to put the CRC on the end.
[...]
> @@ -1484,6 +1491,11 @@ rx_processing_done:
>   			ebdp->cbd_prot = 0;
>   			ebdp->cbd_bdu = 0;
>   		}
> +		/* Make sure the updates to rest of the descriptor are
> +		 * performed before transferring ownership.
> +		 */
> +		wmb();
> +		bdp->cbd_sc = cpu_to_fec16(status);

    I think you can use "ligter" dma_wmb() in this case.

[...]

MBR, Sergei
