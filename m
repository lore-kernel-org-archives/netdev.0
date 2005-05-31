From: Grant Grundler <iod00d@hp.com>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Tue, 31 May 2005 08:38:19 -0700
Message-ID: <20050531153819.GA20793@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Chubb <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2004 at 04:02:44PM -0800, Michael Chan wrote:
> David, While the 2nd patch or something similar should be applied, I
> think the underlying cause of tg3_readphy() returning error should be
> further investigated.
> 
> Peter, if you provide more information, such as registers MAC_MI_MODE
> (0x454) and MAC_MI_COM (0x44c) after the failure, I can look into it.

Michael,
Peter bounced this email to me after we talked about issues he was
having with the rx8620 (HP 16-way ia64, sx1000 chipset) "IOX Core LAN".
It sounded like the same problem I tracked down with rx8620 IOX Core LAN
in March.  Here is the summary :

| In May, 2004,  tg3 v3.4 changed how MAC_LED_CTRL (0x40c) was getting
| programmed and how to determine what to program into LED_CTRL. The new
| code trusted NIC_SRAM_DATA_CFG (0x00000b58) to indicate what to write
| to LED_CTRL and MII EXT_CTRL registers. On "IOX Core Lan", SRAM was
| saying MODE_MAC (0x0) and that doesn't work.

HP is working with broadcom to figure out how to update the firmware.
Ben Malavazi <malavazi@cup.hp.com> is talking with
	Pratapa Reddy Vaka <pvaka@broadcom.com>
	'Johnny Ho' <jho@broadcom.com>

I'm not sure they are aware of the root cause. But they can probably
provide you with the process to update the onboard firmware image
should this come up again.

b57diag is one way. HP also has an FCUPDATE tool that's a bit
less dangerous/more user friendly. FCUPDATE needs a newer EFI
driver to operate correctly so it's non-trivial to get started as well.
I'm hoping one of the two can be scripted to auto update.

I'm told rx5670 Core LAN firmware was the original image used by the
rx8620 IOX Core LAN team and may also exhibit the same problem.
I've not heard any trouble reports so far on rx5670 but please
forward them to me if you do.

Please do NOT apply the appended patch - it's just a temp workaround
until the owners of the "IOX Core LAN" and Broadcom can get their
act together.  The patch appended below is for RHEL3u4 (tg3 v3.10RH)
but should apply (with fuzz) to any tg3 v3.4 or later.

The patch adds a "quirk" (bug workaround) to overide the SRAM value
and use LED_CTRL_MODE_PHY_1 (0x00000800) instead.  This results in
LNK3_LED_MODE (0x2) getting written to MII_TG3_EXT_CTRL (0x10) for
bcm5700/5701 chips.  I do NOT understand why programming the
MII_TG3_EXT_CTRL register differently will change how auto-negotiation
works.

hth,
grant

--- orig/drivers/net/tg3.c 2005-03-19 21:39:25.000000000 -0600
+++ ggg/drivers/net/tg3.c	2005-03-20 13:17:50.000000000 -0600
@@ -7090,9 +7089,20 @@ static int __devinit tg3_phy_probe(struc
 		};
 
 		if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) &&
-		    tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)
-			tp->led_ctrl = LED_CTRL_MODE_PHY_2;
+		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
+			/* Quirks: firmware is wrong */
+			switch (tp->pdev->subsystem_vendor) {
+			case PCI_VENDOR_ID_DELL:
+				tp->led_ctrl = LED_CTRL_MODE_PHY_2;
+				break;
+
+			case PCI_VENDOR_ID_HP:
+				/* HP IOX Core Lan 1000Base-T [A7109AX] */
+				if (tp->pdev->subsystem_device == 0x12c1)
+					tp->led_ctrl = LED_CTRL_MODE_PHY_1;
+				break;
+			}
+		}
 
 		if (((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) ||
 		     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
