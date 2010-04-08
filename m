From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 08 Apr 2010 02:20:35 -0700
Message-ID: <1270718435.19154.44.camel@Joe-Laptop.home>
References: <20100408.012617.98660541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1432 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab0DHJUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 05:20:37 -0400
In-Reply-To: <20100408.012617.98660541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-08 at 01:26 -0700, David Miller wrote:
> Fix this by setting skb->ip_summed in the common non-data packet
> constructor.  It already is setting skb->csum to zero.
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f181b78..00afbb0 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -349,6 +349,7 @@ static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
>   */
>  static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
>  {
> +	skb->ip_summed = CHECKSUM_PARTIAL;
>  	skb->csum = 0;
>  
>  	TCP_SKB_CB(skb)->flags = flags;

There might be trivial value in using the
struct layout order for the sets avoiding
crossing cachelines.

from:

static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
{
	skb->ip_summed = CHECKSUM_PARTIAL;
	skb->csum = 0;

	TCP_SKB_CB(skb)->flags = flags;
	TCP_SKB_CB(skb)->sacked = 0;

	skb_shinfo(skb)->gso_segs = 1;
	skb_shinfo(skb)->gso_size = 0;
	skb_shinfo(skb)->gso_type = 0;

	TCP_SKB_CB(skb)->seq = seq;
	if (flags & (TCPCB_FLAG_SYN | TCPCB_FLAG_FIN))
		seq++;
	TCP_SKB_CB(skb)->end_seq = seq;
}

to:

static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
{
	skb->ip_summed = CHECKSUM_PARTIAL; 
	skb->csum = 0;

	TCP_SKB_CB(skb)->seq = seq;
	if (flags & (TCPCB_FLAG_SYN | TCPCB_FLAG_FIN))
		seq++;
	TCP_SKB_CB(skb)->end_seq = seq;
	TCP_SKB_CB(skb)->sacked = 0;
	TCP_SKB_CB(skb)->flags = flags;

	skb_shinfo(skb)->gso_size = 0;
	skb_shinfo(skb)->gso_segs = 1;
	skb_shinfo(skb)->gso_type = 0;
}


