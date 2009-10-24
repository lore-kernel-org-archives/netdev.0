From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 10/16] pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (wireless)
Date: Sat, 24 Oct 2009 21:43:00 +0200
Message-ID: <1256413386-20501-10-git-send-email-linux@dominikbrodowski.net>
References: <20091024194219.GA19546@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:55665 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751882AbZJXTnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 15:43:17 -0400
In-Reply-To: <20091024194219.GA19546@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert PCMCIA drivers to use the dynamic debug infrastructure, instead=
 of
requiring manual settings of PCMCIA_DEBUG.

Also, remove all usages of the CS_CHECK macro and replace them with pro=
per
Linux style calling and return value checking. The extra error reportin=
g may
be dropped, as the PCMCIA core already complains about any (non-driver-=
author)
errors.

CC: linux-wireless@vger.kernel.org
CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/wireless/airo_cs.c             |   48 +++++----------
 drivers/net/wireless/atmel_cs.c            |   46 +++++----------
 drivers/net/wireless/hostap/hostap_cs.c    |   23 +++-----
 drivers/net/wireless/netwave_cs.c          |   88 +++++++++++---------=
-------
 drivers/net/wireless/orinoco/orinoco_cs.c  |   27 +++-----
 drivers/net/wireless/orinoco/spectrum_cs.c |   54 +++++++++---------
 drivers/net/wireless/wavelan_cs.c          |   24 --------
 drivers/net/wireless/wl3501_cs.c           |   67 ++++++++------------=
--
 8 files changed, 136 insertions(+), 241 deletions(-)

diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo=
_cs.c
index d0593ed..a1b84fc 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -43,21 +43,6 @@
=20
 #include "airo.h"
=20
-/*
-   All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
-   you do not define PCMCIA_DEBUG at all, all the debug code will be
-   left out.  If you compile with PCMCIA_DEBUG=3D0, the debug code wil=
l
-   be present but disabled -- but it can then be enabled for specific
-   modules at load time with a 'pc_debug=3D#' option to insmod.
-*/
-#ifdef PCMCIA_DEBUG
-static int pc_debug =3D PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-static char *version =3D "$Revision: 1.2 $";
-#define DEBUG(n, args...) if (pc_debug > (n)) printk(KERN_DEBUG args);
-#else
-#define DEBUG(n, args...)
-#endif
=20
 /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
