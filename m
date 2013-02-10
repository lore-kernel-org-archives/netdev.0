From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [net-next (TAKE 2) 1/4] firewire net: Accept IPv4 and ARP only.
Date: Sun, 10 Feb 2013 18:02:10 +0900
Message-ID: <51176212.7080907@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, stefanr@s5r6.in-berlin.de, davem@davemloft.net
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2b27bff..a748790 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -517,6 +517,14 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	int status;
 	__be64 guid;
 
+	switch (ether_type) {
+	case ETH_P_ARP:
+	case ETH_P_IP:
+		break;
+	default:
+		goto err;
+	}
+
 	dev = netdev_priv(net);
 	/* Write metadata, and then pass to the receive level */
 	skb->dev = net;
@@ -653,6 +661,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	return 0;
 
  no_peer:
+ err:
 	net->stats.rx_errors++;
 	net->stats.rx_dropped++;
 
@@ -1299,9 +1308,17 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	 * We might need to rebuild the header on tx failure.
 	 */
 	memcpy(&hdr_buf, skb->data, sizeof(hdr_buf));
-	skb_pull(skb, sizeof(hdr_buf));
-
 	proto = hdr_buf.h_proto;
+
+	switch (proto) {
+	case htons(ETH_P_ARP):
+	case htons(ETH_P_IP):
+		break;
+	default:
+		goto fail;
+	}
+
+	skb_pull(skb, sizeof(hdr_buf));
 	dg_size = skb->len;
 
 	/*
-- 
1.7.9.5



------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
