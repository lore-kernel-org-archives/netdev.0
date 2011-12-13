From: Thomas Sailer <sailer@sailer.dynip.lugs.ch>
Subject: Re: bayom_epp patch
Date: Tue, 13 Dec 2011 19:50:08 +0100
Message-ID: <1323802208.12740.5.camel@xbox360.hq.axsem.com>
References: <1323777960.12740.2.camel@xbox360.hq.axsem.com>
	 <4EE748BA.5080807@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fep22.mx.upcmail.net ([62.179.121.42]:57517 "EHLO
	fep22.mx.upcmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab1LMSwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:52:42 -0500
Received: from edge04.upcmail.net ([192.168.13.239])
          by viefep13-int.chello.at
          (InterMail vM.8.01.05.04 201-2260-151-105-20111014) with ESMTP
          id <20111213185022.HCYM19694.viefep13-int.chello.at@edge04.upcmail.net>
          for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 19:50:22 +0100
Received: from [192.168.1.220] (245-28.202-62.fix.bluewin.ch [62.202.28.245])
	(authenticated bits=0)
	by xbox.hb9jnx.ampr.org (8.14.5/8.14.5) with ESMTP id pBDIo99l012292
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 19:50:11 +0100
In-Reply-To: <4EE748BA.5080807@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

baycom_epp: Improve parport handling, fix multi-core support

Parallel port settings no longer require an IO address value,
because addresses are automatically assigned by the PCI BIOS
nowadays and may change rather frequently.
Instead, the parport number is used (e.g. modprobe baycom_epp parport=0)

EPP transfers now utilize block IO transfers, thus significantly
reducing CPU load. Furthermore, EPP RX data transfer handling of the
conventional EPP modem (without FPGA) has been improved to assure
a minimum block transfer size increasing the effective data rate.

Spin-locks have been introduced for better multi-core compatibility.
The x86_64 exclusion has been removed from Kconfig because no problems
where observed on several test systems. To achieve this, several x86
architecture specific debug statements had to be removed.

Signed-off-by: Thomas Sailer <sailer@ife.ee.ethz.ch>
Signed-off-by: Steffen Koehler <steffen.koehler@tu-dresden.de>

diff --git a/drivers/net/hamradio/Kconfig b/drivers/net/hamradio/Kconfig
index 95dbcfd..9a736f0 100644
--- a/drivers/net/hamradio/Kconfig
+++ b/drivers/net/hamradio/Kconfig
@@ -166,7 +166,7 @@ config BAYCOM_PAR
 
 config BAYCOM_EPP
 	tristate "BAYCOM epp driver for AX.25"
-	depends on PARPORT && AX25 && !64BIT
+	depends on PARPORT && AX25
 	select CRC_CCITT
 	---help---
 	  This is a driver for Baycom style simple amateur radio modems that
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 9537aaa..6e1019b 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -3,8 +3,9 @@
 /*
  *	baycom_epp.c  -- baycom epp radio modem driver.
  *
- *	Copyright (C) 1998-2000
+ *	Copyright (C) 1998-2000, 2010
  *          Thomas Sailer (sailer@ife.ee.ethz.ch)
+ *          Steffen Koehler (steffen.koehler@tu-dresden.de)
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License as published by
@@ -33,8 +34,12 @@
  *   0.4  26.07.1999  Adapted to new lowlevel parport driver interface
  *   0.5  03.08.1999  adapt to Linus' new __setup/__initcall
  *                    removed some pre-2.2 kernel compatibility cruft
- *   0.6  10.08.1999  Check if parport can do SPP and is safe to access during interrupt contexts
+ *   0.6  10.08.1999  Check if parport can do SPP and is safe to access during
+ *                    interrupt contexts
  *   0.7  12.02.2000  adapted to softnet driver interface
+ *   0.8  12.01.2010  added spinlocks for multi-cpu safety, changed interface
+ *                    enumeration according to the parport number, some minor
+ *                    bug fixes
  *
  */
 
@@ -59,7 +64,6 @@
 
 /* --------------------------------------------------------------------- */
 
-#define BAYCOM_DEBUG
 #define BAYCOM_MAGIC 19730510
 
 /* --------------------------------------------------------------------- */
@@ -68,8 +72,8 @@ static const char paranoia_str[] = KERN_ERR
 	"baycom_epp: bad magic number for hdlcdrv_state struct in routine %s\n";
 
 static const char bc_drvname[] = "baycom_epp";
-static const char bc_drvinfo[] = KERN_INFO "baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA\n"
-"baycom_epp: version 0.7\n";
+static const char bc_drvinfo[] = KERN_INFO "baycom_epp: (C) 1998-2010 Thomas Sailer, HB9JNX/AE4WA\n"
+"baycom_epp: version 0.8\n";
 
 /* --------------------------------------------------------------------- */
 
@@ -94,72 +98,13 @@ static struct net_device *baycom_device[NR_PORTS];
 #define EPP_RX_FIFO_ENABLE 0x08
 #define EPP_MODEM_ENABLE   0x20
 #define EPP_LEDS           0xC0
-#define EPP_IRQ_ENABLE     0x10
-
-/* LPT registers */
-#define LPTREG_ECONTROL       0x402
-#define LPTREG_CONFIGB        0x401
-#define LPTREG_CONFIGA        0x400
-#define LPTREG_EPPDATA        0x004
-#define LPTREG_EPPADDR        0x003
-#define LPTREG_CONTROL        0x002
-#define LPTREG_STATUS         0x001
-#define LPTREG_DATA           0x000
-
-/* LPT control register */
-#define LPTCTRL_PROGRAM       0x04   /* 0 to reprogram */
-#define LPTCTRL_WRITE         0x01
-#define LPTCTRL_ADDRSTB       0x08
-#define LPTCTRL_DATASTB       0x02
-#define LPTCTRL_INTEN         0x10
-
-/* LPT status register */
-#define LPTSTAT_SHIFT_NINTR   6
-#define LPTSTAT_WAIT          0x80
-#define LPTSTAT_NINTR         (1<<LPTSTAT_SHIFT_NINTR)
-#define LPTSTAT_PE            0x20
-#define LPTSTAT_DONE          0x10
-#define LPTSTAT_NERROR        0x08
-#define LPTSTAT_EPPTIMEOUT    0x01
-
-/* LPT data register */
-#define LPTDATA_SHIFT_TDI     0
-#define LPTDATA_SHIFT_TMS     2
-#define LPTDATA_TDI           (1<<LPTDATA_SHIFT_TDI)
-#define LPTDATA_TCK           0x02
-#define LPTDATA_TMS           (1<<LPTDATA_SHIFT_TMS)
-#define LPTDATA_INITBIAS      0x80
-
-
-/* EPP modem config/status bits */
-#define EPP_DCDBIT            0x80
-#define EPP_PTTBIT            0x08
-#define EPP_RXEBIT            0x01
-#define EPP_RXAEBIT           0x02
-#define EPP_RXHFULL           0x04
-
-#define EPP_NTHF              0x20
-#define EPP_NTAEF             0x10
-#define EPP_NTEF              EPP_PTTBIT
-
-#define EPP_TX_FIFO_ENABLE    0x10
-#define EPP_RX_FIFO_ENABLE    0x08
-#define EPP_MODEM_ENABLE      0x20
-#define EPP_LEDS              0xC0
-#define EPP_IRQ_ENABLE        0x10
-
-/* Xilinx 4k JTAG instructions */
-#define XC4K_IRLENGTH   3
-#define XC4K_EXTEST     0
-#define XC4K_PRELOAD    1
-#define XC4K_CONFIGURE  5
-#define XC4K_BYPASS     7
 
 #define EPP_CONVENTIONAL  0
 #define EPP_FPGA          1
-#define EPP_FPGAEXTSTATUS 2
 
-#define TXBUFFER_SIZE     ((HDLCDRV_MAXFLEN*6/5)+8)
+#define EPP_XFER_FLAGS	PARPORT_EPP_FAST
+
+#define TXBUFFER_SIZE	((HDLCDRV_MAXFLEN*6/5)+8)
 
 /* ---------------------------------------------------------------------- */
 /*
@@ -171,7 +116,6 @@ struct baycom_state {
 
         struct pardevice *pdev;
 	struct net_device *dev;
-	unsigned int work_running;
 	struct delayed_work run_work;
 	unsigned int modem;
 	unsigned int bitrate;
@@ -186,6 +130,7 @@ struct baycom_state {
 	} cfg;
 
         struct hdlcdrv_channel_params ch_params;
+	enum { rx_idle = 0, rx_receive, rx_flush } rx_state;
 
         struct {
 		unsigned int bitbuf, bitstream, numbits, state;
@@ -206,18 +151,7 @@ struct baycom_state {
 
 	unsigned int ptt_keyed;
 	struct sk_buff *skb;  /* next transmit packet  */
-
-#ifdef BAYCOM_DEBUG
-	struct debug_vals {
-		unsigned long last_jiffies;
-		unsigned cur_intcnt;
-		unsigned last_intcnt;
-		int cur_pllcorr;
-		int last_pllcorr;
-		unsigned int mod_cycles;
-		unsigned int demod_cycles;
-	} debug_vals;
-#endif /* BAYCOM_DEBUG */
+	spinlock_t lock;
 };
 
 /* --------------------------------------------------------------------- */
