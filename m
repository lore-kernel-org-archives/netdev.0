From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v2] sctp: properly latch and use autoclose value from
 sock to association
Date: Sat, 7 Dec 2013 14:29:49 +0800
Message-ID: <52A2C05D.3080608@huawei.com>
References: <52A1EEFA.601@gmail.com> <1386350560-20920-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>, <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:57327 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab3LGGaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 01:30:08 -0500
In-Reply-To: <1386350560-20920-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/7 1:22, Neil Horman wrote:
> Currently, sctp associations latch a sockets autoclose value to an association
> at association init time, subject to capping constraints from the max_autoclose
> sysctl value.  This leads to an odd situation where an application may set a
> socket level autoclose timeout, but sliently sctp will limit the autoclose
> timeout to something less than that.
> 
> Fix this by modifying the autoclose setsockopt function to check the limit, cap
> it and warn the user via syslog that the timeout is capped.  This will allow
> getsockopt to return valid autoclose timeout values that reflect what subsequent
> associations actually use.
> 
> While were at it, also elimintate the assoc->autoclose variable, it duplicates
> whats in the timeout array, which leads to multiple sources for the same
> information, that may differ (as the former isn't subject to any capping).  This
> gives us the timeout information in a canonical place and saves some space in
> the association structure as well.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Wang Weidong <wangweidong1@huawei.com>
> CC: David Miller <davem@davemloft.net>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: netdev@vger.kernel.org
> 
> ---
> Change notes:
> 
> V2) Based on conversation with Vlad, removing the cap operation from
> sctp_association_init.  The spec is vague as to how we should handle this, and
> so we're removing it as a code savings, and will readdress if anyone complains.
> ---
>  include/net/sctp/structs.h |  6 ------
>  net/sctp/associola.c       |  5 +----
>  net/sctp/output.c          |  3 ++-
>  net/sctp/sm_statefuns.c    | 12 ++++++------
>  net/sctp/socket.c          |  7 +++++++
>  5 files changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 2174d8d..0b069a0 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1725,12 +1725,6 @@ struct sctp_association {
>  	/* How many duplicated TSNs have we seen?  */
>  	int numduptsns;
>  
> -	/* Number of seconds of idle time before an association is closed.
> -	 * In the association context, this is really used as a boolean
> -	 * since the real timeout is stored in the timeouts array
> -	 */
> -	__u32 autoclose;
> -
>  	/* These are to support
>  	 * "SCTP Extensions for Dynamic Reconfiguration of IP Addresses
>  	 *  and Enforcement of Flow and Message Limits"
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index c9b91cb..be939b1 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -154,8 +154,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  
>  	asoc->timeouts[SCTP_EVENT_TIMEOUT_HEARTBEAT] = 0;
>  	asoc->timeouts[SCTP_EVENT_TIMEOUT_SACK] = asoc->sackdelay;
> -	asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] =
> -		min_t(unsigned long, sp->autoclose, net->sctp.max_autoclose) * HZ;
> +	asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] = sp->autoclose * HZ;
>  
>  	/* Initializes the timers */
>  	for (i = SCTP_EVENT_TIMEOUT_NONE; i < SCTP_NUM_TIMEOUT_TYPES; ++i)
> @@ -291,8 +290,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  		asoc->peer.ipv6_address = 1;
>  	INIT_LIST_HEAD(&asoc->asocs);
>  
> -	asoc->autoclose = sp->autoclose;
> -
>  	asoc->default_stream = sp->default_stream;
>  	asoc->default_ppid = sp->default_ppid;
>  	asoc->default_flags = sp->default_flags;
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index e650978..c89e57d 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -580,7 +580,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  		unsigned long timeout;
>  
>  		/* Restart the AUTOCLOSE timer when sending data. */
> -		if (sctp_state(asoc, ESTABLISHED) && asoc->autoclose) {
> +		if (sctp_state(asoc, ESTABLISHED) &&
> +		    asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]) {
>  			timer = &asoc->timers[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
>  			timeout = asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
>  
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index dfe3f36..a26065b 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -820,7 +820,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
>  	SCTP_INC_STATS(net, SCTP_MIB_PASSIVEESTABS);
>  	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMERS_START, SCTP_NULL());
>  
> -	if (new_asoc->autoclose)
> +	if (new_asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE])
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  
> @@ -908,7 +908,7 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
>  	SCTP_INC_STATS(net, SCTP_MIB_CURRESTAB);
>  	SCTP_INC_STATS(net, SCTP_MIB_ACTIVEESTABS);
>  	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMERS_START, SCTP_NULL());
> -	if (asoc->autoclose)
> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE])
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  
> @@ -2970,7 +2970,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
>  	if (chunk->chunk_hdr->flags & SCTP_DATA_SACK_IMM)
>  		force = SCTP_FORCE();
>  
> -	if (asoc->autoclose) {
> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]) {
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  	}
> @@ -3878,7 +3878,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
>  				SCTP_CHUNK(chunk));
>  
>  	/* Count this as receiving DATA. */
> -	if (asoc->autoclose) {
> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]) {
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  	}
> @@ -5267,7 +5267,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
>  	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
>  
> -	if (asoc->autoclose)
> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE])
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  
> @@ -5346,7 +5346,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
>  	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
>  			SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
>  
> -	if (asoc->autoclose)
> +	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE])
>  		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
>  				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
>  
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 72046b9..9486ffd 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2196,6 +2196,7 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
>  				     unsigned int optlen)
>  {
>  	struct sctp_sock *sp = sctp_sk(sk);
> +	struct net *net = sock_net(sk);
>  
>  	/* Applicable to UDP-style socket only */
>  	if (sctp_style(sk, TCP))
> @@ -2205,6 +2206,12 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
>  	if (copy_from_user(&sp->autoclose, optval, optlen))
>  		return -EFAULT;
>  
> +	if (sp->autoclose > net->sctp.max_autoclose) {
> +		pr_warn("Capping autoclose value %d to defined maximum of %lu\n",
> +			sp->autoclose, net->sctp.max_autoclose);
> +		sp->autoclose = net->sctp.max_autoclose;
> +	}
> +
>  	return 0;
>  }
>  
> 

I test it on my machine. And it works for me.
Thanks.

Acked-by: Wang Weidong <wangweidong1@huawei.com>
