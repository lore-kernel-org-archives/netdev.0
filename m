From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: wanPMC-CxT1E1
Date: Fri, 30 Oct 2009 02:52:40 +0100
Message-ID: <m3d4454phz.fsf@intrepid.localdomain>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	<20091026204144.GA28436@kroah.com>
	<4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45386 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754708AbZJ3Bwn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 21:52:43 -0400
In-Reply-To: <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com> (Bob
	Beers's message of "Tue, 27 Oct 2009 13:48:53 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bob Beers <bob.beers@gmail.com> writes:

> ok, so where do I start, I have a system ready to start
>  git cloning, and creating patches. I googled for a while
>  but didn't find a nice recipe for participating in the -staging
>  process.

I gave it a try. At least compiles with few warnings. Not sure about th=
e
WORK_INIT() change.

Created drivers/net/wan/cxt1e1, moved all relevant SBE's .c and .h
there, added a simple Makefile/Kconfig. Quick and dirty. There is a
_lot_ of work to be done before it meets the usual kernel standards.

It's not in staging/ so the paths need to be corrected but I can't work
further on it at this time. Hand-edited but I tried to be careful.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

 drivers/net/wan/Kconfig         |   22 ++++++++++++++++++++++
 drivers/net/wan/Makefile        |    1 +
 drivers/net/wan/cxt1e1/Makefile |    3 +++
 drivers/net/wan/cxt1e1/functions.c           |  117 +----
 drivers/net/wan/cxt1e1/hwprobe.c             |   30 +-
 drivers/net/wan/cxt1e1/libsbew.h             |    4 -
 drivers/net/wan/cxt1e1/linux.c               |  631 +++++++-----------=
-------
 drivers/net/wan/cxt1e1/musycc.c              |  237 +----------
 drivers/net/wan/cxt1e1/musycc.h              |   51 +--
 drivers/net/wan/cxt1e1/pmcc4_defs.h          |   28 +--
 drivers/net/wan/cxt1e1/pmcc4_drv.c           |  114 +-----
 drivers/net/wan/cxt1e1/pmcc4_private.h       |   34 +--
 drivers/net/wan/cxt1e1/pmcc4_sysdep.h        |   77 +---
 drivers/net/wan/cxt1e1/sbecom_inline_linux.h |   65 +---
 drivers/net/wan/cxt1e1/sbeid.c               |   38 +--
 drivers/net/wan/cxt1e1/sbeproc.c             |   70 +---
 drivers/net/wan/cxt1e1/sbeproc.h             |   39 +--

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index d08ce6a..0c3c761 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -342,6 +342,28 @@ config IXP4XX_HSS
 	  Say Y here if you want to use built-in HSS ports
 	  on IXP4xx processor.
=20
+config CXT1E1
+	tristate "SBE wanPMC-C[421]T1E1 hardware support"
+	depends on HDLC && PCI
+	help
+	  This driver supports the SBE wanPMC-CxT1E1 1, 2 and 4 port T1
+	  channelized stream WAN adapter card which contains a HDLC/Transpare=
nt
+	  mode controller.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called cxt1e1.
+
+	  If unsure, say N.
+
+config SBE_PMCC4_NCOMM
+	bool "SBE PMCC4 NCOMM support"
+	depends on SBE_PMCC4
+	help
+          SBE supplies optional support for NCOMM products.
+
+	  If you have purchased this optional support you must say Y or M
+	  here to allow the driver to operate with the NCOMM product.
+
 config DLCI
 	tristate "Frame Relay DLCI support"
 	---help---
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 19d14bc..1715c14 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_WANXL)		+=3D wanxl.o
 obj-$(CONFIG_PCI200SYN)		+=3D pci200syn.o
 obj-$(CONFIG_PC300TOO)		+=3D pc300too.o
 obj-$(CONFIG_IXP4XX_HSS)	+=3D ixp4xx_hss.o
+obj-$(CONFIG_CXT1E1)		+=3D cxt1e1/
=20
 clean-files :=3D wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
diff --git a/drivers/net/wan/cxt1e1/Makefile b/drivers/net/wan/cxt1e1/M=
akefile
new file mode 100644
index 0000000..82b9118
--- /dev/null
+++ b/drivers/net/wan/cxt1e1/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_CXT1E1) +=3D cxt1e1.o
+
+cxt1e1-objs :=3D comet.o comet_tables.o functions.o hwprobe.o linux.o =
musycc.o pmc93x6_eeprom.o pmcc4_drv.o sbecrc.o sbeid.o sbeproc.o
diff --git a/drivers/net/wan/cxt1e1/functions.c b/drivers/net/wan/cxt1e=
1/functions.c
index e490b5e..52581d7 100644
--- a/drivers/net/wan/cxt1e1/functions.c
+++ b/drivers/net/wan/cxt1e1/functions.c
@@ -1,10 +1,4 @@
 /*
- * $Id: functions.c,v 2.1 2007/08/15 21:59:46 rickd PMCC4_3_1B $
- */
-
-/*--------------------------------------------------------------------=
---------
- * functions.c -
- *
  * Copyright (C) 2003-2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
@@ -16,47 +10,15 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 2.1 $
- * Last changed on $Date: 2007/08/15 21:59:46 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: functions.c,v $
- * Revision 2.1  2007/08/15 21:59:46  rickd
- * Watchdog data address casting to *ULONG* for 64bit kernel compatibi=
lity.
- *
- * Revision 2.0  2005/09/28 00:10:05  rickd
- * Add inlining of functions. Use OS_ function-name prefix.
- *
- * Revision 1.3  2005/05/10 22:45:12  rickd
- * Add c4_sem_init().  Fix udelay for large delays which use mdelay()
- * and then udelay() for remnants and short delays per Linux documenta=
tion
- * suggestions that udelay() for long delays is not accurate.
- * CI prior to major code upgrade to standardize to 256T3 code model.
- *
- * Revision 1.2  2005/04/28 23:54:48  rickd
- * Add RCS tracking header.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-char        SBEid_pmcc4_functionsc[] =3D
-"@(#)functions.c - $Revision: 2.1 $      (c) Copyright 2002-2005 SBE, =
Inc.";
-
-
-#include "pmcc4_sysdep.h"
 #include <linux/slab.h>
-#include <asm/io.h>
-#include <asm/byteorder.h>
-#include <asm/semaphore.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/hdlc.h>
-
+#include <asm/io.h>
+#include <asm/byteorder.h>
+#include "pmcc4_sysdep.h"
 #include "sbecom_inline_linux.h"
 #include "libsbew.h"
 #include "pmcc4.h"
@@ -159,41 +121,22 @@ watchdog_func (unsigned long arg)
             printk (KERN_WARNING "watchdog_func: drvr not available (%=
x)\n", drvr_state);
         return;
     }
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    /* Initialize the tq entry only the first time */
-    if (wd->init_tq)
-    {
-        wd->init_tq =3D 0;
-        wd->tq.routine =3D wd->func;
-        wd->tq.sync =3D 0;
-        wd->tq.data =3D wd->softc;
-    }
-    schedule_task (&wd->tq);
-#else
     schedule_work (&wd->work);
-#endif
     mod_timer (&wd->h, jiffies + wd->ticks);
 }
=20
-int         OS_init_watchdog (struct watchdog * wdp, void (*f) (void *=
), void *c, int usec)
+int OS_init_watchdog(struct watchdog *wdp, void (*f)(struct work_struc=
t *),
+		     void *c, int usec)
 {
-    wdp->func =3D f;
-    wdp->softc =3D c;
-    wdp->ticks =3D (HZ) * (usec / 1000) / 1000;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    wdp->init_tq =3D 1;               /* initialize the tq entry only =
the first
-                                     * time */
-#else
-    INIT_WORK (&wdp->work, f, c);
-#endif
-    init_timer (&wdp->h);
-    {
-        ci_t       *ci =3D (ci_t *) c;
-
+	ci_t *ci =3D (ci_t *)c;
+	wdp->func =3D f;
+	wdp->softc =3D c;
+	wdp->ticks =3D (HZ) * (usec / 1000) / 1000;
+	INIT_WORK(&wdp->work, f);
+	init_timer(&wdp->h);
         wdp->h.data =3D (unsigned long) &ci->wd;
-    }
-    wdp->h.function =3D watchdog_func;
-    return 0;
+	wdp->h.function =3D watchdog_func;
+	return 0;
 }
=20
 void
@@ -303,35 +246,15 @@ sd_queue_stopped (void *user)
     return (netif_queue_stopped (ndev));
 }
=20
-void
-sd_recv_consume (void *token, size_t len, void *user)
+void sd_recv_consume(void *token, size_t len, void *user)
 {
-    struct net_device *ndev =3D user;
-    struct sk_buff *skb =3D token;
-
-    skb->dev =3D ndev;
-    ndev->last_rx =3D jiffies;
-    skb_put (skb, len);
-    skb->mac.raw =3D skb->data;
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-    V7 (hdlc_netif_rx) (dev_to_hdlc (ndev), skb);
-#else
-#ifdef CONFIG_SBE_HDLC_V20
-    /*
-     * hdlc implementation under 2.4.20 seems to contain an interim <h=
dlc>
-     * stack
-     */
-    skb->protocol =3D htons (ETH_P_HDLC);
-#else
-    /*
-     * hdlc implementation under 2.4.21+ seems to contain an augmented=
 <hdlc>
-     * stack whereby linux/hdlc.h contains the following "inline" rout=
ine
-     */
+	struct sk_buff *skb =3D token;
+	struct net_device *dev =3D user;
=20
-    skb->protocol =3D hdlc_type_trans (skb, ndev);
-#endif
-    netif_rx (skb);
-#endif
+	skb->dev =3D dev;
+	skb_put(skb, len);
+	skb->protocol =3D hdlc_type_trans(skb, dev);
+	netif_rx(skb);
 }
=20
=20
diff --git a/drivers/net/wan/cxt1e1/hwprobe.c b/drivers/net/wan/cxt1e1/=
hwprobe.c
index 8f5b1d1..8b5d955 100644
--- a/drivers/net/wan/cxt1e1/hwprobe.c
+++ b/drivers/net/wan/cxt1e1/hwprobe.c
@@ -107,7 +107,7 @@ show_two (hdw_info_t * hi, int brdno)
     bp =3D banner;
     memset (banner, 0, 80);         /* clear print buffer */
=20
-    ci =3D (ci_t *) hi->ndev->priv;
+    ci =3D netdev_priv(hi->ndev);
     bid =3D sbeid_get_bdname (ci);
     switch (hi->promfmt)
     {
@@ -243,27 +243,25 @@ cleanup_ioremap (void)
 }
=20
=20
-void
-cleanup_devs (void)
+void cleanup_devs(void)
 {
-    hdw_info_t *hi;
-    int         i;
+	hdw_info_t *hi;
+	int i;
=20
-    for (i =3D 0, hi =3D hdw_info; i < MAX_BOARDS; i++, hi++)
-    {
-        if (hi->pci_slot =3D=3D 0xff || !hi->ndev)
-            break;
-        c4_stopwd (hi->ndev->priv);
+	for (i =3D 0, hi =3D hdw_info; i < MAX_BOARDS; i++, hi++) {
+		if (hi->pci_slot =3D=3D 0xff || !hi->ndev)
+			break;
+		c4_stopwd(netdev_priv(hi->ndev));
 #ifdef CONFIG_PROC_FS
-        sbecom_proc_brd_cleanup (hi->ndev->priv);
+		sbecom_proc_brd_cleanup(netdev_priv(hi->ndev));
 #endif
-        unregister_netdev (hi->ndev);
-        free_irq (hi->pdev[0]->irq, hi->ndev);
+		unregister_netdev(hi->ndev);
+		free_irq (hi->pdev[0]->irq, hi->ndev);
 #ifdef CONFIG_SBE_PMCC4_NCOMM
-        free_irq (hi->pdev[1]->irq, hi->ndev);
+		free_irq(hi->pdev[1]->irq, hi->ndev);
 #endif
-        OS_kfree (hi->ndev);
-    }
+		OS_kfree(hi->ndev);
+	}
 }
