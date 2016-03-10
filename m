From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V3 1/3] net: adjust napi_consume_skb to handle
 none-NAPI callers
Date: Thu, 10 Mar 2016 15:59:11 +0100
Message-ID: <20160310145911.22901.28762.stgit@firesoul>
References: <20160310145803.22901.24734.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, eugenia@mellanox.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbcCJO7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 09:59:16 -0500
In-Reply-To: <20160310145803.22901.24734.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers reuse/share code paths that free SKBs between NAPI
and none-NAPI calls. Adjust napi_consume_skb to handle this
use-case.

Before, calls from netpoll (w/ IRQs disabled) was handled and
indicated with a budget zero indication.  Use the same zero
indication to handle calls not originating from NAPI/softirq.
Simply handled by using dev_consume_skb_any().

This adds an extra branch+call for the netpoll case (checking
in_irq() + irqs_disabled()), but that is okay as this is a slowpath.

Suggested-by: Alexander Duyck <aduyck@mirantis.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/skbuff.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7af7ec635d90..bc62baa54ceb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -801,9 +801,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 	if (unlikely(!skb))
 		return;
 
-	/* if budget is 0 assume netpoll w/ IRQs disabled */
+	/* Zero budget indicate none-NAPI context called us, like netpoll */
 	if (unlikely(!budget)) {
-		dev_consume_skb_irq(skb);
+		dev_consume_skb_any(skb);
 		return;
 	}
 
