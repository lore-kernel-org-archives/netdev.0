From: wen xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver - patch for
	big-endian systems
Date: Thu, 24 Aug 2006 15:36:50 -0500
Message-ID: <1156451811.13196.132.camel@wendyx.austin.ibm.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
	 <Pine.LNX.4.64.0608220038580.18115@dut46>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-QfnU/X/xatNSrh0/s+GQ"
Cc: netdev@vger.kernel.org, "jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	Rob Mapes <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:39398 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1422649AbWHXUo1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 16:44:27 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7OKiQSo020831
	for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 16:44:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7OKiQ5J264814
	for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 14:44:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7OKiPNj026254
	for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 14:44:26 -0600
To: Pradeep Dalvi <pradeep@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0608220038580.18115@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QfnU/X/xatNSrh0/s+GQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Hi All,

This patch brings the NetXen Ethernet driver to work on big-endian
systems. I have tested this patch on difference platforms including
little-endian and big-endian systems. The patch included:
(1)transmit and receive descriptors endian issue fix.
(2)MAC address endian issue fix.

This patch can apply to the recently NetXen driver submission patches.

If you have any questions and comments, please let me know.
Thank for your help!
wendy

Signed-off-by : Wen Xiong <wendyx@us.ibm.com>

On Tue, 2006-08-22 at 00:43 -0700, Pradeep Dalvi wrote:
> Hi,
> 
> This updated patch with name prefix changes is available for download at,
> http://www.netxen.com/products/downloads/netxen-2.6.17.patch.zip
> 
> Thanks and regards,
> pradeep
> 


--=-QfnU/X/xatNSrh0/s+GQ
Content-Disposition: attachment; filename=ppc-patch
Content-Type: text/x-patch; name=ppc-patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Nuar old/drivers/net/netxen/netxen_nic_hw.c new/drivers/net/netxen/netxen_nic_hw.c
--- old/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 12:58:43.000000000 -0500
+++ new/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 13:15:19.000000000 -0500
@@ -313,7 +313,8 @@
 		}
 	}
 	CMD_DESC_TCP_HDR_OFFSET_WRT(desc, skb->h.raw - skb->data);
-	desc->ip_hdr_offset = skb->nh.raw - skb->data;
+	desc->length_tcp_hdr=cpu_to_le32(desc->length_tcp_hdr);
+	desc->ip_hdr_offset  = skb->nh.raw - skb->data;
 	adapter->stats.xmitcsummed++;
 }
 
diff -Nuar old/drivers/net/netxen/netxen_nic_init.c new/drivers/net/netxen/netxen_nic_init.c
--- old/drivers/net/netxen/netxen_nic_init.c	2006-08-23 12:58:43.000000000 -0500
+++ new/drivers/net/netxen/netxen_nic_init.c	2006-08-23 13:15:19.000000000 -0500
@@ -494,7 +494,7 @@
 		desc_head = recv_ctx->rcv_status_desc_head;
 		desc = &desc_head[consumer];
 
-		if ((desc->owner & STATUS_OWNER_HOST))
+		if (((le16_to_cpu(desc->owner)) & STATUS_OWNER_HOST))
 			return 1;
 	}
 
@@ -540,12 +540,12 @@
 	struct netxen_port *port = adapter->port[STATUS_DESC_PORT(desc)];
 	struct pci_dev *pdev = port->pdev;
 	struct net_device *netdev = port->netdev;
-	int index = __le16_to_cpu(desc->reference_handle);
+	int index = le16_to_cpu(desc->reference_handle);
 	struct netxen_recv_context *recv_ctx =
 	    &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = __le16_to_cpu(desc->total_length);
+	u16 length = le16_to_cpu(desc->total_length);
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
@@ -640,7 +640,7 @@
 	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
-		if (!(desc->owner & STATUS_OWNER_HOST)) {
+		if (!((le16_to_cpu(desc->owner)) & STATUS_OWNER_HOST)) {
 			DPRINTK(ERR, "desc %p ownedby %x\n", desc, desc->owner);
 			break;
 		}
@@ -832,9 +832,9 @@
 					     rcv_desc->dma_size,
 					     PCI_DMA_FROMDEVICE);
 		/* make a rcv descriptor  */
