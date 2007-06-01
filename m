From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: disable polling before registering netdevice
Date: Fri, 01 Jun 2007 10:22:39 -0700
Message-ID: <20070601172239.12639.92139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, doug.chapman@hp.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62954 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759605AbXFARWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 13:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To assure the symmetry of poll enable/disable in up/down, we should
initialize the netdevice to be poll_disabled at load time. Doing
this after register_netdevice leaves us open to another race, so
lets move all the netif_* calls above register_netdevice so the
stack starts out how we expect it to be.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Doug Chapman <doug.chapman@hp.com>
---

 drivers/net/e1000/e1000_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9ec35b7..cf8af92 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1142,13 +1142,16 @@ e1000_probe(struct pci_dev *pdev,
 	    !e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
-	strcpy(netdev->name, "eth%d");
-	if ((err = register_netdev(netdev)))
-		goto err_register;
-
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_disable(netdev);
+#endif
+
+	strcpy(netdev->name, "eth%d");
+	if ((err = register_netdev(netdev)))
+		goto err_register;
 
 	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
 
