From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Thu, 3 Jul 2008 21:05:30 -0700
Message-ID: <20080703210530.544af173@extreme>
References: <396556a20805301217k293e5718h6bbf02bfe069000@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41904 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbYGDEFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 00:05:38 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069000@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Jul 2008 17:19:41 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> Currently, the MD5 code assumes that the SKBs are linear and, in the case
> that they aren't, happily goes off and hashes off the end of the SKB and
> into random memory.
> 
> Reported by Stephen Hemminger in [1]. Advice thanks to Stephen and Evgeniy
> Polyakov. Also includes a couple of missed route_caps from Stephen's patch
> in [2].
> 
> [1] http://marc.info/?l=linux-netdev&m=121445989106145&w=2
> [2] http://marc.info/?l=linux-netdev&m=121459157816964&w=2
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>
> ---
> 
>  include/net/tcp.h     |   20 ++---
>  net/ipv4/tcp.c        |   57 ++++++++++++++++
>  net/ipv4/tcp_ipv4.c   |  180 ++++++++++++++++++++++---------------------------
>  net/ipv4/tcp_output.c |   17 ++---
>  net/ipv6/tcp_ipv6.c   |  168 ++++++++++++++++++++++------------------------
>  5 files changed, 237 insertions(+), 205 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index cf54034..baca49e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1113,14 +1113,9 @@ struct tcp_md5sig_pool {
>  #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
>  
>  /* - functions */
> -extern int			tcp_v4_calc_md5_hash(char *md5_hash,
> -						     struct tcp_md5sig_key *key,
> -						     struct sock *sk,
> -						     struct dst_entry *dst,
> -						     struct request_sock *req,
> -						     struct tcphdr *th,
> -						     int protocol,
> -						     unsigned int tcplen);
> +int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
> +			struct sock *sk, struct request_sock *req,
> +			int protocol, struct sk_buff *skb);
>  extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
>  						   struct sock *addr_sk);
>  
> @@ -1137,6 +1132,11 @@ extern void			tcp_free_md5sig_pool(void);
>  
>  extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
>  extern void			__tcp_put_md5sig_pool(void);
> +extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
> +extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
> +				 unsigned header_len);
> +extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
> +			    struct tcp_md5sig_key *key);
>  
>  static inline
>  struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
> @@ -1366,11 +1366,9 @@ struct tcp_sock_af_ops {
>  	int			(*calc_md5_hash) (char *location,
>  						  struct tcp_md5sig_key *md5,
>  						  struct sock *sk,
> -						  struct dst_entry *dst,
>  						  struct request_sock *req,
> -						  struct tcphdr *th,
>  						  int protocol,
> -						  unsigned int len);
> +						  struct sk_buff *skb);
>  	int			(*md5_add) (struct sock *sk,
>  					    struct sock *addr_sk,
>  					    u8 *newkey,
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1d723de..33b3860 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2590,6 +2590,63 @@ void __tcp_put_md5sig_pool(void)
>  }
>  
>  EXPORT_SYMBOL(__tcp_put_md5sig_pool);
> +
> +int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
> +			struct tcphdr *th)
> +{
> +	struct scatterlist sg;
> +	int err;
> +
> +	__sum16 old_checksum = th->check;
> +	th->check = 0;
> +	sg_init_table(&sg, 1);
> +	/* options aren't included in the hash */
> +	sg_set_buf(&sg, th, sizeof(struct tcphdr));
> +	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(struct tcphdr));
> +	th->check = old_checksum;
> +	return err;
> +}
> +
> +int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
> +			  struct sk_buff *skb, unsigned header_len)
> +{
> +	struct scatterlist sg;
> +	const struct tcphdr *tp = tcp_hdr(skb);
> +	struct hash_desc *desc = &hp->md5_desc;
> +
> +	sg_init_table(&sg, 1);
> +
> +	if (skb_headlen(skb) > header_len) {
> +		const unsigned head_data_len = skb_headlen(skb) - header_len;
> +		sg_set_buf(&sg, ((u8 *) tp) + header_len, head_data_len);
> +		if (crypto_hash_update(desc, &sg, head_data_len))
> +			return 1;
> +	}
> +
> +	if (skb_is_nonlinear(skb)) {
> +		const struct skb_shared_info *shi = skb_shinfo(skb);
> +		unsigned i;
> +
> +		for (i = 0; i < shi->nr_frags; ++i) {
> +			const struct skb_frag_struct *f = &shi->frags[i];
> +			sg_set_page(&sg, f->page, f->size, f->page_offset);
> +			if (crypto_hash_update(desc, &sg, f->size))
> +				return 1;
> +		}
> +	}
> +
> +	return 0;
> +}
>
Minor nit. I would code both of these as possibly empty loops.
     crypto_hash_update(x,&p, 0) should be a nop
and also no need to test for nonlinear, just let the for() loop
go for zero times.
