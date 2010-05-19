From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 05/29] pcmcia: re-work pcmcia_request_irq()
Date: Wed, 19 May 2010 08:42:41 +0200
Message-ID: <1274251385-6196-5-git-send-email-linux@dominikbrodowski.net>
References: <20100519064149.GA5755@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-bluetooth@vger.kernel.org, linux-serial@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100519064149.GA5755@comet.dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Instead of the old pcmcia_request_irq() interface, drivers may now
choose between:

- calling request_irq/free_irq directly. Use the IRQ from *p_dev->irq.

- use pcmcia_request_irq(p_dev, handler_t); the PCMCIA core will
  clean up automatically on calls to pcmcia_disable_device() or
  device ejection.

- drivers still not capable of IRQF_SHARED (or not telling us so) may
  use the deprecated pcmcia_request_exclusive_irq() for the time
  being; they might receive a shared IRQ nonetheless.

CC: linux-bluetooth@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-serial@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: linux-usb@vger.kernel.org
CC: linux-ide@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 Documentation/pcmcia/driver-changes.txt          |   10 ++
 drivers/ata/pata_pcmcia.c                        |    6 +-
 drivers/bluetooth/bluecard_cs.c                  |    7 +-
 drivers/bluetooth/bt3c_cs.c                      |    7 +-
 drivers/bluetooth/btuart_cs.c                    |    7 +-
 drivers/bluetooth/dtl1_cs.c                      |    7 +-
 drivers/char/pcmcia/ipwireless/main.c            |   11 +--
 drivers/char/pcmcia/synclink_cs.c                |   12 +--
 drivers/ide/ide-cs.c                             |    8 +-
 drivers/isdn/hardware/avm/avm_cs.c               |   17 +--
 drivers/isdn/hisax/avma1_cs.c                    |   12 +--
 drivers/isdn/hisax/elsa_cs.c                     |   13 +--
 drivers/isdn/hisax/sedlbauer_cs.c                |   23 +---
 drivers/isdn/hisax/teles_cs.c                    |   13 +--
 drivers/net/pcmcia/3c574_cs.c                    |    6 +-
 drivers/net/pcmcia/3c589_cs.c                    |    7 +-
 drivers/net/pcmcia/axnet_cs.c                    |   13 +--
 drivers/net/pcmcia/com20020_cs.c                 |    8 +-
 drivers/net/pcmcia/fmvj18x_cs.c                  |   10 +--
 drivers/net/pcmcia/ibmtr_cs.c                    |    8 +-
 drivers/net/pcmcia/nmclan_cs.c                   |    6 +-
 drivers/net/pcmcia/pcnet_cs.c                    |    8 +-
 drivers/net/pcmcia/smc91c92_cs.c                 |    8 +-
 drivers/net/pcmcia/xirc2ps_cs.c                  |    7 +-
 drivers/net/wireless/airo_cs.c                   |   25 +---
 drivers/net/wireless/atmel_cs.c                  |   28 +----
 drivers/net/wireless/b43/pcmcia.c                |    5 +-
 drivers/net/wireless/hostap/hostap_cs.c          |   29 +----
 drivers/net/wireless/libertas/if_cs.c            |   21 +---
 drivers/net/wireless/orinoco/orinoco_cs.c        |   13 +--
 drivers/net/wireless/orinoco/spectrum_cs.c       |   13 +--
 drivers/net/wireless/ray_cs.c                    |    8 +-
 drivers/net/wireless/wl3501_cs.c                 |    8 +-
 drivers/parport/parport_cs.c                     |    8 +-
 drivers/pcmcia/ds.c                              |    3 +-
 drivers/pcmcia/pcmcia_resource.c                 |  137 +++++++++-------------
 drivers/scsi/pcmcia/aha152x_stub.c               |    6 +-
 drivers/scsi/pcmcia/fdomain_stub.c               |    6 +-
 drivers/scsi/pcmcia/nsp_cs.c                     |   20 +---
 drivers/scsi/pcmcia/qlogic_stub.c                |   10 +-
 drivers/scsi/pcmcia/sym53c500_cs.c               |    6 +-
 drivers/serial/serial_cs.c                       |   27 ++---
 drivers/ssb/main.c                               |    2 +-
 drivers/staging/comedi/drivers/cb_das16_cs.c     |   26 +---
 drivers/staging/comedi/drivers/das08_cs.c        |   16 +--
 drivers/staging/comedi/drivers/ni_daq_700.c      |   23 +---
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   23 +---
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   24 +---
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    9 +-
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |   22 +---
 drivers/staging/netwave/netwave_cs.c             |    8 +-
 drivers/staging/wavelan/wavelan_cs.c             |   15 +--
 drivers/staging/wlags49_h2/wl_cs.c               |    9 +-
 drivers/usb/host/sl811_cs.c                      |   18 +--
 include/pcmcia/cs.h                              |    7 -
 include/pcmcia/ds.h                              |   11 ++-
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    9 +-
 sound/pcmcia/vx/vxpocket.c                       |    8 +-
 58 files changed, 244 insertions(+), 593 deletions(-)

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 446f43b..3268a9a 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,14 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* New IRQ request rules (as of 2.6.35)
+   Instead of the old pcmcia_request_irq() interface, drivers may now
+   choose between:
+   - calling request_irq/free_irq directly. Use the IRQ from *p_dev->irq.
+   - use pcmcia_request_irq(p_dev, handler_t); the PCMCIA core will
+     clean up automatically on calls to pcmcia_disable_device() or
+     device ejection.
+   - drivers still not capable of IRQF_SHARED (or not telling us so) may
+     use the deprecated pcmcia_request_exclusive_irq() for the time
+     being; they might receive a shared IRQ nonetheless.
 
 * no cs_error / CS_CHECK / CONFIG_PCMCIA_DEBUG (as of 2.6.33)
    Instead of the cs_error() callback or the CS_CHECK() macro, please use
diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index d94b8f0..2aab1e0 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -268,7 +268,6 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	pdev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	pdev->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	pdev->io.IOAddrLines = 3;
-	pdev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	pdev->conf.Attributes = CONF_ENABLE_IRQ;
 	pdev->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -293,8 +292,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	}
 	io_base = pdev->io.BasePort1;
 	ctl_base = stk->ctl_base;
-	ret = pcmcia_request_irq(pdev, &pdev->irq);
-	if (ret)
+	if (!pdev->irq)
 		goto failed;
 
 	ret = pcmcia_request_configuration(pdev, &pdev->conf);
@@ -344,7 +342,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	}
 
 	/* activate */