@@ -243,21 +177,6 @@ struct baycom_state {
 
 /*---------------------------------------------------------------------------*/
 
-#if 0
-static inline void append_crc_ccitt(unsigned char *buffer, int len)
-{
- 	unsigned int crc = 0xffff;
-
-	for (;len>0;len--)
-		crc = (crc >> 8) ^ crc_ccitt_table[(crc ^ *buffer++) & 0xff];
-	crc ^= 0xffff;
-	*buffer++ = crc;
-	*buffer++ = crc >> 8;
-}
-#endif
-
-/*---------------------------------------------------------------------------*/
-
 static inline int check_crc_ccitt(const unsigned char *buf, int cnt)
 {
 	return (crc_ccitt(0xffff, buf, cnt) & 0xffff) == 0xf0b8;
@@ -274,26 +193,6 @@ static inline int calc_crc_ccitt(const unsigned char *buf, int cnt)
 
 #define tenms_to_flags(bc,tenms) ((tenms * bc->bitrate) / 800)
 
-/* --------------------------------------------------------------------- */
-
-static inline void baycom_int_freq(struct baycom_state *bc)
-{
-#ifdef BAYCOM_DEBUG
-	unsigned long cur_jiffies = jiffies;
-	/*
-	 * measure the interrupt frequency
-	 */
-	bc->debug_vals.cur_intcnt++;
-	if (time_after_eq(cur_jiffies, bc->debug_vals.last_jiffies + HZ)) {
-		bc->debug_vals.last_jiffies = cur_jiffies;
-		bc->debug_vals.last_intcnt = bc->debug_vals.cur_intcnt;
-		bc->debug_vals.cur_intcnt = 0;
-		bc->debug_vals.last_pllcorr = bc->debug_vals.cur_pllcorr;
-		bc->debug_vals.cur_pllcorr = 0;
-	}
-#endif /* BAYCOM_DEBUG */
-}
-
 /* ---------------------------------------------------------------------- */
 /*
  *    eppconfig_path should be setable  via /proc/sys.
@@ -337,6 +236,7 @@ static inline void do_kiss_params(struct baycom_state *bc,
 
 	if (len < 2)
 		return;
+	spin_lock_bh(&bc->lock);
 	switch(data[0]) {
 	case PARAM_TXDELAY:
 		bc->ch_params.tx_delay = data[1];
@@ -361,6 +261,7 @@ static inline void do_kiss_params(struct baycom_state *bc,
 	default:
 		break;
 	}
+	spin_unlock_bh(&bc->lock);
 #undef PKP
 }
 
@@ -442,7 +343,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 		if (bc->hdlctx.bufcnt <= 0)
 			return 0;
 		if (!bc->ch_params.fulldup) {
-			if (!(stat & EPP_DCDBIT)) {
+			if (!(stat & EPP_DCDBIT) || (bc->rx_state != rx_idle)) {
 				bc->hdlctx.slotcnt = bc->ch_params.slottime;
 				return 0;
 			}
@@ -469,7 +370,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			memset(tmp, 0x7e, sizeof(tmp));
 			while (i > 0) {
 				j = (i > sizeof(tmp)) ? sizeof(tmp) : i;
-				if (j != pp->ops->epp_write_data(pp, tmp, j, 0))
+				if (j != pp->ops->epp_write_data(pp, tmp, j, EPP_XFER_FLAGS))
 					return -1;
 				i -= j;
 			}
@@ -487,7 +388,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			i = min_t(int, cnt, bc->hdlctx.bufcnt);
 			bc->hdlctx.bufcnt -= i;
 			cnt -= i;
-			if (i != pp->ops->epp_write_data(pp, bc->hdlctx.bufptr, i, 0))
+			if (i != pp->ops->epp_write_data(pp, bc->hdlctx.bufptr, i, EPP_XFER_FLAGS))
 					return -1;
 			bc->hdlctx.bufptr += i;
 			break;
@@ -505,7 +406,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 				memset(tmp, 0x7e, sizeof(tmp));
 				while (i > 0) {
 					j = (i > sizeof(tmp)) ? sizeof(tmp) : i;
-					if (j != pp->ops->epp_write_data(pp, tmp, j, 0))
+					if (j != pp->ops->epp_write_data(pp, tmp, j, EPP_XFER_FLAGS))
 						return -1;
 					i -= j;
 				}
@@ -521,7 +422,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			memset(tmp, 0, sizeof(tmp));
 			while (i > 0) {
 				j = (i > sizeof(tmp)) ? sizeof(tmp) : i;
-				if (j != pp->ops->epp_write_data(pp, tmp, j, 0))
+				if (j != pp->ops->epp_write_data(pp, tmp, j, EPP_XFER_FLAGS))
 					return -1;
 				i -= j;
 			}
@@ -575,7 +476,7 @@ static int receive(struct net_device *dev, int cnt)
 	while (cnt > 0) {
 		cnt2 = (cnt > sizeof(tmp)) ? sizeof(tmp) : cnt;
 		cnt -= cnt2;
-		if (cnt2 != pp->ops->epp_read_data(pp, tmp, cnt2, 0)) {
+		if (cnt2 != pp->ops->epp_read_data(pp, tmp, cnt2, EPP_XFER_FLAGS)) {
 			ret = -1;
 			break;
 		}
@@ -633,17 +534,6 @@ static int receive(struct net_device *dev, int cnt)
 
 /* --------------------------------------------------------------------- */
 
-#ifdef __i386__
-#include <asm/msr.h>
-#define GETTICK(x)                                                \
-({                                                                \
-	if (cpu_has_tsc)                                          \
-		rdtscl(x);                                        \
-})
-#else /* __i386__ */
-#define GETTICK(x)
-#endif /* __i386__ */
-
 static void epp_bh(struct work_struct *work)
 {
 	struct net_device *dev;
@@ -651,22 +541,17 @@ static void epp_bh(struct work_struct *work)
 	struct parport *pp;
 	unsigned char stat;
 	unsigned char tmp[2];
-	unsigned int time1 = 0, time2 = 0, time3 = 0;
 	int cnt, cnt2;
 
 	bc = container_of(work, struct baycom_state, run_work.work);
+	spin_lock_bh(&bc->lock);
 	dev = bc->dev;
-	if (!bc->work_running)
-		return;
-	baycom_int_freq(bc);
 	pp = bc->pdev->port;
 	/* update status */
 	if (pp->ops->epp_read_addr(pp, &stat, 1, 0) != 1)
 		goto epptimeout;
 	bc->stat = stat;
-	bc->debug_vals.last_pllcorr = stat;
-	GETTICK(time1);
-	if (bc->modem == EPP_FPGAEXTSTATUS) {
+	if (bc->modem == EPP_FPGA) {
 		/* get input count */
 		tmp[0] = EPP_TX_FIFO_ENABLE|EPP_RX_FIFO_ENABLE|EPP_MODEM_ENABLE|1;
 		if (pp->ops->epp_write_addr(pp, tmp, 1, 0) != 1)
@@ -689,36 +574,52 @@ static void epp_bh(struct work_struct *work)
 			goto epptimeout;
 		if (transmit(bc, cnt2, stat))
 			goto epptimeout;
-		GETTICK(time2);
 		if (receive(dev, cnt))
 			goto epptimeout;
-		if (pp->ops->epp_read_addr(pp, &stat, 1, 0) != 1)
-			goto epptimeout;
-		bc->stat = stat;
 	} else {
-		/* try to tx */
+		/* try to TX */
 		switch (stat & (EPP_NTAEF|EPP_NTHF)) {
 		case EPP_NTHF:
 			cnt = 2048 - 256;
 			break;
-		
+
 		case EPP_NTAEF:
 			cnt = 2048 - 1793;
 			break;
-		
+
 		case 0:
 			cnt = 0;
 			break;
-		
+
 		default:
 			cnt = 2048 - 1025;
 			break;
 		}
 		if (transmit(bc, cnt, stat))
 			goto epptimeout;
-		GETTICK(time2);
 		/* do receiver */
 		while ((stat & (EPP_NRAEF|EPP_NRHF)) != EPP_NRHF) {
+			/* FIFO fill state accuracy work-around: */
+			/* When the channel is free, we further read */
+			/* one block to assure that the last frame has */
+			/* been completely flushed before we tell the */
+			/* TX that the channel is free */
+			if (stat & EPP_DCDBIT) {
+				switch (bc->rx_state) {
+				case rx_receive:
+					bc->rx_state = rx_flush;
+					break;
+
+				case rx_flush:
+					bc->rx_state = rx_idle;
+					break;
+
+				case rx_idle:
+					break;
+				}
+			} else
+				bc->rx_state = rx_receive;
+			/* guess RX block size */
 			switch (stat & (EPP_NRAEF|EPP_NRHF)) {
 			case EPP_NRAEF:
 				cnt = 1025;
@@ -737,29 +638,15 @@ static void epp_bh(struct work_struct *work)
 			if (pp->ops->epp_read_addr(pp, &stat, 1, 0) != 1)
 				goto epptimeout;
 		}
-		cnt = 0;
-		if (bc->bitrate < 50000)
-			cnt = 256;
-		else if (bc->bitrate < 100000)
-			cnt = 128;
-		while (cnt > 0 && stat & EPP_NREF) {
-			if (receive(dev, 1))
-				goto epptimeout;
-			cnt--;
-			if (pp->ops->epp_read_addr(pp, &stat, 1, 0) != 1)
-				goto epptimeout;
-		}
 	}
-	GETTICK(time3);
-#ifdef BAYCOM_DEBUG
-	bc->debug_vals.mod_cycles = time2 - time1;
-	bc->debug_vals.demod_cycles = time3 - time2;
-#endif /* BAYCOM_DEBUG */
-	schedule_delayed_work(&bc->run_work, 1);
 	if (!bc->skb)
 		netif_wake_queue(dev);
+	schedule_delayed_work(&bc->run_work, 1);
+	spin_unlock_bh(&bc->lock);
 	return;
+
  epptimeout:
+ 	spin_unlock_bh(&bc->lock);
 	printk(KERN_ERR "%s: EPP timeout!\n", bc_drvname);
 }
 
@@ -777,15 +664,19 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+	
 	if (bc->skb)
 		return NETDEV_TX_LOCKED;
+		
 	/* strip KISS byte */
 	if (skb->len >= HDLCDRV_MAXFLEN+1 || skb->len < 3) {
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+	spin_lock_bh(&bc->lock);
 	netif_stop_queue(dev);
 	bc->skb = skb;
+	spin_unlock_bh(&bc->lock);
 	return NETDEV_TX_OK;
 }
 
@@ -836,20 +727,12 @@ static int epp_open(struct net_device *dev)
                 printk(KERN_ERR "%s: parport at 0x%lx unknown\n", bc_drvname, dev->base_addr);
                 return -ENXIO;
         }
-#if 0
-        if (pp->irq < 0) {
-                printk(KERN_ERR "%s: parport at 0x%lx has no irq\n", bc_drvname, pp->base);
-		parport_put_port(pp);
-                return -ENXIO;
-        }
-#endif
 	if ((~pp->modes) & (PARPORT_MODE_TRISTATE | PARPORT_MODE_PCSPP | PARPORT_MODE_SAFEININT)) {
                 printk(KERN_ERR "%s: parport at 0x%lx cannot be used\n",
 		       bc_drvname, pp->base);
 		parport_put_port(pp);
                 return -EIO;
 	}
-	memset(&bc->modem, 0, sizeof(bc->modem));
         bc->pdev = parport_register_device(pp, dev->name, NULL, epp_wakeup, 
 					   NULL, PARPORT_DEV_EXCL, dev);
 	parport_put_port(pp);
@@ -862,15 +745,13 @@ static int epp_open(struct net_device *dev)
                 parport_unregister_device(bc->pdev);
                 return -EBUSY;
         }
-        dev->irq = /*pp->irq*/ 0;
-	INIT_DELAYED_WORK(&bc->run_work, epp_bh);
-	bc->work_running = 1;
 	bc->modem = EPP_CONVENTIONAL;
 	if (eppconfig(bc))
 		printk(KERN_INFO "%s: no FPGA detected, assuming conventional EPP modem\n", bc_drvname);
 	else
-		bc->modem = /*EPP_FPGA*/ EPP_FPGAEXTSTATUS;
-	parport_write_control(pp, LPTCTRL_PROGRAM); /* prepare EPP mode; we aren't using interrupts */
+		bc->modem = EPP_FPGA;
+	/* prepare EPP mode; we aren't using interrupts */		
+	parport_write_control(pp, PARPORT_CONTROL_INIT);
 	/* reset the modem */
 	tmp[0] = 0;
 	tmp[1] = EPP_TX_FIFO_ENABLE|EPP_RX_FIFO_ENABLE|EPP_MODEM_ENABLE;
@@ -886,9 +767,9 @@ static int epp_open(struct net_device *dev)
 			schedule();
 			continue;
 		}
-		if (pp->ops->epp_read_data(pp, tmp, 128, 0) != 128)
+		if (pp->ops->epp_read_data(pp, tmp, 128, EPP_XFER_FLAGS) != 128)
 			goto epptimeout;
-		if (pp->ops->epp_read_data(pp, tmp, 128, 0) != 128)
+		if (pp->ops->epp_read_data(pp, tmp, 128, EPP_XFER_FLAGS) != 128)
 			goto epptimeout;
 		i += 256;
 	}
