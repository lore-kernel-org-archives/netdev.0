From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 17:33:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
References: <20070329230917.63c3f79c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33450 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbXC3Odc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 10:33:32 -0400
In-Reply-To: <20070329230917.63c3f79c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2007, Andrew Morton wrote:

> Full -mm lineup.  The x86_64 box was acting as a distcc server at the time.
> 
> Nothing hit the logs, I'm afraid. But almost all the info is in 
> http://userweb.kernel.org/~akpm/s5000494.jpg
>
> <pokes around in gdb a bit>
> 
> It died in tcp_update_scoreboard_fack() here:
> 
>                 if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
>                     after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
>                         /* RFC: should we have find_below? */
>                         skb = tcp_write_queue_find(sk, tp->high_seq);
>                         not_marked_skb = skb;
>                         skb = tcp_write_queue_prev(sk, skb);
>                         /* Timedout top is again uncertain? */
>                         if (tcp_skb_timedout(sk, skb))
>                                 timedout_continue = 1;
>                 }
> 
> 
> (gdb) l *0xffffffff8048ded8
> 0xffffffff8048ded8 is in tcp_update_scoreboard_fack (include/net/tcp.h:1197).
> 1192            return skb->next;
> 1193    }
> 1194    
> 1195    static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
> 1196    {
> 1197            return skb->prev;
> 1198    }
> 1199    
> 1200    #define tcp_for_write_queue(skb, sk)                                   \
> 
> (gdb) x/10i 0xffffffff8048ded8
> 0xffffffff8048ded8 <tcp_update_scoreboard_fack+528>:    mov    0x8(%rdx),%r12
> 
> So if that "CR2: 0000000000000008" is the access address then it appears that
> `skb' is NULL.  tcp_write_queue_find() didn't find nuthin.

If there is nothing at high_seq (application hasn't given any data to/past 
that point), the search fails to find any skb and returns NULL... But I 
have no idea how this can happen? As TCP does after(skb->seq, 
tp->high_seq) (even in the quoted code block) guaranteeing that something 
is there after the high_seq for TCP to step temporarily on... So at least 
one skb should have it's end_seq after tp->high_seq (actually there 
should be at least two valid skbs after tp->high_seq since the used 
sequence number space does not have holes), which should be enough to get 
an existing skb from write_queue_find?!

I also checked all call paths to tcp_update_scoreboard_fack to make sure 
that snd_una hasn't gone past high_seq and found nothing suspicious (and 
that wouldn't return NULL anyway I think)...


-- 
 i.
