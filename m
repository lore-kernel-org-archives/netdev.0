From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 1/3] [TCP]: Fix NewReno's fast rexmit/recovery
 problems with GSOed skb
Date: Mon, 7 Apr 2008 14:33:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804071432480.32028@wrl-59.cs.helsinki.fi>
References: <1207567537-16393-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1207567537-16393-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1297057278-1207567996=:32028"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Soeren Sonnenburg <kernel@nn7.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54946 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbYDGLdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 07:33:18 -0400
In-Reply-To: <1207567537-16393-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1297057278-1207567996=:32028
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 7 Apr 2008, Ilpo Järvinen wrote:

> Fixes a long-standing bug which makes NewReno recovery crippled.
> With GSO the whole head skb was marked as LOST which is in
> violation of NewReno procedure that only wants to mark one packet
> and ended up breaking our TCP code by causing counter overflow
> because our code was built on top of assumption about valid
> NewReno procedure. This manifested as triggering a WARN_ON for
> the overflow in a number of places.
> 
> It seems relatively safe alternative to just do nothing if
> tcp_fragment fails due to oom because another duplicate ACK is
> likely to be received soon and the fragmentation will be retried.
> 
> Special thanks goes to Soeren Sonnenburg <kernel@nn7.de> who was
> lucky enough to be able to reproduce this so that the warning
> for the overflow was hit. It's not as easy task as it seems even
> if this bug happens quite often because the amount of outstanding
> data is pretty significant for the mismarkings to lead to an
> overflow.
> 
> Because it's very late in 2.6.25-rc cycle (if this even makes in
> time), I didn't want to touch anything with SACK enabled here.
> Fragmenting might be useful for it as well but it's more or less
> a policy decision rather than mandatory fix. Thus there's no need
> to rush and we can postpone considering tcp_fragment with SACK
> for 2.6.26.
> 
> In 2.6.24 and earlier, this very same bug existed but the effect
> is slightly different because of a small changes in the if
> conditions that fit to the patch's context. With them nothing
> got lost marker and thus no retransmissions happened.
> 
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |   22 ++++++++++++++++++----
>  1 files changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 6e46b4c..58cad8b 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2138,7 +2138,9 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct sk_buff *skb;
> -	int cnt;
> +	int cnt, oldcnt;
> +	int err;
> +	unsigned int mss;
>  
>  	BUG_TRAP(packets <= tp->packets_out);
>  	if (tp->lost_skb_hint) {
> @@ -2157,13 +2159,25 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
>  		tp->lost_skb_hint = skb;
>  		tp->lost_cnt_hint = cnt;
>  
> +		if (after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
> +			break;
> +
> +		oldcnt = cnt;
>  		if (tcp_is_fack(tp) || tcp_is_reno(tp) ||
>  		    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
>  			cnt += tcp_skb_pcount(skb);
>  
> -		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
> -		    after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
> -			break;
> +		if ((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) {

...Nah, this won't work too well. I'll repost soon.

> +			if (tcp_is_sack(tp) || (oldcnt >= packets))
> +				break;
> +
> +			mss = skb_shinfo(skb)->gso_size;
> +			err = tcp_fragment(sk, skb, (packets - oldcnt) * mss, mss);
> +			if (err < 0)
> +				break;
> +			cnt = packets;
> +		}
> +
>  		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
>  			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
>  			tp->lost_out += tcp_skb_pcount(skb);
> 

-- 
 i.
---696208474-1297057278-1207567996=:32028--
