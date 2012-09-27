From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Thu, 27 Sep 2012 10:23:35 -0400
Message-ID: <20120927142334.GA3194@neilslaptop.think-freely.org>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38345 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab2I0OXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 10:23:52 -0400
Content-Disposition: inline
In-Reply-To: <1348735261-29225-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 04:41:01PM +0800, Cong Wang wrote:
> Some customer requests this feature, as they stated:
> 
> 	"This parameter is necessary, especially for software that continually 
>         creates many ephemeral processes which open sockets, to avoid socket 
>         exhaustion. In many cases, the risk of the exhaustion can be reduced by 
>         tuning reuse interval to allow sockets to be reusable earlier.
> 
>         In commercial Unix systems, this kind of parameters, such as 
>         tcp_timewait in AIX and tcp_time_wait_interval in HP-UX, have 
>         already been available. Their implementations allow users to tune 
>         how long they keep TCP connection as TIME-WAIT state on the 
>         millisecond time scale."
> 
> We indeed have "tcp_tw_reuse" and "tcp_tw_recycle", but these tunings
> are not equivalent in that they cannot be tuned directly on the time
> scale nor in a safe way, as some combinations of tunings could still
> cause some problem in NAT. And, I think second scale is enough, we don't
> have to make it in millisecond time scale.
> 
I think I have a little difficultly seeing how this does anything other than
pay lip service to actually having sockets spend time in TIME_WAIT state.  That
is to say, while I see users using this to just make the pain stop.  If we wait
less time than it takes to be sure that a connection isn't being reused (either
by waiting two segment lifetimes, or by checking timestamps), then you might as
well not wait at all.  I see how its tempting to be able to say "Just don't wait
as long", but it seems that theres no difference between waiting half as long as
the RFC mandates, and waiting no time at all.  Neither is a good idea.

Given the problem you're trying to solve here, I'll ask the standard question in
response: How does using SO_REUSEADDR not solve the problem?  Alternatively, in
a pinch, why not reduce the tcp_max_tw_buckets sufficiently to start forcing
TIME_WAIT sockets back into CLOSED state?

The code looks fine, but the idea really doesn't seem like a good plan to me.
I'm sure HPUX/Solaris/AIX/etc have done this in response to customer demand, but
that doesn't make it the right solution.

Regards
Neil

> See also: https://lkml.org/lkml/2008/11/15/80
> 
> Any comments?
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index c7fc107..4b24398 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -520,6 +520,12 @@ tcp_tw_reuse - BOOLEAN
>  	It should not be changed without advice/request of technical
>  	experts.
>  
> +tcp_tw_interval - INTEGER
> +	Specify the timeout, in seconds, of TIME-WAIT sockets.
> +	It should not be changed without advice/request of technical
> +	experts.
> +	Default: 60
> +
>  tcp_window_scaling - BOOLEAN
>  	Enable window scaling as defined in RFC1323.
>  
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 6feeccd..72f92a1 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -114,9 +114,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
>  				 * initial RTO.
>  				 */
>  
> -#define TCP_TIMEWAIT_LEN (60*HZ) /* how long to wait to destroy TIME-WAIT
> -				  * state, about 60 seconds	*/
> -#define TCP_FIN_TIMEOUT	TCP_TIMEWAIT_LEN
> +#define TCP_TIMEWAIT_LEN (sysctl_tcp_tw_interval * HZ)
> +				 /* how long to wait to destroy TIME-WAIT
> +				  * state, default 60 seconds	*/
> +#define TCP_FIN_TIMEOUT	(60*HZ)
>                                   /* BSD style FIN_WAIT2 deadlock breaker.
>  				  * It used to be 3min, new value is 60sec,
>  				  * to combine FIN-WAIT-2 timeout with
> @@ -292,6 +293,7 @@ extern int sysctl_tcp_thin_dupack;
>  extern int sysctl_tcp_early_retrans;
>  extern int sysctl_tcp_limit_output_bytes;
>  extern int sysctl_tcp_challenge_ack_limit;
> +extern int sysctl_tcp_tw_interval;
>  
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 9205e49..f99cacf 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -27,6 +27,7 @@
>  #include <net/tcp_memcontrol.h>
>  
>  static int zero;
> +static int one = 1;
>  static int two = 2;
>  static int tcp_retr1_max = 255;
>  static int ip_local_port_range_min[] = { 1, 1 };
> @@ -271,6 +272,28 @@ bad_key:
>  	return ret;
>  }
>  
> +static int proc_tcp_tw_interval(ctl_table *ctl, int write,
> +				void __user *buffer, size_t *lenp,
> +				loff_t *ppos)
> +{
> +	int ret;
> +	ctl_table tmp = {
> +		.data = &sysctl_tcp_tw_interval,
> +		.maxlen = sizeof(int),
> +		.mode = ctl->mode,
> +		.extra1 = &one,
> +	};
> +
> +	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
> +	if (ret)
> +		return ret;
> +	if (write)
> +		tcp_death_row.period = (HZ / INET_TWDR_TWKILL_SLOTS)
> +				       * sysctl_tcp_tw_interval;
> +
> +	return 0;
> +}
> +
>  static struct ctl_table ipv4_table[] = {
>  	{
>  		.procname	= "tcp_timestamps",
> @@ -794,6 +817,13 @@ static struct ctl_table ipv4_table[] = {
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &zero
>  	},
> +	{
> +		.procname	= "tcp_tw_interval",
> +		.data		= &sysctl_tcp_tw_interval,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_tcp_tw_interval,
> +	},
>  	{ }
>  };
>  
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 93406c5..64af0b6 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -86,6 +86,7 @@
>  #include <linux/scatterlist.h>
>  
>  int sysctl_tcp_tw_reuse __read_mostly;
> +int sysctl_tcp_tw_interval __read_mostly = 60;
>  int sysctl_tcp_low_latency __read_mostly;
>  EXPORT_SYMBOL(sysctl_tcp_low_latency);
>  
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 27536ba..e16f524 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -34,7 +34,7 @@ int sysctl_tcp_abort_on_overflow __read_mostly;
>  
>  struct inet_timewait_death_row tcp_death_row = {
>  	.sysctl_max_tw_buckets = NR_FILE * 2,
> -	.period		= TCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
> +	.period		= (60 * HZ) / INET_TWDR_TWKILL_SLOTS,
>  	.death_lock	= __SPIN_LOCK_UNLOCKED(tcp_death_row.death_lock),
>  	.hashinfo	= &tcp_hashinfo,
>  	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
> 
