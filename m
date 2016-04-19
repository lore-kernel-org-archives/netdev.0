From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 19:27:04 -0700
Message-ID: <20160419022704.GB35817@dreloong-mbp.local.DHCP.thefacebook.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-5-git-send-email-kafai@fb.com>
 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160418234202.GA27948@kafai-mba.local>
 <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:29218 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751896AbcDSC1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 22:27:15 -0400
Content-Disposition: inline
In-Reply-To: <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 05:06:57PM -0700, Eric Dumazet wrote:
> It should only be a request from user space to ask TCP to not aggregate
> stuff on future sendpage()/sendmsg() on the skb carrying this new flag.
>
How about something like this.  Please advise if tcp_sendmsg_noappend can
be simpler.

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c0ef054..ac31798 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -762,7 +762,8 @@ struct tcp_skb_cb {

 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
-			unused:7;
+			eor:1,		/* Is skb MSG_EOR marked */
+			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858..12772be 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -874,6 +874,13 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }

+static bool tcp_sendmsg_noappend(const struct sock *sk)
+{
+	const struct sk_buff *skb = tcp_write_queue_tail(sk);
+
+	return (!skb || TCP_SKB_CB(skb)->eor);
+}
+
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 				size_t size, int flags)
 {
@@ -903,6 +910,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;

+	if (tcp_sendmsg_noappend(sk))
+		goto new_segment;
+
 	while (size > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		int copy, i;
@@ -960,6 +970,7 @@ new_segment:
 		size -= copy;
 		if (!size) {
 			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}

@@ -1145,6 +1156,9 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)

 	sg = !!(sk->sk_route_caps & NETIF_F_SG);

+	if (tcp_sendmsg_noappend(sk))
+		goto new_segment;
+
 	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
@@ -1250,6 +1264,7 @@ new_segment:
 		copied += copy;
 		if (!msg_data_left(msg)) {
 			tcp_tx_timestamp(sk, sockc.tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}
