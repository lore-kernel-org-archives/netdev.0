From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 4/4] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Wed, 25 Feb 2015 20:19:22 -0800
Message-ID: <1424924362.5565.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	 <1424922566-6787-1-git-send-email-fan.du@intel.com>
	 <1424922566-6787-5-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, edumazet@google.com, davem@davemloft.net,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36050 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbbBZETZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:19:25 -0500
Received: by ierx19 with SMTP id x19so11003775ier.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:19:24 -0800 (PST)
In-Reply-To: <1424922566-6787-5-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 11:49 +0800, Fan Du wrote:
> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
> be armed once probing has converged. Once this timer expired,
> probing again to take advantage of any path PMTU change. The
> recommended probing interval is 10 minutes per RFC1981. Probing
> interval could be sysctled by sysctl_tcp_probe_interval.
> 
> Eric suggested to implement pseudo timer based on 32bits jiffies
> tcp_time_stamp instead of using classic timer for such rare event.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
> v2:
>    - Create a pseudo timer based on 32bits jiffies tcp_time_stamp
>      to control when to reprobing as suggested by Eric.

...

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index c418829..0e9ee6a 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1354,6 +1354,8 @@ void tcp_mtup_init(struct sock *sk)
>  			       icsk->icsk_af_ops->net_header_len;
>  	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
>  	icsk->icsk_mtup.probe_size = 0;
> +	if (icsk->icsk_mtup.enabled)

I guess the test can be removed.

Assignment of probe_timestamp can be done regardless of the flag.

> +		icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
>  }
>  EXPORT_SYMBOL(tcp_mtup_init);
>  
> @@ -1823,6 +1825,35 @@ send_now:
>  	return false;
>  }
>  
> +static inline void tcp_mtu_check_reprobe(struct sock *sk)
> +{
> +	struct inet_connection_sock *icsk = inet_csk(sk);
> +	struct net *net = sock_net(sk);
> +	struct tcp_sock *tp = tcp_sk(sk);
> +

extra newline

> +	u32 delta;
> +	u32 now = tcp_time_stamp;
> +	u32 interval = net->ipv4.sysctl_tcp_probe_interval;


Please try to keep variables sorted by lengths, it helps readability :

	u32 interval = net->ipv4.sysctl_tcp_probe_interval;
	struct inet_connection_sock *icsk = inet_csk(sk);
	struct tcp_sock *tp = tcp_sk(sk);
	struct net *net = sock_net(sk);
	s32 delta;
 


> +
> +	if (likely(now > icsk->icsk_mtup.probe_timestamp))

Wrapping issue.

 if ((s32)(now - icsk->icsk_mtup.probe_timestamp)) > 0) ...


> +		delta = now - icsk->icsk_mtup.probe_timestamp;
> +	else
> +		delta = now + (U32_MAX - icsk->icsk_mtup.probe_timestamp);


oh well..

delta = tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;

is fine (if delta is declared as s32).
Adding U32_MAX makes no sense. No need for @now var.

> +	if (unlikely(jiffies_to_msecs(delta) >= interval * MSEC_PER_SC)) {

if (unlikely(delta >= interval * HZ)) {

> +		int mss = tcp_current_mss(sk);
> +
> +		/* Update current search range */
> +		icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp +
> +			sizeof(struct tcphdr) +
> +			icsk->icsk_af_ops->net_header_len;
> +		icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
> +		icsk->icsk_mtup.probe_size = 0;
> +
> +		/* Update probe time stamp */
> +		icsk->icsk_mtup.probe_timestamp = now;

		icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
> +	}
> +}
> +
>  /* Create a new MTU probe if we are ready.
>   * MTU probe is regularly attempting to increase the path MTU by
>   * deliberately sending larger packets.  This discovers routing
> @@ -1866,8 +1897,11 @@ static int tcp_mtu_probe(struct sock *sk)
>  	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
>  	interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
>  	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
> -	    interval < net->ipv4.sysctl_tcp_probe_threshold) {
> -		/* TODO: set timer for probe_converge_event */
> +		interval < net->ipv4.sysctl_tcp_probe_threshold) {
> +		/* Check whether enough time has elaplased for
> +		 * another round of probing.
> +		 */
> +		tcp_mtu_check_reprobe(sk);
>  		return -1;
>  	}
>  
