From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Mon, 22 Oct 2007 10:44:28 -0400
Message-ID: <471CB74C.4080709@redhat.com>
References: <7DCDA0F058071B49AED9D3D7886C41BE0966AEDB@muon.jnpr.net> <47179F1F.3030202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Mack <dmack@juniper.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, esandeen@redhat.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbXJVOol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 10:44:41 -0400
In-Reply-To: <47179F1F.3030202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18/2007 01:59 PM, Kok, Auke wrote:
> David Mack wrote:
>> It appears that the needed e100 fix made it into the Fedora
>> 2.6.23.1-23.fc8 kernel. Boots reliably now.
>>
>> Huge thanks and great work, guys.
> 
> 
> DaveJ, I didn't push anything upstream. Can you verify this now works?
> 

One of our users just posted this:


We observed the same panic on a Dell Dimension 5150 (E510), although not
limited to warm boots.	We noticed that the following trace is possible:

- when starting the interface, e100_up() gets called
- it calls e100_hw_init(), which disables e100 IRQ generation
(e100_disable_irq())
- it registers the interrupt handler
- the interrupt handler (e100_intr()) gets called - this happens because the
IRQ line is shared with another device (in this case, the SATA controller)
- the interrupt handler examines the stat_ack register of the interface: even
though interrupts are disabled, an event is indicated and the interrupt handler
proceeds
- the interrupt handler calls netif_rx_schedule_prep(), which sets the
__LINK_STATE_RX_SCHED bit, and __netif_rx_schedule(), which adds the interface
to the poll list
- when the interrupt handler returns, e100_up() calls netif_poll_enable(), thus
clearing the __LINK_STATE_RX_SCHED bit
- now the NET RX softirq (net_rx_action) calls e100_poll(), which in turn calls
netif_rx_complete()
- netif_rx_complete() checks whether the __LINK_STATE_RX_SCHED bit is set and
triggers the panic

To avoid this situation, where the interrupt handler executes although e100
interrupts are disabled, we suggest the attached patch.  It lets the interrupt
handler check the interrupt mask bit before proceeding with the interrupt
handling.


Authors: Christof Efkemann <chref@tzi.de>, Kai Thomsen <kthomsen@tzi.de>
Description:
Avoid interrupt handler execution if e100 interrupts are disabled.
Checks the interrupt mask bit before proceeding with the interrupt handling.

--- drivers/net/e100.c.old	2007-10-20 18:32:40.000000000 +0200
+++ drivers/net/e100.c	2007-10-20 18:36:02.000000000 +0200
@@ -1960,11 +1960,13 @@
 	struct net_device *netdev = dev_id;
 	struct nic *nic = netdev_priv(netdev);
 	u8 stat_ack = ioread8(&nic->csr->scb.stat_ack);
+	u8 cmd_hi = ioread8(&nic->csr->scb.cmd_hi);
 
 	DPRINTK(INTR, DEBUG, "stat_ack = 0x%02X\n", stat_ack);
 
 	if(stat_ack == stat_ack_not_ours ||	/* Not our interrupt */
-	   stat_ack == stat_ack_not_present)	/* Hardware is ejected */
+	   stat_ack == stat_ack_not_present ||	/* Hardware is ejected */
+	   cmd_hi & irq_mask_all)		/* Interrupts masked */
 		return IRQ_NONE;
 
 	/* Ack interrupt(s) */
