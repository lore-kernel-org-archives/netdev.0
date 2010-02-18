From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm : fix /sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Thu, 18 Feb 2010 09:22:53 -0500
Message-ID: <201002181422.o1IEMrGo004602@thirdoffive.cmf.nrl.navy.mil>
References: <20100214175136.GA15891@frolo.macqel>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:41863 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab0BROXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 09:23:08 -0500
In-reply-to: <20100214175136.GA15891@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20100214175136.GA15891@frolo.macqel>,Philippe De Muyter writes:
>cxacru itself does the right thing : as soon as carrier state is known,
>signal is set to ATM_PHY_SIG_LOST or ATM_PHY_SIG_FOUND, but
>atm_sysfs.c::show_carrier is wrong.

so, i was thinking about something like this.  atm_dev->signal is
initializated to _LOST (because it is at this point), but most drivers
will set ->signal to _FOUND since they dont handle detecting carrier
when they finish their hardware initialization.  the usb atm layer 
is the major exception here, and it appears that they already handle
the atm_dev->signal status correctly.  the minor exception being
"unknown line state" -- i am going to assume LOST is the best choice
for this case.

please try this and let me know if it fixes your problem.

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index 5effec6..2b9315f 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -134,6 +134,7 @@ static int __init adummy_init(void)
 	}
 
 	list_add(&adummy_dev->entry, &adummy_devs);
+	atm_dev->signal = ATM_PHY_SIG_FOUND;
 out:
 	return err;
 
diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 8af2341..31e9baa 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2269,6 +2269,7 @@ static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_
 	// enable host interrupts
 	interrupts_on (dev);
 
+	dev->atm_dev->signal = ATM_PHY_SIG_FOUND;
 out:
 	return err;
 
diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 02ad83d..82ae3cc 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -375,6 +375,7 @@ static int atmtcp_create(int itf,int persist,struct atm_dev **result)
 	dev->dev_data = dev_data;
 	PRIV(dev)->vcc = NULL;
 	PRIV(dev)->persist = persist;
+	dev->signal = ATM_PHY_SIG_FOUND;
 	if (result) *result = dev;
 	return 0;
 }
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index cd5049a..b6cb376 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1923,6 +1923,7 @@ static int __devinit firestream_init_one (struct pci_dev *pci_dev,
 
 	fs_dev->next = fs_boards;
 	fs_boards = fs_dev;
+	atm_dev->signal = ATM_PHY_SIG_FOUND;
 	return 0;
 
  err_out_free_atm_dev:
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index f7d6eba..ad2d919 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2637,6 +2637,7 @@ fore200e_init(struct fore200e* fore200e)
 
     /* all done, board initialization is now complete */
     fore200e->state = FORE200E_STATE_COMPLETE;
+    fore200e->atm_dev->signal = ATM_PHY_SIG_FOUND;
     return 0;
 }
 
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index e8c6529..ae83f9e 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1528,6 +1528,8 @@ he_start(struct atm_dev *dev)
 		suni_init(he_dev->atm_dev);
 	if (he_dev->atm_dev->phy && he_dev->atm_dev->phy->start)
 		he_dev->atm_dev->phy->start(he_dev->atm_dev);
+#else
+	he_dev->atm_dev->signal = ATM_PHY_SIG_FOUND;
 #endif /* CONFIG_ATM_HE_USE_SUNI */
 
 	if (sdh) {
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 4e49021..269c01f 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2827,6 +2827,7 @@ static int __devinit hrz_probe(struct pci_dev *pci_dev, const struct pci_device_
 	dev->housekeeping.data = (unsigned long) dev;
 	mod_timer(&dev->housekeeping, jiffies);
 
+	dev->atm_dev->signal = ATM_PHY_SIG_FOUND;
 out:
 	return err;
 
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 01f36c0..adc5eee 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3715,6 +3715,8 @@ idt77252_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 		err = -EIO;
 		goto err_out_deinit_card;
 	}
+#else
+	dev->signal = ATM_PHY_SIG_FOUND;
 #endif	/* CONFIG_ATM_IDT77252_USE_SUNI */
 
 	card->sramsize = probe_sram(card);
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 7fe7c32..446cc67 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2250,6 +2250,7 @@ static int __devinit lanai_dev_open(struct atm_dev *atmdev)
 	    "board_rev=%d\n", lanai->number,
 	    lanai->type==lanai2 ? "2" : "HB", (unsigned int) lanai->serialno,
 	    (unsigned int) lanai->serialno, lanai->board_rev);
+	atmdev->signal = ATM_PHY_SIG_FOUND;
 	return 0;
 
     error_vcctable:
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 5083840..02fb6a6 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -815,14 +815,18 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
    card->atmdev->link_rate = card->max_pcr;
    card->atmdev->phy = NULL;
 
