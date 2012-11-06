From: Eric Leblond <eric@regit.org>
Subject: [PATCH 1/1] af-packet: fix oops when socket is not present
Date: Tue,  6 Nov 2012 11:24:41 +0100
Message-ID: <1352197481-16782-2-git-send-email-eric@regit.org>
References: <1352197481-16782-1-git-send-email-eric@regit.org>
Cc: stable@vger.kernel.org, Eric Leblond <eric@regit.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:48868 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab2KFLDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:03:19 -0500
In-Reply-To: <1352197481-16782-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When skb->sk is NULL and when packet fanout is used, there is a
crash in match_fanout_group where skb->sk is accessed.
This patch fixes the issue by returning false as soon as the
socket is NULL: this correspond to the wanted behavior because
the kernel as to resend the skb to all the listening socket in
this case.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..c7b5293 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1666,7 +1666,7 @@ static inline int deliver_skb(struct sk_buff *skb,
 
 static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
 {
-	if (ptype->af_packet_priv == NULL)
+	if ((ptype->af_packet_priv == NULL) || (skb->sk == NULL))
 		return false;
 
 	if (ptype->id_match)
-- 
1.7.10.4
