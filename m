From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix a race between sky2_down and sky2_poll
Date: Fri, 12 Jun 2009 07:16:14 -0700
Message-ID: <20090612071614.312e715d@nehalam>
References: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
	<20090611100448.09a9b730@nehalam>
	<392fb48f0906120616n123d8b57h9ef7c8e1735d26bf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33986 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754318AbZFLOQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 10:16:58 -0400
In-Reply-To: <392fb48f0906120616n123d8b57h9ef7c8e1735d26bf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Jun 2009 22:16:42 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 2009/6/12 Stephen Hemminger <shemminger@linux-foundation.org>
> 
> > Does the following fix the problem?
> 
> I tried your patch out, but it still got a crash.
> 
> The patch below does fix the problem. Does this look better?
> 
> thanks,
> 
> Mike
> 
> -----------------------------
> 
> Subject: [PATCH] sky2: Shutdown receive path cleanly in sky2_down
> 
> If sky2_down was called while receiving a packet, receive interrupts
> would still occur after the receive buffer was free'd causing a crash in
> sky2_status_intr.
> 
> To avoid further receive interrupts after sky2_down:
> 
> * make sure NAPI and interrupts are fully disabled during shutdown
> * call sky2_rx_stop after shutting down the receiver
> * clear received packets after shutdown
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |   21 +++++++++++++++------
>  1 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index a2ff9cb..136b362 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1805,10 +1805,13 @@ static int sky2_down(struct net_device *dev)
>  	/* Disable port IRQ */
>  	imask = sky2_read32(hw, B0_IMSK);
>  	imask &= ~portirq_msk[port];
> -	sky2_write32(hw, B0_IMSK, imask);
> +	sky2_write32(hw, B0_IMSK, 0);
> 

This breaks on 2 port boards. On dual port boards, both ports share
the same IRQ. 


-- 
