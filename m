From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 4/4] net: sctp: Convert log timestamps to be y2038 safe
Date: Thu, 25 Feb 2016 09:09:19 -0500
Message-ID: <20160225140919.GA20042@hmsreliant.think-freely.org>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
 <1456384031-29244-5-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org, arnd@arndb.de,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33023 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760641AbcBYOJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:09:38 -0500
Content-Disposition: inline
In-Reply-To: <1456384031-29244-5-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 11:07:11PM -0800, Deepa Dinamani wrote:
> SCTP probe log timestamps use struct timespec which is
> not y2038 safe.
> Use struct timespec64 which is 2038 safe instead.
> 
> Use monotonic time instead of real time as only time
> differences are logged.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-sctp@vger.kernel.org
> ---
>  net/sctp/probe.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> index 5e68b94..6cc2152 100644
> --- a/net/sctp/probe.c
> +++ b/net/sctp/probe.c
> @@ -65,7 +65,7 @@ static struct {
>  	struct kfifo	  fifo;
>  	spinlock_t	  lock;
>  	wait_queue_head_t wait;
> -	struct timespec	  tstart;
> +	struct timespec64 tstart;
>  } sctpw;
>  
>  static __printf(1, 2) void printl(const char *fmt, ...)
> @@ -85,7 +85,7 @@ static __printf(1, 2) void printl(const char *fmt, ...)
>  static int sctpprobe_open(struct inode *inode, struct file *file)
>  {
>  	kfifo_reset(&sctpw.fifo);
> -	getnstimeofday(&sctpw.tstart);
> +	ktime_get_ts64(&sctpw.tstart);
>  
>  	return 0;
>  }
> @@ -138,7 +138,7 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
>  	struct sk_buff *skb = chunk->skb;
>  	struct sctp_transport *sp;
>  	static __u32 lcwnd = 0;
> -	struct timespec now;
> +	struct timespec64 now;
>  
>  	sp = asoc->peer.primary_path;
>  
> @@ -149,8 +149,8 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
>  	    (full || sp->cwnd != lcwnd)) {
>  		lcwnd = sp->cwnd;
>  
> -		getnstimeofday(&now);
> -		now = timespec_sub(now, sctpw.tstart);
> +		ktime_get_ts64(&now);
> +		now = timespec64_sub(now, sctpw.tstart);
>  
>  		printl("%lu.%06lu ", (unsigned long) now.tv_sec,
>  		       (unsigned long) now.tv_nsec / NSEC_PER_USEC);
> -- 
> 1.9.1
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