=20
=20
diff --git a/drivers/net/wan/cxt1e1/libsbew.h b/drivers/net/wan/cxt1e1/=
libsbew.h
index 5c99646..359a36a 100644
--- a/drivers/net/wan/cxt1e1/libsbew.h
+++ b/drivers/net/wan/cxt1e1/libsbew.h
@@ -232,9 +232,7 @@ struct sbecom_port_param
     u_int8_t    portP;          /* more port parameters (clock source =
- 0x80;
                                  * and LBO - 0xf; */
                                 /* bits 0x70 are reserved for future u=
se ) */
-#ifdef SBE_PMCC4_ENABLE
 	u_int32_t   hypersize;  /* RLD DEBUG - add this in until I learn how =
to make this entry obsolete */
-#endif
     int         reserved[3-1];    /* reserved for future use */
     int    _res[4];
 };
@@ -271,11 +269,9 @@ struct sbecom_port_param
     struct sbecom_chan_param
     {
         u_int32_t   channum;    /* 0: */
-#ifdef SBE_PMCC4_ENABLE
 	u_int32_t   card;  /* RLD DEBUG - add this in until I learn how to ma=
ke this entry obsolete */
 	u_int32_t   port;  /* RLD DEBUG - add this in until I learn how to ma=
ke this entry obsolete */
 	u_int8_t bitmask[32];
-#endif
         u_int32_t   intr_mask;  /* 4: interrupt mask, specify ored
                                  * (SS7_)INTR_* to disable */
         u_int8_t    status;     /* 8: channel transceiver status (TX_E=
NABLED,
diff --git a/drivers/net/wan/cxt1e1/linux.c b/drivers/net/wan/cxt1e1/li=
nux.c
index a8d6784..de33908 100644
--- a/drivers/net/wan/cxt1e1/linux.c
+++ b/drivers/net/wan/cxt1e1/linux.c
@@ -1,11 +1,4 @@
-/*
- * $Id: linux.c,v 2.11 2008/01/03 20:53:03 rdobbs PMCC4_3_1B $
- */
-
-/*--------------------------------------------------------------------=
---------
- * linux.c -
- *
- * Copyright (C) 2007-2008  One Stop Systems
+/* Copyright (C) 2007-2008  One Stop Systems
  * Copyright (C) 2003-2006  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
@@ -17,86 +10,17 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@onestopsystems.=
com
- * One Stop Systems  Escondido, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 2.11 $
- * Last changed on $Date: 2008/01/03 20:53:03 $
- * Changed by $Author: rdobbs $
- *--------------------------------------------------------------------=
---------
- * $Log: linux.c,v $
- * Revision 2.11  2008/01/03 20:53:03  rdobbs
- * Release string name from SBE to OSSI.
- *
- * Revision 2.10  2007/08/15 22:04:02  rickd
- * Correct casting to *ULONG* w/in do_reset() to support 64bit compati=
bility.
- *
- * Revision 2.9  2007/05/02 22:50:19  rickd
- * Add GCC compiler checks from kernel's init/main.c
- *
- * Revision 2.8  2006/04/21 00:56:40  rickd
- * workqueue files now prefixed with <sbecom> prefix.
- *
- * Revision 2.7  2005/11/03 00:03:26  rickd
- * Routine c4_add_dev() can be declared __init.
- *
- * Revision 2.6  2005/11/02 23:48:22  rickd
- * Routine create_chan() was erroneoulsy declared __init, which is cau=
sing
- * panic under 2.6.13 as code is correctly removed from kernel space d=
ue
- * to the declaration (so removed declaration).
- *
- * Revision 2.5  2005/11/01 19:23:48  rickd
- * Add sanity checks against max_port for ioctl functions.
- * Several functions should return status_t for consistant usage of sa=
me.
- *
- * Revision 2.4  2005/10/27 18:54:18  rickd
- * Return c4_chan_up() failure code.  Clean out old code.
- *
- * Revision 2.3  2005/10/17 23:55:27  rickd
- * Initial port of NCOMM support patches from original work found
- * in pmc_c4t1e1 as updated by NCOMM.  Ref: CONFIG_SBE_PMCC4_NCOMM.
- * Added cleanup w/in c4_add_dev() if c4_init2() fails.
- *
- * Revision 2.2  2005/10/13 20:36:28  rickd
- * Fix compiler warning causaed by mixing code/declarations of <priv>.
- *
- * Revision 2.1  2005/10/11 18:35:15  rickd
- * Remove option ifname, it's not supported by the system's hdlc drive=
r
- * which explicitly names interface only <hdlc>.
- *
- * Revision 2.0  2005/09/28 00:10:06  rickd
- * Implement 2.6 workqueue for TX/RX restart. Use board's
- * serial number.
- *
- * Revision 1.4  2005/08/12 17:47:03  rickd
- * Major rewrite including MUSYCC bug fix updates.
- *
- * Revision 1.3  2005/05/10 22:40:54  rickd
- * Start switch to common structure variable names and routines.
- * Switch to THIS_MODULE usage in printks to handle alternate driver n=
ames.
- *
- * Revision 1.2  2005/04/28 23:54:48  rickd
- * Add RCS tracking header.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-char        OSSIid_pmcc4_linuxc[] =3D
-"@(#)linux.c - $Revision: 2.11 $   (c) Copyright 2008 One Stop Systems=
";
-
-
 #include <linux/types.h>
-#include "pmcc4_sysdep.h"
 #include <linux/netdevice.h>
 #include <linux/hdlc.h>
 #include <linux/if_arp.h>
 #include <linux/init.h>
-#include <asm/uaccess.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
-
+#include <asm/uaccess.h>
+#include "pmcc4_sysdep.h"
 #include "sbecom_inline_linux.h"
 #include "libsbew.h"
 #include "pmcc4.h"
@@ -139,7 +63,6 @@ status_t    c4_chan_work_init (mpi_t *, mch_t *);
 void        musycc_wq_chan_restart (void *);
 status_t __init c4_init (ci_t *, u_char *, u_char *);
 status_t __init c4_init2 (ci_t *);
-ci_t       *__init c4_new (void *);
 int __init  c4hw_attach_all (void);
 void __init hdw_sn_get (hdw_info_t *, int);
=20
@@ -160,7 +83,7 @@ status_t    musycc_chan_down (ci_t *, int);
 irqreturn_t musycc_intr_th_handler (void *);
 int         musycc_start_xmit (ci_t *, int, void *);
=20
-extern char pmcc4_OSSI_release[];
+static const char pmcc4_OSSI_release[] =3D "based on PMCC4_3_1B";
 extern ci_t *CI;
 extern struct s_hdw_info hdw_info[];
=20
@@ -185,24 +108,23 @@ extern int  unregister_hdlc_device_v7 (hdlc_devic=
e *);
 int         error_flag;         /* module load error reporting */
 int         log_level =3D LOG_ERROR;
 int         log_level_default =3D LOG_ERROR;
+module_param(log_level, int, 0444);
=20
-MODULE_PARM (log_level, "i");
 int         max_mru =3D MUSYCC_MRU;
 int         max_mru_default =3D MUSYCC_MRU;
+module_param(max_mru, int, 0444);
=20
-MODULE_PARM (max_mru, "i");
 int         max_mtu =3D MUSYCC_MTU;
 int         max_mtu_default =3D MUSYCC_MTU;
+module_param(max_mtu, int, 0444);
=20
-MODULE_PARM (max_mtu, "i");
 int         max_txdesc_used =3D MUSYCC_TXDESC_MIN;
 int         max_txdesc_default =3D MUSYCC_TXDESC_MIN;
+module_param(max_txdesc_used, int, 0444);
=20
-MODULE_PARM (max_txdesc_used, "i");
 int         max_rxdesc_used =3D MUSYCC_RXDESC_MIN;
 int         max_rxdesc_default =3D MUSYCC_RXDESC_MIN;
-
-MODULE_PARM (max_rxdesc_used, "i");
+module_param(max_rxdesc_used, int, 0444);
=20
 /*********************************************************************=
*******/
 /*********************************************************************=
*******/
@@ -218,10 +140,6 @@ getuserbychan (int channum)
 }
=20
=20
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#define DEV_TO_PRIV(dev) ( * (struct c4_priv **) ((hdlc_device*)(dev)+=
1))
-#else
-
 char       *
 get_hdlc_name (hdlc_device * hdlc)
 {
@@ -230,7 +148,6 @@ get_hdlc_name (hdlc_device * hdlc)
=20
     return dev->name;
 }
-#endif
=20
=20
 static      status_t
@@ -282,19 +199,11 @@ c4_wk_chan_restart (mch_t * ch)
     queue_work (pi->wq_port, &ch->ch_work);
 }
=20
-status_t
-c4_wk_chan_init (mpi_t * pi, mch_t * ch)
+status_t c4_wk_chan_init(mpi_t * pi, mch_t * ch)
 {
-    /*
-     * this will be used to restart a stopped channel
-     */
-
-    /** INIT_WORK (struct work_struct *work,
-     **            void (*function)(void *),
-     **            void *data);
-     **/
-    INIT_WORK (&ch->ch_work, musycc_wq_chan_restart, ch);
-    return 0;                       /* success */
+	/* this will be used to restart a stopped channel */
+	INIT_WORK (&ch->ch_work, musycc_wq_chan_restart);
+	return 0;
 }
=20
 status_t
@@ -337,14 +246,11 @@ c4_wq_port_cleanup (mpi_t * pi)
=20
 /*********************************************************************=
******/
=20
-irqreturn_t
-c4_linux_interrupt (int irq, void *dev_instance, struct pt_regs * regs=
)
+irqreturn_t c4_linux_interrupt(int irq, void *dev_instance)
 {
-    struct net_device *ndev =3D dev_instance;
+	struct net_device *ndev =3D dev_instance;
=20
-    if (!ndev->priv)
-        return IRQ_NONE;
-    return musycc_intr_th_handler (ndev->priv);
+	return musycc_intr_th_handler(netdev_priv(ndev));
 }
=20
=20
@@ -362,12 +268,6 @@ c4_ebus_interrupt (int irq, void *dev_instance, st=
ruct pt_regs * regs)
=20
=20
 static int
-void_init (struct net_device * ndev)
-{
-    return 0;
-}
-
-static int
 void_open (struct net_device * ndev)
 {
     printk ("%s: trying to open master device !\n", ndev->name);
@@ -375,161 +275,50 @@ void_open (struct net_device * ndev)
 }
