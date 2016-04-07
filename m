From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: optimizations to sk_buff handling in rds_tcp_data_ready
Date: Thu, 07 Apr 2016 07:16:00 -0700
Message-ID: <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160407130859.GA2818@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tom@herbertland.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33390 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbcDGOQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:16:06 -0400
Received: by mail-pa0-f42.google.com with SMTP id zm5so55816346pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 07:16:05 -0700 (PDT)
In-Reply-To: <20160407130859.GA2818@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 09:11 -0400, Sowmini Varadhan wrote:
> I was going back to Alexei's comment here:
>   http://permalink.gmane.org/gmane.linux.network/387806
> In rds-stress profiling,  we are indeed seeing the pksb_pull 
> (from rds_tcp_data_recv) show up in the perf profile.
> 
> At least for rds-tcp, we cannot re-use the skb even if
> it is not shared, because what we need to do is to carve out
> the interesting bits (start at offset, and trim it to to_copy)
> and queue up those interesting bits on the PF_RDS socket,
> while allowing tcp_data_read to go back and read the next 
> tcp segment (which may be part of the next rds dgram).
> 
> But, when  pskb_expand_head is invoked in the call-stack
>   pskb_pull(.., offset) -> ... -> __pskb_pull_tail(.., delta) 
> it will memcpy the offset bytes to the start of data. At least 
> for the rds_tcp_data_recv, we are not interested in being able 
> to do a *skb_push after the *skb_pull, so we dont really care 
> about the intactness of these bytes in offset.
> Thus what I am finding is that when delta > 0, if we skip the 
> following in pskb_expand_head (for the rds-tcp recv case only!)
> 
>         /* Copy only real data... and, alas, header. This should be
>          * optimized for the cases when header is void.
>          */
>         memcpy(data + nhead, skb->head, skb_tail_pointer(skb) - skb->head);
> 
> and also (only for this case!) this one in __pskb_pull_tail
> 
>  if (skb_copy_bits(skb, skb_headlen(skb), skb_tail_pointer(skb), delta))
>                 BUG();
> 
> I am able to get a 40% improvement in the measured IOPS (req/response 
> transactions per second, using 8K byte requests, 256 byte responses,
> 16 concurrent threads), so this optimization seems worth doing.
> 
> Does my analysis above make sense? If yes, the question is, how to
> achieve this bypass in a neat way.  Clearly there are many callers of
> pskb_expand_head who will expect to find the skb_header_len bytes at
> the start of data, but we also dont want to duplicate code in these
> functions. One thought I had is to pass a flag arouund saying "caller
> doesnt care about retaining offset bytes", and use this flag
> - in __pskb_pull_tail, to avoid skb_copy_bits() above,  and to
>   pass delta to pskb_expand_head,
> - in pskb_expand_head, only do the memcpy listed above 
>   if delta <= 0
> Any other ideas for how to achieve this?

Use skb split like TCP in output path ?

Really, pskb_expand_head() is not supposed to copy payload ;)
