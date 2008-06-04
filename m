From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 4 Jun 2008 09:25:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806040921530.16057@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu>  <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
  <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
 <1212537241.6980.12.camel@localhost>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1218874784-1212560738=:16057"
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	mcmanus@ducksong.com, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55572 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbYFDGZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 02:25:40 -0400
In-Reply-To: <1212537241.6980.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1218874784-1212560738=:16057
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jun 2008, Joe Perches wrote:

> On Wed, 2008-06-04 at 02:22 +0300, Ilpo Järvinen wrote:
> > But here's somewhat more likely explanation... Only compile tested...
> > It probably needs some commenting from people who understand locking 
> > variants & details (I don't).
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index c9454f0..d21d2b9 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4562,6 +4562,7 @@ static int tcp_defer_accept_check(struct sock *sk)
> >  	struct tcp_sock *tp = tcp_sk(sk);
> >  
> >  	if (tp->defer_tcp_accept.request) {
> > +		struct sock *listen_sk = tp->defer_tcp_accept.listen_sk;
> 
> Not commenting on the locking, but I think the code
> would be clearer if tp->defer_tcp_accept was used in
> a temporary instead.

Only fixes to net-2.6 now, as agreed. ...So I try to leave syntax cleanup 
to net-next.

Besides, there's a trap which makes your patch a lot worse than
mine... ;-) I too once tried a version without temporary until
noticed that trap.

> Perhaps:
> 
>  net/ipv4/tcp_input.c |   33 ++++++++++++++++-----------------
>  1 files changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index b54d9d3..f846e11 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4535,18 +4535,18 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
>  static int tcp_defer_accept_check(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -
> -	if (tp->defer_tcp_accept.request) {
> -		int queued_data =  tp->rcv_nxt - tp->copied_seq;
> -		int hasfin =  !skb_queue_empty(&sk->sk_receive_queue) ?
> +	struct tcp_deferred_accept_info *tdai = &tp->defer_tcp_accept;
> +	if (tdai->request) {
> +		int queued_data = tp->rcv_nxt - tp->copied_seq;
> +		int hasfin = !skb_queue_empty(&sk->sk_receive_queue) ?
>  			tcp_hdr((struct sk_buff *)
>  				sk->sk_receive_queue.prev)->fin : 0;
>  
>  		if (queued_data && hasfin)
>  			queued_data--;
>  
> -		if (queued_data &&
> -		    tp->defer_tcp_accept.listen_sk->sk_state == TCP_LISTEN) {
> +		bh_lock_sock(tdai->listen_sk);
> +		if (queued_data && tdai->listen_sk->sk_state == TCP_LISTEN) {
>  			if (sock_flag(sk, SOCK_KEEPOPEN)) {
>  				inet_csk_reset_keepalive_timer(sk,
>  							       keepalive_time_when(tp));
> @@ -4554,23 +4554,22 @@ static int tcp_defer_accept_check(struct sock *sk)
>  				inet_csk_delete_keepalive_timer(sk);
>  			}
>  
> -			inet_csk_reqsk_queue_add(
> -				tp->defer_tcp_accept.listen_sk,
> -				tp->defer_tcp_accept.request,
> -				sk);
> +			inet_csk_reqsk_queue_add(tdai->listen_sk,
> +						 tdai->request,
> +						 sk);
>  
> -			tp->defer_tcp_accept.listen_sk->sk_data_ready(
> -				tp->defer_tcp_accept.listen_sk, 0);
> +			tdai->listen_sk->sk_data_ready(tdai->listen_sk, 0);
>  
> -			sock_put(tp->defer_tcp_accept.listen_sk);
> +			sock_put(tdai->listen_sk);
>  			sock_put(sk);
> -			tp->defer_tcp_accept.listen_sk = NULL;
> -			tp->defer_tcp_accept.request = NULL;
> -		} else if (hasfin ||
> -			   tp->defer_tcp_accept.listen_sk->sk_state != TCP_LISTEN) {
> +			tdai->listen_sk = NULL;
> +			tdai->request = NULL;

uh-oh...

> +		} else if (hasfin || tdai->listen_sk->sk_state != TCP_LISTEN) {
> +			bh_unlock_sock(tdai->listen_sk);
>  			tcp_reset(sk);
>  			return -1;
>  		}
> +		bh_unlock_sock(tdai->listen_sk);

...which will crash in here. 

NAK.

>  	}
>  	return 0;
>  }
> 
> 
> 

-- 
 i.
---696208474-1218874784-1212560738=:16057--
