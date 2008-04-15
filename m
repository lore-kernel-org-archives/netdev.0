From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 6/7 net-2.6.26] [TIPC]: Force linearization of non-linear sk_buffs
Date: Tue, 15 Apr 2008 15:43:56 -0400
Message-ID: <1208288637-15304-7-git-send-email-allan.stephens@windriver.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46963 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655AbYDOTpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:55 -0400
In-Reply-To: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows TIPC to process incoming messages that are
stored in a fragmented sk_buff, by forcing the linearization
of any such messages it receives.

Note: This is an interim solution to allow TIPC to operate with
Ethernet devices that generate non-linear buffers (such as the
gianfar driver), until such time as the rest of TIPC is enhanced
to handle sk_buffs with multiple data areas.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |   12 ++++++++++++
 net/tipc/link.c |    6 ++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index b3c9df3..325404f 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -337,4 +337,16 @@ static inline void buf_discard(struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+/**
+ * buf_linearize - convert a TIPC message buffer into a single contiguous piece
+ * @skb: message buffer
+ *
+ * Returns 0 on success.
+ */
+
+static inline int buf_linearize(struct sk_buff *skb)
+{
+	return skb_linearize(skb);
+}
+
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a42f434..0873793 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1811,6 +1811,12 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 #endif
 			msg_dbg(msg,"<REC<");
 
+		/* Ensure message data is a single contiguous unit */
+
+		if (unlikely(buf_linearize(buf))) {
+			goto cont;
+		}
+
 		if (unlikely(msg_non_seq(msg))) {
 			link_recv_non_seq(buf);
 			continue;
-- 
1.5.3.2

