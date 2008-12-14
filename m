From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] l2tp: fix UDP checksum support
Date: Sun, 14 Dec 2008 16:41:08 GMT
Message-ID: <200812141641.mBEGf8Lq021173@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49932 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbYLNQo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2008 11:44:59 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id D25C9A620A1
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2008 16:41:15 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fOLk9jVPFR5t for <netdev@vger.kernel.org>;
	Sun, 14 Dec 2008 16:41:09 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id AD021A62087
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2008 16:41:09 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pppol2tp driver has had broken UDP checksum code for a long
time. This patch fixes it. If UDP checksums are enabled in the
tunnel's UDP socket, the L2TP driver now properly validates the
checksum on receive and fills in the checksum on transmit. If the
network device has hardware checksum support and is enabled, it is
used instead of generating/checking the checksum in software.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: net-next-2.6-l2tp/drivers/net/pppol2tp.c
===================================================================
--- net-next-2.6-l2tp.orig/drivers/net/pppol2tp.c
+++ net-next-2.6-l2tp/drivers/net/pppol2tp.c
@@ -489,6 +489,30 @@ out:
 	spin_unlock_bh(&session->reorder_q.lock);
 }
 
+static inline int pppol2tp_verify_udp_checksum(struct sock *sk,
+					       struct sk_buff *skb)
+{
+	struct udphdr *uh = udp_hdr(skb);
+	u16 ulen = ntohs(uh->len);
+	struct inet_sock *inet;
+	__wsum psum;
+
+	if (sk->sk_no_check || skb_csum_unnecessary(skb) || !uh->check)
+		return 0;
+
+	inet = inet_sk(sk);
+	psum = csum_tcpudp_nofold(inet->saddr, inet->daddr, ulen,
+				  IPPROTO_UDP, 0);
+
+	if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
+	    !csum_fold(csum_add(psum, skb->csum)))
+		return 0;
+
+	skb->csum = psum;
+
+	return __skb_checksum_complete(skb);
+}
+
 /* Internal receive frame. Do the real work of receiving an L2TP data frame
  * here. The skb is not on a list when we get here.
  * Returns 0 if the packet was a data packet and was successfully passed on.
@@ -509,6 +533,9 @@ static int pppol2tp_recv_core(struct soc
 	if (tunnel == NULL)
 		goto no_tunnel;
 
+	if (tunnel->sock && pppol2tp_verify_udp_checksum(tunnel->sock, skb))
+		goto discard_bad_csum;
+
 	/* UDP always verifies the packet length. */
 	__skb_pull(skb, sizeof(struct udphdr));
 
@@ -725,6 +752,14 @@ discard:
 
 	return 0;
 
+discard_bad_csum:
+	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
+	UDP_INC_STATS_USER(&init_net, UDP_MIB_INERRORS, 0);
+	tunnel->stats.rx_errors++;
+	kfree_skb(skb);
+
+	return 0;
+
 error:
 	/* Put UDP header back */
 	__skb_push(skb, sizeof(struct udphdr));
