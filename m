From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: update skb->skb_mstamp more carefully
Date: Fri, 15 Sep 2017 16:16:51 -0700
Message-ID: <1505517411.29839.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
         <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170915.143706.992734259378949259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, edumazet@google.com, ycheng@google.com,
        hkchu@google.com, netdev@vger.kernel.org, weiyongjun1@huawei.com,
        wangkefeng.wang@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:45819 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdIOXQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 19:16:54 -0400
Received: by mail-pg0-f47.google.com with SMTP id 188so2304540pgb.2
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 16:16:54 -0700 (PDT)
In-Reply-To: <20170915.143706.992734259378949259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-15 at 14:37 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 13 Sep 2017 20:30:39 -0700
> 
> > From: Eric Dumazet <edumazet@googl.com>
> > 
> > liujian reported a problem in TCP_USER_TIMEOUT processing with a patch
> > in tcp_probe_timer() :
> >       https://www.spinics.net/lists/netdev/msg454496.html
> > 
> > After investigations, the root cause of the problem is that we update
> > skb->skb_mstamp of skbs in write queue, even if the attempt to send a
> > clone or copy of it failed. One reason being a routing problem.
> > 
> > This patch prevents this, solving liujian issue.
> > 
> > It also removes a potential RTT miscalculation, since
> > __tcp_retransmit_skb() is not OR-ing TCP_SKB_CB(skb)->sacked with
> > TCPCB_EVER_RETRANS if a failure happens, but skb->skb_mstamp has
> > been changed.
> > 
> > A future ACK would then lead to a very small RTT sample and min_rtt
> > would then be lowered to this too small value.
> > 
> > Tested:
> ...
> > Signed-off-by: Eric Dumazet <edumazet@googl.com>
> > Reported-by: liujian <liujian56@huawei.com>
> 
> Applied and queued up for -stable, thanks.

Thanks David.

It seems I forgot to move the call to tcp_rate_skb_sent(sk, skb),
as this function depended on skb->skb_mstamp being up to date.

I will send a fix, sorry for not catching this earlier.
