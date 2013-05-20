From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3/4] e1000e: Calculate the desc_len based on adapter type
Date: Mon, 20 May 2013 16:15:06 +0800
Message-ID: <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:39917 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab3ETIPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:15:32 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 20 May 2013 18:09:01 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 457F72CE804D
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:26 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4K81B658388722
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:01:11 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4K8FPxH015941
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:25 +1000
In-Reply-To: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

desc_len represents the size of descriptor in rx_ring. There are two kinds of
rx descriptors, e1000_rx_desc_packet_split(32 byte) and
e1000_rx_desc_extended(16 byte). Different adapter will use different rx
descriptors.

When allocating the dma space for this descriptor in current implementation,
the code ignore the descriptor type and take it as e1000_rx_desc_packet_split
in any case. This behavior will not effect the function, but will require
double size of dma space.

This patch will calculate the desc_len based on the adapter type.

Tested on T420, which use e1000_rx_desc_extended and works fine.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5cb8321..a2e8a53 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2364,7 +2364,12 @@ int e1000e_setup_rx_resources(struct e1000_ring *rx_ring)
 			goto err_pages;
 	}
 
-	desc_len = sizeof(union e1000_rx_desc_packet_split);
+	if (adapter->rx_ps_pages) {
+		/* this is a 32 byte descriptor */
+		desc_len = sizeof(union e1000_rx_desc_packet_split);
+	} else {
+		desc_len = sizeof(union e1000_rx_desc_extended);
+	}
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * desc_len;
-- 
1.7.5.4
