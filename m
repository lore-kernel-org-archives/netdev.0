From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
Date: Mon, 31 Oct 2016 08:16:46 -0700
Message-ID: <1477927006.7065.304.camel@edumazet-glaptop3.roam.corp.google.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477729045.5306.11.camel@redhat.com>
         <1477745013.7065.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477926132.6655.10.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477926132.6655.10.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-31 at 16:02 +0100, Paolo Abeni wrote:

> 
> No problem at all with incremental patches ;-)
> 
> In our experiment, touching udp_memory_allocated is only a part of the
> the source of contention, with the biggest source of contention being
> the sk_rmem_alloc update - which happens on every dequeue.
> 
> We experimented doing fwd alloc of the whole sk_rcvbuf; even in that
> scenario we hit relevant contention if sk_rmem_alloc update was done
> under the lock, while full sk_rcvbuf forward allocation and
> sk_rmem_alloc update outside the spinlock gave very similar performance
> to our posted patch.


> I think that the next step (after the double lock on dequeue removal)
> should be moving sk_rmem_alloc outside the lock: the needed changes for
> doing that on top of double lock on dequeue removal are very small
> (would add ~10 lines of code).
> 

During my load tests, one of the major factor was sk_drops being
incremented like crazy, dirtying a critical cache line, hurting
sk_filter reads for example.

        /* --- cacheline 6 boundary (384 bytes) --- */
        struct {
                atomic_t           rmem_alloc;           /* 0x180   0x4 */
                int                len;                  /* 0x184   0x4 */
                struct sk_buff *   head;                 /* 0x188   0x8 */
                struct sk_buff *   tail;                 /* 0x190   0x8 */
        } sk_backlog;                                    /* 0x180  0x18 */
        int                        sk_forward_alloc;     /* 0x198   0x4 */
        __u32                      sk_txhash;            /* 0x19c   0x4 */
        unsigned int               sk_napi_id;           /* 0x1a0   0x4 */
        unsigned int               sk_ll_usec;           /* 0x1a4   0x4 */
        atomic_t                   sk_drops;             /* 0x1a8   0x4 */
        int                        sk_rcvbuf;            /* 0x1ac   0x4 */
        struct sk_filter *         sk_filter;            /* 0x1b0   0x8 */
        union {
                struct socket_wq * sk_wq;                /*         0x8 */
                struct socket_wq * sk_wq_raw;            /*         0x8 */
        };                                               /* 0x1b8   0x8 */

I was playing moving this field elsewhere and not reading it if not
necessary.

diff --git a/include/net/sock.h b/include/net/sock.h
index f13ac87a8015cb18c5d3fe5fdcf2d6a0592428f4..a901df591eb45e153517cdb8b409b61563d1a4e3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2112,7 +2112,8 @@ struct sock_skb_cb {
 static inline void
 sock_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
 {
-	SOCK_SKB_CB(skb)->dropcount = atomic_read(&sk->sk_drops);
+	SOCK_SKB_CB(skb)->dropcount = sock_flag(sk, SOCK_RXQ_OVFL) ?
+					atomic_read(&sk->sk_drops) : 0;
 }
 
 static inline void sk_drops_add(struct sock *sk, const struct sk_buff *skb)



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
