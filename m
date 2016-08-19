From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix use after free in
 tcp_xmit_retransmit_queue()
Date: Thu, 18 Aug 2016 23:24:47 -0700 (PDT)
Message-ID: <20160818.232447.1977166448213196018.davem@davemloft.net>
References: <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
        <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
        <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marco.gra@gmail.com, ycheng@google.com,
        ncardwell@google.com, gregkh@linuxfoundation.org,
        ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753022AbcHSGd2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:33:28 -0400
In-Reply-To: <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Aug 2016 05:56:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When tcp_sendmsg() allocates a fresh and empty skb, it puts it at the
> tail of the write queue using tcp_add_write_queue_tail()
> 
> Then it attempts to copy user data into this fresh skb.
> 
> If the copy fails, we undo the work and remove the fresh skb.
> 
> Unfortunately, this undo lacks the change done to tp->highest_sack and
> we can leave a dangling pointer (to a freed skb)
> 
> Later, tcp_xmit_retransmit_queue() can dereference this pointer and
> access freed memory. For regular kernels where memory is not unmapped,
> this might cause SACK bugs because tcp_highest_sack_seq() is buggy,
> returning garbage instead of tp->snd_nxt, but with various debug
> features like CONFIG_DEBUG_PAGEALLOC, this can crash the kernel.
> 
> This bug was found by Marco Grassi thanks to syzkaller.
> 
> Fixes: 6859d49475d4 ("[TCP]: Abstract tp->highest_sack accessing & point to next skb")
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
