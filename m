From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 10/17 linux-2.6.7-rc2] prism54: Fix bug 77, strengthened oid txn (resend)
Date: Sat, 5 Jun 2004 14:49:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051449.39098.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jFcwAw/FU/M0bFU"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_jFcwAw/FU/M0bFU
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-04-09      Aurelien Alleaume <slts@free.fr>

* oid_mgt.c, isl_ioctl.c : Cleanups. Bug #77. Minor stuffs.

* islpci_mgt.c (islpci_mgt_transaction) : enforce serialization
  in oid transaction. lindent.sh.

* islpci_mgt.c (islpci_mgt_transaction) : Strengthened oid transaction.



--Boundary-00=_jFcwAw/FU/M0bFU
Content-Type: text/x-diff;
  charset="us-ascii";
  name="10-fix-bug-77-enforce-serialization.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="10-fix-bug-77-enforce-serialization.patch"

diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 14:44:24.886289992 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 15:08:00.681056472 +0200
@@ -204,7 +204,7 @@
 
 /* Noise floor.
  * I'm not sure if the unit is dBm.
- * Note : If we are not connected, this value seems to be irrevelant. */
+ * Note : If we are not connected, this value seems to be irrelevant. */
 
 	mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	priv->local_iwstatistics.qual.noise = r.u;
@@ -216,8 +216,7 @@
 	data = r.ptr;
 
 	/* copy this MAC to the bss */
-	for (j = 0; j < 6; j++)
-		bss.address[j] = data[j];
+	memcpy(bss.address, data, 6);
 	kfree(data);
 
 	/* now ask for the corresponding bss */
@@ -505,7 +504,7 @@
 		return 0;
 
 	/* Request the device for the supported frequencies
-	 * not really revelant since some devices will report the 5 GHz band
+	 * not really relevant since some devices will report the 5 GHz band
 	 * frequencies even if they don't support them.
 	 */
 	rvalue =
@@ -515,21 +514,12 @@
 	range->num_channels = freq->nr;
 	range->num_frequency = freq->nr;
 
-	/* Frequencies are not listed in the right order. The reordering is probably
-	 * firmware dependant and thus should work for everyone.
-	 */
 	m = min(IW_MAX_FREQUENCIES, (int) freq->nr);
-	for (i = 0; i < m - 12; i++) {
-		range->freq[i].m = freq->mhz[12 + i];
-		range->freq[i].e = 6;
-		range->freq[i].i = i + 1;
-	}
-	for (i = m - 12; i < m; i++) {
-		range->freq[i].m = freq->mhz[i - m + 12];
+	for (i = 0; i < m; i++) {
+		range->freq[i].m = freq->mhz[i];
 		range->freq[i].e = 6;
-		range->freq[i].i = i + 23;
+		range->freq[i].i = channel_of_freq(freq->mhz[i]);
 	}
-
 	kfree(freq);
 
 	rvalue |= mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r);
@@ -1967,60 +1957,6 @@
 }
 
 int
