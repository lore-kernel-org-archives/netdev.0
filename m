From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 07/13] sock: add ee_code SO_EE_CODE_ZEROCOPY_COPIED
Date: Wed, 21 Jun 2017 16:36:46 -0400
Message-ID: <20170621203652.15306-8-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

A send request with MSG_ZEROCOPY falls back to copying when a request
cannot be completed in zerocopy mode.

Notify processes when the call reverted to copying through a new bit
in the completion notification, so that they can optionally decline
passing the flag on subsequent calls on the same path.

Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/linux/skbuff.h        | 2 ++
 include/uapi/linux/errqueue.h | 2 ++
 net/core/skbuff.c             | 5 ++++-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1d842860f074..24479da9905c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -416,6 +416,7 @@ struct ubuf_info {
 		struct {
 			u32 id;
 			u16 len;
+			u16 zerocopy:1;
 			u32 bytelen;
 		};
 	};
@@ -1257,6 +1258,7 @@ static inline void skb_zcopy_clear(struct sk_buff *skb, bool zerocopy)
 	struct ubuf_info *uarg = skb_zcopy(skb);
 
 	if (uarg) {
+		uarg->zerocopy = uarg->zerocopy && zerocopy;
 		sock_zerocopy_put(uarg);
 		skb_shinfo(skb)->tx_flags &= ~SKBTX_ZEROCOPY_FRAG;
 	}
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 0f15a77c9e39..78fdf52d6b2f 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -23,6 +23,8 @@ struct sock_extended_err {
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
+#define SO_EE_CODE_ZEROCOPY_COPIED	1
+
 /**
  *	struct scm_timestamping - timestamps exposed through cmsg
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 41fedc4e651f..35a7a7b1192f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -943,6 +943,7 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg->callback = sock_zerocopy_callback;
 	uarg->id = ((u32)atomic_inc_return(&sk->sk_zckey)) - 1;
 	uarg->len = 1;
+	uarg->zerocopy = 1;
 	uarg->bytelen = size;
 	atomic_set(&uarg->refcnt, 0);
 	sock_hold(sk);
@@ -1039,6 +1040,8 @@ void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
 	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
 	serr->ee.ee_data = hi;
 	serr->ee.ee_info = lo;
+	if (!success)
+		serr->ee.ee_code |= SO_EE_CODE_ZEROCOPY_COPIED;
 
 	spin_lock_irqsave(&q->lock, flags);
 	tail = skb_peek_tail(q);
@@ -1061,7 +1064,7 @@ void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
 		if (uarg->callback)
-			uarg->callback(uarg, true);
+			uarg->callback(uarg, uarg->zerocopy);
 		else
 			consume_skb(skb_from_uarg(uarg));
 	}
-- 
2.13.1.611.g7e3b11ae1-goog
