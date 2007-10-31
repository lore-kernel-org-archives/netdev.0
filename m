From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][RFC] Add support for the RDC R6040 Fast Ethernet
 controller
Date: Wed, 31 Oct 2007 09:07:23 -0700
Message-ID: <20071031090723.408cf228@shemminger-laptop>
References: <200710292251.43257.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49253 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753449AbXJaQHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 12:07:44 -0400
In-Reply-To: <200710292251.43257.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 22:51:42 +0100
Florian Fainelli <florian.fainelli@telecomint.eu> wrote:

> This patch adds support for the RDC R6040 MAC we can find in the RDC R-321x System-on-chips.
> This driver really needs improvements especially on the NAPI part which probably does not
> fully use the new NAPI structure.
> You will need the RDC PCI identifiers if you want to test this driver which are the following ones :
> 
> RDC_PCI_VENDOR_ID = 0x17f3
> RDC_PCI_DEVICE_ID_RDC_R6040 = 0x6040
> 
> Thank you very much in advance for your comments.
> 
> Signed-off-by: Sten Wang <sten.wang@rdc.com.tw>
> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>


**** BUG *** Don't call kfree() to free the network device; use free_netdev()

* Don't define use uppercase for variable names (NUM_MAC_TABLE)

* Use get_random_ether_addr() rather than a hardcoded table of mac addresses.

* checkpatch complains about some extra blanks, and several lines > 80 chars.

* use ethtool stubs for check_link

* add ethtool get_settings to allow use by bonding/bridging, etc.

* this is unusual coding style:
+	do {} while ((i++ < 2048) && (inw(ioaddr + 0x04) & 0x1));

* add a blank line after declarations and before code in a function

* use of global NAPI_status should be replaced by putting it in priv

* the handling of shared IRQ is wrong.
     - need to check for status == 0 || status == 0xffff and return IRQ_NONE

* don't call napi_disable() with irq's disabled in r6040_close

* poll routine shouldn't call dev_kfree_skb_irq() to free Tx buffers because
   that means going through TX softirq, just call dev_kfree_skb()

* the down routine calls pci_unmap_single with wrong length when handling
   TX buffers.

* pci id table can be cleaned up:
static struct pci_device_id r6040_pci_tbl[] = {
	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, 0x6040) },
	{ PCI_DEVICE(PCI_VENDOR_VIA, 0x3065) },
	{ 0 }
};

* use netdev_priv() consistently rather than dev->priv.
   Yes they are the same now, but that will be fixed in future.

* eliminate check for dev being NULL in IRQ handler.

* reorder functions to eliminate need for forward declarations

* get rid of R6040_PCI_CMD and pci_flags field it is unused.
  
* do you really have to have the whole chip_info at all? The only usage
   seems to be to validate the pci region size.  Do you have platforms with
   busted BIOS that set it wrong or something??



---

WARNING: no space between function name and open parenthesis '('
#1071: FILE: drivers/net/r6040.c:958:
+static int __init r6040_init (void)

WARNING: no space between function name and open parenthesis '('
#1073: FILE: drivers/net/r6040.c:960:
+	return pci_register_driver (&r6040_driver);

WARNING: no space between function name and open parenthesis '('
#1077: FILE: drivers/net/r6040.c:964:
+static void __exit r6040_cleanup (void)

WARNING: no space between function name and open parenthesis '('
#1079: FILE: drivers/net/r6040.c:966:
+	pci_unregister_driver (&r6040_driver);

total: 0 errors, 36 warnings, 1001 lines checked
Your patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.
