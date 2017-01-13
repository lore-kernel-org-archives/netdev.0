From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netlink: do not enter direct reclaim from
 netlink_trim()
Date: Fri, 13 Jan 2017 09:11:22 -0800
Message-ID: <1484327482.13165.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34225 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdAMRL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:11:29 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so9175357pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 09:11:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit d35c99ff77ecb ("netlink: do not enter direct reclaim from
netlink_dump()") we made sure to not trigger expensive memory reclaim.

Problem is that a bit later, netlink_trim() might be called and
trigger memory reclaim.

netlink_trim() should be best effort, and really as fast as possible.
Under memory pressure, it is fine to not trim this skb.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netlink/af_netlink.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 161b628ab2b08bf4321dbe617022c4c50486534d..edcc1e19ad532641f51f6809b8c90d1e377081ff 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1210,7 +1210,9 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 		skb = nskb;
 	}
 
-	if (!pskb_expand_head(skb, 0, -delta, allocation))
+	if (!pskb_expand_head(skb, 0, -delta,
+			      (allocation & ~__GFP_DIRECT_RECLAIM) |
+			      __GFP_NOWARN | __GFP_NORETRY))
 		skb->truesize -= delta;
 
 	return skb;