@@ -914,9 +795,9 @@ static int epp_open(struct net_device *dev)
 	tmp[0] = EPP_TX_FIFO_ENABLE|EPP_RX_FIFO_ENABLE|EPP_MODEM_ENABLE/*|j*/;
 	if (pp->ops->epp_write_addr(pp, tmp, 1, 0) != 1)
 		goto epptimeout;
-	/*
-	 * initialise hdlc variables
-	 */
+        /* reset RX buffer handling */
+        bc->rx_state = rx_idle;
+	/* initialise hdlc variables */
 	bc->hdlcrx.state = 0;
 	bc->hdlcrx.numbits = 0;
 	bc->hdlctx.state = tx_idle;
@@ -924,8 +805,9 @@ static int epp_open(struct net_device *dev)
 	bc->hdlctx.slotcnt = bc->ch_params.slottime;
 	bc->hdlctx.calibrate = 0;
 	/* start the bottom half stuff */
-	schedule_delayed_work(&bc->run_work, 1);
 	netif_start_queue(dev);
+	INIT_DELAYED_WORK(&bc->run_work, epp_bh);
+	schedule_delayed_work(&bc->run_work, 1);
 	return 0;
 
  epptimeout:
@@ -944,19 +826,20 @@ static int epp_close(struct net_device *dev)
 	struct parport *pp = bc->pdev->port;
 	unsigned char tmp[1];
 
