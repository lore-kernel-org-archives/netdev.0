From: ganesh.venkatesan@intel.com
Subject: [PATCH 4/12 2.4] e1000 - TSO fixes (in preparation for IPv6 TSO)
Date: Thu, 29 Jul 2004 08:29:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290728090.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -1475,8 +1475,9 @@ e1000_tso(struct e1000_adapter *adapter,
 #ifdef NETIF_F_TSO
 	struct e1000_context_desc *context_desc;
 	unsigned int i;
-	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	uint32_t cmd_length = 0;
 	uint16_t ipcse, tucse, mss;
+	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 
 	if(skb_shinfo(skb)->tso_size) {
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
@@ -1495,6 +1496,10 @@ e1000_tso(struct e1000_adapter *adapter,
 		tucso = (void *)&(skb->h.th->check) - (void *)skb->data;
 		tucse = 0;
 
+		cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
+			       E1000_TXD_CMD_IP | E1000_TXD_CMD_TCP |
+			       (skb->len - (hdr_len)));
+
 		i = adapter->tx_ring.next_to_use;
 		context_desc = E1000_CONTEXT_DESC(adapter->tx_ring, i);
 
@@ -1506,10 +1511,7 @@ e1000_tso(struct e1000_adapter *adapter,
 		context_desc->upper_setup.tcp_fields.tucse = cpu_to_le16(tucse);
 		context_desc->tcp_seg_setup.fields.mss     = cpu_to_le16(mss);
 		context_desc->tcp_seg_setup.fields.hdr_len = hdr_len;
-		context_desc->cmd_and_length = cpu_to_le32(
-			E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
-			E1000_TXD_CMD_IP | E1000_TXD_CMD_TCP |
-			(skb->len - (hdr_len)));
+		context_desc->cmd_and_length = cpu_to_le32(cmd_length);
 
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
@@ -1526,17 +1551,16 @@ e1000_tx_csum(struct e1000_adapter *adap
 {
 	struct e1000_context_desc *context_desc;
 	unsigned int i;
-	uint8_t css, cso;
+	uint8_t css;
 
 	if(skb->ip_summed == CHECKSUM_HW) {
 		css = skb->h.raw - skb->data;
-		cso = (skb->h.raw + skb->csum) - skb->data;
 
 		i = adapter->tx_ring.next_to_use;
 		context_desc = E1000_CONTEXT_DESC(adapter->tx_ring, i);
 
 		context_desc->upper_setup.tcp_fields.tucss = css;
-		context_desc->upper_setup.tcp_fields.tucso = cso;
+		context_desc->upper_setup.tcp_fields.tucso = css + skb->csum;
 		context_desc->upper_setup.tcp_fields.tucse = 0;
 		context_desc->tcp_seg_setup.data = 0;
 		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);
