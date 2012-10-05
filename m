From: ramesh.nagappa@gmail.com
Subject: [PATCH] net: Fix skb_under_panic oops in neigh_resolve_output
Date: Thu,  4 Oct 2012 20:05:25 -0700
Message-ID: <1349406325-3157-1-git-send-email-ramesh.nagappa@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, ebiederm@xmission.com,
	xemul@parallels.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Ramesh Nagappa <ramesh.nagappa@ericsson.com>
To: bnramesh@yahoo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ramesh Nagappa <ramesh.nagappa@ericsson.com>

The retry loop in neigh_resolve_output() and neigh_connected_output()
call dev_hard_header() with out reseting the skb to network_header.
This causes the retry to fail with skb_under_panic. The fix is to
reset the network_header within the retry loop.

Signed-off-by: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
Reviewed-by: Shawn Lu <shawn.lu@ericsson.com>
Reviewed-by: Robert Coulson <robert.coulson@ericsson.com>
Reviewed-by: Billie Alsup <billie.alsup@ericsson.com>
---
 net/core/neighbour.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 117afaf..f50c542 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1313,6 +1313,7 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 
 		do {
 			seq = read_seqbegin(&neigh->ha_lock);
+			__skb_pull(skb, skb_network_offset(skb));
 			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
 					      neigh->ha, NULL, skb->len);
 		} while (read_seqretry(&neigh->ha_lock, seq));
@@ -1342,10 +1343,9 @@ int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb)
 	unsigned int seq;
 	int err;
 
-	__skb_pull(skb, skb_network_offset(skb));
-
 	do {
 		seq = read_seqbegin(&neigh->ha_lock);
+		__skb_pull(skb, skb_network_offset(skb));
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
 				      neigh->ha, NULL, skb->len);
 	} while (read_seqretry(&neigh->ha_lock, seq));
-- 
1.7.11.4
