From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/15] l2tp: Fix locking in l2tp_core.c
Date: Sun, 08 May 2011 15:37:27 -0700 (PDT)
Message-ID: <20110508.153727.112619158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42638
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755698Ab1EHWh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:37:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5977624C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


l2tp_xmit_skb() must take the socket lock.  It makes use of ip_queue_xmit()
which expects to execute in a socket atomic context.

Since we execute this function in software interrupts, we cannot use the
usual lock_sock()/release_sock() sequence, instead we have to use
bh_lock_sock() and see if a user has the socket locked, and if so drop
the packet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_core.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index c64ce0a..7853029 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1060,6 +1060,12 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 			      IPSKB_REROUTED);
 	nf_reset(skb);
 
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		dev_kfree_skb(skb);
+		goto out_unlock;
+	}
+
 	/* Get routing info from the tunnel socket */
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst_clone(__sk_dst_get(sk)));
@@ -1106,6 +1112,8 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	l2tp_skb_set_owner_w(skb, sk);
 
 	l2tp_xmit_core(session, skb, data_len);
+out_unlock:
+	bh_unlock_sock(sk);
 
 abort:
 	return 0;
-- 
1.7.5.1

