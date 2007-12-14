From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Re: [patch 03/10] forcedeth: fix MAC address detection on
 network card (regression in 2.6.23)
Date: Fri, 14 Dec 2007 16:06:00 -0500
Message-ID: <4762F038.2050106@garzik.org>
References: <200712140002.lBE02spv025517@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010306040404070703060708"
Cc: netdev@vger.kernel.org, michael.pyne@kdemail.net,
	AAbdulla@nvidia.com, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51705 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795AbXLNVGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:06:06 -0500
In-Reply-To: <200712140002.lBE02spv025517@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010306040404070703060708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

akpm@linux-foundation.org wrote:
> From: Michael Pyne <michael.pyne@kdemail.net>
> 
> Partially revert a change to mac address detection introduced to the forcedeth
> driver.  The change was intended to correct mac address detection for newer
> nVidia chipsets where the mac address was stored in reverse order.  One of
> those chipsets appears to still have the mac address in reverse order (or at
> least, it does on my system).
> 
> The change that broke mac address detection for my card was commit
> ef756b3e56c68a4d76d9d7b9a73fa8f4f739180f "forcedeth: mac address correct"
> 
> My network card is an nVidia built-in Ethernet card, output from lspci as
> follows (with text and numeric ids):
> $ lspci | grep Ethernet
> 00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev a2)
> $ lspci -n | grep 07.0
> 00:07.0 0680: 10de:03ef (rev a2)
> 
> The vendor id is, of course, nVidia.  The device id corresponds to the
> NVIDIA_NVENET_19 entry.
> 
> The included patch fixes the MAC address detection on my system.
> Interestingly, the MAC address appears to be in the range reserved for my
> motherboard manufacturer (Gigabyte) and not nVidia.
> 
> Signed-off-by: Michael J. Pyne <michael.pyne@kdemail.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: <stable@kernel.org>
> 
> On Wed, 21 Nov 2007 15:34:52 -0800
> "Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:
> 
>> The solution is to get the OEM to update their BIOS (instead of
>> integrating this patch) since the MCP61 specs indicate that the MAC
>> Address should be in correct order from BIOS.
>>
>> By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
>> could cause it to break on other OEM systems who have implemented it
>> correctly.
>>
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623 drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623
> +++ a/drivers/net/forcedeth.c
> @@ -5551,7 +5551,7 @@ static struct pci_device_id pci_tbl[] = 
>  	},
>  	{	/* MCP61 Ethernet Controller */
>  		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
> -		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
> +		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,

As discussed in the thread (and Michael did provide dmidecode output 
IIRC), one "make everybody happy" solution is to use a technique similar 
to that found in drivers/ata/ata_piix.c to match a list of BIOS that 
have incorrect mac addresses, and clear the feature bit 
DEV_HAS_CORRECT_MACADDR.

I have attached an example patch of this approach -- someone merely 
needs to take the patch, fill in the blanks, and test it!  :)

	Jeff





--------------010306040404070703060708
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a96583c..f7aab9b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -147,6 +147,7 @@
 #include <linux/init.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -4987,6 +4988,26 @@ static int nv_close(struct net_device *dev)
 	return 0;
 }
 
+static int have_broken_macaddr(void)
+{
+	static const struct dmi_system_id brokenmac_sysids[] = {
+		{
+			.ident = "blahblah",
+			.matches = {
+				DMI_MATCH(DMI_SYS_VENDOR, "MY_VENDOR"),
+				DMI_MATCH(DMI_PRODUCT_NAME, "blahblah"),
+			},
+		},
+
+		{ }	/* terminate list */
+	};
+
+	if (dmi_check_system(brokenmac_sysids))
+		return 1;
+	
+	return 0;
+}
+
 static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
@@ -4997,6 +5018,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	u32 powerstate, txreg;
 	u32 phystate_orig = 0, phystate;
 	int phyinitialized = 0;
+	int broken_macaddr = 0;
 	DECLARE_MAC_BUF(mac);
 	static int printed_version;
 
@@ -5180,10 +5202,14 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->orig_mac[0] = readl(base + NvRegMacAddrA);
 	np->orig_mac[1] = readl(base + NvRegMacAddrB);
 
+	if (!(id->driver_data & DEV_HAS_CORRECT_MACADDR))
+		broken_macaddr = 1;
+	else if (have_broken_macaddr())
+		broken_macaddr = 1;
+
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
+	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) || (!broken_macaddr)) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;

--------------010306040404070703060708--
