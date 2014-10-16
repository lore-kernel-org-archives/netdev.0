From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: Re: [PATCH RFC net-next] sfc: add support for skb->xmit_more
Date: Thu, 16 Oct 2014 17:36:24 +0100
Message-ID: <543FF408.3000808@solarflare.com>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com> <543C13AE.80606@solarflare.com> <543C2588.6060604@redhat.com> <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <nikolay@redhat.com>,
	<netdev@vger.kernel.org>, Shradha Shah <sshah@solarflare.com>,
	Jon Cooper <jcooper@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:14080 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbaJPQne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 12:43:34 -0400
In-Reply-To: <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/10/14 19:41, Edward Cree wrote:
> Don't ring the doorbell, and don't do PIO.  This will also prevent
>   TX Push, because there will be more than one buffer waiting when
>   the doorbell is rung.
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>
> @@ -351,8 +343,6 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>   	unsigned short dma_flags;
>   	int i = 0;
>   
> -	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
> -
>   	if (skb_shinfo(skb)->gso_size)
>   		return efx_enqueue_skb_tso(tx_queue, skb);

Would it be possible to keep a weaker version of this check i.e.
EFX_BUG_ON_PARANOID(tx_queue->write_count > tx_queue->insert_count);

> @@ -1258,14 +1249,13 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
>   			       struct sk_buff *skb)
>   {
>   	struct efx_nic *efx = tx_queue->efx;
> +	unsigned int old_insert_count = tx_queue->insert_count;
>   	int frag_i, rc;
>   	struct tso_state state;
>   
>   	/* Find the packet protocol and sanity-check it */
>   	state.protocol = efx_tso_check_protocol(skb);
>   
> -	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
> -
>   	rc = tso_start(&state, efx, skb);
>   	if (rc)
>   		goto mem_err;

The same would apply here.

Thanks
Rob