=20
=20
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-
-/** Linux 2.4.18-19 **/
-STATIC int
-chan_open (hdlc_device * hdlc)
-{
-    status_t    ret;
-
-    if ((ret =3D c4_chan_up (DEV_TO_PRIV (hdlc)->ci, DEV_TO_PRIV (hdlc=
)->channum)))
-        return -ret;
-    MOD_INC_USE_COUNT;
-    netif_start_queue (hdlc_to_dev (hdlc));
-    return 0;                       /* no error =3D success */
-}
-
-#else
-
-/** Linux 2.4.20 and higher **/
-STATIC int
-chan_open (struct net_device * ndev)
+STATIC int chan_open(struct net_device *ndev)
 {
-    hdlc_device *hdlc =3D dev_to_hdlc (ndev);
-    status_t    ret;
-
-    hdlc->proto =3D IF_PROTO_HDLC;
-    if ((ret =3D hdlc_open (hdlc)))
-    {
-        printk ("%s: hdlc_open failure, err %d.\n", THIS_MODULE->name,=
 ret);
-        return ret;
-    }
-    if ((ret =3D c4_chan_up (DEV_TO_PRIV (hdlc)->ci, DEV_TO_PRIV (hdlc=
)->channum)))
-        return -ret;
-    MOD_INC_USE_COUNT;
-    netif_start_queue (hdlc_to_dev (hdlc));
-    return 0;                       /* no error =3D success */
-}
-#endif
-
-#else
-
-/** Linux 2.6 **/
-STATIC int
-chan_open (struct net_device * ndev)
-{
-    hdlc_device *hdlc =3D dev_to_hdlc (ndev);
-    const struct c4_priv *priv =3D hdlc->priv;
-    int         ret;
-
-    hdlc->proto.id =3D IF_PROTO_HDLC;
-    if ((ret =3D hdlc_open (ndev)))
-    {
-        printk ("%s: hdlc_open failure, err %d.\n", THIS_MODULE->name,=
 ret);
-        return ret;
-    }
-    if ((ret =3D c4_chan_up (priv->ci, priv->channum)))
-        return -ret;
-    try_module_get (THIS_MODULE);
-    netif_start_queue (ndev);
-    return 0;                       /* no error =3D success */
+	hdlc_device *hdlc =3D dev_to_hdlc (ndev);
+	const struct c4_priv *priv =3D hdlc->priv;
+	int ret;
+
+	if ((ret =3D hdlc_open (ndev))) {
+		printk ("%s: hdlc_open failure, err %d.\n",
+			THIS_MODULE->name, ret);
+		return ret;
+	}
+	if ((ret =3D c4_chan_up (priv->ci, priv->channum)))
+		return -ret;
+	try_module_get(THIS_MODULE);
+	netif_start_queue(ndev);
+	return 0;
 }
-#endif
=20
=20
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-
-/** Linux 2.4.18-19 **/
-STATIC void
-chan_close (hdlc_device * hdlc)
+STATIC int chan_close(struct net_device *ndev)
 {
-    netif_stop_queue (hdlc_to_dev (hdlc));
-    musycc_chan_down ((ci_t *) 0, DEV_TO_PRIV (hdlc)->channum);
-    MOD_DEC_USE_COUNT;
+	hdlc_device *hdlc =3D dev_to_hdlc (ndev);
+	const struct c4_priv *priv =3D hdlc->priv;
+
+	netif_stop_queue (ndev);
+	musycc_chan_down ((ci_t *) 0, priv->channum);
+	hdlc_close (ndev);
+	module_put (THIS_MODULE);
+	return 0;
 }
-#else
=20
-/** Linux 2.4.20 and higher **/
-STATIC int
-chan_close (struct net_device * ndev)
-{
-    hdlc_device *hdlc =3D dev_to_hdlc (ndev);
-
-    netif_stop_queue (hdlc_to_dev (hdlc));
-    musycc_chan_down ((ci_t *) 0, DEV_TO_PRIV (hdlc)->channum);
-    hdlc_close (hdlc);
-    MOD_DEC_USE_COUNT;
-    return 0;
-}
-#endif
=20
-#else
-
-/** Linux 2.6 **/
-STATIC int
-chan_close (struct net_device * ndev)
+STATIC int chan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, i=
nt cmd)
 {
-    hdlc_device *hdlc =3D dev_to_hdlc (ndev);
-    const struct c4_priv *priv =3D hdlc->priv;
-
-    netif_stop_queue (ndev);
-    musycc_chan_down ((ci_t *) 0, priv->channum);
-    hdlc_close (ndev);
-    module_put (THIS_MODULE);
-    return 0;
+    return hdlc_ioctl(dev, ifr, cmd);
 }
-#endif
-
=20
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
=20
-/** Linux 2.4.18-19 **/
-STATIC int
-chan_ioctl (hdlc_device * hdlc, struct ifreq * ifr, int cmd)
-{
-    if (cmd =3D=3D HDLCSCLOCK)
-    {
-        ifr->ifr_ifru.ifru_ivalue =3D LINE_DEFAULT;
-        return 0;
-    }
-    return -EINVAL;
-}
-#endif
-
-
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-STATIC int
-chan_dev_ioctl (struct net_device * hdlc, struct ifreq * ifr, int cmd)
-{
-    if (cmd =3D=3D HDLCSCLOCK)
-    {
-        ifr->ifr_ifru.ifru_ivalue =3D LINE_DEFAULT;
-        return 0;
-    }
-    return -EINVAL;
-}
-#else
-STATIC int
-chan_dev_ioctl (struct net_device * dev, struct ifreq * ifr, int cmd)
-{
-    return hdlc_ioctl (dev, ifr, cmd);
-}
-
-
-STATIC int
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-chan_attach_noop (hdlc_device * hdlc, unsigned short foo_1, unsigned s=
hort foo_2)
-#else
-chan_attach_noop (struct net_device * ndev, unsigned short foo_1, unsi=
gned short foo_2)
-#endif
+STATIC int chan_attach_noop(struct net_device *ndev, unsigned short fo=
o_1,
+			    unsigned short foo_2)
 {
     return 0;                   /* our driver has nothing to do here, =
show's
                                  * over, go home */
 }
-#endif
=20
=20
 STATIC struct net_device_stats *
@@ -539,23 +328,16 @@ chan_get_stats (struct net_device * ndev)
     struct net_device_stats *nstats;
     struct sbecom_chan_stats *stats;
     int         channum;
+    struct c4_priv *priv;
=20
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    channum =3D DEV_TO_PRIV (ndev)->channum;
-#else
-    {
-        struct c4_priv *priv;
-
-        priv =3D (struct c4_priv *) dev_to_hdlc (ndev)->priv;
-        channum =3D priv->channum;
-    }
-#endif
+    priv =3D (struct c4_priv *)dev_to_hdlc(ndev)->priv;
+    channum =3D priv->channum;
=20
     ch =3D c4_find_chan (channum);
     if (ch =3D=3D NULL)
         return NULL;
=20
-    nstats =3D &dev_to_hdlc (ndev)->stats;
+    nstats =3D &ndev->stats;
     stats =3D &ch->s;
=20
     memset (nstats, 0, sizeof (struct net_device_stats));
@@ -589,46 +371,34 @@ chan_get_stats (struct net_device * ndev)
 }
=20
=20
-static ci_t *
-get_ci_by_dev (struct net_device * ndev)
+static ci_t* get_ci_by_dev(struct net_device *ndev)
 {
-    return (ci_t *) ndev->priv;
+	return (ci_t *)netdev_priv(ndev);
 }
=20
=20
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-STATIC int
-c4_linux_xmit (hdlc_device * hdlc, struct sk_buff * skb)
+STATIC int c4_linux_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-    int         rval;
+	const struct c4_priv *priv;
+	int rval;
+	hdlc_device *hdlc =3D dev_to_hdlc(ndev);
=20
-    rval =3D musycc_start_xmit (DEV_TO_PRIV (hdlc)->ci, DEV_TO_PRIV (h=
dlc)->channum, skb);
-    return -rval;
+	priv =3D hdlc->priv;
+	rval =3D musycc_start_xmit (priv->ci, priv->channum, skb);
+	return -rval;
 }
