From: "David S. Miller" <davem@redhat.com>
Subject: Re: possible bug in tcp_input.c
Date: Fri, 24 Oct 2003 19:30:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024193034.30f1caed.davem@redhat.com>
References: <20031024162959.GB11154@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, grof@dragon.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20031024162959.GB11154@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Oct 2003 18:29:59 +0200
Tomas Szepe <szepe@pinerecords.com> wrote:

> /* tcp_input.c, line 1138 */
> static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
> {
>   return tp->packets_out && tcp_skb_timedout(tp, skb_peek(&sk->write_queue));
> }
> 
> The passed NULL (and yes, this is where we are getting one) is dereferenced
> immediately in:
> 
> /* tcp_input.c, line 1133 */
> static inline int tcp_skb_timedout(struct tcp_opt *tp, struct sk_buff *skb)
> {
>   return (tcp_time_stamp - TCP_SKB_CB(skb)->when > tp->rto);
> }

If tp->packets_out is non-zero (which by definition it is
in your case else the right hand side of the "&&" would not be
evaluated) then we _MUST_ have some packets in sk->write_queue.

Something is being fiercely corrupted.  Probably some piece of
netfilter is freeing up an SKB one too many times thus corrupting
the TCP write queue list pointers.