=20
@@ -145,7 +130,7 @@ static int airo_probe(struct pcmcia_device *p_dev)
 {
 	local_info_t *local;
=20
-	DEBUG(0, "airo_attach()\n");
+	dev_dbg(&p_dev->dev, "airo_attach()\n");
=20
 	/* Interrupt setup */
 	p_dev->irq.Attributes =3D IRQ_TYPE_DYNAMIC_SHARING;
@@ -184,7 +169,7 @@ static int airo_probe(struct pcmcia_device *p_dev)
=20
 static void airo_detach(struct pcmcia_device *link)
 {
-	DEBUG(0, "airo_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "airo_detach\n");
=20
 	airo_release(link);
=20
@@ -204,9 +189,6 @@ static void airo_detach(struct pcmcia_device *link)
=20
   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
=20
-#define CS_CHECK(fn, ret) \
-do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_failed=
; } while (0)
-
 static int airo_cs_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
@@ -291,11 +273,11 @@ static int airo_config(struct pcmcia_device *link=
)
 {
 	local_info_t *dev;
 	win_req_t *req;
-	int last_fn, last_ret;
+	int ret;
=20
 	dev =3D link->priv;
=20
-	DEBUG(0, "airo_config(0x%p)\n", link);
+	dev_dbg(&link->dev, "airo_config\n");
=20
 	req =3D kzalloc(sizeof(win_req_t), GFP_KERNEL);
 	if (!req)
@@ -315,8 +297,8 @@ static int airo_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	last_ret =3D pcmcia_loop_config(link, airo_cs_config_check, req);
-	if (last_ret)
+	ret =3D pcmcia_loop_config(link, airo_cs_config_check, req);
+	if (ret)
 		goto failed;
=20
 	/*
@@ -324,21 +306,25 @@ static int airo_config(struct pcmcia_device *link=
)
 	  handler to the interrupt, unless the 'Handler' member of the
 	  irq structure is initialized.
 	*/
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
+		ret =3D pcmcia_request_irq(link, &link->irq);
+		if (ret)
+			goto failed;
+	}
=20
 	/*
 	  This actually configures the PCMCIA socket -- setting up
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
-	CS_CHECK(RequestConfiguration,
-		 pcmcia_request_configuration(link, &link->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
 	((local_info_t *)link->priv)->eth_dev =3D
 		init_airo_card(link->irq.AssignedIRQ,
 			       link->io.BasePort1, 1, &handle_to_dev(link));
 	if (!((local_info_t *)link->priv)->eth_dev)
-		goto cs_failed;
+		goto failed;
=20
 	/*
 	  At this point, the dev_node_t structure(s) need to be
@@ -368,8 +354,6 @@ static int airo_config(struct pcmcia_device *link)
 	kfree(req);
 	return 0;
=20
- cs_failed:
-	cs_error(link, last_fn, last_ret);
  failed:
 	airo_release(link);
 	kfree(req);
@@ -386,7 +370,7 @@ static int airo_config(struct pcmcia_device *link)
=20
 static void airo_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "airo_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "airo_release\n");
 	pcmcia_disable_device(link);
 }
=20
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atm=
el_cs.c
index ddaa859..7838572 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -55,22 +55,6 @@
=20
 #include "atmel.h"
=20
-/*
-   All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
-   you do not define PCMCIA_DEBUG at all, all the debug code will be
-   left out.  If you compile with PCMCIA_DEBUG=3D0, the debug code wil=
l
-   be present but disabled -- but it can then be enabled for specific
-   modules at load time with a 'pc_debug=3D#' option to insmod.
-*/
-
-#ifdef PCMCIA_DEBUG
-static int pc_debug =3D PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-static char *version =3D "$Revision: 1.2 $";
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args);
-#else
-#define DEBUG(n, args...)
-#endif
=20
 /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
=20
@@ -155,7 +139,7 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 {
 	local_info_t *local;
=20
-	DEBUG(0, "atmel_attach()\n");
+	dev_dbg(&p_dev->dev, "atmel_attach()\n");
=20
 	/* Interrupt setup */
 	p_dev->irq.Attributes =3D IRQ_TYPE_DYNAMIC_SHARING;
@@ -194,7 +178,7 @@ static int atmel_probe(struct pcmcia_device *p_dev)
=20
 static void atmel_detach(struct pcmcia_device *link)
 {
-	DEBUG(0, "atmel_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "atmel_detach\n");
=20
 	atmel_release(link);
=20
@@ -209,9 +193,6 @@ static void atmel_detach(struct pcmcia_device *link=
)
=20
   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
=20
-#define CS_CHECK(fn, ret) \
-do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_failed=
; } while (0)
-
 /* Call-back function to interrogate PCMCIA-specific information
    about the current existance of the card */
 static int card_present(void *arg)
@@ -275,13 +256,13 @@ static int atmel_config_check(struct pcmcia_devic=
e *p_dev,
 static int atmel_config(struct pcmcia_device *link)
 {
 	local_info_t *dev;
-	int last_fn, last_ret;
+	int ret;
 	struct pcmcia_device_id *did;
=20
 	dev =3D link->priv;
 	did =3D dev_get_drvdata(&handle_to_dev(link));
=20
-	DEBUG(0, "atmel_config(0x%p)\n", link);
+	dev_dbg(&link->dev, "atmel_config\n");
=20
 	/*
 	  In this loop, we scan the CIS for configuration table entries,
@@ -303,20 +284,25 @@ static int atmel_config(struct pcmcia_device *lin=
k)
 	  handler to the interrupt, unless the 'Handler' member of the
 	  irq structure is initialized.
 	*/
-	if (link->conf.Attributes & CONF_ENABLE_IRQ)
-		CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
+		ret =3D pcmcia_request_irq(link, &link->irq);
+		if (ret)
+			goto failed;
+	}
=20
 	/*
 	  This actually configures the PCMCIA socket -- setting up
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
-	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &li=
nk->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
=20
 	if (link->irq.AssignedIRQ =3D=3D 0) {
 		printk(KERN_ALERT
 		       "atmel: cannot assign IRQ: check that CONFIG_ISA is set in ke=
rnel config.");
-		goto cs_failed;
+		goto failed;
 	}
=20
 	((local_info_t*)link->priv)->eth_dev =3D
@@ -327,7 +313,7 @@ static int atmel_config(struct pcmcia_device *link)
 				card_present,
 				link);
 	if (!((local_info_t*)link->priv)->eth_dev)
-			goto cs_failed;
+			goto failed;
=20
=20
 	/*
@@ -340,8 +326,6 @@ static int atmel_config(struct pcmcia_device *link)
=20
 	return 0;
=20
- cs_failed:
-	cs_error(link, last_fn, last_ret);
  failed:
 	atmel_release(link);
 	return -ENODEV;
@@ -359,7 +343,7 @@ static void atmel_release(struct pcmcia_device *lin=
k)
 {
 	struct net_device *dev =3D ((local_info_t*)link->priv)->eth_dev;
=20
-	DEBUG(0, "atmel_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "atmel_release\n");
=20
 	if (dev)
 		stop_atmel_card(dev);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wire=
less/hostap/hostap_cs.c
index 31b60dd..ca3ab84 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -510,10 +510,6 @@ static void prism2_detach(struct pcmcia_device *li=
nk)
 }
=20
=20
-#define CS_CHECK(fn, ret) \
-do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_failed=
; } while (0)
-
-
 /* run after a CARD_INSERTION event is received to configure the PCMCI=
A
  * socket and make the device available to the system */
=20
@@ -605,7 +601,6 @@ static int prism2_config(struct pcmcia_device *link=
)
 	struct hostap_interface *iface;
 	local_info_t *local;
 	int ret =3D 1;
-	int last_fn, last_ret;
 	struct hostap_cs_priv *hw_priv;
=20
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
@@ -617,13 +612,12 @@ static int prism2_config(struct pcmcia_device *li=
nk)
 	}
=20
 	/* Look for an appropriate configuration table entry in the CIS */
-	last_ret =3D pcmcia_loop_config(link, prism2_config_check, NULL);
-	if (last_ret) {
+	ret =3D pcmcia_loop_config(link, prism2_config_check, NULL);
+	if (ret) {
 		if (!ignore_cis_vcc)
 			printk(KERN_ERR "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=3D1 parameter.\n");
-		cs_error(link, RequestIO, last_ret);
 		goto failed;
 	}
=20
@@ -652,8 +646,9 @@ static int prism2_config(struct pcmcia_device *link=
)
 		link->irq.IRQInfo1 =3D IRQ_LEVEL_ID;
 		link->irq.Handler =3D prism2_interrupt;
 		link->irq.Instance =3D dev;
-		CS_CHECK(RequestIRQ,
-			 pcmcia_request_irq(link, &link->irq));
+		ret =3D pcmcia_request_irq(link, &link->irq);
+		if (ret)
+			goto failed;
 	}
=20
 	/*
@@ -661,8 +656,9 @@ static int prism2_config(struct pcmcia_device *link=
)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	CS_CHECK(RequestConfiguration,
-		 pcmcia_request_configuration(link, &link->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
=20
 	dev->irq =3D link->irq.AssignedIRQ;
 	dev->base_addr =3D link->io.BasePort1;
@@ -695,9 +691,6 @@ static int prism2_config(struct pcmcia_device *link=
)
 	}
 	return ret;
=20
- cs_failed:
-	cs_error(link, last_fn, last_ret);
-
  failed:
 	kfree(hw_priv);
 	prism2_release((u_long)link);
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/n=
etwave_cs.c
index 9498b46..cbd85de 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -145,23 +145,6 @@ static const unsigned int txConfEUD    =3D 0x10; /=
* Enable Uni-Data packets */
 static const unsigned int txConfKey    =3D 0x02; /* Scramble data pack=
ets */
 static const unsigned int txConfLoop   =3D 0x01; /* Loopback mode */
=20
-/*
-   All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
-   you do not define PCMCIA_DEBUG at all, all the debug code will be
-   left out.  If you compile with PCMCIA_DEBUG=3D0, the debug code wil=
l
-   be present but disabled -- but it can then be enabled for specific
-   modules at load time with a 'pc_debug=3D#' option to insmod.
-*/
-
-#ifdef PCMCIA_DEBUG
-static int pc_debug =3D PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args)
-static char *version =3D
-"netwave_cs.c 0.3.0 Thu Jul 17 14:36:02 1997 (John Markus Bj=C3=B8rnda=
len)\n";
-#else
-#define DEBUG(n, args...)
-#endif
=20
 /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
=20
@@ -383,7 +366,7 @@ static int netwave_probe(struct pcmcia_device *link=
)
     struct net_device *dev;
     netwave_private *priv;
=20
-    DEBUG(0, "netwave_attach()\n");
+    dev_dbg(&link->dev, "netwave_attach()\n");
=20
     /* Initialize the struct pcmcia_device structure */
     dev =3D alloc_etherdev(sizeof(netwave_private));
@@ -438,7 +421,7 @@ static void netwave_detach(struct pcmcia_device *li=
nk)
 {
 	struct net_device *dev =3D link->priv;
=20
-	DEBUG(0, "netwave_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "netwave_detach\n");
=20
 	netwave_release(link);
=20
@@ -725,18 +708,15 @@ static const struct iw_handler_def	netwave_handle=
r_def =3D
  *
  */
=20
-#define CS_CHECK(fn, ret) \
-do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_failed=
; } while (0)
-
 static int netwave_pcmcia_config(struct pcmcia_device *link) {
     struct net_device *dev =3D link->priv;
     netwave_private *priv =3D netdev_priv(dev);
-    int i, j, last_ret, last_fn;
+    int i, j, ret;
     win_req_t req;
     memreq_t mem;
     u_char __iomem *ramBase =3D NULL;
=20
-    DEBUG(0, "netwave_pcmcia_config(0x%p)\n", link);
+    dev_dbg(&link->dev, "netwave_pcmcia_config\n");
=20
     /*
      *  Try allocating IO ports.  This tries a few fixed addresses.
@@ -749,22 +729,24 @@ static int netwave_pcmcia_config(struct pcmcia_de=
vice *link) {
 	if (i =3D=3D 0)
 		break;
     }
-    if (i !=3D 0) {
-	cs_error(link, RequestIO, i);
+    if (i !=3D 0)
 	goto failed;
-    }
=20
     /*
      *  Now allocate an interrupt line.  Note that this does not
      *  actually assign a handler to the interrupt.
      */
-    CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+    ret =3D pcmcia_request_irq(link, &link->irq);
+    if (ret)
+	    goto failed;
=20
     /*
      *  This actually configures the PCMCIA socket -- setting up
      *  the I/O windows and the interrupt mapping.
      */
-    CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, =
&link->conf));
+    ret =3D pcmcia_request_configuration(link, &link->conf);
+    if (ret)
+	    goto failed;
=20
     /*
      *  Allocate a 32K memory window.  Note that the struct pcmcia_dev=
ice
@@ -772,14 +754,18 @@ static int netwave_pcmcia_config(struct pcmcia_de=
vice *link) {
      *  device needs several windows, you'll need to keep track of
      *  the handles in your private data structure, dev->priv.
      */
-    DEBUG(1, "Setting mem speed of %d\n", mem_speed);
+    dev_dbg(&link->dev, "Setting mem speed of %d\n", mem_speed);
=20
     req.Attributes =3D WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
     req.Base =3D 0; req.Size =3D 0x8000;
     req.AccessSpeed =3D mem_speed;
-    CS_CHECK(RequestWindow, pcmcia_request_window(&link, &req, &link->=
win));
+    ret =3D pcmcia_request_window(&link, &req, &link->win);
+    if (ret)
+	    goto failed;
     mem.CardOffset =3D 0x20000; mem.Page =3D 0;=20
-    CS_CHECK(MapMemPage, pcmcia_map_mem_page(link->win, &mem));
+    ret =3D pcmcia_map_mem_page(link->win, &mem);
+    if (ret)
+	    goto failed;
=20
     /* Store base address of the common window frame */
     ramBase =3D ioremap(req.Base, 0x8000);
@@ -818,8 +804,6 @@ static int netwave_pcmcia_config(struct pcmcia_devi=
ce *link) {
 	   get_uint16(ramBase + NETWAVE_EREG_ARW+2));
     return 0;
=20
-cs_failed:
-    cs_error(link, last_fn, last_ret);
 failed:
     netwave_release(link);
     return -ENODEV;
@@ -837,7 +821,7 @@ static void netwave_release(struct pcmcia_device *l=
ink)
 	struct net_device *dev =3D link->priv;
 	netwave_private *priv =3D netdev_priv(dev);
=20
-	DEBUG(0, "netwave_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "netwave_release\n");
=20
 	pcmcia_disable_device(link);
 	if (link->win)
@@ -892,7 +876,7 @@ static void netwave_reset(struct net_device *dev) {
     u_char __iomem *ramBase =3D priv->ramBase;
     unsigned int iobase =3D dev->base_addr;
=20
-    DEBUG(0, "netwave_reset: Done with hardware reset\n");
+    pr_debug("netwave_reset: Done with hardware reset\n");
=20
     priv->timeoutCounter =3D 0;
=20
@@ -988,7 +972,7 @@ static int netwave_hw_xmit(unsigned char* data, int=
 len,
=20
     dev->stats.tx_bytes +=3D len;
=20
-    DEBUG(3, "Transmitting with SPCQ %x SPU %x LIF %x ISPLQ %x\n",
+    pr_debug("Transmitting with SPCQ %x SPU %x LIF %x ISPLQ %x\n",
 	  readb(ramBase + NETWAVE_EREG_SPCQ),
 	  readb(ramBase + NETWAVE_EREG_SPU),
 	  readb(ramBase + NETWAVE_EREG_LIF),
@@ -1000,7 +984,7 @@ static int netwave_hw_xmit(unsigned char* data, in=
t len,
     MaxData    =3D get_uint16(ramBase + NETWAVE_EREG_TDP+2);
     DataOffset =3D get_uint16(ramBase + NETWAVE_EREG_TDP+4);
 =09
-    DEBUG(3, "TxFreeList %x, MaxData %x, DataOffset %x\n",
+    pr_debug("TxFreeList %x, MaxData %x, DataOffset %x\n",
 	  TxFreeList, MaxData, DataOffset);
=20
     /* Copy packet to the adapter fragment buffers */
@@ -1088,7 +1072,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
         status =3D inb(iobase + NETWAVE_REG_ASR);
 	=09
 	if (!pcmcia_dev_present(link)) {
-	    DEBUG(1, "netwave_interrupt: Interrupt with status 0x%x "
+	    pr_debug("netwave_interrupt: Interrupt with status 0x%x "
 		  "from removed or suspended card!\n", status);
 	    break;
 	}
@@ -1132,7 +1116,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
 	    int txStatus;
=20
 	    txStatus =3D readb(ramBase + NETWAVE_EREG_TSER);
-	    DEBUG(3, "Transmit done. TSER =3D %x id %x\n",=20
+	    pr_debug("Transmit done. TSER =3D %x id %x\n",
 		  txStatus, readb(ramBase + NETWAVE_EREG_TSER + 1));
 	   =20
 	    if (txStatus & 0x20) {
@@ -1156,7 +1140,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
 		 *      TxGU and TxNOAP is set. (Those are the only ones
 		 *      to set TxErr).
 		 */
-		DEBUG(3, "netwave_interrupt: TxDN with error status %x\n",=20
+		pr_debug("netwave_interrupt: TxDN with error status %x\n",
 		      txStatus);
 	=09
 		/* Clear out TxGU, TxNOAP, TxErr and TxTrys */
@@ -1164,7 +1148,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
 		writeb(0xdf & txStatus, ramBase+NETWAVE_EREG_TSER+4);
 		++dev->stats.tx_errors;
 	    }
-	    DEBUG(3, "New status is TSER %x ASR %x\n",
+	    pr_debug("New status is TSER %x ASR %x\n",
 		  readb(ramBase + NETWAVE_EREG_TSER),
 		  inb(iobase + NETWAVE_REG_ASR));
=20
@@ -1172,7 +1156,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
 	}
 	/* TxBA, this would trigger on all error packets received */
 	/* if (status & 0x01) {
-	   DEBUG(4, "Transmit buffers available, %x\n", status);
+	   pr_debug("Transmit buffers available, %x\n", status);
 	   }
 	   */
     }
@@ -1190,7 +1174,7 @@ static irqreturn_t netwave_interrupt(int irq, voi=
d* dev_id)
  */
 static void netwave_watchdog(struct net_device *dev) {
=20
-    DEBUG(1, "%s: netwave_watchdog: watchdog timer expired\n", dev->na=
me);
+    pr_debug("%s: netwave_watchdog: watchdog timer expired\n", dev->na=
me);
     netwave_reset(dev);
     dev->trans_start =3D jiffies;
     netif_wake_queue(dev);
@@ -1211,7 +1195,7 @@ static int netwave_rx(struct net_device *dev)
     int i;
     u_char *ptr;
 =09
-    DEBUG(3, "xinw_rx: Receiving ... \n");
+    pr_debug("xinw_rx: Receiving ... \n");
=20
     /* Receive max 10 packets for now. */
     for (i =3D 0; i < 10; i++) {
@@ -1237,7 +1221,7 @@ static int netwave_rx(struct net_device *dev)
 	=09
 	skb =3D dev_alloc_skb(rcvLen+5);
 	if (skb =3D=3D NULL) {
-	    DEBUG(1, "netwave_rx: Could not allocate an sk_buff of "
+	    pr_debug("netwave_rx: Could not allocate an sk_buff of "
 		  "length %d\n", rcvLen);
 	    ++dev->stats.rx_dropped;
 	    /* Tell the adapter to skip the packet */
@@ -1279,7 +1263,7 @@ static int netwave_rx(struct net_device *dev)
 	wait_WOC(iobase);
 	writeb(NETWAVE_CMD_SRP, ramBase + NETWAVE_EREG_CB + 0);
 	writeb(NETWAVE_CMD_EOC, ramBase + NETWAVE_EREG_CB + 1);
-	DEBUG(3, "Packet reception ok\n");
+	pr_debug("Packet reception ok\n");
     }
     return 0;
 }
@@ -1288,7 +1272,7 @@ static int netwave_open(struct net_device *dev) {
     netwave_private *priv =3D netdev_priv(dev);
     struct pcmcia_device *link =3D priv->p_dev;
=20
-    DEBUG(1, "netwave_open: starting.\n");
+    dev_dbg(&link->dev, "netwave_open: starting.\n");
    =20
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
@@ -1305,7 +1289,7 @@ static int netwave_close(struct net_device *dev) =
{
     netwave_private *priv =3D netdev_priv(dev);
     struct pcmcia_device *link =3D priv->p_dev;
=20
-    DEBUG(1, "netwave_close: finishing.\n");
+    dev_dbg(&link->dev, "netwave_close: finishing.\n");
=20
     link->open--;
     netif_stop_queue(dev);
@@ -1358,11 +1342,11 @@ static void set_multicast_list(struct net_devic=
e *dev)
     u_char  rcvMode =3D 0;
   =20
 #ifdef PCMCIA_DEBUG
-    if (pc_debug > 2) {
-	static int old;
+    {
+	xstatic int old;
 	if (old !=3D dev->mc_count) {
 	    old =3D dev->mc_count;
-	    DEBUG(0, "%s: setting Rx mode to %d addresses.\n",
+	    pr_debug("%s: setting Rx mode to %d addresses.\n",
 		  dev->name, dev->mc_count);
 	}
     }
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wi=
reless/orinoco/orinoco_cs.c
index 38c1c9d..da626ec 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -160,12 +160,6 @@ static void orinoco_cs_detach(struct pcmcia_device=
 *link)
  * device available to the system.
  */
=20
-#define CS_CHECK(fn, ret) do { \
-	last_fn =3D (fn); \
-	if ((last_ret =3D (ret)) !=3D 0) \
-		goto cs_failed; \
-} while (0)
-
 static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
 				   cistpl_cftable_entry_t *cfg,
 				   cistpl_cftable_entry_t *dflt,
@@ -240,7 +234,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 	struct orinoco_private *priv =3D link->priv;
 	struct orinoco_pccard *card =3D priv->card;
 	hermes_t *hw =3D &priv->hw;
-	int last_fn, last_ret;
+	int ret;
 	void __iomem *mem;
=20
 	/*
@@ -257,13 +251,12 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	last_ret =3D pcmcia_loop_config(link, orinoco_cs_config_check, NULL);
-	if (last_ret) {
+	ret =3D pcmcia_loop_config(link, orinoco_cs_config_check, NULL);
+	if (ret) {
 		if (!ignore_cis_vcc)
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=3D1 parameter.\n");
-		cs_error(link, RequestIO, last_ret);
 		goto failed;
 	}
=20
@@ -272,14 +265,16 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * a handler to the interrupt, unless the 'Handler' member of
 	 * the irq structure is initialized.
 	 */
-	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	ret =3D pcmcia_request_irq(link, &link->irq);
+	if (ret)
+		goto failed;
=20
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
 	 * called. */
 	mem =3D ioport_map(link->io.BasePort1, link->io.NumPorts1);
 	if (!mem)
-		goto cs_failed;
+		goto failed;
=20
 	hermes_struct_init(hw, mem, HERMES_16BIT_REGSPACING);
=20
@@ -288,8 +283,9 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	CS_CHECK(RequestConfiguration,
-		 pcmcia_request_configuration(link, &link->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
=20
 	/* Ok, we have the configuration, prepare to register the netdev */
 	card->node.major =3D card->node.minor =3D 0;
@@ -315,9 +311,6 @@ orinoco_cs_config(struct pcmcia_device *link)
 				       * net_device has been registered */
 	return 0;
=20
- cs_failed:
-	cs_error(link, last_fn, last_ret);
-
  failed:
 	orinoco_cs_release(link);
 	return -ENODEV;
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/w=
ireless/orinoco/spectrum_cs.c
index c361310..700010e 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -73,9 +73,6 @@ static void spectrum_cs_release(struct pcmcia_device =
*link);
 #define HCR_MEM16	0x10	/* memory width bit, should be preserved */
=20
=20
-#define CS_CHECK(fn, ret) \
-  do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_fail=
ed; } while (0)
-
 /*
  * Reset the card using configuration registers COR and CCSR.
  * If IDLE is 1, stop the firmware, so that it can be safely rewritten=
=2E
@@ -83,7 +80,7 @@ static void spectrum_cs_release(struct pcmcia_device =
*link);
 static int
 spectrum_reset(struct pcmcia_device *link, int idle)
 {
-	int last_ret, last_fn;
+	int ret;
 	conf_reg_t reg;
 	u_int save_cor;
=20
@@ -95,23 +92,26 @@ spectrum_reset(struct pcmcia_device *link, int idle=
)
 	reg.Function =3D 0;
 	reg.Action =3D CS_READ;
 	reg.Offset =3D CISREG_COR;
-	CS_CHECK(AccessConfigurationRegister,
-		 pcmcia_access_configuration_register(link, &reg));
+	ret =3D pcmcia_access_configuration_register(link, &reg);
+	if (ret)
+		goto failed;
 	save_cor =3D reg.Value;
=20
 	/* Soft-Reset card */
 	reg.Action =3D CS_WRITE;
 	reg.Offset =3D CISREG_COR;
 	reg.Value =3D (save_cor | COR_SOFT_RESET);
-	CS_CHECK(AccessConfigurationRegister,
-		 pcmcia_access_configuration_register(link, &reg));
+	ret =3D pcmcia_access_configuration_register(link, &reg);
+	if (ret)
+		goto failed;
 	udelay(1000);
=20
 	/* Read CCSR */
 	reg.Action =3D CS_READ;
 	reg.Offset =3D CISREG_CCSR;
-	CS_CHECK(AccessConfigurationRegister,
-		 pcmcia_access_configuration_register(link, &reg));
+	ret =3D pcmcia_access_configuration_register(link, &reg);
+	if (ret)
+		goto failed;
=20
 	/*
 	 * Start or stop the firmware.  Memory width bit should be
@@ -120,21 +120,22 @@ spectrum_reset(struct pcmcia_device *link, int id=
le)
 	reg.Action =3D CS_WRITE;
 	reg.Offset =3D CISREG_CCSR;
 	reg.Value =3D (idle ? HCR_IDLE : HCR_RUN) | (reg.Value & HCR_MEM16);
-	CS_CHECK(AccessConfigurationRegister,
-		 pcmcia_access_configuration_register(link, &reg));
+	ret =3D pcmcia_access_configuration_register(link, &reg);
+	if (ret)
+		goto failed;
 	udelay(1000);
=20
 	/* Restore original COR configuration index */
 	reg.Action =3D CS_WRITE;
 	reg.Offset =3D CISREG_COR;
 	reg.Value =3D (save_cor & ~COR_SOFT_RESET);
-	CS_CHECK(AccessConfigurationRegister,
-		 pcmcia_access_configuration_register(link, &reg));
+	ret =3D pcmcia_access_configuration_register(link, &reg);
+	if (ret)
+		goto failed;
 	udelay(1000);
 	return 0;
=20
-cs_failed:
-	cs_error(link, last_fn, last_ret);
+failed:
 	return -ENODEV;
 }
=20
@@ -307,7 +308,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 	struct orinoco_private *priv =3D link->priv;
 	struct orinoco_pccard *card =3D priv->card;
 	hermes_t *hw =3D &priv->hw;
-	int last_fn, last_ret;
+	int ret;
 	void __iomem *mem;
=20
 	/*
@@ -324,13 +325,12 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	last_ret =3D pcmcia_loop_config(link, spectrum_cs_config_check, NULL)=
;
-	if (last_ret) {
+	ret =3D pcmcia_loop_config(link, spectrum_cs_config_check, NULL);
+	if (ret) {
 		if (!ignore_cis_vcc)
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=3D1 parameter.\n");
-		cs_error(link, RequestIO, last_ret);
 		goto failed;
 	}
=20
@@ -339,14 +339,16 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * a handler to the interrupt, unless the 'Handler' member of
 	 * the irq structure is initialized.
 	 */
-	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	ret =3D pcmcia_request_irq(link, &link->irq);
+	if (ret)
+		goto failed;
=20
 	/* We initialize the hermes structure before completing PCMCIA
 	 * configuration just in case the interrupt handler gets
 	 * called. */
 	mem =3D ioport_map(link->io.BasePort1, link->io.NumPorts1);
 	if (!mem)
-		goto cs_failed;
+		goto failed;
=20
 	hermes_struct_init(hw, mem, HERMES_16BIT_REGSPACING);
=20
@@ -355,8 +357,9 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * the I/O windows and the interrupt mapping, and putting the
 	 * card and host interface into "Memory and IO" mode.
 	 */
-	CS_CHECK(RequestConfiguration,
-		 pcmcia_request_configuration(link, &link->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
=20
 	/* Ok, we have the configuration, prepare to register the netdev */
 	card->node.major =3D card->node.minor =3D 0;
@@ -386,9 +389,6 @@ spectrum_cs_config(struct pcmcia_device *link)
 				       * net_device has been registered */
 	return 0;
=20
- cs_failed:
-	cs_error(link, last_fn, last_ret);
-
  failed:
 	spectrum_cs_release(link);
 	return -ENODEV;
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/w=
avelan_cs.c
index 431a20e..2fad4ac 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3656,10 +3656,7 @@ wv_pcmcia_reset(struct net_device *	dev)
=20
   i =3D pcmcia_access_configuration_register(link, &reg);
   if (i !=3D 0)
-    {
-      cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
-    }
      =20
 #ifdef DEBUG_CONFIG_INFO
   printk(KERN_DEBUG "%s: wavelan_pcmcia_reset(): Config reg is 0x%x\n"=
,
@@ -3670,19 +3667,13 @@ wv_pcmcia_reset(struct net_device *	dev)
   reg.Value =3D reg.Value | COR_SW_RESET;
   i =3D pcmcia_access_configuration_register(link, &reg);
   if (i !=3D 0)
-    {
-      cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
-    }
      =20
   reg.Action =3D CS_WRITE;
   reg.Value =3D COR_LEVEL_IRQ | COR_CONFIG;
   i =3D pcmcia_access_configuration_register(link, &reg);
   if (i !=3D 0)
-    {
-      cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
-    }
=20
 #ifdef DEBUG_CONFIG_TRACE
   printk(KERN_DEBUG "%s: <-wv_pcmcia_reset()\n", dev->name);
@@ -3857,10 +3848,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
     {
       i =3D pcmcia_request_io(link, &link->io);
       if (i !=3D 0)
-	{
-	  cs_error(link, RequestIO, i);
 	  break;
-	}
=20
       /*
        * Now allocate an interrupt line.  Note that this does not
@@ -3868,10 +3856,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
        */
       i =3D pcmcia_request_irq(link, &link->irq);
       if (i !=3D 0)
-	{
-	  cs_error(link, RequestIRQ, i);
 	  break;
-	}
=20
       /*
        * This actually configures the PCMCIA socket -- setting up
@@ -3880,10 +3865,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       link->conf.ConfigIndex =3D 1;
       i =3D pcmcia_request_configuration(link, &link->conf);
       if (i !=3D 0)
-	{
-	  cs_error(link, RequestConfiguration, i);
 	  break;
-	}
=20
       /*
        * Allocate a small memory window.  Note that the struct pcmcia_=
device
@@ -3896,10 +3878,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       req.AccessSpeed =3D mem_speed;
       i =3D pcmcia_request_window(&link, &req, &link->win);
       if (i !=3D 0)
-	{
-	  cs_error(link, RequestWindow, i);
 	  break;
-	}
=20
       lp->mem =3D ioremap(req.Base, req.Size);
       dev->mem_start =3D (u_long)lp->mem;
@@ -3908,10 +3887,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       mem.CardOffset =3D 0; mem.Page =3D 0;
       i =3D pcmcia_map_mem_page(link->win, &mem);
       if (i !=3D 0)
-	{
-	  cs_error(link, MapMemPage, i);
 	  break;
-	}
=20
       /* Feed device with this info... */
       dev->irq =3D link->irq.AssignedIRQ;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl=
3501_cs.c
index 4f1e0cf..7e8e269 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -67,23 +67,7 @@
 /* For rough constant delay */
 #define WL3501_NOPLOOP(n) { int x =3D 0; while (x++ < n) slow_down_io(=
); }
=20
-/*
- * All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If y=
ou do not
- * define PCMCIA_DEBUG at all, all the debug code will be left out.  I=
f you
- * compile with PCMCIA_DEBUG=3D0, the debug code will be present but d=
isabled --
- * but it can then be enabled for specific modules at load time with a
- * 'pc_debug=3D#' option to insmod.
- */
-#define PCMCIA_DEBUG 0
-#ifdef PCMCIA_DEBUG
-static int pc_debug =3D PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-#define dprintk(n, format, args...) \
-	{ if (pc_debug > (n)) \
-		printk(KERN_INFO "%s: " format "\n", __func__ , ##args); }
-#else
-#define dprintk(n, format, args...)
-#endif
+
=20
 #define wl3501_outb(a, b) { outb(a, b); slow_down_io(); }
 #define wl3501_outb_p(a, b) { outb_p(a, b); slow_down_io(); }
@@ -684,10 +668,10 @@ static void wl3501_mgmt_scan_confirm(struct wl350=
1_card *this, u16 addr)
 	int matchflag =3D 0;
 	struct wl3501_scan_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status =3D=3D WL3501_STATUS_SUCCESS) {
-		dprintk(3, "success");
+		pr_debug("success");
 		if ((this->net_type =3D=3D IW_MODE_INFRA &&
 		     (sig.cap_info & WL3501_MGMT_CAPABILITY_ESS)) ||
 		    (this->net_type =3D=3D IW_MODE_ADHOC &&
@@ -722,7 +706,7 @@ static void wl3501_mgmt_scan_confirm(struct wl3501_=
card *this, u16 addr)
 			}
 		}
 	} else if (sig.status =3D=3D WL3501_STATUS_TIMEOUT) {
-		dprintk(3, "timeout");
+		pr_debug("timeout");
 		this->join_sta_bss =3D 0;
 		for (i =3D this->join_sta_bss; i < this->bss_cnt; i++)
 			if (!wl3501_mgmt_join(this, i))
@@ -879,7 +863,7 @@ static int wl3501_mgmt_auth(struct wl3501_card *thi=
s)
 		.timeout =3D 1000,
 	};
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	memcpy(sig.mac_addr, this->bssid, ETH_ALEN);
 	return wl3501_esbq_exec(this, &sig, sizeof(sig));
 }
@@ -893,7 +877,7 @@ static int wl3501_mgmt_association(struct wl3501_ca=
rd *this)
 		.cap_info	 =3D this->cap_info,
 	};
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	memcpy(sig.mac_addr, this->bssid, ETH_ALEN);
 	return wl3501_esbq_exec(this, &sig, sizeof(sig));
 }
@@ -903,7 +887,7 @@ static void wl3501_mgmt_join_confirm(struct net_dev=
ice *dev, u16 addr)
 	struct wl3501_card *this =3D netdev_priv(dev);
 	struct wl3501_join_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status =3D=3D WL3501_STATUS_SUCCESS) {
 		if (this->net_type =3D=3D IW_MODE_INFRA) {
@@ -962,7 +946,7 @@ static inline void wl3501_md_confirm_interrupt(stru=
ct net_device *dev,
 {
 	struct wl3501_md_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	wl3501_free_tx_buffer(this, sig.data);
 	if (netif_queue_stopped(dev))
@@ -1017,7 +1001,7 @@ static inline void wl3501_md_ind_interrupt(struct=
 net_device *dev,
 static inline void wl3501_get_confirm_interrupt(struct wl3501_card *th=
is,
 						u16 addr, void *sig, int size)
 {
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &this->sig_get_confirm,
 			    sizeof(this->sig_get_confirm));
 	wake_up(&this->wait);
@@ -1029,7 +1013,7 @@ static inline void wl3501_start_confirm_interrupt=
(struct net_device *dev,
 {
 	struct wl3501_start_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status =3D=3D WL3501_STATUS_SUCCESS)
 		netif_wake_queue(dev);
@@ -1041,7 +1025,7 @@ static inline void wl3501_assoc_confirm_interrupt=
(struct net_device *dev,
 	struct wl3501_card *this =3D netdev_priv(dev);
 	struct wl3501_assoc_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
=20
 	if (sig.status =3D=3D WL3501_STATUS_SUCCESS)
@@ -1053,7 +1037,7 @@ static inline void wl3501_auth_confirm_interrupt(=
struct wl3501_card *this,
 {
 	struct wl3501_auth_confirm sig;
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
=20
 	if (sig.status =3D=3D WL3501_STATUS_SUCCESS)
@@ -1069,7 +1053,7 @@ static inline void wl3501_rx_interrupt(struct net=
_device *dev)
 	u8 sig_id;
 	struct wl3501_card *this =3D netdev_priv(dev);
=20
-	dprintk(3, "entry");
+	pr_debug("entry");
 loop:
 	morepkts =3D 0;
 	if (!wl3501_esbq_confirm(this))
@@ -1302,7 +1286,7 @@ static int wl3501_reset(struct net_device *dev)
 	wl3501_ack_interrupt(this);
 	wl3501_unblock_interrupt(this);
 	wl3501_mgmt_scan(this, 100);
-	dprintk(1, "%s: device reset", dev->name);
+	pr_debug("%s: device reset", dev->name);
 	rc =3D 0;
 out:
 	return rc;
@@ -1376,7 +1360,7 @@ static int wl3501_open(struct net_device *dev)
 	link->open++;
=20
 	/* Initial WL3501 firmware */
-	dprintk(1, "%s: Initialize WL3501 firmware...", dev->name);
+	pr_debug("%s: Initialize WL3501 firmware...", dev->name);
 	if (wl3501_init_firmware(this))
 		goto fail;
 	/* Initial device variables */
@@ -1388,7 +1372,7 @@ static int wl3501_open(struct net_device *dev)
 	wl3501_unblock_interrupt(this);
 	wl3501_mgmt_scan(this, 100);
 	rc =3D 0;
-	dprintk(1, "%s: WL3501 opened", dev->name);
+	pr_debug("%s: WL3501 opened", dev->name);
 	printk(KERN_INFO "%s: Card Name: %s\n"
 			 "%s: Firmware Date: %s\n",
 			 dev->name, this->card_name,
@@ -1945,9 +1929,6 @@ out_link:
 	return -ENOMEM;
 }
=20
-#define CS_CHECK(fn, ret) \
-do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=3D 0) goto cs_failed=
; } while (0)
-
 /**
  * wl3501_config - configure the PCMCIA socket and make eth device ava=
ilable
  * @link - FILL_IN
@@ -1959,7 +1940,7 @@ do { last_fn =3D (fn); if ((last_ret =3D (ret)) !=
=3D 0) goto cs_failed; } while (0)
 static int wl3501_config(struct pcmcia_device *link)
 {
 	struct net_device *dev =3D link->priv;
-	int i =3D 0, j, last_fn, last_ret;
+	int i =3D 0, j, ret;
 	struct wl3501_card *this;
=20
 	/* Try allocating IO ports.  This tries a few fixed addresses.  If yo=
u
@@ -1975,20 +1956,22 @@ static int wl3501_config(struct pcmcia_device *=
link)
 		if (i =3D=3D 0)
 			break;
 	}
-	if (i !=3D 0) {
-		cs_error(link, RequestIO, i);
+	if (i !=3D 0)
 		goto failed;
-	}
=20
 	/* Now allocate an interrupt line. Note that this does not actually
 	 * assign a handler to the interrupt. */
=20
-	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	ret =3D pcmcia_request_irq(link, &link->irq);
+	if (ret)
+		goto failed;
=20
 	/* This actually configures the PCMCIA socket -- setting up the I/O
 	 * windows and the interrupt mapping.  */
=20
-	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &li=
nk->conf));
+	ret =3D pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
=20
 	dev->irq =3D link->irq.AssignedIRQ;
 	dev->base_addr =3D link->io.BasePort1;
@@ -2041,8 +2024,6 @@ static int wl3501_config(struct pcmcia_device *li=
nk)
 	netif_start_queue(dev);
 	return 0;
=20
-cs_failed:
-	cs_error(link, last_fn, last_ret);
 failed:
 	wl3501_release(link);
 	return -ENODEV;
--=20
1.6.0.4

