From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH 1/1] net: Set NOCARRIER bit of etherdev state at initialization
Date: Fri, 23 May 2014 22:31:35 +0530
Message-ID: <537F7EEF.3060701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, stephen@networkplumber.org,
	avi.kp.137@gmail.com, edumazet@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:53738 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaEWRCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 13:02:05 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so4342574pad.23
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 10:02:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For any etherdev 'netif_carrier_ok' should succeed only after phy
layer determines carrier state through auto-negotiation or setting
it forcibly.

So ethernet drivers should set '__LINK_STATE_NOCARRIER' bit of
'dev->state' using 'netif_carrier_off' call at driver initialization.
As it is common for all ethernet devices, 'netif_carrier_off' call
could be moved to 'ether_setup'.

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
---
'netif_carrier_off' could be called anywhere in between
'alloc_etherdev' and 'phy_start'. For example,
1. e1000 driver calls at the end of 'e1000_probe'
2. intel i40e driver calls at the beginning of 'i40e_open'
3. realtek r8169 driver calls at the end of 'rtl_init_one'

But some driver misses this call. For example smsc911x driver doesn't
call 'netif_carrier_off' before calling 'phy_start'. So device starts
performing dhcp and IPv6 DAD even if carrier is not ready.

So it is better to move 'netif_carrier_off' call to 'ether_setup'. And
drivers can remove this call from their initialization functions.
---
 net/ethernet/eth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5dc638c..45f6703 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -369,6 +369,9 @@ void ether_setup(struct net_device *dev)
 
 	memset(dev->broadcast, 0xFF, ETH_ALEN);
 
+	/* Carrier state should be off initially */
+	netif_carrier_off(dev);
+
 }
 EXPORT_SYMBOL(ether_setup);
 
-- 
1.8.3.2
