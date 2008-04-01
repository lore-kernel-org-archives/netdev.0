From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] socket: sk_filter deinline
Date: Mon, 31 Mar 2008 17:47:10 -0700
Message-ID: <20080401004724.528304251@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755373AbYDACbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:37 -0400
Content-Disposition: inline; filename=sk-filter-deinline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_filter function is too big to be inlined. This saves 2296 bytes
of text on allyesconfig.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/filter.h	2008-03-31 10:24:40.000000000 -0700
+++ b/include/linux/filter.h	2008-03-31 10:26:49.000000000 -0700
@@ -142,6 +142,7 @@ static inline unsigned int sk_filter_len
 struct sk_buff;
 struct sock;
 
+extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(struct sk_buff *skb,
 				  struct sock_filter *filter, int flen);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
--- a/include/net/sock.h	2008-03-31 10:23:12.000000000 -0700
+++ b/include/net/sock.h	2008-03-31 10:25:57.000000000 -0700
@@ -927,41 +927,6 @@ extern void sk_common_release(struct soc
 extern void sock_init_data(struct socket *sock, struct sock *sk);
 
 /**
- *	sk_filter - run a packet through a socket filter
- *	@sk: sock associated with &sk_buff
- *	@skb: buffer to filter
- *	@needlock: set to 1 if the sock is not locked by caller.
- *
- * Run the filter code and then cut skb->data to correct size returned by
- * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
- * than pkt_len we keep whole skb->data. This is the socket level
- * wrapper to sk_run_filter. It returns 0 if the packet should
- * be accepted or -EPERM if the packet should be tossed.
- *
- */
-
-static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
-{
-	int err;
-	struct sk_filter *filter;
-	
-	err = security_sock_rcv_skb(sk, skb);
-	if (err)
-		return err;
-	
-	rcu_read_lock_bh();
-	filter = rcu_dereference(sk->sk_filter);
-	if (filter) {
-		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
-				filter->len);
-		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
-	}
- 	rcu_read_unlock_bh();
-
-	return err;
-}
-
-/**
  *	sk_filter_release: Release a socket filter
  *	@sk: socket
  *	@fp: filter to remove
--- a/net/core/filter.c	2008-03-31 10:25:29.000000000 -0700
+++ b/net/core/filter.c	2008-03-31 10:27:43.000000000 -0700
@@ -64,6 +64,41 @@ static inline void *load_pointer(struct 
 }
 
 /**
+ *	sk_filter - run a packet through a socket filter
+ *	@sk: sock associated with &sk_buff
+ *	@skb: buffer to filter
+ *	@needlock: set to 1 if the sock is not locked by caller.
+ *
+ * Run the filter code and then cut skb->data to correct size returned by
+ * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
+ * than pkt_len we keep whole skb->data. This is the socket level
+ * wrapper to sk_run_filter. It returns 0 if the packet should
+ * be accepted or -EPERM if the packet should be tossed.
+ *
+ */
+int sk_filter(struct sock *sk, struct sk_buff *skb)
+{
+	int err;
+	struct sk_filter *filter;
+
+	err = security_sock_rcv_skb(sk, skb);
+	if (err)
+		return err;
+
+	rcu_read_lock_bh();
+	filter = rcu_dereference(sk->sk_filter);
+	if (filter) {
+		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
+				filter->len);
+		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
+	}
+ 	rcu_read_unlock_bh();
+
+	return err;
+}
+EXPORT_SYMBOL(sk_filter);
+
+/**
  *	sk_run_filter - run a filter on a socket
  *	@skb: buffer to run the filter on
  *	@filter: filter to apply

-- 