-#else                           /* new */
-STATIC int
-c4_linux_xmit (struct sk_buff * skb, struct net_device * ndev)
-{
-    const struct c4_priv *priv;
-    int         rval;
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    priv =3D DEV_TO_PRIV (ndev);
-#else
-    hdlc_device *hdlc =3D dev_to_hdlc (ndev);
-
-    priv =3D hdlc->priv;
-#endif
=20
-    rval =3D musycc_start_xmit (priv->ci, priv->channum, skb);
-    return -rval;
-}
-#endif                          /* GENERIC_HDLC_VERSION */
=20
+static const struct net_device_ops chan_ops =3D {
+	.ndo_open       =3D chan_open,
+	.ndo_stop       =3D chan_close,
+	.ndo_start_xmit =3D c4_linux_xmit,
+	.ndo_do_ioctl   =3D chan_dev_ioctl,
+	.ndo_get_stats  =3D chan_get_stats,
+};
=20
-STATIC struct net_device *
-create_chan (struct net_device * ndev, ci_t * ci,
-             struct sbecom_chan_param * cp)
+STATIC struct net_device* create_chan(struct net_device *ndev, ci_t *c=
i,
+				      struct sbecom_chan_param *cp)
 {
     hdlc_device *hdlc;
     struct net_device *dev;
@@ -638,27 +408,6 @@ create_chan (struct net_device * ndev, ci_t * ci,
     if (c4_find_chan (cp->channum))
         return 0;                   /* channel already exists */
=20
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    hdlc =3D (hdlc_device *) OS_kmalloc (sizeof (hdlc_device) + sizeof=
 (void *));
-    if (!hdlc)
-    {
-        printk (KERN_WARNING "%s: no memory for hdlc_device !\n", ci->=
devname);
-        return 0;
-    }
-    dev =3D hdlc_to_dev (hdlc);
-
-    /* allocate and fill in private data structure */
-    DEV_TO_PRIV (dev) =3D kmalloc (sizeof (struct c4_priv), GFP_KERNEL=
);
-    if (!DEV_TO_PRIV (dev))
-    {
-        printk (KERN_WARNING "%s: no memory for c4_priv !\n", ci->devn=
ame);
-        OS_kfree (hdlc);
-        return 0;
-    }
-    DEV_TO_PRIV (dev)->ci =3D ci;
-    DEV_TO_PRIV (dev)->channum =3D cp->channum;
-
-#else
     {
         struct c4_priv *priv;
=20
@@ -681,13 +430,10 @@ create_chan (struct net_device * ndev, ci_t * ci,
     }
=20
     hdlc =3D dev_to_hdlc (dev);
-#endif
=20
     dev->base_addr =3D 0;             /* not I/O mapped */
     dev->irq =3D ndev->irq;
-    dev->init =3D void_init;
     dev->type =3D ARPHRD_RAWHDLC;
-    dev->do_ioctl =3D chan_dev_ioctl;
     *dev->name =3D 0;                 /* default ifconfig name =3D "hd=
lc" */
=20
     hi =3D (hdw_info_t *) ci->hdw_info;
@@ -711,15 +457,7 @@ create_chan (struct net_device * ndev, ci_t * ci,
     }
=20
     hdlc->xmit =3D c4_linux_xmit;
-
-#if !defined(GENERIC_HDLC_VERSION) || (GENERIC_HDLC_VERSION < 4)
-    hdlc->open =3D chan_open;
-    hdlc->close =3D chan_close;
-    hdlc->ioctl =3D chan_ioctl;
-#else                               /* new */
-    dev->hard_start_xmit =3D c4_linux_xmit;
-    dev->open =3D chan_open;
-    dev->stop =3D chan_close;
+    dev->netdev_ops =3D &chan_ops;
     /*
      * The native hdlc stack calls this 'attach' routine during
      * hdlc_raw_ioctl(), passing parameters for line encoding and pari=
ty.
@@ -730,16 +468,10 @@ create_chan (struct net_device * ndev, ci_t * ci,
      */
=20
     hdlc->attach =3D chan_attach_noop;
-#endif                              /* GENERIC_HDLC_VERSION */
=20
     rtnl_unlock ();                 /* needed due to Ioctl calling seq=
uence */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    ret =3D V7 (register_hdlc_device) (hdlc);
-#else
     ret =3D register_hdlc_device (dev);
-#endif
     /* NOTE: <stats> setting must occur AFTER registration in order to=
 "take" */
-    dev->get_stats =3D chan_get_stats;
     dev->tx_queue_len =3D MAX_DEFAULT_IFQLEN;
=20
     rtnl_lock ();                   /* needed due to Ioctl calling seq=
uence */
@@ -748,12 +480,7 @@ create_chan (struct net_device * ndev, ci_t * ci,
         if (log_level >=3D LOG_WARN)
             printk ("%s: create_chan[%d] registration error =3D %d.\n"=
,
                     ci->devname, cp->channum, ret);
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-        OS_kfree (DEV_TO_PRIV (dev));   /* cleanup */
-        OS_kfree (hdlc);            /* cleanup */
-#else
         free_netdev (dev);          /* cleanup */
-#endif
         return 0;                   /* failed to register */
     }
     return dev;
@@ -1036,26 +763,26 @@ do_deluser (struct net_device * ndev, int lockit=
)
     return 0;
 }
=20
-int
-do_del_chan (struct net_device * musycc_dev, void *data)
+int do_del_chan(struct net_device *musycc_dev, void *data)
 {
     struct sbecom_chan_param cp;
-    char        buf[sizeof (CHANNAME) + 3];
+    char buf[sizeof(CHANNAME) + 3];
     struct net_device *dev;
-    int         ret;
-
-    if (copy_from_user (&cp, data,
-                        sizeof (struct sbecom_chan_param)))
-        return -EFAULT;
-    sprintf (buf, CHANNAME "%d", cp.channum);
-    if (!(dev =3D dev_get_by_name (buf)))
-        return -ENOENT;
-    dev_put (dev);
-    ret =3D do_deluser (dev, 1);
+    int ret;
+
+    if (copy_from_user(&cp, data,
+		       sizeof(struct sbecom_chan_param)))
+	    return -EFAULT;
+    sprintf(buf, CHANNAME "%d", cp.channum);
+    if (!(dev =3D dev_get_by_name(&init_net, buf)))
+	    return -ENOENT;
+    dev_put(dev);
+    ret =3D do_deluser(dev, 1);
     if (ret)
-        return ret;
-    return c4_del_chan (cp.channum);
+	    return ret;
+    return c4_del_chan(cp.channum);
 }
+
 int         c4_reset_board (void *);
=20
 int
@@ -1070,20 +797,16 @@ do_reset (struct net_device * musycc_dev, void *=
data)
         char        buf[sizeof (CHANNAME) + 3];
=20
         sprintf (buf, CHANNAME "%d", i);
-        if (!(ndev =3D dev_get_by_name (buf)))
+        if (!(ndev =3D dev_get_by_name (&init_net, buf)))
             continue;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-        priv =3D DEV_TO_PRIV (ndev);
-#else
         priv =3D dev_to_hdlc (ndev)->priv;
-#endif
=20
 #if 0
         if ((unsigned long) (DEV_TO_PRIV (ndev)->ci) =3D=3D
             (unsigned long) (musycc_dev->priv))
 #else
         if ((unsigned long) (priv->ci) =3D=3D
-            (unsigned long) (musycc_dev->priv))
+            (unsigned long) (netdev_priv(musycc_dev)))
 #endif
         {
             ndev->flags &=3D ~IFF_UP;
@@ -1227,107 +950,108 @@ c4_ioctl (struct net_device * ndev, struct ifr=
eq * ifr, int cmd)
 }
=20
=20
-struct net_device *__init
-c4_add_dev (hdw_info_t * hi, int brdno, unsigned long f0, unsigned lon=
g f1,
-            int irq0, int irq1)
-{
-    struct net_device *ndev;
-    ci_t       *ci;
+static const struct net_device_ops c4_ops =3D {
+	.ndo_open       =3D void_open,
+	.ndo_start_xmit =3D c4_linux_xmit,
+	.ndo_do_ioctl   =3D c4_ioctl,
+};
=20
-    ndev =3D (struct net_device *) OS_kmalloc (sizeof (struct net_devi=
ce));
-    if (!ndev)
-    {
-        printk (KERN_WARNING "%s: no memory for struct net_device !\n"=
, hi->devname);
-        error_flag =3D ENOMEM;
-        return 0;
-    }
-    ndev->base_addr =3D 0;            /* not I/O mapped */
-    ndev->irq =3D irq0;
-    ndev->init =3D void_init;
-    ndev->type =3D ARPHRD_VOID;
-    ndev->open =3D void_open;
-    ndev->do_ioctl =3D c4_ioctl;
-    dev_alloc_name (ndev, SBE_IFACETMPL);
-
-    ndev->priv =3D c4_new ((void *) hi);
-    if (!ndev->priv)
-    {
-        printk (KERN_WARNING "%s: no memory for struct card_info !\n",=
 hi->devname);
-        OS_kfree (ndev);
-        error_flag =3D ENOMEM;
-        return 0;
-    }
-    ci =3D (ci_t *) ndev->priv;
-    strcpy (ci->devname, hi->devname);
-    ci->release =3D &pmcc4_OSSI_release[0];
=20
-    /* tasklet */
+static void c4_setup(struct net_device *dev)
+{
+	dev->type =3D ARPHRD_VOID;
+	dev->netdev_ops =3D &c4_ops;
+}
+
+struct net_device *__init c4_add_dev(hdw_info_t *hi, int brdno,
+				     unsigned long f0, unsigned long f1,
+				     int irq0, int irq1)
+{
+	struct net_device *ndev;
+	ci_t *ci;
+
+	ndev =3D alloc_netdev(sizeof(ci_t), SBE_IFACETMPL, c4_setup);
+	if (!ndev) {
+		printk(KERN_WARNING "%s: no memory for struct net_device !\n",
+		       hi->devname);
+		error_flag =3D ENOMEM;
+		return 0;
+	}
+	ci =3D netdev_priv(ndev);
+	ndev->irq =3D irq0;
+
+	ci->hdw_info =3D hi;
+	ci->state =3D C_INIT;         /* mark as hardware not available */
+	ci->next =3D c4_list;
+	c4_list =3D ci;
+	ci->brdno =3D ci->next ? ci->next->brdno + 1 : 0;
+
+	if (CI =3D=3D 0)
+		CI =3D ci;                    /* DEBUG, only board 0 usage */
+
+	strcpy (ci->devname, hi->devname);
+	ci->release =3D &pmcc4_OSSI_release[0];
+
+	/* tasklet */
 #if defined(SBE_ISR_TASKLET)
-    tasklet_init (&ci->ci_musycc_isr_tasklet,
-                  (void (*) (unsigned long)) musycc_intr_bh_tasklet,
-                  (unsigned long) ci);
+	tasklet_init (&ci->ci_musycc_isr_tasklet,
+		      (void (*) (unsigned long)) musycc_intr_bh_tasklet,
+		      (unsigned long) ci);
=20
-    if (atomic_read (&ci->ci_musycc_isr_tasklet.count) =3D=3D 0)
-        tasklet_disable_nosync (&ci->ci_musycc_isr_tasklet);
+	if (atomic_read (&ci->ci_musycc_isr_tasklet.count) =3D=3D 0)
+		tasklet_disable_nosync (&ci->ci_musycc_isr_tasklet);
 #elif defined(SBE_ISR_IMMEDIATE)
-    ci->ci_musycc_isr_tq.routine =3D (void *) (unsigned long) musycc_i=
ntr_bh_tasklet;
-    ci->ci_musycc_isr_tq.data =3D ci;
+	ci->ci_musycc_isr_tq.routine =3D (void *) (unsigned long) musycc_intr=
_bh_tasklet;
+	ci->ci_musycc_isr_tq.data =3D ci;
 #endif
=20
=20
-    if (register_netdev (ndev) ||
-        (c4_init (ci, (u_char *) f0, (u_char *) f1) !=3D SBE_DRVR_SUCC=
ESS))
-    {
-        OS_kfree (ndev->priv);
-        OS_kfree (ndev);
-        error_flag =3D ENODEV;
-        return 0;
-    }
-    /*************************************************************
-     *  int request_irq(unsigned int irq,
-     *                  void (*handler)(int, void *, struct pt_regs *)=
,
-     *                  unsigned long flags, const char *dev_name, voi=
d *dev_id);
-     *  wherein:
-     *  irq      -> The interrupt number that is being requested.
-     *  handler  -> Pointer to handling function being installed.
-     *  flags    -> A bit mask of options related to interrupt managem=
ent.
-     *  dev_name -> String used in /proc/interrupts to show owner of i=
nterrupt.
-     *  dev_id   -> Pointer (for shared interrupt lines) to point to i=
ts own
-     *              private data area (to identify which device is int=
errupting).
-     *
-     *  extern void free_irq(unsigned int irq, void *dev_id);
-     **************************************************************/
-
-    if (request_irq (irq0, &c4_linux_interrupt,
-#if defined(SBE_ISR_TASKLET)
-                     SA_INTERRUPT | SA_SHIRQ,
-#elif defined(SBE_ISR_IMMEDIATE)
-                     SA_INTERRUPT | SA_SHIRQ,
+	if (register_netdev (ndev) ||
+	    (c4_init (ci, (u_char *) f0, (u_char *) f1) !=3D SBE_DRVR_SUCCESS=
)) {
+		free_netdev(ndev);
+		error_flag =3D ENODEV;
+		return 0;
+	}
+	/*************************************************************
+	 *  int request_irq(unsigned int irq,
+	 *                  void (*handler)(int, void *, struct pt_regs *),
+	 *                  unsigned long flags, const char *dev_name, void *=
dev_id);
+	 *  wherein:
+	 *  irq      -> The interrupt number that is being requested.
+	 *  handler  -> Pointer to handling function being installed.
+	 *  flags    -> A bit mask of options related to interrupt management=
=2E
+	 *  dev_name -> String used in /proc/interrupts to show owner of inte=
rrupt.
+	 *  dev_id   -> Pointer (for shared interrupt lines) to point to its =
own
+	 *              private data area (to identify which device is interr=
upting).
+	 *
+	 *  extern void free_irq(unsigned int irq, void *dev_id);
+	 **************************************************************/
+
+	if (request_irq(irq0, &c4_linux_interrupt,
+#if defined(SBE_ISR_TASKLET) || defined(SBE_ISR_IMMEDIATE)
+			 IRQF_DISABLED | IRQF_SHARED,
 #elif defined(SBE_ISR_INLINE)
-                     SA_SHIRQ,
+			 IRQF_SHARED,
 #endif
-                     ndev->name, ndev))
-    {
-        printk (KERN_WARNING "%s: MUSYCC could not get irq: %d\n",
-                ndev->name, irq0);
-        unregister_netdev (ndev);
-        OS_kfree (ndev->priv);
-        OS_kfree (ndev);
-        error_flag =3D EIO;
-        return 0;
-    }
+			 ndev->name, ndev)) {
+		printk(KERN_WARNING "%s: MUSYCC could not get irq: %d\n",
+			ndev->name, irq0);
+		unregister_netdev(ndev);
+		free_netdev(ndev);
+		error_flag =3D EIO;
+		return 0;
+	}
 #ifdef CONFIG_SBE_PMCC4_NCOMM
-    if (request_irq (irq1, &c4_ebus_interrupt, SA_SHIRQ, ndev->name, n=
dev))
-    {
-        printk (KERN_WARNING "%s: EBUS could not get irq: %d\n",
-                hi->devname, irq1);
-        unregister_netdev (ndev);
-        free_irq (irq0, ndev);
-        OS_kfree (ndev->priv);
-        OS_kfree (ndev);
-        error_flag =3D EIO;
-        return 0;
-    }
+	if (request_irq(irq1, &c4_ebus_interrupt, IRQF_SHARED, ndev->name, nd=
ev))
+	{
+		printk (KERN_WARNING "%s: EBUS could not get irq: %d\n",
+			hi->devname, irq1);
+		unregister_netdev(ndev);
+		free_irq(irq0, ndev);
+		free_netdev(ndev);
+		error_flag =3D EIO;
+		return 0;
+	}
 #endif
=20
     /* setup board identification information */
@@ -1382,8 +1106,7 @@ c4_add_dev (hdw_info_t * hi, int brdno, unsigned =
long f0, unsigned long f1,
         unregister_netdev (ndev);
         free_irq (irq1, ndev);
         free_irq (irq0, ndev);
-        OS_kfree (ndev->priv);
-        OS_kfree (ndev);
+	free_netdev(ndev);
         return 0;                   /* failure, error_flag is set */
     }
     return ndev;
@@ -1443,7 +1166,7 @@ cleanup_hdlc (void)
     {
         if (hi->ndev)               /* a board has been attached */
         {
-            ci =3D (ci_t *) hi->ndev->priv;
+	    ci =3D (ci_t *) netdev_priv(hi->ndev);
             for (j =3D 0; j < ci->max_port; j++)
                 for (k =3D 0; k < MUSYCC_NCHANS; k++)
                     if ((ndev =3D ci->port[j].chan[k]->user))
diff --git a/drivers/net/wan/cxt1e1/musycc.c b/drivers/net/wan/cxt1e1/m=
usycc.c
index 8fc42dd..d72f610 100644
--- a/drivers/net/wan/cxt1e1/musycc.c
+++ b/drivers/net/wan/cxt1e1/musycc.c
@@ -1,14 +1,7 @@
-/*
- * $Id: musycc.c,v 2.1 2007/08/15 23:32:17 rickd PMCC4_3_1B $
- */
-
 unsigned int max_intcnt =3D 0;
 unsigned int max_bh =3D 0;
=20
-/*--------------------------------------------------------------------=
---------
- * musycc.c -
- *
- * Copyright (C) 2007  One Stop Systems, Inc.
+/* Copyright (C) 2007  One Stop Systems, Inc.
  * Copyright (C) 2003-2006  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
@@ -20,63 +13,12 @@ unsigned int max_bh =3D 0;
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@onestopsystems.=
com
- * One Stop Systems, Inc.  Escondido, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 2.1 $
- * Last changed on $Date: 2007/08/15 23:32:17 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: musycc.c,v $
- * Revision 2.1  2007/08/15 23:32:17  rickd
- * Use 'if 0' instead of GNU comment delimeter to avoid line wrap indu=
ced compiler errors.
- *
- * Revision 2.0  2007/08/15 22:13:20  rickd
- * Update to printf pointer %p usage and correct some UINT to ULONG fo=
r
- * 64bit comptibility.
- *
- * Revision 1.7  2006/04/21 00:56:40  rickd
- * workqueue files now prefixed with <sbecom> prefix.
- *
- * Revision 1.6  2005/10/27 18:54:19  rickd
- * Clean out old code.  Default to HDLC_FCS16, not TRANS.
- *
- * Revision 1.5  2005/10/17 23:55:28  rickd
- * Initial port of NCOMM support patches from original work found
- * in pmc_c4t1e1 as updated by NCOMM.  Ref: CONFIG_SBE_PMCC4_NCOMM.
- *
- * Revision 1.4  2005/10/13 20:35:25  rickd
- * Cleanup warning for unused <flags> variable.
- *
- * Revision 1.3  2005/10/13 19:19:22  rickd
- * Disable redundant driver removal cleanup code.
- *
- * Revision 1.2  2005/10/11 18:36:16  rickd
- * Clean up warning messages caused by de-implemented some <flags> ass=
ociated
- * with spin_lock() removals.
- *
- * Revision 1.1  2005/10/05 00:45:28  rickd
- * Re-enable xmit on flow-controlled and full channel to fix restart h=
ang.
- * Add some temp spin-lock debug code (rld_spin_owner).
- *
- * Revision 1.0  2005/09/28 00:10:06  rickd
- * Initial release for C4T1E1 support. Lots of transparent
- * mode updates.
- *
- *--------------------------------------------------------------------=
---------
  */
-
-char        SBEid_pmcc4_musyccc[] =3D
-"@(#)musycc.c - $Revision: 2.1 $      (c) Copyright 2004-2006 SBE, Inc=
=2E";
-
-
 #include <linux/types.h>
-#include "pmcc4_sysdep.h"
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include "pmcc4_sysdep.h"
 #include "sbecom_inline_linux.h"
 #include "libsbew.h"
 #include "pmcc4_private.h"
@@ -706,9 +648,7 @@ rewrite:
 }
=20
=20
-#ifdef  SBE_PMCC4_ENABLE
-void
-musycc_update_timeslots (mpi_t * pi)
+void musycc_update_timeslots(mpi_t *pi)
 {
     int         i, ch;
     char        e1mode =3D IS_FRAME_ANY_E1 (pi->p.port_mode);
@@ -773,43 +713,6 @@ musycc_update_timeslots (mpi_t * pi)
     musycc_serv_req (pi, SR_SUBCHANNEL_MAP | SR_RX_DIRECTION);
     musycc_serv_req (pi, SR_SUBCHANNEL_MAP | SR_TX_DIRECTION);
 }
-#endif
-
-
-#ifdef SBE_WAN256T3_ENABLE
-void
-musycc_update_timeslots (mpi_t * pi)
-{
-    mch_t      *ch;
-
-    u_int8_t    ts, hmask, tsen;
-    int         gchan;
-    int         i;
-
-#ifdef SBE_PMCC4_ENABLE
-    hmask =3D (0x1f << pi->up->p.hypersize) & 0x1f;
-#endif
-#ifdef SBE_WAN256T3_ENABLE
-    hmask =3D (0x1f << hyperdummy) & 0x1f;
-#endif
-    for (i =3D 0; i < 128; i++)
-    {
-        gchan =3D ((pi->portnum * MUSYCC_NCHANS) + (i & hmask)) % MUSY=
CC_NCHANS;
-        ch =3D pi->chan[gchan];
-        if (ch->p.mode_56k)
-            tsen =3D MODE_56KBPS;
-        else
-            tsen =3D MODE_64KBPS;     /* also the default */
-        ts =3D ((pi->portnum % 4) =3D=3D (i / 32)) ? (tsen << 5) | (i =
& hmask) : 0;
-        pi->regram->rtsm[i] =3D ts;
-        pi->regram->ttsm[i] =3D ts;
-    }
-    FLUSH_MEM_WRITE ();
-    musycc_serv_req (pi, SR_TIMESLOT_MAP | SR_RX_DIRECTION);
-    musycc_serv_req (pi, SR_TIMESLOT_MAP | SR_TX_DIRECTION);
-}
-#endif
-
=20
  /*
   * This routine converts a generic library channel configuration para=
meter
@@ -841,41 +744,6 @@ musycc_chan_proto (int proto)
     return reg;
 }
=20
-#ifdef SBE_WAN256T3_ENABLE
-STATIC void __init
-musycc_init_port (mpi_t * pi)
-{
-    pci_write_32 ((u_int32_t *) &pi->reg->gbp, OS_vtophys (pi->regram)=
);
-
-    pi->regram->grcd =3D
-        __constant_cpu_to_le32 (MUSYCC_GRCD_RX_ENABLE |
-                                MUSYCC_GRCD_TX_ENABLE |
-                                MUSYCC_GRCD_SF_ALIGN |
-                                MUSYCC_GRCD_SUBCHAN_DISABLE |
-                                MUSYCC_GRCD_OOFMP_DISABLE |
-                                MUSYCC_GRCD_COFAIRQ_DISABLE |
-                                MUSYCC_GRCD_MC_ENABLE |
-                       (MUSYCC_GRCD_POLLTH_32 << MUSYCC_GRCD_POLLTH_SH=
IFT));
-
-    pi->regram->pcd =3D
-        __constant_cpu_to_le32 (MUSYCC_PCD_E1X4_MODE |
-                                MUSYCC_PCD_TXDATA_RISING |
-                                MUSYCC_PCD_TX_DRIVEN);
-
-    /* Message length descriptor */
-    pi->regram->mld =3D __constant_cpu_to_le32 (max_mru | (max_mru << =
16));
-    FLUSH_MEM_WRITE ();
-
-    musycc_serv_req (pi, SR_GROUP_INIT | SR_RX_DIRECTION);
-    musycc_serv_req (pi, SR_GROUP_INIT | SR_TX_DIRECTION);
-
-    musycc_init_mdt (pi);
-
-    musycc_update_timeslots (pi);
-}
-#endif
-
-
 status_t    __init
 musycc_init (ci_t * ci)
 {
@@ -969,10 +837,6 @@ musycc_init (ci_t * ci)
                 THIS_MODULE->name, max_mtu, 0xffe);
         max_mtu =3D 0xffe;
     }
-#ifdef SBE_WAN256T3_ENABLE
-    for (i =3D 0; i < MUSYCC_NPORTS; i++)
-        musycc_init_port (&ci->port[i]);
-#endif
=20
     return SBE_DRVR_SUCCESS;        /* no error */
 }
@@ -1072,24 +936,6 @@ musycc_bh_tx_eom (mpi_t * pi, int gchan)
             atomic_sub (OS_mem_token_tlen (md->mem_token), &ch->tx_pen=
ding);
             /* upcount card */
             atomic_sub (OS_mem_token_tlen (md->mem_token), &pi->up->tx=
_pending);
-#ifdef SBE_WAN256T3_ENABLE
-            if (!atomic_read (&pi->up->tx_pending))
-                wan256t3_led (pi->up, LED_TX, 0);
-#endif
-
-#ifdef CONFIG_SBE_WAN256T3_NCOMM
-            /* callback that our packet was sent */
-            {
-                int         hdlcnum =3D (pi->portnum * 32 + gchan);
-
-                if (hdlcnum >=3D 228)
-                {
-                    if (nciProcess_TX_complete)
-                        (*nciProcess_TX_complete) (hdlcnum,
-                                                   getuserbychan (gcha=
n));
-                }
-            }
-#endif                              /*** CONFIG_SBE_WAN256T3_NCOMM ***=
/
=20
             OS_mem_token_free_irq (md->mem_token);
             md->mem_token =3D 0;
@@ -1197,21 +1043,6 @@ musycc_bh_rx_eom (mpi_t * pi, int gchan)
         error =3D (status >> 16) & 0xf;
         if (error =3D=3D 0)
         {
-#ifdef CONFIG_SBE_WAN256T3_NCOMM
-            int         hdlcnum =3D (pi->portnum * 32 + gchan);
-
-            /*
-             * if the packet number belongs to NCOMM, then send it to =
the TMS
-             * driver
-             */
-            if (hdlcnum >=3D 228)
-            {
-                if (nciProcess_RX_packet)
-                    (*nciProcess_RX_packet) (hdlcnum, status & 0x3fff,=
 m, ch->user);
-            } else
-#endif                              /*** CONFIG_SBE_WAN256T3_NCOMM ***=
/
-
-            {
                 if ((m2 =3D OS_mem_token_alloc (max_mru)))
                 {
                     /* substitute the mbuf+cluster */
@@ -1226,7 +1057,6 @@ musycc_bh_rx_eom (mpi_t * pi, int gchan)
                 {
                     ch->s.rx_dropped++;
                 }
-            }
         } else if (error =3D=3D ERR_FCS)
         {
             ch->s.rx_crc_errors++;
@@ -1750,9 +1580,7 @@ musycc_new_chan (ci_t * ci, int channum, void *us=
er)
 #endif
=20
=20
-#ifdef SBE_PMCC4_ENABLE
-status_t
-musycc_chan_down (ci_t * dummy, int channum)
+status_t musycc_chan_down(ci_t *dummy, int channum)
 {
     mpi_t      *pi;
     mch_t      *ch;
@@ -1803,7 +1631,6 @@ musycc_chan_down (ci_t * dummy, int channum)
     pi->openchans--;
     return 0;
 }
-#endif
=20
=20
 int
@@ -2035,9 +1862,6 @@ musycc_start_xmit (ci_t * ci, int channum, void *=
mem_token)
         musycc_chan_restart (ch);
 #endif
     }
-#ifdef SBE_WAN256T3_ENABLE
-    wan256t3_led (ci, LED_TX, LEDV_G);
-#endif
     return 0;
 }
=20
@@ -2125,56 +1949,3 @@ musycc_get_chan_stats (ci_t * ci, int channum, s=
truct sbecom_chan_stats * p)
     p->tx_pending =3D atomic_read (&ch->tx_pending);
     return 0;
 }
