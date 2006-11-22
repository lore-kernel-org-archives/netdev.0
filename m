From: Dmitry Mishin <dim@openvz.org>
Subject: [PATCH 2.6.18] e1000: fix initialization irqs
Date: Wed, 22 Nov 2006 15:49:14 +0300
Message-ID: <200611221549.15765.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com, akpm@osdl.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:26453 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1755680AbWKVMuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 07:50:06 -0500
To: cramerj@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of irqpoll boot option set, e1000 may oops due to:
1) e1000 register it's handler with e1000_request_irq
2) spurious interrupt happens
3) kernel tries to handle this interrupt with all available descs
4) e1000_intr is called and oops due to not initialized clean_rx handler, 
because e1000_up is not called yet.

Solution is to initialize driver before handler registration.

Signed-off-by: Dmitry Mishin <dim@openvz.org>
Signed-off-by: Pavel Emelianov <xemul@openvz.org>

---
 e1000_main.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

---
--- ./drivers/net/e1000/e1000_main.c.e1000	2006-09-20 07:42:06.000000000 +0400
+++ ./drivers/net/e1000/e1000_main.c	2006-11-22 14:08:15.000000000 +0300
@@ -1206,14 +1206,15 @@ e1000_open(struct net_device *netdev)
 	if ((err = e1000_setup_all_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	err = e1000_request_irq(adapter);
-	if (err)
-		goto err_up;
-
 	e1000_power_up_phy(adapter);
 
 	if ((err = e1000_up(adapter)))
 		goto err_up;
+
+	err = e1000_request_irq(adapter);
+	if (err)
+		goto err_up;
+
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 	if ((adapter->hw.mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {
