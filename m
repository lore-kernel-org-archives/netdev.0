From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 1/2] ipmr: restrict mroute "queue full" warning to related error values
Date: Wed, 21 Jun 2017 10:58:10 -0700
Message-ID: <20170621175811.16940-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sending a cache report on mroute_sk, mroute will emit a
"pending queue full" warning for every error value returned by
sock_queue_rcv_skb().
This warning can be misleading, for example on the EPERM error value
that sk_filter() can return.

Restricting this warning to only ENOMEM or ENOBUFS seems more
appropriate.

Signed-off-by: Julien Gomes <julien@arista.com>
---
 net/ipv4/ipmr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a1d521be612b..ace12cddb9de 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1068,7 +1068,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	ret = sock_queue_rcv_skb(mroute_sk, skb);
 	rcu_read_unlock();
 	if (ret < 0) {
-		net_warn_ratelimited("mroute: pending queue full, dropping entries\n");
+		if (ret == -ENOMEM || ret == -ENOBUFS)
+			net_warn_ratelimited("mroute: pending queue full, dropping entries\n");
 		kfree_skb(skb);
 	}
 
-- 
2.13.1
