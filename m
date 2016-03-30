From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 7/8] sock: enable timestamping using control messages
Date: Wed, 30 Mar 2016 18:37:27 -0400
Message-ID: <1459377448-2239-8-git-send-email-soheil.kdev@gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:33191 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbcC3Whv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 18:37:51 -0400
Received: by mail-qg0-f67.google.com with SMTP id y89so6193022qge.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 15:37:51 -0700 (PDT)
In-Reply-To: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Currently, SOL_TIMESTAMPING can only be enabled using setsockopt.
This is very costly when users want to sample writes to gather
tx timestamps.

Add support for enabling SO_TIMESTAMPING via control messages by
using tsflags added in `struct sockcm_cookie` (added in the previous
patches in this series) to set the tx_flags of the last skb created in
a sendmsg. With this patch, the timestamp recording bits in tx_flags
of the skbuff is overridden if SO_TIMESTAMPING is passed in a cmsg.

Please note that this is only effective for overriding the recording
timestamps flags. Users should enable timestamp reporting (e.g.,
SOF_TIMESTAMPING_SOFTWARE | SOF_TIMESTAMPING_OPT_ID) using
socket options and then should ask for SOF_TIMESTAMPING_TX_*
using control messages per sendmsg to sample timestamps for each
write.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 drivers/net/tun.c      |  3 ++-
 include/net/ipv6.h     |  6 ++++--
 include/net/sock.h     | 10 ++++++----
 net/can/raw.c          |  2 +-
 net/ipv4/ping.c        |  5 +++--
 net/ipv4/raw.c         | 11 ++++++-----
 net/ipv4/tcp.c         | 20 +++++++++++++++-----
 net/ipv4/udp.c         |  7 ++++---
 net/ipv6/icmp.c        |  6 ++++--
 net/ipv6/ip6_output.c  | 15 +++++++++------
 net/ipv6/ping.c        |  3 ++-
 net/ipv6/raw.c         |  5 ++---
 net/ipv6/udp.c         |  7 ++++---
 net/packet/af_packet.c | 30 +++++++++++++++++++++++++-----
 net/socket.c           | 10 +++++-----
 15 files changed, 92 insertions(+), 48 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950..6d2fcd0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -860,7 +860,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	if (skb->sk && sk_fullsock(skb->sk)) {
-		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
+		sock_tx_timestamp(skb->sk, skb->sk->sk_tsflags,
+				  &skb_shinfo(skb)->tx_flags);
 		sw_tx_timestamp(skb);
 	}
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0aeb97..55ee1eb 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -867,7 +867,8 @@ int ip6_append_data(struct sock *sk,
 				int odd, struct sk_buff *skb),
 		    void *from, int length, int transhdrlen, int hlimit,
 		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-		    struct rt6_info *rt, unsigned int flags, int dontfrag);
+		    struct rt6_info *rt, unsigned int flags, int dontfrag,
+		    const struct sockcm_cookie *sockc);
 
 int ip6_push_pending_frames(struct sock *sk);
 
@@ -884,7 +885,8 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 			     void *from, int length, int transhdrlen,
 			     int hlimit, int tclass, struct ipv6_txoptions *opt,
 			     struct flowi6 *fl6, struct rt6_info *rt,
-			     unsigned int flags, int dontfrag);
+			     unsigned int flags, int dontfrag,
+			     const struct sockcm_cookie *sockc);
 
 static inline struct sk_buff *ip6_finish_skb(struct sock *sk)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index af012da..e91b87f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2057,19 +2057,21 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 		sk->sk_stamp = skb->tstamp;
 }
 
-void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags);
+void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
 
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
  * @sk:		socket sending this packet
+ * @tsflags:	timestamping flags to use
  * @tx_flags:	completed with instructions for time stamping
  *
  * Note : callers should take care of initial *tx_flags value (usually 0)
  */
-static inline void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+static inline void sock_tx_timestamp(const struct sock *sk, __u16 tsflags,
+				     __u8 *tx_flags)
 {
-	if (unlikely(sk->sk_tsflags))
-		__sock_tx_timestamp(sk, tx_flags);
+	if (unlikely(tsflags))
+		__sock_tx_timestamp(tsflags, tx_flags);
 	if (unlikely(sock_flag(sk, SOCK_WIFI_STATUS)))
 		*tx_flags |= SKBTX_WIFI_STATUS;
 }
diff --git a/net/can/raw.c b/net/can/raw.c
index 2e67b14..972c187 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -755,7 +755,7 @@ static int raw_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 	if (err < 0)
 		goto free_skb;
 
-	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	sock_tx_timestamp(sk, sk->sk_tsflags, &skb_shinfo(skb)->tx_flags);
 
 	skb->dev = dev;
 	skb->sk  = sk;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 670639b..66ddcb6 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -737,6 +737,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		/* no remote port */
 	}
 