-
-
-
-#ifdef SBE_WAN256T3_ENABLE
-int
-musycc_chan_down (ci_t * ci, int channum)
-{
-    mch_t      *ch;
-    mpi_t      *pi;
-    int         i, gchan;
-
-    if (!(ch =3D sd_find_chan (ci, channum)))
-        return EINVAL;
-    pi =3D ch->up;
-    gchan =3D ch->gchan;
-
-    /* Deactivate the channel */
-    musycc_serv_req (pi, SR_CHANNEL_DEACTIVATE | SR_RX_DIRECTION | gch=
an);
-    ch->ch_start_rx =3D 0;
-    musycc_serv_req (pi, SR_CHANNEL_DEACTIVATE | SR_TX_DIRECTION | gch=
an);
-    ch->ch_start_tx =3D 0;
-
-    if (ch->state =3D=3D DOWN)
-        return 0;
-    ch->state =3D DOWN;
-
-    pi->regram->thp[gchan] =3D 0;
-    pi->regram->tmp[gchan] =3D 0;
-    pi->regram->rhp[gchan] =3D 0;
-    pi->regram->rmp[gchan] =3D 0;
-    FLUSH_MEM_WRITE ();
-    for (i =3D 0; i < ch->txd_num; i++)
-    {
-        if (ch->mdt[i].mem_token !=3D 0)
-            OS_mem_token_free (ch->mdt[i].mem_token);
-    }
-
-    for (i =3D 0; i < ch->rxd_num; i++)
-    {
-        if (ch->mdr[i].mem_token !=3D 0)
-            OS_mem_token_free (ch->mdr[i].mem_token);
-    }
-
-    OS_kfree (ch->mdt);
-    ch->mdt =3D 0;
-    OS_kfree (ch->mdr);
-    ch->mdr =3D 0;
-
-    return 0;
-}
-#endif
-
-/*** End-of-File ***/
diff --git a/drivers/net/wan/cxt1e1/musycc.h b/drivers/net/wan/cxt1e1/m=
usycc.h
index d2c91ef..c4c074c 100644
--- a/drivers/net/wan/cxt1e1/musycc.h
+++ b/drivers/net/wan/cxt1e1/musycc.h
@@ -1,12 +1,7 @@
-/*
- * $Id: musycc.h,v 1.3 2005/09/28 00:10:08 rickd PMCC4_3_1B $
- */
-
 #ifndef _INC_MUSYCC_H_
 #define _INC_MUSYCC_H_
