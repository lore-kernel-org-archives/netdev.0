From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] include listenq max/backlog in tcp_info and related reports
 - correct version/signorder
Date: Mon, 17 Sep 2007 16:06:13 -0400
Message-ID: <46EEDE35.8090102@psc.edu>
References: <200709171950.MAA14825@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51739 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756128AbXIQUGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 16:06:19 -0400
In-Reply-To: <200709171950.MAA14825@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any reason you're overloading tcpi_unacked and tcpi_sacked?  It seems 
that setting idiag_rqueue and idiag_wqueue are sufficient.

   -John


Rick Jones wrote:
> Return some useful information such as the maximum listen backlog and the
> current listen backlog in the tcp_info structure and have that match what
> one can see in /proc/net/tcp, /proc/net/tcp6, and INET_DIAG_INFO.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> 
> diff -r bdcdd0e1ee9d Documentation/networking/proc_net_tcp.txt
> --- a/Documentation/networking/proc_net_tcp.txt	Sat Sep 01 07:00:31 2007 +0000
> +++ b/Documentation/networking/proc_net_tcp.txt	Tue Sep 11 10:38:23 2007 -0700
> @@ -20,8 +20,8 @@ up into 3 parts because of the length of
>        |        |     |     |       |--> number of unrecovered RTO timeouts
>        |        |     |     |----------> number of jiffies until timer expires
>        |        |     |----------------> timer_active (see below)
> -      |        |----------------------> receive-queue
> -      |-------------------------------> transmit-queue
> +      |        |----------------------> receive-queue or connection backlog
> +      |-------------------------------> transmit-queue or connection limit
>  
>     1000        0 54165785 4 cd1e6040 25 4 27 3 -1
>      |          |    |     |    |     |  | |  | |--> slow start size threshold, 
> diff -r bdcdd0e1ee9d net/ipv4/tcp.c
> --- a/net/ipv4/tcp.c	Sat Sep 01 07:00:31 2007 +0000
> +++ b/net/ipv4/tcp.c	Tue Sep 11 10:38:23 2007 -0700
> @@ -2030,8 +2030,14 @@ void tcp_get_info(struct sock *sk, struc
>  	info->tcpi_snd_mss = tp->mss_cache;
>  	info->tcpi_rcv_mss = icsk->icsk_ack.rcv_mss;
>  
> -	info->tcpi_unacked = tp->packets_out;
> -	info->tcpi_sacked = tp->sacked_out;
> +	if (sk->sk_state == TCP_LISTEN) {
> +		info->tcpi_unacked = sk->sk_ack_backlog;
> +		info->tcpi_sacked = sk->sk_max_ack_backlog;
> +	}
> +	else {
> +		info->tcpi_unacked = tp->packets_out;
> +		info->tcpi_sacked = tp->sacked_out;
> +	}
>  	info->tcpi_lost = tp->lost_out;
>  	info->tcpi_retrans = tp->retrans_out;
>  	info->tcpi_fackets = tp->fackets_out;
> diff -r bdcdd0e1ee9d net/ipv4/tcp_diag.c
> --- a/net/ipv4/tcp_diag.c	Sat Sep 01 07:00:31 2007 +0000
> +++ b/net/ipv4/tcp_diag.c	Tue Sep 11 10:38:23 2007 -0700
> @@ -25,11 +25,14 @@ static void tcp_diag_get_info(struct soc
>  	const struct tcp_sock *tp = tcp_sk(sk);
>  	struct tcp_info *info = _info;
>  
> -	if (sk->sk_state == TCP_LISTEN)
> +	if (sk->sk_state == TCP_LISTEN) {
>  		r->idiag_rqueue = sk->sk_ack_backlog;
> -	else
> +		r->idiag_wqueue = sk->sk_max_ack_backlog;
> +	}
> +	else {
>  		r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
> -	r->idiag_wqueue = tp->write_seq - tp->snd_una;
> +		r->idiag_wqueue = tp->write_seq - tp->snd_una;
> +	}
>  	if (info != NULL)
>  		tcp_get_info(sk, info);
>  }
> diff -r bdcdd0e1ee9d net/ipv4/tcp_ipv4.c
> --- a/net/ipv4/tcp_ipv4.c	Sat Sep 01 07:00:31 2007 +0000
> +++ b/net/ipv4/tcp_ipv4.c	Tue Sep 11 10:38:23 2007 -0700
> @@ -2320,7 +2320,8 @@ static void get_tcp4_sock(struct sock *s
>  	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
>  			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
>  		i, src, srcp, dest, destp, sk->sk_state,
> -		tp->write_seq - tp->snd_una,
> +		sk->sk_state == TCP_LISTEN ? sk->sk_max_ack_backlog :
> +					     (tp->write_seq - tp->snd_una),
>  		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
>  					     (tp->rcv_nxt - tp->copied_seq),
>  		timer_active,
> diff -r bdcdd0e1ee9d net/ipv6/tcp_ipv6.c
> --- a/net/ipv6/tcp_ipv6.c	Sat Sep 01 07:00:31 2007 +0000
> +++ b/net/ipv6/tcp_ipv6.c	Tue Sep 11 10:38:23 2007 -0700
> @@ -2005,8 +2005,10 @@ static void get_tcp6_sock(struct seq_fil
>  		   dest->s6_addr32[0], dest->s6_addr32[1],
>  		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
>  		   sp->sk_state,
> -		   tp->write_seq-tp->snd_una,
> -		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
> +		   (sp->sk_state == TCP_LISTEN) ? sp->sk_max_ack_backlog:
> +						  tp->write_seq-tp->snd_una,
> +		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : 
> +					(tp->rcv_nxt - tp->copied_seq),
>  		   timer_active,
>  		   jiffies_to_clock_t(timer_expires - jiffies),
>  		   icsk->icsk_retransmits,
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

