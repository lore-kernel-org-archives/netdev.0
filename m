From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: [PATCH] Bluetooth: Fix deadlock in the ERTM logic
Date: Tue, 21 Sep 2010 18:20:13 -0300
Message-ID: <1285104013-9946-2-git-send-email-padovan@profusion.mobi>
References: <1285104013-9946-1-git-send-email-padovan@profusion.mobi>
Cc: linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	padovan@profusion.mobi, marcel@holtmann.org, davem@davemloft.net,
	mathewm@codeaurora.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47074 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328Ab0IUVUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:20:36 -0400
In-Reply-To: <1285104013-9946-1-git-send-email-padovan@profusion.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Enhanced Retransmission Mode(ERTM) is a realiable mode of operation
of the Bluetooth L2CAP layer. Think on it like a simplified version of
TCP.
The problem we were facing here was a deadlock. ERTM uses a backlog
queue to queue incomimg packets while the user is helding the lock. The
problem is that at some moment the user doesn't have memory anymore to
do alloc new skbs and sleep with the lock to wait for memory, that
stalls the ERTM connection once we can't read the acknowledgements
packets in the backlog queue to free memory and make the allocation of
outcoming skb successful.

I'm thinking on this patch more like a proof of concept than a real fix
to the deadlock in ERTM.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
---
 net/bluetooth/l2cap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 44a8fb0..dd406b5 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1633,7 +1633,9 @@ static inline int l2cap_skbuff_fromiovec(struct sock *sk, struct msghdr *msg, in
 	while (len) {
 		count = min_t(unsigned int, conn->mtu, len);
 
+		release_sock(sk);
 		*frag = bt_skb_send_alloc(sk, count, msg->msg_flags & MSG_DONTWAIT, &err);
+		lock_sock(sk);
 		if (!*frag)
 			return -EFAULT;
 		if (memcpy_fromiovec(skb_put(*frag, count), msg->msg_iov, count))
@@ -1724,8 +1726,10 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct sock *sk, struct msghdr *m
 		hlen += 2;
 
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
+	release_sock(sk);
 	skb = bt_skb_send_alloc(sk, count + hlen,
 			msg->msg_flags & MSG_DONTWAIT, &err);
+	lock_sock(sk);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.7.3

