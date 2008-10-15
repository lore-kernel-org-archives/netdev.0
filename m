From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Thu, 16 Oct 2008 00:50:23 +0200
Message-ID: <20081015225023.GB12337@electric-eye.fr.zoreil.com>
References: <200810151357.m9FDvZqk028829@post.webmailer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org,
	kernel@vger.kernel.org
To: c4p7n@capitanio.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46466 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755929AbYJOWut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 18:50:49 -0400
Content-Disposition: inline
In-Reply-To: <200810151357.m9FDvZqk028829@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

c4p7n@capitanio.org <c4p7n@capitanio.org> :
> May be we are reading just by luck zeros and not a random perfectly
> sane address.

I would use the attached patches. The former one is mostly Ivan's one
with some rework of the debug messages. The later checks the eeprom
for its signature.

With these patches the driver notices that it can not get an address
for my 8168b but it works ok with my 8169 after both an hot and a
cold boot. Interestingly enough, the VPD is not enabled on the 8169
during the first boot.

Ivan, can you test them (and fix them afterwards :o) ) ?

-- 
Ueimor

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=a

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..e80ca26 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1947,11 +1947,11 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	u8 cfg1;
 	int vpd_cap;
 	u8 mac[8];
-	DECLARE_MAC_BUF(buf);
 
 	cfg1 = RTL_R8(Config1);
 	if (!(cfg1  & VPD)) {
-		dprintk("VPD access not enabled, enabling\n");
+		if (netif_msg_probe(tp))
+			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
 		RTL_W8(Cfg9346, Cfg9346_Unlock);
 		RTL_W8(Config1, cfg1 | VPD);
 		RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -1969,14 +1969,22 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	 */
 	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
 	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		dprintk("Reading MAC address from EEPROM failed\n");
+		if (netif_msg_probe(tp)) {
+			dev_warn(&pdev->dev,
+				 "reading MAC address from EEPROM failed\n");
+		}
 		return;
 	}
 
-	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
 
-	/* Write MAC address */
-	rtl_rar_set(tp, mac);
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
 }
 
 static int __devinit

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=b

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..f26ef24 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1944,23 +1944,34 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 				 void __iomem *ioaddr)
 {
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 cfg1;
 	int vpd_cap;
+	__le32 sig;
 	u8 mac[8];
-	DECLARE_MAC_BUF(buf);
+	u8 cfg1;
 
 	cfg1 = RTL_R8(Config1);
-	if (!(cfg1  & VPD)) {
-		dprintk("VPD access not enabled, enabling\n");
-		RTL_W8(Cfg9346, Cfg9346_Unlock);
-		RTL_W8(Config1, cfg1 | VPD);
-		RTL_W8(Cfg9346, Cfg9346_Lock);
+	if (netif_msg_probe(tp)) {
+		dev_info(&pdev->dev, "VPD access %sadvertised.\n",
+			 (cfg1  & VPD) ? "" : "not ");
 	}
 
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Config1, cfg1 | VPD);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	vpd_cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
 	if (!vpd_cap)
 		return;
 
+	if (rtl_eeprom_read(pdev, vpd_cap, 0x0000, &sig) < 0)
+		return;
+
+	if ((sig & 0xffff) != 0x8129) {
+		dev_info(&pdev->dev, "Missing EEPROM signature: %04x\n",
+			 sig & 0xffff);
+		return;
+	}
+
 	/* MAC address is stored in EEPROM at offset 0x0e
 	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
 	 * address as defined in the PCI 2.2 Specifications, but the VPD data
@@ -1969,14 +1980,22 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	 */
 	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
 	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		dprintk("Reading MAC address from EEPROM failed\n");
+		if (netif_msg_probe(tp)) {
+			dev_warn(&pdev->dev,
+				 "reading MAC address from EEPROM failed\n");
+		}
 		return;
 	}
 
-	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
 
-	/* Write MAC address */
-	rtl_rar_set(tp, mac);
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
 }
 
 static int __devinit

--fUYQa+Pmc3FrFX/N--
