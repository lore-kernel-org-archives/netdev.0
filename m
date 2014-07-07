From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH v2 1/3] usb: gadget: NCM: RX function support multiple NDPs
Date: Mon, 7 Jul 2014 18:33:17 +0100
Message-ID: <1404754399-10360-2-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1404754399-10360-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404754399-10360-1-git-send-email-jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NDP was ignoring the wNextNdpIndex in the NDP which
means that NTBs containing multiple NDPs would have missed
frames.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---

This patch originally came about because I read the CDC-NCM specification
Figures 3-1, 3-2 and table 3-4 which specifies 32bit NDPs as a link.
It has since been noted that table 3-3 states it is reserved so there is
an inconsistancy in the specfification which this patch covers either
version of.


 drivers/usb/gadget/f_ncm.c |  146 +++++++++++++++++++++++---------------------
 1 file changed, 78 insertions(+), 68 deletions(-)

diff --git a/drivers/usb/gadget/f_ncm.c b/drivers/usb/gadget/f_ncm.c
index a9499fd..d0ebbac 100644
--- a/drivers/usb/gadget/f_ncm.c
+++ b/drivers/usb/gadget/f_ncm.c
@@ -963,6 +963,7 @@ static int ncm_unwrap_ntb(struct gether *port,
 	struct f_ncm	*ncm = func_to_ncm(&port->func);
 	__le16		*tmp = (void *) skb->data;
 	unsigned	index, index2;
+	int		ndp_index;
 	unsigned	dg_len, dg_len2;
 	unsigned	ndp_len;
 	struct sk_buff	*skb2;
@@ -995,91 +996,100 @@ static int ncm_unwrap_ntb(struct gether *port,
 		goto err;
 	}
 
-	index = get_ncm(&tmp, opts->fp_index);
-	/* NCM 3.2 */
-	if (((index % 4) != 0) && (index < opts->nth_size)) {
-		INFO(port->func.config->cdev, "Bad index: %x\n",
-			index);
-		goto err;
-	}
-
-	/* walk through NDP */
-	tmp = ((void *)skb->data) + index;
-	if (get_unaligned_le32(tmp) != ncm->ndp_sign) {
-		INFO(port->func.config->cdev, "Wrong NDP SIGN\n");
-		goto err;
-	}
-	tmp += 2;
-
-	ndp_len = get_unaligned_le16(tmp++);
-	/*
-	 * NCM 3.3.1
-	 * entry is 2 items
-	 * item size is 16/32 bits, opts->dgram_item_len * 2 bytes
-	 * minimal: struct usb_cdc_ncm_ndpX + normal entry + zero entry
-	 */
-	if ((ndp_len < opts->ndp_size + 2 * 2 * (opts->dgram_item_len * 2))
-	    || (ndp_len % opts->ndplen_align != 0)) {
-		INFO(port->func.config->cdev, "Bad NDP length: %x\n", ndp_len);
-		goto err;
-	}
-	tmp += opts->reserved1;
-	tmp += opts->next_fp_index; /* skip reserved (d)wNextFpIndex */
-	tmp += opts->reserved2;
-
-	ndp_len -= opts->ndp_size;
-	index2 = get_ncm(&tmp, opts->dgram_item_len);
-	dg_len2 = get_ncm(&tmp, opts->dgram_item_len);
-	dgram_counter = 0;
+	ndp_index = get_ncm(&tmp, opts->fp_index);
 
+	/* Run through all the NDP's in the NTB */
 	do {
-		index = index2;
-		dg_len = dg_len2;
-		if (dg_len < 14 + crc_len) { /* ethernet header + crc */
-			INFO(port->func.config->cdev, "Bad dgram length: %x\n",
-			     dg_len);
+		/* NCM 3.2 */
+		if (((ndp_index % 4) != 0) &&
+				(ndp_index < opts->nth_size)) {
+			INFO(port->func.config->cdev, "Bad index: %#X\n",
+			     ndp_index);
 			goto err;
 		}
-		if (ncm->is_crc) {
-			uint32_t crc, crc2;
-
-			crc = get_unaligned_le32(skb->data +
-						 index + dg_len - crc_len);
-			crc2 = ~crc32_le(~0,
-					 skb->data + index,
-					 dg_len - crc_len);
-			if (crc != crc2) {
-				INFO(port->func.config->cdev, "Bad CRC\n");
-				goto err;
-			}
+
+		/* walk through NDP */
+		tmp = (void *)(skb->data + ndp_index);
+		if (get_unaligned_le32(tmp) != ncm->ndp_sign) {
+			INFO(port->func.config->cdev, "Wrong NDP SIGN\n");
+			goto err;
 		}
+		tmp += 2;
 
+		ndp_len = get_unaligned_le16(tmp++);
+		/*
+		 * NCM 3.3.1
+		 * entry is 2 items
+		 * item size is 16/32 bits, opts->dgram_item_len * 2 bytes
+		 * minimal: struct usb_cdc_ncm_ndpX + normal entry + zero entry
+		 * Each entry is a dgram index and a dgram length.
+		 */
+		if ((ndp_len < opts->ndp_size
+				+ 2 * 2 * (opts->dgram_item_len * 2))
+				|| (ndp_len % opts->ndplen_align != 0)) {
+			INFO(port->func.config->cdev, "Bad NDP length: %#X\n",
+			     ndp_len);
+			goto err;
+		}
+		tmp += opts->reserved1;
+		/* Check for another NDP (d)wNextNdpIndex */
+		ndp_index = get_ncm(&tmp, opts->next_fp_index);
+		tmp += opts->reserved2;
+
+		ndp_len -= opts->ndp_size;
 		index2 = get_ncm(&tmp, opts->dgram_item_len);
 		dg_len2 = get_ncm(&tmp, opts->dgram_item_len);
+		dgram_counter = 0;
+
+		do {
+			index = index2;
+			dg_len = dg_len2;
+			if (dg_len < 14 + crc_len) { /* ethernet hdr + crc */
+				INFO(port->func.config->cdev,
+				     "Bad dgram length: %#X\n", dg_len);
+				goto err;
+			}
+			if (ncm->is_crc) {
+				uint32_t crc, crc2;
+
+				crc = get_unaligned_le32(skb->data +
+							 index + dg_len -
+							 crc_len);
+				crc2 = ~crc32_le(~0,
+						 skb->data + index,
+						 dg_len - crc_len);
+				if (crc != crc2) {
+					INFO(port->func.config->cdev,
+					     "Bad CRC\n");
+					goto err;
+				}
+			}
+
+			index2 = get_ncm(&tmp, opts->dgram_item_len);
+			dg_len2 = get_ncm(&tmp, opts->dgram_item_len);
 
-		if (index2 == 0 || dg_len2 == 0) {
-			skb2 = skb;
-		} else {
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2 == NULL)
 				goto err;
-		}
 
-		if (!skb_pull(skb2, index)) {
-			ret = -EOVERFLOW;
-			goto err;
-		}
+			if (!skb_pull(skb2, index)) {
+				ret = -EOVERFLOW;
+				goto err;
+			}
 
-		skb_trim(skb2, dg_len - crc_len);
-		skb_queue_tail(list, skb2);
+			skb_trim(skb2, dg_len - crc_len);
+			skb_queue_tail(list, skb2);
 
-		ndp_len -= 2 * (opts->dgram_item_len * 2);
+			ndp_len -= 2 * (opts->dgram_item_len * 2);
 
-		dgram_counter++;
+			dgram_counter++;
 
-		if (index2 == 0 || dg_len2 == 0)
-			break;
-	} while (ndp_len > 2 * (opts->dgram_item_len * 2)); /* zero entry */
+			if (index2 == 0 || dg_len2 == 0)
+				break;
+		} while (ndp_len > 2 * (opts->dgram_item_len * 2));
+	} while (ndp_index);
+
+	dev_kfree_skb_any(skb);
 
 	VDBG(port->func.config->cdev,
 	     "Parsed NTB with %d frames\n", dgram_counter);
-- 
1.7.9.5