-	ret = ata_host_activate(host, pdev->irq.AssignedIRQ, ata_sff_interrupt,
+	ret = ata_host_activate(host, pdev->irq, ata_sff_interrupt,
 				IRQF_SHARED, &pcmcia_sht);
 	if (ret)
 		goto failed;
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index d9bf87c..a34653d 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -869,9 +869,6 @@ static int bluecard_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
-	link->irq.Handler = bluecard_interrupt;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -908,9 +905,9 @@ static int bluecard_config(struct pcmcia_device *link)
 	if (i != 0)
 		goto failed;
 
-	i = pcmcia_request_irq(link, &link->irq);
+	i = pcmcia_request_irq(link, bluecard_interrupt);
 	if (i != 0)
-		link->irq.AssignedIRQ = 0;
+		goto failed;
 
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 027cb8b..1ad9694 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -661,9 +661,6 @@ static int bt3c_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
-	link->irq.Handler = bt3c_interrupt;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -743,9 +740,9 @@ static int bt3c_config(struct pcmcia_device *link)
 	goto failed;
 
 found_port:
-	i = pcmcia_request_irq(link, &link->irq);
+	i = pcmcia_request_irq(link, &bt3c_interrupt);
 	if (i != 0)
-		link->irq.AssignedIRQ = 0;
+		goto failed;
 
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 60c0953..1073d66 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -590,9 +590,6 @@ static int btuart_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
-	link->irq.Handler = btuart_interrupt;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -672,9 +669,9 @@ static int btuart_config(struct pcmcia_device *link)
 	goto failed;
 
 found_port:
-	i = pcmcia_request_irq(link, &link->irq);
+	i = pcmcia_request_irq(link, btuart_interrupt);
 	if (i != 0)
-		link->irq.AssignedIRQ = 0;
+		goto failed;
 
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 1778831..3d72afd 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -575,9 +575,6 @@ static int dtl1_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
-	link->irq.Handler = dtl1_interrupt;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
@@ -621,9 +618,9 @@ static int dtl1_config(struct pcmcia_device *link)
 	if (pcmcia_loop_config(link, dtl1_confcheck, NULL) < 0)
 		goto failed;
 
-	i = pcmcia_request_irq(link, &link->irq);
+	i = pcmcia_request_irq(link, dtl1_interrupt);
 	if (i != 0)
-		link->irq.AssignedIRQ = 0;
+		goto failed;
 
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index dff24da..2237890 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -195,9 +195,6 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = ipwireless_interrupt;
-
 	INIT_WORK(&ipw->work_reboot, signalled_reboot_work);
 
 	ipwireless_init_hardware_v1(ipw->hardware, link->io.BasePort1,
@@ -205,8 +202,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 				    ipw->is_v2_card, signalled_reboot_callback,
 				    ipw);
 
-	ret = pcmcia_request_irq(link, &link->irq);
-
+	ret = pcmcia_request_irq(link, ipwireless_interrupt);
 	if (ret != 0)
 		goto exit;
 
@@ -217,7 +213,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 			(unsigned int) link->io.BasePort1,
 			(unsigned int) (link->io.BasePort1 +
 				link->io.NumPorts1 - 1),
-			(unsigned int) link->irq.AssignedIRQ);
+			(unsigned int) link->irq);
 	if (ipw->attr_memory && ipw->common_memory)
 		printk(KERN_INFO IPWIRELESS_PCCARD_NAME
 			": attr memory 0x%08lx-0x%08lx, common memory 0x%08lx-0x%08lx\n",
@@ -271,8 +267,6 @@ exit:
 
 static void release_ipwireless(struct ipw_dev *ipw)
 {
-	pcmcia_disable_device(ipw->link);
-
 	if (ipw->common_memory) {
 		release_mem_region(ipw->request_common_memory.Base,
 				ipw->request_common_memory.Size);
@@ -288,7 +282,6 @@ static void release_ipwireless(struct ipw_dev *ipw)
 	if (ipw->attr_memory)
 		pcmcia_release_window(ipw->link, ipw->handle_attr_memory);
 
-	/* Break the link with Card Services */
 	pcmcia_disable_device(ipw->link);
 }
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index c31a0d9..027690b 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -552,10 +552,6 @@ static int mgslpc_probe(struct pcmcia_device *link)
 
     /* Initialize the struct pcmcia_device structure */
 
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = NULL;
-
     link->conf.Attributes = 0;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -608,9 +604,7 @@ static int mgslpc_config(struct pcmcia_device *link)
     link->conf.ConfigIndex = 8;
     link->conf.Present = PRESENT_OPTION;
 
-    link->irq.Handler     = mgslpc_isr;
-
-    ret = pcmcia_request_irq(link, &link->irq);
+    ret = pcmcia_request_irq(link, mgslpc_isr);
     if (ret)
 	    goto failed;
     ret = pcmcia_request_configuration(link, &link->conf);
@@ -618,7 +612,7 @@ static int mgslpc_config(struct pcmcia_device *link)
 	    goto failed;
 
     info->io_base = link->io.BasePort1;
-    info->irq_level = link->irq.AssignedIRQ;
+    info->irq_level = link->irq;
 
     /* add to linked list of devices */
     sprintf(info->node.dev_name, "mgslpc0");
@@ -628,7 +622,7 @@ static int mgslpc_config(struct pcmcia_device *link)
     printk(KERN_INFO "%s: index 0x%02x:",
 	   info->node.dev_name, link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	    printk(", irq %d", link->irq.AssignedIRQ);
+	    printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
 	    printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		   link->io.BasePort1+link->io.NumPorts1-1);
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index b854508..17ad91e 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -102,7 +102,6 @@ static int ide_probe(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.IOAddrLines = 3;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -285,8 +284,7 @@ static int ide_config(struct pcmcia_device *link)
     io_base = link->io.BasePort1;
     ctl_base = stk->ctl_base;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
@@ -299,11 +297,11 @@ static int ide_config(struct pcmcia_device *link)
     if (is_kme)
 	outb(0x81, ctl_base+1);
 
-     host = idecs_register(io_base, ctl_base, link->irq.AssignedIRQ, link);
+     host = idecs_register(io_base, ctl_base, link->irq, link);
      if (host == NULL && link->io.NumPorts1 == 0x20) {
 	    outb(0x02, ctl_base + 0x10);
 	    host = idecs_register(io_base + 0x10, ctl_base + 0x10,
-				  link->irq.AssignedIRQ, link);
+				  link->irq, link);
     }
 
     if (host == NULL)
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 94b796d..0d485f6 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -107,9 +107,6 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
     p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     p_dev->io.NumPorts2 = 0;
 
-    /* Interrupt setup */
-    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
@@ -172,7 +169,7 @@ static int avmcs_configcheck(struct pcmcia_device *p_dev,
 static int avmcs_config(struct pcmcia_device *link)
 {
     local_info_t *dev;
-    int i;
+    int i = -1;
     char devname[128];
     int cardtype;
     int (*addcard)(unsigned int port, unsigned irq);
@@ -190,11 +187,7 @@ static int avmcs_config(struct pcmcia_device *link)
 	    return -ENODEV;
 
     do {
-	/*
-	 * allocate an interrupt line
-	 */
-	i = pcmcia_request_irq(link, &link->irq);
-	if (i != 0) {
+	if (!link->irq) {
 	    /* undo */
 	    pcmcia_disable_device(link);
 	    break;
@@ -249,9 +242,9 @@ static int avmcs_config(struct pcmcia_device *link)
 	default:
         case AVM_CARDTYPE_B1: addcard = b1pcmcia_addcard_b1; break;
     }
-    if ((i = (*addcard)(link->io.BasePort1, link->irq.AssignedIRQ)) < 0) {
+    if ((i = (*addcard)(link->io.BasePort1, link->irq)) < 0) {
         printk(KERN_ERR "avm_cs: failed to add AVM-%s-Controller at i/o %#x, irq %d\n",
-		dev->node.dev_name, link->io.BasePort1, link->irq.AssignedIRQ);
+		dev->node.dev_name, link->io.BasePort1, link->irq);
 	avmcs_release(link);
 	return -ENODEV;
     }
@@ -270,7 +263,7 @@ static int avmcs_config(struct pcmcia_device *link)
 
 static void avmcs_release(struct pcmcia_device *link)
 {
-	b1pcmcia_delcard(link->io.BasePort1, link->irq.AssignedIRQ);
+	b1pcmcia_delcard(link->io.BasePort1, link->irq);
 	pcmcia_disable_device(link);
 } /* avmcs_release */
 
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 8d1d63a..3ae2176 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -119,9 +119,6 @@ static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
     p_dev->io.Attributes2 = IO_DATA_PATH_WIDTH_16;
     p_dev->io.IOAddrLines = 5;
 
-    /* Interrupt setup */
-    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
@@ -177,7 +174,7 @@ static int avma1cs_configcheck(struct pcmcia_device *p_dev,
 static int __devinit avma1cs_config(struct pcmcia_device *link)
 {
     local_info_t *dev;
-    int i;
+    int i = -1;
     char devname[128];
     IsdnCard_t	icard;
     int busy = 0;
@@ -197,8 +194,7 @@ static int __devinit avma1cs_config(struct pcmcia_device *link)
 	/*
 	 * allocate an interrupt line
 	 */
-	i = pcmcia_request_irq(link, &link->irq);
-	if (i != 0) {
+	if (!link->irq) {
 	    /* undo */
 	    pcmcia_disable_device(link);
 	    break;
@@ -230,9 +226,9 @@ static int __devinit avma1cs_config(struct pcmcia_device *link)
     }
 
     printk(KERN_NOTICE "avma1_cs: checking at i/o %#x, irq %d\n",
-				link->io.BasePort1, link->irq.AssignedIRQ);
+				link->io.BasePort1, link->irq);
 
-    icard.para[0] = link->irq.AssignedIRQ;
+    icard.para[0] = link->irq;
     icard.para[1] = link->io.BasePort1;
     icard.protocol = isdnprot;
     icard.typ = ISDN_CTYPE_A1_PCMCIA;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index c9f2279..8e170e4 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -136,10 +136,6 @@ static int __devinit elsa_cs_probe(struct pcmcia_device *link)
 
     local->cardnr = -1;
 
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = NULL;
-
     /*
       General socket configuration defaults can go here.  In this
       client, we assume very little, and rely on the CIS for almost
@@ -223,11 +219,8 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     if (i != 0)
 	goto failed;
 
-    i = pcmcia_request_irq(link, &link->irq);
-    if (i != 0) {
-        link->irq.AssignedIRQ = 0;
+    if (!link->irq)
 	goto failed;
-    }
 
     i = pcmcia_request_configuration(link, &link->conf);
     if (i != 0)
@@ -244,7 +237,7 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     printk(KERN_INFO "%s: index 0x%02x: ",
            dev->node.dev_name, link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
-        printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
         printk(", io 0x%04x-0x%04x", link->io.BasePort1,
                link->io.BasePort1+link->io.NumPorts1-1);
@@ -253,7 +246,7 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
                link->io.BasePort2+link->io.NumPorts2-1);
     printk("\n");
 
-    icard.para[0] = link->irq.AssignedIRQ;
+    icard.para[0] = link->irq;
     icard.para[1] = link->io.BasePort1;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_ELSA_PCMCIA;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 71b3dde..7778385 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -143,10 +143,6 @@ static int __devinit sedlbauer_probe(struct pcmcia_device *link)
     local->p_dev = link;
     link->priv = local;
 
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = NULL;
-
     /*
       General socket configuration defaults can go here.  In this
       client, we assume very little, and rely on the CIS for almost
@@ -227,9 +223,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -313,17 +307,6 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 	    goto failed;
 
     /*
-       Allocate an interrupt line.  Note that this does not assign a
-       handler to the interrupt, unless the 'Handler' member of the
-       irq structure is initialized.
-    */
-    if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-	    ret = pcmcia_request_irq(link, &link->irq);
-	    if (ret)
-		    goto failed;
-    }
-	
-    /*
        This actually configures the PCMCIA socket -- setting up
        the I/O windows and the interrupt mapping, and putting the
        card and host interface into "Memory and IO" mode.
@@ -346,7 +329,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
     if (link->conf.Vpp)
 	printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
-	printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
 	printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 	       link->io.BasePort1+link->io.NumPorts1-1);
@@ -358,7 +341,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 	       req->Base+req->Size-1);
     printk("\n");
 
-    icard.para[0] = link->irq.AssignedIRQ;
+    icard.para[0] = link->irq;
     icard.para[1] = link->io.BasePort1;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_SEDLBAUER_PCMCIA;
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index d010a0d..02dec13 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -126,10 +126,6 @@ static int __devinit teles_probe(struct pcmcia_device *link)
     local->p_dev = link;
     link->priv = local;
 
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = NULL;
-
     /*
       General socket configuration defaults can go here.  In this
       client, we assume very little, and rely on the CIS for almost
@@ -213,11 +209,8 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
     if (i != 0)
 	goto cs_failed;
 
-    i = pcmcia_request_irq(link, &link->irq);
-    if (i != 0) {
-        link->irq.AssignedIRQ = 0;
+    if (!link->irq)
         goto cs_failed;
-    }
 
     i = pcmcia_request_configuration(link, &link->conf);
     if (i != 0)
@@ -234,7 +227,7 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
     printk(KERN_INFO "%s: index 0x%02x:",
            dev->node.dev_name, link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
-        printk(", irq %d", link->irq.AssignedIRQ);
+	    printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
         printk(", io 0x%04x-0x%04x", link->io.BasePort1,
                link->io.BasePort1+link->io.NumPorts1-1);
@@ -243,7 +236,7 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
                link->io.BasePort2+link->io.NumPorts2-1);
     printk("\n");
 
-    icard.para[0] = link->irq.AssignedIRQ;
+    icard.para[0] = link->irq;
     icard.para[1] = link->io.BasePort1;
     icard.protocol = protocol;
     icard.typ = ISDN_CTYPE_TELESPCMCIA;
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 757f87b..1442831 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -283,8 +283,6 @@ static int tc574_probe(struct pcmcia_device *link)
 	spin_lock_init(&lp->window_lock);
 	link->io.NumPorts1 = 32;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = &el3_interrupt;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
@@ -353,7 +351,7 @@ static int tc574_config(struct pcmcia_device *link)
 	if (i != 0)
 		goto failed;
 
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_irq(link, el3_interrupt);
 	if (ret)
 		goto failed;
 
@@ -361,7 +359,7 @@ static int tc574_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	dev->irq = link->irq.AssignedIRQ;
+	dev->irq = link->irq;
 	dev->base_addr = link->io.BasePort1;
 
 	ioaddr = dev->base_addr;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 091e0b0..405d772 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -194,8 +194,7 @@ static int tc589_probe(struct pcmcia_device *link)
     spin_lock_init(&lp->lock);
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = &el3_interrupt;
+
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
@@ -271,7 +270,7 @@ static int tc589_config(struct pcmcia_device *link)
     if (i != 0)
 	goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
+    ret = pcmcia_request_irq(link, el3_interrupt);
     if (ret)
 	    goto failed;
 
@@ -279,7 +278,7 @@ static int tc589_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 	
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
     ioaddr = dev->base_addr;
     EL3WINDOW(0);
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 9f3d593..967547a 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -168,7 +168,6 @@ static int axnet_probe(struct pcmcia_device *link)
     info = PRIV(dev);
     info->p_dev = link;
     link->priv = dev;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -265,12 +264,9 @@ static int try_io_port(struct pcmcia_device *link)
     int j, ret;
     if (link->io.NumPorts1 == 32) {
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	if (link->io.NumPorts2 > 0) {
-	    /* for master/slave multifunction cards */
+	/* for master/slave multifunction cards */
+	if (link->io.NumPorts2 > 0)
 	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-	    link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING;
-	}
     } else {
 	/* This should be two 16-port windows */
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
@@ -336,8 +332,7 @@ static int axnet_config(struct pcmcia_device *link)
     if (ret != 0)
 	goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
     
     if (link->io.NumPorts2 == 8) {
@@ -349,7 +344,7 @@ static int axnet_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
 
     if (!get_prom(link)) {
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 21d9c9d..278438b 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -163,7 +163,6 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     p_dev->io.NumPorts1 = 16;
     p_dev->io.IOAddrLines = 16;
-    p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
     p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -275,15 +274,14 @@ static int com20020_config(struct pcmcia_device *link)
     dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
 
     dev_dbg(&link->dev, "request IRQ %d\n",
-	    link->irq.AssignedIRQ);
-    i = pcmcia_request_irq(link, &link->irq);
-    if (i != 0)
+	    link->irq);
+    if (!link->irq)
     {
 	dev_dbg(&link->dev, "requestIRQ failed totally!\n");
 	goto failed;
     }
 
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
 
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index b9dc80b..31f1a03 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -254,10 +254,6 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 5;
 
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = fjn_interrupt;
-
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -425,8 +421,6 @@ static int fmvj18x_config(struct pcmcia_device *link)
     }
 
     if (link->io.NumPorts2 != 0) {
-    	link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING;
 	ret = mfc_try_io_port(link);
 	if (ret != 0) goto failed;
     } else if (cardtype == UNGERMANN) {
@@ -437,14 +431,14 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	    if (ret)
 		    goto failed;
     }
-    ret = pcmcia_request_irq(link, &link->irq);
+    ret = pcmcia_request_irq(link, fjn_interrupt);
     if (ret)
 	    goto failed;
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
 	    goto failed;
 
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
 
     if (link->io.BasePort2 != 0) {
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 37f4a6f..0225cdf 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -156,8 +156,6 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts1 = 4;
     link->io.IOAddrLines = 16;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-    link->irq.Handler = ibmtr_interrupt;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
@@ -238,11 +236,11 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     }
     dev->base_addr = link->io.BasePort1;
 
-    ret = pcmcia_request_irq(link, &link->irq);
+    ret = pcmcia_request_exclusive_irq(link, ibmtr_interrupt);
     if (ret)
 	    goto failed;
-    dev->irq = link->irq.AssignedIRQ;
-    ti->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
+    ti->irq = link->irq;
     ti->global_int_enable=GLOBAL_INT_ENABLE+((dev->irq==9) ? 2 : dev->irq);
 
     /* Allocate the MMIO memory window */
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c717b14..b779e3a 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -463,8 +463,6 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 32;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 5;
-    link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-    link->irq.Handler = mace_interrupt;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
@@ -652,14 +650,14 @@ static int nmclan_config(struct pcmcia_device *link)
   ret = pcmcia_request_io(link, &link->io);
   if (ret)
 	  goto failed;
-  ret = pcmcia_request_irq(link, &link->irq);
+  ret = pcmcia_request_exclusive_irq(link, mace_interrupt);
   if (ret)
 	  goto failed;
   ret = pcmcia_request_configuration(link, &link->conf);
   if (ret)
 	  goto failed;
 
-  dev->irq = link->irq.AssignedIRQ;
+  dev->irq = link->irq;
   dev->base_addr = link->io.BasePort1;
 
   ioaddr = dev->base_addr;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 4c0368d..af09be4 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -264,7 +264,6 @@ static int pcnet_probe(struct pcmcia_device *link)
     info->p_dev = link;
     link->priv = dev;
 
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -488,8 +487,6 @@ static int try_io_port(struct pcmcia_device *link)
 	if (link->io.NumPorts2 > 0) {
 	    /* for master/slave multifunction cards */
 	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-	    link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING;
 	}
     } else {
 	/* This should be two 16-port windows */
@@ -559,8 +556,7 @@ static int pcnet_config(struct pcmcia_device *link)
     if (ret)
 	goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
 
     if (link->io.NumPorts2 == 8) {
@@ -574,7 +570,7 @@ static int pcnet_config(struct pcmcia_device *link)
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
 	    goto failed;
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
     if (info->flags & HAS_MISC_REG) {
 	if ((if_port == 1) || (if_port == 2))
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index ccc5537..ad061c7 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -329,8 +329,6 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 4;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = &smc_interrupt;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -453,7 +451,6 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->io.IOAddrLines = 16;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
@@ -652,7 +649,6 @@ static int osi_config(struct pcmcia_device *link)
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->io.NumPorts1 = 64;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
@@ -877,7 +873,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     if (i)
 	    goto config_failed;
 
-    i = pcmcia_request_irq(link, &link->irq);
+    i = pcmcia_request_irq(link, smc_interrupt);
     if (i)
 	    goto config_failed;
     i = pcmcia_request_configuration(link, &link->conf);
@@ -887,7 +883,7 @@ static int smc91c92_config(struct pcmcia_device *link)
     if (smc->manfid == MANFID_MOTOROLA)
 	mot_config(link);
 
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
 
     if ((if_port >= 0) && (if_port <= 2))
 	dev->if_port = if_port;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 4d1802e..c9e7d7d 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -555,7 +555,6 @@ xirc2ps_probe(struct pcmcia_device *link)
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 1;
-    link->irq.Handler = xirc2ps_interrupt;
 
     /* Fill in card specific entries */
     dev->netdev_ops = &netdev_ops;
@@ -841,7 +840,6 @@ xirc2ps_config(struct pcmcia_device * link)
 	    link->conf.Attributes |= CONF_ENABLE_SPKR;
 	    link->conf.Status |= CCSR_AUDIO_ENA;
 	}
-	link->irq.Attributes |= IRQ_TYPE_DYNAMIC_SHARING;
 	link->io.NumPorts2 = 8;
 	link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
@@ -866,7 +864,6 @@ xirc2ps_config(struct pcmcia_device * link)
 	}
 	printk(KNOT_XIRC "no ports available\n");
     } else {
-	link->irq.Attributes |= IRQ_TYPE_DYNAMIC_SHARING;
 	link->io.NumPorts1 = 16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
 	    link->io.BasePort1 = ioaddr;
@@ -885,7 +882,7 @@ xirc2ps_config(struct pcmcia_device * link)
      * Now allocate an interrupt line.	Note that this does not
      * actually assign a handler to the interrupt.
      */
-    if ((err=pcmcia_request_irq(link, &link->irq)))
+    if ((err=pcmcia_request_irq(link, xirc2ps_interrupt)))
 	goto config_error;
 
     /****************
@@ -982,7 +979,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	printk(KNOT_XIRC "invalid if_port requested\n");
 
     /* we can now register the device with the net subsystem */
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
 
     if (local->dingo)
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index f6036fb..7867c51 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -132,10 +132,6 @@ static int airo_probe(struct pcmcia_device *p_dev)
 
 	dev_dbg(&p_dev->dev, "airo_attach()\n");
 
-	/* Interrupt setup */
-	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.Handler = NULL;
-
 	/*
 	  General socket configuration defaults can go here.  In this
 	  client, we assume very little, and rely on the CIS for almost
@@ -212,9 +208,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -300,16 +294,8 @@ static int airo_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/*
-	  Allocate an interrupt line.  Note that this does not assign a
-	  handler to the interrupt, unless the 'Handler' member of the
-	  irq structure is initialized.
-	*/
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
 
 	/*
 	  This actually configures the PCMCIA socket -- setting up
@@ -320,7 +306,7 @@ static int airo_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 	((local_info_t *)link->priv)->eth_dev =
-		init_airo_card(link->irq.AssignedIRQ,
+		init_airo_card(link->irq,
 			       link->io.BasePort1, 1, &link->dev);
 	if (!((local_info_t *)link->priv)->eth_dev)
 		goto failed;
@@ -338,8 +324,7 @@ static int airo_config(struct pcmcia_device *link)
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1+link->io.NumPorts1-1);
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 3240791..759cdc4 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -141,10 +141,6 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 
 	dev_dbg(&p_dev->dev, "atmel_attach()\n");
 
-	/* Interrupt setup */
-	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.Handler = NULL;
-
 	/*
 	  General socket configuration defaults can go here.  In this
 	  client, we assume very little, and rely on the CIS for almost
@@ -226,9 +222,7 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
 		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
-	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -278,15 +272,9 @@ static int atmel_config(struct pcmcia_device *link)
 	if (pcmcia_loop_config(link, atmel_config_check, NULL))
 		goto failed;
 
-	/*
-	  Allocate an interrupt line.  Note that this does not assign a
-	  handler to the interrupt, unless the 'Handler' member of the
-	  irq structure is initialized.
-	*/
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
+	if (!link->irq) {
+		dev_err(&link->dev, "atmel: cannot assign IRQ: check that CONFIG_ISA is set in kernel config.");
+		goto failed;
 	}
 
 	/*
@@ -298,14 +286,8 @@ static int atmel_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	if (link->irq.AssignedIRQ == 0) {
-		printk(KERN_ALERT
-		       "atmel: cannot assign IRQ: check that CONFIG_ISA is set in kernel config.");
-		goto failed;
-	}
-
 	((local_info_t*)link->priv)->eth_dev =
-		init_atmel_card(link->irq.AssignedIRQ,
+		init_atmel_card(link->irq,
 				link->io.BasePort1,
 				did ? did->driver_info : ATMEL_FW_TYPE_NONE,
 				&link->dev,
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 609e705..0e99b63 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -98,10 +98,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (res != 0)
 		goto err_disable;
 
-	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	dev->irq.Handler = NULL; /* The handler is registered later. */
-	res = pcmcia_request_irq(dev, &dev->irq);
-	if (res != 0)
+	if (!dev->irq)
 		goto err_disable;
 
 	res = pcmcia_request_configuration(dev, &dev->conf);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index a36501d..5e2efbb 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -556,15 +556,7 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
-	else if (!(p_dev->conf.Attributes & CONF_ENABLE_IRQ)) {
-		/* At least Compaq WL200 does not have IRQInfo1 set,
-		 * but it does not work without interrupts.. */
-		printk(KERN_WARNING "Config has no IRQ info, but trying to "
-		       "enable IRQ anyway..\n");
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
-	}
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
@@ -636,18 +628,9 @@ static int prism2_config(struct pcmcia_device *link)
 	strcpy(hw_priv->node.dev_name, dev->name);
 	link->dev_node = &hw_priv->node;
 
-	/*
-	 * Allocate an interrupt line.  Note that this does not assign a
-	 * handler to the interrupt, unless the 'Handler' member of the
-	 * irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-		link->irq.Handler = prism2_interrupt;
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	ret = pcmcia_request_irq(link, prism2_interrupt);
+	if (ret)
+		goto failed;
 
 	/*
 	 * This actually configures the PCMCIA socket -- setting up
@@ -658,7 +641,7 @@ static int prism2_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	dev->irq = link->irq.AssignedIRQ;
+	dev->irq = link->irq;
 	dev->base_addr = link->io.BasePort1;
 
 	/* Finally, report what we've done */
@@ -668,7 +651,7 @@ static int prism2_config(struct pcmcia_device *link)
 		printk(", Vpp %d.%d", link->conf.Vpp / 10,
 		       link->conf.Vpp % 10);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+		printk(", irq %d", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1+link->io.NumPorts1-1);
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 6d55439..08e4e39 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -777,7 +777,7 @@ static void if_cs_release(struct pcmcia_device *p_dev)
 
 	lbs_deb_enter(LBS_DEB_CS);
 
-	free_irq(p_dev->irq.AssignedIRQ, card);
+	free_irq(p_dev->irq, card);
 	pcmcia_disable_device(p_dev);
 	if (card->iobase)
 		ioport_unmap(card->iobase);
@@ -807,8 +807,7 @@ static int if_cs_ioprobe(struct pcmcia_device *p_dev,
 	p_dev->io.NumPorts1 = cfg->io.win[0].len;
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	if (cfg->io.nwin != 1) {
@@ -837,9 +836,6 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	card->p_dev = p_dev;
 	p_dev->priv = card;
 
-	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.Handler = NULL;
-
 	p_dev->conf.Attributes = 0;
 	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -854,13 +850,8 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	 * a handler to the interrupt, unless the 'Handler' member of
 	 * the irq structure is initialized.
 	 */
-	if (p_dev->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(p_dev, &p_dev->irq);
-		if (ret) {
-			lbs_pr_err("error in pcmcia_request_irq\n");
-			goto out1;
-		}
-	}
+	if (!p_dev->irq)
+		goto out1;
 
 	/* Initialize io access */
 	card->iobase = ioport_map(p_dev->io.BasePort1, p_dev->io.NumPorts1);
@@ -883,7 +874,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 
 	/* Finally, report what we've done */
 	lbs_deb_cs("irq %d, io 0x%04x-0x%04x\n",
-	       p_dev->irq.AssignedIRQ, p_dev->io.BasePort1,
+	       p_dev->irq, p_dev->io.BasePort1,
 	       p_dev->io.BasePort1 + p_dev->io.NumPorts1 - 1);
 
 	/*
@@ -940,7 +931,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	priv->fw_ready = 1;
 
 	/* Now actually get the IRQ */
-	ret = request_irq(p_dev->irq.AssignedIRQ, if_cs_interrupt,
+	ret = request_irq(p_dev->irq, if_cs_interrupt,
 		IRQF_SHARED, DRV_NAME, card);
 	if (ret) {
 		lbs_pr_err("error in request_irq\n");
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 1d4ada1..5d29b11 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -119,10 +119,6 @@ orinoco_cs_probe(struct pcmcia_device *link)
 	card->p_dev = link;
 	link->priv = priv;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = orinoco_interrupt;
-
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
 	 * almost everything.  In most clients, many details (i.e.,
@@ -258,12 +254,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	 * Allocate an interrupt line.  Note that this does not assign
-	 * a handler to the interrupt, unless the 'Handler' member of
-	 * the irq structure is initialized.
-	 */
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_irq(link, orinoco_interrupt);
 	if (ret)
 		goto failed;
 
@@ -296,7 +287,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 
 	/* Register an interface with the stack */
 	if (orinoco_if_add(priv, link->io.BasePort1,
-			   link->irq.AssignedIRQ) != 0) {
+			   link->irq) != 0) {
 		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
 		goto failed;
 	}
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 59bda24..7a8e056 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -193,10 +193,6 @@ spectrum_cs_probe(struct pcmcia_device *link)
 	card->p_dev = link;
 	link->priv = priv;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = orinoco_interrupt;
-
 	/* General socket configuration defaults can go here.  In this
 	 * client, we assume very little, and rely on the CIS for
 	 * almost everything.  In most clients, many details (i.e.,
@@ -332,12 +328,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	 * Allocate an interrupt line.  Note that this does not assign
-	 * a handler to the interrupt, unless the 'Handler' member of
-	 * the irq structure is initialized.
-	 */
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_irq(link, orinoco_interrupt);
 	if (ret)
 		goto failed;
 
@@ -374,7 +365,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 
 	/* Register an interface with the stack */
 	if (orinoco_if_add(priv, link->io.BasePort1,
-			   link->irq.AssignedIRQ) != 0) {
+			   link->irq) != 0) {
 		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
 		goto failed;
 	}
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 11865ea..fe4642a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -321,10 +321,6 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	p_dev->io.IOAddrLines = 5;
 
-	/* Interrupt setup. For PCMCIA, driver takes what's given */
-	p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.Handler = &ray_interrupt;
-
 	/* General socket configuration */
 	p_dev->conf.Attributes = CONF_ENABLE_IRQ;
 	p_dev->conf.IntType = INT_MEMORY_AND_IO;
@@ -417,10 +413,10 @@ static int ray_config(struct pcmcia_device *link)
 	/* Now allocate an interrupt line.  Note that this does not
 	   actually assign a handler to the interrupt.
 	 */
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_irq(link, ray_interrupt);
 	if (ret)
 		goto failed;
-	dev->irq = link->irq.AssignedIRQ;
+	dev->irq = link->irq;
 
 	/* This actually configures the PCMCIA socket -- setting up
 	   the I/O windows and the interrupt mapping.
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 7b9621d..c43f05b 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1897,10 +1897,6 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	p_dev->io.Attributes1	= IO_DATA_PATH_WIDTH_8;
 	p_dev->io.IOAddrLines	= 5;
 
-	/* Interrupt setup */
-	p_dev->irq.Attributes	= IRQ_TYPE_DYNAMIC_SHARING;
-	p_dev->irq.Handler = wl3501_interrupt;
-
 	/* General socket configuration */
 	p_dev->conf.Attributes	= CONF_ENABLE_IRQ;
 	p_dev->conf.IntType	= INT_MEMORY_AND_IO;
@@ -1961,7 +1957,7 @@ static int wl3501_config(struct pcmcia_device *link)
 	/* Now allocate an interrupt line. Note that this does not actually
 	 * assign a handler to the interrupt. */
 
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_irq(link, wl3501_interrupt);
 	if (ret)
 		goto failed;
 
@@ -1972,7 +1968,7 @@ static int wl3501_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	dev->irq = link->irq.AssignedIRQ;
+	dev->irq = link->irq;
 	dev->base_addr = link->io.BasePort1;
 	SET_NETDEV_DEV(dev, &link->dev);
 	if (register_netdev(dev)) {
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 7dd370f..80c9052 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -105,7 +105,6 @@ static int parport_probe(struct pcmcia_device *link)
 
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -174,20 +173,19 @@ static int parport_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
 	    goto failed;
 
     p = parport_pc_probe_port(link->io.BasePort1, link->io.BasePort2,
-			      link->irq.AssignedIRQ, PARPORT_DMA_NONE,
+			      link->irq, PARPORT_DMA_NONE,
 			      &link->dev, IRQF_SHARED);
     if (p == NULL) {
 	printk(KERN_NOTICE "parport_cs: parport_pc_probe_port() at "
 	       "0x%3x, irq %u failed\n", link->io.BasePort1,
-	       link->irq.AssignedIRQ);
+	       link->irq);
 	goto failed;
     }
 
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 5fd2948..a2649c7 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -546,7 +546,6 @@ struct pcmcia_device *pcmcia_device_add(struct pcmcia_socket *s, unsigned int fu
 			p_dev->function_config = tmp_dev->function_config;
 			p_dev->io = tmp_dev->io;
 			p_dev->irq = tmp_dev->irq;
-			p_dev->irq_v = tmp_dev->irq_v;
 			kref_get(&p_dev->function_config->ref);
 		}
 
@@ -571,7 +570,7 @@ struct pcmcia_device *pcmcia_device_add(struct pcmcia_socket *s, unsigned int fu
 
 	dev_printk(KERN_NOTICE, &p_dev->dev,
 		   "pcmcia: registering new device %s (IRQ: %d)\n",
-		   p_dev->devname, p_dev->irq_v);
+		   p_dev->devname, p_dev->irq);
 
 	pcmcia_device_query(p_dev);
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 8dce223..f355c5a 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -408,41 +408,6 @@ out:
 } /* pcmcia_release_io */
 
 
-static int pcmcia_release_irq(struct pcmcia_device *p_dev, irq_req_t *req)
-{
-	struct pcmcia_socket *s = p_dev->socket;
-	config_t *c;
-	int ret = -EINVAL;
-
-	mutex_lock(&s->ops_mutex);
-
-	c = p_dev->function_config;
-
-	if (!p_dev->_irq)
-		goto out;
-
-	p_dev->_irq = 0;
-
-	if (c->state & CONFIG_LOCKED)
-		goto out;
-
-	if (s->pcmcia_irq != req->AssignedIRQ) {
-		dev_dbg(&s->dev, "IRQ must match assigned one\n");
-		goto out;
-	}
-
-	if (req->Handler)
-		free_irq(req->AssignedIRQ, p_dev->priv);
-
-	ret = 0;
-
-out:
-	mutex_unlock(&s->ops_mutex);
-
-	return ret;
-} /* pcmcia_release_irq */
-
-
 int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 {
 	struct pcmcia_socket *s = p_dev->socket;
@@ -681,61 +646,66 @@ out:
 EXPORT_SYMBOL(pcmcia_request_io);
 
 
-/** pcmcia_request_irq
+/**
+ * pcmcia_request_irq() - attempt to request a IRQ for a PCMCIA device
  *
- * Request_irq() reserves an irq for this client.
+ * pcmcia_request_irq() is a wrapper around request_irq which will allow
+ * the PCMCIA core to clean up the registration in pcmcia_disable_device().
+ * Drivers are free to use request_irq() directly, but then they need to
+ * call free_irq themselfves, too. Also, only IRQF_SHARED capable IRQ
+ * handlers are allowed.
  */
-
-int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
+int __must_check pcmcia_request_irq(struct pcmcia_device *p_dev,
+				    irq_handler_t handler)
 {
-	struct pcmcia_socket *s = p_dev->socket;
-	config_t *c;
-	int ret = -EINVAL, irq = p_dev->irq_v;
-	int type = IRQF_SHARED;
+	int ret;
 
-	mutex_lock(&s->ops_mutex);
+	if (!p_dev->irq)
+		return -EINVAL;
 
-	if (!(s->state & SOCKET_PRESENT)) {
-		dev_dbg(&s->dev, "No card present\n");
-		goto out;
-	}
-	c = p_dev->function_config;
-	if (c->state & CONFIG_LOCKED) {
-		dev_dbg(&s->dev, "Configuration is locked\n");
-		goto out;
-	}
+	ret = request_irq(p_dev->irq, handler, IRQF_SHARED,
+			p_dev->devname, p_dev->priv);
+	if (!ret)
+		p_dev->_irq = 1;
 
-	if (!irq) {
-		dev_dbg(&s->dev, "no IRQ available\n");
-		goto out;
-	}
+	return ret;
+}
+EXPORT_SYMBOL(pcmcia_request_irq);
 
-	if (!(req->Attributes & IRQ_TYPE_DYNAMIC_SHARING)) {
-		req->Attributes |= IRQ_TYPE_DYNAMIC_SHARING;
-		dev_printk(KERN_WARNING, &p_dev->dev, "pcmcia: the driver "
-			"needs updating to supported shared IRQ lines.\n");
-	}
 
-	if (req->Handler) {
-		ret = request_irq(irq, req->Handler, type,
-				  p_dev->devname, p_dev->priv);
-		if (ret) {
-			dev_printk(KERN_INFO, &s->dev,
-				"request_irq() failed\n");
-			goto out;
-		}
-	}
+/**
+ * pcmcia_request_exclusive_irq() - attempt to request an exclusive IRQ first
+ *
+ * pcmcia_request_exclusive_irq() is a wrapper around request_irq which
+ * attempts first to request an exclusive IRQ. If it fails, it also accepts
+ * a shared IRQ, but prints out a warning. PCMCIA drivers should allow for
+ * IRQ sharing and either use request_irq directly (then they need to call
+ * free_irq themselves, too), or the pcmcia_request_irq() function.
+ */
+int __must_check
+pcmcia_request_exclusive_irq(struct pcmcia_device *p_dev, irq_handler_t handler)
+{
+	int ret;
 
-	req->AssignedIRQ = irq;
+	if (!p_dev->irq)
+		return -EINVAL;
 
-	p_dev->_irq = 1;
+	ret = request_irq(p_dev->irq, handler, 0, p_dev->devname, p_dev->priv);
+	if (ret) {
+		ret = pcmcia_request_irq(p_dev, handler);
+		dev_printk(KERN_WARNING, &p_dev->dev, "pcmcia: "
+			"request for exclusive IRQ could not be fulfilled.\n");
+		dev_printk(KERN_WARNING, &p_dev->dev, "pcmcia: the driver "
+			"needs updating to supported shared IRQ lines.\n");
+	}
+	if (ret)
+		dev_printk(KERN_INFO, &p_dev->dev, "request_irq() failed\n");
+	else
+		p_dev->_irq = 1;
 
-	ret = 0;
-out:
-	mutex_unlock(&s->ops_mutex);
 	return ret;
-} /* pcmcia_request_irq */
-EXPORT_SYMBOL(pcmcia_request_irq);
+} /* pcmcia_request_exclusive_irq */
+EXPORT_SYMBOL(pcmcia_request_exclusive_irq);
 
 
 #ifdef CONFIG_PCMCIA_PROBE
@@ -779,7 +749,7 @@ static int pcmcia_setup_isa_irq(struct pcmcia_device *p_dev, int type)
 				  p_dev);
 		if (!ret) {
 			free_irq(irq, p_dev);
-			p_dev->irq_v = s->pcmcia_irq = irq;
+			p_dev->irq = s->pcmcia_irq = irq;
 			pcmcia_used_irq[irq]++;
 			break;
 		}
@@ -820,12 +790,12 @@ int pcmcia_setup_irq(struct pcmcia_device *p_dev)
 {
 	struct pcmcia_socket *s = p_dev->socket;
 
-	if (p_dev->irq_v)
+	if (p_dev->irq)
 		return 0;
 
 	/* already assigned? */
 	if (s->pcmcia_irq) {
-		p_dev->irq_v = s->pcmcia_irq;
+		p_dev->irq = s->pcmcia_irq;
 		return 0;
 	}
 
@@ -839,7 +809,7 @@ int pcmcia_setup_irq(struct pcmcia_device *p_dev)
 
 	/* but use the PCI irq otherwise */
 	if (s->pci_irq) {
-		p_dev->irq_v = s->pcmcia_irq = s->pci_irq;
+		p_dev->irq = s->pcmcia_irq = s->pci_irq;
 		return 0;
 	}
 
@@ -947,7 +917,8 @@ void pcmcia_disable_device(struct pcmcia_device *p_dev)
 {
 	pcmcia_release_configuration(p_dev);
 	pcmcia_release_io(p_dev, &p_dev->io);
-	pcmcia_release_irq(p_dev, &p_dev->irq);
+	if (p_dev->_irq)
+		free_irq(p_dev->irq, p_dev->priv);
 	if (p_dev->win)
 		pcmcia_release_window(p_dev, p_dev->win);
 }
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 528733b..c1de4ba 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -105,7 +105,6 @@ static int aha152x_probe(struct pcmcia_device *link)
     link->io.NumPorts1 = 0x20;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 10;
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
@@ -160,8 +159,7 @@ static int aha152x_config_cs(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
 
     ret = pcmcia_request_configuration(link, &link->conf);
@@ -172,7 +170,7 @@ static int aha152x_config_cs(struct pcmcia_device *link)
     memset(&s, 0, sizeof(s));
     s.conf        = "PCMCIA setup";
     s.io_port     = link->io.BasePort1;
-    s.irq         = link->irq.AssignedIRQ;
+    s.irq         = link->irq;
     s.scsiid      = host_id;
     s.reconnect   = reconnect;
     s.parity      = parity;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 9140406..8cb6d71 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -88,7 +88,6 @@ static int fdomain_probe(struct pcmcia_device *link)
 	link->io.NumPorts1 = 0x10;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
@@ -133,8 +132,7 @@ static int fdomain_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_request_irq(link, &link->irq);
-    if (ret)
+    if (!link->irq)
 	    goto failed;
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
@@ -144,7 +142,7 @@ static int fdomain_config(struct pcmcia_device *link)
     release_region(link->io.BasePort1, link->io.NumPorts1);
 
     /* Set configuration options for the fdomain driver */
-    sprintf(str, "%d,%d", link->io.BasePort1, link->irq.AssignedIRQ);
+    sprintf(str, "%d,%d", link->io.BasePort1, link->irq);
     fdomain_setup(str);
 
     host = __fdomain_16x0_detect(&fdomain_driver_template);
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 0212464..24c78ed 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1563,13 +1563,6 @@ static int nsp_cs_probe(struct pcmcia_device *link)
 	link->io.Attributes1	 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines	 = 10;	/* not used */
 
-	/* Interrupt setup */
-	link->irq.Attributes	 = IRQ_TYPE_EXCLUSIVE;
-
-	/* Interrupt handler */
-	link->irq.Handler	 = &nspintr;
-	link->irq.Attributes     |= IRQF_SHARED;
-
 	/* General socket configuration */
 	link->conf.Attributes	 = CONF_ENABLE_IRQ;
 	link->conf.IntType	 = INT_MEMORY_AND_IO;
@@ -1646,8 +1639,7 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		}
 
 		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-			p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 		/* IO window settings */
 		p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -1720,10 +1712,8 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto cs_failed;
 
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		if (pcmcia_request_irq(link, &link->irq))
-			goto cs_failed;
-	}
+	if (pcmcia_request_irq(link, nspintr))
+		goto cs_failed;
 
 	ret = pcmcia_request_configuration(link, &link->conf);
 	if (ret)
@@ -1741,7 +1731,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	/* Set port and IRQ */
 	data->BaseAddress = link->io.BasePort1;
 	data->NumAddress  = link->io.NumPorts1;
-	data->IrqNumber   = link->irq.AssignedIRQ;
+	data->IrqNumber   = link->irq;
 
 	nsp_dbg(NSP_DEBUG_INIT, "I/O[0x%x+0x%x] IRQ %d",
 		data->BaseAddress, data->NumAddress, data->IrqNumber);
@@ -1775,7 +1765,7 @@ static int nsp_cs_config(struct pcmcia_device *link)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
 	}
 	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		printk(", irq %d", link->irq.AssignedIRQ);
+		printk(", irq %d", link->irq);
 	}
 	if (link->io.NumPorts1) {
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index f85f094..c3a4428 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -161,7 +161,6 @@ static int qlogic_probe(struct pcmcia_device *link)
 	link->io.NumPorts1 = 16;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.Present = PRESENT_OPTION;
@@ -209,8 +208,7 @@ static int qlogic_config(struct pcmcia_device * link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_irq(link, &link->irq);
-	if (ret)
+	if (!link->irq)
 		goto failed;
 
 	ret = pcmcia_request_configuration(link, &link->conf);
@@ -227,10 +225,10 @@ static int qlogic_config(struct pcmcia_device * link)
 	/* The KXL-810AN has a bigger IO port window */
 	if (link->io.NumPorts1 == 32)
 		host = qlogic_detect(&qlogicfas_driver_template, link,
-			link->io.BasePort1 + 16, link->irq.AssignedIRQ);
+			link->io.BasePort1 + 16, link->irq);
 	else
 		host = qlogic_detect(&qlogicfas_driver_template, link,
-			link->io.BasePort1, link->irq.AssignedIRQ);
+			link->io.BasePort1, link->irq);
 	
 	if (!host) {
 		printk(KERN_INFO "%s: no SCSI devices found\n", qlogic_name);
@@ -258,7 +256,7 @@ static void qlogic_release(struct pcmcia_device *link)
 
 	scsi_remove_host(info->host);
 
-	free_irq(link->irq.AssignedIRQ, info->host);
+	free_irq(link->irq, info->host);
 	pcmcia_disable_device(link);
 
 	scsi_host_put(info->host);
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index e7564d8..6eacf4c 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -719,8 +719,7 @@ SYM53C500_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_irq(link, &link->irq);
-	if (ret)
+	if (!link->irq)
 		goto failed;
 
 	ret = pcmcia_request_configuration(link, &link->conf);
@@ -752,7 +751,7 @@ SYM53C500_config(struct pcmcia_device *link)
 	*	0x320, 0x330, 0x340, 0x350
 	*/
 	port_base = link->io.BasePort1;
-	irq_level = link->irq.AssignedIRQ;
+	irq_level = link->irq;
 
 	DEB(printk("SYM53C500: port_base=0x%x, irq=%d, fast_pio=%d\n",
 	    port_base, irq_level, USE_FAST_PIO);)
@@ -866,7 +865,6 @@ SYM53C500_probe(struct pcmcia_device *link)
 	link->io.NumPorts1 = 16;
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.IOAddrLines = 10;
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 8cfa5b1..6459252 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -343,7 +343,6 @@ static int serial_probe(struct pcmcia_device *link)
 
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
 	link->io.NumPorts1 = 8;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	if (do_sound) {
 		link->conf.Attributes |= CONF_ENABLE_SPKR;
@@ -486,7 +485,7 @@ static int simple_config(struct pcmcia_device *link)
 		}
 		if (info->slave) {
 			return setup_serial(link, info, port,
-					    link->irq.AssignedIRQ);
+					    link->irq);
 		}
 	}
 
@@ -507,10 +506,6 @@ static int simple_config(struct pcmcia_device *link)
 	return -1;
 
 found_port:
-	i = pcmcia_request_irq(link, &link->irq);
-	if (i != 0)
-		link->irq.AssignedIRQ = 0;
-
 	if (info->multi && (info->manfid == MANFID_3COM))
 		link->conf.ConfigIndex &= ~(0x08);
 
@@ -523,7 +518,7 @@ found_port:
 	i = pcmcia_request_configuration(link, &link->conf);
 	if (i != 0)
 		return -1;
-	return setup_serial(link, info, link->io.BasePort1, link->irq.AssignedIRQ);
+	return setup_serial(link, info, link->io.BasePort1, link->irq);
 }
 
 static int multi_config_check(struct pcmcia_device *p_dev,
@@ -586,13 +581,9 @@ static int multi_config(struct pcmcia_device *link)
 		}
 	}
 
-	i = pcmcia_request_irq(link, &link->irq);
-	if (i != 0) {
-		/* FIXME: comment does not fit, error handling does not fit */
-		printk(KERN_NOTICE
-		       "serial_cs: no usable port range found, giving up\n");
-		link->irq.AssignedIRQ = 0;
-	}
+	if (!link->irq)
+		dev_warn(&link->dev,
+			"serial_cs: no usable IRQ found, continuing...\n");
 
 	/*
 	 * Apply any configuration quirks.
@@ -615,11 +606,11 @@ static int multi_config(struct pcmcia_device *link)
 		if (link->conf.ConfigIndex == 1 ||
 		    link->conf.ConfigIndex == 3) {
 			err = setup_serial(link, info, base2,
-					link->irq.AssignedIRQ);
+					link->irq);
 			base2 = link->io.BasePort1;
 		} else {
 			err = setup_serial(link, info, link->io.BasePort1,
-					link->irq.AssignedIRQ);
+					link->irq);
 		}
 		info->c950ctrl = base2;
 
@@ -633,10 +624,10 @@ static int multi_config(struct pcmcia_device *link)
 		return 0;
 	}
 
-	setup_serial(link, info, link->io.BasePort1, link->irq.AssignedIRQ);
+	setup_serial(link, info, link->io.BasePort1, link->irq);
 	for (i = 0; i < info->multi - 1; i++)
 		setup_serial(link, info, base2 + (8 * i),
-				link->irq.AssignedIRQ);
+				link->irq);
 	return 0;
 }
 
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 80ff7d9..bc9bdb2 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -490,7 +490,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 			break;
 		case SSB_BUSTYPE_PCMCIA:
 #ifdef CONFIG_SSB_PCMCIAHOST
-			sdev->irq = bus->host_pcmcia->irq.AssignedIRQ;
+			sdev->irq = bus->host_pcmcia->irq;
 			dev->parent = &bus->host_pcmcia->dev;
 #endif
 			break;
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index 5632991..e0352c6 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -180,12 +180,12 @@ static int das16cs_attach(struct comedi_device *dev,
 	}
 	printk("\n");
 
-	ret = request_irq(link->irq.AssignedIRQ, das16cs_interrupt,
+	ret = request_irq(link->irq, das16cs_interrupt,
 			  IRQF_SHARED, "cb_das16_cs", dev);
 	if (ret < 0) {
 		return ret;
 	}
-	dev->irq = link->irq.AssignedIRQ;
+	dev->irq = link->irq;
 	printk("irq=%u ", dev->irq);
 
 	dev->board_ptr = das16cs_probe(dev, link);
@@ -702,10 +702,6 @@ static int das16cs_pcmcia_attach(struct pcmcia_device *link)
 	link->priv = local;
 
 	/* Initialize the pcmcia_device structure */
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = NULL;
-
 	link->conf.Attributes = 0;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -740,8 +736,7 @@ static int das16cs_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -EINVAL;
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -780,16 +775,9 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	   Allocate an interrupt line.  Note that this does not assign a
-	   handler to the interrupt, unless the 'Handler' member of the
-	   irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
+
 	/*
 	   This actually configures the PCMCIA socket -- setting up
 	   the I/O windows and the interrupt mapping, and putting the
@@ -811,7 +799,7 @@ static void das16cs_pcmcia_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq.AssignedIRQ);
+		printk(", irq %u", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 9164ce1..bd69c4f 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -172,10 +172,6 @@ static int das08_pcmcia_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.Handler = NULL;
-
 	/*
 	   General socket configuration defaults can go here.  In this
 	   client, we assume very little, and rely on the CIS for almost
@@ -229,8 +225,7 @@ static int das08_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -277,11 +272,8 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
 
 	/*
 	   This actually configures the PCMCIA socket -- setting up
@@ -304,7 +296,7 @@ static void das08_pcmcia_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq.AssignedIRQ);
+		printk(", irq %u", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 7ea6453..072bc4b 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -380,7 +380,7 @@ static int dio700_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 			return -EIO;
 		iobase = link->io.BasePort1;
 #ifdef incomplete
-		irq = link->irq.AssignedIRQ;
+		irq = link->irq;
 #endif
 		break;
 	default:
@@ -502,10 +502,6 @@ static int dio700_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = NULL;
-
 	/*
 	   General socket configuration defaults can go here.  In this
 	   client, we assume very little, and rely on the CIS for almost
@@ -577,8 +573,7 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	}
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -639,16 +634,8 @@ static void dio700_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	   Allocate an interrupt line.  Note that this does not assign a
-	   handler to the interrupt, unless the 'Handler' member of the
-	   irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
 
 	/*
 	   This actually configures the PCMCIA socket -- setting up
@@ -671,7 +658,7 @@ static void dio700_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+		printk(", irq %d", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index ddc312b..2259fb4 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -131,7 +131,7 @@ static int dio24_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 			return -EIO;
 		iobase = link->io.BasePort1;
 #ifdef incomplete
-		irq = link->irq.AssignedIRQ;
+		irq = link->irq;
 #endif
 		break;
 	default:
@@ -253,10 +253,6 @@ static int dio24_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = NULL;
-
 	/*
 	   General socket configuration defaults can go here.  In this
 	   client, we assume very little, and rely on the CIS for almost
@@ -328,8 +324,7 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	}
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -390,16 +385,8 @@ static void dio24_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	   Allocate an interrupt line.  Note that this does not assign a
-	   handler to the interrupt, unless the 'Handler' member of the
-	   irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
 
 	/*
 	   This actually configures the PCMCIA socket -- setting up
@@ -422,7 +409,7 @@ static void dio24_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+		printk(", irq %d", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 6e4ed0d..907b2ae 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -144,7 +144,7 @@ static int labpc_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 		if (!link)
 			return -EIO;
 		iobase = link->io.BasePort1;
-		irq = link->irq.AssignedIRQ;
+		irq = link->irq;
 		break;
 	default:
 		printk("bug! couldn't determine board type\n");
@@ -229,10 +229,6 @@ static int labpc_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = NULL;
-
 	/*
 	   General socket configuration defaults can go here.  In this
 	   client, we assume very little, and rely on the CIS for almost
@@ -306,9 +302,7 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 	}
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |=
-			(CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ);
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -368,16 +362,8 @@ static void labpc_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	   Allocate an interrupt line.  Note that this does not assign a
-	   handler to the interrupt, unless the 'Handler' member of the
-	   irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	if (!link->irq)
+		goto failed;
 
 	/*
 	   This actually configures the PCMCIA socket -- setting up
@@ -400,7 +386,7 @@ static void labpc_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %d", link->irq.AssignedIRQ);
+		printk(", irq %d", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index dc4849a..a6007ab 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -272,7 +272,6 @@ static int cs_attach(struct pcmcia_device *link)
 {
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
 	link->io.NumPorts1 = 16;
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
@@ -344,10 +343,8 @@ static void mio_cs_config(struct pcmcia_device *link)
 		return;
 	}
 
-	ret = pcmcia_request_irq(link, &link->irq);
-	if (ret) {
-		printk("pcmcia_request_irq() returned error: %i\n", ret);
-	}
+	if (!link->irq)
+		dev_info(&link->dev, "no IRQ available\n");
 
 	ret = pcmcia_request_configuration(link, &link->conf);
 
@@ -369,7 +366,7 @@ static int mio_cs_attach(struct comedi_device *dev, struct comedi_devconfig *it)
 	dev->driver = &driver_ni_mio_cs;
 	dev->iobase = link->io.BasePort1;
 
-	irq = link->irq.AssignedIRQ;
+	irq = link->irq;
 
 	printk("comedi%d: %s: DAQCard: io 0x%04lx, irq %u, ",
 	       dev->minor, dev->driver->driver_name, dev->iobase, irq);
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index 3325f24..7aa17f9 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1040,10 +1040,6 @@ static int daqp_cs_attach(struct pcmcia_device *link)
 	local->link = link;
 	link->priv = local;
 
-	/* Interrupt setup */
-	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-	link->irq.Handler = daqp_interrupt;
-
 	/*
 	   General socket configuration defaults can go here.  In this
 	   client, we assume very little, and rely on the CIS for almost
@@ -1105,8 +1101,7 @@ static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -1144,16 +1139,9 @@ static void daqp_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/*
-	   Allocate an interrupt line.  Note that this does not assign a
-	   handler to the interrupt, unless the 'Handler' member of the
-	   irq structure is initialized.
-	 */
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	}
+	ret = pcmcia_request_irq(link, daqp_interrupt);
+	if (ret)
+		goto failed;
 
 	/*
 	   This actually configures the PCMCIA socket -- setting up
@@ -1180,7 +1168,7 @@ static void daqp_cs_config(struct pcmcia_device *link)
 	printk(KERN_INFO "%s: index 0x%02x",
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		printk(", irq %u", link->irq.AssignedIRQ);
+		printk(", irq %u", link->irq);
 	if (link->io.NumPorts1)
 		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 		       link->io.BasePort1 + link->io.NumPorts1 - 1);
diff --git a/drivers/staging/netwave/netwave_cs.c b/drivers/staging/netwave/netwave_cs.c
index 3875a72..449e6a5 100644
--- a/drivers/staging/netwave/netwave_cs.c
+++ b/drivers/staging/netwave/netwave_cs.c
@@ -382,10 +382,6 @@ static int netwave_probe(struct pcmcia_device *link)
        link->io.Attributes2 = IO_DATA_PATH_WIDTH_16; */
     link->io.IOAddrLines = 5;
     
-    /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-    link->irq.Handler = &netwave_interrupt;
-    
     /* General socket configuration */
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
@@ -732,7 +728,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
      *  Now allocate an interrupt line.  Note that this does not
      *  actually assign a handler to the interrupt.
      */
-    ret = pcmcia_request_irq(link, &link->irq);
+    ret = pcmcia_request_irq(link, netwave_interrupt);
     if (ret)
 	    goto failed;
 
@@ -767,7 +763,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     ramBase = ioremap(req.Base, 0x8000);
     priv->ramBase = ramBase;
 
-    dev->irq = link->irq.AssignedIRQ;
+    dev->irq = link->irq;
     dev->base_addr = link->io.BasePort1;
     SET_NETDEV_DEV(dev, &link->dev);
 
diff --git a/drivers/staging/wavelan/wavelan_cs.c b/drivers/staging/wavelan/wavelan_cs.c
index 04f691d..37fa855 100644
--- a/drivers/staging/wavelan/wavelan_cs.c
+++ b/drivers/staging/wavelan/wavelan_cs.c
@@ -3850,12 +3850,8 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       if (i != 0)
 	  break;
 
-      /*
-       * Now allocate an interrupt line.  Note that this does not
-       * actually assign a handler to the interrupt.
-       */
-      i = pcmcia_request_irq(link, &link->irq);
-      if (i != 0)
+      i = pcmcia_request_interrupt(link, wavelan_interrupt);
+      if (!i)
 	  break;
 
       /*
@@ -3890,7 +3886,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
 	  break;
 
       /* Feed device with this info... */
-      dev->irq = link->irq.AssignedIRQ;
+      dev->irq = link->irq;
       dev->base_addr = link->io.BasePort1;
       netif_start_queue(dev);
 
@@ -4437,10 +4433,6 @@ wavelan_probe(struct pcmcia_device *p_dev)
   p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
   p_dev->io.IOAddrLines = 3;
 
-  /* Interrupt setup */
-  p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
-  p_dev->irq.Handler = wavelan_interrupt;
-
   /* General socket configuration */
   p_dev->conf.Attributes = CONF_ENABLE_IRQ;
   p_dev->conf.IntType = INT_MEMORY_AND_IO;
@@ -4487,7 +4479,6 @@ wavelan_probe(struct pcmcia_device *p_dev)
 
   ret = wv_hw_config(dev);
   if (ret) {
-	  dev->irq = 0;
 	  pcmcia_disable_device(p_dev);
 	  return ret;
   }
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index 9da42e6..c9d99d8 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -156,15 +156,12 @@ static int wl_adapter_attach(struct pcmcia_device *link)
     link->io.NumPorts1      = HCF_NUM_IO_PORTS;
     link->io.Attributes1    = IO_DATA_PATH_WIDTH_16;
     link->io.IOAddrLines    = 6;
-    link->irq.Attributes    = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
-    link->irq.IRQInfo1      = IRQ_INFO2_VALID | IRQ_LEVEL_ID;
-    link->irq.Handler       = &wl_isr;
     link->conf.Attributes   = CONF_ENABLE_IRQ;
     link->conf.IntType      = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex  = 5;
     link->conf.Present      = PRESENT_OPTION;
 
-    link->priv = link->irq.Instance = dev;
+    link->priv = dev;
     lp = wl_priv(dev);
     lp->link = link;
 
@@ -318,11 +315,11 @@ void wl_adapter_insert( struct pcmcia_device *link )
     link->conf.Attributes |= CONF_ENABLE_IRQ;
 
     CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, wl_isr));
     CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
 
 
