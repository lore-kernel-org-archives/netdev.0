From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 4/6] ipv6: Introduce udpv6_send_skb()
Date: Sat, 31 Jan 2015 10:40:16 -0500
Message-ID: <1422718818-21093-5-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:41571 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbAaPk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:40:57 -0500
Received: by mail-qg0-f54.google.com with SMTP id q108so42261190qgd.13
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:40:56 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can individually construct IPv6 skbs to send, add a
udpv6_send_skb() function to populate the udp header and send the
skb.  This allows udp_v6_push_pending_frames() to re-use this
function as well as enables us to add lockless sendmsg() support.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/udp.c | 67 +++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 40 insertions(+), 27 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e41f017..67a3d70 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -990,9 +990,10 @@ static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 {
 	unsigned int offset;
 	struct udphdr *uh = udp_hdr(skb);
+	struct sk_buff *frags = skb_shinfo(skb)->frag_list;
 	__wsum csum = 0;
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+	if (!frags) {
 		/* Only one fragment on the socket.  */
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
@@ -1008,9 +1009,9 @@ static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 
 		skb->ip_summed = CHECKSUM_NONE;
 
-		skb_queue_walk(&sk->sk_write_queue, skb) {
-			csum = csum_add(csum, skb->csum);
-		}
+		do {
+			csum = csum_add(csum, frags->csum);
+		} while ((frags = frags->next));
 
 		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP,
 					    csum);
@@ -1023,26 +1024,15 @@ static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
  *	Sending
  */
 
-static int udp_v6_push_pending_frames(struct sock *sk)
+static int udp_v6_send_skb(struct sk_buff *skb, struct flowi6 *fl6)
 {
-	struct sk_buff *skb;
+	struct sock *sk = skb->sk;
 	struct udphdr *uh;
-	struct udp_sock  *up = udp_sk(sk);
-	struct inet_sock *inet = inet_sk(sk);
-	struct flowi6 *fl6;
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
 	__wsum csum = 0;
-
-	if (up->pending == AF_INET)
-		return udp_push_pending_frames(sk);
-
-	fl6 = &inet->cork.fl.u.ip6;
-
-	/* Grab the skbuff where UDP header space exists. */
-	skb = skb_peek(&sk->sk_write_queue);
-	if (skb == NULL)
-		goto out;
+	int offset = skb_transport_offset(skb);
+	int len = skb->len - offset;
 
 	/*
 	 * Create a UDP header
@@ -1050,29 +1040,28 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	uh = udp_hdr(skb);
 	uh->source = fl6->fl6_sport;
 	uh->dest = fl6->fl6_dport;
-	uh->len = htons(up->len);
+	uh->len = htons(len);
 	uh->check = 0;
 
 	if (is_udplite)
-		csum = udplite_csum_outgoing(sk, skb);
-	else if (up->no_check6_tx) {   /* UDP csum disabled */
+		csum = udplite_csum(skb);
+	else if (udp_sk(sk)->no_check6_tx) {   /* UDP csum disabled */
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
-		udp6_hwcsum_outgoing(sk, skb, &fl6->saddr, &fl6->daddr,
-				     up->len);
+		udp6_hwcsum_outgoing(sk, skb, &fl6->saddr, &fl6->daddr, len);
 		goto send;
 	} else
-		csum = udp_csum_outgoing(sk, skb);
+		csum = udp_csum(skb);
 
 	/* add protocol-dependent pseudo-header */
 	uh->check = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
-				    up->len, fl6->flowi6_proto, csum);
+				    len, fl6->flowi6_proto, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
 send:
-	err = ip6_push_pending_frames(sk);
+	err = ip6_send_skb(skb);
 	if (err) {
 		if (err == -ENOBUFS && !inet6_sk(sk)->recverr) {
 			UDP6_INC_STATS_USER(sock_net(sk),
@@ -1082,6 +1071,30 @@ send:
 	} else
 		UDP6_INC_STATS_USER(sock_net(sk),
 				    UDP_MIB_OUTDATAGRAMS, is_udplite);
+	return err;
+}
+
+static int udp_v6_push_pending_frames(struct sock *sk)
+{
+	struct sk_buff *skb;
+	struct udp_sock  *up = udp_sk(sk);
+	struct flowi6 fl6;
+	int err = 0;
+
+	if (up->pending == AF_INET)
+		return udp_push_pending_frames(sk);
+
+	/* ip6_finish_skb will release the cork, so make a copy of
+	 * fl6 here.
+	 */
+	fl6 = inet_sk(sk)->cork.fl.u.ip6;
+
+	skb = ip6_finish_skb(sk);
+	if (!skb)
+		goto out;
+
+	err = udp_v6_send_skb(skb, &fl6);
+
 out:
 	up->len = 0;
 	up->pending = 0;
-- 
1.9.3
