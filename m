From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] sky2: check drop truncated packets
Date: Thu, 16 Aug 2007 09:12:48 -0400
Message-ID: <20070816131348.817412148@linux-foundation.org>
References: <20070816131244.726293914@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47840 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757291AbXHPNOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:14:48 -0400
Content-Disposition: inline; filename=sky2-stable-trunc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Backport of commit 71749531f2d1954137a1a77422ef4ff29eb102dd
    
If packet larger than MTU is received, the driver uses hardware to
truncate the packet. Use the status registers to catch/drop them.
    
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-08 22:01:28.000000000 +0100
+++ b/drivers/net/sky2.c	2007-08-08 22:01:37.000000000 +0100
@@ -2065,6 +2065,9 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
+	if (status >> 16 != length)
+		goto len_mismatch;
+
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2074,6 +2077,11 @@ resubmit:
 
 	return skb;
 
+len_mismatch:
+	/* Truncation of overlength packets
+	   causes PHY length to not match MAC length */
+	++sky2->net_stats.rx_length_errors;
+
 error:
 	++sky2->net_stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {

-- 