-	bc->work_running = 0;
+	spin_lock_bh(&bc->lock);
 	cancel_delayed_work_sync(&bc->run_work);
+	if (bc->skb)
+		dev_kfree_skb(bc->skb);
+	bc->skb = NULL;
 	bc->stat = EPP_DCDBIT;
+	spin_unlock_bh(&bc->lock);	
 	tmp[0] = 0;
 	pp->ops->epp_write_addr(pp, tmp, 1, 0);
 	parport_write_control(pp, 0); /* reset the adapter */
         parport_release(bc->pdev);
         parport_unregister_device(bc->pdev);
-	if (bc->skb)
-		dev_kfree_skb(bc->skb);
-	bc->skb = NULL;
-	printk(KERN_INFO "%s: close epp at iobase 0x%lx irq %u\n",
-	       bc_drvname, dev->base_addr, dev->irq);
+	printk(KERN_INFO "%s: close parport at 0x%lx\n",
+	       bc_drvname, dev->base_addr);
 	return 0;
 }
 
@@ -966,6 +849,7 @@ static int baycom_setmode(struct baycom_state *bc, const char *modestr)
 {
 	const char *cp;
 
+	spin_lock_bh(&bc->lock);
 	if (strstr(modestr,"intclk"))
 		bc->cfg.intclk = 1;
 	if (strstr(modestr,"extclk"))
@@ -992,6 +876,7 @@ static int baycom_setmode(struct baycom_state *bc, const char *modestr)
 		if (bc->cfg.bps > 1500000)
 			bc->cfg.bps = 1500000;
 	}
