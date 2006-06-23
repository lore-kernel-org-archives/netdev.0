From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: ixgb EEH/PCI errors on reset
Date: Fri, 23 Jun 2006 13:15:53 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0606231258110.3548@jbrandeb-desk.amr.corp.intel.com>
References: <20060623170958.GN8866@austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	cramerj <cramerj@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:15569 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1752019AbWFWUP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:15:56 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060623170958.GN8866@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Jun 2006, Linas Vepstas wrote:
> I've got another ixgb driver bug I'm struggling with; clues or hints
> appreciated.
> 
> I've got a patch for PCI error recovery for the ixgb, which works on
> many older kernels but seems to be broken on linux-2.6.17-rc6-mm2
> (which is ixgb version 1.0.109).  After performing a PCI reset on the
> card, I try to re-initialize the cad and the driver, with the following
> sequence:
> 
>    pci_set_master(pdev);
>    netif_carrier_off(netdev);
>    netif_stop_queue(netdev);
>    ixgb_check_options(adapter);
>    ixgb_reset(adapter);
> 
> This is only a subset of the ixgb_probe code, since I don't need to
> request regions or do any of the other setup.  However, this code
> fails in an unexpected way.  The last call invokes ixgb_mac_reset()
> which writes a reset bit, delays a few millisecs, and reads the reset
> bit.  The problem I'm seeing is that the read
> 
>   ctrl_reg = IXGB_READ_REG(hw, CTRL0);
> 
> triggers some PCI bus error that off-lines the device. Any hints
> about where to look? This doesn't occur on other driver versions,
> and doesn't occur on this driver during the ordinary probe() sequence.
> Increasing the dealy doesn't seem to help.

you probably need to do something similar to stopping the transmitter and 
receiver using the TCTL and RCTL registers, and then waiting for any 
pending master requests to finish.

Ah, it appears the code in ixgb_adapter_stop is missing a IXGB_WRITE_FLUSH 
before the msec_delay.

try this patch?  it is compile tested.


<snip>

[PATCH] ixgb: make sure to flush writes before waiting
ixgb is missing some write flushes when issuing the reset, and a few 
others for that matter.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

 drivers/net/ixgb/ixgb_ee.c |    9 +++++++++
 drivers/net/ixgb/ixgb_hw.c |    5 +++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 8357c55..2359973 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -55,6 +55,7 @@ ixgb_raise_clock(struct ixgb_hw *hw,
 	 */
 	*eecd_reg = *eecd_reg | IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 	return;
 }
@@ -74,6 +75,7 @@ ixgb_lower_clock(struct ixgb_hw *hw,
 	 */
 	*eecd_reg = *eecd_reg & ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 	return;
 }
@@ -112,6 +114,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 			eecd_reg |= IXGB_EECD_DI;
 
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
+		IXGB_WRITE_FLUSH(hw);
 
 		udelay(50);
 
@@ -208,21 +211,25 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 	/*  Deselct EEPROM  */
 	eecd_reg &= ~(IXGB_EECD_CS | IXGB_EECD_SK);
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Clock high  */
 	eecd_reg |= IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Select EEPROM  */
 	eecd_reg |= IXGB_EECD_CS;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Clock low  */
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 	return;
 }
@@ -242,11 +249,13 @@ ixgb_clock_eeprom(struct ixgb_hw *hw)
 	/*  Rising edge of clock  */
 	eecd_reg |= IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Falling edge of clock  */
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 	return;
 }
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index f7fa10e..3e08ba8 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -81,7 +81,7 @@ static uint32_t ixgb_mac_reset(struct ix
 #else
 	IXGB_WRITE_REG(hw, CTRL0, ctrl_reg);
 #endif
-
+	IXGB_WRITE_FLUSH(hw);
 	/* Delay a few ms just to allow the reset to complete */
 	msec_delay(IXGB_DELAY_AFTER_RESET);
 	ctrl_reg = IXGB_READ_REG(hw, CTRL0);
@@ -133,6 +133,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	 */
 	IXGB_WRITE_REG(hw, RCTL, IXGB_READ_REG(hw, RCTL) & ~IXGB_RCTL_RXEN);
 	IXGB_WRITE_REG(hw, TCTL, IXGB_READ_REG(hw, TCTL) & ~IXGB_TCTL_TXEN);
+	IXGB_WRITE_FLUSH(hw);
 	msec_delay(IXGB_DELAY_BEFORE_RESET);
 
 	/* Issue a global reset to the MAC.  This will reset the chip's
@@ -287,7 +288,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 #else
 	IXGB_WRITE_REG(hw, CTRL1, IXGB_CTRL1_EE_RST);
 #endif
-
+	IXGB_WRITE_FLUSH(hw);
 	/* Delay a few ms just to allow the reset to complete */
 	msec_delay(IXGB_DELAY_AFTER_EE_RESET);
 
