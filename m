From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: [PATCH] Bluetooth: Simplify L2CAP Streaming mode sending
Date: Mon, 30 Aug 2010 20:10:24 -0300
Message-ID: <1283209824-8795-2-git-send-email-padovan@profusion.mobi>
References: <1283209824-8795-1-git-send-email-padovan@profusion.mobi>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283209824-8795-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As we don't have any error control on the Streaming mode, i.e., we don't
need to keep a copy of the skb for later resending we don't need to
call skb_clone() on it.
Then we can go one further here, and dequeue the skb before sending it,
that also means we don't need to look to sk->sk_send_head anymore.

This patch fixes a bug in Streaming mode sending procedure, the call to
skb_clone() was making the system run into OOM condition. I never got
that before 2.6.36, so I'm think that we acctually have regression
there.

Anyway, the patch saves memory and time when sending Streaming mode
data, so it is good to mainline.

Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
---
 net/bluetooth/l2cap.c |   24 +++++++-----------------
 1 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index fadf26b..80e98cd 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1441,33 +1441,23 @@ static inline void l2cap_do_send(struct sock *sk, struct sk_buff *skb)
 
 static void l2cap_streaming_send(struct sock *sk)
 {
-	struct sk_buff *skb, *tx_skb;
+	struct sk_buff *skb;
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	u16 control, fcs;
 
-	while ((skb = sk->sk_send_head)) {
-		tx_skb = skb_clone(skb, GFP_ATOMIC);
-
-		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+	while ((skb = skb_dequeue(TX_QUEUE(sk)))) {
+		control = get_unaligned_le16(skb->data + L2CAP_HDR_SIZE);
 		control |= pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT;
-		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
+		put_unaligned_le16(control, skb->data + L2CAP_HDR_SIZE);
 
 		if (pi->fcs == L2CAP_FCS_CRC16) {
-			fcs = crc16(0, (u8 *)tx_skb->data, tx_skb->len - 2);
-			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
+			fcs = crc16(0, (u8 *)skb->data, skb->len - 2);
+			put_unaligned_le16(fcs, skb->data + skb->len - 2);
 		}
 
-		l2cap_do_send(sk, tx_skb);
+		l2cap_do_send(sk, skb);
 
 		pi->next_tx_seq = (pi->next_tx_seq + 1) % 64;
-
-		if (skb_queue_is_last(TX_QUEUE(sk), skb))
-			sk->sk_send_head = NULL;
-		else
-			sk->sk_send_head = skb_queue_next(TX_QUEUE(sk), skb);
-
-		skb = skb_dequeue(TX_QUEUE(sk));
-		kfree_skb(skb);
 	}
 }
 
-- 
1.7.2.2