+	spin_unlock_bh(&bc->lock);
 	return 0;
 }
 
@@ -1012,28 +897,32 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		return -ENOIOCTLCMD;
 
 	case HDLCDRVCTL_GETCHANNELPAR:
+		spin_lock_bh(&bc->lock);
 		hi.data.cp.tx_delay = bc->ch_params.tx_delay;
 		hi.data.cp.tx_tail = bc->ch_params.tx_tail;
 		hi.data.cp.slottime = bc->ch_params.slottime;
 		hi.data.cp.ppersist = bc->ch_params.ppersist;
 		hi.data.cp.fulldup = bc->ch_params.fulldup;
+		spin_unlock_bh(&bc->lock);
 		break;
 
 	case HDLCDRVCTL_SETCHANNELPAR:
 		if (!capable(CAP_NET_ADMIN))
 			return -EACCES;
+		spin_lock_bh(&bc->lock);
 		bc->ch_params.tx_delay = hi.data.cp.tx_delay;
 		bc->ch_params.tx_tail = hi.data.cp.tx_tail;
 		bc->ch_params.slottime = hi.data.cp.slottime;
 		bc->ch_params.ppersist = hi.data.cp.ppersist;
 		bc->ch_params.fulldup = hi.data.cp.fulldup;
 		bc->hdlctx.slotcnt = 1;
