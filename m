From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] cxgb4: Save the correct mac addr for hw-loopback connections
	in the L2T
Date: Mon, 14 Apr 2014 14:22:43 -0500
Message-ID: <20140414192243.13234.46587.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:54360 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbaDNTWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 15:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware needs the local device mac address to support hw loopback for
rdma loopback connections.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/ethernet/chelsio/cxgb4/l2t.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 81e8402..8a96572 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -154,7 +154,7 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 	req->params = htons(L2T_W_PORT(e->lport) | L2T_W_NOREPLY(!sync));
 	req->l2t_idx = htons(e->idx);
 	req->vlan = htons(e->vlan);
-	if (e->neigh)
+	if (e->neigh && !(e->neigh->dev->flags & IFF_LOOPBACK))
 		memcpy(e->dmac, e->neigh->ha, sizeof(e->dmac));
 	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
 
@@ -394,6 +394,8 @@ struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
 	if (e) {
 		spin_lock(&e->lock);          /* avoid race with t4_l2t_free */
 		e->state = L2T_STATE_RESOLVING;
+		if (neigh->dev->flags & IFF_LOOPBACK)
+			memcpy(e->dmac, physdev->dev_addr, sizeof(e->dmac));
 		memcpy(e->addr, addr, addr_len);
 		e->ifindex = ifidx;
 		e->hash = hash;
