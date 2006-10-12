From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: [PATCH] sk98lin: handle pci_enable_device() return value in
 skge_resume() properly
Date: Fri, 13 Oct 2006 00:38:20 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610130028450.29022@twin.jikos.cz>
References: <Pine.LNX.4.64.0610130002320.29022@twin.jikos.cz>
 <20061012152512.66f147b8@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mlindner@syskonnect.de, rroesler@syskonnect.de,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751263AbWJLWli@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061012152512.66f147b8@freekitty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006, Stephen Hemminger wrote:

> >  	pci_set_power_state(pdev, PCI_D0);
> >  	pci_restore_state(pdev);
> > -	pci_enable_device(pdev);
> > +	if ((ret = pci_enable_device(pdev))) {
> > +		printk(KERN_ERR "sk98lin: Cannot enable PCI device during resume\n");
> > +		unregister_netdev(dev);
> >
> Having the device unregister seems harsh.

What would be the proper way? As the initialization failed, accessing the 
device would not make sense any more (therefore I don't think that calling 
skge_remove_one() would be OK, as it issues calls to SkEventQueue() and 
SkEventDispatcher(), trying to send something to the card).

> Why put condtional on same line?

Pardon me?

> Why not print device name dev->name.

Thanks.

[PATCH] fix sk98lin driver, ignoring return value from pci_enable_device()

add check of return value to _resume() function of sk98lin driver.

Signed-off-by: Jiri Kosina <jikos@jikos.cz>

--- 

 drivers/net/sk98lin/skge.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index d4913c3..1f03cf8 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -5070,7 +5070,11 @@ static int skge_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	if ((ret = pci_enable_device(pdev))) {
+		printk(KERN_ERR "sk98lin: Cannot enable PCI device %s during resume\n", 
+				dev->name);
+		return ret;
+	}
 	pci_set_master(pdev);
 	if (pAC->GIni.GIMacsFound == 2)
 		ret = request_irq(dev->irq, SkGeIsr, IRQF_SHARED, "sk98lin", dev);

-- 
Jiri Kosina