=20
-/*--------------------------------------------------------------------=
---------
- * musycc.h - Multichannel Synchronous Communications Controller
+/* musycc.h - Multichannel Synchronous Communications Controller
  *            CN8778/8474A/8472A/8471A
  *
  * Copyright (C) 2002-2005  SBE, Inc.
@@ -20,40 +15,13 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.3 $
- * Last changed on $Date: 2005/09/28 00:10:08 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: musycc.h,v $
- * Revision 1.3  2005/09/28 00:10:08  rickd
- * Add GNU license info. Add PMCC4 PCI/DevIDs.  Implement new
- * musycc reg&bits namings. Use PORTMAP_0 GCD grouping.
- *
- * Revision 1.2  2005/04/28 23:43:04  rickd
- * Add RCS tracking heading.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-#if defined (__FreeBSD__) || defined (__NetBSD__)
-#include <sys/types.h>
-#else
 #include <linux/types.h>
-#endif
=20
 #define VINT8   volatile u_int8_t
 #define VINT32  volatile u_int32_t
=20
-#ifdef __cplusplus
-extern      "C"
-{
-#endif
-
 #include "pmcc4_defs.h"
=20
=20
@@ -149,19 +117,10 @@ extern      "C"
                                          * etc... */
=20
 /* and board specific assignments... */
-#ifdef SBE_WAN256T3_ENABLE
-#define BLAPSE_VAL      0
-#define ALAPSE_VAL      0
-#define ELAPSE_VAL      7
-#define PORTMAP_VAL     MUSYCC_GCD_PORTMAP_2
-#endif
-
-#ifdef SBE_PMCC4_ENABLE
 #define BLAPSE_VAL      7
 #define ALAPSE_VAL      3
 #define ELAPSE_VAL      7
 #define PORTMAP_VAL     MUSYCC_GCD_PORTMAP_0
-#endif
=20
 #define GCD_MAGIC   (((BLAPSE_VAL)<<(MUSYCC_GCD_BLAPSE)) | \
                      ((ALAPSE_VAL)<<(MUSYCC_GCD_ALAPSE)) | \
@@ -448,13 +407,7 @@ extern      "C"
 /*  This must be defined on an entire channel group (Port) basis */
 #define SUERM_THRESHOLD     0x1f
=20
-#ifdef __cplusplus
-}
-#endif
-
 #undef VINT32
 #undef VINT8
=20
-#endif                          /*** _INC_MUSYCC_H_ ***/
-
-/*** End-of-File ***/
+#endif
diff --git a/drivers/net/wan/cxt1e1/pmcc4_defs.h b/drivers/net/wan/cxt1=
e1/pmcc4_defs.h
index 186347b..2c6e95c 100644
--- a/drivers/net/wan/cxt1e1/pmcc4_defs.h
+++ b/drivers/net/wan/cxt1e1/pmcc4_defs.h
@@ -1,14 +1,7 @@
-/*
- * $Id: pmcc4_defs.h,v 1.0 2005/09/28 00:10:09 rickd PMCC4_3_1B $
- */
-
 #ifndef _INC_PMCC4_DEFS_H_
 #define _INC_PMCC4_DEFS_H_
=20
-/*--------------------------------------------------------------------=
---------
- * c4_defs.h -
- *
- *   Implementation elements of the wanPMC-C4T1E1 device driver
+/*   Implementation elements of the wanPMC-C4T1E1 device driver
  *
  * Copyright (C) 2005  SBE, Inc.
  *
@@ -21,32 +14,13 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.0 $
- * Last changed on $Date: 2005/09/28 00:10:09 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: pmcc4_defs.h,v $
- * Revision 1.0  2005/09/28 00:10:09  rickd
- * Initial revision
- *
- *--------------------------------------------------------------------=
---------
  */
=20
=20
 #define MAX_BOARDS          8
 #define MAX_CHANS_USED      128
=20
-#ifdef  SBE_PMCC4_ENABLE
 #define MUSYCC_NPORTS       4     /* CN8474 */
-#endif
-#ifdef SBE_WAN256T3_ENABLE
-#define MUSYCC_NPORTS       8     /* CN8478 */
-#endif
 #define MUSYCC_NCHANS       32    /* actually, chans per port */
=20
 #define MUSYCC_NIQD         0x1000    /* power of 2 */
diff --git a/drivers/net/wan/cxt1e1/pmcc4_drv.c b/drivers/net/wan/cxt1e=
1/pmcc4_drv.c
index 27f2a74..8647cac 100644
--- a/drivers/net/wan/cxt1e1/pmcc4_drv.c
+++ b/drivers/net/wan/cxt1e1/pmcc4_drv.c
@@ -1,12 +1,4 @@
-/*
- * $Id: pmcc4_drv.c,v 3.1 2007/08/15 23:32:17 rickd PMCC4_3_1B $
- */
-
-
-/*--------------------------------------------------------------------=
---------
- * pmcc4_drv.c -
- *
- * Copyright (C) 2007  One Stop Systems, Inc.
+/* Copyright (C) 2007  One Stop Systems, Inc.
  * Copyright (C) 2002-2006  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
@@ -18,87 +10,16 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@onestopsystems.=
com
- * One Stop Systems, Inc.  Escondido, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 3.1 $
- * Last changed on $Date: 2007/08/15 23:32:17 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: pmcc4_drv.c,v $
- * Revision 3.1  2007/08/15 23:32:17  rickd
- * Use 'if 0' instead of GNU comment delimeter to avoid line wrap indu=
ced compiler errors.
- *
- * Revision 3.0  2007/08/15 22:19:55  rickd
- * Correct sizeof() castings and pi->regram to support 64bit compatibi=
lity.
- *
- * Revision 2.10  2006/04/21 00:56:40  rickd
- * workqueue files now prefixed with <sbecom> prefix.
- *
- * Revision 2.9  2005/11/01 19:22:49  rickd
- * Add sanity checks against max_port for ioctl functions.
- *
- * Revision 2.8  2005/10/27 18:59:25  rickd
- * Code cleanup.  Default channel config to HDLC_FCS16.
- *
- * Revision 2.7  2005/10/18 18:16:30  rickd
- * Further NCOMM code repairs - (1) interrupt matrix usage inconsistan=
t
- * for indexing into nciInterrupt[][], code missing double parameters.
- * (2) check input of ncomm interrupt registration cardID for correct
- * boundary values.
- *
- * Revision 2.6  2005/10/17 23:55:28  rickd
- * Initial port of NCOMM support patches from original work found
- * in pmc_c4t1e1 as updated by NCOMM.  Ref: CONFIG_SBE_PMCC4_NCOMM.
- * Corrected NCOMMs wanpmcC4T1E1_getBaseAddress() to correctly handle
- * multiple boards.
- *
- * Revision 2.5  2005/10/13 23:01:28  rickd
- * Correct panic for illegal address reference w/in get_brdinfo on
- * first_if/last_if name acquistion under Linux 2.6
- *
- * Revision 2.4  2005/10/13 21:20:19  rickd
- * Correction of c4_cleanup() wherein next should be acquired before
- * ci_t structure is free'd.
- *
- * Revision 2.3  2005/10/13 19:20:10  rickd
- * Correct driver removal cleanup code for multiple boards.
- *
- * Revision 2.2  2005/10/11 18:34:04  rickd
- * New routine added to determine number of ports (comets) on board.
- *
- * Revision 2.1  2005/10/05 00:48:13  rickd
- * Add some RX activation trace code.
- *
- * Revision 2.0  2005/09/28 00:10:06  rickd
- * Implement 2.6 workqueue for TX/RX restart.  Correction to
- * hardware register boundary checks allows expanded access of MUSYCC.
- * Implement new musycc reg&bits namings.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-char        OSSIid_pmcc4_drvc[] =3D
-"@(#)pmcc4_drv.c - $Revision: 3.1 $   (c) Copyright 2002-2007 One Stop=
 Systems, Inc.";
-
-
-#if defined (__FreeBSD__) || defined (__NetBSD__)
-#include <sys/param.h>
-#include <sys/systm.h>
-#include <sys/errno.h>
-#else
 #include <linux/types.h>
-#include "pmcc4_sysdep.h"
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>        /* include for timer */
 #include <linux/timer.h>        /* include for timer */
 #include <linux/hdlc.h>
 #include <asm/io.h>
