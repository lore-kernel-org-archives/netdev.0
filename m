From: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>
Subject: RE: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow interrupt handler to disable receive interrupts at high bi-directional traffic
Date: Tue, 14 Nov 2006 11:03:46 +0530
Message-ID: <010C7BAE6783F34D9AC336EE5A01A08802BB3C0B@dbde01.ent.ti.com>
References: <20061109234604.GA17969@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from soda.ext.ti.com ([198.47.26.145]:46987 "EHLO soda.ext.ti.com")
	by vger.kernel.org with ESMTP id S1755420AbWKNFei convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 00:34:38 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061109234604.GA17969@electric-eye.fr.zoreil.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Francois Romieu [mailto:romieu@fr.zoreil.com] wrote:

> Afaics your change may disable the Rx irq right after the poll
> routine enabled it again. It will not always work either.
> 
> The (slow) timeout watchdog could grab the poll handler and hack
> the irq mask depending on whether poll was scheduled or not.

Based on your inputs I'm attaching below the updated patch.


Signed-off-by: Mansoor Ahamed <mansoor.ahamed@ti.com>

--- old/8139too.c	2006-11-14 10:44:27.000000000 +0530
+++ new/8139too.c	2006-11-14 10:44:18.000000000 +0530
@@ -1438,8 +1438,18 @@
 	if ((!(tmp & CmdRxEnb)) || (!(tmp & CmdTxEnb)))
 		RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
 
-	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16 (IntrMask, rtl8139_intr_mask);
+	local_irq_disable();
+	/* Don't enable RX if RX was already scheduled */
+	if(test_bit(__LINK_STATE_START, &dev->state) &&
+			test_bit(__LINK_STATE_RX_SCHED, &dev->state) ) {
+		/* Enable all interrupts except RX by setting the
interrupt mask. */
+		RTL_W16 (IntrMask, rtl8139_norx_intr_mask);
+	}
+	else {
+		/* Enable all known interrupts by setting the interrupt
mask. */ 
+		RTL_W16 (IntrMask, rtl8139_intr_mask);
+	}
+	local_irq_enable();
 }

Thanks
Mansoor
