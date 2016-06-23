From: Abdelrhman Ahmed <ab@abahmed.com>
Subject: [PATCH] net: Fix resetting network_header in neigh_resolve_output
 and neigh_connected_output
Date: Thu, 23 Jun 2016 13:39:24 +0200
Message-ID: <1557d0eb9b5.10e107ce3332041.1418466288700186568@abahmed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>
To: "davem" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

neigh_resolve_output and neigh_connected_output resets the skb to network_header because of the retry loop and this reset will pull down the data pointer to the network header in the first iteration then hardware header will be added, but it will overwrite any data which is inserted between network header and hardware header (for example by netfilter hooks) only for the first packet(s) before using cached hardware header as neigh_hh_output (which is called for using cached hardware header) does not reset to the network header.

The fix is to reset with reference to skb's data before loop instead of network header.

Fixes: e1f165032c8b ("net: Fix skb_under_panic oops in neigh_resolve_output")
Signed-off-by: Abdelrhman Ahmed <ab@abahmed.com>
---
 net/core/neighbour.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 29dd8cc..7aac242 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1293,15 +1293,19 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
 	int rc = 0;
 
 	if (!neigh_event_send(neigh, skb)) {
-		int err;
+		int err, offset;
 		struct net_device *dev = neigh->dev;
+		unsigned char *data;
 		unsigned int seq;
 
 		if (dev->header_ops->cache && !neigh->hh.hh_len)
 			neigh_hh_init(neigh);
 
+		data = skb->data;
+
 		do {
-			__skb_pull(skb, skb_network_offset(skb));
+			offset = data - skb->data;
+			__skb_pull(skb, offset);
 			seq = read_seqbegin(&neigh->ha_lock);
 			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
 					      neigh->ha, NULL, skb->len);
@@ -1326,11 +1330,15 @@ EXPORT_SYMBOL(neigh_resolve_output);
 int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb)
 {
 	struct net_device *dev = neigh->dev;
+	unsigned char *data;
 	unsigned int seq;
-	int err;
+	int err, offset;
+
+	data = skb->data;
 
 	do {
-		__skb_pull(skb, skb_network_offset(skb));
+		offset = data - skb->data;
+		__skb_pull(skb, offset);
 		seq = read_seqbegin(&neigh->ha_lock);
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
 				      neigh->ha, NULL, skb->len);
-- 
1.9.1
