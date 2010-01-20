From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Can we remove pci_find_device() yet?
Date: Wed, 20 Jan 2010 16:11:08 +0100 (CET)
Message-ID: <20100120151109.29FA240109@xenon.ts.pxnet.com>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <877hrlf0rf.fsf@basil.nowhere.org> <20100114110214.37d7ffc9@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:36906 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab0ATPTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 10:19:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 14, 2010 at 11:02:14AM +0000, Alan Cox wrote:
> > e.g. set some global variable that forbids device removal
> > and warn in the kernel log. In theory this could be also
> > done per device, but I guess that would be more effort.
> 
> There is a simpler way to do that, which is to just leak a reference in
> the hisax_find_pci_device hack. The pci_dev won't be going anywhere then.

Something like this? (On top of my previous patch introducing
hisax_find_pci_device in the first place.)

Subject: [PATCH RFC] isdn/hisax: intentionally leak a reference in hisax_find_pci_device

Take a reference to the returned pci_dev which will never be released.
Until the HiSax drivers are fixed for proper PCI hotplug support,
this appears as the lesser evil compared to the danger of the
structure being freed without the caller knowing it.

Impact: replacing a bug by another, less consequential one
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/hisax/hisax.h |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 832a878..e459502 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1328,21 +1328,18 @@ void TeiFree(void);
 
 #include <linux/pci.h>
 
-/* adaptation wrapper for old usage
- * WARNING! This is unfit for use in a PCI hotplug environment,
- * as the returned PCI device can disappear at any moment in time.
+/* This function replaces the former function pci_find_device().
+ * Unlike the latter, it takes a reference on the returned pci_dev,
+ * resulting in a reference leak. This is intentional and serves to
+ * prevent an untimely release of the PCI device structure.
  * Callers should be converted to use pci_get_device() instead.
  */
 static inline struct pci_dev *hisax_find_pci_device(unsigned int vendor,
 						    unsigned int device,
 						    struct pci_dev *from)
 {
-	struct pci_dev *pdev;
-
 	pci_dev_get(from);
-	pdev = pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from);
-	pci_dev_put(pdev);
-	return pdev;
+	return pci_get_subsys(vendor, device, PCI_ANY_ID, PCI_ANY_ID, from);
 }
 
 #endif
-- 
1.6.5.3.298.g39add

