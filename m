From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ppp: avoid false drop_monitor false positives
Date: Sat, 19 May 2012 08:23:00 +0200
Message-ID: <1337408580.7029.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:65038 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab2ESGXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:23:08 -0400
Received: by wgbdr13 with SMTP id dr13so3370419wgb.1
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 23:23:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Call consume_skb() in place of kfree_skb() were appropriate.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ppp/ppp_async.c   |    2 +-
 drivers/net/ppp/ppp_generic.c |   14 +++++++-------
 drivers/net/ppp/ppp_synctty.c |    4 ++--
 drivers/net/ppp/pppoe.c       |    6 ++++--
 drivers/net/ppp/pptp.c        |    2 +-
 5 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ppp/ppp_async.c b/drivers/net/ppp/ppp_async.c
index af95a98..a031f6b 100644
--- a/drivers/net/ppp/ppp_async.c
+++ b/drivers/net/ppp/ppp_async.c
@@ -613,7 +613,7 @@ ppp_async_encode(struct asyncppp *ap)
 	*buf++ = PPP_FLAG;
 	ap->olim = buf;
 
-	kfree_skb(ap->tpkt);
+	consume_skb(ap->tpkt);
 	ap->tpkt = NULL;
 	return 1;
 }
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 21d7151..5c05572 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1092,13 +1092,13 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 				   new_skb->data, skb->len + 2,
 				   compressor_skb_size);
 	if (len > 0 && (ppp->flags & SC_CCP_UP)) {
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = new_skb;
 		skb_put(skb, len);
 		skb_pull(skb, 2);	/* pull off A/C bytes */
 	} else if (len == 0) {
 		/* didn't compress, or CCP not up yet */
-		kfree_skb(new_skb);
+		consume_skb(new_skb);
 		new_skb = skb;
 	} else {
 		/*
@@ -1112,7 +1112,7 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 		if (net_ratelimit())
 			netdev_err(ppp->dev, "ppp: compressor dropped pkt\n");
 		kfree_skb(skb);
-		kfree_skb(new_skb);
+		consume_skb(new_skb);
 		new_skb = NULL;
 	}
 	return new_skb;
@@ -1178,7 +1178,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 				    !(ppp->flags & SC_NO_TCP_CCID));
 		if (cp == skb->data + 2) {
 			/* didn't compress */
-			kfree_skb(new_skb);
+			consume_skb(new_skb);
 		} else {
 			if (cp[0] & SL_TYPE_COMPRESSED_TCP) {
 				proto = PPP_VJC_COMP;
@@ -1187,7 +1187,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 				proto = PPP_VJC_UNCOMP;
 				cp[0] = skb->data[2];
 			}
-			kfree_skb(skb);
+			consume_skb(skb);
 			skb = new_skb;
 			cp = skb_put(skb, len + 2);
 			cp[0] = 0;
@@ -1703,7 +1703,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			}
 			skb_reserve(ns, 2);
 			skb_copy_bits(skb, 0, skb_put(ns, skb->len), skb->len);
-			kfree_skb(skb);
+			consume_skb(skb);
 			skb = ns;
 		}
 		else
@@ -1851,7 +1851,7 @@ ppp_decompress_frame(struct ppp *ppp, struct sk_buff *skb)
 			goto err;
 		}
 
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = ns;
 		skb_put(skb, len);
 		skb_pull(skb, 2);	/* pull off the A/C bytes */
diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index 55e466c..1a12033 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -588,7 +588,7 @@ ppp_sync_txmunge(struct syncppp *ap, struct sk_buff *skb)
 			skb_reserve(npkt,2);
 			skb_copy_from_linear_data(skb,
 				      skb_put(npkt, skb->len), skb->len);
-			kfree_skb(skb);
+			consume_skb(skb);
 			skb = npkt;
 		}
 		skb_push(skb,2);
@@ -656,7 +656,7 @@ ppp_sync_push(struct syncppp *ap)
 			if (sent < ap->tpkt->len) {
 				tty_stuffed = 1;
 			} else {
-				kfree_skb(ap->tpkt);
+				consume_skb(ap->tpkt);
 				ap->tpkt = NULL;
 				clear_bit(XMIT_FULL, &ap->xmit_flags);
 				done = 1;
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index dd15b8f..cbf7047 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -984,8 +984,10 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (skb) {
 		total_len = min_t(size_t, total_len, skb->len);
 		error = skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
-		if (error == 0)
-			error = total_len;
+		if (error == 0) {
+			consume_skb(skb);
+			return total_len;
+		}
 	}
 
 	kfree_skb(skb);
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 72b50f5..1c98321 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -209,7 +209,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = new_skb;
 	}
 