-prism54_set_maxframeburst(struct net_device *ndev, struct iw_request_info *info,
-			  __u32 * uwrq, char *extra)
-{
-	islpci_private *priv = netdev_priv(ndev);
-	u32 max_burst;
-
-	max_burst = (*uwrq) ? *uwrq : CARD_DEFAULT_MAXFRAMEBURST;
-	mgt_set_request(priv, DOT11_OID_MAXFRAMEBURST, 0, &max_burst);
-
-	return -EINPROGRESS; /* Call commit handler */
-}
-
-int
-prism54_get_maxframeburst(struct net_device *ndev, struct iw_request_info *info,
-			  __u32 * uwrq, char *extra)
-{
-	islpci_private *priv = netdev_priv(ndev);
-	union oid_res_t r;
-	int rvalue;
-	
-	rvalue = mgt_get_request(priv, DOT11_OID_MAXFRAMEBURST, 0, NULL, &r);
-	*uwrq = r.u;
-	
-	return rvalue;
-}
-
-int
-prism54_set_profile(struct net_device *ndev, struct iw_request_info *info,
-		    __u32 * uwrq, char *extra)
-{
-	islpci_private *priv = netdev_priv(ndev);
-	u32 profile;
-
-	profile = (*uwrq) ? *uwrq : CARD_DEFAULT_PROFILE;
-	mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
-	
-	return -EINPROGRESS; /* Call commit handler */
-}
-
-int
-prism54_get_profile(struct net_device *ndev, struct iw_request_info *info,
-		    __u32 * uwrq, char *extra)
-{
-	islpci_private *priv = netdev_priv(ndev);
-	union oid_res_t r;
-	int rvalue;
-
-	rvalue = mgt_get_request(priv, DOT11_OID_PROFILES, 0, NULL, &r);
-	*uwrq = r.u;
-
-	return rvalue;
-}
-
-int
 prism54_debug_oid(struct net_device *ndev, struct iw_request_info *info,
 		  __u32 * uwrq, char *extra)
 {
@@ -2099,7 +2035,7 @@
 		}
 	}
 	
-	return ret;
+	return (ret ? ret : -EINPROGRESS);
 }
 
 static int
@@ -2205,16 +2141,16 @@
 #define PRISM54_GET_PRISMHDR	SIOCIWFIRSTPRIV+23
 #define PRISM54_SET_PRISMHDR	SIOCIWFIRSTPRIV+24
 
-#define IWPRIV_SET_U32(n,x)	{ n, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "set_"x }
-#define IWPRIV_SET_SSID(n,x)	{ n, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | 1, 0, "set_"x }
-#define IWPRIV_SET_ADDR(n,x)	{ n, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0, "set_"x }
-#define IWPRIV_GET(n,x)	{ n, 0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | PRIV_STR_SIZE, "get_"x }
+#define IWPRIV_SET_U32(n,x)	{ n, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "s_"x }
+#define IWPRIV_SET_SSID(n,x)	{ n, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | 1, 0, "s_"x }
+#define IWPRIV_SET_ADDR(n,x)	{ n, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0, "s_"x }
+#define IWPRIV_GET(n,x)	{ n, 0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | PRIV_STR_SIZE, "g_"x }
 
 #define IWPRIV_U32(n,x)		IWPRIV_SET_U32(n,x), IWPRIV_GET(n,x)
 #define IWPRIV_SSID(n,x)	IWPRIV_SET_SSID(n,x), IWPRIV_GET(n,x)
 #define IWPRIV_ADDR(n,x)	IWPRIV_SET_ADDR(n,x), IWPRIV_GET(n,x)
 
-/* Note : limited to 128 private ioctls */
+/* Note : limited to 128 private ioctls (wireless tools 26) */
 
 static const struct iw_priv_args prism54_private_args[] = {
 /*{ cmd, set_args, get_args, name } */
@@ -2352,5 +2288,6 @@
 int
 prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
+
 	return -EOPNOTSUPP;
 }
diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c	2004-05-28 14:40:26.998454440 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c	2004-05-28 15:08:00.686055712 +0200
@@ -63,7 +63,6 @@
     Queue handling for management frames
 ******************************************************************************/
 
-  
 /*
  * Helper function to create a PIMFOR management frame header.
  */
