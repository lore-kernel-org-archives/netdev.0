From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] sctp: fix incorrect overflow check on autoclose
Date: Thu, 15 Dec 2011 16:07:02 -0500
Message-ID: <4EEA6176.9020704@hp.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com> <4EE919B5.3090901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33323 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756404Ab1LOVHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 16:07:05 -0500
In-Reply-To: <4EE919B5.3090901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/14/2011 04:48 PM, Xi Wang wrote:
> Commit 8ffd3208 voids the previous patches f6778aab and 810c0719 for
> limiting the maximum autoclose value.  If userspace passes in -1 on
> 32-bit platform, the overflow check didn't work and autoclose would be
> set to 0xffffffff.
> 
> This patch defines a max_autoclose for limiting the value and exposes
> it through sysctl.
> 
> Suggested-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  include/net/sctp/structs.h |    4 ++++
>  net/sctp/protocol.c        |    3 +++
>  net/sctp/socket.c          |    4 ++--
>  net/sctp/sysctl.c          |    7 +++++++
>  4 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index e90e7a9..781f16d 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -241,6 +241,9 @@ extern struct sctp_globals {
>  	 * bits is an indicator of when to send and window update SACK.
>  	 */
>  	int rwnd_update_shift;
> +
> +	/* Threshold for autoclose timeout. */
> +	unsigned int max_autoclose;
>  } sctp_globals;
>  
>  #define sctp_rto_initial		(sctp_globals.rto_initial)
> @@ -281,6 +284,7 @@ extern struct sctp_globals {
>  #define sctp_auth_enable		(sctp_globals.auth_enable)
>  #define sctp_checksum_disable		(sctp_globals.checksum_disable)
>  #define sctp_rwnd_upd_shift		(sctp_globals.rwnd_update_shift)
> +#define sctp_max_autoclose		(sctp_globals.max_autoclose)
>  
>  /* SCTP Socket type: UDP or TCP style. */
>  typedef enum {
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 61b9fca..4e07b18 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1285,6 +1285,9 @@ SCTP_STATIC __init int sctp_init(void)
>  	sctp_max_instreams    		= SCTP_DEFAULT_INSTREAMS;
>  	sctp_max_outstreams   		= SCTP_DEFAULT_OUTSTREAMS;
>  
> +	/* Initialize maximum autoclose timeout. */
> +	sctp_max_autoclose		= INT_MAX;
> +
>  	/* Initialize handle used for association ids. */
>  	idr_init(&sctp_assocs_id);
>  
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 13bf5fc..f8c8e66 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2200,8 +2200,8 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
>  		return -EINVAL;
>  	if (copy_from_user(&sp->autoclose, optval, optlen))
>  		return -EFAULT;
> -	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
> -	sp->autoclose = min_t(long, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ);
> +	/* make sure it won't exceed sctp_max_autoclose / HZ */
> +	sp->autoclose = min(sp->autoclose, sctp_max_autoclose / HZ);
>  
>  	return 0;
>  }
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 6b39529..b74686e 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -258,6 +258,13 @@ static ctl_table sctp_table[] = {
>  		.extra1		= &one,
>  		.extra2		= &rwnd_scale_max,
>  	},
> +	{
> +		.procname	= "max_autoclose",
> +		.data		= &sctp_max_autoclose,
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_jiffies,
> +	},
>

I think it would be better to keep this value in seconds and get rid
of division in the setsockopt code.  We could then have a min and max
values where max value could be something like 2 days.  I really don't
see an autoclose value that is bigger then that being very useful.  In
fact, most of the time these values are very small as one wants to close
out idle associations.

-vlad

>  	{ /* sentinel */ }
>  };