+	ipc.sockc.tsflags = sk->sk_tsflags;
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
 	ipc.oif = sk->sk_bound_dev_if;
@@ -744,8 +745,6 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	ipc.ttl = 0;
 	ipc.tos = -1;
 
-	sock_tx_timestamp(sk, &ipc.tx_flags);
-
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sk, msg, &ipc, false);
 		if (unlikely(err)) {
@@ -768,6 +767,8 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		rcu_read_unlock();
 	}
 
+	sock_tx_timestamp(sk, ipc.sockc.tsflags, &ipc.tx_flags);
+
 	saddr = ipc.addr;
 	ipc.addr = faddr = daddr;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 088ce66..438f50c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -339,8 +339,8 @@ int raw_rcv(struct sock *sk, struct sk_buff *skb)
 
 static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 			   struct msghdr *msg, size_t length,
-			   struct rtable **rtp,
-			   unsigned int flags)
+			   struct rtable **rtp, unsigned int flags,
+			   const struct sockcm_cookie *sockc)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
@@ -379,7 +379,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	sock_tx_timestamp(sk, sockc->tsflags, &skb_shinfo(skb)->tx_flags);
 
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
@@ -540,6 +540,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		daddr = inet->inet_daddr;
 	}
 
+	ipc.sockc.tsflags = sk->sk_tsflags;
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
@@ -638,10 +639,10 @@ back_from_confirm:
 
 	if (inet->hdrincl)
 		err = raw_send_hdrinc(sk, &fl4, msg, len,
-				      &rt, msg->msg_flags);
+				      &rt, msg->msg_flags, &ipc.sockc);
 
 	 else {
-		sock_tx_timestamp(sk, &ipc.tx_flags);
+		sock_tx_timestamp(sk, ipc.sockc.tsflags, &ipc.tx_flags);
 
 		if (!ipc.addr)
 			ipc.addr = fl4.daddr;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ce3c9eb..4d73858 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -428,13 +428,13 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
-static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
+static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
 {
-	if (sk->sk_tsflags) {
+	if (sk->sk_tsflags || tsflags) {
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
-		sock_tx_timestamp(sk, &shinfo->tx_flags);
+		sock_tx_timestamp(sk, tsflags, &shinfo->tx_flags);
 		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
 			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
 		tcb->txstamp_ack = !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
@@ -959,7 +959,7 @@ new_segment:
 		offset += copy;
 		size -= copy;
 		if (!size) {
-			tcp_tx_timestamp(sk, skb);
+			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
 			goto out;
 		}
 
@@ -1079,6 +1079,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
+	struct sockcm_cookie sockc;
 	int flags, err, copied = 0;
 	int mss_now = 0, size_goal, copied_syn = 0;
 	bool sg;
@@ -1121,6 +1122,15 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		/* 'common' sending to sendq */
 	}
 
+	sockc.tsflags = sk->sk_tsflags;
+	if (msg->msg_controllen) {
+		err = sock_cmsg_send(sk, msg, &sockc);
+		if (unlikely(err)) {
+			err = -EINVAL;
+			goto out_err;
+		}
+	}
+
 	/* This should be in poll */
 	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
@@ -1239,7 +1249,7 @@ new_segment:
 
 		copied += copy;
 		if (!msg_data_left(msg)) {
-			tcp_tx_timestamp(sk, skb);
+			tcp_tx_timestamp(sk, sockc.tsflags, skb);
 			goto out;
 		}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bccb4e1..45ff590 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1027,12 +1027,11 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		 */
 		connected = 1;
 	}
-	ipc.addr = inet->inet_saddr;
 
+	ipc.sockc.tsflags = sk->sk_tsflags;
+	ipc.addr = inet->inet_saddr;
 	ipc.oif = sk->sk_bound_dev_if;
 
-	sock_tx_timestamp(sk, &ipc.tx_flags);
-
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sk, msg, &ipc, sk->sk_family == AF_INET6);
 		if (unlikely(err)) {
@@ -1059,6 +1058,8 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	saddr = ipc.addr;
 	ipc.addr = faddr = daddr;
 
+	sock_tx_timestamp(sk, ipc.sockc.tsflags, &ipc.tx_flags);
+
 	if (ipc.opt && ipc.opt->opt.srr) {
 		if (!daddr)
 			return -EINVAL;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 0a37ddc..6b573eb 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -400,6 +400,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct icmp6hdr tmp_hdr;
 	struct flowi6 fl6;
 	struct icmpv6_msg msg;
+	struct sockcm_cookie sockc_unused = {0};
 	int iif = 0;
 	int addr_type = 0;
 	int len;
@@ -527,7 +528,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 			      len + sizeof(struct icmp6hdr),
 			      sizeof(struct icmp6hdr), hlimit,
 			      np->tclass, NULL, &fl6, (struct rt6_info *)dst,
-			      MSG_DONTWAIT, np->dontfrag);
+			      MSG_DONTWAIT, np->dontfrag, &sockc_unused);
 	if (err) {
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
@@ -566,6 +567,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	int hlimit;
 	u8 tclass;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
+	struct sockcm_cookie sockc_unused = {0};
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
@@ -617,7 +619,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
 				sizeof(struct icmp6hdr), hlimit, tclass, NULL, &fl6,
 				(struct rt6_info *)dst, MSG_DONTWAIT,
-				np->dontfrag);
+				np->dontfrag, &sockc_unused);
 
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9428345..612f3d1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1258,7 +1258,8 @@ static int __ip6_append_data(struct sock *sk,
 			     int getfrag(void *from, char *to, int offset,
 					 int len, int odd, struct sk_buff *skb),
 			     void *from, int length, int transhdrlen,
-			     unsigned int flags, int dontfrag)
+			     unsigned int flags, int dontfrag,
+			     const struct sockcm_cookie *sockc)
 {
 	struct sk_buff *skb, *skb_prev = NULL;
 	unsigned int maxfraglen, fragheaderlen, mtu, orig_mtu;
@@ -1329,7 +1330,7 @@ emsgsize:
 		csummode = CHECKSUM_PARTIAL;
 
 	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW) {
-		sock_tx_timestamp(sk, &tx_flags);
+		sock_tx_timestamp(sk, sockc->tsflags, &tx_flags);
 		if (tx_flags & SKBTX_ANY_SW_TSTAMP &&
 		    sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
 			tskey = sk->sk_tskey++;
@@ -1565,7 +1566,8 @@ int ip6_append_data(struct sock *sk,
 				int odd, struct sk_buff *skb),
 		    void *from, int length, int transhdrlen, int hlimit,
 		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-		    struct rt6_info *rt, unsigned int flags, int dontfrag)
+		    struct rt6_info *rt, unsigned int flags, int dontfrag,
+		    const struct sockcm_cookie *sockc)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1593,7 +1595,8 @@ int ip6_append_data(struct sock *sk,
 
 	return __ip6_append_data(sk, fl6, &sk->sk_write_queue, &inet->cork.base,
 				 &np->cork, sk_page_frag(sk), getfrag,
-				 from, length, transhdrlen, flags, dontfrag);
+				 from, length, transhdrlen, flags, dontfrag,
+				 sockc);
 }
 EXPORT_SYMBOL_GPL(ip6_append_data);
 
