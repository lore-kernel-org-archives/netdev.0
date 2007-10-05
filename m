From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 2/2] TCP: skip processing cached SACK blocks
Date: Fri, 5 Oct 2007 13:37:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710041516170.31129@kivilampi-30.cs.helsinki.fi>
References: <20071004.184456.40407483.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-717307352-1191580641=:31129"
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41121 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbXJEKhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 06:37:25 -0400
In-Reply-To: <20071004.184456.40407483.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-717307352-1191580641=:31129
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 4 Oct 2007, TAKANO Ryousei wrote:

> This patch allows to process only newly reported SACK blocks at the
> sender side. An ACK packet contains up to three SACK blocks, and some

  "A SACK option that specifies n blocks will have a length of 8*n+2
   bytes, so the 40 bytes available for TCP options can specify a
   maximum of 4 blocks.  It is expected that SACK will often be used in
   conjunction with the Timestamp option used for RTTM [Jacobson92],
   which takes an additional 10 bytes (plus two bytes of padding); thus
   a maximum of 3 SACK blocks will be allowed in this case." [RFC2018]

:-)

> of them may be already reported and processed blocks.  This patch 
> prevents processing of such already processed SACK blocks.
> 
> Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
> Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
> ---
>  net/ipv4/tcp_input.c |   24 ++++++++++++++++++++++++
>  1 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index bbad2cd..9615fc9 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	int cached_fack_count;
>  	int i;
>  	int first_sack_index;
> +	u8 sack_block_skip[4] = {0,0,0,0};
>  
>  	if (!tp->sacked_out)
>  		tp->fackets_out = 0;
> @@ -1012,6 +1013,21 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
>  		return 0;
>  
> +	/* Skip processing cached SACK blocks. */
> +	for (i = 0; i < num_sacks; i++) {
> +		__be32 start_seq = sp[i].start_seq;
> +		__be32 end_seq = sp[i].end_seq;
> +		int j;
> +
> +		for (j = 0; j < ARRAY_SIZE(tp->recv_sack_cache); j++) {
> +			if ((tp->recv_sack_cache[j].start_seq == start_seq) &&
> +			    (tp->recv_sack_cache[j].end_seq == end_seq)) {
> +				sack_block_skip[i] = 1;
> +				break;
> +			}
> +		}
> +	}
> +

I'm somewhat against adding more and more special cases to sacktag, 
there's still need for more special cases after this one to avoid very 
expensive processing (I guess they just won't occur in your scenario)!
...I would rather remove whole special case mess of the fastpath and
have a more generic solution (see the patch I point into in the reply
to patch 1/2)...

>  	/* SACK fastpath:
>  	 * if the only SACK change is the increase of the end_seq of
>  	 * the first block then only apply that SACK block
> @@ -1051,11 +1067,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  				if (after(ntohl(sp[j].start_seq),
>  					  ntohl(sp[j+1].start_seq))){
>  					struct tcp_sack_block_wire tmp;
> +					u8 sbtmp;
>  
>  					tmp = sp[j];
>  					sp[j] = sp[j+1];
>  					sp[j+1] = tmp;
>  
> +					sbtmp = sack_block_skip[j];
> +					sack_block_skip[j] = sack_block_skip[j+1];
> +					sack_block_skip[j+1] = sbtmp;
> +
>  					/* Track where the first SACK block goes to */
>  					if (j == first_sack_index)
>  						first_sack_index = j+1;
> @@ -1083,6 +1104,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  		int fack_count;
>  		int dup_sack = (found_dup_sack && (i == first_sack_index));
>  
> +		if (sack_block_skip[i])

DSACKs must always be processed, so please add:

&& !dup_sack

> +			continue;

By doing this skipping here, you actually end up crippling lost_retrans 
detection even more than it was broken before. ...You probably didn't just 
notice that during tests because of unrelated suboptimal behavior (in 
fastpath_skb_hint handling). ...Anyway, correctness of this should be 
evaluated against the fixed lost_retrans, rather than the already 
broken one.

> +
>  		skb = cached_skb;
>  		fack_count = cached_fack_count;

Other than what's noted above:

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.
---696243703-717307352-1191580641=:31129--
