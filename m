From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 08/12] sky2: check drop truncated packets
Date: Mon, 09 Jul 2007 15:33:40 -0700
Message-ID: <20070709223453.454111039@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38056 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755495AbXGIWhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:20 -0400
Content-Disposition: inline; filename=sky2-len-check.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If packet larger than MTU is received, the driver uses hardware to
truncate the packet. Use the status registers to catch/drop them.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-07-09 15:30:12.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:12.000000000 -0700
@@ -2109,6 +2109,9 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
+	if (status >> 16 != length)
+		goto len_mismatch;
+
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2118,6 +2121,11 @@ resubmit:
 
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
Stephen Hemminger <shemminger@linux-foundation.org>

