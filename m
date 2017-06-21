From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 2/2] ip6mr: restrict mroute6 "queue full" warning to related error values
Date: Wed, 21 Jun 2017 10:58:11 -0700
Message-ID: <20170621175811.16940-2-julien@arista.com>
References: <20170621175811.16940-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621175811.16940-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sending a cache report on mroute6_sk, mroute6 will emit a
"pending queue full" warning for every error value returned by
sock_queue_rcv_skb().
This warning can be misleading, for example on the EPERM error value
that sk_filter() can return.

Restricting this warning to only ENOMEM or ENOBUFS seems more
appropriate.

Signed-off-by: Julien Gomes <julien@arista.com>
---
 net/ipv6/ip6mr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7454850f2098..62fe5fd64f22 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1215,7 +1215,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 	 */
 	ret = sock_queue_rcv_skb(mrt->mroute6_sk, skb);
 	if (ret < 0) {
-		net_warn_ratelimited("mroute6: pending queue full, dropping entries\n");
+		if (ret == -ENOMEM || ret == -ENOBUFS)
+			net_warn_ratelimited("mroute6: pending queue full, dropping entries\n");
 		kfree_skb(skb);
 	}
 
-- 
2.13.1
