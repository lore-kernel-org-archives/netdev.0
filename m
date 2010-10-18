From: Bernard Blackham <bernard@largestprime.net>
Subject: [PATCH] smsc95xx: generate random MAC address once, not every ifup
Date: Tue, 19 Oct 2010 10:16:39 +1100
Message-ID: <20101018231639.GA15955@mersenne.largestprime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap@vger.kernel.org
To: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mersenne.largestprime.net ([203.56.168.14]:38207 "EHLO
	mersenne.largestprime.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482Ab0JRXXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 19:23:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc95xx driver currently generates a new random MAC address
every time the interface is brought up. This makes it impossible to
override using the standard `ifconfig hw ether` approach.

Past patches tried to make the MAC address a module parameter or
base it off the die ID, but it seems to me much simpler (and
hopefully less controversial) to stick with the current random
generation scheme, but allow the user to change the address.

This patch does exactly that - it moves the random address
generation from smsc95xx_reset() into smsc95xx_bind(), so that it is
done once on module load, not on every ifup. The user can then
override this using the standard mechanisms.

Applies against 2.6.35 and linux-2.6 head.

Signed-off-by: Bernard Blackham <b-omap@largestprime.net>

---

--- a/drivers/net/usb/smsc95xx.c	2010-10-19 00:15:35.915612223 +1100
+++ b/drivers/net/usb/smsc95xx.c	2010-10-19 00:15:55.408550929 +1100
@@ -805,8 +805,6 @@ static int smsc95xx_reset(struct usbnet
 		return ret;
 	}
 
-	smsc95xx_init_mac_address(dev);
-
 	ret = smsc95xx_set_mac_address(dev);
 	if (ret < 0)
 		return ret;
@@ -1047,6 +1045,8 @@ static int smsc95xx_bind(struct usbnet *
 	pdata->use_tx_csum = DEFAULT_TX_CSUM_ENABLE;
 	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
 
+	smsc95xx_init_mac_address(dev);
+
 	/* Init all registers */
 	ret = smsc95xx_reset(dev);
 
