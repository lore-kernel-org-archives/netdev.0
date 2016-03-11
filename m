From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V4 1/3] net: adjust napi_consume_skb to handle
 non-NAPI callers
Date: Fri, 11 Mar 2016 09:43:58 +0100
Message-ID: <20160311084358.5207.54143.stgit@firesoul>
References: <20160311084245.5207.70640.stgit@firesoul>
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
Received: from mx1.redhat.com ([209.132.183.28]:36285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935408AbcCKIoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 03:44:04 -0500
In-Reply-To: <20160311084245.5207.70640.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers reuse/share code paths that free SKBs between NAPI
and non-NAPI calls. Adjust napi_consume_skb to handle this
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
index 7af7ec635d90..cf63a6000405 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -801,9 +801,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 	if (unlikely(!skb))
 		return;
 
-	/* if budget is 0 assume netpoll w/ IRQs disabled */
+	/* Zero budget indicate non-NAPI context called us, like netpoll */
 	if (unlikely(!budget)) {
-		dev_consume_skb_irq(skb);
+		dev_consume_skb_any(skb);
 		return;
 	}
 
