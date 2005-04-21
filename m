From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH][RESENT] Generic HDLC update
Date: Thu, 21 Apr 2005 15:57:25 +0200
Message-ID: <m3acns8c6y.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

The attached patch updates generic HDLC to version 1.18.
FR Cisco LMI production-tested. Please apply to Linux 2.6. Thanks.

Changes:
- doc updates
- added Cisco LMI support to Frame-Relay code
- cleaned hdlc_fr.c a bit, removed some orphaned #defines etc.
- fixed a problem with non-functional LMI in FR DCE mode.
- changed diagnostic messages to better conform to FR standards
- all protocols: information about carrier changes (DCD line) is now
  printed to kernel logs.

Signed-Off-By: Krzysztof Halasa <khc@pm.waw.pl>

-- 
Krzysztof Halasa

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=hdlc-2.6-1.18.patch

--- linux-2.6/Documentation/networking/generic-hdlc.txt	25 May 2003 22:13:37 -0000	1.4
+++ linux-2.6/Documentation/networking/generic-hdlc.txt	2 Apr 2005 13:12:18 -0000
@@ -1,21 +1,21 @@
 Generic HDLC layer
 Krzysztof Halasa <khc@pm.waw.pl>
-January, 2003
 
 
 Generic HDLC layer currently supports:
