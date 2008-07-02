From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: MD5 SG fix
Date: Wed, 2 Jul 2008 08:55:55 +0400
Message-ID: <20080702045555.GB11252@2ka.mipt.ru>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa> <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49994 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYGBEzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 00:55:51 -0400
Content-Disposition: inline
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jul 01, 2008 at 03:38:14PM -0700, Adam Langley (agl@imperialviolet.org) wrote:
> @@ -1040,9 +1079,14 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
>  	bp->daddr = daddr;
>  	bp->pad = 0;
>  	bp->protocol = protocol;
> -	bp->len = htons(tcplen);
> +	if (frags)
> +		for (i = 0; i < frags->nr_frags; ++i)
> +			nbytes += frags->frags[i].size;
> +	bp->len = htons(nbytes);
> +	nbytes = 0;
>  
> -	sg_init_table(sg, 4);
> +	sg_init_table(sg, 3 + (head_data_len > 0) +
> +		      (frags ? frags->nr_frags : 0));
>  
>  	sg_set_buf(&sg[block++], bp, sizeof(*bp));
>  	nbytes += sizeof(*bp);
> @@ -1056,11 +1100,19 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
>  	nbytes += sizeof(struct tcphdr);
>  
>  	/* 3. the TCP segment data (if any) */
> -	data_len = tcplen - (th->doff << 2);
> -	if (data_len > 0) {
> -		unsigned char *data = (unsigned char *)th + (th->doff << 2);
> -		sg_set_buf(&sg[block++], data, data_len);
> -		nbytes += data_len;
> +	if (head_data_len > 0) {
> +		unsigned char *data = (unsigned char *)th + data_off;
> +		sg_set_buf(&sg[block++], data, head_data_len);
> +		nbytes += head_data_len;
> +	}
> +
> +	if (frags) {
> +		for (i = 0; i < frags->nr_frags; ++i) {
> +			const struct skb_frag_struct *f = &frags->frags[i];
> +			sg_set_page(&sg[block++], f->page, f->size,
> +				    f->page_offset);
> +			nbytes += f->size;
> +		}
>  	}
>  
>  	/* 4. an independently-specified key or password, known to both

Why dont't you want to iterate over all provided data/page pointers with
crypto_hash_update() and do not mess with huge scatterlist arrays?

-- 
	Evgeniy Polyakov
