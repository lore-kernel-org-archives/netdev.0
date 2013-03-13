From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH v3.4-stable] myri10ge: Restrict LRO max_aggr based on MTU
Date: Wed, 13 Mar 2013 14:46:45 -0400
Message-ID: <1363200405-17839-1-git-send-email-gallatin@myri.com>
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a longstanding panic when myri10ge would configure
lro_mgr->max_aggr wrong, so that lro could aggregate more than
MAX_SKB_FRAGS frags when jumbo frames (which consume multiple frags)
are used.

To fix this, we determine the frags per packet in excess of MAX_SKB_FRAGS
for the current MTU, and subtract those extra frags from MAX_SKB_FRAGS
when configuring lro_mgr->max_aggr to ensure that MAX_SKB_FRAGS will not
be exceeded.

This does not apply to the mainline, because LRO was removed from
myri10ge when it was converted to use GRO in 4ca3221 (appeared in 3.8).
It should probably be merged to all active stable kernels prior to
3.8, since it fixes a panic.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 27273ae..99fa774 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -2406,7 +2406,7 @@ static int myri10ge_open(struct net_device *dev)
 	struct myri10ge_slice_state *ss;
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
-	int i, status, big_pow2, slice;
+	int i, status, big_pow2, slice, extra_frags;
 	u8 *itable;
 	struct net_lro_mgr *lro_mgr;
 
@@ -2529,8 +2529,10 @@ static int myri10ge_open(struct net_device *dev)
 		lro_mgr->get_frag_header = myri10ge_get_frag_header;
 		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
 		lro_mgr->frag_align_pad = 2;
-		if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
-			lro_mgr->max_aggr = MAX_SKB_FRAGS;
+		extra_frags = (dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD) /
+			      MYRI10GE_ALLOC_SIZE;
+		if (lro_mgr->max_aggr > MAX_SKB_FRAGS - extra_frags)
+			lro_mgr->max_aggr = MAX_SKB_FRAGS - extra_frags;
 
 		/* must happen prior to any irq */
 		napi_enable(&(ss)->napi);
-- 
1.7.9.5