-- Frame Relay (ANSI, CCITT and no LMI), with ARP support (no InARP).
-  Normal (routed) and Ethernet-bridged (Ethernet device emulation)
-  interfaces can share a single PVC.
-- raw HDLC - either IP (IPv4) interface or Ethernet device emulation.
-- Cisco HDLC,
-- PPP (uses syncppp.c),
-- X.25 (uses X.25 routines).
-
-There are hardware drivers for the following cards:
-- C101 by Moxa Technologies Co., Ltd.
-- RISCom/N2 by SDL Communications Inc.
-- and others, some not in the official kernel.
+1. Frame Relay (ANSI, CCITT, Cisco and no LMI).
+   - Normal (routed) and Ethernet-bridged (Ethernet device emulation)
+     interfaces can share a single PVC.
+   - ARP support (no InARP support in the kernel - there is an
+     experimental InARP user-space daemon available on:
+     http://www.kernel.org/pub/linux/utils/net/hdlc/).
+2. raw HDLC - either IP (IPv4) interface or Ethernet device emulation.
+3. Cisco HDLC.
+4. PPP (uses syncppp.c).
+5. X.25 (uses X.25 routines).
+
+Generic HDLC is a protocol driver only - it needs a low-level driver
+for your particular hardware.
 
 Ethernet device emulation (using HDLC or Frame-Relay PVC) is compatible
 with IEEE 802.1Q (VLANs) and 802.1D (Ethernet bridging).
@@ -24,7 +24,7 @@
 Make sure the hdlc.o and the hardware driver are loaded. It should
 create a number of "hdlc" (hdlc0 etc) network devices, one for each
 WAN port. You'll need the "sethdlc" utility, get it from:
-	http://hq.pm.waw.pl/hdlc/
+	http://www.kernel.org/pub/linux/utils/net/hdlc/
 
 Compile sethdlc.c utility:
 	gcc -O2 -Wall -o sethdlc sethdlc.c
@@ -52,12 +52,12 @@
 * v35 | rs232 | x21 | t1 | e1 - sets physical interface for a given port
                                 if the card has software-selectable interfaces
   loopback - activate hardware loopback (for testing only)
-* clock ext - external clock (uses DTE RX and TX clock)
-* clock int - internal clock (provides clock signal on DCE clock output)
-* clock txint - TX internal, RX external (provides TX clock on DCE output)
-* clock txfromrx - TX clock derived from RX clock (TX clock on DCE output)
-* rate - sets clock rate in bps (not required for external clock or
-                                 for txfromrx)
+* clock ext - both RX clock and TX clock external
+* clock int - both RX clock and TX clock internal
+* clock txint - RX clock external, TX clock internal
+* clock txfromrx - RX clock external, TX clock derived from RX clock
+* rate - sets clock rate in bps (for "int" or "txint" clock only)
+
 
 Setting protocol:
 
@@ -79,7 +79,7 @@
 * x25 - sets X.25 mode
 
 * fr - Frame Relay mode
-  lmi ansi / ccitt / none - LMI (link management) type
+  lmi ansi / ccitt / cisco / none - LMI (link management) type
   dce - Frame Relay DCE (network) side LMI instead of default DTE (user).
   It has nothing to do with clocks!
   t391 - link integrity verification polling timer (in seconds) - user
@@ -119,13 +119,14 @@
 
 
 
-If you have a problem with N2 or C101 card, you can issue the "private"
-command to see port's packet descriptor rings (in kernel logs):
+If you have a problem with N2, C101 or PLX200SYN card, you can issue the
+"private" command to see port's packet descriptor rings (in kernel logs):
 
 	sethdlc hdlc0 private
 
-The hardware driver has to be build with CONFIG_HDLC_DEBUG_RINGS.
+The hardware driver has to be build with #define DEBUG_RINGS.
 Attaching this info to bug reports would be helpful. Anyway, let me know
 if you have problems using this.
 
-For patches and other info look at http://hq.pm.waw.pl/hdlc/
+For patches and other info look at:
+<http://www.kernel.org/pub/linux/utils/net/hdlc/>.
--- linux-2.6/include/linux/hdlc.h	28 Oct 2004 06:16:08 -0000	1.12
+++ linux-2.6/include/linux/hdlc.h	2 Apr 2005 13:12:18 -0000
@@ -1,7 +1,7 @@
 /*
  * Generic HDLC support routines for Linux
  *
- * Copyright (C) 1999-2003 Krzysztof Halasa <khc@pm.waw.pl>
+ * Copyright (C) 1999-2005 Krzysztof Halasa <khc@pm.waw.pl>
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -41,6 +41,7 @@
 #define LMI_NONE		1 /* No LMI, all PVCs are static */
 #define LMI_ANSI		2 /* ANSI Annex D */
 #define LMI_CCITT		3 /* ITU-T Annex A */
+#define LMI_CISCO		4 /* The "original" LMI, aka Gang of Four */
 
 #define HDLC_MAX_MTU 1500	/* Ethernet 1500 bytes */
 #define HDLC_MAX_MRU (HDLC_MAX_MTU + 10 + 14 + 4) /* for ETH+VLAN over FR */
@@ -89,6 +90,7 @@
 		unsigned int deleted: 1;
 		unsigned int fecn: 1;
 		unsigned int becn: 1;
+		unsigned int bandwidth;	/* Cisco LMI reporting only */
 	}state;
 }pvc_device;
 
--- linux-2.6/drivers/net/wan/hdlc_fr.c	22 Jun 2004 03:25:28 -0000	1.13
+++ linux-2.6/drivers/net/wan/hdlc_fr.c	2 Apr 2005 13:12:18 -0000
@@ -2,7 +2,7 @@
  * Generic HDLC support routines for Linux
  * Frame Relay support
  *
- * Copyright (C) 1999 - 2003 Krzysztof Halasa <khc@pm.waw.pl>
+ * Copyright (C) 1999 - 2005 Krzysztof Halasa <khc@pm.waw.pl>
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -27,6 +27,10 @@
  active = open and "link reliable"
  exist = new = not used
 
+ CCITT LMI: ITU-T Q.933 Annex A
+ ANSI LMI: ANSI T1.617 Annex D
+ CISCO LMI: the original, aka "Gang of Four" LMI
+
 */
 
 #include <linux/module.h>
@@ -49,45 +53,41 @@
 #undef DEBUG_ECN
 #undef DEBUG_LINK
 
