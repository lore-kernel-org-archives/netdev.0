From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: fix the check for path failure detection
Date: Fri, 21 Aug 2009 17:47:33 -0400
Message-ID: <4A8F15F5.3020901@hp.com>
References: <1250838275-7444-1-git-send-email-chunbo.luo@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunbo Luo <chunbo.luo@windriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933123AbZHUVrj@vger.kernel.org>
In-Reply-To: <1250838275-7444-1-git-send-email-chunbo.luo@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunbo Luo wrote:
> The transport is marked DOWN immediately after sending the max+1 HB,
> which is equal to not sending the max+1 HB at all. We should wait
> a next period and make sure the last HB is not acknowledged.
> 

I don't think this code does what you want either...

Let's say path_max_rxt = 2.  What we'll get is:
	timeout:
		err++ (1)
		if (err > 2) false
		send HB
		reset timer
	timeout:
		err++ (2)
		if (err > 2) false
		send HB
		reset timer
	timeout:
		err++ (3)
		if (err > 2)
			set transport DOWN
		send HB
		reset timer.

We only had 2 unacknowledged HB when we should have had 3.

All you need to do is move the error error under a check that
makes sure that HB has been sent (similar to how the rto doubling
is done).  Then you original patch would work where we change ">="
to simply ">".  The error count will be max+1 when transport is marked DOWN.

-vlad

> Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
> ---
>  include/net/sctp/command.h |    1 +
>  net/sctp/sm_sideeffect.c   |   39 ++++++++++++++++++++++++++++-----------
>  net/sctp/sm_statefuns.c    |   16 ++++++++++++++--
>  3 files changed, 43 insertions(+), 13 deletions(-)
> 
> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
> index 3b96680..256effd 100644
> --- a/include/net/sctp/command.h
> +++ b/include/net/sctp/command.h
> @@ -77,6 +77,7 @@ typedef enum {
>  	SCTP_CMD_HB_TIMERS_START,    /* Start the heartbeat timers. */
>  	SCTP_CMD_HB_TIMER_UPDATE,    /* Update a heartbeat timers.  */
>  	SCTP_CMD_HB_TIMERS_STOP,     /* Stop the heartbeat timers.  */
> +	SCTP_CMD_PATH_FAILURE_DETECTION,/* Path failure detection. */
>  	SCTP_CMD_TRANSPORT_HB_SENT,  /* Reset the status of a transport. */
>  	SCTP_CMD_TRANSPORT_IDLE,     /* Do manipulations on idle transport */
>  	SCTP_CMD_TRANSPORT_ON,       /* Mark the transport as active. */
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 86426aa..db299c6 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -432,7 +432,25 @@ sctp_timer_event_t *sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES] = {
>   * mark the destination transport address as inactive, and a
>   * notification SHOULD be sent to the upper layer.
>   *
> + * transport error counter is incremented in sctp_do_8_2_transport_strike
>   */
> +static void sctp_cmd_path_failure_detection(struct sctp_association *asoc,
> +					   struct sctp_transport *transport)
> +{
> +	if (transport->error_count > transport->pathmaxrxt) {
> +		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
> +					 " transport IP: port:%d failed.\n",
> +					 asoc,
> +					 (&transport->ipaddr),
> +					 ntohs(transport->ipaddr.v4.sin_port));
> +		sctp_assoc_control_transport(asoc, transport,
> +					     SCTP_TRANSPORT_DOWN,
> +					     SCTP_FAILED_THRESHOLD);
> +	}
> +}
> +
> +
> + /*  Mark a strike against a transport */
>  static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
>  					 struct sctp_transport *transport,
>  					 int is_hb)
> @@ -446,17 +464,11 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
>  	if (transport->state != SCTP_UNCONFIRMED)
>  		asoc->overall_error_count++;
>  
> -	if (transport->state != SCTP_INACTIVE &&
> -	    (transport->error_count++ >= transport->pathmaxrxt)) {
> -		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
> -					 " transport IP: port:%d failed.\n",
> -					 asoc,
> -					 (&transport->ipaddr),
> -					 ntohs(transport->ipaddr.v4.sin_port));
> -		sctp_assoc_control_transport(asoc, transport,
> -					     SCTP_TRANSPORT_DOWN,
> -					     SCTP_FAILED_THRESHOLD);
> -	}
> +	/* The check for transport's error counter exceeding the threshold
> +	 * is done in the state function.
> +	 */
> +	if (transport->state != SCTP_INACTIVE)
> +		transport->error_count++;
>  
>  	/* E2) For the destination address for which the timer
>  	 * expires, set RTO <- RTO * 2 ("back off the timer").  The
> @@ -1464,6 +1476,11 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  						    0);
>  			break;
>  
> +		case SCTP_CMD_PATH_FAILURE_DETECTION:
> +			t = cmd->obj.transport;
> +			sctp_cmd_path_failure_detection(asoc, t);
> +			break;
> +
>  		case SCTP_CMD_TRANSPORT_IDLE:
>  			t = cmd->obj.transport;
>  			sctp_transport_lower_cwnd(t, SCTP_LOWER_CWND_INACTIVE);
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 7288192..f4c05fd 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -981,6 +981,9 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
>  	 */
>  
>  	if (transport->param_flags & SPP_HB_ENABLE) {
> +		/* Do the path failure detection before send beat */
> +		sctp_add_cmd_sf(commands, SCTP_CMD_PATH_FAILURE_DETECTION,
> +				SCTP_TRANSPORT(transport));
>  		if (SCTP_DISPOSITION_NOMEM ==
>  				sctp_sf_heartbeat(ep, asoc, type, arg,
>  						  commands))
> @@ -5229,6 +5232,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(const struct sctp_endpoint *ep,
>  	 */
>  
>  	/* Do some failure management (Section 8.2). */
> +	sctp_add_cmd_sf(commands, SCTP_CMD_PATH_FAILURE_DETECTION,
> +			SCTP_TRANSPORT(transport));
>  	sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE, SCTP_TRANSPORT(transport));
>  
>  	/* NB: Rules E4 and F1 are implicit in R1.  */
> @@ -5436,9 +5441,13 @@ sctp_disposition_t sctp_sf_t2_timer_expire(const struct sctp_endpoint *ep,
>  	 * If we remove the transport an SHUTDOWN was last sent to, don't
>  	 * do failure management.
>  	 */
> -	if (asoc->shutdown_last_sent_to)
> +	if (asoc->shutdown_last_sent_to) {
> +		sctp_add_cmd_sf(commands, SCTP_CMD_PATH_FAILURE_DETECTION,
> +				SCTP_TRANSPORT(asoc->shutdown_last_sent_to));
> +
>  		sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE,
>  				SCTP_TRANSPORT(asoc->shutdown_last_sent_to));
> +	}
>  
>  	/* Set the transport for the SHUTDOWN/ACK chunk and the timeout for
>  	 * the T2-shutdown timer.
> @@ -5475,9 +5484,12 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
>  	 * detection on the appropriate destination address as defined in
>  	 * RFC2960 [5] section 8.1 and 8.2.
>  	 */
> -	if (transport)
> +	if (transport) {
> +		sctp_add_cmd_sf(commands, SCTP_CMD_PATH_FAILURE_DETECTION,
> +				SCTP_TRANSPORT(transport));
>  		sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE,
>  				SCTP_TRANSPORT(transport));
> +	}
>  
>  	/* Reconfig T4 timer and transport. */
>  	sctp_add_cmd_sf(commands, SCTP_CMD_SETUP_T4, SCTP_CHUNK(chunk));