@@ -87,7 +86,7 @@
 	pimfor_header_t *h = data;
 
         while ((void *) h < data + len) {
-		if(h->flags & PIMFOR_FLAG_LITTLE_ENDIAN) {
+		if (h->flags & PIMFOR_FLAG_LITTLE_ENDIAN) {
 			le32_to_cpus(&h->oid);
 			le32_to_cpus(&h->length);
 		} else {
@@ -124,7 +123,8 @@
 		if (buf->mem == NULL) {
 			buf->mem = kmalloc(MGMT_FRAME_SIZE, GFP_ATOMIC);
 			if (!buf->mem) {
-				printk(KERN_WARNING "Error allocating management frame.\n");
+				printk(KERN_WARNING
+				       "Error allocating management frame.\n");
 				return -ENOMEM;
 			}
 			buf->size = MGMT_FRAME_SIZE;
@@ -133,8 +133,9 @@
 			buf->pci_addr = pci_map_single(priv->pdev, buf->mem,
 						       MGMT_FRAME_SIZE,
 						       PCI_DMA_FROMDEVICE);
-			if(!buf->pci_addr) {
-				printk(KERN_WARNING "Failed to make memory DMA'able\n.");
+			if (!buf->pci_addr) {
+				printk(KERN_WARNING
+				       "Failed to make memory DMA'able\n.");
 				return -ENOMEM;
 			}
 		}
@@ -149,8 +150,7 @@
                  * been written before announcing the frame buffer to
                  * device */
 		wmb();
-		cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ] =
-			cpu_to_le32(curr);
+		cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ] = cpu_to_le32(curr);
 	}
 	return 0;
 }
@@ -249,7 +249,7 @@
 	 * been written before announcing the frame buffer to
 	 * device */
 	wmb();
-	cb->driver_curr_frag[ISL38XX_CB_TX_MGMTQ] = cpu_to_le32(curr_frag+1);
+	cb->driver_curr_frag[ISL38XX_CB_TX_MGMTQ] = cpu_to_le32(curr_frag + 1);
 	spin_unlock_irqrestore(&priv->slock, flags);
 
 	/* trigger the device */
@@ -281,14 +281,13 @@
 	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_receive \n");
 #endif
 
-
         /* Only once per interrupt, determine fragment range to
          * process.  This avoids an endless loop (i.e. lockup) if
          * frames come in faster than we can process them. */
 	curr_frag = le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_RX_MGMTQ]);
 	barrier();
 