-    dev->irq        = link->irq.AssignedIRQ;
+    dev->irq        = link->irq;
     dev->base_addr  = link->io.BasePort1;
 
     SET_NETDEV_DEV(dev, &handle_to_dev(link));
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 39d253e..a712788 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -163,8 +163,7 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 			dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	/* we need an interrupt */
-	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
 	/* IO window settings */
 	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
@@ -197,11 +196,8 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	/* require an IRQ and two registers */
 	if (!link->io.NumPorts1 || link->io.NumPorts1 < 2)
 		goto failed;
-	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
-		ret = pcmcia_request_irq(link, &link->irq);
-		if (ret)
-			goto failed;
-	} else
+
+	if (!link->irq)
 		goto failed;
 
 	ret = pcmcia_request_configuration(link, &link->conf);
@@ -216,12 +212,12 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	       dev->node.dev_name, link->conf.ConfigIndex);
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
-	printk(", irq %d", link->irq.AssignedIRQ);
+	printk(", irq %d", link->irq);
 	printk(", io 0x%04x-0x%04x", link->io.BasePort1,
 	       link->io.BasePort1+link->io.NumPorts1-1);
 	printk("\n");
 
-	if (sl811_hc_init(parent, link->io.BasePort1, link->irq.AssignedIRQ)
+	if (sl811_hc_init(parent, link->io.BasePort1, link->irq)
 			< 0) {
 failed:
 		printk(KERN_WARNING "sl811_cs_config failed\n");
@@ -241,10 +237,6 @@ static int sl811_cs_probe(struct pcmcia_device *link)
 	local->p_dev = link;
 	link->priv = local;
 
-	/* Initialize */
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	link->irq.Handler = NULL;
-
 	link->conf.Attributes = 0;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index af61571..a04e6ca 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -114,13 +114,6 @@ typedef struct io_req_t {
 #define IO_DATA_PATH_WIDTH_16	0x08
 #define IO_DATA_PATH_WIDTH_AUTO	0x10
 
-/* For RequestIRQ and ReleaseIRQ */
-typedef struct irq_req_t {
-	u_int		Attributes;
-	u_int		AssignedIRQ;
-	irq_handler_t	Handler;
-} irq_req_t;
-
 /* Attributes for RequestIRQ and ReleaseIRQ */
 #define IRQ_TYPE			0x03
 #define IRQ_TYPE_EXCLUSIVE		0x00
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 52ebe75..d18330b 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -91,12 +91,11 @@ struct pcmcia_device {
 	dev_node_t		*dev_node;
 	u_int			open;
 	io_req_t		io;
-	irq_req_t		irq;
 	config_req_t		conf;
 	window_handle_t		win;
 
 	/* device setup */
-	unsigned int		irq_v; /* do not use directly yet */
+	unsigned int		irq;
 
 	/* Is the device suspended? */
 	u16			suspended:1;
@@ -194,7 +193,13 @@ int pcmcia_access_configuration_register(struct pcmcia_device *p_dev,
 
 /* device configuration */
 int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req);
-int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req);
+
+int __must_check __deprecated
+pcmcia_request_exclusive_irq(struct pcmcia_device *p_dev,
+				irq_handler_t handler);
+int __must_check pcmcia_request_irq(struct pcmcia_device *p_dev,
+				irq_handler_t handler);
+
 int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 				 config_req_t *req);
 
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index dcf8539..60fddf3 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -142,11 +142,6 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.NumPorts1 = 16;
 
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-	/* FIXME: This driver should be updated to allow for dynamic IRQ sharing */
-	/* link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING; */
-
-	link->irq.Handler = pdacf_interrupt;
 	link->conf.Attributes = CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
@@ -228,7 +223,7 @@ static int pdacf_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_exclusive_irq(link, pdacf_interrupt);
 	if (ret)
 		goto failed;
 
@@ -236,7 +231,7 @@ static int pdacf_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	if (snd_pdacf_assign_resources(pdacf, link->io.BasePort1, link->irq.AssignedIRQ) < 0)
+	if (snd_pdacf_assign_resources(pdacf, link->io.BasePort1, link->irq) < 0)
 		goto failed;
 
 	link->dev_node = &pdacf->node;
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index cfd1438..5eced7a 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -162,10 +162,6 @@ static int snd_vxpocket_new(struct snd_card *card, int ibl,
 	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
 	link->io.NumPorts1 = 16;
 
-	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-
-	link->irq.Handler = &snd_vx_irq_handler;
-
 	link->conf.Attributes = CONF_ENABLE_IRQ;
 	link->conf.IntType = INT_MEMORY_AND_IO;
 	link->conf.ConfigIndex = 1;
@@ -235,7 +231,7 @@ static int vxpocket_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	ret = pcmcia_request_irq(link, &link->irq);
+	ret = pcmcia_request_exclusive_irq(link, snd_vx_irq_handler);
 	if (ret)
 		goto failed;
 
@@ -246,7 +242,7 @@ static int vxpocket_config(struct pcmcia_device *link)
 	chip->dev = &link->dev;
 	snd_card_set_dev(chip->card, chip->dev);
 
-	if (snd_vxpocket_assign_resources(chip, link->io.BasePort1, link->irq.AssignedIRQ) < 0)
+	if (snd_vxpocket_assign_resources(chip, link->io.BasePort1, link->irq) < 0)
 		goto failed;
 
 	link->dev_node = &vxp->node;
-- 
1.6.3.3
