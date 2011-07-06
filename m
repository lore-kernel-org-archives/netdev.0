From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 6 Jul 2011 08:15:09 -0400
Message-ID: <20110706121508.GA19518@hmsreliant.think-freely.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
 <20110704135019.GA801@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Vladislav Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48507 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab1GFMPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 08:15:23 -0400
Content-Disposition: inline
In-Reply-To: <20110704135019.GA801@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 04, 2011 at 09:50:19AM -0400, Thomas Graf wrote:
> When initiating a graceful shutdown while having data chunks
> on the retransmission queue with a peer which is in zero
> window mode the shutdown is never completed because the
> retransmission error count is reset periodically by the
> following two rules:
> 
>  - Do not timeout association while doing zero window probe.
>  - Reset overall error count when a heartbeat request has
>    been acknowledged.
> 
> The graceful shutdown will wait for all outstanding TSN to
> be acknowledged before sending the SHUTDOWN request. This
> never happens due to the peer's zero window not acknowledging
> the continuously retransmitted data chunks. Although the
> error counter is incremented for each failed retransmission,
> the receiving of the SACK announcing the zero window clears
> the error count again immediately. Also heartbeat requests
> continue to be sent periodically. The peer acknowledges these
> requests causing the error counter to be reset as well.
> 
> This patch changes behaviour to only reset the overall error
> counter for the above rules while not in shutdown. After
> reaching the maximum number of retransmission attempts, the
> T5 shutdown guard timer is scheduled to give the receiver
> some additional time to recover. The timer is stopped as soon
> as the receiver acknowledges any data.
> 
> The issue can be easily reproduced by establishing a sctp
> association over the loopback device, constantly queueing
> data at the sender while not reading any at the receiver.
> Wait for the window to reach zero, then initiate a shutdown
> by killing both processes simultaneously. The association
> will never be freed and the chunks on the retransmission
> queue will be retransmitted indefinitely.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>
<snip>
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -5154,7 +5154,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
>  	 * The sender of the SHUTDOWN MAY also start an overall guard timer
>  	 * 'T5-shutdown-guard' to bound the overall time for shutdown sequence.
>  	 */
> -	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
> +	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
>  
How come you're modifying this chunk to use TIMER_RESTART rather than
TIMER_START? start shutdown is where the t5 timer is actually started, isn't it?


The rest, I think looks ok to me.
Neil