@@ -851,7 +886,7 @@ static int pppol2tp_sendmsg(struct kiocb
 	static const unsigned char ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet;
-	__wsum csum = 0;
+	__wsum csum;
 	struct sk_buff *skb;
 	int error;
 	int hdr_len;
@@ -859,6 +894,8 @@ static int pppol2tp_sendmsg(struct kiocb
 	struct pppol2tp_tunnel *tunnel;
 	struct udphdr *uh;
 	unsigned int len;
+	struct sock *sk_tun;
+	u16 udp_len;
 
 	error = -ENOTCONN;
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
@@ -870,7 +907,8 @@ static int pppol2tp_sendmsg(struct kiocb
 	if (session == NULL)
 		goto error;
 
-	tunnel = pppol2tp_sock_to_tunnel(session->tunnel_sock);
+	sk_tun = session->tunnel_sock;
+	tunnel = pppol2tp_sock_to_tunnel(sk_tun);
 	if (tunnel == NULL)
 		goto error_put_sess;
 
@@ -893,11 +931,12 @@ static int pppol2tp_sendmsg(struct kiocb
 	skb_reset_transport_header(skb);
 
 	/* Build UDP header */
-	inet = inet_sk(session->tunnel_sock);
+	inet = inet_sk(sk_tun);
+	udp_len = hdr_len + sizeof(ppph) + total_len;
 	uh = (struct udphdr *) skb->data;
 	uh->source = inet->sport;
 	uh->dest = inet->dport;
-	uh->len = htons(hdr_len + sizeof(ppph) + total_len);
+	uh->len = htons(udp_len);
 	uh->check = 0;
 	skb_put(skb, sizeof(struct udphdr));
 
@@ -919,8 +958,22 @@ static int pppol2tp_sendmsg(struct kiocb
 	skb_put(skb, total_len);
 
 	/* Calculate UDP checksum if configured to do so */
-	if (session->tunnel_sock->sk_no_check != UDP_CSUM_NOXMIT)
-		csum = udp_csum_outgoing(sk, skb);
+	if (sk_tun->sk_no_check == UDP_CSUM_NOXMIT)
+		skb->ip_summed = CHECKSUM_NONE;
+	else if (!(skb->dst->dev->features & NETIF_F_V4_CSUM)) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		csum = skb_checksum(skb, 0, udp_len, 0);
+		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
+					      udp_len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(inet->saddr, inet->daddr,
+					       udp_len, IPPROTO_UDP, 0);
+	}
 
 	/* Debug */
 	if (session->send_seq)
@@ -1008,13 +1061,14 @@ static int pppol2tp_xmit(struct ppp_chan
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
 	int hdr_len;
+	u16 udp_len;
 	struct pppol2tp_session *session;
 	struct pppol2tp_tunnel *tunnel;
 	int rc;
 	int headroom;
 	int data_len = skb->len;
 	struct inet_sock *inet;
-	__wsum csum = 0;
+	__wsum csum;
 	struct udphdr *uh;
 	unsigned int len;
 	int old_headroom;
@@ -1060,6 +1114,8 @@ static int pppol2tp_xmit(struct ppp_chan
 	/* Setup L2TP header */
 	pppol2tp_build_l2tp_header(session, __skb_push(skb, hdr_len));
 
+	udp_len = sizeof(struct udphdr) + hdr_len + sizeof(ppph) + data_len;
+
 	/* Setup UDP header */
 	inet = inet_sk(sk_tun);
 	__skb_push(skb, sizeof(*uh));
@@ -1067,13 +1123,9 @@ static int pppol2tp_xmit(struct ppp_chan
 	uh = udp_hdr(skb);
 	uh->source = inet->sport;
 	uh->dest = inet->dport;
-	uh->len = htons(sizeof(struct udphdr) + hdr_len + sizeof(ppph) + data_len);
+	uh->len = htons(udp_len);
 	uh->check = 0;
 
-	/* *BROKEN* Calculate UDP checksum if configured to do so */
-	if (sk_tun->sk_no_check != UDP_CSUM_NOXMIT)
-		csum = udp_csum_outgoing(sk_tun, skb);
-
 	/* Debug */
 	if (session->send_seq)
 		PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_DEBUG,
@@ -1108,6 +1160,24 @@ static int pppol2tp_xmit(struct ppp_chan
 	skb->dst = dst_clone(__sk_dst_get(sk_tun));
 	pppol2tp_skb_set_owner_w(skb, sk_tun);
 
+	/* Calculate UDP checksum if configured to do so */
+	if (sk_tun->sk_no_check == UDP_CSUM_NOXMIT)
+		skb->ip_summed = CHECKSUM_NONE;
+	else if (!(skb->dst->dev->features & NETIF_F_V4_CSUM)) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		csum = skb_checksum(skb, 0, udp_len, 0);
+		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
+					      udp_len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(inet->saddr, inet->daddr,
+					       udp_len, IPPROTO_UDP, 0);
+	}
+
 	/* Queue the packet to IP for output */
 	len = skb->len;
 	rc = ip_queue_xmit(skb, 1);
