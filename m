From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2.6.23] [PPP]: L2TP: Fix oops in transmit and receive paths
Date: Mon, 5 Nov 2007 17:17:39 GMT
Message-ID: <200711051717.lA5HHd9u013301@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:58185 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbXKEUQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 15:16:46 -0500
Received: from [84.92.108.75] (helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1Ip5Ho-0007rC-4Z
	for netdev@vger.kernel.org; Mon, 05 Nov 2007 10:58:52 -0600
Received: from quickie.katalix.com (localhost.localdomain [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id lA5HHdpE013302
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 17:17:39 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id lA5HHd9u013301
	for netdev@vger.kernel.org; Mon, 5 Nov 2007 17:17:39 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP]: L2TP: Fix oops in transmit and receive paths

Changes made on 18-sep to fix skb handling in the pppol2tp driver
broke the transmit and receive paths. Users are only running into this
now because distros are now using 2.6.23 and I must have messed up
when I tested the change.

For receive, we now do our own calculation of how much to pull from
the skb (variable length L2TP header) rather than using
skb_transport_offset(). Also, if the skb isn't a data packet, it must
be passed back to UDP with skb->data pointing to the UDP header.

For transmit, make sure skb->sk is set up because ip_queue_xmit()
needs it.

Signed-off-by: James Chapman <jchapman@katalix.com>

---
This patch is for stable 2.6.23 fixes and the mainline.

Index: linux-2.6.23-l2tp/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.23-l2tp.orig/drivers/net/pppol2tp.c
+++ linux-2.6.23-l2tp/drivers/net/pppol2tp.c
@@ -487,7 +487,7 @@ static int pppol2tp_recv_core(struct soc
 {
 	struct pppol2tp_session *session = NULL;
 	struct pppol2tp_tunnel *tunnel;
-	unsigned char *ptr;
+	unsigned char *ptr, *optr;
 	u16 hdrflags;
 	u16 tunnel_id, session_id;
 	int length;
@@ -495,7 +495,7 @@ static int pppol2tp_recv_core(struct soc
 
 	tunnel = pppol2tp_sock_to_tunnel(sock);
 	if (tunnel == NULL)
-		goto error;
+		goto no_tunnel;
 
 	/* UDP always verifies the packet length. */
 	__skb_pull(skb, sizeof(struct udphdr));
@@ -508,7 +508,7 @@ static int pppol2tp_recv_core(struct soc
 	}
 
 	/* Point to L2TP header */
-	ptr = skb->data;
+	optr = ptr = skb->data;
 
 	/* Get L2TP header flags */
 	hdrflags = ntohs(*(__be16*)ptr);
@@ -636,12 +636,14 @@ static int pppol2tp_recv_core(struct soc
 	/* If offset bit set, skip it. */
 	if (hdrflags & L2TP_HDRFLAG_O) {
 		offset = ntohs(*(__be16 *)ptr);
-		skb->transport_header += 2 + offset;
-		if (!pskb_may_pull(skb, skb_transport_offset(skb) + 2))
-			goto discard;
+		ptr += 2 + offset;
 	}
 
-	__skb_pull(skb, skb_transport_offset(skb));
+	offset = ptr - optr;
+	if (!pskb_may_pull(skb, offset))
+		goto discard;
+
+	__skb_pull(skb, offset);
 
 	/* Skip PPP header, if present.	 In testing, Microsoft L2TP clients
 	 * don't send the PPP header (PPP header compression enabled), but
@@ -651,6 +653,9 @@ static int pppol2tp_recv_core(struct soc
 	 * Note that skb->data[] isn't dereferenced from a u16 ptr here since
 	 * the field may be unaligned.
 	 */
+	if (!pskb_may_pull(skb, 2))
+		goto discard;
+
 	if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
 		skb_pull(skb, 2);
 
@@ -708,6 +713,10 @@ discard:
 	return 0;
 
 error:
+	/* Put UDP header back */
+	__skb_push(skb, sizeof(struct udphdr));
+
+no_tunnel:
 	return 1;
 }
 
@@ -1049,6 +1052,8 @@ static int pppol2tp_xmit(struct ppp_chan
 	/* Get routing info from the tunnel socket */
 	dst_release(skb->dst);
 	skb->dst = sk_dst_get(sk_tun);
+	skb_orphan(skb);
+	skb->sk = sk_tun;
 
 	/* Queue the packet to IP for output */
 	len = skb->len;
