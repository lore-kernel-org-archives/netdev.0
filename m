From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V1 3/3] net: warn on napi_alloc_skb being called in
 wrong context
Date: Mon, 09 May 2016 15:44:39 +0200
Message-ID: <20160509134439.3573.97841.stgit@firesoul>
References: <20160509134352.3573.37044.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, gerlitz.or@gmail.com, eugenia@mellanox.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbcEINol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 09:44:41 -0400
In-Reply-To: <20160509134352.3573.37044.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It have always been required to call napi_alloc_skb from NAPI/softirq
context, which implies running with local_bh_disable'ed.  Thus, this
code path should already be well tested. But recent SKB bulk changes
introduced will make this more volatile and bugs more subtle, if this
is violated.

To catch any driver violating this add a loud WARN_ON.

Performance wise, I do worry about adding this runtime check code into
the hotpath, of this highly optimized function call.  I've
micro-benchmarked it with both IP-forwarding and local UDP delivery,
and didn't see any regressions.  It does adds extra code size (icache).

add/remove: 0/0 grow/shrink: 1/0 up/down: 43/0 (43)
function                                     old     new   delta
__napi_alloc_skb                             461     504     +43

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/skbuff.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e85f1065b263..99addbf66f2e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -498,6 +498,9 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	struct sk_buff *skb;
 	void *data;
 
+	/* Catch drivers violating, not having local BH disabled */
+	WARN_ON(!in_softirq());
+
 	len += NET_SKB_PAD + NET_IP_ALIGN;
 
 	if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
