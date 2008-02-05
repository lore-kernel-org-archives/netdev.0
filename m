From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/4] forcedeth: fix MAC address detection on network card
 (regression in 2.6.23)
Date: Tue, 05 Feb 2008 14:08:45 -0500
Message-ID: <47A8B43D.5070601@garzik.org>
References: <200802050746.m157ktY9010399@imap1.linux-foundation.org>	<47A8A90B.6010602@garzik.org> <20080205105909.fd8c6dbe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030708030606090702080804"
Cc: netdev@vger.kernel.org, michael.pyne@kdemail.net,
	AAbdulla@nvidia.com, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45606 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756574AbYBETIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 14:08:50 -0500
In-Reply-To: <20080205105909.fd8c6dbe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030708030606090702080804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
> 
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> NAK - this fixes one set of users, and breaks a working set of users.
>>
>> Need to add DMI check for the specific motherboard (dmi_check_system), 
>> and flip flag according to success/failure of that check.
> 
> OK :)  I added the above to the changelog for next time.
> 
> You guys can hide, but this patch isn't going away!

In the original thread, I even posted a 
fill-in-the-blanks-with-the-motherboard-name patch.  I'll attach it again...

	Jeff




--------------030708030606090702080804
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 3634223..eab85fa 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -147,6 +147,7 @@
 #include <linux/init.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -4992,6 +4993,26 @@ static int nv_close(struct net_device *dev)
 	return 0;
 }
 
+static int nv_reversed_macaddr(void)
+{
+	static const struct dmi_system_id sysids[] = {
+		{
+			.ident = "",
+			.matches = {
+				DMI_MATCH(DMI_SYS_VENDOR, ""),
+				DMI_MATCH(DMI_PRODUCT_NAME, ""),
+			},
+		},
+
+		{ }	/* terminate list */
+	};
+
+	if (dmi_check_system(sysids))
+		return 1;
+	
+	return 0;
+}
+
 static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
@@ -5187,8 +5208,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
+	if (((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
+	    (id->driver_data & DEV_HAS_CORRECT_MACADDR))) &&
+	    (!nv_reversed_macaddr())) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;

--------------030708030606090702080804--
