From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v3 3/4] net: use skb->priority for overloading skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 19:52:03 +0200
Message-ID: <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
Cc: edumazet@google.com, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:62011 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbBWRwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 12:52:21 -0500
Received: by mail-wi0-f177.google.com with SMTP id bs8so19454523wib.4
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 09:52:20 -0800 (PST)
In-Reply-To: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
unionized skb->mark and skb->dropcount in order to allow recording
of the socket drop count while maintaining struct sk_buff size.

In order to allow for the skb->mark to be fetched by user-space code
it needs to be detached from this union; skb->priority is used
instead.

The purpose of overloading skb->priority is solely for retaining
struct sk_buff size; skb->priority is not used after the skb is
queued to the socket.

Use of aliased fields, skb->dropcount and skb->reserved_tailroom,
is either done after the skb is cloned (e.g. in packet_rcv()) or
before skb->priority is used (e.g. in IGMPv3/MLD/TCP).

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/linux/skbuff.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d898b32..23e77cb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -625,7 +625,7 @@ struct sk_buff {
 			__u16	csum_offset;
 		};
 	};
-	__u32			priority;
+	__u32			mark;
 	int			skb_iif;
 	__u32			hash;
 	__be16			vlan_proto;
@@ -640,7 +640,7 @@ struct sk_buff {
 	__u32			secmark;
 #endif
 	union {
-		__u32		mark;
+		__u32		priority;
 		__u32		dropcount;
 		__u32		reserved_tailroom;
 	};
-- 
2.1.4
