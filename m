From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 1 Aug 2013 07:48:44 +0200
Message-ID: <20130801054844.GC3688@order.stressinduktion.org>
References: <20130724232852.GA29572@ws> <20130725061731.GA12365@order.stressinduktion.org> <20130725103048.GB29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Werner Almesberger <werner@almesberger.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:52721 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3HAFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 01:48:45 -0400
Content-Disposition: inline
In-Reply-To: <20130725103048.GB29572@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Werner!

On Thu, Jul 25, 2013 at 07:30:49AM -0300, Werner Almesberger wrote:
> Hannes Frederic Sowa wrote:
> > Hmm, maybe we should update the icmp header to something like
> 
> That would be quite clean. Is it okay to introduce new names
> like that in a uapi/ header (uapi/linux/icmpv6.h) ?
> 
> > Hmm, there is a bug in this function, _hdr must not be a pointer.
> 
> Oh, I didn't even notice that. Very good catch !
> 
> So on 32 bit system, it would actually work even with "short"
> ICMPv6 messages. Two wrongs sometimes do make a right :-)
> 
> I've attached a revised patch that, according to quick testing,
> still works and doesn't break anything else.
> 
> Thanks,
> - Werner
> 
> ---------------------------------- cut here -----------------------------------
> 
> diff --git a/include/uapi/linux/icmpv6.h b/include/uapi/linux/icmpv6.h
> index e0133c7..11eb5ff 100644
> --- a/include/uapi/linux/icmpv6.h
> +++ b/include/uapi/linux/icmpv6.h
> @@ -5,11 +5,15 @@
>  #include <asm/byteorder.h>
>  
>  struct icmp6hdr {
> -
> -	__u8		icmp6_type;
> -	__u8		icmp6_code;
> -	__sum16		icmp6_cksum;
> -
> +	struct icmp6hdr_head {
> +		__u8		type;
> +		__u8		code;
> +		__sum16		cksum;
> +	} icmpv6_head;
> +
> +#define	icmp6_type	icmpv6_head.type
> +#define	icmp6_code	icmpv6_head.code
> +#define	icmp6_cksum	icmpv6_head.cksum
>  
>  	union {
>  		__be32			un_data32[1];
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index c45f7a5..99ab06f 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -108,14 +108,14 @@ found:
>   */
>  static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
>  {
> -	struct icmp6hdr *_hdr;
> -	const struct icmp6hdr *hdr;
> +	struct icmp6hdr_head _head;
> +	const struct icmp6hdr_head *head;
>  
> -	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
> -				 sizeof(_hdr), &_hdr);
> -	if (hdr) {
> +	head = skb_header_pointer(skb, skb_transport_offset(skb),
> +				  sizeof(_head), &_head);
> +	if (head) {
>  		const __u32 *data = &raw6_sk(sk)->filter.data[0];
> -		unsigned int type = hdr->icmp6_type;
> +		unsigned int type = head->type;
>  
>  		return (data[type >> 5] & (1U << (type & 31))) != 0;
>  	}

I would go ahead and post this as an offical patch submission now and let
David Miller have a look.

Thanks,

  Hannes
