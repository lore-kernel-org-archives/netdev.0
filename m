From: Michael Breuer <mbreuer@majjas.com>
Subject: [PATCH] sky2: Flow control frames recorded as dropped packets
Date: Wed, 03 Feb 2010 11:56:09 -0500
Message-ID: <4B69AAA9.20505@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:40973 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757457Ab0BCQ4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 11:56:25 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta4.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KX900GHBZ1OPNJ0@mta4.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Wed, 03 Feb 2010 11:56:13 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a flow control packet is received, sky2_receive resubmits the i/o. 
Upon exit, sky2_status_intr counts these as dropped packets.

This fix just skips the rx_dropped accounting in this one case. It 
didn't seem worthwhile to change sky2_receive to deal differently.

This is my first patch submission - comments more than welcome.

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 95fd10f..bcb035c 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2525,7 +2517,8 @@ static int sky2_status_intr(struct sky2_hw *hw, 
int to_do, u16 idx)
                         total_bytes[port] += length;
                         skb = sky2_receive(dev, length, status);
                         if (unlikely(!skb)) {
-                               dev->stats.rx_dropped++;
+                               if (!(status & GMR_FS_GOOD_FC) )
+                                       dev->stats.rx_dropped++;
                                 break;
                         }

