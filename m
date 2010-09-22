From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH 1/2] atl1: fix resume
Date: Wed, 22 Sep 2010 22:41:58 +0200
Message-ID: <20100922204158.GA1372@nb-core2.darkstar.lan>
References: <20100922.132341.48506736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: atl1-devel@lists.sourceforge.net, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39045 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab0IVUmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:42:43 -0400
Received: by wwb34 with SMTP id 34so16711wwb.1
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 13:42:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100922.132341.48506736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adapter->cmb.cmb is initialized when the device is opened and freed when
it's closed. Accessing it unconditionally during resume results either
in a crash (NULL pointer dereference, when the interface has not been
opened yet) or data corruption (when the interface has been used and
brought down adapter->cmb.cmb points to a deallocated memory area).

Cc: stable@kernel.org
Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
Acked-by: Chris Snook <chris.snook@gmail.com>
---
This time with mutt :)

 drivers/net/atlx/atl1.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 63b9ba0..bbd6e30 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2847,10 +2847,11 @@ static int atl1_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	atl1_reset_hw(&adapter->hw);
-	adapter->cmb.cmb->int_stats = 0;
 
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		adapter->cmb.cmb->int_stats = 0;
 		atl1_up(adapter);
+	}
 	netif_device_attach(netdev);
 
 	return 0;
-- 
1.7.1
