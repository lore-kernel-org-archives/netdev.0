From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0
 and local.state is SHUTDOWN_PENDING
Date: Mon, 24 Aug 2015 14:13:38 -0400
Message-ID: <55DB5ED2.1050702@redhat.com>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbbHXSNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 14:13:40 -0400
In-Reply-To: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2015 07:30 AM, Xin Long wrote:
> when A sends a data to B, then A close() and enter into SHUTDOWN_PENDING state,
> if B neither claim his rwnd is 0 nor send SACK for this data, A will keep
> retransmitting this data util t5 timeout, Max.Retrans times can't work anymore,
> which is bad.
> 
> if B's rwnd is not 0, it should send abord after Max.Retrans times, only when
> B's rwnd == 0 and A's retransmitting beyonds Max.Retrans times, A will start
> t5 timer, which is also commit f8d960524 means, but it lacks the condition
> peer.rwnd == 0.
> 
> Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_statefuns.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 3ee27b7..deb9eab 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
>  	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
>  
>  	if (asoc->overall_error_count >= asoc->max_retrans) {
> -		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> +		if (!q->asoc->peer.rwnd &&
> +		    asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
>  			/*
>  			 * We are here likely because the receiver had its rwnd
>  			 * closed for a while and we have not been able to
> 

This may not work as expected.  peer.rwnd is the calculated peer window, but it
also gets updated when we receive sacks.  So there is no way to tell that
the current windows is 0 because peer told us, or because we sent data to make 0
and the peer hasn't responded.

-vlad
