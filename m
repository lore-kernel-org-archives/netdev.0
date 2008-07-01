From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 15:46:06 -0700
Message-ID: <20080701154606.4d706e78@extreme>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	<396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48886 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862AbYGAWqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:46:07 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008 15:38:14 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> Cut three,
>   * I should use sg_set_page, not sg_set_buf with page_address
>   * Make the version that tcp_output etc use take an SKB
>   * Replicate fix to IPv6
> 
> Cheers,
> 
> 
> AGL
> 
>  include/net/tcp.h     |    6 +--
>  net/ipv4/tcp_ipv4.c   |  112 +++++++++++++++++++++++++++++++++++++------------
>  net/ipv4/tcp_output.c |   11 ++---
>  net/ipv6/tcp_ipv6.c   |   65 ++++++++++++++++++----------
>  4 files changed, 133 insertions(+), 61 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 633147c..a9130a1 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1120,9 +1120,8 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
>  						     struct sock *sk,
>  						     struct dst_entry *dst,
>  						     struct request_sock *req,
> -						     struct tcphdr *th,
>  						     int protocol,
> -						     unsigned int tcplen);
> +						     struct sk_buff *skb);
>  extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
>  						   struct sock *addr_sk);
>  
> @@ -1370,9 +1369,8 @@ struct tcp_sock_af_ops {
>  						  struct sock *sk,
>  						  struct dst_entry *dst,
>  						  struct request_sock *req,
> -						  struct tcphdr *th,
>  						  int protocol,
> -						  unsigned int len);
> +						  struct sk_buff *skb);
>  	int			(*md5_add) (struct sock *sk,
>  					    struct sock *addr_sk,
>  					    u8 *newkey,
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index cd601a8..90a5f41 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -95,8 +95,9 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
>  						   __be32 addr);
>  static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
>  				   __be32 saddr, __be32 daddr,
> -				   struct tcphdr *th, int protocol,
> -				   unsigned int tcplen);
> +				   int protocol,
> +				   struct tcphdr *th, int data_off, int tcplen,
> +				   struct skb_shared_info *frags);
>  #endif
>  
>  struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
> @@ -586,8 +587,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
>  					key,
>  					ip_hdr(skb)->daddr,
>  					ip_hdr(skb)->saddr,
> -					&rep.th, IPPROTO_TCP,
> -					arg.iov[0].iov_len);
> +					IPPROTO_TCP, &rep.th,
> +					arg.iov[0].iov_len, arg.iov[0].iov_len,
> +					NULL);
>  	}
>  #endif
>  	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
> @@ -680,8 +682,9 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
>  					key,
>  					ip_hdr(skb)->daddr,
>  					ip_hdr(skb)->saddr,
> -					&rep.th, IPPROTO_TCP,
> -					arg.iov[0].iov_len);
> +					IPPROTO_TCP, &rep.th,
> +					arg.iov[0].iov_len, arg.iov[0].iov_len,
> +					NULL);
>  	}
>  #endif
>  	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
> @@ -1004,20 +1007,56 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
>  				 newkey, cmd.tcpm_keylen);
>  }
>  
> +/*
> +static void
> +md5_dump(struct scatterlist *sglist, int nsg, unsigned nbytes, int data_off, int tcplen, char frags) {
> +	struct scatterlist *sg;
> +	unsigned e;
> +
> +	printk(KERN_INFO "MD5: %d %d %d %d %d\n", nsg, nbytes, data_off, tcplen, frags);
> +	for_each_sg(sglist, sg, nsg, e) {
> +		u8 *buf = sg_virt(sg);
> +		unsigned i;
> +
> +		for (i = 0; i < sg->length; ++i)
> +			printk(" %02x", buf[i]);
> +
> +		printk("\n");
> +	}
> +
> +	printk("\n");
> +}*/
> +
> +/**
> + * tcp_v4_do_calc_md5_hash - calculate an MD5 hash (RFC 2385)
> + * @md5_hash: (output) a 16 byte space into which the MD5 sig is written
> + * @key: the key that is appened to the hash input
> + * @saddr: source IP address for the packet
> + * @daddr: destination IP address for the packet
> + * @protocol: the protocol number in the IP header (see the RFC)
> + * @th: the TCP header, followed by options and (optional) data
> + * @data_off: the offset of the optional data (in bytes) from @th
> + * @tcplen: the length of the buffer (in bytes) pointed to by @th. If
> + *   @tcplen == @data_off then there is no data following the header
> + * @frags: (maybe NULL) a list of additional fragments of data
> + *
> + * We don't always have the SKB when this function is called, thus the pointer
> + * to the TCP header and all the length arguments.
> + */
>  static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
> -				   __be32 saddr, __be32 daddr,
> -				   struct tcphdr *th, int protocol,
> -				   unsigned int tcplen)
> +				   __be32 saddr, __be32 daddr, int protocol,
> +				   struct tcphdr *th, int data_off, int tcplen,
> +				   struct skb_shared_info *frags)
>  {
> -	struct scatterlist sg[4];
> -	__u16 data_len;
> +	struct scatterlist sg[MAX_SKB_FRAGS + 3];

Since this can be big, why not allocate with kmalloc()?
