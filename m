From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Wed, 2 Nov 2011 09:04:38 +0100
Message-ID: <20111102080438.GA324@e-circ.dyndns.org>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Reuben Dowle <Reuben.Dowle@navico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:8257 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046Ab1KBIEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 04:04:43 -0400
Content-Disposition: inline
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2011 at 11:18:03AM +1300, Reuben Dowle wrote:
> Currently the flexcan driver uses hardware local echo. This blindly echos all transmitted frames to all receiving sockets, regardless what CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.
> 
> This patch now submits transmitted frames to be echoed in the transmit complete interrupt, preserving the reference to the sending socket. This allows the can protocol to correctly handle the local echo.
> 
> Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>
> 
> ---
>  drivers/net/can/flexcan.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index e023379..542ada8 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -302,7 +302,7 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
>  	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
>  
> -	kfree_skb(skb);
> +	can_put_echo_skb(skb, dev, 0);
>  
>  	/* tx_packets is incremented in flexcan_irq */
>  	stats->tx_bytes += cf->can_dlc;
Why not move the statistics to the place where the echo_skb is popped?
When no frame gets out (due to whatever reason), the statistics may have
incremented.

Or maybe this needs a seperate patch?

The rest looks good.

Kurt
