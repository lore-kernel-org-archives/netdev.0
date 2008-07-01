From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 15:49:05 -0700
Message-ID: <20080701154905.5226863f@extreme>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	<396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49015 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299AbYGAWtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:49:06 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008 15:38:14 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

>  static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
>  				   struct in6_addr *saddr,
>  				   struct in6_addr *daddr,
> -				   struct tcphdr *th, int protocol,
> -				   unsigned int tcplen)
> +				   int protocol,
> +				   struct tcphdr *th, int data_off, int tcplen,
> +				   struct skb_shared_info *frags)
>  {
> -	struct scatterlist sg[4];
> -	__u16 data_len;
> +	struct scatterlist sg[MAX_SKB_FRAGS + 3];
> +	const int head_data_len = tcplen - data_off;
>  	int block = 0;
>  	__sum16 cksum;
>  	struct tcp_md5sig_pool *hp;
>  	struct tcp6_pseudohdr *bp;
>  	struct hash_desc *desc;
> -	int err;
> -	unsigned int nbytes = 0;
> +	int err, i;
> +	unsigned int nbytes = tcplen;
>  
>  	hp = tcp_get_md5sig_pool();
>  	if (!hp) {
> @@ -760,10 +761,15 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
>  	/* 1. TCP pseudo-header (RFC2460) */
>  	ipv6_addr_copy(&bp->saddr, saddr);
>  	ipv6_addr_copy(&bp->daddr, daddr);
> -	bp->len = htonl(tcplen);
>  	bp->protocol = htonl(protocol);
> +	if (frags)
> +		for (i = 0; i < frags->nr_frags; ++i)
> +			nbytes += frags->frags[i].size;
> +	bp->len = htonl(nbytes);
> +	nbytes = 0;

Just pass the skb in and not tcplen, frags, ...
avoid all this nonsense.  tcplen == skb->len, and you have the correct size info.