+		spin_unlock_bh(&bc->lock);
 		return 0;
 		
 	case HDLCDRVCTL_GETMODEMPAR:
 		hi.data.mp.iobase = dev->base_addr;
-		hi.data.mp.irq = dev->irq;
-		hi.data.mp.dma = dev->dma;
+		hi.data.mp.irq = 0;
+		hi.data.mp.dma = 0;
 		hi.data.mp.dma2 = 0;
 		hi.data.mp.seriobase = 0;
 		hi.data.mp.pariobase = 0;
@@ -1041,14 +930,12 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 
 	case HDLCDRVCTL_SETMODEMPAR:
-		if ((!capable(CAP_SYS_RAWIO)) || netif_running(dev))
+		if (!capable(CAP_SYS_RAWIO))
 			return -EACCES;
-		dev->base_addr = hi.data.mp.iobase;
-		dev->irq = /*hi.data.mp.irq*/0;
-		dev->dma = /*hi.data.mp.dma*/0;
 		return 0;	
 		
 	case HDLCDRVCTL_GETSTAT:
+		spin_lock_bh(&bc->lock);
 		hi.data.cs.ptt = !!(bc->stat & EPP_PTTBIT);
 		hi.data.cs.dcd = !(bc->stat & EPP_DCDBIT);
 		hi.data.cs.ptt_keyed = bc->ptt_keyed;
