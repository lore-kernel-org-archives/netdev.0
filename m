From: Yinghai Lu <yhlu.kernel.send@gmail.com>
Subject: [PATCH] r8169: fix IRQx nobody cared for shared irq with INTx
Date: Mon, 31 Mar 2008 14:58:55 -0700
Message-ID: <200803311458.56119.yhlu.kernel@gmail.com>
References: <200803291403.23479.yhlu.kernel@gmail.com>
Reply-To: yhlu.kernel@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz,
	Vadim Dyadkin <dyadkin@lns.pnpi.spb.ru>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:18406 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbYCaV4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 17:56:12 -0400
Received: by py-out-1112.google.com with SMTP id u52so2594884pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 14:56:09 -0700 (PDT)
In-Reply-To: <200803291403.23479.yhlu.kernel@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


try to solve
	troubles with r8169
	http://lkml.org/lkml/2007/8/12/225

same to
	[PATCH] e1000: fix IRQx nobody cared for shared irq with INTx
	http://lkml.org/lkml/2008/3/29/103

Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3acfeea..7405a95 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1619,6 +1619,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->dev = dev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
+	/* disable INTx at first */
+	pci_intx(pdev, 0);
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
@@ -1887,6 +1889,11 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
+	if (!(tp->features & RTL_FEATURE_MSI)) {
+		/* enable INTx if not using MSI */
+		pci_intx(pdev, 1);
+        }
+
 #ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
 #endif
