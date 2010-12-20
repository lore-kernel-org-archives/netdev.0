From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Buglet in net/pkt_cls.h pointer handling.
Date: Mon, 20 Dec 2010 09:54:40 +0000
Message-ID: <20101220095440.GA7977@ff.dom.local>
References: <20101216215627.43f34977.suckfish@ihug.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ralph Loader <suckfish@ihug.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:56686 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab0LTJyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 04:54:44 -0500
Received: by bwz16 with SMTP id 16so3092234bwz.4
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 01:54:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101216215627.43f34977.suckfish@ihug.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-16 09:56, Ralph Loader wrote:
> Hi,
> 
> tcf_valid_offset() in net/pkt_cls.h appears to have a couple of 
> problems (obvious patch below):
> 
> (a) there is no check for overflow in the pointer arithmetic.
> (b) the pointers are presumably likely to be normally valid, so the
>     hint should be 'likely()' not 'unlikely()'.
Hi,

Your 'unlikely()' concern seems likely right. Forcing 'len >= 0' in
your patch is another question. Anyway, I wonder why don't you add
your "Signed-off-by", and Cc people who know these things: the
'TC CLASSIFIER' maintainer (as in MAINTAINERS) and the ematch author?

Cheers,
Jarek P.

> 
> The offsets used to construct the arguments to that function, e.g., as
> called in net/sched/em_u32.c, I think come from user-space & in theory
> could be crafted to cause an invalid pointer deref if ptr+len overflows?
> 
> Possibly the '<' and '>' in that function should be '<=' and '>='
> also.  I'm not familiar enough with the data-structures to be sure.
> 
> Also a question:  in em_u32.c em_u32_match(), and in cls_u32.c
> u32_classify(), we dereference pointers that have had an offset
> (originally from user space) added to them.  I can't see anything that
> keeps those pointers aligned.  Is that a problem on architectures that
> don't support unaligned pointers, or am I missing something?
> 
> Cheers,
> Ralph.
> 
> 
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index dd3031a..99a2d7b 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -323,7 +323,7 @@ static inline unsigned char * tcf_get_base_ptr(struct sk_buff *skb, int layer)
>  static inline int tcf_valid_offset(const struct sk_buff *skb,
>                                    const unsigned char *ptr, const int len)
>  {
> -       return unlikely((ptr + len) < skb_tail_pointer(skb) && ptr > skb->head);
> +       return likely((ptr + len) < skb_tail_pointer(skb) && ptr > skb->head && ptr <= ptr + len);
>  }
>  
>  #ifdef CONFIG_NET_CLS_IND
