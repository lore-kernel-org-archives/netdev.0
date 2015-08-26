From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE
 state
Date: Wed, 26 Aug 2015 11:19:20 -0400
Message-ID: <55DDD8F8.4090400@gmail.com>
References: <46eeeb896c5be2523e3d978d4a7ea9907d4301ee.1440329415.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35134 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbHZPTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:19:23 -0400
Received: by qgj62 with SMTP id 62so128174271qgj.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 08:19:22 -0700 (PDT)
In-Reply-To: <46eeeb896c5be2523e3d978d4a7ea9907d4301ee.1440329415.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2015 07:30 AM, Xin Long wrote:
> commit f8d960524 fix the 0 peer.rwnd issue in SHUTDOWN_PENDING state through
> not reseting the overall_error_count when receive a heartbeat, but the same
> issue also exists in SHUTDOWN_RECEIVE state.
> 
> so we change the condition to state < SCTP_STATE_SHUTDOWN_PENDING to reset the
> overall_error_count when receive a heartbeat, which can avoid the issue happen
> in SCTP_STATE_SHUTDOWN_RECEIVE.
> 
> as to SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT state, with
> this patch, it will not be affected by the heartbeat, cause these two states
> have been taken charge of by t2 timer.
> 
> Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>


The code is OK, but the change log could use some help.

How is this for the explanation:

Commit f8d960524 ("sctp: Enforce retransmission limit during shutdown") fixed a
problem with excessive retransmissions in the SHUTDOWN_PENDING by not resetting
the association overall_error_count.  This allowed the association to better
enforce assoc.max_retrans limit.

However, the same issue still exists when the association is in SHUTDOWN_RECEIVED
state.  In this state, HB-ACKs will continue to reset the overall_error_count
for the association would extend the lifetime of association unnecessarily.

This patch solves this by resetting the overall_error_count whenever the current
state is small then SCTP_STATE_SHUTDOWN_PENDING.  As a small side-effect, we
end up also handling SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT
states, but they are not really impacted because we disable Heartbeats in those
states.


Thanks
-vlad


> ---
>  net/sctp/sm_sideeffect.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index fef2acd..85e6f03 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -702,7 +702,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	 * outstanding data and rely on the retransmission limit be reached
>  	 * to shutdown the association.
>  	 */
> -	if (t->asoc->state != SCTP_STATE_SHUTDOWN_PENDING)
> +	if (t->asoc->state < SCTP_STATE_SHUTDOWN_PENDING)
>  		t->asoc->overall_error_count = 0;
>  
>  	/* Clear the hb_sent flag to signal that we had a good
> 
