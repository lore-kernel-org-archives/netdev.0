From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Sat, 5 Jul 2014 22:10:07 +0200
Message-ID: <20140705201007.GC3869@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, richardcochran@gomail.com,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:57462 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301AbaGEUKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:10:33 -0400
Received: by mail-wg0-f46.google.com with SMTP id y10so2786374wgg.17
        for <netdev@vger.kernel.org>; Sat, 05 Jul 2014 13:10:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404416380-3545-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2014 at 03:39:33PM -0400, Willem de Bruijn wrote:

> +/**
> + *	struct scm_timestamping - timestamps exposed through cmsg
> + *
> + *	The timestamping interfaces SO_TIMESTAMPING, MSG_TSTAMP_*
> + *	communicate network timestamps by passing this struct in a cmsg with
> + *	recvmsg(). See Documentation/networking/timestamping.txt for details.
> + */
> +struct scm_timestamping {
> +	struct timespec ts[3];
> +};
> +
> +#define SCM_TSTAMP_SND		0x1	/* driver passed skb to NIC */
> +#define SCM_TSTAMP_ACK		0x2	/* transport layer saw ACK */
> +#define SCM_TSTAMP_ENQ		0x4	/* stack passed skb to TC layer */
> +#define SCM_TSTAMP_RCV		0x8	/* stack received skb */
> +#define SCM_TSTAMP_HWSYS	0x10	/* NIC tstamp in system format */
> +#define SCM_TSTAMP_HWRAW	0x20	/* NIC tstamp in native format */
> +
> +#define SCM_TSTAMP_OFF(n, ts)	(ts << (10 * n))

Hm ...
  
>  #endif /* _UAPI_LINUX_ERRQUEUE_H */
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c1a3303..1bcd05d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3521,6 +3521,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>  	memset(serr, 0, sizeof(*serr));
>  	serr->ee.ee_errno = ENOMSG;
>  	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
> +	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
>  
>  	err = sock_queue_err_skb(sk, skb);
>  
> diff --git a/net/socket.c b/net/socket.c
> index abf56b2..a31138d 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -106,6 +106,7 @@
>  #include <linux/sockios.h>
>  #include <linux/atalk.h>
>  #include <net/busy_poll.h>
> +#include <linux/errqueue.h>
>  
>  #ifdef CONFIG_NET_RX_BUSY_POLL
>  unsigned int sysctl_net_busy_read __read_mostly;
> @@ -696,9 +697,10 @@ EXPORT_SYMBOL(kernel_sendmsg);
>  void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>  	struct sk_buff *skb)
>  {
> +	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
>  	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
> -	struct timespec ts[3];
> -	int empty = 1;
> +	struct scm_timestamping tss;
> +	int tstype = 0, is_tx = skb_shinfo(skb)->tx_flags & SKBTX_ANY_TSTAMP;
>  	struct skb_shared_hwtstamps *shhwtstamps =
>  		skb_hwtstamps(skb);
>  
> @@ -714,28 +716,31 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>  			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
>  				 sizeof(tv), &tv);
>  		} else {
> -			skb_get_timestampns(skb, &ts[0]);
> +			struct timespec ts;
> +			skb_get_timestampns(skb, &ts);
>  			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
> -				 sizeof(ts[0]), &ts[0]);
> +				 sizeof(ts), &ts);
>  		}
>  	}
>  
> -
> -	memset(ts, 0, sizeof(ts));
> +	memset(&tss, 0, sizeof(tss));
>  	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
> -	    ktime_to_timespec_cond(skb->tstamp, ts + 0))
> -		empty = 0;
> +	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
> +		tstype |= is_tx ? serr->ee.ee_info : SCM_TSTAMP_RCV;
>  	if (shhwtstamps) {
>  		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
> -		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
> -			empty = 0;
> +		    ktime_to_timespec_cond(shhwtstamps->syststamp, tss.ts + 1))
> +			tstype |= SCM_TSTAMP_OFF(1, SCM_TSTAMP_HWSYS);
>  		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
> -		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
> -			empty = 0;
> +		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
> +			tstype |= SCM_TSTAMP_OFF(2, SCM_TSTAMP_HWRAW);

So you want ee_info to be a bit field like this?

   | 10 bits    | 10 bits    | 10 bits    | 2 bits |
   |------------+------------+------------+--------|
   | ts[0] type | ts[1] type | ts[2] type | rsv    |

Why not simplify this into two fields:

1. the index ts[] that contains a time stamp
2. the type of the time stamp

The kernel never provides more than one value in ts[], and it is hard
to imagine that we will ever do this. The original so_timestamping
interface and documentation seem to suggest that multiple values are
possible, but there was never, ever any code that did this. As an end
user, I found that very confusing.

I would prefer making the extended interface simpler, rather than
giving the impression that multiple time stamps are possible when they
really are not.

Thanks,
Richard

>  	}
> -	if (!empty)
> +	if (tstype) {
> +		if (is_tx)
> +			serr->ee.ee_info = tstype;
>  		put_cmsg(msg, SOL_SOCKET,
> -			 SCM_TIMESTAMPING, sizeof(ts), &ts);
> +			 SCM_TIMESTAMPING, sizeof(tss), &tss);
> +	}
>  }
>  EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
>  
> -- 
> 2.0.0.526.g5318336
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
