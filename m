From: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net] tcp: fix tcp_match_skb_to_sack() for unaligned SACK
 at end of an skb
Date: Fri, 20 Jun 2014 11:15:33 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1406201056590.21393@melkinpaasi.cs.helsinki.fi>
References: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from script.cs.helsinki.fi ([128.214.11.1]:36889 "EHLO
	script.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189AbaFTIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 04:20:40 -0400
In-Reply-To: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jun 2014, Neal Cardwell wrote:

> If there is an MSS change (or misbehaving receiver) that causes a SACK
> to arrive that covers the end of an skb but is less than one MSS, then
> tcp_match_skb_to_sack() was rounding up pkt_len to the full length of
> the skb ("Round if necessary..."), then chopping all bytes off the skb
> and creating a zero-byte skb in the write queue.
> 
> This was visible now because the recently simplified TLP logic in
> bef1909ee3ed1c ("tcp: fixing TLP's FIN recovery") could find that 0-byte
> skb at the end of the write queue, and now that we do not check that
> skb's length we could send it as a TLP probe.
> 
> Consider the following example scenario:
> 
>  mss: 1000
>  skb: seq: 0 end_seq: 4000  len: 4000
>  SACK: start_seq: 3999 end_seq: 4000
> 
> The tcp_match_skb_to_sack() code will compute:
> 
>  in_sack = false
>  pkt_len = start_seq - TCP_SKB_CB(skb)->seq = 3999 - 0 = 3999
>  new_len = (pkt_len / mss) * mss = (3999/1000)*1000 = 3000
>  new_len += mss = 4000
> 
> Previously we would find the new_len > skb->len check failing, so we
> would fall through and set pkt_len = new_len = 4000 and chop off
> pkt_len of 4000 from the 4000-byte skb, leaving a 0-byte segment
> afterward in the write queue.
> 
> With this new commit, we notice that the new new_len >= skb->len check
> succeeds, so that we return without trying to fragment.
> 
> Fixes: adb92db857ee ("tcp: Make SACK code to split only at mss boundaries")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 40661fc..b5c2375 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1162,7 +1162,7 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
>  			unsigned int new_len = (pkt_len / mss) * mss;
>  			if (!in_sack && new_len < pkt_len) {
>  				new_len += mss;
> -				if (new_len > skb->len)
> +				if (new_len >= skb->len)

Any idea if tcp_fragment WARN_ON(len > skb->len)) could be similarly 
made stricter to include equality? Maybe SACK for a super skb
including FIN but not covered by the SACK block might need it so 
that equality check there wouldn't work?

-- 
 i.