-#endif
-
+#include "pmcc4_sysdep.h"
 #include "sbecom_inline_linux.h"
 #include "libsbew.h"
 #include "pmcc4_private.h"
@@ -118,12 +39,9 @@ char        OSSIid_pmcc4_drvc[] =3D
 #define KERN_WARN KERN_WARNING
=20
 /* forward references */
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
 status_t    c4_wk_chan_init (mpi_t *, mch_t *);
 void        c4_wq_port_cleanup (mpi_t *);
 status_t    c4_wq_port_init (mpi_t *);
-
-#endif
 int         c4_loop_port (ci_t *, int, u_int8_t);
 status_t    c4_set_port (ci_t *, int);
 status_t    musycc_chan_down (ci_t *, int);
@@ -201,34 +119,6 @@ c4_find_chan (int channum)
 }
=20
=20
-ci_t       *__init
-c4_new (void *hi)
-{
-    ci_t       *ci;
-
-#ifdef SBE_MAP_DEBUG
-    printk (KERN_WARNING "%s: c4_new() entered, ci needs %u.\n",
-            THIS_MODULE->name, (unsigned int) sizeof (ci_t));
-#endif
-
-    ci =3D (ci_t *) OS_kmalloc (sizeof (ci_t));
-    if (ci)
-    {
-        ci->hdw_info =3D hi;
-        ci->state =3D C_INIT;         /* mark as hardware not availabl=
e */
-        ci->next =3D c4_list;
-        c4_list =3D ci;
-        ci->brdno =3D ci->next ? ci->next->brdno + 1 : 0;
-    } else
-        printk (KERN_WARNING "%s: failed CI malloc, size %u.\n",
-                THIS_MODULE->name, (unsigned int) sizeof (ci_t));
-
-    if (CI =3D=3D 0)
-        CI =3D ci;                    /* DEBUG, only board 0 usage */
-    return ci;
-}
-
-
 /***
  * Check port state and set LED states using watchdog or ioctl...
  * also check for in-band SF loopback commands (& cause results if the=
y are there)
diff --git a/drivers/net/wan/cxt1e1/pmcc4_private.h b/drivers/net/wan/c=
xt1e1/pmcc4_private.h
index 4ee424f..431a718 100644
--- a/drivers/net/wan/cxt1e1/pmcc4_private.h
+++ b/drivers/net/wan/cxt1e1/pmcc4_private.h
@@ -1,14 +1,7 @@
-/*
- * $Id: pmcc4_private.h,v 1.4 2005/10/27 18:54:19 rickd PMCC4_3_1B $
- */
-
 #ifndef _INC_PMCC4_PRIVATE_H_
 #define _INC_PMCC4_PRIVATE_H_
=20
-/*--------------------------------------------------------------------=
---------
- * pmcc4_private.h -
- *
- * Copyright (C) 2005  SBE, Inc.
+/* Copyright (C) 2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
  *   it under the terms of the GNU General Public License as published=
 by
@@ -19,40 +12,15 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.4 $
- * Last changed on $Date: 2005/10/27 18:54:19 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: pmcc4_private.h,v $
- * Revision 1.4  2005/10/27 18:54:19  rickd
- * Clean out old watchdog_copy code.  Msg Desc <status> to volatile.
- *
- * Revision 1.3  2005/09/28 00:10:09  rickd
- * Add GNU License info.  Name changed from c4_private.h.
- *
- * Revision 1.2  2005/04/28 23:43:03  rickd
- * Add RCS tracking heading.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
=20
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/spinlock.h>
-#include <asm/semaphore.h>
 #include <linux/interrupt.h>    /* support for tasklets */
 #include <linux/timer.h>        /* support for timer */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#include <linux/tqueue.h>       /* support for tq_struct */
-#else
 #include <linux/workqueue.h>
-#endif
 #include <linux/hdlc.h>
=20
 #include "libsbew.h"
diff --git a/drivers/net/wan/cxt1e1/pmcc4_sysdep.h b/drivers/net/wan/cx=
t1e1/pmcc4_sysdep.h
index 9e71a8b..bde7f0a 100644
--- a/drivers/net/wan/cxt1e1/pmcc4_sysdep.h
+++ b/drivers/net/wan/cxt1e1/pmcc4_sysdep.h
@@ -1,12 +1,9 @@
-/*
- * $Id: pmcc4_sysdep.h,v 1.1 2005/09/28 00:10:09 rickd PMCC4_3_1B $
- */
-
 #ifndef _INC_PMCC4_SYSDEP_H_
 #define _INC_PMCC4_SYSDEP_H_
=20
-/*--------------------------------------------------------------------=
---------
- * pmcc4_sysdep.h -
+#include <linux/kernel.h>
+
+/*
  *
  * Copyright (C) 2005  SBE, Inc.
  *
@@ -20,55 +17,8 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.1 $
- * Last changed on $Date: 2005/09/28 00:10:09 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: pmcc4_sysdep.h,v $
- * Revision 1.1  2005/09/28 00:10:09  rickd
- * Add GNU License info.
- *
- * Revision 1.0  2005/05/04 17:19:25  rickd
- * Initial revision
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-
-#if defined (__FreeBSD__) || defined (__NetBSD__)
-#   include <sys/types.h>
-#else
-#   include <linux/types.h>
-#   include <linux/config.h>
-#   if defined(CONFIG_SMP) && ! defined(__SMP__)
-#      define __SMP__
-#   endif
-#   if defined(CONFIG_MODVERSIONS) && defined(MODULE) && ! defined(MOD=
VERSIONS)
-#      define MODVERSIONS
-#   endif
-#
-#   include <linux/version.h>
-#   ifdef MODULE
-#      ifdef MODVERSIONS
-#         if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#            include <linux/modversions.h>
-#         else
-#            include <config/modversions.h>
-#         endif
-#      endif
-#      include <linux/module.h>
-#   else
-#      define MOD_INC_USE_COUNT
-#      define MOD_DEC_USE_COUNT
-#      define SET_MODULE_OWNER(dev)
-#      define MODULE_DEVICE_TABLE(pci, pci_tbl)
-#   endif
-#endif
-
 /* reduce multiple autoconf entries to a single definition */
=20
 #ifdef CONFIG_SBE_PMCC4_HDLC_V7_MODULE
@@ -86,39 +36,22 @@
  * otherwise a memory barrier needs to be inserted.
  */
=20
-#if defined (__FreeBSD__) || defined (__NetBSD__)
-#else
-#define IO_CACHE_COHERENT      1
-#define MEM_CACHE_COHERENT     0
-#if IO_CACHE_COHERENT
-#define FLUSH_PCI_READ()
-#define FLUSH_PCI_WRITE()
-#else
 #define FLUSH_PCI_READ()     rmb()
 #define FLUSH_PCI_WRITE()    wmb()
-#endif
-#if MEM_CACHE_COHERENT
-#define FLUSH_MEM_READ()
-#define FLUSH_MEM_WRITE()
-#else
 #define FLUSH_MEM_READ()     rmb()
 #define FLUSH_MEM_WRITE()    wmb()
-#endif
-#endif
-
=20
 /*
  * System dependent callbacks routines, not inlined...
  * For inlined system dependent routines, see include/sbecom_inlinux_l=
inux.h
  */
-                                                                      =
         =20
+
 /*
  * passes received memory token back to the system, <user> is paramete=
r from
  * sd_new_chan() used to create the channel which the data arrived on
  */
=20
 void        sd_recv_consume (void *token, size_t len, void *user);
-
 void        sd_disable_xmit (void *user);
 void        sd_enable_xmit (void *user);
 int         sd_line_is_ok (void *user);
@@ -126,4 +59,4 @@ void        sd_line_is_up (void *user);
 void        sd_line_is_down (void *user);
 int         sd_queue_stopped (void *user);
=20
-#endif                          /*** _INC_PMCC4_SYSDEP_H_ ***/
+#endif
diff --git a/drivers/net/wan/cxt1e1/sbecom_inline_linux.h b/drivers/net=
/wan/cxt1e1/sbecom_inline_linux.h
index c1d8cba..d2a2b95 100644
--- a/drivers/net/wan/cxt1e1/sbecom_inline_linux.h
+++ b/drivers/net/wan/cxt1e1/sbecom_inline_linux.h
@@ -1,14 +1,7 @@
-/*
- * $Id: sbecom_inline_linux.h,v 1.2 2007/08/15 22:51:35 rickd PMCC4_3_=
1B $
- */
-
 #ifndef _INC_SBECOM_INLNX_H_
 #define _INC_SBECOM_INLNX_H_
=20
-/*--------------------------------------------------------------------=
---------
- * sbecom_inline_linux.h - SBE common Linux inlined routines
- *
- * Copyright (C) 2007  One Stop Systems, Inc.
+/* Copyright (C) 2007  One Stop Systems, Inc.
  * Copyright (C) 2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
@@ -20,57 +13,12 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@onestopsystems.=
com
- * One Stop Systems, Inc.  Escondido, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.2 $
- * Last changed on $Date: 2007/08/15 22:51:35 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: sbecom_inline_linux.h,v $
- * Revision 1.2  2007/08/15 22:51:35  rickd
- * Remove duplicate version.h entry.
- *
- * Revision 1.1  2007/08/15 22:50:29  rickd
- * Update linux/config for 2.6.18 and later.
- *
- * Revision 1.0  2005/09/28 00:10:09  rickd
- * Initial revision
- *
- *--------------------------------------------------------------------=
---------
  */
=20
=20
-#if defined (__FreeBSD__) || defined (__NetBSD__)
-#include <sys/types.h>
-#else
+#include <linux/kernel.h>       /* resolves kmalloc references */
 #include <linux/types.h>
 #include <linux/version.h>
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18)
-#include <linux/config.h>
-#endif
-#if defined(CONFIG_SMP) && ! defined(__SMP__)
-#define __SMP__
-#endif
-#if defined(CONFIG_MODVERSIONS) && defined(MODULE) && ! defined(MODVER=
SIONS)
-#define MODVERSIONS
-#endif
-
-#ifdef MODULE
-#ifdef MODVERSIONS
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-#include <linux/modversions.h>
-#else
-#include <config/modversions.h>
-#endif
-#endif
-#include <linux/module.h>
-#endif
-#endif
-
-#include <linux/kernel.h>       /* resolves kmalloc references */
 #include <linux/skbuff.h>       /* resolves skb references */
 #include <linux/netdevice.h>    /* resolves dev_kree_skb_any */
 #include <asm/byteorder.h>      /* resolves cpu_to_le32 */
@@ -260,13 +208,9 @@ OS_sem_free (void *sem)
 struct watchdog
 {
     struct timer_list h;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
-    struct tq_struct tq;
-#else
     struct work_struct work;
-#endif
     void       *softc;
-    void        (*func) (void *softc);
+    void        (*func)(struct work_struct *softc);
     int         ticks;
     int         init_tq;
 };
@@ -304,7 +248,8 @@ void        OS_uwait_dummy (void);
=20
=20
 /* watchdog functions */
-int         OS_init_watchdog (struct watchdog * wdp, void (*f) (void *=
), void *ci, int usec);
+int OS_init_watchdog (struct watchdog * wdp, void (*f) (struct work_st=
ruct *),
+		      void *ci, int usec);
=20
=20
 #endif                          /*** _INC_SBECOM_INLNX_H_ ***/