-#define MAXLEN_LMISTAT  20	/* max size of status enquiry frame */
+#define FR_UI			0x03
+#define FR_PAD			0x00
+
+#define NLPID_IP		0xCC
+#define NLPID_IPV6		0x8E
+#define NLPID_SNAP		0x80
+#define NLPID_PAD		0x00
+#define NLPID_CCITT_ANSI_LMI	0x08
+#define NLPID_CISCO_LMI		0x09
+
+
+#define LMI_CCITT_ANSI_DLCI	   0 /* LMI DLCI */
+#define LMI_CISCO_DLCI		1023
+
+#define LMI_CALLREF		0x00 /* Call Reference */
+#define LMI_ANSI_LOCKSHIFT	0x95 /* ANSI locking shift */
+#define LMI_ANSI_CISCO_REPTYPE	0x01 /* report type */
+#define LMI_CCITT_REPTYPE	0x51
+#define LMI_ANSI_CISCO_ALIVE	0x03 /* keep alive */
+#define LMI_CCITT_ALIVE		0x53
+#define LMI_ANSI_CISCO_PVCSTAT	0x07 /* PVC status */
+#define LMI_CCITT_PVCSTAT	0x57
+
+#define LMI_FULLREP		0x00 /* full report  */
+#define LMI_INTEGRITY		0x01 /* link integrity report */
+#define LMI_SINGLE		0x02 /* single PVC report */
 
-#define PVC_STATE_NEW	 0x01
-#define PVC_STATE_ACTIVE 0x02
-#define PVC_STATE_FECN	 0x08 /* FECN condition */
-#define PVC_STATE_BECN	 0x10 /* BECN condition */
-
-
-#define FR_UI		 0x03
-#define FR_PAD		 0x00
-
-#define NLPID_IP	 0xCC
-#define NLPID_IPV6	 0x8E
-#define NLPID_SNAP	 0x80
-#define NLPID_PAD	 0x00
-#define NLPID_Q933	 0x08
-
-
-#define LMI_DLCI                   0 /* LMI DLCI */
-#define LMI_PROTO               0x08
-#define LMI_CALLREF             0x00 /* Call Reference */
-#define LMI_ANSI_LOCKSHIFT      0x95 /* ANSI lockshift */
-#define LMI_REPTYPE                1 /* report type */
-#define LMI_CCITT_REPTYPE       0x51
-#define LMI_ALIVE                  3 /* keep alive */
-#define LMI_CCITT_ALIVE         0x53
-#define LMI_PVCSTAT                7 /* pvc status */
-#define LMI_CCITT_PVCSTAT       0x57
-#define LMI_FULLREP                0 /* full report  */
-#define LMI_INTEGRITY              1 /* link integrity report */
-#define LMI_SINGLE                 2 /* single pvc report */
 #define LMI_STATUS_ENQUIRY      0x75
 #define LMI_STATUS              0x7D /* reply */
 
 #define LMI_REPT_LEN               1 /* report type element length */
 #define LMI_INTEG_LEN              2 /* link integrity element length */
 
-#define LMI_LENGTH                13 /* standard LMI frame length */
-#define LMI_ANSI_LENGTH           14
+#define LMI_CCITT_CISCO_LENGTH	  13 /* LMI frame lengths */
+#define LMI_ANSI_LENGTH		  14
 
 
 typedef struct {
@@ -223,51 +223,34 @@
 }
 
 
