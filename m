From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6] [TCP]: fix D-SACK cwnd handling
Date: Thu, 25 Oct 2007 11:39:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710251123340.25107@kivilampi-30.cs.helsinki.fi>
References: <20071025.171147.107738702.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2069886062-1193301544=:25107"
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: Ryousei Takano <takano-ryousei@aist.go.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54215 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbXJYIjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 04:39:07 -0400
In-Reply-To: <20071025.171147.107738702.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2069886062-1193301544=:25107
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 25 Oct 2007, Ryousei Takano wrote:

> In the current net-2.6 kernel, handling FLAG_DSACKING_ACK is broken.
> The flag is cleared to 1 just after FLAG_DSACKING_ACK is set.
> 
>         if (found_dup_sack)
>                 flag |= FLAG_DSACKING_ACK;
> 	:
> 	flag = 1;
> 
> To fix it, this patch introduces a part of the tcp_sacktag_state patch:
> 	http://marc.info/?l=linux-netdev&m=119210560431519&w=2
> 
> Do you plan to apply the tcp_sacktag_state patch?
> Or please apply this patch.

Thanks for noticing this, it seems I've been playing too much already with 
the safer code where the possibility of this kind of annoying trap is 
already removed and wasn't therefore careful enough anymore. Luckily, it 
doesn't have huge impact.

...I'd say that this is better for now (it could have been a separate one
right from the beginning, conforms better to just-one-thing-per-patch). 
State patch and other things that depend on it are not targetted, at 
earliest, to 2.6.25 AFAICT, so no big hurry to have it fully.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.

> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
> ---
>  net/ipv4/tcp_input.c |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 3dbbb44..59e3c9a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1248,6 +1248,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	int cached_fack_count;
>  	int i;
>  	int first_sack_index;
> +	int force_one_sack;
>  
>  	if (!tp->sacked_out) {
>  		if (WARN_ON(tp->fackets_out))
> @@ -1272,18 +1273,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	 * if the only SACK change is the increase of the end_seq of
>  	 * the first block then only apply that SACK block
>  	 * and use retrans queue hinting otherwise slowpath */
> -	flag = 1;
> +	force_one_sack = 1;
>  	for (i = 0; i < num_sacks; i++) {
>  		__be32 start_seq = sp[i].start_seq;
>  		__be32 end_seq = sp[i].end_seq;
>  
>  		if (i == 0) {
>  			if (tp->recv_sack_cache[i].start_seq != start_seq)
> -				flag = 0;
> +				force_one_sack = 0;
>  		} else {
>  			if ((tp->recv_sack_cache[i].start_seq != start_seq) ||
>  			    (tp->recv_sack_cache[i].end_seq != end_seq))
> -				flag = 0;
> +				force_one_sack = 0;
>  		}
>  		tp->recv_sack_cache[i].start_seq = start_seq;
>  		tp->recv_sack_cache[i].end_seq = end_seq;
> @@ -1295,7 +1296,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	}
>  
>  	first_sack_index = 0;
> -	if (flag)
> +	if (force_one_sack)
>  		num_sacks = 1;
>  	else {
>  		int j;
> @@ -1321,9 +1322,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  		}
>  	}
>  
> -	/* clear flag as used for different purpose in following code */
> -	flag = 0;
> -
>  	/* Use SACK fastpath hint if valid */
>  	cached_skb = tp->fastpath_skb_hint;
>  	cached_fack_count = tp->fastpath_cnt_hint;
> 
---696243703-2069886062-1193301544=:25107--
