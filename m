From: Bill Helfinstine <bhelf@flitterfly.whirpon.com>
Subject: [PATCH 2.6.21-rc5] b44: fix IFF_ALLMULTI handling of CAM slots
Date: Sun, 01 Apr 2007 13:10:28 -0400
Message-ID: <1175447428.9384.4.camel@tomato>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhelf@flitterfly.whirpon.com
To: zambrano@broadcom.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yam.whirpon.com ([72.9.242.239]:50126 "EHLO yam.whirpon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933645AbXDARhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2007 13:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If you set the IFF_ALLMULTI flag on a b44 device, or if you join more than
B44_MCAST_TABLE_SIZE multicast groups, the device will stop receiving unicast
messages.  This is because the __b44_set_mac_addr call sets the zeroth CAM
entry to the MAC address of the device, and then the loop at line 1722
proceeds to overwrite it unless the value of i is set by the __b44_load_mcast
call.  However, when IFF_ALLMULTI is set, that call is bypassed, leaving i set
to zero.  

Fixed by starting the loop at 1 to make it skip the CAM entry for the MAC
address.

Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>

---

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index aaada57..d742bfe 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1709,7 +1709,7 @@ static void __b44_set_rx_mode(struct net_device *dev)
 		bw32(bp, B44_RXCONFIG, val);
 	} else {
 		unsigned char zero[6] = {0, 0, 0, 0, 0, 0};
-		int i = 0;
+		int i = 1;
 
 		__b44_set_mac_addr(bp);
 