-static inline u16 status_to_dlci(u8 *status, int *active, int *new)
-{
-	*new = (status[2] & 0x08) ? 1 : 0;
-	*active = (status[2] & 0x02) ? 1 : 0;
-
-	return ((status[0] & 0x3F) << 4) | ((status[1] & 0x78) >> 3);
-}
-
-
-static inline void dlci_to_status(u16 dlci, u8 *status, int active, int new)
-{
-	status[0] = (dlci >> 4) & 0x3F;
-	status[1] = ((dlci << 3) & 0x78) | 0x80;
-	status[2] = 0x80;
-
-	if (new)
-		status[2] |= 0x08;
-	else if (active)
-		status[2] |= 0x02;
-}
-
-
-
 static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 {
 	u16 head_len;
 	struct sk_buff *skb = *skb_p;
 
 	switch (skb->protocol) {
-	case __constant_ntohs(ETH_P_IP):
+	case __constant_ntohs(NLPID_CCITT_ANSI_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
-		skb->data[3] = NLPID_IP;
+		skb->data[3] = NLPID_CCITT_ANSI_LMI;
 		break;
 
-	case __constant_ntohs(ETH_P_IPV6):
+	case __constant_ntohs(NLPID_CISCO_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
-		skb->data[3] = NLPID_IPV6;
+		skb->data[3] = NLPID_CISCO_LMI;
 		break;
 
-	case __constant_ntohs(LMI_PROTO):
+	case __constant_ntohs(ETH_P_IP):
 		head_len = 4;
 		skb_push(skb, head_len);
-		skb->data[3] = LMI_PROTO;
+		skb->data[3] = NLPID_IP;
+		break;
+
+	case __constant_ntohs(ETH_P_IPV6):
+		head_len = 4;
+		skb_push(skb, head_len);
+		skb->data[3] = NLPID_IPV6;
 		break;
 
 	case __constant_ntohs(ETH_P_802_3):
@@ -461,13 +444,14 @@
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	struct sk_buff *skb;
 	pvc_device *pvc = hdlc->state.fr.first_pvc;
-	int len = (hdlc->state.fr.settings.lmi == LMI_ANSI) ? LMI_ANSI_LENGTH
-		: LMI_LENGTH;
-	int stat_len = 3;
+	int lmi = hdlc->state.fr.settings.lmi;
+	int dce = hdlc->state.fr.settings.dce;
+	int len = lmi == LMI_ANSI ? LMI_ANSI_LENGTH : LMI_CCITT_CISCO_LENGTH;
+	int stat_len = (lmi == LMI_CISCO) ? 6 : 3;
 	u8 *data;
 	int i = 0;
 
-	if (hdlc->state.fr.settings.dce && fullrep) {
+	if (dce && fullrep) {
 		len += hdlc->state.fr.dce_pvc_count * (2 + stat_len);
 		if (len > HDLC_MAX_MRU) {
 			printk(KERN_WARNING "%s: Too many PVCs while sending "
@@ -484,29 +468,31 @@
 	}
 	memset(skb->data, 0, len);
 	skb_reserve(skb, 4);
-	skb->protocol = __constant_htons(LMI_PROTO);
-	fr_hard_header(&skb, LMI_DLCI);
+	if (lmi == LMI_CISCO) {
+		skb->protocol = __constant_htons(NLPID_CISCO_LMI);
+		fr_hard_header(&skb, LMI_CISCO_DLCI);
+	} else {
+		skb->protocol = __constant_htons(NLPID_CCITT_ANSI_LMI);
+		fr_hard_header(&skb, LMI_CCITT_ANSI_DLCI);
+	}
 	data = skb->tail;
 	data[i++] = LMI_CALLREF;
-	data[i++] = hdlc->state.fr.settings.dce
-		? LMI_STATUS : LMI_STATUS_ENQUIRY;
-	if (hdlc->state.fr.settings.lmi == LMI_ANSI)
+	data[i++] = dce ? LMI_STATUS : LMI_STATUS_ENQUIRY;
+	if (lmi == LMI_ANSI)
 		data[i++] = LMI_ANSI_LOCKSHIFT;
-	data[i++] = (hdlc->state.fr.settings.lmi == LMI_CCITT)
-		? LMI_CCITT_REPTYPE : LMI_REPTYPE;
+	data[i++] = lmi == LMI_CCITT ? LMI_CCITT_REPTYPE :
+		LMI_ANSI_CISCO_REPTYPE;
 	data[i++] = LMI_REPT_LEN;
 	data[i++] = fullrep ? LMI_FULLREP : LMI_INTEGRITY;
-
-	data[i++] = (hdlc->state.fr.settings.lmi == LMI_CCITT)
-		? LMI_CCITT_ALIVE : LMI_ALIVE;
+	data[i++] = lmi == LMI_CCITT ? LMI_CCITT_ALIVE : LMI_ANSI_CISCO_ALIVE;
 	data[i++] = LMI_INTEG_LEN;
 	data[i++] = hdlc->state.fr.txseq =fr_lmi_nextseq(hdlc->state.fr.txseq);
 	data[i++] = hdlc->state.fr.rxseq;
 
-	if (hdlc->state.fr.settings.dce && fullrep) {
+	if (dce && fullrep) {
 		while (pvc) {
-			data[i++] = (hdlc->state.fr.settings.lmi == LMI_CCITT)
-				? LMI_CCITT_PVCSTAT : LMI_PVCSTAT;
+			data[i++] = lmi == LMI_CCITT ? LMI_CCITT_PVCSTAT :
+				LMI_ANSI_CISCO_PVCSTAT;
 			data[i++] = stat_len;
 
 			/* LMI start/restart */
@@ -523,8 +509,20 @@
 				fr_log_dlci_active(pvc);
 			}
 
-			dlci_to_status(pvc->dlci, data + i,
-				       pvc->state.active, pvc->state.new);
+			if (lmi == LMI_CISCO) {
+				data[i] = pvc->dlci >> 8;
+				data[i + 1] = pvc->dlci & 0xFF;
+			} else {
+				data[i] = (pvc->dlci >> 4) & 0x3F;
+				data[i + 1] = ((pvc->dlci << 3) & 0x78) | 0x80;
+				data[i + 2] = 0x80;
+			}
+
+			if (pvc->state.new)
+				data[i + 2] |= 0x08;
+			else if (pvc->state.active)
+				data[i + 2] |= 0x02;
+
 			i += stat_len;
 			pvc = pvc->next;
 		}
@@ -569,6 +567,8 @@
 			pvc_carrier(0, pvc);
 			pvc->state.exist = pvc->state.active = 0;
 			pvc->state.new = 0;
+			if (!hdlc->state.fr.settings.dce)
+				pvc->state.bandwidth = 0;
 			pvc = pvc->next;
 		}
 	}
@@ -583,11 +583,12 @@
 	int i, cnt = 0, reliable;
 	u32 list;
 
-	if (hdlc->state.fr.settings.dce)
+	if (hdlc->state.fr.settings.dce) {
 		reliable = hdlc->state.fr.request &&
 			time_before(jiffies, hdlc->state.fr.last_poll +
 				    hdlc->state.fr.settings.t392 * HZ);
-	else {
+		hdlc->state.fr.request = 0;
+	} else {
 		hdlc->state.fr.last_errors <<= 1; /* Shift the list */
 		if (hdlc->state.fr.request) {
 			if (hdlc->state.fr.reliable)
@@ -634,65 +635,88 @@
 static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	int stat_len;
 	pvc_device *pvc;
-	int reptype = -1, error, no_ram;
 	u8 rxseq, txseq;
-	int i;
+	int lmi = hdlc->state.fr.settings.lmi;
+	int dce = hdlc->state.fr.settings.dce;
+	int stat_len = (lmi == LMI_CISCO) ? 6 : 3, reptype, error, no_ram, i;
 
-	if (skb->len < ((hdlc->state.fr.settings.lmi == LMI_ANSI)
-			? LMI_ANSI_LENGTH : LMI_LENGTH)) {
+	if (skb->len < (lmi == LMI_ANSI ? LMI_ANSI_LENGTH :
+			LMI_CCITT_CISCO_LENGTH)) {
 		printk(KERN_INFO "%s: Short LMI frame\n", dev->name);
 		return 1;
 	}
 
-	if (skb->data[5] != (!hdlc->state.fr.settings.dce ?
-			     LMI_STATUS : LMI_STATUS_ENQUIRY)) {
-		printk(KERN_INFO "%s: LMI msgtype=%x, Not LMI status %s\n",
-		       dev->name, skb->data[2],
-		       hdlc->state.fr.settings.dce ? "enquiry" : "reply");
+	if (skb->data[3] != (lmi == LMI_CISCO ? NLPID_CISCO_LMI :
+			     NLPID_CCITT_ANSI_LMI)) {
+		printk(KERN_INFO "%s: Received non-LMI frame with LMI"
+		       " DLCI\n", dev->name);
 		return 1;
 	}
 
-	i = (hdlc->state.fr.settings.lmi == LMI_ANSI) ? 7 : 6;
+	if (skb->data[4] != LMI_CALLREF) {
+		printk(KERN_INFO "%s: Invalid LMI Call reference (0x%02X)\n",
+		       dev->name, skb->data[4]);
+		return 1;
+	}
+
+	if (skb->data[5] != (dce ? LMI_STATUS_ENQUIRY : LMI_STATUS)) {
+		printk(KERN_INFO "%s: Invalid LMI Message type (0x%02X)\n",
+		       dev->name, skb->data[5]);
+		return 1;
+	}
+
+	if (lmi == LMI_ANSI) {
+		if (skb->data[6] != LMI_ANSI_LOCKSHIFT) {
+			printk(KERN_INFO "%s: Not ANSI locking shift in LMI"
+			       " message (0x%02X)\n", dev->name, skb->data[6]);
+			return 1;
+		}
+		i = 7;
+	} else
+		i = 6;
 
-	if (skb->data[i] !=
-	    ((hdlc->state.fr.settings.lmi == LMI_CCITT)
-	     ? LMI_CCITT_REPTYPE : LMI_REPTYPE)) {
-		printk(KERN_INFO "%s: Not a report type=%x\n",
+	if (skb->data[i] != (lmi == LMI_CCITT ? LMI_CCITT_REPTYPE :
+			     LMI_ANSI_CISCO_REPTYPE)) {
+		printk(KERN_INFO "%s: Not an LMI Report type IE (0x%02X)\n",
 		       dev->name, skb->data[i]);
 		return 1;
 	}
-	i++;
 
-	i++;				/* Skip length field */
+	if (skb->data[++i] != LMI_REPT_LEN) {
+		printk(KERN_INFO "%s: Invalid LMI Report type IE length"
+		       " (%u)\n", dev->name, skb->data[i]);
+		return 1;
+	}
 
-	reptype = skb->data[i++];
+	reptype = skb->data[++i];
+	if (reptype != LMI_INTEGRITY && reptype != LMI_FULLREP) {
+		printk(KERN_INFO "%s: Unsupported LMI Report type (0x%02X)\n",
+		       dev->name, reptype);
+		return 1;
+	}
 
-	if (skb->data[i]!=
-	    ((hdlc->state.fr.settings.lmi == LMI_CCITT)
-	     ? LMI_CCITT_ALIVE : LMI_ALIVE)) {
-		printk(KERN_INFO "%s: Unsupported status element=%x\n",
-		       dev->name, skb->data[i]);
+	if (skb->data[++i] != (lmi == LMI_CCITT ? LMI_CCITT_ALIVE :
+			       LMI_ANSI_CISCO_ALIVE)) {
+		printk(KERN_INFO "%s: Not an LMI Link integrity verification"
+		       " IE (0x%02X)\n", dev->name, skb->data[i]);
 		return 1;
 	}
-	i++;
 
-	i++;			/* Skip length field */
+	if (skb->data[++i] != LMI_INTEG_LEN) {
+		printk(KERN_INFO "%s: Invalid LMI Link integrity verification"
+		       " IE length (%u)\n", dev->name, skb->data[i]);
+		return 1;
+	}
+	i++;
 
 	hdlc->state.fr.rxseq = skb->data[i++]; /* TX sequence from peer */
 	rxseq = skb->data[i++];	/* Should confirm our sequence */
 
 	txseq = hdlc->state.fr.txseq;
 
-	if (hdlc->state.fr.settings.dce) {
-		if (reptype != LMI_FULLREP && reptype != LMI_INTEGRITY) {
-			printk(KERN_INFO "%s: Unsupported report type=%x\n",
-			       dev->name, reptype);
-			return 1;
-		}
+	if (dce)
 		hdlc->state.fr.last_poll = jiffies;
-	}
 
 	error = 0;
 	if (!hdlc->state.fr.reliable)
@@ -703,7 +727,7 @@
 		error = 1;
 	}
 
-	if (hdlc->state.fr.settings.dce) {
+	if (dce) {
 		if (hdlc->state.fr.fullrep_sent && !error) {
 /* Stop sending full report - the last one has been confirmed by DTE */
 			hdlc->state.fr.fullrep_sent = 0;
@@ -725,6 +749,7 @@
 			hdlc->state.fr.dce_changed = 0;
 		}
 
+		hdlc->state.fr.request = 1; /* got request */
 		fr_lmi_send(dev, reptype == LMI_FULLREP ? 1 : 0);
 		return 0;
 	}
@@ -739,7 +764,6 @@
 	if (reptype != LMI_FULLREP)
 		return 0;
 
-	stat_len = 3;
 	pvc = hdlc->state.fr.first_pvc;
 
 	while (pvc) {
@@ -750,24 +774,35 @@
 	no_ram = 0;
 	while (skb->len >= i + 2 + stat_len) {
 		u16 dlci;
+		u32 bw;
 		unsigned int active, new;
 
-		if (skb->data[i] != ((hdlc->state.fr.settings.lmi == LMI_CCITT)
-				     ? LMI_CCITT_PVCSTAT : LMI_PVCSTAT)) {
-			printk(KERN_WARNING "%s: Invalid PVCSTAT ID: %x\n",
-			       dev->name, skb->data[i]);
+		if (skb->data[i] != (lmi == LMI_CCITT ? LMI_CCITT_PVCSTAT :
+				       LMI_ANSI_CISCO_PVCSTAT)) {
+			printk(KERN_INFO "%s: Not an LMI PVC status IE"
+			       " (0x%02X)\n", dev->name, skb->data[i]);
 			return 1;
 		}
-		i++;
 
-		if (skb->data[i] != stat_len) {
-			printk(KERN_WARNING "%s: Invalid PVCSTAT length: %x\n",
-			       dev->name, skb->data[i]);
+		if (skb->data[++i] != stat_len) {
+			printk(KERN_INFO "%s: Invalid LMI PVC status IE length"
+			       " (%u)\n", dev->name, skb->data[i]);
 			return 1;
 		}
 		i++;
 
-		dlci = status_to_dlci(skb->data + i, &active, &new);
+		new = !! (skb->data[i + 2] & 0x08);
+		active = !! (skb->data[i + 2] & 0x02);
+		if (lmi == LMI_CISCO) {
+			dlci = (skb->data[i] << 8) | skb->data[i + 1];
+			bw = (skb->data[i + 3] << 16) |
+				(skb->data[i + 4] << 8) |
+				(skb->data[i + 5]);
+		} else {
+			dlci = ((skb->data[i] & 0x3F) << 4) |
+				((skb->data[i + 1] & 0x78) >> 3);
+			bw = 0;
+		}
 
 		pvc = add_pvc(dev, dlci);
 
@@ -783,9 +818,11 @@
 			pvc->state.deleted = 0;
 			if (active != pvc->state.active ||
 			    new != pvc->state.new ||
+			    bw != pvc->state.bandwidth ||
 			    !pvc->state.exist) {
 				pvc->state.new = new;
 				pvc->state.active = active;
+				pvc->state.bandwidth = bw;
 				pvc_carrier(active, pvc);
 				fr_log_dlci_active(pvc);
 			}
@@ -801,6 +838,7 @@
 			pvc_carrier(0, pvc);
 			pvc->state.active = pvc->state.new = 0;
 			pvc->state.exist = 0;
+			pvc->state.bandwidth = 0;
 			fr_log_dlci_active(pvc);
 		}
 		pvc = pvc->next;
@@ -829,22 +867,15 @@
 
 	dlci = q922_to_dlci(skb->data);
 
-	if (dlci == LMI_DLCI) {
-		if (hdlc->state.fr.settings.lmi == LMI_NONE)
-			goto rx_error; /* LMI packet with no LMI? */
-
-		if (data[3] == LMI_PROTO) {
-			if (fr_lmi_recv(ndev, skb))
-				goto rx_error;
-			else {
-				dev_kfree_skb_any(skb);
-				return NET_RX_SUCCESS;
-			}
-		}
-
-		printk(KERN_INFO "%s: Received non-LMI frame with LMI DLCI\n",
-		       ndev->name);
-		goto rx_error;
+	if ((dlci == LMI_CCITT_ANSI_DLCI &&
+	     (hdlc->state.fr.settings.lmi == LMI_ANSI ||
+	      hdlc->state.fr.settings.lmi == LMI_CCITT)) ||
+	    (dlci == LMI_CISCO_DLCI &&
+	     hdlc->state.fr.settings.lmi == LMI_CISCO)) {
+		if (fr_lmi_recv(ndev, skb))
+			goto rx_error;
+		dev_kfree_skb_any(skb);
+		return NET_RX_SUCCESS;
 	}
 
 	pvc = find_pvc(hdlc, dlci);
@@ -1170,7 +1201,8 @@
 
 		if ((new_settings.lmi != LMI_NONE &&
 		     new_settings.lmi != LMI_ANSI &&
-		     new_settings.lmi != LMI_CCITT) ||
+		     new_settings.lmi != LMI_CCITT &&
+		     new_settings.lmi != LMI_CISCO) ||
 		    new_settings.t391 < 1 ||
 		    new_settings.t392 < 2 ||
 		    new_settings.n391 < 1 ||
--- linux-2.6/drivers/net/wan/hdlc_generic.c	3 Jun 2004 05:04:21 -0000	1.15
+++ linux-2.6/drivers/net/wan/hdlc_generic.c	2 Apr 2005 13:12:18 -0000
@@ -1,7 +1,7 @@
 /*
  * Generic HDLC support routines for Linux
  *
- * Copyright (C) 1999 - 2003 Krzysztof Halasa <khc@pm.waw.pl>
+ * Copyright (C) 1999 - 2005 Krzysztof Halasa <khc@pm.waw.pl>
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -38,7 +38,7 @@
 #include <linux/hdlc.h>
 
 
-static const char* version = "HDLC support module revision 1.17";
+static const char* version = "HDLC support module revision 1.18";
 
 #undef DEBUG_LINK
 
@@ -126,10 +126,13 @@
 	if (!hdlc->open)
 		goto carrier_exit;
 
-	if (hdlc->carrier)
+	if (hdlc->carrier) {
+		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
 		__hdlc_set_carrier_on(dev);
-	else
+	} else {
+		printk(KERN_INFO "%s: Carrier lost\n", dev->name);
 		__hdlc_set_carrier_off(dev);
+	}
 
 carrier_exit:
 	spin_unlock_irqrestore(&hdlc->state_lock, flags);
@@ -157,8 +160,11 @@
 
 	spin_lock_irq(&hdlc->state_lock);
 
-	if (hdlc->carrier)
+	if (hdlc->carrier) {
+		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
 		__hdlc_set_carrier_on(dev);
+	} else
+		printk(KERN_INFO "%s: No carrier\n", dev->name);
 
 	hdlc->open = 1;
 

--=-=-=--