-		pdesc->reference_handle = __cpu_to_le16(buffer->ref_handle);
-		pdesc->buffer_length = __cpu_to_le16(rcv_desc->dma_size);
-		pdesc->addr_buffer = __cpu_to_le64(buffer->dma);
+		pdesc->reference_handle = le16_to_cpu(buffer->ref_handle);
+		pdesc->buffer_length = le16_to_cpu(rcv_desc->dma_size);
+		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 		DPRINTK(INFO, "done writing descripter\n");
 		producer =
 		    get_next_index(producer, rcv_desc->max_rx_desc_count);
diff -Nuar old/drivers/net/netxen/netxen_nic_main.c new/drivers/net/netxen/netxen_nic_main.c
--- old/drivers/net/netxen/netxen_nic_main.c	2006-08-23 12:58:43.000000000 -0500
+++ new/drivers/net/netxen/netxen_nic_main.c	2006-08-23 13:15:19.000000000 -0500
@@ -746,8 +746,8 @@
 	hwdesc->opcode = TX_ETHER_PKT;
 
 	CMD_DESC_PORT_WRT(hwdesc, port->portnum);
-	hwdesc->buffer1_length = __cpu_to_le16(first_seg_len);
-	hwdesc->addr_buffer1 = __cpu_to_le64(buffrag->dma);
+	hwdesc->buffer1_length = cpu_to_le16(first_seg_len);
+	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
 	for (i = 1, k = 1; i < frag_count; i++, k++) {
 		struct skb_frag_struct *frag;
@@ -778,20 +778,20 @@
 		DPRINTK(INFO, "for loop. i=%d k=%d\n", i, k);
 		switch (k) {
 		case 0:
-			hwdesc->buffer1_length = __cpu_to_le16(temp_len);
-			hwdesc->addr_buffer1 = __cpu_to_le64(temp_dma);
+			hwdesc->buffer1_length = cpu_to_le16(temp_len);
+			hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
 			break;
 		case 1:
-			hwdesc->buffer2_length = __cpu_to_le16(temp_len);
-			hwdesc->addr_buffer2 = __cpu_to_le64(temp_dma);
+			hwdesc->buffer2_length = cpu_to_le16(temp_len);
+			hwdesc->addr_buffer2 = cpu_to_le64(temp_dma);
 			break;
 		case 2:
-			hwdesc->buffer3_length = __cpu_to_le16(temp_len);
-			hwdesc->addr_buffer3 = __cpu_to_le64(temp_dma);
+			hwdesc->buffer3_length = cpu_to_le16(temp_len);
+			hwdesc->addr_buffer3 = cpu_to_le64(temp_dma);
 			break;
 		case 3:
 			hwdesc->buffer4_length = temp_len;
-			hwdesc->addr_buffer4 = __cpu_to_le64(temp_dma);
+			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
 			break;
 		}
 		frag++;
diff -Nuar old/drivers/net/netxen/netxen_nic_niu.c new/drivers/net/netxen/netxen_nic_niu.c
--- old/drivers/net/netxen/netxen_nic_niu.c	2006-08-23 12:58:43.000000000 -0500
+++ new/drivers/net/netxen/netxen_nic_niu.c	2006-08-23 13:15:19.000000000 -0500
@@ -712,6 +712,7 @@
 		return -EINVAL;
 
 	memcpy(&temp, addr, 2);
+	temp=cpu_to_le32(temp);
 	temp <<= 16;
 	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
 				   &temp, 4))
@@ -720,6 +721,7 @@
 	temp = 0;
 
 	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
+	temp=cpu_to_le32(temp);
 	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
 				   &temp, 4))
 		return -EIO;
@@ -760,7 +762,7 @@
 long netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 					long port, netxen_niu_prom_mode_t mode)
 {
-	long reg;
+	netxen_crbword_t reg;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;

--=-QfnU/X/xatNSrh0/s+GQ--