@@ -1056,18 +943,23 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		hi.data.cs.tx_errors = dev->stats.tx_errors;
 		hi.data.cs.rx_packets = dev->stats.rx_packets;
 		hi.data.cs.rx_errors = dev->stats.rx_errors;
+		spin_unlock_bh(&bc->lock);
 		break;		
 
 	case HDLCDRVCTL_OLDGETSTAT:
+		spin_lock_bh(&bc->lock);
 		hi.data.ocs.ptt = !!(bc->stat & EPP_PTTBIT);
 		hi.data.ocs.dcd = !(bc->stat & EPP_DCDBIT);
 		hi.data.ocs.ptt_keyed = bc->ptt_keyed;
+		spin_unlock_bh(&bc->lock);
 		break;		
 
 	case HDLCDRVCTL_CALIBRATE:
 		if (!capable(CAP_SYS_RAWIO))
 			return -EACCES;
+		spin_lock_bh(&bc->lock);
 		bc->hdlctx.calibrate = hi.data.calibrate * bc->bitrate / 8;
+		spin_unlock_bh(&bc->lock);
 		return 0;
 
 	case HDLCDRVCTL_DRIVERNAME:
@@ -1104,46 +996,59 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 /* --------------------------------------------------------------------- */
 
 static const struct net_device_ops baycom_netdev_ops = {
-	.ndo_open	     = epp_open,
-	.ndo_stop	     = epp_close,
-	.ndo_do_ioctl	     = baycom_ioctl,
+	.ndo_open            = epp_open,
+	.ndo_stop            = epp_close,
+	.ndo_do_ioctl        = baycom_ioctl,
 	.ndo_start_xmit      = baycom_send_packet,
 	.ndo_set_mac_address = baycom_set_mac_address,
 };
 
+/* --------------------------------------------------------------------- */
+
 /*
- * Check for a network adaptor of this type, and return '0' if one exists.
- * If dev->base_addr == 0, probe all likely locations.
- * If dev->base_addr == 1, always return failure.
- * If dev->base_addr == 2, allocate space for the device and return success
- * (detachable devices only).
+ * command line settable parameters
  */
