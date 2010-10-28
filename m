From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/4] tipc: Fix bugs in tipc_msg_calc_data_size()
Date: Thu, 28 Oct 2010 10:07:11 -0400
Message-ID: <20101028140711.GA25455@shamino.rdu.redhat.com>
References: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
 <1288207773-25448-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, torvalds@linux-foundation.org,
	security@kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53029 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758691Ab0J1OH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 10:07:29 -0400
Content-Disposition: inline
In-Reply-To: <1288207773-25448-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 03:29:30PM -0400, Paul Gortmaker wrote:
> From: Allan Stephens <Allan.Stephens@windriver.com>
> 
> Enhances TIPC's computation of the amount of data to be sent so that
> it works properly when large values are involved. Calculations are now
> done using "size_t" instead of "int", and a check has been added to
> handle cases where the total amount of data exceeds the range of "size_t".
> 
> Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
> ---
>  net/tipc/msg.c |   17 ++++++++++++-----
>  net/tipc/msg.h |    2 +-
>  2 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index ecb532f..38360a9 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -72,15 +72,22 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
>  
>  /**
>   * tipc_msg_calc_data_size - determine total data size for message
> + *
> + * Note: If total exceeds range of size_t returns largest possible value
>   */
>  
> -int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
> +size_t tipc_msg_calc_data_size(struct iovec const *msg_sect, size_t num_sect)
>  {
> -	int dsz = 0;
> -	int i;
> +	size_t dsz = 0;
> +	size_t len;
> +	size_t i;
>  
> -	for (i = 0; i < num_sect; i++)
> -		dsz += msg_sect[i].iov_len;
> +	for (i = 0; i < num_sect; i++) {
> +		len = msg_sect[i].iov_len;
> +		if (len > (size_t)LONG_MAX - dsz)
> +			return (size_t)LONG_MAX;
> +		dsz += len;
> +	}
>  	return dsz;
>  }
>  
> diff --git a/net/tipc/msg.h b/net/tipc/msg.h
> index 031aad1..a132800 100644
> --- a/net/tipc/msg.h
> +++ b/net/tipc/msg.h
> @@ -711,7 +711,7 @@ static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
>  u32 tipc_msg_tot_importance(struct tipc_msg *m);
>  void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
>  			    u32 hsize, u32 destnode);
> -int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect);
> +size_t tipc_msg_calc_data_size(struct iovec const *msg_sect, size_t num_sect);
>  int tipc_msg_build(struct tipc_msg *hdr,
>  			    struct iovec const *msg_sect, u32 num_sect,
>  			    int max_size, int usrmem, struct sk_buff** buf);
> -- 
> 1.7.1.GIT
> 
You should probably roll this patch together with your second one.  The caller
tipc_msg_build will otherwise throw a warning when you build, as it assigns the
return value with this patch (a size_t) to a signed integer.  It probably won't
matter since you limit dsz to TIPC_MAX_USER_MSG_SIZE which is small in
comparison to the size of an int, but nevertheless, the two patches are related,
so you can merge them.

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
