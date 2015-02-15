From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] net: Reflect RX hash for transmit
Date: Sun, 15 Feb 2015 10:37:18 -0800
Message-ID: <1424025438-1659-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33001 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbbBOShh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:37:37 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so19847639iga.0
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:37:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows a driver to request that the receive hash it provides
to the stack is reflected back in skb->hash for packets transmitted
on the associated connection. The hash value returned by a device could
have meaning when used in transmit to identify a flow, for instance
the hash may by a flow ID for a flow created in a (virtual) device.
With the flow ID provided on transmit this can obviate the need
to create the hash and do the lookup on the fly in transmit.

Note that this is an opportunistic optimization, there is no
separate negotiation between the stack and driver/device for
the hash used in either TX or RX.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 3 ++-
 include/net/sock.h     | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1bb36ed..f792a0d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -605,7 +605,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+	__u8			reflect_hash:1;
+	/* 2 or 4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/net/sock.h b/include/net/sock.h
index e138245..133fc51 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -871,6 +871,8 @@ static inline void sock_rps_save_rxhash(struct sock *sk,
 	if (unlikely(sk->sk_rxhash != skb->hash))
 		sk->sk_rxhash = skb->hash;
 #endif
+	if (unlikely(skb->reflect_hash && sk->sk_txhash != skb->hash))
+		sk->sk_txhash = skb->hash;
 }
 
 static inline void sock_rps_reset_rxhash(struct sock *sk)
-- 
2.2.0.rc0.207.ga3a616c
