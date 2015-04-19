From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [PATCH] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Sun, 19 Apr 2015 15:48:49 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C859010828D6@AVMB1.qlogic.org>
References: <1429293524-26897-1-git-send-email-krisman@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"cascardo@linux.vnet.ibm.com" <cascardo@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22254 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751038AbbDSPsy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2015 11:48:54 -0400
In-Reply-To: <1429293524-26897-1-git-send-email-krisman@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gabriel,
Thanks for pointing out this shortcoming.
However, I don't think that the solution you suggested would work as is.

@@ -628,21 +644,30 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			bnx2x_fp_qstats(bp, fp)->rx_skb_alloc_failed++;
 			return err;
 		}
+		if (old_rx_pg.offset + old_rx_pg.len >= PAGE_SIZE) {
+			/* Unmap the page as we finished passing it to
+			 * the stack
+			 */
+			old_rx_pg.mapping = old_rx_pg.mapping -
+				old_rx_pg.offset;
+			dma_unmap_page(&bp->pdev->dev,
+				       dma_unmap_addr(&old_rx_pg, mapping),
+				       PAGE_SIZE, DMA_FROM_DEVICE);
+		}

This code assumes that pages are consumed by the device in order. This is not true.
The pages are consumed according to packet arrival order, which can be from different aggregations.

We'll come up with a compatible solution.

Thanks,
Ariel