@@ -1752,7 +1755,7 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 			     int hlimit, int tclass,
 			     struct ipv6_txoptions *opt, struct flowi6 *fl6,
 			     struct rt6_info *rt, unsigned int flags,
-			     int dontfrag)
+			     int dontfrag, const struct sockcm_cookie *sockc)
 {
 	struct inet_cork_full cork;
 	struct inet6_cork v6_cork;
@@ -1779,7 +1782,7 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 	err = __ip6_append_data(sk, fl6, &queue, &cork.base, &v6_cork,
 				&current->task_frag, getfrag, from,
 				length + exthdrlen, transhdrlen + exthdrlen,
-				flags, dontfrag);
+				flags, dontfrag, sockc);
 	if (err) {
 		__ip6_flush_pending_frames(sk, &queue, &cork, &v6_cork);
 		return ERR_PTR(err);
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index c382db7..da1cff7 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -62,6 +62,7 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct dst_entry *dst;
 	struct rt6_info *rt;
 	struct pingfakehdr pfh;
+	struct sockcm_cookie junk = {0};
 
 	pr_debug("ping_v6_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
 
@@ -144,7 +145,7 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
 			      0, hlimit,
 			      np->tclass, NULL, &fl6, rt,
-			      MSG_DONTWAIT, np->dontfrag);
+			      MSG_DONTWAIT, np->dontfrag, &junk);
 
 	if (err) {
 		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index f175ec0..b07ce21 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -822,8 +822,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (fl6.flowi6_oif == 0)
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
-	sockc.tsflags = 0;
-
+	sockc.tsflags = sk->sk_tsflags;
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
@@ -901,7 +900,7 @@ back_from_confirm:
 		lock_sock(sk);
 		err = ip6_append_data(sk, raw6_getfrag, &rfv,
 			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info *)dst,
-			msg->msg_flags, dontfrag);
+			msg->msg_flags, dontfrag, &sockc);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8371a51..fef21c4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1248,7 +1248,7 @@ do_udp_sendmsg:
 		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
 
 	fl6.flowi6_mark = sk->sk_mark;
