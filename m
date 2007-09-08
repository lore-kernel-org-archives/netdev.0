From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Fri, 07 Sep 2007 19:26:21 -0700
Message-ID: <1189218381.5210.67.camel@dell>
References: <20070906.073423.74747465.davem@davemloft.net>
 <20070906154123.GC10317@gospo.rdu.redhat.com>
 <1189105530.4852.8.camel@dell>
 <20070906.125019.104036964.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, "netdev" <netdev@vger.kernel.org>,
	ananth@broadcom.com, nsankar@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2204 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbXIHB24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 21:28:56 -0400
In-Reply-To: <20070906.125019.104036964.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-06 at 12:50 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 06 Sep 2007 12:05:30 -0700
> 
> > The HT1000 bridge may very well have an MSI issue.  I'm checking with
> > ServerWorks and I will do some testing to confirm.  If confirmed, we can
> > disable MSI behind the HT1000 bridge instead of globally.  The 5714
> > issue is not caused by the HT1000 as it is not behind the HT1000.
> 
> What I'm going to do at this point is just merge the tg3
> fix into the current 2.6.23 tree right now.
> 
> Meanwhile I'll have the HT1000 MSI quirk revert ready and,
> unless we find a reason not to, I'll ask Greg KH to merge
> that patch into 2.6.24
> 
David, I see that you have already done the revert in your 2.6.23 tree.
So the following patch assumes the revert is already done.  I think it
is quite safe for this to go into 2.6.23.

[PCI]: Add MSI quirk for ServerWorks HT1000 PCIX bridge.

This is the fix for the following problem:

https://bugzilla.redhat.com/show_bug.cgi?id=227657

The bnx2 device 5706 complains about MSI not working behind a
ServerWorks HT1000 PCIX bridge. An earlier commit to fix the problem:

e3008dedff4bdc96a5f67224cd3d8d12237082a0:

"PCI: disable MSI by default on systems with Serverworks HT1000 chips"

was not entirely correct, and has been reverted.

MSI does not work on the PCIX bus because the BIOS did not set the
HT_MSI_FLAGS_ENABLE bit in the HyperTransport MSI capability on the
bridge.  We use the existing quirk_msi_ht_cap() to detect the problem
and disable MSI in all buses behind it.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Anantha Subramanyam <ananth@broadcom.com>
Cc: Naren Sankar <nsankar@broadcom.com>

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 6da5a5d..c58429b 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1703,6 +1703,9 @@ static void __devinit quirk_msi_ht_cap(struct pci_dev *dev)
 }
 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_SERVERWORKS, PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE,
 			quirk_msi_ht_cap);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_SERVERWORKS,
+			PCI_DEVICE_ID_SERVERWORKS_HT1000_PXB,
+			quirk_msi_ht_cap);
 
 /* The nVidia CK804 chipset may have 2 HT MSI mappings.
  * MSI are supported if the MSI capability set in any of these mappings.
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 3e34dc0..1bdf8be 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1428,6 +1428,7 @@
 #define PCI_DEVICE_ID_SERVERWORKS_HE	  0x0008
 #define PCI_DEVICE_ID_SERVERWORKS_LE	  0x0009
 #define PCI_DEVICE_ID_SERVERWORKS_GCNB_LE 0x0017
+#define PCI_DEVICE_ID_SERVERWORKS_HT1000_PXB	0x0036
 #define PCI_DEVICE_ID_SERVERWORKS_EPB	  0x0103
 #define PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE	0x0132
 #define PCI_DEVICE_ID_SERVERWORKS_OSB4	  0x0200


