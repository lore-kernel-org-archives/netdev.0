From: Andrew Morton <akpm@linux-foundation.org>
Subject: tcp crash in net-2.6 tree
Date: Thu, 29 Mar 2007 23:09:17 -0700
Message-ID: <20070329230917.63c3f79c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53024 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbXC3GJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 02:09:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Full -mm lineup.  The x86_64 box was acting as a distcc server at the time.

Nothing hit the logs, I'm afraid.  But almost all the info is in
http://userweb.kernel.org/~akpm/s5000494.jpg


<pokes around in gdb a bit>

It died in tcp_update_scoreboard_fack() here:

                if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
                    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
                        /* RFC: should we have find_below? */
                        skb = tcp_write_queue_find(sk, tp->high_seq);
                        not_marked_skb = skb;
                        skb = tcp_write_queue_prev(sk, skb);
                        /* Timedout top is again uncertain? */
                        if (tcp_skb_timedout(sk, skb))
                                timedout_continue = 1;
                }


(gdb) l *0xffffffff8048ded8
0xffffffff8048ded8 is in tcp_update_scoreboard_fack (include/net/tcp.h:1197).
1192            return skb->next;
1193    }
1194    
1195    static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
1196    {
1197            return skb->prev;
1198    }
1199    
1200    #define tcp_for_write_queue(skb, sk)                                   \

(gdb) x/10i 0xffffffff8048ded8
0xffffffff8048ded8 <tcp_update_scoreboard_fack+528>:    mov    0x8(%rdx),%r12

So if that "CR2: 0000000000000008" is the access address then it appears that
`skb' is NULL.  tcp_write_queue_find() didn't find nuthin.
