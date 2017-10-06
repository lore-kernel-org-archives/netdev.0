From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv6: Convert icmpv6_push_pending_frames to void
Date: Thu,  5 Oct 2017 23:46:14 -0700
Message-ID: <14612f639009193e561bcdb11c5ef5b6f12830ed.1507272313.git.joe@perches.com>
Cc: Tim Hansen <devtimhansen@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit cc71b7b07119 ("net/ipv6: remove unused err variable on
icmpv6_push_pending_frames") exposed icmpv6_push_pending_frames
return value not being used.

Remove now unnecessary int err declarations and uses.

Miscellanea:

o Remove unnecessary goto and out: labels
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/ipv6.h |  4 ++--
 net/ipv6/icmp.c    | 43 ++++++++++++++++++-------------------------
 net/ipv6/ping.c    |  5 ++---
 3 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6eac5cf8f1e6..3cda3b521c36 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -300,8 +300,8 @@ static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 
 void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info);
 
-int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
-			       struct icmp6hdr *thdr, int len);
+void icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
+				struct icmp6hdr *thdr, int len);
 
 int ip6_ra_control(struct sock *sk, int sel);
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index aeb49b4d8c7d..4e52d52a6752 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -250,15 +250,15 @@ static bool opt_unrec(struct sk_buff *skb, __u32 offset)
 	return (*op & 0xC0) == 0x80;
 }
 
-int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
-			       struct icmp6hdr *thdr, int len)
+void icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
+				struct icmp6hdr *thdr, int len)
 {
 	struct sk_buff *skb;
 	struct icmp6hdr *icmp6h;
 
 	skb = skb_peek(&sk->sk_write_queue);
 	if (!skb)
-		goto out;
+		return;
 
 	icmp6h = icmp6_hdr(skb);
 	memcpy(icmp6h, thdr, sizeof(struct icmp6hdr));
@@ -286,8 +286,6 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 						      tmp_csum);
 	}
 	ip6_push_pending_frames(sk);
-out:
-	return 0;
 }
 
 struct icmpv6_msg {
@@ -437,7 +435,6 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	int iif = 0;
 	int addr_type = 0;
 	int len;
-	int err = 0;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 
 	if ((u8 *)hdr < skb->head ||
@@ -574,17 +571,16 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	rcu_read_lock();
 	idev = __in6_dev_get(skb->dev);
 
-	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
-			      len + sizeof(struct icmp6hdr),
-			      sizeof(struct icmp6hdr),
-			      &ipc6, &fl6, (struct rt6_info *)dst,
-			      MSG_DONTWAIT, &sockc_unused);
-	if (err) {
+	if (ip6_append_data(sk, icmpv6_getfrag, &msg,
+			    len + sizeof(struct icmp6hdr),
+			    sizeof(struct icmp6hdr),
+			    &ipc6, &fl6, (struct rt6_info *)dst,
+			    MSG_DONTWAIT, &sockc_unused)) {
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
-		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
-						 len + sizeof(struct icmp6hdr));
+		icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
+					   len + sizeof(struct icmp6hdr));
 	}
 	rcu_read_unlock();
 out_dst_release:
@@ -681,7 +677,6 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct icmpv6_msg msg;
 	struct dst_entry *dst;
 	struct ipcm6_cookie ipc6;
-	int err = 0;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 	struct sockcm_cookie sockc_unused = {0};
 
@@ -718,8 +713,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
-	err = ip6_dst_lookup(net, sk, &dst, &fl6);
-	if (err)
+	if (ip6_dst_lookup(net, sk, &dst, &fl6))
 		goto out;
 	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), sk, 0);
 	if (IS_ERR(dst))
@@ -736,17 +730,16 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	ipc6.dontfrag = np->dontfrag;
 	ipc6.opt = NULL;
 
-	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), &ipc6, &fl6,
-				(struct rt6_info *)dst, MSG_DONTWAIT,
-				&sockc_unused);
-
-	if (err) {
+	if (ip6_append_data(sk, icmpv6_getfrag, &msg,
+			    skb->len + sizeof(struct icmp6hdr),
+			    sizeof(struct icmp6hdr), &ipc6, &fl6,
+			    (struct rt6_info *)dst, MSG_DONTWAIT,
+			    &sockc_unused)) {
 		__ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
-		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
-						 skb->len + sizeof(struct icmp6hdr));
+		icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
+					   skb->len + sizeof(struct icmp6hdr));
 	}
 	dst_release(dst);
 out:
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index ac826dd338ff..d12c55dad7d1 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -154,9 +154,8 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 				ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
-		err = icmpv6_push_pending_frames(sk, &fl6,
-						 (struct icmp6hdr *) &pfh.icmph,
-						 len);
+		icmpv6_push_pending_frames(sk, &fl6,
+					   (struct icmp6hdr *)&pfh.icmph, len);
 	}
 	release_sock(sk);
 
-- 
2.10.0.rc2.1.g053435c
