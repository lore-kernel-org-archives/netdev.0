From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 25 Aug 2009 20:47:01 -0700
Message-ID: <m1prajme2y.fsf@fess.ebiederm.org>
References: <1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
	<m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org>
	<1250973787.3582.14.camel@obelisk.thedillows.org>
	<m1r5v0ogvw.fsf@fess.ebiederm.org>
	<1251169150.4023.11.camel@obelisk.thedillows.org>
	<m1prajabk8.fsf@fess.ebiederm.org>
	<1251232848.9607.15.camel@lap75545.ornl.gov>
	<m1k50r8u4p.fsf@fess.ebiederm.org>
	<20090825221903.GA13630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33768 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756583AbZHZDrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:47:06 -0400
In-Reply-To: <20090825221903.GA13630@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Wed\, 26 Aug 2009 00\:19\:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> :
> [...]
>> I am a bit curious about TxDescUnavail.  Perhaps we had a temporary
>> memory shortage and that is what was screaming?  I don't think we do
>> anything at all with that state.
>
> You are not alone, the driver completely ignores this bit.
>
> As far as I remember, the TxDescUnavail event mostly pops up when the
> driver makes an excessive use of TxPoll requests.
>
>> Perhaps the flaw here is simply not masking TxDescUnavail while we are
>> in NAPI mode ?
>
> Yes, it is worth trying.

At first blush things seem better, but it isn't sufficient.
I still have a problem with RxFIFOOver set.
r8169 screaming irq status 00000040 mask 0000ffe2 event 0000803f napi 0000001d

The patch I ran is below.

Eric

---
 drivers/net/r8169.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3b19e0c..e144bc1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3552,6 +3552,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
 	int status;
+	int count = 0;
 
 	/* loop handling interrupts until we have no new ones or
 	 * we hit a invalid/hotplug case.
@@ -3560,6 +3561,14 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	while (status && status != 0xffff) {
 		handled = 1;
 
+		if (count++ > 100) {                                                                                               
+			printk_once("r8169 screaming irq status %08x "
+				"mask %08x event %08x napi %08x\n",
+				status, tp->intr_mask, tp->intr_event,
+				tp->napi_event);
+			break;
+		}
+
 		/* Handle all of the error cases first. These will reset
 		 * the chip, so just exit the loop.
 		 */
@@ -3609,6 +3618,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 		status = RTL_R16(IntrStatus);
+		if (status == 0xffff)
+			break;
+		status &= tp->intr_mask;
 	}
 
 	return IRQ_RETVAL(handled);
-- 
1.6.2.5

