From: David Miller <davem@davemloft.net>
Subject: [PATCH] infiniband: addr: Avoid unnecessary neigh lookup.
Date: Fri, 02 Dec 2011 14:55:25 -0500 (EST)
Message-ID: <20111202.145525.1679807360238725746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab1LBTz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 14:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The explicit neigh_lookup() in addr4_resolve() is unnecessary because this
is the exact same calculation the routing code already made to attach the
neigh to the route.

Therefore, just use dst_get_neighbour().

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Roland, I'm auditing all of the uses of dst_get_neighbour() with the
end result being that a dst_put_neighbour() interface will be added
and all access will be reduced to quick:

	rcu_read_lock();
	n = dst_get_neighbour();
	...
	dst_put_neighbour();
	rcu_read_unlock();

sequences.  And then, at the next step, things will be further
whittled down into a refcount-less variant:

	rcu_read_lock();
	n = dst_get_neighbour_noref();
	...
	rcu_read_unlock();

Another key difference is that we are making the code able to handle
dst_get_neighbour() returning NULL.

So if it's OK with you I'd like to merge this stuff directly in the
net-next tree after getting your ACK on each patch.

In the case here, the neigh_lookup() call is spurious and is exactly
mimicking the neigh lookup that the ipv4 routing code does to attach
the neighbour to the route.  There is no need to duplicate that
operation, and we can thus use the route attached neigh directly.

 drivers/infiniband/core/addr.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index a20c3c8..83d88e1 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -214,20 +214,19 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 		goto put;
 	}
 
-	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
-	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		rcu_read_lock();
-		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
-		rcu_read_unlock();
-		ret = -ENODATA;
-		if (neigh)
-			goto release;
-		goto put;
+	rcu_read_lock();
+	neigh = dst_get_neighbour(&rt->dst);
+	ret = -ENODATA;
+	if (!neigh)
+		goto unlock_put;
+	if (!(neigh->nud_state & NUD_VALID)) {
+		neigh_event_send(neigh, NULL);
+		goto unlock_put;
 	}
 
 	ret = rdma_copy_addr(addr, neigh->dev, neigh->ha);
-release:
-	neigh_release(neigh);
+unlock_put:
+	rcu_read_unlock();
 put:
 	ip_rt_put(rt);
 out:
-- 
1.7.7.3
