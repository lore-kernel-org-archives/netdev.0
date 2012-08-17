From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc probe
Date: Fri, 17 Aug 2012 15:11:38 +0800
Message-ID: <1345187499-16929-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202Ab2HQHMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 03:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rt6_probe(), we call ndisc_send_ns() with root->rwlock,
but this is not necessary, so we can drop it before calling
ndisc_send_ns().

This could probably fix the deadlock reported by Debabrata:
https://lkml.org/lkml/2012/8/16/432

Reported-by: "Banerjee, Debabrata" <dbanerje@akamai.com>
Cc: "Banerjee, Debabrata" <dbanerje@akamai.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/route.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0ddf2d1..7a36df2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -460,13 +460,18 @@ static void rt6_probe(struct rt6_info *rt)
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
+		struct net_device *dev = rt->dst.dev;
+		struct fib6_table *table = rt->rt6i_table;
 
 		neigh->updated = jiffies;
 		read_unlock_bh(&neigh->lock);
+		read_unlock_bh(&table->tb6_lock);
 
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
+		ndisc_send_ns(dev, NULL, target, &mcaddr, NULL);
+
+		read_lock_bh(&table->tb6_lock);
 	} else {
 		read_unlock_bh(&neigh->lock);
 	}
-- 
1.7.7.6