-static void baycom_probe(struct net_device *dev)
+static const char *mode[NR_PORTS] = { "", "", "", "", };
+static int parport[NR_PORTS] = { 0, 1, 2, 3, };
+
+module_param_array(mode, charp, NULL, 0);
+MODULE_PARM_DESC(mode, "baycom operating mode");
+module_param_array(parport, int, NULL, 0);
+MODULE_PARM_DESC(parport, "baycom parport number");
+
+MODULE_AUTHOR("Thomas M. Sailer, sailer@ife.ee.ethz.ch");
+MODULE_DESCRIPTION("Baycom epp amateur radio modem driver");
+MODULE_LICENSE("GPL");
+
+/* --------------------------------------------------------------------- */
+
+static void __init baycom_epp_dev_setup(struct net_device *dev)
 {
 	const struct hdlcdrv_channel_params dflt_ch_params = { 
 		20, 2, 10, 40, 0 
 	};
-	struct baycom_state *bc;
+	struct baycom_state *bc = netdev_priv(dev);
 
 	/*
-	 * not a real probe! only initialize data structures
-	 */
-	bc = netdev_priv(dev);
-	/*
-	 * initialize the baycom_state struct
+	 * initialize part of the baycom_state struct
 	 */
+	bc->dev = dev;
+	bc->magic = BAYCOM_MAGIC;
+	bc->cfg.fclk = 19666600;
+	bc->cfg.bps = 9600;
 	bc->ch_params = dflt_ch_params;
 	bc->ptt_keyed = 0;
 
 	/*
 	 * initialize the device struct
 	 */
+	spin_lock_init(&bc->lock);
 
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
-	dev->netdev_ops = &baycom_netdev_ops;
 	dev->header_ops = &ax25_header_ops;
+	dev->netdev_ops = &baycom_netdev_ops;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
@@ -1157,42 +1062,6 @@ static void baycom_probe(struct net_device *dev)
 	dev->flags = 0;
 }
 
-/* --------------------------------------------------------------------- */
-
-/*
- * command line settable parameters
- */
-static const char *mode[NR_PORTS] = { "", };
-static int iobase[NR_PORTS] = { 0x378, };
-
-module_param_array(mode, charp, NULL, 0);
-MODULE_PARM_DESC(mode, "baycom operating mode");
-module_param_array(iobase, int, NULL, 0);
-MODULE_PARM_DESC(iobase, "baycom io base address");
-
-MODULE_AUTHOR("Thomas M. Sailer, sailer@ife.ee.ethz.ch, hb9jnx@hb9w.che.eu");
-MODULE_DESCRIPTION("Baycom epp amateur radio modem driver");
-MODULE_LICENSE("GPL");
-
-/* --------------------------------------------------------------------- */
-
-static void __init baycom_epp_dev_setup(struct net_device *dev)
-{
-	struct baycom_state *bc = netdev_priv(dev);
-
-	/*
-	 * initialize part of the baycom_state struct
-	 */
-	bc->dev = dev;
-	bc->magic = BAYCOM_MAGIC;
-	bc->cfg.fclk = 19666600;
-	bc->cfg.bps = 9600;
-	/*
-	 * initialize part of the device struct
-	 */
-	baycom_probe(dev);
-}
-
 static int __init init_baycomepp(void)
 {
 	int i, found = 0;
@@ -1203,6 +1072,7 @@ static int __init init_baycomepp(void)
 	 * register net devices
 	 */
 	for (i = 0; i < NR_PORTS; i++) {
+		struct parport *pp = parport_find_number(parport[i]);
 		struct net_device *dev;
 		
 		dev = alloc_netdev(sizeof(struct baycom_state), "bce%d",
@@ -1212,14 +1082,12 @@ static int __init init_baycomepp(void)
 			printk(KERN_WARNING "bce%d : out of memory\n", i);
 			return found ? 0 : -ENOMEM;
 		}
-			
+		
 		sprintf(dev->name, "bce%d", i);
-		dev->base_addr = iobase[i];
+		dev->base_addr = pp ? pp->base : 0;
 
-		if (!mode[i])
+		if (!pp || !mode[i])
 			set_hw = 0;
-		if (!set_hw)
-			iobase[i] = 0;
 
 		if (register_netdev(dev)) {
 			printk(KERN_WARNING "%s: cannot register net device %s\n", bc_drvname, dev->name);
@@ -1261,7 +1129,7 @@ module_exit(cleanup_baycomepp);
 #ifndef MODULE
 
 /*
- * format: baycom_epp=io,mode
+ * format: baycom_epp=parport,mode
  * mode: fpga config options
  */
 
@@ -1272,11 +1140,11 @@ static int __init baycom_epp_setup(char *str)
 
         if (nr_dev >= NR_PORTS)
                 return 0;
-	str = get_options(str, 2, ints);
+	str = get_options(str, ARRAY_SIZE(ints), ints);
 	if (ints[0] < 1)
 		return 0;
 	mode[nr_dev] = str;
-	iobase[nr_dev] = ints[1];
+	parport[nr_dev] = ints[1];
 	nr_dev++;
 	return 1;
 }