-	sockc.tsflags = 0;
+	sockc.tsflags = sk->sk_tsflags;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -1324,7 +1324,7 @@ back_from_confirm:
 		skb = ip6_make_skb(sk, getfrag, msg, ulen,
 				   sizeof(struct udphdr), hlimit, tclass, opt,
 				   &fl6, (struct rt6_info *)dst,
-				   msg->msg_flags, dontfrag);
+				   msg->msg_flags, dontfrag, &sockc);
 		err = PTR_ERR(skb);
 		if (!IS_ERR_OR_NULL(skb))
 			err = udp_v6_send_skb(skb, &fl6);
@@ -1351,7 +1351,8 @@ do_append_data:
 	err = ip6_append_data(sk, getfrag, msg, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
 		(struct rt6_info *)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
+		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag,
+		&sockc);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1ecfa71..0007e23 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1837,6 +1837,7 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 	DECLARE_SOCKADDR(struct sockaddr_pkt *, saddr, msg->msg_name);
 	struct sk_buff *skb = NULL;
 	struct net_device *dev;
+	struct sockcm_cookie sockc;
 	__be16 proto = 0;
 	int err;
 	int extra_len = 0;
@@ -1925,12 +1926,21 @@ retry:
 		goto out_unlock;
 	}
 
+	sockc.tsflags = 0;
+	if (msg->msg_controllen) {
+		err = sock_cmsg_send(sk, msg, &sockc);
+		if (unlikely(err)) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
+	}
+
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	sock_tx_timestamp(sk, sockc.tsflags, &skb_shinfo(skb)->tx_flags);
 
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
@@ -2486,7 +2496,8 @@ static int packet_snd_vnet_gso(struct sk_buff *skb,
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, void *data, int tp_len,
-		__be16 proto, unsigned char *addr, int hlen, int copylen)
+		__be16 proto, unsigned char *addr, int hlen, int copylen,
+		const struct sockcm_cookie *sockc)
 {
 	union tpacket_uhdr ph;
 	int to_write, offset, len, nr_frags, len_max;
@@ -2500,7 +2511,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
-	sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
+	sock_tx_timestamp(&po->sk, sockc->tsflags, &skb_shinfo(skb)->tx_flags);
 	skb_shinfo(skb)->destructor_arg = ph.raw;
 
 	skb_reserve(skb, hlen);
@@ -2624,6 +2635,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct sk_buff *skb;
 	struct net_device *dev;
 	struct virtio_net_hdr *vnet_hdr = NULL;
+	struct sockcm_cookie sockc;
 	__be16 proto;
 	int err, reserve = 0;
 	void *ph;
@@ -2655,6 +2667,13 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
 	}
 
+	sockc.tsflags = 0;
+	if (msg->msg_controllen) {
+		err = sock_cmsg_send(&po->sk, msg, &sockc);
+		if (unlikely(err))
+			goto out;
+	}
+
 	err = -ENXIO;
 	if (unlikely(dev == NULL))
 		goto out;
@@ -2712,7 +2731,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_status;
 		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, data, tp_len, proto,
-					  addr, hlen, copylen);
+					  addr, hlen, copylen, &sockc);
 		if (likely(tp_len >= 0) &&
 		    tp_len > dev->mtu + reserve &&
 		    !po->has_vnet_hdr &&
@@ -2851,6 +2870,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_unlock;
 
+	sockc.tsflags = 0;
 	sockc.mark = sk->sk_mark;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(sk, msg, &sockc);
@@ -2908,7 +2928,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		goto out_free;
 	}
 
-	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	sock_tx_timestamp(sk, sockc.tsflags, &skb_shinfo(skb)->tx_flags);
 
 	if (!vnet_hdr.gso_type && (len > dev->mtu + reserve + extra_len) &&
 	    !packet_extra_vlan_len_allowed(dev, skb)) {
diff --git a/net/socket.c b/net/socket.c
index 5f77a8e..979d314 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -587,20 +587,20 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
+void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags)
 {
 	u8 flags = *tx_flags;
 
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_HARDWARE)
+	if (tsflags & SOF_TIMESTAMPING_TX_HARDWARE)
 		flags |= SKBTX_HW_TSTAMP;
 
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
+	if (tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
 		flags |= SKBTX_SW_TSTAMP;
 
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SCHED)
+	if (tsflags & SOF_TIMESTAMPING_TX_SCHED)
 		flags |= SKBTX_SCHED_TSTAMP;
 
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)
+	if (tsflags & SOF_TIMESTAMPING_TX_ACK)
 		flags |= SKBTX_ACK_TSTAMP;
 
 	*tx_flags = flags;
-- 
2.8.0.rc3.226.g39d4020
