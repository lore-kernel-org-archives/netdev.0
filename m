From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] icmp: add a global rate limitation
Date: Fri, 19 Sep 2014 07:56:53 -0700
Message-ID: <1411138613.24444.13.camel@joe-AO725>
References: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0005.hostedemail.com ([216.40.44.5]:39576 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756425AbaISO45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 10:56:57 -0400
In-Reply-To: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 07:38 -0700, Eric Dumazet wrote:
> Current ICMP rate limiting uses inetpeer cache, which is an RBL tree
> protected by a lock, meaning that hosts can be stuck hard if all cpus
> want to check ICMP limits.
> 
> When say a DNS or NTP server process is restarted, inetpeer tree grows
> quick and machine comes to its knees.
> 
> iptables can not help because the bottleneck happens before ICMP
> messages are even cooked and sent.
> 
> This patch adds a new global limitation, using a token bucket filter,
> controlled by two new sysctl :
> 
> icmp_msgs_per_sec - INTEGER
>     Limit maximal number of ICMP packets sent per second from this host.
>     Only messages whose type matches icmp_ratemask are
>     controlled by this limit.
>     Default: 1000
> 
> icmp_msgs_burst - INTEGER
>     icmp_msgs_per_sec controls number of ICMP packets sent per second,
>     while icmp_msgs_burst controls the burst size of these packets.
>     Default: 50

nice.

> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
[]
> @@ -231,12 +231,62 @@ static inline void icmp_xmit_unlock(struct sock *sk)
>  	spin_unlock_bh(&sk->sk_lock.slock);
>  }
>  
> +int sysctl_icmp_msgs_per_sec __read_mostly = 1000;
> +int sysctl_icmp_msgs_burst __read_mostly = 50;
> +
> +static struct {
> +	spinlock_t	lock;
> +	u32		credit;
> +	u32		stamp;
> +} icmp_global = {
> +	.lock		= __SPIN_LOCK_UNLOCKED(icmp_global.lock),
> +};

Is there any real benefit using a u32 stamp
instead of unsigned long?

The stamp comparisons are to jiffies and now
have slightly odd (u32) casts.

> +
> +/**
> + * icmp_global_allow - Are we allowed to send one more ICMP message ?
> + *
> + * Uses a token bucket to limit our ICMP messages to sysctl_icmp_msgs_per_sec.
> + * Returns false if we reached the limit and can not send another packet.
> + * Note: called with BH disabled
> + */
> +bool icmp_global_allow(void)
> +{
> +	u32 credit, delta, incr = 0, now = (u32)jiffies;

Doesn't casting jiffies costs a couple cycles
on a 64 bit machine?
