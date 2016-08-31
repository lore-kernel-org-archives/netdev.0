From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RT PATCH 2/2] net: add a lock around icmp_sk()
Date: Wed, 31 Aug 2016 09:37:43 -0700
Message-ID: <1472661463.14381.327.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160831160049.14303-1-bigeasy@linutronix.de>
         <20160831160049.14303-2-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
        tglx@linutronix.de, Steven Rostedt <rostedt@goodmis.org>,
        netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831160049.14303-2-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-31 at 18:00 +0200, Sebastian Andrzej Siewior wrote:
> It looks like the this_cpu_ptr() access in icmp_sk() is protected with
> local_bh_disable(). To avoid missing serialization in -RT I am adding
> here a local lock. No crash has been observed, this is just precaution.
> 


Hmm...

> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  net/ipv4/icmp.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index c1f1d5030d37..63731fd6af3e 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -78,6 +78,7 @@
>  #include <linux/string.h>
>  #include <linux/netfilter_ipv4.h>
>  #include <linux/slab.h>
> +#include <linux/locallock.h>
>  #include <net/snmp.h>
>  #include <net/ip.h>
>  #include <net/route.h>
> @@ -205,6 +206,8 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES+1];
>   *
>   *	On SMP we have one ICMP socket per-cpu.
>   */
> +static DEFINE_LOCAL_IRQ_LOCK(icmp_sk_lock);
> +
>  static struct sock *icmp_sk(struct net *net)
>  {
>  	return *this_cpu_ptr(net->ipv4.icmp_sk);
> @@ -216,12 +219,14 @@ static inline struct sock *icmp_xmit_lock(struct net *net)
>  
>  	local_bh_disable();
>  
> +	local_lock(icmp_sk_lock);

Deadlock alert ?
Please read the comment few lines after, explaining why we have to use
spin_trylock().
Or maybe I should double check what is local_lock() in RT

>  	sk = icmp_sk(net);
>  
>  	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {

...
>  		/* This can happen if the output path signals a
>  		 * dst_link_failure() for an outgoing ICMP packet.
>  		 */


> +		local_unlock(icmp_sk_lock);
>  		local_bh_enable();
>  		return NULL;
