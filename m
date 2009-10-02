From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 2 Oct 2009 15:29:22 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0910021520280.13543@wel-95.cs.helsinki.fi>
References: <pan.2009.09.03.19.55.37.672875@googlemail.com> <20090907072143.GA5966@ff.dom.local> <20091001.154913.88345178.davem@davemloft.net> <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-427312890-1254486562=:13543"
Cc: jarkao2@gmail.com, holger.hoffstaette@googlemail.com,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	Evgeniy Polyakov <zbr@ioremap.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59658 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067AbZJBM3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 08:29:20 -0400
In-Reply-To: <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-427312890-1254486562=:13543
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Fri, 2 Oct 2009, Ilpo Järvinen wrote:

> On Thu, 1 Oct 2009, David Miller wrote:
> 
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 7 Sep 2009 07:21:43 +0000
> > 
> > > While Eric is analyzing your data, I guess you could try reverting
> > > some stuff around this tcp_tw_recycle, and my tcp ignorance would
> > > point these commits for the beginning:
> > > 
> > > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=fc1ad92dfc4e363a055053746552cdb445ba5c57
> > > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=c887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72
> > 
> > Ilpo's cleanup (the second commit listed) looks most likely to
> > be a possibility.
> > 
> > But I surely cannot find any bugs in it, even after studying it
> > a few times.
> > 
> > Ilpo could you audit it one more time for us just in case?
> 
> Argh, not that one ...the jungle of negations. But I'll try to go it 
> through once more but I tell you I did go through those negations multiple 
> times already before submitting it :-).
> 
> > I also looked through all the TCP commits in 2.6.29 to 2.6.30
> > and I could not find anything else that might cause stalls with
> > time-wait recycled connections.
> 
> What about the more than 64k connections change a9d8f9110d7e953c2f2 (or 
> its fixes), it might be another possibility? ...It certainly does 
> something related to reuse and happens to be in the correct time frame... 
> (I've added Evgeniy).

Here's my full analysis:

> c887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index d74ac30..255ca35 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -997,11 +997,21 @@ static inline int tcp_fin_time(const struct sock *sk)
>  	return fin_timeout;
>  }
>  
> -static inline int tcp_paws_check(const struct tcp_options_received *rx_opt, int rst)
> +static inline int tcp_paws_check(const struct tcp_options_received *rx_opt,
> +				 int paws_win)
>  {
> -	if ((s32)(rx_opt->rcv_tsval - rx_opt->ts_recent) >= 0)
> -		return 0;
> -	if (get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS)
> +	if ((s32)(rx_opt->ts_recent - rx_opt->rcv_tsval) <= paws_win)
> +		return 1;
> +	if (unlikely(get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static inline int tcp_paws_reject(const struct tcp_options_received *rx_opt,
> +				  int rst)
> +{
> +	if (tcp_paws_check(rx_opt, 0))
>  		return 0;

First condition is * -1 to switch subtraction terms around (and reverses
inequality). The other condition is very much the same. In addition, it 
has an extra negation round but still OK.

>  
>  	/* RST segments are not recommended to carry timestamp,
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index f527a16..b7d02c5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3883,8 +3883,7 @@ static inline void tcp_replace_ts_recent(struct tcp_sock *tp, u32 seq)
>  		 * Not only, also it occurs for expired timestamps.
>  		 */
>  
> -		if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >= 0 ||

* -1 here too.

> -		   get_seconds() >= tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS)

The very same condition.

> +		if (tcp_paws_check(&tp->rx_opt, 0))
>  			tcp_store_ts_recent(tp);
>  	}
>  }
> @@ -3936,9 +3935,9 @@ static inline int tcp_paws_discard(const struct sock *sk,
>  				   const struct sk_buff *skb)
>  {
>  	const struct tcp_sock *tp = tcp_sk(sk);
> -	return ((s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) > TCP_PAWS_WINDOW &&
> -		get_seconds() < tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS &&
> -		!tcp_disordered_ack(sk, skb));
> +
> +	return !tcp_paws_check(&tp->rx_opt, TCP_PAWS_WINDOW) &&

DeMorgan: 

   (a > b) &&  (c < d) 
          <==>
!(!(a > b) || !(c < d))
          <==>
!((a <= b) || (c >= d))

> +	       !tcp_disordered_ack(sk, skb);
>  }
>  
>  /* Check segment sequence number for validity.
> @@ -5513,7 +5512,7 @@ discard:
>  
>  	/* PAWS check. */
>  	if (tp->rx_opt.ts_recent_stamp && tp->rx_opt.saw_tstamp &&
> -	    tcp_paws_check(&tp->rx_opt, 0))
> +	    tcp_paws_reject(&tp->rx_opt, 0))

A plain rename, the rest likewise.

>  		goto discard_and_undo;
>  
>  	if (th->syn) {
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 4b0df3e..43bbba7 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -107,7 +107,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
>  		if (tmp_opt.saw_tstamp) {
>  			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
>  			tmp_opt.ts_recent_stamp	= tcptw->tw_ts_recent_stamp;
> -			paws_reject = tcp_paws_check(&tmp_opt, th->rst);
> +			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
>  		}
>  	}
>  
> @@ -511,7 +511,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
>  			 * from another data.
>  			 */
>  			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
> -			paws_reject = tcp_paws_check(&tmp_opt, th->rst);
> +			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
>  		}
>  	}
>  

...Which concludes the patch innocent. ...I certainly won't regret this 
cleanup after having to figure that mess out once again - that is to say,
hopefully for the last time :-). ...Sadly the problem remains.

-- 
 i.
--8323329-427312890-1254486562=:13543--