-#ifdef CONFIG_ATM_NICSTAR_USE_SUNI
    if (card->max_pcr == ATM_OC3_PCR)
+#ifdef CONFIG_ATM_NICSTAR_USE_SUNI
       suni_init(card->atmdev);
+#else
+       card->atmdev->signal = ATM_PHY_SIG_FOUND;
 #endif /* CONFIG_ATM_NICSTAR_USE_SUNI */
 
-#ifdef CONFIG_ATM_NICSTAR_USE_IDT77105
    if (card->max_pcr == ATM_25_PCR)
+#ifdef CONFIG_ATM_NICSTAR_USE_IDT77105
       idt77105_init(card->atmdev);
+#else
+      card->atmdev->signal = ATM_PHY_SIG_FOUND;
 #endif /* CONFIG_ATM_NICSTAR_USE_IDT77105 */
 
    if (card->atmdev->phy && card->atmdev->phy->start)
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 51eed67..0e505f5 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1245,7 +1245,7 @@ static int atm_init(struct solos_card *card)
 		card->atmdev[i]->ci_range.vci_bits = 16;
 		card->atmdev[i]->dev_data = card;
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
-		card->atmdev[i]->signal = ATM_PHY_SIG_UNKNOWN;
+		card->atmdev[i]->signal = ATM_PHY_SIG_LOST;
 
 		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 		if (!skb) {
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 2e9635b..99712f0 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1345,6 +1345,8 @@ static int __devinit zatm_start(struct atm_dev *dev)
 	zout(0xffffffff,IMR); /* enable interrupts */
 	/* enable TX & RX */
 	zout(zin(GMR) | uPD98401_GMR_SE | uPD98401_GMR_RE,GMR);
+
+	dev->signal = ATM_PHY_SIG_FOUND;
 done:
 	return error;
 
diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
index 56802d2..febe1f0 100644
--- a/drivers/usb/atm/cxacru.c
+++ b/drivers/usb/atm/cxacru.c
@@ -803,7 +803,7 @@ static void cxacru_poll_status(struct work_struct *work)
 		break;
 
 	default:
-		atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+		atm_dev->signal = ATM_PHY_SIG_LOST;
 		atm_info(usbatm, "Unknown line state %02x\n", instance->line_status);
 		break;
 	}
diff --git a/drivers/usb/atm/speedtch.c b/drivers/usb/atm/speedtch.c
index 3e86240..fe19fe4 100644
--- a/drivers/usb/atm/speedtch.c
+++ b/drivers/usb/atm/speedtch.c
@@ -536,7 +536,7 @@ static void speedtch_check_status(struct work_struct *work)
 			break;
 
 		case 0x08:
-			atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+			atm_dev->signal = ATM_PHY_SIG_LOST;
 			atm_info(usbatm, "ADSL line is blocked?\n");
 			break;
 
@@ -565,7 +565,7 @@ static void speedtch_check_status(struct work_struct *work)
 			break;
 
 		default:
-			atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+			atm_dev->signal = ATM_PHY_SIG_LOST;
 			atm_info(usbatm, "unknown line state %02x\n", status);
 			break;
 		}
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index fbea856..10899ec 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -963,7 +963,7 @@ static int usbatm_atm_init(struct usbatm_data *instance)
 
 	atm_dev->ci_range.vpi_bits = ATM_CI_MAX;
 	atm_dev->ci_range.vci_bits = ATM_CI_MAX;
-	atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
+	atm_dev->signal = ATM_PHY_SIG_LOST;
 
 	/* temp init ATM device, set to 128kbit */
 	atm_dev->link_rate = 128 * 1000 / 424;
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 817b237..6e3db35 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -290,7 +290,6 @@ enum {
 
 
 #define ATM_PHY_SIG_LOST    0	/* no carrier/light */
-#define ATM_PHY_SIG_UNKNOWN 1	/* carrier/light status is unknown */
 #define ATM_PHY_SIG_FOUND   2	/* carrier/light okay */
 
 #define ATM_ATMOPT_CLP	1	/* set CLP bit */
diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index f693b78..a560857 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -65,7 +65,7 @@ static ssize_t show_carrier(struct device *cdev,
 	struct atm_dev *adev = to_atm_dev(cdev);
 
 	pos += sprintf(pos, "%d\n",
-		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
+		       adev->signal == ATM_PHY_SIG_FOUND);
 
 	return pos - buf;
 }
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 9008290..2d5f95f 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -38,7 +38,7 @@ static struct atm_dev *__alloc_atm_dev(const char *type)
 	if (!dev)
 		return NULL;
 	dev->type = type;
-	dev->signal = ATM_PHY_SIG_UNKNOWN;
+	dev->signal = ATM_PHY_SIG_LOST;
 	dev->link_rate = ATM_OC3_PCR;
 	spin_lock_init(&dev->lock);
 	INIT_LIST_HEAD(&dev->local);

