From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] BUG_ON() bad input to request_irq
Date: Thu, 24 Jan 2008 09:15:10 +1100
Message-ID: <200801240915.11216.rusty@rustcorp.com.au>
References: <200801171757.59026.rusty@rustcorp.com.au> <200801171759.59029.rusty@rustcorp.com.au> <20080123140414.e1ff2263.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48204 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbYAWWQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 17:16:01 -0500
In-Reply-To: <20080123140414.e1ff2263.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 January 2008 09:04:14 Andrew Morton wrote:
> > On Thu, 17 Jan 2008 17:59:58 +1100 Rusty Russell <rusty@rustcorp.com.au>
> If no driver is passing in args which will trigger this BUG, we presumably
> don't need the patch.

You're only thinking of current code.  The BUG catches future changes, too.

> If some driver _is_ passing in args which will trigger these BUGs then it is
> presumably working OK anyway.  Taking a working system and making it go BUG
> is likely to upset people.

That's why I did the audit.  See patch below which preceeded it, which Jeff
hasn't responded to.  Breaking his drivers might make him notice :)

> IOW: WARN_ON, please.

At end of cycles, sure, but not for 2.6.25: they're even more invisible than
deprecated warnings :(

Rusty.
===
request_irq() always returns -EINVAL with a NULL handler.

I assume that these ancient network drivers were trying to find out if
an irq is available.  eepro.c expecting +EBUSY was doubly wrong.

Request_irq should BUG() on bad input, and these would have been found
earlier.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/3c503.c |    2 +-
 drivers/net/e2100.c |    2 +-
 drivers/net/eepro.c |    2 +-
 drivers/net/hp.c    |    2 +-
 kernel/irq/manage.c |    1 +
 5 files changed, 5 insertions(+), 4 deletions(-)

diff -r 0b7e4fbb6238 drivers/net/3c503.c
--- a/drivers/net/3c503.c	Thu Jan 17 15:49:34 2008 +1100
+++ b/drivers/net/3c503.c	Thu Jan 17 16:40:28 2008 +1100
@@ -379,7 +379,7 @@ el2_open(struct net_device *dev)
 
 	outb(EGACFR_NORM, E33G_GACFR);	/* Enable RAM and interrupts. */
 	do {
-	    if (request_irq (*irqp, NULL, 0, "bogus", dev) != -EBUSY) {
+	    if (can_request_irq(*irqp, 0)) {
 		/* Twinkle the interrupt, and check if it's seen. */
 		unsigned long cookie = probe_irq_on();
 		outb_p(0x04 << ((*irqp == 9) ? 2 : *irqp), E33G_IDCFR);
diff -r 0b7e4fbb6238 drivers/net/e2100.c
--- a/drivers/net/e2100.c	Thu Jan 17 15:49:34 2008 +1100
+++ b/drivers/net/e2100.c	Thu Jan 17 16:40:28 2008 +1100
@@ -202,7 +202,7 @@ static int __init e21_probe1(struct net_
 	if (dev->irq < 2) {
 		int irqlist[] = {15,11,10,12,5,9,3,4}, i;
 		for (i = 0; i < 8; i++)
-			if (request_irq (irqlist[i], NULL, 0, "bogus", NULL) != -EBUSY) {
+			if (can_request_irq(irqlist[i], 0)) {
 				dev->irq = irqlist[i];
 				break;
 			}
diff -r 0b7e4fbb6238 drivers/net/eepro.c
--- a/drivers/net/eepro.c	Thu Jan 17 15:49:34 2008 +1100
+++ b/drivers/net/eepro.c	Thu Jan 17 16:40:28 2008 +1100
@@ -914,7 +914,7 @@ static int	eepro_grab_irq(struct net_dev
 
 		eepro_sw2bank0(ioaddr); /* Switch back to Bank 0 */
 
-		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) != EBUSY) {
+		if (can_request_irq(*irqp, IRQF_SHARED)) {
 			unsigned long irq_mask;
 			/* Twinkle the interrupt, and check if it's seen */
 			irq_mask = probe_irq_on();
diff -r 0b7e4fbb6238 drivers/net/hp.c
--- a/drivers/net/hp.c	Thu Jan 17 15:49:34 2008 +1100
+++ b/drivers/net/hp.c	Thu Jan 17 16:40:28 2008 +1100
@@ -170,7 +170,7 @@ static int __init hp_probe1(struct net_d
 		int *irqp = wordmode ? irq_16list : irq_8list;
 		do {
 			int irq = *irqp;
-			if (request_irq (irq, NULL, 0, "bogus", NULL) != -EBUSY) {
+			if (can_request_irq(irq, 0)) {
 				unsigned long cookie = probe_irq_on();
 				/* Twinkle the interrupt, and check if it's seen. */
 				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
diff -r 0b7e4fbb6238 kernel/irq/manage.c
--- a/kernel/irq/manage.c	Thu Jan 17 15:49:34 2008 +1100
+++ b/kernel/irq/manage.c	Thu Jan 17 16:40:28 2008 +1100
@@ -252,6 +252,7 @@ int can_request_irq(unsigned int irq, un
 
 	return !action;
 }
+EXPORT_SYMBOL(can_request_irq);
 
 void compat_irq_chip_set_default_handler(struct irq_desc *desc)
 {