diff --git a/drivers/net/wan/cxt1e1/sbeid.c b/drivers/net/wan/cxt1e1/sb=
eid.c
index 37c7629..7a1c66a 100644
--- a/drivers/net/wan/cxt1e1/sbeid.c
+++ b/drivers/net/wan/cxt1e1/sbeid.c
@@ -1,11 +1,4 @@
-/*
- * $Id: sbeid.c,v 1.2 2005/10/13 19:13:23 rickd PMCC4_3_1B $
- */
-
-/*--------------------------------------------------------------------=
---------
- * sbeid.c - generic board identification routines
- *
- * Copyright (C) 2005  SBE, Inc.
+/* Copyright (C) 2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
  *   it under the terms of the GNU General Public License as published=
 by
@@ -16,36 +9,9 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.2 $
- * Last changed on $Date: 2005/10/13 19:13:23 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: sbeid.c,v $
- * Revision 1.2  2005/10/13 19:13:23  rickd
- * Fix PMCC4 enabling by correction of "ifdef" flag usage.
- *
- * Revision 1.1  2005/10/11 18:32:21  rickd
- * Maximum ports setting set elsewhere during module initialization.
- * C4T1E1 PCI BID appears to be global, now further parse this setting
- * and reassign number based upon number of found ports.
- *
- * Revision 1.0  2005/09/28 00:10:07  rickd
- * Initial revision
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-char        SBEid_sbeid[] =3D
-"@(#)sbeid.c - $Revision: 1.2 $      (c) Copyright 2005 SBE, Inc.";
-
-
 #include "pmcc4_sysdep.h"
-
 #include "sbecom_inline_linux.h"
 #include "libsbew.h"
 #include "pmcc4_private.h"
@@ -154,7 +120,6 @@ sbeid_set_hdwbid (ci_t * ci)
     case SBE_BOARD_ID (PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_WANPMC_C1T1E1_=
L):
         ci->hdw_bid =3D SBE_BID_PMC_C1T1E1;       /* 0xC1 - SBE wanPMC=
-C1T1E1 */
         break;
-#ifdef SBE_PMCC4_ENABLE
         /*
          * This case is entered as a result of the inability to obtain=
 the
          * <bid> from the board's EEPROM.  Assume a PCI board and set
@@ -164,7 +129,6 @@ sbeid_set_hdwbid (ci_t * ci)
         /* start by assuming 4-port for ZERO casing */
         ci->brd_id =3D SBE_BOARD_ID (PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_=
WANPCI_C4T1E1);
         /* drop thru to set hdw_bid and alternate PCI CxT1E1 settings =
*/
-#endif
     case SBE_BOARD_ID (PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_WANPCI_C4T1E1)=
:
         /*
          * This Board ID is a generic identification.  Use the number =
of
diff --git a/drivers/net/wan/cxt1e1/sbeproc.c b/drivers/net/wan/cxt1e1/=
sbeproc.c
index d9ccb19..c435639 100644
--- a/drivers/net/wan/cxt1e1/sbeproc.c
+++ b/drivers/net/wan/cxt1e1/sbeproc.c
@@ -1,11 +1,4 @@
-/*
- * $Id: sbeproc.c,v 1.5 2005/10/31 20:26:37 rickd PMCC4_3_1B $
- */
-
-/*--------------------------------------------------------------------=
---------
- * sbeproc.c -
- *
- * Copyright (C) 2004-2005  SBE, Inc.
+/* Copyright (C) 2004-2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
  *   it under the terms of the GNU General Public License as published=
 by
@@ -16,50 +9,8 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.5 $
- * Last changed on $Date: 2005/10/31 20:26:37 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: sbeproc.c,v $
- * Revision 1.5  2005/10/31 20:26:37  rickd
- * Fix for compilation warning re: declaration w/in ...get_sge_info().
- *
- * Revision 1.4  2005/10/27 18:54:19  rickd
- * Display driver tuning variable settings.
- *
- * Revision 1.3  2005/10/11 18:31:22  rickd
- * Add number of physical ports to displayed board info.
- *
- * Revision 1.2  2005/09/28 00:10:07  rickd
- * Add EEPROM Type 2 info.  Switch from os_ to OS_ named functions.
- *
- * Revision 1.3  2005/06/06 23:47:51  rickd
- * OS support routine names changed from sd_ to OS_.  Implement
- * in-line OS function support via inclusion of sbecom_inline_linux.h
- *
- * Revision 1.2  2005/04/18 21:23:20  rickd
- * Make directory within /proc/driver using proc_root_driver because
- * trying w/in /proc failed for multiple cards/drivers.
- *
- * Revision 1.1  2005/04/01 00:17:52  rickd
- * Use alternate proc_mkdir() to create driver/board directory.
- *
- * Revision 1.0  2004/12/03 23:32:07  rickd
- * Initial CI.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
-
-char        SBEid_sbeproc_c[] =3D
-"@(#)sbeproc.c        $Revision: 1.5 $      (c) Copyright 2004-2005 SB=
E, Inc.";
-
-
 #include "pmcc4_sysdep.h"
 #include <linux/types.h>
 #include <linux/module.h>
@@ -73,8 +24,7 @@ char        SBEid_sbeproc_c[] =3D
 #include "pmcc4_private.h"
 #include "sbeproc.h"
=20
-/* forwards */
-void        sbecom_get_brdinfo (ci_t *, struct sbe_brd_info *, u_int8_=
t *);
+void sbecom_get_brdinfo (ci_t *, struct sbe_brd_info *, u_int8_t *);
 extern struct s_hdw_info hdw_info[MAX_BOARDS];
=20
 #ifdef CONFIG_PROC_FS
@@ -83,14 +33,15 @@ extern struct s_hdw_info hdw_info[MAX_BOARDS];
 /* procfs stuff                                                     */
 /********************************************************************/
=20
-
 void
 sbecom_proc_brd_cleanup (ci_t * ci)
 {
     if (ci->dir_dev)
     {
+	char dir[7 + SBE_IFACETMPL_SIZE + 1];
+	snprintf(dir, sizeof(dir), "driver/%s", ci->devname);
         remove_proc_entry ("info", ci->dir_dev);
-        remove_proc_entry (ci->devname, proc_root_driver);
+        remove_proc_entry (dir, NULL);
         ci->dir_dev =3D NULL;
     }
 }
@@ -214,9 +165,7 @@ sbecom_proc_get_sbe_info (char *buffer, char **star=
t, off_t offset,
     }
     len +=3D sprintf (buffer + len, "PCI Bus Speed: %s\n", spd);
     len +=3D sprintf (buffer + len, "Release:       %s\n", ci->release=
);
-    len +=3D sprintf (buffer + len, "Module Name:   %s\n", ci->dir_dev=
->owner->name);
=20
-#ifdef SBE_PMCC4_ENABLE
     {
         extern int max_mru;
 #if 0
@@ -224,7 +173,7 @@ sbecom_proc_get_sbe_info (char *buffer, char **star=
t, off_t offset,
         extern int max_mtu;
 #endif
         extern int max_rxdesc_used, max_txdesc_used;
-                                                                      =
                                 =20
+
         len +=3D sprintf (buffer + len, "\nmax_mru:         %d\n", max=
_mru);
 #if 0
         len +=3D sprintf (buffer + len, "\nmax_chans_used:  %d\n", max=
_chans_used);
@@ -233,7 +182,6 @@ sbecom_proc_get_sbe_info (char *buffer, char **star=
t, off_t offset,
         len +=3D sprintf (buffer + len, "max_rxdesc_used: %d\n", max_r=
xdesc_used);
         len +=3D sprintf (buffer + len, "max_txdesc_used: %d\n", max_t=
xdesc_used);
     }
-#endif
=20
     OS_kfree (bip);                 /* cleanup */
=20
@@ -359,16 +307,17 @@ int         __init
 sbecom_proc_brd_init (ci_t * ci)
 {
     struct proc_dir_entry *e;
+    char dir[7 + SBE_IFACETMPL_SIZE + 1];
=20
     /* create a directory in the root procfs */
-    ci->dir_dev =3D proc_mkdir (ci->devname, proc_root_driver);
+    snprintf(dir, sizeof(dir), "driver/%s", ci->devname);
+    ci->dir_dev =3D proc_mkdir(dir, NULL);
     if (!ci->dir_dev)
     {
         printk (KERN_ERR "%s: Unable to create directory /proc/driver/=
%s\n",
                 THIS_MODULE->name, ci->devname);
         goto fail;
     }
-    ci->dir_dev->owner =3D THIS_MODULE;
     e =3D create_proc_read_entry ("info", S_IFREG | S_IRUGO,
                                 ci->dir_dev, sbecom_proc_get_sbe_info,=
 ci);
     if (!e)
@@ -377,7 +326,6 @@ sbecom_proc_brd_init (ci_t * ci)
                 THIS_MODULE->name, ci->devname);
         goto fail;
     }
-    e->owner =3D THIS_MODULE;
     return 0;
=20
 fail:
diff --git a/drivers/net/wan/cxt1e1/sbeproc.h b/drivers/net/wan/cxt1e1/=
sbeproc.h
index 4aa53f4..f8025f7 100644
--- a/drivers/net/wan/cxt1e1/sbeproc.h
+++ b/drivers/net/wan/cxt1e1/sbeproc.h
@@ -1,14 +1,7 @@
-/*
- * $Id: sbeproc.h,v 1.2 2005/10/17 23:55:28 rickd PMCC4_3_1B $
- */
-
 #ifndef _INC_SBEPROC_H_
 #define _INC_SBEPROC_H_
=20
-/*--------------------------------------------------------------------=
---------
- * sbeproc.h -
- *
- * Copyright (C) 2004-2005  SBE, Inc.
+/* Copyright (C) 2004-2005  SBE, Inc.
  *
  *   This program is free software; you can redistribute it and/or mod=
ify
  *   it under the terms of the GNU General Public License as published=
 by
@@ -19,34 +12,14 @@
  *   but WITHOUT ANY WARRANTY; without even the implied warranty of
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
- *
- * For further information, contact via email: support@sbei.com
- * SBE, Inc.  San Ramon, California  U.S.A.
- *--------------------------------------------------------------------=
---------
- * RCS info:
- * RCS revision: $Revision: 1.2 $
- * Last changed on $Date: 2005/10/17 23:55:28 $
- * Changed by $Author: rickd $
- *--------------------------------------------------------------------=
---------
- * $Log: sbeproc.h,v $
- * Revision 1.2  2005/10/17 23:55:28  rickd
- * sbecom_proc_brd_init() is an declared an __init function.
- *
- * Revision 1.1  2005/09/28 00:10:09  rickd
- * Remove unneeded inclusion of c4_private.h.
- *
- * Revision 1.0  2005/05/10 22:21:46  rickd
- * Initial check-in.
- *
- *--------------------------------------------------------------------=
---------
  */
=20
=20
 #ifdef CONFIG_PROC_FS
 #ifdef __KERNEL__
-void        sbecom_proc_brd_cleanup (ci_t *);
-int __init  sbecom_proc_brd_init (ci_t *);
+void sbecom_proc_brd_cleanup(ci_t *);
+int __init sbecom_proc_brd_init(ci_t *);
=20
-#endif                          /*** __KERNEL__ ***/
-#endif                          /*** CONFIG_PROC_FS ***/
-#endif                          /*** _INC_SBEPROC_H_ ***/
+#endif
+#endif
+#endif

--=20
Krzysztof Halasa
