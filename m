From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] net: sctp: improve sctp_select_active_and_retran_path
 selection
Date: Wed, 11 Jun 2014 11:21:06 -0400
Message-ID: <539873E2.3020003@gmail.com>
References: <1402499003-29355-1-git-send-email-dborkman@redhat.com> <1402499003-29355-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:59496 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123AbaFKPVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 11:21:10 -0400
In-Reply-To: <1402499003-29355-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 11:03 AM, Daniel Borkmann wrote:
> In case we neither found a possible ACTIVE or UNKNOWN trans_pri
> resp. trans_sec from our current transport list, we currently
^^^^^^

Not sure what you wanted to say here.

-vlad

> just camp on a possibly PF or INACTIVE transport that is primary
> path; this behaviour actually dates back to linux-history tree
> of the very early days of lksctp, and can yield a behaviour that
> chooses suboptimal transport paths.
> 
> Instead, be a bit more clever by reusing and extending the
> recently introduced sctp_trans_elect_best() handler: In case of
> a tie, that is, both transports that are to be evaluated have
> the same score resulting from same states, will be examined
> further in that case based on other properties, that is, 1) we
> look at the transport path error_count, and if also that is a
> tie, 2) we look at the last_time_heard. This is analogous to
> Nishida's Quick Failover draft, section 5.1, 3:
> 
>   The sender SHOULD avoid data transmission to PF destinations.
>   When all destinations are in either PF or Inactive state,
>   the sender MAY either move the destination from PF to active
>   state (and transmit data to the active destination) or the
>   sender MAY transmit data to a PF destination. In the former
>   scenario, (i) the sender MUST NOT notify the ULP about the
>   state transition, and (ii) MUST NOT clear the destination's
>   error counter. It is recommended that the sender picks the
>   PF destination with least error count (fewest consecutive
>   timeouts) for data transmission. In case of a tie (multiple PF
>   destinations with same error count), the sender MAY choose the
>   last active destination.
> 
> Thus for sctp_select_active_and_retran_path(), we keep track of
> the best, if any, transport in PF state and in case no ACTIVE or
> UNKNOWN transport has been found (hence trans_{pri,sec} is NULL)
> we select the best out of the current primary_path and retran_path
> as well as the best found PF transport via sctp_trans_elect_best().
> The secondary may still camp on the original primary_path as
> before. The change in sctp_trans_elect_best() with a more fine
> grained tie selection also improves at the same time path selection
> for sctp_assoc_update_retran_path() in cases of non-ACTIVE states.
> 
>   [1] http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/associola.c | 50 +++++++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 45 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 620c99e..58bbb73 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1224,13 +1224,41 @@ static u8 sctp_trans_score(const struct sctp_transport *trans)
>  	return sctp_trans_state_to_prio_map[trans->state];
>  }
>  
> +static struct sctp_transport *sctp_trans_elect_tie(struct sctp_transport *trans1,
> +						   struct sctp_transport *trans2)
> +{
> +	if (trans1->error_count > trans2->error_count) {
> +		return trans2;
> +	} else if (trans1->error_count == trans2->error_count &&
> +		   ktime_after(trans2->last_time_heard,
> +			       trans1->last_time_heard)) {
> +		return trans2;
> +	} else {
> +		return trans1;
> +	}
> +}
> +
>  static struct sctp_transport *sctp_trans_elect_best(struct sctp_transport *curr,
>  						    struct sctp_transport *best)
>  {
> +	u8 score_curr, score_best;
> +
>  	if (best == NULL)
>  		return curr;
>  
> -	return sctp_trans_score(curr) > sctp_trans_score(best) ? curr : best;
> +	score_curr = sctp_trans_score(curr);
> +	score_best = sctp_trans_score(best);
> +
> +	/* First, try a score-based selection if both transport states
> +	 * differ. If we're in a tie, lets try to make a more clever
> +	 * decision here based on error counts and last time heard.
> +	 */
> +	if (score_curr > score_best)
> +		return curr;
> +	else if (score_curr == score_best)
> +		return sctp_trans_elect_tie(curr, best);
> +	else
> +		return best;
>  }
>  
>  void sctp_assoc_update_retran_path(struct sctp_association *asoc)
> @@ -1274,14 +1302,23 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
>  {
>  	struct sctp_transport *trans, *trans_pri = NULL, *trans_sec = NULL;
> +	struct sctp_transport *trans_pf = NULL;
>  
>  	/* Look for the two most recently used active transports. */
>  	list_for_each_entry(trans, &asoc->peer.transport_addr_list,
>  			    transports) {
> +		/* Skip uninteresting transports. */
>  		if (trans->state == SCTP_INACTIVE ||
> -		    trans->state == SCTP_UNCONFIRMED ||
> -		    trans->state == SCTP_PF)
> +		    trans->state == SCTP_UNCONFIRMED)
>  			continue;
> +		/* Keep track of the best PF transport from our
> +		 * list in case we don't find an active one.
> +		 */
> +		if (trans->state == SCTP_PF) {
> +			trans_pf = sctp_trans_elect_best(trans, trans_pf);
> +			continue;
> +		}
> +		/* For active transports, pick the most recent ones. */
>  		if (trans_pri == NULL ||
>  		    ktime_after(trans->last_time_heard,
>  				trans_pri->last_time_heard)) {
> @@ -1317,10 +1354,13 @@ static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
>  		trans_sec = trans_pri;
>  
>  	/* If we failed to find a usable transport, just camp on the
> -	 * primary, even if they are inactive.
> +	 * primary or retran, even if they are inactive, if possible
> +	 * pick a PF iff it's the better choice.
>  	 */
>  	if (trans_pri == NULL) {
> -		trans_pri = asoc->peer.primary_path;
> +		trans_pri = sctp_trans_elect_best(asoc->peer.primary_path,
> +						  asoc->peer.retran_path);
> +		trans_pri = sctp_trans_elect_best(trans_pri, trans_pf);
>  		trans_sec = asoc->peer.primary_path;
>  	}
>  
> 
