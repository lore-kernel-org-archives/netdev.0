From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] tcp: avoid order-1 allocations on wifi and tx path
Date: Wed, 11 Apr 2012 08:30:48 +0200
Message-ID: <1334125848.5300.2330.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org>
	 <1334122980.5300.2154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334122980.5300.2154.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marc Merlin reported many order-1 allocations failures in TX path on its
wireless setup, that dont make any sense with MTU=1500 network, and non
SG capable hardware.

After investigation, it turns out TCP uses sk_stream_alloc_skb() and
used as a convention skb_tailroom(skb) to know how many bytes of data
payload could be put in this skb (for non SG capable devices)

Note : these skb used kmalloc-4096 (MTU=1500 + MAX_HEADER +
sizeof(struct skb_shared_info) being above 2048)

Later, mac80211 layer need to add some bytes at the tail of skb
(IEEE80211_ENCRYPT_TAILROOM = 18 bytes) and since no more tailroom is
available has to call pskb_expand_head() and request order-1
allocations.

This patch changes sk_stream_alloc_skb() so that only
sk->sk_prot->max_header bytes of headroom are reserved, and use a new
skb field, avail_size to hold the data payload limit.

This way, order-0 allocations done by TCP stack can leave more than 2 KB
of tailroom and no more allocation is performed in mac80211 layer (or
any layer needing some tailroom)

avail_size is unioned with mark/dropcount, since mark will be set later
in IP stack for output packets. Therefore, skb size is unchanged.

Reported-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Tested-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/skbuff.h |   13 +++++++++++++
 net/ipv4/tcp.c         |    8 ++++----
 net/ipv4/tcp_output.c  |    2 +-
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3337027..70a3f8d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -481,6 +481,7 @@ struct sk_buff {
 	union {
 		__u32		mark;
 		__u32		dropcount;
+		__u32		avail_size;
 	};
 
 	sk_buff_data_t		transport_header;
@@ -1366,6 +1367,18 @@ static inline int skb_tailroom(const struct sk_buff *skb)
 }
 
 /**
+ *	skb_availroom - bytes at buffer end
+ *	@skb: buffer to check
+ *
+ *	Return the number of bytes of free space at the tail of an sk_buff
+ *	allocated by sk_stream_alloc()
+ */
+static inline int skb_availroom(const struct sk_buff *skb)
+{
+	return skb_is_nonlinear(skb) ? 0 : skb->avail_size - skb->len;
+}
+
+/**
  *	skb_reserve - adjust headroom
  *	@skb: buffer to alter
  *	@len: bytes to move
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5d54ed3..87f497f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -701,11 +701,12 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
+			skb_reserve(skb, sk->sk_prot->max_header);
 			/*
 			 * Make sure that we have exactly size bytes
 			 * available to the caller, no more, no less.
 			 */
-			skb_reserve(skb, skb_tailroom(skb) - size);
+			skb->avail_size = size;		
 			return skb;
 		}
 		__kfree_skb(skb);
@@ -995,10 +996,9 @@ new_segment:
 				copy = seglen;
 
 			/* Where to copy to? */
-			if (skb_tailroom(skb) > 0) {
+			if (skb_availroom(skb) > 0) {
 				/* We have some space in skb head. Superb! */
-				if (copy > skb_tailroom(skb))
-					copy = skb_tailroom(skb);
+				copy = min_t(int, copy, skb_availroom(skb));
 				err = skb_add_data_nocache(sk, skb, from, copy);
 				if (err)
 					goto do_fault;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 364784a..376b2cf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2060,7 +2060,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		/* Punt if not enough space exists in the first SKB for
 		 * the data in the second
 		 */
-		if (skb->len > skb_tailroom(to))
+		if (skb->len > skb_availroom(to))
 			break;
 
 		if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
