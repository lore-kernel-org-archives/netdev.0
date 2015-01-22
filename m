From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers: net: xgene: fix: Out of order descriptor bytes
 read
Date: Thu, 22 Jan 2015 14:50:50 -0800
Message-ID: <1421967050.3471.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421957007-720-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	mlangsdo@redhat.com, patches@apm.com,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:64412 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbAVWuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 17:50:52 -0500
In-Reply-To: <1421957007-720-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 12:03 -0800, Iyappan Subramanian wrote:
> This patch fixes the following kernel crash,
> 
> 	WARNING: CPU: 2 PID: 0 at net/ipv4/tcp_input.c:3079 tcp_clean_rtx_queue+0x658/0x80c()
> 	Call trace:

> 
> Software writes poison data into the descriptor bytes[15:8] and upon
> receiving the interrupt, if those bytes are overwritten by the hardware with
> the valid data, software also reads bytes[7:0] and executes receive/tx
> completion logic.
> 
> If the CPU executes the above two reads in out of order fashion, then the
> bytes[7:0] will have older data and causing the kernel panic.  We have to
> force the order of the reads and thus this patch introduces read memory
> barrier between these reads.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 83a5028..3622cdb 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -369,6 +369,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
>  		if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
>  			break;
>  
> +		/* read fpqnum field after dataaddr field */
> +		smp_rmb();
>  		if (is_rx_desc(raw_desc))
>  			ret = xgene_enet_rx_frame(ring, raw_desc);
>  		else

Reading your changelog, it looks like you need a plain rmb() here.
