From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] forcedeth: Fix kexec regression
Date: Tue, 19 Aug 2008 20:45:53 +0200
Message-ID: <200808192045.54779.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808190008.54743.rjw@sisk.pl> <86802c440808181536j2c214cc3k47e73fd147b4fee1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Yinghai Lu" <yhlu.kernel@gmail.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"Simon Arlott" <simon@fire.lp0.eu>
To: "Jeff Garzik" <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54067 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756119AbYHSSmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 14:42:33 -0400
In-Reply-To: <86802c440808181536j2c214cc3k47e73fd147b4fee1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

forcedeth: Fix kexec regression

Fix regression tracked as
http://bugzilla.kernel.org/show_bug.cgi?id=11361 and
caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
("[netdrvr] forcedeth: setup wake-on-lan before shutting down")
that makes network adapters integrated into the NVidia
MCP55 chipsets fail to work in kexeced kernels.  The problem appears
to be that if the adapter is put into D3_hot during ->shutdown(),
it cannot be brought back into D0 after kexec (ref.
http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore,
only put forcedeth into D3 during ->shutdown() if the system is to be
powered off.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Tested-by: Yinghai Lu <yhlu.kernel@gmail.com>
---
 drivers/net/forcedeth.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
 	if (netif_running(dev))
 		nv_close(dev);
 
-	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
-	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	if (system_state == SYSTEM_POWER_OFF) {
+		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
+			pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 #else
 #define nv_suspend NULL