-	for ( ; priv->index_mgmt_rx < curr_frag; priv->index_mgmt_rx++) {
+	for (; priv->index_mgmt_rx < curr_frag; priv->index_mgmt_rx++) {
 		pimfor_header_t *header;
 		u32 index = priv->index_mgmt_rx % ISL38XX_CB_MGMT_QSIZE;
 		struct islpci_membuf *buf = &priv->mgmt_rx[index];
@@ -298,7 +297,7 @@
               
                 /* I have no idea (and no documentation) if flags != 0
                  * is possible.  Drop the frame, reuse the buffer. */
-                if(le16_to_cpu(cb->rx_data_mgmt[index].flags) != 0) {
+		if (le16_to_cpu(cb->rx_data_mgmt[index].flags) != 0) {
                         printk(KERN_WARNING "%s: unknown flags 0x%04x\n",
                                ndev->name,
                                le16_to_cpu(cb->rx_data_mgmt[index].flags));
@@ -314,8 +313,7 @@
                  * triggers, we likely have kernel heap corruption. */
                 if (frag_len > MGMT_FRAME_SIZE) {
                         printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\
-n",
-                               ndev->name, frag_len, frag_len);
+n", ndev->name, frag_len, frag_len);
                         frag_len = MGMT_FRAME_SIZE;
                 }
 
@@ -344,23 +342,25 @@
 
 		/* display the buffer contents for debugging */
 		display_buffer((char *) header, PIMFOR_HEADER_SIZE);
-		display_buffer((char *) header + PIMFOR_HEADER_SIZE, header->length);
+		display_buffer((char *) header + PIMFOR_HEADER_SIZE,
+			       header->length);
 #endif
 
 		/* nobody sends these */
 		if (header->flags & PIMFOR_FLAG_APPLIC_ORIGIN) {
-			printk(KERN_DEBUG "%s: errant PIMFOR application frame\n",
+			printk(KERN_DEBUG
+			       "%s: errant PIMFOR application frame\n",
 			       ndev->name);
 			continue;
 		}
 
 		/* Determine frame size, skipping OID_INL_TUNNEL headers. */
 		size = PIMFOR_HEADER_SIZE + header->length;
-		frame = kmalloc(sizeof(struct islpci_mgmtframe) + size,
+		frame = kmalloc(sizeof (struct islpci_mgmtframe) + size,
 				GFP_ATOMIC);
 		if (!frame) {
-			printk(KERN_WARNING "%s: Out of memory, cannot handle oid 0x%08x\n",
-
+			printk(KERN_WARNING
+			       "%s: Out of memory, cannot handle oid 0x%08x\n",
 			       ndev->name, header->oid);
 			continue;        
 		}
@@ -392,14 +392,13 @@
 			/* Signal the one waiting process that a response
 			 * has been received. */
 			if ((frame = xchg(&priv->mgmt_received, frame)) != NULL) {
-				printk(KERN_WARNING "%s: mgmt response not collected\n",
+				printk(KERN_WARNING
+				       "%s: mgmt response not collected\n",
 				       ndev->name);
 				kfree(frame);
 			}
-                              
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			DEBUG(SHOW_TRACING,
-			      "Wake up Mgmt Queue\n");
+			DEBUG(SHOW_TRACING, "Wake up Mgmt Queue\n");
 #endif
 			wake_up(&priv->mgmt_wqueue);
 		}
@@ -431,7 +430,7 @@
 	curr_frag = le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_TX_MGMTQ]); 
 	barrier();
 
-	for ( ; priv->index_mgmt_tx < curr_frag; priv->index_mgmt_tx++) {
+	for (; priv->index_mgmt_tx < curr_frag; priv->index_mgmt_tx++) {
 		int index = priv->index_mgmt_tx % ISL38XX_CB_MGMT_QSIZE;
 		struct islpci_membuf *buf = &priv->mgmt_tx[index];
 		pci_unmap_single(priv->pdev, buf->pci_addr, buf->size,
@@ -463,7 +462,7 @@
 
 	prepare_to_wait(&priv->mgmt_wqueue, &wait, TASK_UNINTERRUPTIBLE);
 	err = islpci_mgt_transmit(ndev, operation, oid, senddata, sendlen);
-	if(err)
+	if (err)
 		goto out;
 
 	err = -ETIMEDOUT;
@@ -474,12 +473,22 @@
 		timeleft = schedule_timeout(wait_cycle_jiffies);
 		frame = xchg(&priv->mgmt_received, NULL);
 		if (frame) {
+			if (frame->header->oid == oid) {
 			*recvframe = frame;
 			err = 0;
 			goto out;
+			} else {
+				printk(KERN_DEBUG
+				       "%s: expecting oid 0x%x, received 0x%x.\n",
+				       ndev->name, (unsigned int) oid,
+				       frame->header->oid);
+				kfree(frame);
+				frame = NULL;
 		}
-		if(timeleft == 0) {
-			printk(KERN_DEBUG "%s: timeout waiting for mgmt response %lu, trigging device\n",
+		}
+		if (timeleft == 0) {
+			printk(KERN_DEBUG
+			       "%s: timeout waiting for mgmt response %lu, trigging device\n",
 			       ndev->name, timeout_left);
 			islpci_trigger(priv);
 		}
diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 14:44:24.888289688 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 15:08:00.688055408 +0200
@@ -40,17 +40,13 @@
 	if ((f >= 2412) && (f <= 2484)) {
 		while ((c < 14) && (f != frequency_list_bg[c]))
 			c++;
-		if (c >= 14)
-			return 0;
+		return (c >= 14) ? 0 : ++c;
 	} else if ((f >= (int) 5170) && (f <= (int) 5320)) {
 		while ((c < 12) && (f != frequency_list_a[c]))
 			c++;
-		if (c >= 12)
-			return 0;
+		return (c >= 12) ? 0 : (c + 37);
 	} else
 		return 0;
-
-	return ++c;
 }
 
 #define OID_STRUCT(name,oid,s,t) [name] = {oid, 0, sizeof(s), t}

--Boundary-00=_jFcwAw/FU/M0bFU--
