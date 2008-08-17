From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot
Date: Sat, 16 Aug 2008 23:22:53 -0700
Message-ID: <1218954173-12628-1-git-send-email-yhlu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Jeff Garzik <jgarzik@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:44562 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbYHQGXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 02:23:42 -0400
Received: by wa-out-1112.google.com with SMTP id j37so994682waf.23
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 23:23:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after

| commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
| Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
| Date:   Sun May 18 15:02:37 2008 +0200
|
|    [netdrvr] forcedeth: setup wake-on-lan before shutting down
|
|    When hibernating in 'shutdown' mode, after saving the image the suspend hook
|    is not called again.
|    However, if the device is in promiscous mode, wake-on-lan will not work.
|    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
|
|    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
|    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

my servers with nvidia mcp55 will nic doesn't work with msi.

after remove pci_set_power_state(, PCI_D3hot) that nic/msi will work again.

check with e1000 is using pci_choose_state in _shutdown.

So change that pci_choose_state(pdev, ...), and it works.

Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>

---
 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -5988,7 +5988,7 @@ static void nv_shutdown(struct pci_dev *
 	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
 	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	pci_set_power_state(pdev, pci_choose_state(pdev, PMSG_SUSPEND));
 }
 #else
 #define nv_suspend NULL
