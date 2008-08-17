From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot - v2
Date: Sun, 17 Aug 2008 18:55:57 +0200
Message-ID: <200808171855.58384.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808171502.02946.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:40656 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbYHQQwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2008 12:52:49 -0400
In-Reply-To: <200808171502.02946.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 17 of August 2008, Rafael J. Wysocki wrote:
> On Sunday, 17 of August 2008, Yinghai Lu wrote:
> > after
> > 
> > | commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> > | Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> > | Date:   Sun May 18 15:02:37 2008 +0200
> > |
> > |    [netdrvr] forcedeth: setup wake-on-lan before shutting down
> > |
> > |    When hibernating in 'shutdown' mode, after saving the image the suspend hook
> > |    is not called again.
> > |    However, if the device is in promiscous mode, wake-on-lan will not work.
> > |    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
> > |
> > |    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> > |    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> > 
> > my servers with nvidia mcp55 nic doesn't work with msi in second kernel by kexec
> > 
> > after remove pci_set_power_state(, PCI_D3hot) that nic/msi will work again.
> > 
> > check with e1000 is using pci_choose_state in _shutdown.

This is wrong.

> > So change that pci_choose_state(pdev, ...), and it works.
> 
> Well, this doesn't look like a good solution to me, because you're putting
> PMSG_SUSPEND in there, which is not correct for shutdown.  The right thing to
> do would be to avoid changing the device power state if nv_shutdown() is
> used for kexec or to rework the initialization of the adapter to handle the
> case when it's initially in D3.
> 
> Does it help if you just remove the pci_set_power_state(pdev, PCI_D3hot)
> altogether?

Ah, sorry.  I see it does.

Actually, I think you can use pci_prepare_to_sleep() instead of
pci_enable_wake() / pci_set_power_state() combo.  It wasn't designed for this
purpose, but should work nevertheless.

Can you please check if the appended patch works instead of your one?

Rafael

---
Fix the problem that boxes with NVidia MCP55 don't work with MSI
in a kexeced kernel.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/forcedeth.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -5975,10 +5975,8 @@ static void nv_shutdown(struct pci_dev *
 	if (netif_running(dev))
 		nv_close(dev);
 
-	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
-	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	pci_prepare_to_sleep(pdev);
 }
 #else
 #define nv_suspend NULL

