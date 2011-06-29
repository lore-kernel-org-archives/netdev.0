From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Wed, 29 Jun 2011 10:20:01 -0400
Message-ID: <4E0B3491.1060603@hp.com>
References: <20110629135704.GB10085@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:1223 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab1F2OUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:20:08 -0400
In-Reply-To: <20110629135704.GB10085@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2011 09:57 AM, Thomas Graf wrote:
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
> The graceful shutdown will wait for all outstanding TSN to be
> acknowledged before sending the SHUTDOWN request. This never
> happens due to the peer's zero window not acknowledging the
> continuously retransmitted data chunks. Although the error
> counter is incremented for each failed retransmission done
> via the T3-rtx timer, the receiving of the SACK sent in return
> to the retransmission, announcing the zero window, clears the
> error count again immediately.
> 
> Also heartbeat requests continue to be sent periodically. The
> peer acknowledges these requests causing the error counter to
> be reset as well.
> 
> This patch changes behaviour to only reset the overall error
> counter for the above rules while not in shutdown. This means
> that if already queued data can't be transmitted in max_retrans
> attempts we ABORT because a graceful shutdown is obviously not
> possible.
> 
> The issue can be easily reproduced by establishing a sctp
> association over the loopback device, constantly queueing data
> at the sender while not reading any at the receiver.  Wait for
> the window to reach zero, then initiate a shutdown by killing
> both processes simultaneously. The association will never be
> freed and the chunks on the retransmission queue will be
> retransmitted indefinitely.
> 

Hi Tomas

I think in this particular case, the receiver has to terminate, not the sender.
Look at how tcp_close() handles this.

As long as receiver is available, the sender should continue to try
sending data.

Once the receiver is no longer available (killed), if it had queued data, it should
trigger an ABORT since it lost data.  That ABORT will stop the sender as well.

-vlad

> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1c88c89..14a5295 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1629,10 +1629,15 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  			 * A sender is doing zero window probing when the
>  			 * receiver's advertised window is zero, and there is
>  			 * only one data chunk in flight to the receiver.
> +			 *
> +			 * Allow the association to timeout if SHUTDOWN is
> +			 * pending. We have no interest in keeping the
> +			 * association around forever.
>  			 */
>  			if (!q->asoc->peer.rwnd &&
>  			    !list_empty(&tlist) &&
> -			    (sack_ctsn+2 == q->asoc->next_tsn)) {
> +			    (sack_ctsn+2 == q->asoc->next_tsn) &&
> +			    !(q->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING)) {
>  				SCTP_DEBUG_PRINTK("%s: SACK received for zero "
>  						  "window probe: %u\n",
>  						  __func__, sack_ctsn);
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 534c2e5..fa92f4d6 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -670,10 +670,21 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	/* 8.3 Upon the receipt of the HEARTBEAT ACK, the sender of the
>  	 * HEARTBEAT should clear the error counter of the destination
>  	 * transport address to which the HEARTBEAT was sent.
> -	 * The association's overall error count is also cleared.
>  	 */
>  	t->error_count = 0;
> -	t->asoc->overall_error_count = 0;
> +
> +	/*
> +	 * Although RFC2960 and RFC4460 specify that the overall error
> +	 * count must be cleared when a HEARTBEAT ACK is received this
> +	 * behaviour may prevent the maximum retransmission count from
> +	 * being reached while in SHUTDOWN. If the peer keeps its window
> +	 * closed not acknowledging any outstanding TSN we may rely on
> +	 * reaching the max_retrans limit via the T3-rtx timer to close
> +	 * the association which will never happen if the error count is
> +	 * reset every heartbeat interval.
> +	 */
> +	if (!(t->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING))
> +		t->asoc->overall_error_count = 0;
>  
>  	/* Clear the hb_sent flag to signal that we had a good
>  	 * acknowledgement.
> 

