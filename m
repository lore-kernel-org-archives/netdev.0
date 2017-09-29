From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 07/10] sctp: add sockopt to get/set stream
 scheduler
Date: Fri, 29 Sep 2017 12:47:32 -0400
Message-ID: <20170929164732.GA19460@hmswarspite.think-freely.org>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
 <a68151caa1cb95d9bc5dd483637fe5368589723f.1506536044.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32899 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752113AbdI2Qrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 12:47:49 -0400
Content-Disposition: inline
In-Reply-To: <a68151caa1cb95d9bc5dd483637fe5368589723f.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 05:25:20PM -0300, Marcelo Ricardo Leitner wrote:
> As defined per RFC Draft ndata Section 4.3.2, named as
> SCTP_STREAM_SCHEDULER.
> 
> See-also: https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  include/uapi/linux/sctp.h |  1 +
>  net/sctp/socket.c         | 75 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 76 insertions(+)
> 
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index 4487e7625ddbd48be1868a8292a807ecd0a314bc..0050f10087d224bad87c8c54ad318003381aee12 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -122,6 +122,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_RESET_ASSOC	120
>  #define SCTP_ADD_STREAMS	121
>  #define SCTP_SOCKOPT_PEELOFF_FLAGS 122
> +#define SCTP_STREAM_SCHEDULER	123
>  
>  /* PR-SCTP policies */
>  #define SCTP_PR_SCTP_NONE	0x0000
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d207734326b085e60625e4333f74221481114892..ae35dbf2810f78c71ce77115ffe4b0e27a672abc 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -79,6 +79,7 @@
>  #include <net/sock.h>
>  #include <net/sctp/sctp.h>
>  #include <net/sctp/sm.h>
> +#include <net/sctp/stream_sched.h>
>  
>  /* Forward declarations for internal helper functions. */
>  static int sctp_writeable(struct sock *sk);
> @@ -3914,6 +3915,36 @@ static int sctp_setsockopt_add_streams(struct sock *sk,
>  	return retval;
>  }
>  
> +static int sctp_setsockopt_scheduler(struct sock *sk,
> +				     char __user *optval,
> +				     unsigned int optlen)
> +{
> +	struct sctp_association *asoc;
> +	struct sctp_assoc_value params;
> +	int retval = -EINVAL;
> +
> +	if (optlen < sizeof(params))
> +		goto out;
> +
> +	optlen = sizeof(params);
> +	if (copy_from_user(&params, optval, optlen)) {
> +		retval = -EFAULT;
> +		goto out;
> +	}
> +
> +	if (params.assoc_value > SCTP_SS_MAX)
> +		goto out;
> +
> +	asoc = sctp_id2assoc(sk, params.assoc_id);
> +	if (!asoc)
> +		goto out;
> +
> +	retval = sctp_sched_set_sched(asoc, params.assoc_value);
> +
> +out:
> +	return retval;
> +}
> +
Don't you want to lock the socket here prior to setting the scheduler, lest you
race in the set operation after you free the old scheduler and before you init
the new.  It would seem to me that not doing so can lead to packet loss or
worse.

Neil
