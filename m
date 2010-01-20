From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] DMA sync errors
Date: Wed, 20 Jan 2010 15:28:32 -0800
Message-ID: <20100120152832.06a905a5@nehalam>
References: <20100120204459.820265084@vyatta.com>
	<20100120.144639.31770545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60483 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab0ATX2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 18:28:50 -0500
In-Reply-To: <20100120.144639.31770545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should fix the dma-debug API code (and documentation), to
avoid false positives when sync is done on a partial map.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/DMA-API.txt	2010-01-20 15:17:01.390143729 -0800
+++ b/Documentation/DMA-API.txt	2010-01-20 15:18:48.967875255 -0800
@@ -377,9 +377,10 @@ void
 pci_dma_sync_sg(struct pci_dev *hwdev, struct scatterlist *sg,
 		       int nelems, int direction)
 
-Synchronise a single contiguous or scatter/gather mapping.  All the
-parameters must be the same as those passed into the single mapping
-API.
+Synchronise a single contiguous or scatter/gather mapping.  The
+device and handle must be the same as those passed into the single mapping
+API. The size can be less than the original mapping if only part
+of the mapping needs to be accessed.
 
 Notes:  You must do this:
 
--- a/lib/dma-debug.c	2010-01-20 15:22:55.919519883 -0800
+++ b/lib/dma-debug.c	2010-01-20 15:26:31.648895638 -0800
@@ -285,11 +285,9 @@ static struct dma_debug_entry *hash_buck
 	}
 
 	/*
-	 * If we have multiple matches but no perfect-fit, just return
-	 * NULL.
+	 * If we have multiple matches but no perfect-fit
+	 * return best value and let caller deal with it.
 	 */
-	ret = (matches == 1) ? ret : NULL;
-
 	return ret;
 }
 
