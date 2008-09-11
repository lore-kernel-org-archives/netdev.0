From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Thu, 11 Sep 2008 00:08:04 -0400
Message-ID: <48C899A4.2040904@redhat.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <87zlmhs7we.fsf@basil.nowhere.org> <48C6C300.4050102@redhat.com> <20080909190737.GB7714@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48773 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbYIKEKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 00:10:15 -0400
In-Reply-To: <20080909190737.GB7714@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> These apps have a love/hate relationship with TCP.  They'll probably love 
>> SCTP 5 years from now, but it's not mature enough for them yet.  They do 
>> want to minimize all latencies, 
> 
> Then they should just TCP_NODELAY.
> 
>> and many of the apps explicitly set 
>> TCP_NODELAY. 
> 
> That's the right thing for them.
> 
>> The goal here is to improve latencies on the supporting apps 
>> that aren't quite as carefully optimized as the main message daemons 
>> themselves.  If we can give them a knob that bounds their worst-case 
>> latency to 2-3 times their average latency, without risking network floods 
>> that won't show up in testing, they'll be much happier.
> 
> Hmm in theory I don't see a big drawback in making the these defaults sysctls.
> As in this untested patch. It's probably not the right solution
> for this problem. Still if you want to experiment. This makes both 
> the ato default and the delack default tunable. You'll have to restart
> sockets for it to take effect.
> 
> -Andi
> 
> ---
> 
> 
> Make ato min and delack min tunable 
> 
> This might potentially help with some programs which have problems with nagle.
> 
> Sockets have to be restarted
> 
> TBD documentation for the new sysctls
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

It needs the changed constants replaced with the _DEFAULT versions in 
net/dccp/timer.c and net/dccp/output.c to build with DCCP enabled.  I did that, 
and tested it (over loopback).  The tunables come up at 0, not the expected 
default values, and when that happens, latencies are extremely low, as would be 
expected with a value of 0, but when I set net.ipv4.tcp_delack_min to *any* 
non-zero value, the old 40 ms magic number becomes 200 ms.  I haven't yet 
figured out why.  Tweaking net.ipv4.tcp_ato_min isn't having any observable 
effect on my loopback latencies.

I think there may be something worth pursuing with a tcp_delack_min tunable. 
Any suggestions on where I should look to debug this?

-- Chris

> Index: linux-2.6.27-rc4-misc/include/net/tcp.h
> ===================================================================
> --- linux-2.6.27-rc4-misc.orig/include/net/tcp.h
> +++ linux-2.6.27-rc4-misc/include/net/tcp.h
> @@ -118,12 +118,16 @@ extern void tcp_time_wait(struct sock *s
>  
>  #define TCP_DELACK_MAX	((unsigned)(HZ/5))	/* maximal time to delay before sending an ACK */
>  #if HZ >= 100
> -#define TCP_DELACK_MIN	((unsigned)(HZ/25))	/* minimal time to delay before sending an ACK */
> -#define TCP_ATO_MIN	((unsigned)(HZ/25))
> +#define TCP_DELACK_MIN_DEFAULT	((unsigned)(HZ/25))	/* minimal time to delay before sending an ACK */
> +#define TCP_ATO_MIN_DEFAULT	((unsigned)(HZ/25))
>  #else
> -#define TCP_DELACK_MIN	4U
> -#define TCP_ATO_MIN	4U
> +#define TCP_DELACK_MIN_DEFAULT	4U
> +#define TCP_ATO_MIN_DEFAULT	4U
>  #endif
> +
> +#define TCP_DELACK_MIN sysctl_tcp_delack_min
> +#define TCP_ATO_MIN sysctl_tcp_ato_min
> +
>  #define TCP_RTO_MAX	((unsigned)(120*HZ))
>  #define TCP_RTO_MIN	((unsigned)(HZ/5))
>  #define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
> @@ -236,6 +240,8 @@ extern int sysctl_tcp_base_mss;
>  extern int sysctl_tcp_workaround_signed_windows;
>  extern int sysctl_tcp_slow_start_after_idle;
>  extern int sysctl_tcp_max_ssthresh;
> +extern int sysctl_tcp_ato_min;
> +extern int sysctl_tcp_delack_min;
>  
>  extern atomic_t tcp_memory_allocated;
>  extern atomic_t tcp_sockets_allocated;
> Index: linux-2.6.27-rc4-misc/net/ipv4/sysctl_net_ipv4.c
> ===================================================================
> --- linux-2.6.27-rc4-misc.orig/net/ipv4/sysctl_net_ipv4.c
> +++ linux-2.6.27-rc4-misc/net/ipv4/sysctl_net_ipv4.c
> @@ -717,6 +717,24 @@ static struct ctl_table ipv4_table[] = {
>  	},
>  	{
>  		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_delack_min",
> +		.data		= &sysctl_tcp_delack_min,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_jiffies,
> +		.strategy	= &sysctl_jiffies
> +	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_ato_min",
> +		.data		= &sysctl_tcp_ato_min,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_jiffies,
> +		.strategy	= &sysctl_jiffies
> +	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
>  		.procname	= "udp_mem",
>  		.data		= &sysctl_udp_mem,
>  		.maxlen		= sizeof(sysctl_udp_mem),
> Index: linux-2.6.27-rc4-misc/net/ipv4/tcp_timer.c
> ===================================================================
> --- linux-2.6.27-rc4-misc.orig/net/ipv4/tcp_timer.c
> +++ linux-2.6.27-rc4-misc/net/ipv4/tcp_timer.c
> @@ -29,6 +29,8 @@ int sysctl_tcp_keepalive_intvl __read_mo
>  int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
>  int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
>  int sysctl_tcp_orphan_retries __read_mostly;
> +int sysctl_tcp_delack_min __read_mostly = TCP_DELACK_MIN_DEFAULT;
> +int sysctl_tcp_ato_min __read_mostly = TCP_ATO_MIN_DEFAULT;
>  
>  static void tcp_write_timer(unsigned long);
>  static void tcp_delack_timer(unsigned long);
> Index: linux-2.6.27-rc4-misc/net/ipv4/tcp_output.c
> ===================================================================
> --- linux-2.6.27-rc4-misc.orig/net/ipv4/tcp_output.c
> +++ linux-2.6.27-rc4-misc/net/ipv4/tcp_output.c
> @@ -2436,7 +2436,7 @@ void tcp_send_delayed_ack(struct sock *s
>  		 * directly.
>  		 */
>  		if (tp->srtt) {
> -			int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
> +			int rtt = max_t(unsigned, tp->srtt >> 3, TCP_DELACK_MIN);
>  
>  			if (rtt < max_ato)
>  				max_ato = rtt;
> 

