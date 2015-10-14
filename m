From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: move fragment importance field to new header position
Date: Wed, 14 Oct 2015 09:49:28 -0400
Message-ID: <1444830568-5048-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:34443 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbbJNNuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 09:50:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit e3eea1eb47a ("tipc: clean up handling of message priorities")
we introduced a field in the packet header for keeping track of the
priority of fragments, since this value is not present in the specified
protocol header. Since the value so far only is used at the transmitting
end of the link, we have not yet officially defined it as part of the
protocol.

Unfortunately, the field we use for keeping this value, bits 13-15 in
in word 5, has turned out to be a poor choice; it is already used by the
broadcast protocol for carrying the 'network id' field of the sending
node. Since packet fragments also need to be transported across the
broadcast protocol, the risk of conflict is obvious, and we see this
happen when we use network identities larger than 2^13-1. This has
escaped our testing because we have so far only been using small network
id values.

We now move this field to bits 0-2 in word 9, a field that is guaranteed
to be unused by all involved protocols.

Fixes: e3eea1eb47a ("tipc: clean up handling of message priorities")
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index a82c584..5351a3f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -357,7 +357,7 @@ static inline u32 msg_importance(struct tipc_msg *m)
 	if (likely((usr <= TIPC_CRITICAL_IMPORTANCE) && !msg_errcode(m)))
 		return usr;
 	if ((usr == MSG_FRAGMENTER) || (usr == MSG_BUNDLER))
-		return msg_bits(m, 5, 13, 0x7);
+		return msg_bits(m, 9, 0, 0x7);
 	return TIPC_SYSTEM_IMPORTANCE;
 }
 
@@ -366,7 +366,7 @@ static inline void msg_set_importance(struct tipc_msg *m, u32 i)
 	int usr = msg_user(m);
 
 	if (likely((usr == MSG_FRAGMENTER) || (usr == MSG_BUNDLER)))
-		msg_set_bits(m, 5, 13, 0x7, i);
+		msg_set_bits(m, 9, 0, 0x7, i);
 	else if (i < TIPC_SYSTEM_IMPORTANCE)
 		msg_set_user(m, i);
 	else
-- 
1.9.1
