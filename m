From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] netlink: Warn on unordered or illegal nla_nest_cancel() or nlmsg_cancel()
Date: Tue,  6 Jan 2015 01:04:21 +0100
Message-ID: <c0e7aa02ab55b7a810eee7d51839a139a833cfb3.1420502617.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50003 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbAFAEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 19:04:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling nla_nest_cancel() in a different order as the nesting was
built up can lead to negative offsets being calculated which
results in skb_trim() being called with an underflowed unsigned
int. Warn if mark < skb->data as it's definitely a bug.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/netlink.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 6415835..d5869b9 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -520,8 +520,10 @@ static inline void *nlmsg_get_pos(struct sk_buff *skb)
  */
 static inline void nlmsg_trim(struct sk_buff *skb, const void *mark)
 {
-	if (mark)
+	if (mark) {
+		WARN_ON((unsigned char *) mark < skb->data);
 		skb_trim(skb, (unsigned char *) mark - skb->data);
+	}
 }
 
 /**
-- 
1.9.3
