From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 11:07:42 -0800
Message-ID: <1485198462.16328.208.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Xiangning Yu <yuxiangning@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36680 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751310AbdAWTHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:07:44 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so10498195pfo.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:07:44 -0800 (PST)
In-Reply-To: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 10:46 -0800, Xiangning Yu wrote:
> Hi netdev folks,
> 
> It looks like we call dev_forward_skb() in veth_xmit(), which calls
> netif_rx() eventually.
> 
> While netif_rx() will enqueue the skb to the CPU RX backlog before the
> actual processing takes place. So, this actually means a TX skb has to
> wait some un-related RX skbs to finish. And this will happen twice for
> a single ping, because the veth device always works as a pair?
> 
> IMHO this might lead to some latency issue under certain workload,
> can we change the call to dev_forward_skb() to something like this?
> 
>         if (likely(__dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
>                 local_bh_disable();
>                 netif_receive_skb(skb);
>                 local_bh_enable();
> 
> Could you please shed some light on this change? And please feel free
> to correct my if my understanding is wrong.

How veth would have different latency requirement than loopback device ?

Calling netif_receive_skb() is considered too dangerous here (or from
any ndo_start_xmit()) because of possible kernel stack exhaustion.
