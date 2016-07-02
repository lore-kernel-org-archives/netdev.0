From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2] geneve: fix max_mtu setting
Date: Sat,  2 Jul 2016 15:02:48 +0800
Message-ID: <1467442968-13723-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ipv6+udp+geneve encapsulation data, the max_mtu should subtract
sizeof(ipv6hdr), instead of sizeof(iphdr).

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
Changes in v2:
   - As suggested by Jesse Gross, treat AF_UNSPEC same as AF_INET4 to
avoid disallowing potentially valid configrations.
---
 drivers/net/geneve.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 310e0b9c..5de892f 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1036,12 +1036,17 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int __geneve_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 {
+	struct geneve_dev *geneve = netdev_priv(dev);
 	/* The max_mtu calculation does not take account of GENEVE
 	 * options, to avoid excluding potentially valid
 	 * configurations.
 	 */
-	int max_mtu = IP_MAX_MTU - GENEVE_BASE_HLEN - sizeof(struct iphdr)
-		- dev->hard_header_len;
+	int max_mtu = IP_MAX_MTU - GENEVE_BASE_HLEN - dev->hard_header_len;
+
+	if (geneve->remote.sa.sa_family == AF_INET6)
+		max_mtu -= sizeof(struct ipv6hdr);
+	else
+		max_mtu -= sizeof(struct iphdr);
 
 	if (new_mtu < 68)
 		return -EINVAL;
-- 
1.8.3.1
