From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 5/15] wireless/orinoco: Update orinoco pcmcia
	driver's IRQ handling
Date: Tue, 26 Oct 2004 14:47:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098816469.3663.52.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Update orinoco pcmcia driver's IRQ handling

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco_cs.c.5-irq-handling	2004-10-26 09:28:06.330250992 -0400
+++ b/drivers/net/wireless/orinoco_cs.c	2004-10-26 09:33:00.939463584 -0400
@@ -54,19 +54,11 @@
 
 /* Module parameters */
 
-/* The old way: bit map of interrupts to choose from */
-/* This means pick from 15, 14, 12, 11, 10, 9, 7, 5, 4, and 3 */
-static uint irq_mask = 0xdeb8;
-/* Newer, simpler way of listing specific interrupts */
-static int irq_list[4] = { -1 };
-
 /* Some D-Link cards have buggy CIS. They do work at 5v properly, but
  * don't have any CIS entry for it. This workaround it... */
 static int ignore_cis_vcc; /* = 0 */
-
-MODULE_PARM(irq_mask, "i");
-MODULE_PARM(irq_list, "1-4i");
-MODULE_PARM(ignore_cis_vcc, "i");
+module_param(ignore_cis_vcc, int, 0644);
+MODULE_PARM_DESC(ignore_cis_vcc, "Allow voltage mismatch between card and socket");
 
 /********************************************************************/
 /* Magic constants						    */
@@ -162,7 +154,7 @@
 	struct orinoco_pccard *card;
 	dev_link_t *link;
 	client_reg_t client_reg;
-	int ret, i;
+	int ret;
 
 	dev = alloc_orinocodev(sizeof(*card), orinoco_cs_hard_reset);
 	if (! dev)
@@ -175,14 +167,11 @@
 	link->priv = dev;
 
 	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
+	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
 	link->irq.IRQInfo1 = IRQ_INFO2_VALID | IRQ_LEVEL_ID;
-	if (irq_list[0] == -1)
-		link->irq.IRQInfo2 = irq_mask;
-	else
-		for (i = 0; i < 4; i++)
-			link->irq.IRQInfo2 |= 1 << irq_list[i];
-	link->irq.Handler = NULL;
+	link->irq.IRQInfo2 = 0xffffffff;	/* Any ISA IRQ */
+	link->irq.Handler = orinoco_interrupt;
+	link->irq.Instance = dev; 
 
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
@@ -263,6 +252,9 @@
 		last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; \
 	} while (0)
 
+#define CFG_CHECK(fn, ret) \
+	if (ret != 0) goto next_entry
+
 static void
 orinoco_cs_config(dev_link_t *link)
 {
@@ -323,9 +315,8 @@
 		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
 		cistpl_cftable_entry_t dflt = { .index = 0 };
 
-		if (pcmcia_get_tuple_data(handle, &tuple) != 0 ||
-				pcmcia_parse_tuple(handle, &tuple, &parse) != 0)
-			goto next_entry;
+		CFG_CHECK(GetTupleData, pcmcia_get_tuple_data(handle, &tuple));
+		CFG_CHECK(ParseTuple, pcmcia_parse_tuple(handle, &tuple, &parse));
 
 		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
 			dflt = *cfg;
@@ -363,8 +354,7 @@
 			    dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
 		
 		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
+		link->conf.Attributes |= CONF_ENABLE_IRQ;
 
 		/* IO window settings */
 		link->io.NumPorts1 = link->io.NumPorts2 = 0;
@@ -390,8 +380,8 @@
 			}
 
 			/* This reserves IO space but doesn't actually enable it */
-			if (pcmcia_request_io(link->handle, &link->io) != 0)
-				goto next_entry;
+			CFG_CHECK(RequestIO,
+				  pcmcia_request_io(link->handle, &link->io));
 		}
 
 
@@ -416,22 +406,7 @@
 	 * a handler to the interrupt, unless the 'Handler' member of
 	 * the irq structure is initialized.
 	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		int i;
-
-		link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_HANDLE_PRESENT;
-		link->irq.IRQInfo1 = IRQ_INFO2_VALID | IRQ_LEVEL_ID;
-		if (irq_list[0] == -1)
-			link->irq.IRQInfo2 = irq_mask;
-		else
-			for (i=0; i<4; i++)
-				link->irq.IRQInfo2 |= 1 << irq_list[i];
-		
-  		link->irq.Handler = orinoco_interrupt; 
-  		link->irq.Instance = dev; 
-		
-		CS_CHECK(RequestIRQ, pcmcia_request_irq(link->handle, &link->irq));
-	}
+	CS_CHECK(RequestIRQ, pcmcia_request_irq(link->handle, &link->irq));
 
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
@@ -453,8 +428,6 @@
 	SET_MODULE_OWNER(dev);
 	card->node.major = card->node.minor = 0;
 
-	/* register_netdev will give us an ethX name */
-	dev->name[0] = '\0';
 	/* Tell the stack we exist */
 	if (register_netdev(dev) != 0) {
 		printk(KERN_ERR PFX "register_netdev() failed\n");
@@ -476,8 +449,7 @@
 	if (link->conf.Vpp1)
 		printk(", Vpp %d.%d", link->conf.Vpp1 / 10,
 		       link->conf.Vpp1 % 10);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq.AssignedIRQ);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
