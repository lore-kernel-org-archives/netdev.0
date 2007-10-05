From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Fri, 5 Oct 2007 13:02:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
References: <20071004.184519.16476818.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52634 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbXJEKCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 06:02:14 -0400
In-Reply-To: <20071004.184519.16476818.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Oct 2007, TAKANO Ryousei wrote:

> This patch allows to detect loss of retransmitted packets more
> accurately by using the highest end sequence number among SACK 
> blocks.  Before the retransmission queue is scanned, the highest
> end sequence number (high_end_seq) is retrieved, and this value
> is compared with the ack_seq of each packet.
> 
> Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
> Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
> ---
>  net/ipv4/tcp_input.c |   14 +++++++++++---
>  1 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index bbad2cd..12db4b3 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	int cached_fack_count;
>  	int i;
>  	int first_sack_index;
> +	__u32 high_end_seq;

No __-types when not visible to userspace please.

>
>  	if (!tp->sacked_out)
>  		tp->fackets_out = 0;
> @@ -1012,6 +1013,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
>  		return 0;
>  
> +	/* Retrieve the highest end_seq among SACK blocks. */
> +	high_end_seq = ntohl(sp[0].end_seq);
> +	for (i = 1; i < num_sacks; i++) {
> +		__u32 end_seq = ntohl(sp[i].end_seq);
> +		if (after(end_seq, high_end_seq))
> +			high_end_seq = end_seq;
> +	}
> +

There's one problem... Net-2.6.24 tree includes SACK block validator 
which is being done in the marking loop. The SACK blocks would not yet be 
validated in that position, yet this code should be protected by the 
validation! My intention is to move the validator earlier anyway (yet to 
be split into smaller logical patches), see:

http://marc.info/?l=linux-netdev&m=119062989408053&w=2

>  	/* SACK fastpath:
>  	 * if the only SACK change is the increase of the end_seq of
>  	 * the first block then only apply that SACK block
> @@ -1161,9 +1170,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  			}
>  
>  			if ((sacked&TCPCB_SACKED_RETRANS) &&
> -			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
> -			    (!lost_retrans || after(end_seq, lost_retrans)))
> -				lost_retrans = end_seq;
> +			    after(high_end_seq, TCP_SKB_CB(skb)->ack_seq))
> +				lost_retrans = high_end_seq;

Just couple of thoughts, not that this change itself is incorrect...

In case sacktag uses fastpath, this code won't be executed for the skb's 
that we would like to check (those with SACKED_RETRANS set, that are 
below the fastpath_skb_hint). We will eventually deal with the whole queue 
when fastpath_skb_hint gets set to NULL, with the next cumulative ACK that 
fully ACKs an skb at the latest. Maybe there's a need for a larger surgery 
than this to fix it. I think we need additional field to tcp_sock to avoid 
doing a full-walk per ACK:

Keep minimum of TCP_SKB_CB(skb)->ack_seq of rexmitted segments in 
tcp_sock, when that's exceeded by SACK block, do a full-walk in the 
lost_retrans worker loop like the old code does...


In future, please base your work to current development tree instead of 
linus' tree (net-2.6.24 at this point of time, there's also tcp-2.6 but 
it's currently a bit outdated).


-- 
 i.
