From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,2/3] hv_netvsc: Define a macro RNDIS_AND_PPI_SIZE
Date: Mon,  6 Apr 2015 15:22:53 -0700
Message-ID: <1428358974-7958-2-git-send-email-haiyangz@microsoft.com>
References: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The sum of RNDIS msg and PPI struct sizes is used in multiple places, so we define
a macro for them.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    6 ++++++
 drivers/net/hyperv/netvsc_drv.c |   15 +++------------
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 95a25e4..80bc52e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -958,6 +958,10 @@ struct ndis_tcp_lso_info {
 #define NDIS_HASH_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
 		sizeof(u32))
 
+/* Total size of all PPI data */
+#define NDIS_ALL_PPI_SIZE (NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE + \
+			   NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE)
+
 /* Format of Information buffer passed in a SetRequest for the OID */
 /* OID_GEN_RNDIS_CONFIG_PARAMETER. */
 struct rndis_config_parameter_info {
@@ -1170,6 +1174,8 @@ struct rndis_message {
 #define RNDIS_HEADER_SIZE	(sizeof(struct rndis_message) - \
 				 sizeof(union rndis_message_container))
 
+#define RNDIS_AND_PPI_SIZE (sizeof(struct rndis_message) + NDIS_ALL_PPI_SIZE)
+
 #define NDIS_PACKET_TYPE_DIRECTED	0x00000001
 #define NDIS_PACKET_TYPE_MULTICAST	0x00000002
 #define NDIS_PACKET_TYPE_ALL_MULTICAST	0x00000004
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f9db6bc..73f8fba 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -401,10 +401,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		return NETDEV_TX_OK;
 	}
 
-	pkt_sz = sizeof(struct hv_netvsc_packet) +
-			sizeof(struct rndis_message) +
-			NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
-			NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
+	pkt_sz = sizeof(struct hv_netvsc_packet) + RNDIS_AND_PPI_SIZE;
 
 	if (head_room < pkt_sz) {
 		packet = kmalloc(pkt_sz, GFP_ATOMIC);
@@ -436,11 +433,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	packet->rndis_msg = (struct rndis_message *)((unsigned long)packet +
 				sizeof(struct hv_netvsc_packet));
 
-	memset(packet->rndis_msg, 0, sizeof(struct rndis_message) +
-					NDIS_VLAN_PPI_SIZE +
-					NDIS_CSUM_PPI_SIZE +
-					NDIS_LSO_PPI_SIZE +
-					NDIS_HASH_PPI_SIZE);
+	memset(packet->rndis_msg, 0, RNDIS_AND_PPI_SIZE);
 
 	/* Set the completion routine */
 	packet->send_completion = netvsc_xmit_completion;
@@ -872,9 +865,7 @@ static int netvsc_probe(struct hv_device *dev,
 		return -ENOMEM;
 
 	max_needed_headroom = sizeof(struct hv_netvsc_packet) +
-				sizeof(struct rndis_message) +
-				NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
-				NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
+			      RNDIS_AND_PPI_SIZE;
 
 	netif_carrier_off(net);
 
-- 
1.7.4.1
