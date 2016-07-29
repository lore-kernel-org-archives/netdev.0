From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 2/3] sctp_diag: export timer value only if it is active
Date: Fri, 29 Jul 2016 17:51:13 -0300
Message-ID: <20160729205113.GA2954@localhost.localdomain>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
 <1469811580-32429-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753784AbcG2UvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 16:51:16 -0400
Content-Disposition: inline
In-Reply-To: <1469811580-32429-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 06:59:39PM +0200, Phil Sutter wrote:
> Since it is exported as unsigned value, userspace has no way detecting
> whether it is negative or just very large. Therefore do this in kernel
> space where it is a simple comparison.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  net/sctp/sctp_diag.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index f69edcf219e51..0ad6033a7330c 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -40,10 +40,12 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
>  	}
>  
>  	r->idiag_state = asoc->state;
> -	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
> -	r->idiag_retrans = asoc->rtx_data_chunks;
> -	r->idiag_expires = jiffies_to_msecs(
> -		asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);

I think we have two issues here, prior to your patch, but I noticed
while reviewing it :-)

This array is actually not based on jiffies but on intervals instead, as
per:

sm_sideeffect.c:
                case SCTP_CMD_TIMER_START:                       [1]
                        timer = &asoc->timers[cmd->obj.to];
                        timeout = asoc->timeouts[cmd->obj.to];   <---
                        BUG_ON(!timeout);

                        timer->expires = jiffies + timeout;      <---

But more importantly, this array is actually not used for this timeout
and the timeout is sctp_transport dependant, as per:

/* Schedule retransmission on the given transport */
void sctp_transport_immediate_rtx(struct sctp_transport *t)
{
        /* Stop pending T3_rtx_timer */
        if (del_timer(&t->T3_rtx_timer))
                sctp_transport_put(t);

        sctp_retransmit(&t->asoc->outqueue, t, SCTP_RTXR_T3_RTX);
        if (!timer_pending(&t->T3_rtx_timer)) {
                if (!mod_timer(&t->T3_rtx_timer, jiffies + t->rto))
                                                 ^^^^^^^^^^^^^^^^
                        sctp_transport_hold(t);

Note how on sctp_get_sctp_info() it fetches the RTO (which is T3_RTX)
this way:
	info->sctpi_p_rto = jiffies_to_msecs(prim->rto);
If we want to know how long is left for the timer to expire, we have to
read directly from it.

With git grep -A 1 TIMER_START we can confirm that [1] is never hit for
SCTP_EVENT_TIMEOUT_T3_RTX. Yet, the asoc is allocated with kzalloc(), so
I guess you were just reading -jiffies in there.

Note however that the stats rtx_data_chunks is the accumulated stats,
it's good, and that we may have multiple T3 timers running at once, with
different timeouts.

Xin, ideas on how we can fix this? I'm not sure if we can dump
per-transport info in there. Not as it is now, I guess.

> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] > jiffies) {
> +		r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
> +		r->idiag_retrans = asoc->rtx_data_chunks;
> +		r->idiag_expires = jiffies_to_msecs(
> +			asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
> +	}
>  }
>  
>  static int inet_diag_msg_sctpladdrs_fill(struct sk_buff *skb,
> -- 
> 2.8.2
> 
