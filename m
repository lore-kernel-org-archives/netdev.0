From: Kevin Curtis <kevin.curtis@farsite.co.uk>
Subject: Update FarSync WAN driver in 2.4.25
Date: Wed, 4 Feb 2004 16:06:16 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7C078C66B7752B438B88E11E5E20E72E25CBB5@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_000_01C3EB38.D1A7D900"
Cc: "'davem@redhat.com'" <davem@redhat.com>,
        "'jgarzik@redhat.com'"
	 <jgarzik@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C3EB38.D1A7D900
Content-Type: text/plain

Hi,
	please find attached a patch to update the FarSync WAN driver in the
2.4 Kernel.  The driver has been updated in the following ways:

1) Provides support for new FarSync cards T1U, T2U, T4U and TE1
2) Provides support for an E1 interface
3) Provides support for a variant of X.21 that allows transmit and receive
clocks
4) Provide a raw socket interface directly to the data from the line.
5) Improves performance with less time in interrupts and more in BH's

In the main the only files affected are the farsync.c and farsync.h files,
although there have been some additions to the if.h file.

Please try to include it in the 2.4.25 release.

Never having submitted such a large patch before, let me know if there is
anything I should have done that I haven't.  But I think I remember a mail a
little while back asking for patches to be submitted through you?


Kind Regards

Kevin Curtis
Linux Development
FarSite Communications Ltd
http://www.farsite.co.uk
tel:  +44 1256 330461
fax:  +44 1256 854931


------_=_NextPart_000_01C3EB38.D1A7D900
Content-Type: application/octet-stream;
	name="farsync.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="farsync.patch"

diff -urN linux-2.4.25-orig/drivers/net/wan/farsync.c =
linux/drivers/net/wan/farsync.c=0A=
--- linux-2.4.25-orig/drivers/net/wan/farsync.c	2004-02-04 =
12:08:41.000000000 +0000=0A=
+++ linux/drivers/net/wan/farsync.c	2004-02-04 13:15:45.000000000 =
+0000=0A=
@@ -1,9 +1,9 @@=0A=
 /*=0A=
- *      FarSync X21 driver for Linux (generic HDLC version)=0A=
+ *      FarSync X21 driver for Linux (2.4.x kernel version)=0A=
  *=0A=
  *      Actually sync driver for X.21, V.35 and V.24 on FarSync =
T-series cards=0A=
  *=0A=
- *      Copyright (C) 2001 FarSite Communications Ltd.=0A=
+ *      Copyright (C) 2001-2002 FarSite Communications Ltd.=0A=
  *      www.farsite.co.uk=0A=
  *=0A=
  *      This program is free software; you can redistribute it =
and/or=0A=
@@ -11,17 +11,20 @@=0A=
  *      as published by the Free Software Foundation; either =
version=0A=
  *      2 of the License, or (at your option) any later version.=0A=
  *=0A=
- *      Author: R.J.Dunlop      <bob.dunlop@farsite.co.uk>=0A=
+ *      Author:      R.J.Dunlop    <bob.dunlop@farsite.co.uk>=0A=
+ *      Maintainer:  Kevin Curtis  <kevin.curtis@farsite.co.uk>=0A=
  */=0A=
 =0A=
 #include <linux/module.h>=0A=
 #include <linux/kernel.h>=0A=
+#include <linux/version.h>=0A=
 #include <linux/pci.h>=0A=
 #include <linux/ioport.h>=0A=
 #include <linux/init.h>=0A=
 #include <asm/uaccess.h>=0A=
 #include <linux/if.h>=0A=
 #include <linux/hdlc.h>=0A=
+#include <asm/delay.h>=0A=
 =0A=
 #include "farsync.h"=0A=
 =0A=
@@ -31,6 +34,11 @@=0A=
  */=0A=
 MODULE_AUTHOR("R.J.Dunlop <bob.dunlop@farsite.co.uk>");=0A=
 MODULE_DESCRIPTION("FarSync T-Series X21 driver. FarSite =
Communications Ltd.");=0A=
+MODULE_PARM (fst_txq_low, "i");=0A=
+MODULE_PARM (fst_txq_high, "i");=0A=
+MODULE_PARM (fst_max_reads, "i");=0A=
+MODULE_PARM (fst_excluded_cards, "i");=0A=
+MODULE_PARM (fst_excluded_list, "0-32i");=0A=
 MODULE_LICENSE("GPL");=0A=
 =0A=
 EXPORT_NO_SYMBOLS;=0A=
@@ -40,16 +48,21 @@=0A=
  *      =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A=
  */=0A=
 =0A=
-/*      Number of ports (per card) supported=0A=
+/*      Number of ports (per card) and cards supported=0A=
  */=0A=
 #define FST_MAX_PORTS           4=0A=
-=0A=
+#define FST_MAX_CARDS           32=0A=
 =0A=
 /*      PCI vendor and device IDs=0A=
  */=0A=
 #define FSC_PCI_VENDOR_ID       0x1619  /* FarSite Communications Ltd =
*/=0A=
 #define T2P_PCI_DEVICE_ID       0x0400  /* T2P X21 2 port card */=0A=
 #define T4P_PCI_DEVICE_ID       0x0440  /* T4P X21 4 port card */=0A=
+#define T1U_PCI_DEVICE_ID       0x0610  /* T1U X21 1 port card */=0A=
+#define T2U_PCI_DEVICE_ID       0x0620  /* T2U X21 2 port card */=0A=
+#define T4U_PCI_DEVICE_ID       0x0640  /* T4U X21 4 port card */=0A=
+#define TE1_PCI_DEVICE_ID       0x1610  /* TE1 X21 1 port card */=0A=
+#define TE1C_PCI_DEVICE_ID      0x1612  /* TE1 X21 1 port channelised =
*/=0A=
 =0A=
 =0A=
 /*      Default parameters for the link=0A=
@@ -59,6 +72,15 @@=0A=
                                          * this down assuming a slower =
line I=0A=
                                          * guess.=0A=
                                          */=0A=
+#define FST_TXQ_DEPTH           16      /* This one is for the =
buffering=0A=
+                                         * of frames on the way down =
to the card=0A=
+                                         * so that we can keep the =
card busy=0A=
+                                         * and maximise throughput=0A=
+					 */=0A=
+#define FST_HIGH_WATER_MARK     12      /* Point at which we flow =
control=0A=
+					 * network layer */=0A=
+#define FST_LOW_WATER_MARK      8       /* Point at which we remove =
flow=0A=
+					 * control from network layer */=0A=
 #define FST_MAX_MTU             8000    /* Huge but possible */=0A=
 #define FST_DEF_MTU             1500    /* Common sane value */=0A=
 =0A=
@@ -72,6 +94,15 @@=0A=
 #endif=0A=
 =0A=
 =0A=
+/*=0A=
+ * Modules parameters and associated varaibles=0A=
+ */=0A=
+int   fst_txq_low=3DFST_LOW_WATER_MARK;=0A=
+int   fst_txq_high=3DFST_HIGH_WATER_MARK;=0A=
+int   fst_max_reads=3D7;=0A=
+int   fst_excluded_cards=3D0;=0A=
+int   fst_excluded_list[FST_MAX_CARDS];=0A=
+=0A=
 /*      Card shared memory layout=0A=
  *      =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=0A=
  */=0A=
@@ -87,7 +118,7 @@=0A=
  *      be used to check that we have not got out of step with the =
firmware=0A=
  *      contained in the .CDE files.=0A=
  */=0A=
-#define SMC_VERSION 11=0A=
+#define SMC_VERSION 24=0A=
 =0A=
 #define FST_MEMSIZE 0x100000    /* Size of card memory (1Mb) */=0A=
 =0A=
@@ -161,7 +192,7 @@=0A=
 #define RX_ENP          0x01            /* Rx: end of packet */=0A=
 =0A=
 =0A=
-/* Interrupts from the card are caused by various events and these are =
presented=0A=
+/* Interrupts from the card are caused by various events which are =
presented=0A=
  * in a circular buffer as several events may be processed on one =
physical int=0A=
  */=0A=
 #define MAX_CIRBUFF     32=0A=
@@ -193,15 +224,59 @@=0A=
 #define TXC_UNDF        0x2A=0A=
 #define TXD_UNDF        0x2B=0A=
 =0A=
+#define F56_INT         0x2C=0A=
+#define M32_INT         0x2D=0A=
+=0A=
+#define TE1_ALMA        0x30=0A=
+=0A=
 =0A=
 /* Port physical configuration. See farsync.h for field values */=0A=
 struct port_cfg {=0A=
         u16  lineInterface;     /* Physical interface type */=0A=
         u8   x25op;             /* Unused at present */=0A=
         u8   internalClock;     /* 1 =3D> internal clock, 0 =3D> =
external */=0A=
+        u8   transparentMode;   /* 1 =3D> on, 0 =3D> off */=0A=
+        u8   invertClock;       /* 0 =3D> normal, 1 =3D> inverted =
*/=0A=
+        u8   padBytes[6];       /* Padding */=0A=
         u32  lineSpeed;         /* Speed in bps */=0A=
 };=0A=
 =0A=
+/* TE1 port physical configuration */=0A=
+struct su_config {=0A=
+        u32  dataRate;=0A=
+        u8   clocking;=0A=
+        u8   framing;=0A=
+        u8   structure;=0A=
+        u8   interface;=0A=
+        u8   coding;=0A=
+        u8   lineBuildOut;=0A=
+        u8   equalizer;=0A=
+        u8   transparentMode;=0A=
+        u8   loopMode;=0A=
+        u8   range;=0A=
+        u8   txBufferMode;=0A=
+        u8   rxBufferMode;=0A=
+        u8   startingSlot;=0A=
+        u8   losThreshold;=0A=
+        u8   enableIdleCode;=0A=
+        u8   idleCode;=0A=
+        u8   spare[44];=0A=
+};=0A=
+=0A=
+/* TE1 Status */=0A=
+struct su_status {=0A=
+        u32  receiveBufferDelay;=0A=
+        u32  framingErrorCount;=0A=
+        u32  codeViolationCount;=0A=
+        u32  crcErrorCount;=0A=
+        u32  lineAttenuation;=0A=
+        u8   portStarted;=0A=
+        u8   lossOfSignal;=0A=
+        u8   receiveRemoteAlarm;=0A=
+        u8   alarmIndicationSignal;=0A=
+        u8   spare[40];=0A=
+};=0A=
+=0A=
 /* Finally sling all the above together into the shared memory =
structure.=0A=
  * Sorry it's a hodge podge of arrays, structures and unused bits, =
it's been=0A=
  * evolving under NT for some time so I guess we're stuck with it.=0A=
@@ -259,14 +334,14 @@=0A=
         u16 portMailbox[FST_MAX_PORTS][2];      /* command, modifier =
*/=0A=
         u16 cardMailbox[4];                     /* Not used */=0A=
 =0A=
-                                /* Number of times that card thinks =
the host has=0A=
+                                /* Number of times the card thinks the =
host has=0A=
                                  * missed an interrupt by not =
acknowledging=0A=
                                  * within 2mS (I guess NT has =
problems)=0A=
                                  */=0A=
         u32 interruptRetryCount;=0A=
 =0A=
                                 /* Driver private data used as an ID. =
We'll not=0A=
-                                 * use this on Linux I'd rather keep =
such things=0A=
+                                 * use this as I'd rather keep such =
things=0A=
                                  * in main memory rather than on the =
PCI bus=0A=
                                  */=0A=
         u32 portHandle[FST_MAX_PORTS];=0A=
@@ -293,9 +368,12 @@=0A=
 =0A=
         u16 portScheduleOffset;=0A=
 =0A=
+        struct su_config suConfig;     /* TE1 Bits */=0A=
+        struct su_status suStatus;=0A=
+=0A=
         u32 endOfSmcSignature;  /* endOfSmcSignature MUST be the last =
member of=0A=
-                                 * the structure and marks the end of =
the shared=0A=
-                                 * memory. Adapter code initializes =
its value as=0A=
+                                 * the structure and marks the end of =
shared=0A=
+                                 * memory. Adapter code initializes it =
as=0A=
                                  * END_SIG.=0A=
                                  */=0A=
 };=0A=
@@ -312,6 +390,42 @@=0A=
 #define ABORTTX         5       /* Abort the transmitter for a port =
*/=0A=
 #define SETV24O         6       /* Set V24 outputs */=0A=
 =0A=
+/* PLX Chip Register Offsets */=0A=
+#define CNTRL_9052      0x50    /* Control Register */=0A=
+#define CNTRL_9054      0x6c    /* Control Register */=0A=
+=0A=
+#define PCIILR          0x3c    /* Interrupt Line Register */=0A=
+#define PCICR           0x04    /* Interrupt Control Register */=0A=
+#define INTCSR_9052     0x4c    /* Interrupt control/status register =
*/=0A=
+#define INTCSR_9054     0x68    /* Interrupt control/status register =
*/=0A=
+=0A=
+/* 9054 DMA Registers */=0A=
+/*=0A=
+ * Note that we will be using DMA Channel 0 for copying rx data=0A=
+ * and Channel 1 for copying tx data=0A=
+ */=0A=
+#define DMAMODE0        0x80=0A=
+#define DMAPADR0        0x84=0A=
+#define DMALADR0        0x88=0A=
+#define DMASIZ0         0x8c=0A=
+#define DMADPR0         0x90=0A=
+#define DMAMODE1        0x94=0A=
+#define DMAPADR1        0x98=0A=
+#define DMALADR1        0x9c=0A=
+#define DMASIZ1         0xa0=0A=
+#define DMADPR1         0xa4=0A=
+#define DMACSR0         0xa8=0A=
+#define DMACSR1         0xa9=0A=
+#define DMAARB          0xac=0A=
+#define DMATHR          0xb0=0A=
+#define DMADAC0         0xb4=0A=
+#define DMADAC1         0xb8=0A=
+#define DMAMARBR        0xac=0A=
+=0A=
+#define FST_MIN_DMA_LEN 64=0A=
+#define FST_RX_DMA_INT  0x01=0A=
+#define FST_TX_DMA_INT  0x02=0A=
+#define FST_CARD_INT    0x04=0A=
 =0A=
 /* Larger buffers are positioned in memory at offset BFM_BASE */=0A=
 struct buf_window {=0A=
@@ -336,10 +450,18 @@=0A=
         int                     index;  /* Port index on the card =
*/=0A=
         int                     hwif;   /* Line hardware =
(lineInterface copy) */=0A=
         int                     run;    /* Port is running */=0A=
+        int                     mode;    /* Normal or FarSync raw =
*/=0A=
         int                     rxpos;  /* Next Rx buffer to use */=0A=
         int                     txpos;  /* Next Tx buffer to use */=0A=
         int                     txipos; /* Next Tx buffer to check for =
free */=0A=
-        int                     txcnt;  /* Count of Tx buffers in use =
*/=0A=
+        int                     start;  /* Indication of start/stop to =
network */=0A=
+  /*=0A=
+   * A sixteen entry transmit queue=0A=
+   */=0A=
+        int                     txqs;  /* index to get next buffer to =
tx */=0A=
+        int                     txqe;  /* index to queue next packet =
*/=0A=
+        struct sk_buff         *txq[FST_TXQ_DEPTH]; /* The queue */=0A=
+        int                     rxqdepth;=0A=
 };=0A=
 =0A=
 /*      Per card information=0A=
@@ -357,6 +479,24 @@=0A=
         unsigned short pci_conf;        /* PCI card config in I/O =
space */=0A=
                                         /* Per port info */=0A=
         struct fst_port_info ports[ FST_MAX_PORTS ];=0A=
+        struct pci_dev *device;         /* Information about the pci =
device */=0A=
+        int            card_no;         /* Inst of the card on the =
system */=0A=
+        int            family;          /* TxP or TxU */=0A=
+        int            dmarx_in_progress;=0A=
+        int            dmatx_in_progress;=0A=
+        unsigned long  int_count;=0A=
+        unsigned long  int_time_ave;=0A=
+	void          *rx_dma_handle_host;=0A=
+	dma_addr_t     rx_dma_handle_card;  =0A=
+	void          *tx_dma_handle_host;=0A=
+	dma_addr_t     tx_dma_handle_card;  =0A=
+        struct sk_buff *dma_skb_rx;=0A=
+        struct fst_port_info *dma_port_rx;=0A=
+        struct fst_port_info *dma_port_tx;=0A=
+        int            dma_len_rx;=0A=
+        int            dma_len_tx;=0A=
+        int            dma_txpos;=0A=
+        int            dma_rxpos;=0A=
 };=0A=
 =0A=
 /* Convert an HDLC device pointer into a port info pointer and similar =
*/=0A=
@@ -403,7 +543,7 @@=0A=
                                 printk ( KERN_DEBUG FST_NAME ": " fmt, =
## A )=0A=
 =0A=
 #else=0A=
-# define dbg(X...)      /* NOP */=0A=
+#define dbg(X...)      /* NOP */=0A=
 #endif=0A=
 =0A=
 =0A=
@@ -422,12 +562,131 @@=0A=
                                         FST_TYPE_T2P },=0A=
         { FSC_PCI_VENDOR_ID, T4P_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
                                         FST_TYPE_T4P },=0A=
+        { FSC_PCI_VENDOR_ID, T1U_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
+                                        FST_TYPE_T1U },=0A=
+        { FSC_PCI_VENDOR_ID, T2U_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
+                                        FST_TYPE_T2U },=0A=
+        { FSC_PCI_VENDOR_ID, T4U_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
+                                        FST_TYPE_T4U },=0A=
+        { FSC_PCI_VENDOR_ID, TE1_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
+                                        FST_TYPE_TE1 },=0A=
+        { FSC_PCI_VENDOR_ID, TE1C_PCI_DEVICE_ID, PCI_ANY_ID, =
PCI_ANY_ID, 0, 0,=0A=
+                                        FST_TYPE_TE1 },=0A=
         { 0, }                          /* End */=0A=
 };=0A=
 =0A=
 MODULE_DEVICE_TABLE ( pci, fst_pci_dev_id );=0A=
 =0A=
 =0A=
+/*=0A=
+ *      Device Driver Work Queues=0A=
+ *=0A=
+ *      So that we don't spend too much time processing events in the =
=0A=
+ *      Interrupt Service routine, we will declare a work queue per =
Card =0A=
+ *      and make the ISR schedule a task in the queue for later =
execution.=0A=
+ */=0A=
+=0A=
+static void do_bottom_half_tx (struct fst_card_info *card);=0A=
+static void do_bottom_half_rx (struct fst_card_info *card);=0A=
+=0A=
+struct tq_struct      fst_int_task;=0A=
+struct tq_struct      fst_tx_task;=0A=
+struct fst_card_info *fst_card_array[FST_MAX_CARDS];=0A=
+spinlock_t            fst_work_q_lock;=0A=
+u64                   fst_work_txq;=0A=
+u64                   fst_work_intq;=0A=
+=0A=
+static void=0A=
+fst_q_work_item (u64 *queue, int card_index)=0A=
+{=0A=
+  unsigned long  flags;=0A=
+  u64            mask;=0A=
+=0A=
+  /*=0A=
+   * Grab the queue exclusively=0A=
+   */=0A=
+  spin_lock_irqsave(&fst_work_q_lock, flags);=0A=
+=0A=
+  /*=0A=
+   * Making an entry in the queue is simply a matter of setting=0A=
+   * a bit for the card indicating that there is work to do in the=0A=
+   * bottom half for the card.  Note the limitation of 64 cards.=0A=
+   * That ought to be enough=0A=
+   */=0A=
+  mask =3D 1 << card_index;=0A=
+  *queue |=3D mask; =0A=
+  spin_unlock_irqrestore(&fst_work_q_lock, flags);=0A=
+}=0A=
+=0A=
+=0A=
+static void=0A=
+fst_process_tx_work_q ( void *work_q)=0A=
+{=0A=
+  unsigned long  flags;=0A=
+  u64            work_txq;=0A=
+  int            i;=0A=
+=0A=
+  /*=0A=
+   * Grab the queue exclusively=0A=
+   */=0A=
+  dbg(DBG_TX, "fst_process_tx_work_q\n");=0A=
+  spin_lock_irqsave(&fst_work_q_lock, flags);=0A=
+  work_txq =3D fst_work_txq;=0A=
+  fst_work_txq =3D 0;=0A=
+  spin_unlock_irqrestore(&fst_work_q_lock, flags);=0A=
+=0A=
+  /*=0A=
+   * Call the bottom half for each card with work waiting=0A=
+   */=0A=
+  for (i=3D0; i<FST_MAX_CARDS; i++)=0A=
+    {=0A=
+      if (work_txq & 0x01)=0A=
+        {=0A=
+          if (fst_card_array[i] !=3D NULL)=0A=
+            {=0A=
+              dbg(DBG_TX, "Calling tx bh for card %d\n", i);=0A=
+              do_bottom_half_tx(fst_card_array[i]);=0A=
+            }=0A=
+        }=0A=
+      work_txq =3D work_txq>>1;=0A=
+    }=0A=
+}=0A=
+=0A=
+static void=0A=
+fst_process_int_work_q ( void *work_q)=0A=
+{=0A=
+  unsigned long  flags;=0A=
+  u64            work_intq;=0A=
+  int            i;=0A=
+=0A=
+  /*=0A=
+   * Grab the queue exclusively=0A=
+   */=0A=
+  dbg(DBG_INTR, "fst_process_int_work_q\n");=0A=
+  spin_lock_irqsave(&fst_work_q_lock, flags);=0A=
+  work_intq =3D fst_work_intq;=0A=
+  fst_work_intq =3D 0;=0A=
+  spin_unlock_irqrestore(&fst_work_q_lock, flags);=0A=
+=0A=
+  /*=0A=
+   * Call the bottom half for each card with work waiting=0A=
+   */=0A=
+  for (i=3D0; i<FST_MAX_CARDS; i++)=0A=
+    {=0A=
+      if (work_intq & 0x01)=0A=
+        {=0A=
+          if (fst_card_array[i] !=3D NULL)=0A=
+            {=0A=
+              dbg(DBG_INTR,"Calling rx & tx bh for card %d\n", i);=0A=
+              do_bottom_half_rx(fst_card_array[i]);=0A=
+              do_bottom_half_tx(fst_card_array[i]);=0A=
+            }=0A=
+        }=0A=
+      work_intq =3D work_intq>>1;=0A=
+    }=0A=
+}=0A=
+=0A=
+=0A=
 /*      Card control functions=0A=
  *      =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A=
  */=0A=
@@ -436,17 +695,55 @@=0A=
  * Used to be a simple write to card control space but a glitch in the =
latest=0A=
  * AMD Am186CH processor means that we now have to do it by asserting =
and de-=0A=
  * asserting the PLX chip PCI Adapter Software Reset. Bit 30 in CNTRL =
register=0A=
- * at offset 0x50.=0A=
+ * at offset 9052_CNTRL.  Note the updates for the TXU.=0A=
  */=0A=
 static inline void=0A=
 fst_cpureset ( struct fst_card_info *card )=0A=
 {=0A=
+        unsigned char interrupt_line_register;=0A=
+	unsigned long j =3D jiffies + 1;=0A=
         unsigned int regval;=0A=
 =0A=
-        regval =3D inl ( card->pci_conf + 0x50 );=0A=
-=0A=
-        outl ( regval |  0x40000000, card->pci_conf + 0x50 );=0A=
-        outl ( regval & ~0x40000000, card->pci_conf + 0x50 );=0A=
+ 	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    if (pci_read_config_byte(card->device, PCIILR, =
&interrupt_line_register))=0A=
+	      {=0A=
+		dbg (DBG_ASS, "Error in reading interrupt line register\n");=0A=
+	      }=0A=
+	    /*=0A=
+	     * Assert PLX software reset and Am186 hardware reset=0A=
+	     * and then deassert the PLX software reset but 186 still in =
reset=0A=
+	     */=0A=
+	    outw ( 0x440f, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	    outw ( 0x040f, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	    /*=0A=
+	     * We are delaying here to allow the 9054 to reset itself=0A=
+	     */=0A=
+	    j =3D jiffies + 1;=0A=
+	    while (jiffies < j)=0A=
+	      /* Do nothing */;=0A=
+	    outw ( 0x240f, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	    /*=0A=
+	     * We are delaying here to allow the 9054 to reload its eeprom=0A=
+	     */=0A=
+	    j =3D jiffies + 1;=0A=
+	    while (jiffies < j)=0A=
+	      /* Do nothing */;=0A=
+	    outw ( 0x040f, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	    =0A=
+	    if (pci_write_config_byte(card->device, PCIILR, =
interrupt_line_register))=0A=
+	      {=0A=
+		dbg (DBG_ASS, "Error in writing interrupt line register\n");=0A=
+	      }=0A=
+	    =0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    regval =3D inl ( card->pci_conf + CNTRL_9052 );=0A=
+=0A=
+	    outl ( regval |  0x40000000, card->pci_conf + CNTRL_9052 );=0A=
+	    outl ( regval & ~0x40000000, card->pci_conf + CNTRL_9052 );=0A=
+	  }=0A=
 }=0A=
 =0A=
 /*      Release the processor from reset=0A=
@@ -454,7 +751,24 @@=0A=
 static inline void=0A=
 fst_cpurelease ( struct fst_card_info *card )=0A=
 {=0A=
-        (void) readb ( card->ctlmem );=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    /*=0A=
+	     * Force posted writes to complete=0A=
+	     */=0A=
+	    (void) readb (card->mem);=0A=
+=0A=
+	    /*=0A=
+	     * Release LRESET DO =3D 1=0A=
+	     * Then release Local Hold, DO =3D 1=0A=
+	     */=0A=
+	    outw ( 0x040e, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	    outw ( 0x040f, card->pci_conf + CNTRL_9054 + 2 );=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    (void) readb ( card->ctlmem );=0A=
+	  }=0A=
 }=0A=
 =0A=
 /*      Clear the cards interrupt flag=0A=
@@ -462,9 +776,31 @@=0A=
 static inline void=0A=
 fst_clear_intr ( struct fst_card_info *card )=0A=
 {=0A=
-        /* Poke the appropriate PLX chip register (same as enabling =
interrupts)=0A=
-         */=0A=
-        outw ( 0x0543, card->pci_conf + 0x4C );=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    (void) readb ( card->ctlmem );=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    /* Poke the appropriate PLX chip register (same as enabling =
interrupts)=0A=
+	     */=0A=
+	    outw ( 0x0543, card->pci_conf + INTCSR_9052 );=0A=
+	  }=0A=
+}=0A=
+=0A=
+/*      Enable card interrupts=0A=
+ */=0A=
+static inline void=0A=
+fst_enable_intr ( struct fst_card_info *card )=0A=
+{=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    outl ( 0x0f0c0900, card->pci_conf + INTCSR_9054 );=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    outw ( 0x0543, card->pci_conf + INTCSR_9052 );=0A=
+	  }=0A=
 }=0A=
 =0A=
 /*      Disable card interrupts=0A=
@@ -472,7 +808,196 @@=0A=
 static inline void=0A=
 fst_disable_intr ( struct fst_card_info *card )=0A=
 {=0A=
-        outw ( 0x0000, card->pci_conf + 0x4C );=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    outl ( 0x00000000, card->pci_conf + INTCSR_9054 );=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    outw ( 0x0000, card->pci_conf + INTCSR_9052 );=0A=
+	  }=0A=
+}=0A=
+=0A=
+/*      Process the result of trying to pass a recieved frame up the =
stack=0A=
+ */=0A=
+static void fst_process_rx_status ( int rx_status , char *name)=0A=
+{=0A=
+  switch (rx_status)=0A=
+    {=0A=
+    case NET_RX_SUCCESS:=0A=
+      {=0A=
+	/*=0A=
+	 * Nothing to do here=0A=
+	 */=0A=
+	break;=0A=
+      }=0A=
+=0A=
+    case NET_RX_CN_LOW:=0A=
+      {=0A=
+	printk_warn("%s: Receive Low Congestion\n", name);=0A=
+	break;=0A=
+      }=0A=
+=0A=
+    case NET_RX_CN_MOD:=0A=
+      {=0A=
+	printk_warn("%s: Receive Moderate Congestion\n", name);=0A=
+	break;=0A=
+      }=0A=
+=0A=
+    case NET_RX_CN_HIGH:=0A=
+      {=0A=
+	printk_warn("%s: Receive High Congestion\n", name);=0A=
+	break;=0A=
+      }=0A=
+=0A=
+    case NET_RX_DROP:=0A=
+      {=0A=
+	printk_err("%s: Received packet dropped\n", name);=0A=
+	break;=0A=
+      }=0A=
+    }=0A=
+}=0A=
+=0A=
+=0A=
+/*      Initilaise DMA for PLX 9054=0A=
+ */=0A=
+static inline void=0A=
+fst_init_dma ( struct fst_card_info *card )=0A=
+{=0A=
+  unsigned short pci_cr;=0A=
+=0A=
+  /*=0A=
+   * This is only required for the PLX 9054=0A=
+   */=0A=
+  if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+    {=0A=
+      pci_read_config_word (card->device, PCICR, &pci_cr);=0A=
+      pci_cr |=3D 0x0004;=0A=
+      pci_write_config_word (card->device, PCICR, pci_cr);  /* Enable =
DMA Bus mastering */=0A=
+      outl ( 0x00020441, card->pci_conf + DMAMODE0 );=0A=
+      outl ( 0x00020441, card->pci_conf + DMAMODE1 );=0A=
+      outl ( 0x0, card->pci_conf + DMATHR );=0A=
+    }=0A=
+}=0A=
+=0A=
+=0A=
+/*      Tx dma complete interrupt=0A=
+ */=0A=
+static void=0A=
+fst_tx_dma_complete ( struct fst_card_info *card, struct fst_port_info =
*port, =0A=
+		      int len, int txpos)=0A=
+{=0A=
+	/*=0A=
+	 * Everything is now set, just tell the card to go=0A=
+	 */=0A=
+        dbg(DBG_TX, "fst_tx_dma_complete\n");=0A=
+	FST_WRB ( card, txDescrRing[port->index][txpos].bits, =0A=
+		  DMA_OWN | TX_STP | TX_ENP );=0A=
+	port->hdlc.stats.tx_packets++;=0A=
+	port->hdlc.stats.tx_bytes +=3D len;=0A=
+	port_to_dev(port)->trans_start =3D jiffies;=0A=
+}=0A=
+=0A=
+/*      Rx dma complete interrupt=0A=
+ */=0A=
+static void=0A=
+fst_rx_dma_complete ( struct fst_card_info *card, struct fst_port_info =
*port,=0A=
+		      int len, struct sk_buff *skb, int rxp)=0A=
+{=0A=
+    =0A=
+        int pi;=0A=
+	int rx_status;=0A=
+=0A=
+        dbg(DBG_TX, "fst_rx_dma_complete\n");=0A=
+	pi =3D port->index;=0A=
+	memcpy(skb_put(skb, len), card->rx_dma_handle_host, len);=0A=
+=0A=
+	/* Reset buffer descriptor */=0A=
+        FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
+=0A=
+        /* Update stats */=0A=
+        port->hdlc.stats.rx_packets++;=0A=
+        port->hdlc.stats.rx_bytes +=3D len;=0A=
+=0A=
+        /* Push upstream */=0A=
+        dbg(DBG_RX, "Pushing the frame up the stack\n");=0A=
+        skb->mac.raw =3D skb->data;=0A=
+        skb->dev =3D hdlc_to_dev(&port->hdlc);=0A=
+        if (port->mode =3D=3D FST_RAW)=0A=
+          {=0A=
+            /*=0A=
+             * Mark it for our own raw sockets interface=0A=
+             */=0A=
+            skb->protocol =3D htons (ETH_P_CUST);=0A=
+            skb->pkt_type =3D PACKET_HOST;=0A=
+          }=0A=
+        else=0A=
+          {=0A=
+            skb->protocol =3D hdlc_type_trans (skb, skb->dev);=0A=
+          }=0A=
+        rx_status =3D netif_rx ( skb );=0A=
+        fst_process_rx_status(rx_status, port_to_dev(port)->name);=0A=
+        if (rx_status =3D=3D NET_RX_DROP)=0A=
+          port->hdlc.stats.rx_dropped++;=0A=
+	port_to_dev(port)->last_rx =3D jiffies;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *      Receive a frame through the DMA=0A=
+ */=0A=
+static inline void=0A=
+fst_rx_dma (struct fst_card_info *card, unsigned char *skb, =0A=
+	    unsigned char *mem, int len)=0A=
+{=0A=
+  /*=0A=
+   * This routine will setup the DMA and start it=0A=
+   */=0A=
+=0A=
+  dbg(DBG_RX, "In fst_rx_dma %p %p %d\n", skb, mem, len);=0A=
+  if (card->dmarx_in_progress)=0A=
+    {=0A=
+      dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");=0A=
+    }=0A=
+=0A=
+  outl ( (unsigned long)skb, card->pci_conf + DMAPADR0 );   /* Copy to =
here */=0A=
+  outl ( (unsigned long)mem, card->pci_conf + DMALADR0 );   /* from =
here */=0A=
+  outl ( len, card->pci_conf + DMASIZ0 );       /* for this length =
*/=0A=
+  outl ( 0x00000000c, card->pci_conf + DMADPR0); /* In this direction =
*/=0A=
+=0A=
+  /*=0A=
+   * We use the dmarx_in_progress flag to flag the channel as busy=0A=
+   */=0A=
+  card->dmarx_in_progress =3D 1;=0A=
+  outb ( 0x03, card->pci_conf + DMACSR0 );     /* Start the transfer =
*/=0A=
+}=0A=
+=0A=
+/*=0A=
+ *      Send a frame through the DMA=0A=
+ */=0A=
+static inline void=0A=
+fst_tx_dma (struct fst_card_info *card, unsigned char *skb, =0A=
+	    unsigned char *mem, int len)=0A=
+{=0A=
+  /*=0A=
+   * This routine will setup the DMA and start it.=0A=
+   */=0A=
+=0A=
+  dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);=0A=
+  if (card->dmatx_in_progress)=0A=
+    {=0A=
+      dbg(DBG_ASS, "In fst_tx_dma while dma in progress\n");=0A=
+    }=0A=
+=0A=
+  outl ( (unsigned long)skb, card->pci_conf + DMAPADR1 );  /* Copy =
from here */=0A=
+  outl ( (unsigned long)mem, card->pci_conf + DMALADR1 );  /* to here =
*/=0A=
+  outl ( len, card->pci_conf + DMASIZ1 );       /* for this length =
*/=0A=
+  outl ( 0x000000004, card->pci_conf + DMADPR1); /* In this direction =
*/=0A=
+=0A=
+  /*=0A=
+   * We use the dmatx_in_progress to flag the channel as busy=0A=
+   */=0A=
+  card->dmatx_in_progress =3D 1;=0A=
+  outb ( 0x03, card->pci_conf + DMACSR1 );     /* Start the transfer =
*/=0A=
 }=0A=
 =0A=
 =0A=
@@ -496,11 +1021,11 @@=0A=
         /* Wait for any previous command to complete */=0A=
         while ( mbval > NAK )=0A=
         {=0A=
-                spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
+	        spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
                 schedule_timeout ( 1 );=0A=
                 spin_lock_irqsave ( &card->card_lock, flags );=0A=
 =0A=
-                if ( ++safety > 1000 )=0A=
+                if ( ++safety > 2000 )=0A=
                 {=0A=
                         printk_err ("Mailbox safety timeout\n");=0A=
                         break;=0A=
@@ -523,7 +1048,7 @@=0A=
         {=0A=
                 port->txpos  =3D 0;=0A=
                 port->txipos =3D 0;=0A=
-                port->txcnt  =3D 0;=0A=
+                port->start  =3D 0;=0A=
         }=0A=
 =0A=
         spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
@@ -576,7 +1101,7 @@=0A=
                 FST_WRB ( card, rxDescrRing[pi][i].hadr, (u8)( offset =
>> 16 ));=0A=
                 FST_WRW ( card, rxDescrRing[pi][i].bcnt,=0A=
                                         cnv_bcnt ( LEN_RX_BUFFER =
));=0A=
-                FST_WRW ( card, rxDescrRing[pi][i].mcnt, 0 );=0A=
+                FST_WRW ( card, rxDescrRing[pi][i].mcnt, LEN_RX_BUFFER =
);=0A=
                 FST_WRB ( card, rxDescrRing[pi][i].bits, DMA_OWN );=0A=
         }=0A=
         port->rxpos  =3D 0;=0A=
@@ -610,11 +1135,63 @@=0A=
         }=0A=
         port->txpos  =3D 0;=0A=
         port->txipos =3D 0;=0A=
-        port->txcnt  =3D 0;=0A=
+        port->start  =3D 0;=0A=
         spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
 }=0A=
 =0A=
 =0A=
+/*      TE1 Alarm change interrupt event=0A=
+ */=0A=
+static void=0A=
+fst_intr_te1_alarm ( struct fst_card_info *card, struct fst_port_info =
*port )=0A=
+{=0A=
+  u8 los;=0A=
+  u8 rra;=0A=
+  u8 ais;=0A=
+=0A=
+  los =3D FST_RDB ( card, suStatus.lossOfSignal );=0A=
+  rra =3D FST_RDB ( card, suStatus.receiveRemoteAlarm );=0A=
+  ais =3D FST_RDB ( card, suStatus.alarmIndicationSignal );=0A=
+=0A=
+  if ( los )=0A=
+    {=0A=
+      /*=0A=
+       * Lost the link=0A=
+       */=0A=
+      if (netif_carrier_ok(port_to_dev(port)))=0A=
+        {=0A=
+          dbg ( DBG_INTR,"Net carrier off\n");=0A=
+          netif_carrier_off(port_to_dev(port));=0A=
+        }    =0A=
+    }=0A=
+  else=0A=
+    {=0A=
+      /*=0A=
+       * Link available=0A=
+       */=0A=
+      if ( ! netif_carrier_ok(port_to_dev(port)))=0A=
+        {=0A=
+          dbg ( DBG_INTR,"Net carrier on\n");  =0A=
+          netif_carrier_on(port_to_dev(port));=0A=
+        }=0A=
+    }=0A=
+=0A=
+  if (los)=0A=
+    dbg (DBG_INTR, "Assert LOS Alarm\n");=0A=
+  else=0A=
+    dbg (DBG_INTR, "De-assert LOS Alarm\n");=0A=
+  if (rra)=0A=
+    dbg (DBG_INTR, "Assert RRA Alarm\n");=0A=
+  else=0A=
+    dbg (DBG_INTR, "De-assert RRA Alarm\n");=0A=
+=0A=
+  if (ais)=0A=
+    dbg (DBG_INTR, "Assert AIS Alarm\n");=0A=
+  else=0A=
+    dbg (DBG_INTR, "De-assert AIS Alarm\n");=0A=
+}=0A=
+=0A=
+=0A=
 /*      Control signal change interrupt event=0A=
  */=0A=
 static void=0A=
@@ -624,7 +1201,8 @@=0A=
 =0A=
         signals =3D FST_RDL ( card, v24DebouncedSts[port->index]);=0A=
 =0A=
-        if ( signals & (( port->hwif =3D=3D X21 ) ? IPSTS_INDICATE : =
IPSTS_DCD ))=0A=
+        if ( signals & (((port->hwif =3D=3D X21) || (port->hwif =3D=3D =
X21D)) =0A=
+			? IPSTS_INDICATE : IPSTS_DCD ))=0A=
         {=0A=
                 if ( ! netif_carrier_ok ( port_to_dev ( port )))=0A=
                 {=0A=
@@ -642,6 +1220,86 @@=0A=
         }=0A=
 }=0A=
 =0A=
+/*      Log Rx Errors=0A=
+ */=0A=
+static void=0A=
+fst_log_rx_error ( struct fst_card_info *card, struct fst_port_info =
*port,=0A=
+		   unsigned char dmabits, int rxp, unsigned short len)=0A=
+{=0A=
+        /* =0A=
+	 * Increment the appropriate error counter=0A=
+	 */=0A=
+         port->hdlc.stats.rx_errors++;=0A=
+         if ( dmabits & RX_OFLO )=0A=
+           {=0A=
+             port->hdlc.stats.rx_fifo_errors++;=0A=
+	     dbg(DBG_ASS, "Rx fifo error on card %d port %d buffer %d\n", =0A=
+		 card->card_no, port->index, rxp);=0A=
+            }=0A=
+          if ( dmabits & RX_CRC )=0A=
+            {=0A=
+              port->hdlc.stats.rx_crc_errors++;=0A=
+	      dbg(DBG_ASS, "Rx crc error on card %d port %d\n",=0A=
+		  card->card_no, port->index);=0A=
+            }=0A=
+          if ( dmabits & RX_FRAM )=0A=
+            {=0A=
+              port->hdlc.stats.rx_frame_errors++;=0A=
+	      dbg(DBG_ASS, "Rx frame error on card %d port %d\n",=0A=
+		  card->card_no, port->index);=0A=
+            }=0A=
+          if ( dmabits =3D=3D ( RX_STP | RX_ENP ))=0A=
+            {=0A=
+              port->hdlc.stats.rx_length_errors++;=0A=
+	      dbg(DBG_ASS, "Rx length error (%d) on card %d port %d\n", =0A=
+	          len,card->card_no, port->index);=0A=
+            }=0A=
+}=0A=
+=0A=
+/*      Rx Error Recovery=0A=
+ */=0A=
+static void=0A=
+fst_recover_rx_error ( struct fst_card_info *card, struct =
fst_port_info *port,=0A=
+		   unsigned char dmabits, int rxp, unsigned short len)=0A=
+{=0A=
+        int i;=0A=
+	int pi;=0A=
+=0A=
+        pi  =3D port->index;=0A=
+	/* =0A=
+	 * Discard buffer descriptors until we see the start of the=0A=
+	 * next frame.  Note that for long frames this could be in=0A=
+	 * a subsequent interrupt. =0A=
+	 */=0A=
+	i =3D 0;=0A=
+	while (( dmabits & ( DMA_OWN | RX_STP )) =3D=3D 0 )=0A=
+	  {=0A=
+	    FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
+	    if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
+	      rxp =3D 0;=0A=
+	    if ( ++i > NUM_RX_BUFFER )=0A=
+	      {=0A=
+		dbg ( DBG_ASS,"intr_rx: Discarding more bufs"=0A=
+		      " than we have\n");=0A=
+		break;=0A=
+	      }=0A=
+	    dmabits =3D FST_RDB ( card, rxDescrRing[pi][rxp].bits );=0A=
+	    dbg(DBG_ASS, "DMA Bits of next buffer was %x\n", dmabits);=0A=
+	  }=0A=
+	dbg(DBG_ASS, "There were %d subsequent buffers in error\n", i);=0A=
+	=0A=
+	/* Discard the terminal buffer */=0A=
+	if ( ! ( dmabits & DMA_OWN ))=0A=
+	  {=0A=
+	    FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
+	    if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
+	      rxp =3D 0;=0A=
+	  }=0A=
+	port->rxpos =3D rxp;=0A=
+	return;=0A=
+	=0A=
+}=0A=
+=0A=
 =0A=
 /*      Rx complete interrupt=0A=
  */=0A=
@@ -651,10 +1309,9 @@=0A=
         unsigned char dmabits;=0A=
         int pi;=0A=
         int rxp;=0A=
+	int rx_status;=0A=
         unsigned short len;=0A=
         struct sk_buff *skb;=0A=
-        int i;=0A=
-=0A=
 =0A=
         /* Check we have a buffer to process */=0A=
         pi  =3D port->index;=0A=
@@ -666,11 +1323,32 @@=0A=
                                         pi, rxp );=0A=
                 return;=0A=
         }=0A=
+	if (card->dmarx_in_progress)=0A=
+	{=0A=
+	        return;=0A=
+	}=0A=
 =0A=
         /* Get buffer length */=0A=
         len =3D FST_RDW ( card, rxDescrRing[pi][rxp].mcnt );=0A=
         /* Discard the CRC */=0A=
         len -=3D 2;=0A=
+	if (len =3D=3D 0)=0A=
+	  {=0A=
+	    /*=0A=
+	     * This seems to happen on the TE1 interface sometimes=0A=
+	     * so throw the frame away and log the event.=0A=
+	     */=0A=
+	    printk_err("Frame received with 0 length. Card %d Port %d\n",=0A=
+		        card->card_no, port->index);=0A=
+	    /* Return descriptor to card */=0A=
+	    FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
+	    =0A=
+	    if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
+	      port->rxpos =3D 0;=0A=
+	    else=0A=
+	      port->rxpos =3D rxp;=0A=
+	    return;=0A=
+	  }=0A=
 =0A=
         /* Check buffer length and for other errors. We insist on one =
packet=0A=
          * in one buffer. This simplifies things greatly and since =
we've=0A=
@@ -680,53 +1358,9 @@=0A=
                                         len );=0A=
         if ( dmabits !=3D ( RX_STP | RX_ENP ) || len > LEN_RX_BUFFER - =
2 )=0A=
         {=0A=
-                port->hdlc.stats.rx_errors++;=0A=
-=0A=
-                /* Update error stats and discard buffer */=0A=
-                if ( dmabits & RX_OFLO )=0A=
-                {=0A=
-                        port->hdlc.stats.rx_fifo_errors++;=0A=
-                }=0A=
-                if ( dmabits & RX_CRC )=0A=
-                {=0A=
-                        port->hdlc.stats.rx_crc_errors++;=0A=
-                }=0A=
-                if ( dmabits & RX_FRAM )=0A=
-                {=0A=
-                        port->hdlc.stats.rx_frame_errors++;=0A=
-                }=0A=
-                if ( dmabits =3D=3D ( RX_STP | RX_ENP ))=0A=
-                {=0A=
-                        port->hdlc.stats.rx_length_errors++;=0A=
-                }=0A=
-=0A=
-                /* Discard buffer descriptors until we see the end of =
packet=0A=
-                 * marker=0A=
-                 */=0A=
-                i =3D 0;=0A=
-                while (( dmabits & ( DMA_OWN | RX_ENP )) =3D=3D 0 )=0A=
-                {=0A=
-                        FST_WRB ( card, rxDescrRing[pi][rxp].bits, =
DMA_OWN );=0A=
-                        if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
-                                rxp =3D 0;=0A=
-                        if ( ++i > NUM_RX_BUFFER )=0A=
-                        {=0A=
-                                dbg ( DBG_ASS,"intr_rx: Discarding =
more bufs"=0A=
-                                                " than we have\n");=0A=
-                                break;=0A=
-                        }=0A=
-                        dmabits =3D FST_RDB ( card, =
rxDescrRing[pi][rxp].bits );=0A=
-                }=0A=
-=0A=
-                /* Discard the terminal buffer */=0A=
-                if ( ! ( dmabits & DMA_OWN ))=0A=
-                {=0A=
-                        FST_WRB ( card, rxDescrRing[pi][rxp].bits, =
DMA_OWN );=0A=
-                        if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
-                                rxp =3D 0;=0A=
-                }=0A=
-                port->rxpos =3D rxp;=0A=
-                return;=0A=
+	     fst_log_rx_error(card, port, dmabits, rxp, len);=0A=
+	     fst_recover_rx_error(card, port, dmabits, rxp, len);=0A=
+	     return;=0A=
         }=0A=
 =0A=
         /* Allocate SKB */=0A=
@@ -746,28 +1380,210 @@=0A=
                 return;=0A=
         }=0A=
 =0A=
-        memcpy_fromio ( skb_put ( skb, len ),=0A=
-                                card->mem + BUF_OFFSET ( =
rxBuffer[pi][rxp][0]),=0A=
-                                len );=0A=
+	/*=0A=
+	 * We know the length we need to receive, len.=0A=
+	 * It's not worth using the DMA for reads of less than=0A=
+	 * FST_MIN_DMA_LEN=0A=
+	 */=0A=
+=0A=
+	if ((len < FST_MIN_DMA_LEN) || (card->family =3D=3D =
FST_FAMILY_TXP))=0A=
+	  {=0A=
+		memcpy_fromio ( skb_put ( skb, len ),=0A=
+				card->mem + BUF_OFFSET ( rxBuffer[pi][rxp][0]),=0A=
+				len );=0A=
+=0A=
+		/* Reset buffer descriptor */=0A=
+		FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
+=0A=
+		/* Update stats */=0A=
+		port->hdlc.stats.rx_packets++;=0A=
+		port->hdlc.stats.rx_bytes +=3D len;=0A=
+		=0A=
+		/* Push upstream */=0A=
+                dbg(DBG_RX, "Pushing frame up the stack\n");=0A=
+		skb->mac.raw =3D skb->data;=0A=
+		skb->dev =3D hdlc_to_dev (&port->hdlc);=0A=
+                if (port->mode =3D=3D FST_RAW)=0A=
+                  {=0A=
+                    /*=0A=
+                     * Mark it for our own raw sockets interface=0A=
+                     */=0A=
+                    skb->protocol =3D htons (ETH_P_CUST);=0A=
+                    skb->pkt_type =3D PACKET_HOST;=0A=
+                  }=0A=
+                else=0A=
+                  {=0A=
+                    skb->protocol =3D hdlc_type_trans (skb, =
skb->dev);=0A=
+                  }=0A=
+		rx_status =3D netif_rx ( skb );=0A=
+                fst_process_rx_status( rx_status, =
port_to_dev(port)->name );=0A=
+                if (rx_status =3D=3D NET_RX_DROP)=0A=
+                  {=0A=
+                    port->hdlc.stats.rx_dropped++;=0A=
+                  }=0A=
+		port_to_dev (port)->last_rx =3D jiffies;=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    card->dma_skb_rx =3D skb;=0A=
+	    card->dma_port_rx =3D port;=0A=
+	    card->dma_len_rx =3D len;=0A=
+	    card->dma_rxpos =3D rxp;=0A=
+	    fst_rx_dma(card, (char*)card->rx_dma_handle_card, =0A=
+		       (char*)BUF_OFFSET(rxBuffer[pi][rxp][0]), =0A=
+		       len);=0A=
+	  }=0A=
+	if (rxp !=3D port->rxpos)=0A=
+	  {=0A=
+	    dbg(DBG_ASS, "About to increment rxpos by more than 1\n");=0A=
+	    dbg(DBG_ASS, "rxp =3D %d rxpos =3D %d\n", rxp, port->rxpos);=0A=
+	  }=0A=
+	if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
+	  port->rxpos =3D 0;=0A=
+	else=0A=
+	  port->rxpos =3D rxp;=0A=
+}=0A=
 =0A=
-        /* Reset buffer descriptor */=0A=
-        FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );=0A=
-        if ( ++rxp >=3D NUM_RX_BUFFER )=0A=
-                port->rxpos =3D 0;=0A=
-        else=0A=
-                port->rxpos =3D rxp;=0A=
 =0A=
-        /* Update stats */=0A=
-        port->hdlc.stats.rx_packets++;=0A=
-        port->hdlc.stats.rx_bytes +=3D len;=0A=
+/*=0A=
+ *      The bottom halfs to the ISR=0A=
+ *=0A=
+ */=0A=
 =0A=
-        /* Push upstream */=0A=
-        skb->mac.raw =3D skb->data;=0A=
-        skb->dev =3D hdlc_to_dev ( &port->hdlc );=0A=
-        skb->protocol =3D hdlc_type_trans(skb, skb->dev);=0A=
-        netif_rx ( skb );=0A=
+static void do_bottom_half_tx (struct fst_card_info *card)=0A=
+{=0A=
+  struct fst_port_info *port;=0A=
+  int pi;=0A=
+  int txq_length;=0A=
+  struct sk_buff *skb;=0A=
+  unsigned long flags;=0A=
+=0A=
+  /*=0A=
+   *  Find a free buffer for the transmit=0A=
+   *  Step through each port on this card=0A=
+   */=0A=
+=0A=
+  dbg(DBG_TX, "do_bottom_half_tx\n");=0A=
+  for ( pi =3D 0, port =3D card->ports ; pi < card->nports ; pi++, =
port++ )=0A=
+    {=0A=
+      if ( ! port->run )=0A=
+	continue;=0A=
+=0A=
+      while (!(FST_RDB ( card, txDescrRing[pi][port->txpos].bits ) & =
DMA_OWN)=0A=
+	     && !(card->dmatx_in_progress))=0A=
+	{=0A=
+	  /*=0A=
+	   * There doesn't seem to be a txdone event per-se=0A=
+	   * We seem to have to deduce it, by checking the DMA_OWN=0A=
+	   * bit on the next buffer we think we can use=0A=
+	   */=0A=
+	  spin_lock_irqsave ( &card->card_lock, flags );=0A=
+	  if ((txq_length =3D port->txqe - port->txqs) < 0)=0A=
+	    {=0A=
+	      /*=0A=
+	       * This is the case where one has wrapped and the=0A=
+	       * maths gives us a negative number=0A=
+	       */=0A=
+	      txq_length =3D txq_length + FST_TXQ_DEPTH ;=0A=
+	    }=0A=
+	  spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
+	  if (txq_length > 0)=0A=
+	    {=0A=
+	      /*=0A=
+	       * There is something to send=0A=
+	       */=0A=
+	      spin_lock_irqsave ( &card->card_lock, flags );=0A=
+	      skb =3D port->txq[port->txqs];=0A=
+	      port->txqs++;=0A=
+	      if (port->txqs =3D=3D FST_TXQ_DEPTH)=0A=
+		{=0A=
+		  port->txqs =3D 0;=0A=
+		}=0A=
+	      spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
+	      /*=0A=
+	       * copy the data and set the required indicators on the=0A=
+	       * card.=0A=
+	       */=0A=
+	      FST_WRW ( card, txDescrRing[pi][port->txpos].bcnt, cnv_bcnt ( =
skb->len ));=0A=
+	      if ((skb->len < FST_MIN_DMA_LEN) || (card->family =3D=3D =
FST_FAMILY_TXP))=0A=
+		{=0A=
+	          /* Enqueue the packet with normal io*/=0A=
+	          memcpy_toio ( card->mem + BUF_OFFSET ( =
txBuffer[pi][port->txpos][0]),=0A=
+		                skb->data, skb->len );=0A=
+		  FST_WRB ( card, txDescrRing[pi][port->txpos].bits, DMA_OWN | =
TX_STP | TX_ENP );=0A=
+		  port->hdlc.stats.tx_packets++;=0A=
+		  port->hdlc.stats.tx_bytes +=3D skb->len;=0A=
+		  port_to_dev(port)->trans_start =3D jiffies;=0A=
+		}=0A=
+	      else=0A=
+		{=0A=
+	          /* Or do it through dma */=0A=
+	          memcpy(card->tx_dma_handle_host, skb->data, skb->len);=0A=
+		  card->dma_port_tx =3D port;=0A=
+		  card->dma_len_tx =3D skb->len;=0A=
+		  card->dma_txpos =3D port->txpos;=0A=
+	          fst_tx_dma(card, (char*)card->tx_dma_handle_card, =0A=
+		             (char*)BUF_OFFSET(txBuffer[pi][port->txpos][0]), =0A=
+		             skb->len);=0A=
+	        }=0A=
+	      if ( ++port->txpos >=3D NUM_TX_BUFFER )=0A=
+		port->txpos =3D 0;=0A=
+	      /*=0A=
+	       * If we have flow control on, can we now release it?=0A=
+	       */=0A=
+	      if (port->start)=0A=
+		{=0A=
+		  if (txq_length < fst_txq_low)=0A=
+		    {=0A=
+		      netif_wake_queue ( port_to_dev(port) );=0A=
+		      port->start =3D 0;=0A=
+		    }=0A=
+		}=0A=
+	      dev_kfree_skb ( skb );=0A=
+	    }=0A=
+	  else=0A=
+	    {=0A=
+	      /*=0A=
+	       * Nothing to send so break out of the while loop=0A=
+	       */=0A=
+	      break;=0A=
+	    }=0A=
+	}=0A=
+    }=0A=
+}=0A=
 =0A=
-        port_to_dev ( port )->last_rx =3D jiffies;=0A=
+static void do_bottom_half_rx (struct fst_card_info *card)=0A=
+{=0A=
+  struct fst_port_info *port;=0A=
+  int pi;=0A=
+  int rx_count=3D0;=0A=
+=0A=
+  /* Check for rx completions on all ports on this card */=0A=
+  dbg(DBG_RX, "do_bottom_half_rx\n");=0A=
+  for ( pi =3D 0, port =3D card->ports ; pi < card->nports ; pi++, =
port++ )=0A=
+    {=0A=
+      //rx_count =3D 0;=0A=
+      if ( ! port->run )=0A=
+	continue;=0A=
+      while (!( FST_RDB ( card, rxDescrRing[pi][port->rxpos].bits )=0A=
+		& DMA_OWN ) && !(card->dmarx_in_progress))=0A=
+	{=0A=
+	  if (rx_count > fst_max_reads)=0A=
+	    {=0A=
+	      /*=0A=
+	       * Don't spend forever in receive processing=0A=
+	       * Schedule another event=0A=
+	       */=0A=
+              fst_q_work_item(&fst_work_intq, card->card_no);=0A=
+	      queue_task(&fst_int_task, &tq_immediate); =0A=
+	      mark_bh(IMMEDIATE_BH); /* Note that this call must follow =
queue_task */=0A=
+	      //pi =3D card->nports;=0A=
+	      break;  /* Leave the loop */=0A=
+	    }=0A=
+	  fst_intr_rx ( card, port );=0A=
+	  rx_count++;=0A=
+	}=0A=
+    }=0A=
 }=0A=
 =0A=
 =0A=
@@ -783,7 +1599,9 @@=0A=
         int rdidx;                      /* Event buffer indices */=0A=
         int wridx;=0A=
         int event;                      /* Actual event for processing =
*/=0A=
-        int pi;=0A=
+	unsigned int dma_intcsr=3D0;=0A=
+	unsigned int do_card_interrupt;=0A=
+	unsigned int int_retry_count;=0A=
 =0A=
         if (( card =3D dev_id ) =3D=3D NULL )=0A=
         {=0A=
@@ -791,100 +1609,160 @@=0A=
                 return;=0A=
         }=0A=
 =0A=
+	/*=0A=
+	 * Check to see if the interrupt was for this card=0A=
+	 * return if not=0A=
+	 * Note that the call to clear the interrupt is important=0A=
+	 */=0A=
         dbg ( DBG_INTR,"intr: %d %p\n", irq, card );=0A=
-=0A=
-        spin_lock ( &card->card_lock );=0A=
+	if (card->state !=3D FST_RUNNING)=0A=
+	  {=0A=
+	    printk_err("Interrupt received for card %d in a non running state =
(%d)\n", card->card_no, card->state);=0A=
+=0A=
+	    /* =0A=
+	     * It is possible to really be running, i.e. we have re-loaded=0A=
+	     * a running card=0A=
+	     * Clear and reprime the interrupt source =0A=
+	     */=0A=
+	    fst_clear_intr ( card );=0A=
+	    return;=0A=
+	  }=0A=
 =0A=
         /* Clear and reprime the interrupt source */=0A=
         fst_clear_intr ( card );=0A=
 =0A=
-        /* Set the software acknowledge */=0A=
-        FST_WRB ( card, interruptHandshake, 0xEE );=0A=
-=0A=
+	/*=0A=
+	 * Is the interrupt for this card (handshake =3D=3D 1)=0A=
+	 */=0A=
+	do_card_interrupt =3D 0;=0A=
+	if (FST_RDB( card, interruptHandshake) =3D=3D 1)=0A=
+	  {=0A=
+	    do_card_interrupt +=3D FST_CARD_INT;=0A=
+	    /* Set the software acknowledge */=0A=
+	    FST_WRB ( card, interruptHandshake, 0xEE );=0A=
+	  }=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    /*=0A=
+	     * Is it a DMA Interrupt=0A=
+	     */=0A=
+	    dma_intcsr =3D inl (card->pci_conf + INTCSR_9054);=0A=
+	    if (dma_intcsr & 0x00200000)=0A=
+	      {=0A=
+		/*=0A=
+		 * DMA Channel 0 (Rx transfer complete)=0A=
+		 */=0A=
+		dbg(DBG_RX, "DMA Rx xfer complete\n");=0A=
+		outb( 0x8, card->pci_conf + DMACSR0);=0A=
+		fst_rx_dma_complete (card, card->dma_port_rx, card->dma_len_rx,=0A=
+				     card->dma_skb_rx, card->dma_rxpos);=0A=
+		card->dmarx_in_progress =3D 0;=0A=
+		do_card_interrupt +=3D FST_RX_DMA_INT;=0A=
+	      }=0A=
+	    if (dma_intcsr & 0x00400000)=0A=
+	      {=0A=
+		/*=0A=
+		 * DMA Channel 1 (Tx transfer complete)=0A=
+		 */=0A=
+		dbg(DBG_TX, "DMA Tx xfer complete\n");=0A=
+		outb( 0x8, card->pci_conf + DMACSR1);=0A=
+		fst_tx_dma_complete (card, card->dma_port_tx, card->dma_len_tx,=0A=
+				     card->dma_txpos);=0A=
+                card->dmatx_in_progress =3D 0;=0A=
+		do_card_interrupt +=3D FST_TX_DMA_INT;=0A=
+	      }=0A=
+	  }=0A=
+	=0A=
+	/*=0A=
+	 * Have we been missing Interrupts=0A=
+	 */=0A=
+	int_retry_count =3D FST_RDL( card, interruptRetryCount);=0A=
+	if (int_retry_count)=0A=
+	  {=0A=
+	    dbg(DBG_ASS, "Card %d int_retry_count is  %d\n", =0A=
+                card->card_no, int_retry_count);=0A=
+	    FST_WRL( card, interruptRetryCount, 0);=0A=
+	  }=0A=
+=0A=
+	if (!do_card_interrupt)=0A=
+	  {=0A=
+	    return;=0A=
+	  }=0A=
+=0A=
+	/* Scehdule the bottom half of the ISR */=0A=
+        fst_q_work_item(&fst_work_intq, card->card_no);=0A=
+	queue_task(&fst_int_task, &tq_immediate); =0A=
+	mark_bh(IMMEDIATE_BH); /* Note that this call must follow =0A=
+				  queue_task */=0A=
+	=0A=
         /* Drain the event queue */=0A=
-        rdidx =3D FST_RDB ( card, interruptEvent.rdindex );=0A=
-        wridx =3D FST_RDB ( card, interruptEvent.wrindex );=0A=
+        rdidx =3D FST_RDB ( card, interruptEvent.rdindex ) & 0x1f;=0A=
+        wridx =3D FST_RDB ( card, interruptEvent.wrindex ) & 0x1f;=0A=
         while ( rdidx !=3D wridx )=0A=
-        {=0A=
-                event =3D FST_RDB ( card, =
interruptEvent.evntbuff[rdidx]);=0A=
-=0A=
-                port =3D &card->ports[event & 0x03];=0A=
-=0A=
-                dbg ( DBG_INTR,"intr: %x\n", event );=0A=
-=0A=
+	  {=0A=
+	    event =3D FST_RDB ( card, interruptEvent.evntbuff[rdidx]);=0A=
+	    port =3D &card->ports[event & 0x03];=0A=
+	    =0A=
+                dbg ( DBG_INTR,"Processing Interrupt event: %x\n", =
event );=0A=
+		=0A=
                 switch ( event )=0A=
-                {=0A=
-                case CTLA_CHG:=0A=
-                case CTLB_CHG:=0A=
-                case CTLC_CHG:=0A=
-                case CTLD_CHG:=0A=
-                        if ( port->run )=0A=
-                                fst_intr_ctlchg ( card, port );=0A=
-                        break;=0A=
-=0A=
-                case ABTA_SENT:=0A=
-                case ABTB_SENT:=0A=
-                case ABTC_SENT:=0A=
-                case ABTD_SENT:=0A=
-                        dbg ( DBG_TX,"Abort complete port %d\n", event =
& 0x03 );=0A=
-                        break;=0A=
-=0A=
-                case TXA_UNDF:=0A=
-                case TXB_UNDF:=0A=
-                case TXC_UNDF:=0A=
-                case TXD_UNDF:=0A=
-                        /* Difficult to see how we'd get this given =
that we=0A=
-                         * always load up the entire packet for =
DMA.=0A=
-                         */=0A=
-                        dbg ( DBG_TX,"Tx underflow port %d\n", event & =
0x03 );=0A=
-                        port->hdlc.stats.tx_errors++;=0A=
-                        port->hdlc.stats.tx_fifo_errors++;=0A=
-                        break;=0A=
-=0A=
-                case INIT_CPLT:=0A=
-                        dbg ( DBG_INIT,"Card init OK intr\n");=0A=
-                        break;=0A=
-=0A=
-                case INIT_FAIL:=0A=
-                        dbg ( DBG_INIT,"Card init FAILED intr\n");=0A=
-                        card->state =3D FST_IFAILED;=0A=
-                        break;=0A=
-=0A=
-                default:=0A=
-                        printk_err ("intr: unknown card event code. =
ignored\n");=0A=
-                        break;=0A=
+		  {=0A=
+		  case TE1_ALMA:=0A=
+		    dbg ( DBG_INTR,"TE1 Alarm intr\n");=0A=
+                    if ( port->run )=0A=
+                      fst_intr_te1_alarm (card, port);=0A=
+                    break;=0A=
+		    		    =0A=
+		  case CTLA_CHG:=0A=
+		  case CTLB_CHG:=0A=
+		  case CTLC_CHG:=0A=
+		  case CTLD_CHG:=0A=
+		    if ( port->run )=0A=
+		      fst_intr_ctlchg ( card, port );=0A=
+		    break;=0A=
+		    =0A=
+		  case ABTA_SENT:=0A=
+		  case ABTB_SENT:=0A=
+		  case ABTC_SENT:=0A=
+		  case ABTD_SENT:=0A=
+		    dbg (DBG_TX,"Abort complete port %d\n", port->index );=0A=
+		    break;=0A=
+		    =0A=
+		  case TXA_UNDF:=0A=
+		  case TXB_UNDF:=0A=
+		  case TXC_UNDF:=0A=
+		  case TXD_UNDF:=0A=
+		    /* Difficult to see how we'd get this given that we=0A=
+		     * always load up the entire packet for DMA.=0A=
+		     */=0A=
+		    dbg (DBG_TX,"Tx underflow port %d\n", port->index );=0A=
+		    =0A=
+		    port->hdlc.stats.tx_errors++;=0A=
+		    port->hdlc.stats.tx_fifo_errors++;=0A=
+		    dbg(DBG_ASS, "Tx underflow on card %d port %d\n",=0A=
+			card->card_no, port->index);=0A=
+		    break;=0A=
+=0A=
+		  case INIT_CPLT:=0A=
+		    dbg ( DBG_INIT,"Card init OK intr\n");=0A=
+		    break;=0A=
+		    =0A=
+		  case INIT_FAIL:=0A=
+		    dbg ( DBG_INIT,"Card init FAILED intr\n");=0A=
+		    card->state =3D FST_IFAILED;=0A=
+		    break;=0A=
+		    =0A=
+		  default:=0A=
+		    printk_err ("intr: unknown card event %d. ignored\n",=0A=
+                                event);=0A=
+		    break;=0A=
                 }=0A=
-=0A=
+		=0A=
                 /* Bump and wrap the index */=0A=
                 if ( ++rdidx >=3D MAX_CIRBUFF )=0A=
-                        rdidx =3D 0;=0A=
-        }=0A=
+		  rdidx =3D 0;=0A=
+	  }=0A=
         FST_WRB ( card, interruptEvent.rdindex, rdidx );=0A=
-=0A=
-        for ( pi =3D 0, port =3D card->ports ; pi < card->nports ; =
pi++, port++ )=0A=
-        {=0A=
-                if ( ! port->run )=0A=
-                        continue;=0A=
-=0A=
-                /* Check for rx completions */=0A=
-                while ( ! ( FST_RDB ( card, =
rxDescrRing[pi][port->rxpos].bits )=0A=
-                                                                & =
DMA_OWN ))=0A=
-                {=0A=
-                        fst_intr_rx ( card, port );=0A=
-                }=0A=
-=0A=
-                /* Check for Tx completions */=0A=
-                while ( port->txcnt > 0 && ! ( FST_RDB ( card,=0A=
-                        txDescrRing[pi][port->txipos].bits ) & DMA_OWN =
))=0A=
-                {=0A=
-                        --port->txcnt;=0A=
-                        if ( ++port->txipos >=3D NUM_TX_BUFFER )=0A=
-                                port->txipos =3D 0;=0A=
-                        netif_wake_queue ( port_to_dev ( port ));=0A=
-                }=0A=
-        }=0A=
-=0A=
-        spin_unlock ( &card->card_lock );=0A=
 }=0A=
 =0A=
 =0A=
@@ -934,9 +1812,9 @@=0A=
          */=0A=
         if ( FST_RDL ( card, numberOfPorts ) !=3D card->nports )=0A=
         {=0A=
-                printk_warn ("Port count mismatch."=0A=
-                                " Firmware thinks %d we say %d\n",=0A=
-                                FST_RDL ( card, numberOfPorts ), =
card->nports );=0A=
+                printk_warn ("Port count mismatch on card %d."=0A=
+                             " Firmware thinks %d we say %d\n", =
card->card_no,=0A=
+                              FST_RDL ( card, numberOfPorts ), =
card->nports );=0A=
         }=0A=
 }=0A=
 =0A=
@@ -946,24 +1824,89 @@=0A=
                 struct fstioc_info *info )=0A=
 {=0A=
         int err;=0A=
+	unsigned char my_framing;=0A=
 =0A=
-        /* Set things according to the user set valid flags.=0A=
-         * Several of the old options have been invalidated/replaced =
by the=0A=
-         * generic HDLC package.=0A=
-         */=0A=
+        /* Set things according to the user set valid flags =0A=
+	 * Several of the old options have been invalidated/replaced by the =
=0A=
+	 * generic hdlc package.=0A=
+	 */=0A=
         err =3D 0;=0A=
         if ( info->valid & FSTVAL_PROTO )=0A=
-                err =3D -EINVAL;=0A=
+          {=0A=
+            if (info->proto =3D=3D FST_RAW)=0A=
+              port->mode =3D FST_RAW;=0A=
+            else=0A=
+              port->mode =3D FST_GEN_HDLC;=0A=
+          }=0A=
+=0A=
         if ( info->valid & FSTVAL_CABLE )=0A=
-                err =3D -EINVAL;=0A=
+	        err =3D -EINVAL;=0A=
+=0A=
         if ( info->valid & FSTVAL_SPEED )=0A=
-                err =3D -EINVAL;=0A=
+	        err =3D -EINVAL;=0A=
 =0A=
+        if ( info->valid & FSTVAL_PHASE )=0A=
+                FST_WRB ( card, =
portConfig[port->index].invertClock,=0A=
+                                        info->invertClock );=0A=
         if ( info->valid & FSTVAL_MODE )=0A=
                 FST_WRW ( card, cardMode, info->cardMode );=0A=
+        if ( info->valid & FSTVAL_TE1 )=0A=
+        {=0A=
+                FST_WRL ( card, suConfig.dataRate, info->lineSpeed =
);=0A=
+                FST_WRB ( card, suConfig.clocking, info->clockSource =
);=0A=
+		my_framing =3D FRAMING_E1;=0A=
+		if (info->framing =3D=3D E1)=0A=
+		  my_framing =3D FRAMING_E1;=0A=
+		if (info->framing =3D=3D T1)=0A=
+		  my_framing =3D FRAMING_T1;=0A=
+		if (info->framing =3D=3D J1)=0A=
+		  my_framing =3D FRAMING_J1;=0A=
+		FST_WRB ( card, suConfig.framing,  my_framing );=0A=
+                FST_WRB ( card, suConfig.structure, info->structure =
);=0A=
+                FST_WRB ( card, suConfig.interface, info->interface =
);=0A=
+                FST_WRB ( card, suConfig.coding, info->coding );=0A=
+                FST_WRB ( card, suConfig.lineBuildOut, =
info->lineBuildOut );=0A=
+                FST_WRB ( card, suConfig.equalizer, info->equalizer =
);=0A=
+                FST_WRB ( card, suConfig.transparentMode, =
info->transparentMode );=0A=
+                FST_WRB ( card, suConfig.loopMode, info->loopMode =
);=0A=
+                FST_WRB ( card, suConfig.range, info->range );=0A=
+                FST_WRB ( card, suConfig.txBufferMode, =
info->txBufferMode );=0A=
+                FST_WRB ( card, suConfig.rxBufferMode, =
info->rxBufferMode );=0A=
+                FST_WRB ( card, suConfig.startingSlot, =
info->startingSlot );=0A=
+                FST_WRB ( card, suConfig.losThreshold, =
info->losThreshold );=0A=
+		if (info->idleCode)=0A=
+		  FST_WRB ( card, suConfig.enableIdleCode, 1 );=0A=
+		else=0A=
+		  FST_WRB ( card, suConfig.enableIdleCode, 0 );=0A=
+		FST_WRB ( card, suConfig.idleCode, info->idleCode );=0A=
+#if FST_DEBUG=0A=
+                if ( info->valid & FSTVAL_TE1 )=0A=
+                  {=0A=
+                    printk("Setting TE1 data\n");=0A=
+                    printk("Line Speed =3D %d\n", info->lineSpeed);=0A=
+                    printk("Start slot =3D %d\n", =
info->startingSlot);=0A=
+                    printk("Clock source =3D %d\n", =
info->clockSource);=0A=
+                    printk("Framing =3D %d\n", my_framing);=0A=
+                    printk("Structure =3D %d\n", info->structure);=0A=
+                    printk("interface =3D %d\n", info->interface);=0A=
+                    printk("Coding =3D %d\n", info->coding);=0A=
+                    printk("Line build out =3D %d\n", =
info->lineBuildOut);=0A=
+                    printk("Equaliser =3D %d\n", info->equalizer);=0A=
+                    printk("Transparent mode =3D %d\n", =
info->transparentMode);=0A=
+                    printk("Loop mode =3D %d\n", info->loopMode);=0A=
+                    printk("Range =3D %d\n", info->range);=0A=
+                    printk("Tx Buffer mode =3D %d\n", =
info->txBufferMode);=0A=
+                    printk("Rx Buffer mode =3D %d\n", =
info->rxBufferMode);=0A=
+                    printk("LOS Threshold =3D %d\n", =
info->losThreshold);=0A=
+		    printk("Idle Code =3D %d\n", info->idleCode);=0A=
+                  }=0A=
+#endif=0A=
+        }=0A=
 #if FST_DEBUG=0A=
         if ( info->valid & FSTVAL_DEBUG )=0A=
+        {=0A=
                 fst_debug_mask =3D info->debug;=0A=
+        }=0A=
 #endif=0A=
 =0A=
         return err;=0A=
@@ -978,6 +1921,7 @@=0A=
         memset ( info, 0, sizeof ( struct fstioc_info ));=0A=
 =0A=
         i =3D port->index;=0A=
+        info->kernelVersion =3D LINUX_VERSION_CODE;=0A=
         info->nports =3D card->nports;=0A=
         info->type   =3D card->type;=0A=
         info->state  =3D card->state;=0A=
@@ -1000,12 +1944,69 @@=0A=
         info->lineInterface =3D FST_RDW ( card, =
portConfig[i].lineInterface );=0A=
         info->internalClock =3D FST_RDB ( card, =
portConfig[i].internalClock );=0A=
         info->lineSpeed     =3D FST_RDL ( card, =
portConfig[i].lineSpeed );=0A=
+	info->invertClock   =3D FST_RDB ( card, portConfig[i].invertClock =
);=0A=
         info->v24IpSts      =3D FST_RDL ( card, v24IpSts[i] );=0A=
         info->v24OpSts      =3D FST_RDL ( card, v24OpSts[i] );=0A=
         info->clockStatus   =3D FST_RDW ( card, clockStatus[i] );=0A=
         info->cableStatus   =3D FST_RDW ( card, cableStatus );=0A=
         info->cardMode      =3D FST_RDW ( card, cardMode );=0A=
         info->smcFirmwareVersion  =3D FST_RDL ( card, =
smcFirmwareVersion );=0A=
+=0A=
+	/*=0A=
+	 * The T2U can report cable presence for both A or B=0A=
+	 * in bits 0 and 1 of cableStatus.  See which port we are and =0A=
+	 * do the mapping.=0A=
+	 */=0A=
+ 	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    if (port->index =3D=3D 0)=0A=
+	      {=0A=
+		/*=0A=
+		 * Port A=0A=
+		 */=0A=
+		info->cableStatus =3D info->cableStatus & 1;=0A=
+	      }=0A=
+	    else=0A=
+	      {=0A=
+		/*=0A=
+		 * Port B=0A=
+		 */=0A=
+		info->cableStatus =3D info->cableStatus >> 1;=0A=
+		info->cableStatus =3D info->cableStatus & 1;=0A=
+	      }=0A=
+          }=0A=
+        /*=0A=
+         * Some additional bits if we are TE1=0A=
+         */=0A=
+        if (card->type =3D=3D FST_TYPE_TE1)=0A=
+          {=0A=
+            info->lineSpeed =3D FST_RDL ( card, suConfig.dataRate =
);=0A=
+            info->clockSource =3D FST_RDB ( card, suConfig.clocking =
);=0A=
+            info->framing =3D FST_RDB ( card, suConfig.framing );=0A=
+            info->structure =3D FST_RDB ( card, suConfig.structure =
);=0A=
+            info->interface =3D FST_RDB ( card, suConfig.interface =
);=0A=
+            info->coding =3D FST_RDB ( card, suConfig.coding );=0A=
+            info->lineBuildOut =3D FST_RDB ( card, =
suConfig.lineBuildOut );=0A=
+            info->equalizer =3D FST_RDB ( card, suConfig.equalizer =
);=0A=
+            info->loopMode =3D FST_RDB ( card, suConfig.loopMode ); =
=0A=
+            info->range =3D FST_RDB ( card, suConfig.range ); =0A=
+            info->txBufferMode =3D FST_RDB ( card, =
suConfig.txBufferMode ); =0A=
+            info->rxBufferMode =3D FST_RDB ( card, =
suConfig.rxBufferMode ); =0A=
+            info->startingSlot =3D FST_RDB ( card, =
suConfig.startingSlot ); =0A=
+            info->losThreshold =3D FST_RDB ( card, =
suConfig.losThreshold );=0A=
+	    if (FST_RDB (card, suConfig.enableIdleCode ))=0A=
+	      info->idleCode =3D  FST_RDB ( card, suConfig.idleCode );=0A=
+	    else=0A=
+	      info->idleCode =3D 0 ; =0A=
+            info->receiveBufferDelay =3D FST_RDL ( card, =
suStatus.receiveBufferDelay );=0A=
+            info->framingErrorCount =3D FST_RDL ( card, =
suStatus.framingErrorCount ); =0A=
+            info->codeViolationCount =3D FST_RDL ( card, =
suStatus.codeViolationCount ); =0A=
+            info->crcErrorCount =3D FST_RDL ( card, =
suStatus.crcErrorCount );=0A=
+            info->lineAttenuation =3D FST_RDL ( card, =
suStatus.lineAttenuation );=0A=
+            info->lossOfSignal =3D FST_RDB ( card, =
suStatus.lossOfSignal );=0A=
+            info->receiveRemoteAlarm =3D FST_RDB ( card, =
suStatus.receiveRemoteAlarm );=0A=
+            info->alarmIndicationSignal =3D FST_RDB ( card, =
suStatus.alarmIndicationSignal );=0A=
+          }=0A=
 }=0A=
 =0A=
 =0A=
@@ -1016,16 +2017,22 @@=0A=
         sync_serial_settings sync;=0A=
         int i;=0A=
 =0A=
-        if (copy_from_user (&sync, ifr->ifr_settings.ifs_ifsu.sync,=0A=
-			    sizeof (sync)))=0A=
+        if ( ifr->ifr_settings.size !=3D sizeof ( sync ))=0A=
+        {=0A=
+                return -ENOMEM;=0A=
+        }=0A=
+=0A=
+        if ( copy_from_user ( &sync, ifr->ifr_settings.ifs_ifsu.sync, =
sizeof ( sync )))=0A=
+        {=0A=
                 return -EFAULT;=0A=
+        }=0A=
 =0A=
         if ( sync.loopback )=0A=
                 return -EINVAL;=0A=
 =0A=
         i =3D port->index;=0A=
 =0A=
-        switch (ifr->ifr_settings.type)=0A=
+        switch ( ifr->ifr_settings.type )=0A=
         {=0A=
         case IF_IFACE_V35:=0A=
                 FST_WRW ( card, portConfig[i].lineInterface, V35 );=0A=
@@ -1042,6 +2049,21 @@=0A=
                 port->hwif =3D X21;=0A=
                 break;=0A=
 =0A=
+        case IF_IFACE_X21D:=0A=
+                FST_WRW ( card, portConfig[i].lineInterface, X21D =
);=0A=
+                port->hwif =3D X21D;=0A=
+                break;=0A=
+=0A=
+        case IF_IFACE_T1:=0A=
+                FST_WRW ( card, portConfig[i].lineInterface, T1 );=0A=
+                port->hwif =3D T1;=0A=
+                break;=0A=
+=0A=
+        case IF_IFACE_E1:=0A=
+                FST_WRW ( card, portConfig[i].lineInterface, E1 );=0A=
+                port->hwif =3D E1;=0A=
+                break;=0A=
+=0A=
         case IF_IFACE_SYNC_SERIAL:=0A=
                 break;=0A=
 =0A=
@@ -1079,33 +2101,48 @@=0A=
          */=0A=
         switch ( port->hwif )=0A=
         {=0A=
+        case E1:=0A=
+                ifr->ifr_settings.type =3D IF_IFACE_E1;=0A=
+                break;=0A=
+        case T1:=0A=
+                ifr->ifr_settings.type =3D IF_IFACE_T1;=0A=
+                break;=0A=
         case V35:=0A=
                 ifr->ifr_settings.type =3D IF_IFACE_V35;=0A=
                 break;=0A=
         case V24:=0A=
                 ifr->ifr_settings.type =3D IF_IFACE_V24;=0A=
                 break;=0A=
+        case X21D:=0A=
+                ifr->ifr_settings.type =3D IF_IFACE_X21D;=0A=
+                break;=0A=
         case X21:=0A=
         default:=0A=
                 ifr->ifr_settings.type =3D IF_IFACE_X21;=0A=
                 break;=0A=
         }=0A=
-=0A=
-	if (ifr->ifr_settings.size < sizeof(sync)) {=0A=
-		ifr->ifr_settings.size =3D sizeof(sync); /* data size wanted */=0A=
-		return -ENOBUFS;=0A=
-	}=0A=
+        if ( ifr->ifr_settings.size =3D=3D 0 )=0A=
+        {=0A=
+                return 0;       /* only type requested */=0A=
+        }=0A=
+        if ( ifr->ifr_settings.size < sizeof ( sync ))=0A=
+        {=0A=
+                return -ENOMEM;=0A=
+        }=0A=
 =0A=
         i =3D port->index;=0A=
         sync.clock_rate =3D FST_RDL ( card, portConfig[i].lineSpeed =
);=0A=
         /* Lucky card and linux use same encoding here */=0A=
-        sync.clock_type =3D FST_RDB ( card, =
portConfig[i].internalClock );=0A=
+        sync.clock_type =3D FST_RDB ( card, =
portConfig[i].internalClock ) =3D=3D=0A=
+                                    INTCLK ? CLOCK_INT : CLOCK_EXT;=0A=
         sync.loopback =3D 0;=0A=
 =0A=
-        if (copy_to_user (ifr->ifr_settings.ifs_ifsu.sync, &sync,=0A=
-			  sizeof(sync)))=0A=
+        if ( copy_to_user ( ifr->ifr_settings.ifs_ifsu.sync, &sync, =
sizeof ( sync )))=0A=
+        {=0A=
                 return -EFAULT;=0A=
+        }=0A=
 =0A=
+        ifr->ifr_settings.size =3D sizeof ( sync );=0A=
         return 0;=0A=
 }=0A=
 =0A=
@@ -1196,7 +2233,7 @@=0A=
                         if ( card->state =3D=3D FST_RUNNING )=0A=
                         {=0A=
                                 spin_lock_irqsave ( &card->card_lock, =
flags );=0A=
-                                fst_clear_intr ( card );=0A=
+                                fst_enable_intr ( card );=0A=
                                 FST_WRB ( card, interruptHandshake, =
0xEE );=0A=
                                 spin_unlock_irqrestore ( =
&card->card_lock,=0A=
                                                                 flags =
);=0A=
@@ -1218,9 +2255,16 @@=0A=
 =0A=
         case FSTSETCONF:=0A=
 =0A=
-                /* Most of the setting have been moved to the generic =
ioctls=0A=
-                 * this just covers debug and board ident mode now=0A=
-                 */=0A=
+		/*=0A=
+		 * Most of the settings have been moved to the generic ioctls=0A=
+		 * this just covers debug and board ident now=0A=
+		 */=0A=
+=0A=
+                if(card->state !=3D FST_RUNNING)=0A=
+	        {=0A=
+		  printk_err("Attempt to configure card %d in non-running state =
(%d)\n", card->card_no, card->state);=0A=
+	                return -EIO;=0A=
+	        }=0A=
                 if ( copy_from_user ( &info,  ifr->ifr_data, sizeof ( =
info )))=0A=
                 {=0A=
                         return -EFAULT;=0A=
@@ -1229,7 +2273,7 @@=0A=
                 return set_conf_from_info ( card, port, &info );=0A=
 =0A=
         case SIOCWANDEV:=0A=
-                switch (ifr->ifr_settings.type)=0A=
+	        switch ( ifr->ifr_settings.type )=0A=
                 {=0A=
                 case IF_GET_IFACE:=0A=
                         return fst_get_iface ( card, port, ifr );=0A=
@@ -1238,10 +2282,28 @@=0A=
                 case IF_IFACE_V35:=0A=
                 case IF_IFACE_V24:=0A=
                 case IF_IFACE_X21:=0A=
+		case IF_IFACE_X21D:=0A=
+                case IF_IFACE_T1:=0A=
+                case IF_IFACE_E1:=0A=
                         return fst_set_iface ( card, port, ifr );=0A=
 =0A=
+                case IF_PROTO_RAW:=0A=
+                  port->mode =3D FST_RAW;=0A=
+                  return 0;=0A=
+=0A=
+                case IF_GET_PROTO:=0A=
+                  if (port->mode =3D=3D FST_RAW)=0A=
+                    {=0A=
+                      ifr->ifr_settings.type =3D IF_PROTO_RAW;=0A=
+                      return 0;=0A=
+                    }=0A=
+                  return hdlc_ioctl ( dev, ifr, cmd );=0A=
+=0A=
                 default:=0A=
-                        return hdlc_ioctl ( dev, ifr, cmd );=0A=
+                  port->mode =3D FST_GEN_HDLC;=0A=
+                  dbg(DBG_IOCTL, "Passing this type to hdlc %x\n",=0A=
+                      ifr->ifr_settings.type);=0A=
+                  return hdlc_ioctl ( dev, ifr, cmd );=0A=
                 }=0A=
 =0A=
         default:=0A=
@@ -1255,6 +2317,7 @@=0A=
 fst_openport ( struct fst_port_info *port )=0A=
 {=0A=
         int signals;=0A=
+	int txq_length;=0A=
 =0A=
         /* Only init things if card is actually running. This allows =
open to=0A=
          * succeed for downloads etc.=0A=
@@ -1277,12 +2340,17 @@=0A=
                 port->run =3D 1;=0A=
 =0A=
                 signals =3D FST_RDL ( port->card, =
v24DebouncedSts[port->index]);=0A=
-                if ( signals & (( port->hwif =3D=3D X21 ) ? =
IPSTS_INDICATE=0A=
-                                                      : IPSTS_DCD =
))=0A=
-                        netif_carrier_on ( port_to_dev ( port ));=0A=
+                if ( signals & (((port->hwif =3D=3D X21) || =
(port->hwif =3D=3D X21D))=0A=
+				? IPSTS_INDICATE : IPSTS_DCD ))=0A=
+                        netif_carrier_on ( port_to_dev(port) );=0A=
                 else=0A=
-                        netif_carrier_off ( port_to_dev ( port ));=0A=
+                        netif_carrier_off ( port_to_dev(port) );=0A=
+=0A=
+		txq_length =3D port->txqe - port->txqs;=0A=
+		port->txqe =3D 0;=0A=
+		port->txqs =3D 0;=0A=
         }=0A=
+=0A=
 }=0A=
 =0A=
 static void=0A=
@@ -1309,14 +2377,18 @@=0A=
 fst_open ( struct net_device *dev )=0A=
 {=0A=
         int err;=0A=
+        struct fst_port_info *port;=0A=
 =0A=
-        err =3D hdlc_open ( dev_to_hdlc ( dev ));=0A=
-        if ( err )=0A=
-                return err;=0A=
-=0A=
+        port =3D dev_to_port(dev);=0A=
         MOD_INC_USE_COUNT;=0A=
+        if (port->mode !=3D FST_RAW)=0A=
+          {=0A=
+            err =3D hdlc_open ( dev_to_hdlc ( dev ));=0A=
+            if ( err )=0A=
+              return err;=0A=
+          }=0A=
 =0A=
-        fst_openport ( dev_to_port ( dev ));=0A=
+        fst_openport ( port );=0A=
         netif_wake_queue ( dev );=0A=
         return 0;=0A=
 }=0A=
@@ -1324,40 +2396,59 @@=0A=
 static int=0A=
 fst_close ( struct net_device *dev )=0A=
 {=0A=
-        netif_stop_queue ( dev );=0A=
-        fst_closeport ( dev_to_port ( dev ));=0A=
-        hdlc_close ( dev_to_hdlc  ( dev ));=0A=
+        struct fst_port_info *port;=0A=
+        struct fst_card_info *card;=0A=
+	unsigned char tx_dma_done;=0A=
+	unsigned char rx_dma_done;=0A=
+=0A=
+        port =3D dev_to_port(dev);=0A=
+	card =3D port->card;=0A=
+=0A=
+	tx_dma_done =3D inb ( card->pci_conf + DMACSR1 );=0A=
+	rx_dma_done =3D inb ( card->pci_conf + DMACSR0 );=0A=
+	dbg(DBG_OPEN, "Port Close: tx_dma_in_progress =3D %d (%x) =
rx_dma_in_progress =3D %d (%x)\n",=0A=
+	       card->dmatx_in_progress, tx_dma_done, =0A=
+	       card->dmarx_in_progress, rx_dma_done);=0A=
+=0A=
+	netif_stop_queue ( dev );=0A=
+	fst_closeport ( dev_to_port (dev) );=0A=
+        if (port->mode !=3D FST_RAW)=0A=
+          {=0A=
+            hdlc_close ( dev_to_hdlc ( dev ));=0A=
+          }=0A=
         MOD_DEC_USE_COUNT;=0A=
         return 0;=0A=
 }=0A=
 =0A=
 static int=0A=
-fst_attach ( hdlc_device *hdlc, unsigned short encoding, unsigned =
short parity )=0A=
+fst_attach ( hdlc_device *hdlc, unsigned short encoding, unsigned =
short parity)=0A=
 {=0A=
-        /* Setting currently fixed in FarSync card so we check and =
forget */=0A=
-        if ( encoding !=3D ENCODING_NRZ || parity !=3D =
PARITY_CRC16_PR1_CCITT )=0A=
-                return -EINVAL;=0A=
-        return 0;=0A=
+	/*=0A=
+	 * Setting currently fixed in FarSync card so we check and forget=0A=
+	 */=0A=
+	if ( encoding !=3D ENCODING_NRZ || parity !=3D PARITY_CRC16_PR1_CCITT =
)=0A=
+		return -EINVAL;=0A=
+	return 0;=0A=
 }=0A=
 =0A=
-=0A=
 static void=0A=
 fst_tx_timeout ( struct net_device *dev )=0A=
 {=0A=
         struct fst_port_info *port;=0A=
+        struct fst_card_info *card;=0A=
 =0A=
-        dbg ( DBG_INTR | DBG_TX,"tx_timeout\n");=0A=
-=0A=
-        port =3D dev_to_port ( dev );=0A=
+        port =3D dev_to_port (dev);=0A=
+        card =3D port->card;=0A=
 =0A=
         port->hdlc.stats.tx_errors++;=0A=
         port->hdlc.stats.tx_aborted_errors++;=0A=
-=0A=
-        if ( port->txcnt > 0 )=0A=
-                fst_issue_cmd ( port, ABORTTX );=0A=
+	dbg(DBG_ASS, "Tx timeout card %d port %d\n", =0A=
+	    card->card_no, port->index);=0A=
+        fst_issue_cmd ( port, ABORTTX );=0A=
 =0A=
         dev->trans_start =3D jiffies;=0A=
         netif_wake_queue ( dev );=0A=
+	port->start =3D 0;=0A=
 }=0A=
 =0A=
 =0A=
@@ -1366,13 +2457,12 @@=0A=
 {=0A=
         struct fst_card_info *card;=0A=
         struct fst_port_info *port;=0A=
-        unsigned char dmabits;=0A=
         unsigned long flags;=0A=
-        int pi;=0A=
-        int txp;=0A=
+	int txq_length;=0A=
 =0A=
         port =3D dev_to_port ( dev );=0A=
         card =3D port->card;=0A=
+	dbg(DBG_TX,"fst_start_xmit: length =3D %d\n", skb->len);=0A=
 =0A=
         /* Drop packet with error if we don't have carrier */=0A=
         if ( ! netif_carrier_ok ( dev ))=0A=
@@ -1380,56 +2470,74 @@=0A=
                 dev_kfree_skb ( skb );=0A=
                 port->hdlc.stats.tx_errors++;=0A=
                 port->hdlc.stats.tx_carrier_errors++;=0A=
+		dbg(DBG_ASS, "Tried to transmit but no carrier on card %d port =
%d\n",=0A=
+		    card->card_no, port->index);=0A=
                 return 0;=0A=
         }=0A=
 =0A=
         /* Drop it if it's too big! MTU failure ? */=0A=
         if ( skb->len > LEN_TX_BUFFER )=0A=
         {=0A=
-                dbg ( DBG_TX,"Packet too large %d vs %d\n", =
skb->len,=0A=
+                dbg ( DBG_ASS,"Packet too large %d vs %d\n", =
skb->len,=0A=
                                                 LEN_TX_BUFFER );=0A=
                 dev_kfree_skb ( skb );=0A=
                 port->hdlc.stats.tx_errors++;=0A=
                 return 0;=0A=
         }=0A=
 =0A=
-        /* Check we have a buffer */=0A=
-        pi =3D port->index;=0A=
+	/*=0A=
+	 * We are always going to queue the packet=0A=
+	 * so that the bottom half is the only place we tx from=0A=
+	 * Check there is room in the port txq=0A=
+	 */=0A=
         spin_lock_irqsave ( &card->card_lock, flags );=0A=
-        txp =3D port->txpos;=0A=
-        dmabits =3D FST_RDB ( card, txDescrRing[pi][txp].bits );=0A=
-        if ( dmabits & DMA_OWN )=0A=
-        {=0A=
-                spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
-                dbg ( DBG_TX,"Out of Tx buffers\n");=0A=
-                dev_kfree_skb ( skb );=0A=
-                port->hdlc.stats.tx_errors++;=0A=
-                return 0;=0A=
-        }=0A=
-        if ( ++port->txpos >=3D NUM_TX_BUFFER )=0A=
-                port->txpos =3D 0;=0A=
-=0A=
-        if ( ++port->txcnt >=3D NUM_TX_BUFFER )=0A=
-                netif_stop_queue ( dev );=0A=
-=0A=
-        /* Release the card lock before we copy the data as we now =
have=0A=
-         * exclusive access to the buffer.=0A=
-         */=0A=
-        spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
-=0A=
-        /* Enqueue the packet */=0A=
-        memcpy_toio ( card->mem + BUF_OFFSET ( =
txBuffer[pi][txp][0]),=0A=
-                                                skb->data, skb->len =
);=0A=
-        FST_WRW ( card, txDescrRing[pi][txp].bcnt, cnv_bcnt ( skb->len =
));=0A=
-        FST_WRB ( card, txDescrRing[pi][txp].bits, DMA_OWN | TX_STP | =
TX_ENP );=0A=
-=0A=
-        port->hdlc.stats.tx_packets++;=0A=
-        port->hdlc.stats.tx_bytes +=3D skb->len;=0A=
-=0A=
-        dev_kfree_skb ( skb );=0A=
+	if ((txq_length =3D port->txqe - port->txqs) < 0)=0A=
+	  {=0A=
+	    /*=0A=
+	     * This is the case where the next free has wrapped but the=0A=
+	     * last used hasn't=0A=
+	     */=0A=
+	    txq_length =3D txq_length + FST_TXQ_DEPTH;=0A=
+	  }=0A=
+	spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
+	if (txq_length > fst_txq_high)=0A=
+	  {=0A=
+	    /*=0A=
+	     * We have got enough buffers in the pipeline.  Ask the =
network=0A=
+	     * layer to stop sending frames down=0A=
+	     */=0A=
+	    netif_stop_queue ( dev );=0A=
+	    port->start =3D 1;   /* I'm using this to signal stop sent up =
*/=0A=
+	  }=0A=
+=0A=
+	if (txq_length =3D=3D FST_TXQ_DEPTH - 1)=0A=
+	  {=0A=
+	    /*=0A=
+	     * This shouldn't have happened but such is life=0A=
+	     */=0A=
+	    dev_kfree_skb ( skb );=0A=
+	    port->hdlc.stats.tx_errors++;=0A=
+	    dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",=0A=
+		card->card_no, port->index);=0A=
+	    return 0;=0A=
+	  }=0A=
+=0A=
+	/*=0A=
+	 * queue the buffer=0A=
+	 */=0A=
+        spin_lock_irqsave ( &card->card_lock, flags );=0A=
+	port->txq[port->txqe] =3D skb;=0A=
+	port->txqe++;=0A=
+	if (port->txqe =3D=3D FST_TXQ_DEPTH)=0A=
+	  port->txqe =3D 0;=0A=
+	spin_unlock_irqrestore ( &card->card_lock, flags );=0A=
+	=0A=
+	/* Scehdule the bottom half which now does transmit processing */=0A=
+        fst_q_work_item(&fst_work_txq, card->card_no);=0A=
+	queue_task(&fst_tx_task, &tq_immediate); =0A=
+	mark_bh(IMMEDIATE_BH); /* Note that this call must follow queue_task =
*/=0A=
 =0A=
-        dev->trans_start =3D jiffies;=0A=
-        return 0;=0A=
+	return 0;=0A=
 }=0A=
 =0A=
 =0A=
@@ -1443,7 +2551,11 @@=0A=
 static char *type_strings[] __devinitdata =3D {=0A=
         "no hardware",                  /* Should never be seen */=0A=
         "FarSync T2P",=0A=
-        "FarSync T4P"=0A=
+        "FarSync T4P",=0A=
+	"FarSync T1U",=0A=
+	"FarSync T2U",=0A=
+	"FarSync T4U",=0A=
+        "FarSync TE1"=0A=
 };=0A=
 =0A=
 static void __devinit=0A=
@@ -1462,22 +2574,19 @@=0A=
                 card->ports[i].card   =3D card;=0A=
                 card->ports[i].index  =3D i;=0A=
                 card->ports[i].run    =3D 0;=0A=
+                card->ports[i].mode   =3D FST_GEN_HDLC;=0A=
 =0A=
                 dev =3D hdlc_to_dev ( &card->ports[i].hdlc );=0A=
 =0A=
-                /* Fill in the net device info */=0A=
-                                /* Since this is a PCI setup this is =
purely=0A=
-                                 * informational. Give them the buffer =
addresses=0A=
-                                 * and basic card I/O.=0A=
-                                 */=0A=
+                /* Fill in the net device info =0A=
+                 * Since this is a PCI setup this is purely=0A=
+                 * informational. Give them the buffer addresses=0A=
+                 * and basic card I/O.=0A=
+                 */=0A=
                 dev->mem_start   =3D card->phys_mem=0A=
                                  + BUF_OFFSET ( txBuffer[i][0][0]);=0A=
                 dev->mem_end     =3D card->phys_mem=0A=
                                  + BUF_OFFSET ( =
txBuffer[i][NUM_TX_BUFFER][0]);=0A=
-                dev->rmem_start  =3D card->phys_mem=0A=
-                                 + BUF_OFFSET ( rxBuffer[i][0][0]);=0A=
-                dev->rmem_end    =3D card->phys_mem=0A=
-                                 + BUF_OFFSET ( =
rxBuffer[i][NUM_RX_BUFFER][0]);=0A=
                 dev->base_addr   =3D card->pci_conf;=0A=
                 dev->irq         =3D card->irq;=0A=
 =0A=
@@ -1505,6 +2614,29 @@=0A=
                         hdlc_to_dev(&card->ports[0].hdlc)->name,=0A=
                         =
hdlc_to_dev(&card->ports[card->nports-1].hdlc)->name,=0A=
                         type_strings[card->type], card->irq, =
card->nports );=0A=
+=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    /*=0A=
+	     * Allocate a dma buffer for transmit and receives=0A=
+	     */=0A=
+	    card->rx_dma_handle_host =3D =0A=
+	      pci_alloc_consistent(card->device, FST_MAX_MTU, =0A=
+				   &card->rx_dma_handle_card);=0A=
+	    if (card->rx_dma_handle_host =3D=3D NULL)=0A=
+	      {=0A=
+		printk_err("Could not allocate rx dma buffer\n");=0A=
+		return;=0A=
+	      }=0A=
+	    card->tx_dma_handle_host =3D =0A=
+	      pci_alloc_consistent(card->device, FST_MAX_MTU,=0A=
+				   &card->tx_dma_handle_card);=0A=
+	    if (card->tx_dma_handle_host =3D=3D NULL)=0A=
+	      {=0A=
+		printk_err("Could not allocate tx dma buffer\n");=0A=
+		return;=0A=
+	      }=0A=
+	  }=0A=
 }=0A=
 =0A=
 =0A=
@@ -1516,16 +2648,39 @@=0A=
 fst_add_one ( struct pci_dev *pdev, const struct pci_device_id *ent =
)=0A=
 {=0A=
         static int firsttime_done =3D 0;=0A=
+	static int no_of_cards_added =3D 0;=0A=
         struct fst_card_info *card;=0A=
         int err =3D 0;=0A=
+	int i;=0A=
 =0A=
         if ( ! firsttime_done )=0A=
         {=0A=
                 printk ( KERN_INFO "FarSync X21 driver " =
FST_USER_VERSION=0A=
-                                " (c) 2001 FarSite Communications =
Ltd.\n");=0A=
+                         " (c) 2001-2003 FarSite Communications =
Ltd.\n");=0A=
                 firsttime_done =3D 1;=0A=
+		dbg(DBG_ASS, "The value of debug mask is %x\n", fst_debug_mask);=0A=
         }=0A=
 =0A=
+	/*=0A=
+	 * We are going to be clever and allow certain cards not to be=0A=
+	 * configured.  An exclude list can be provided in =
/etc/modules.conf=0A=
+	 */=0A=
+	if (fst_excluded_cards !=3D 0)=0A=
+	  {=0A=
+	    /*=0A=
+	     * There are cards to exclude=0A=
+	     *=0A=
+	     */=0A=
+	    for (i=3D0; i< fst_excluded_cards; i++)=0A=
+	      {=0A=
+		if ((pdev->devfn)>>3 =3D=3D fst_excluded_list[i])=0A=
+		  {=0A=
+		    printk("FarSync PCI device %d not assigned\n", =
(pdev->devfn)>>3);=0A=
+		    return -EBUSY;=0A=
+		  }=0A=
+	      }=0A=
+	  }=0A=
+=0A=
         /* Allocate driver private data */=0A=
         card =3D kmalloc ( sizeof ( struct fst_card_info ),  =
GFP_KERNEL);=0A=
         if (card =3D=3D NULL)=0A=
@@ -1536,6 +2691,13 @@=0A=
         }=0A=
         memset ( card, 0, sizeof ( struct fst_card_info ));=0A=
 =0A=
+        /* Try to enable the device */=0A=
+        if (( err =3D pci_enable_device ( pdev )) !=3D 0 )=0A=
+        {=0A=
+                printk_err ("Failed to enable card. Err %d\n", -err =
);=0A=
+                goto error_free_card;=0A=
+        }=0A=
+=0A=
         /* Record info we need*/=0A=
         card->irq         =3D pdev->irq;=0A=
         card->pci_conf    =3D pci_resource_start ( pdev, 1 );=0A=
@@ -1543,9 +2705,18 @@=0A=
         card->phys_ctlmem =3D pci_resource_start ( pdev, 3 );=0A=
 =0A=
         card->type        =3D ent->driver_data;=0A=
-        card->nports      =3D ( ent->driver_data =3D=3D FST_TYPE_T2P ) =
? 2 : 4;=0A=
+	card->family       =3D (( ent->driver_data =3D=3D FST_TYPE_T2P ) =
||=0A=
+                             ( ent->driver_data =3D=3D FST_TYPE_T4P ) =
) =0A=
+	                     ? FST_FAMILY_TXP : FST_FAMILY_TXU;=0A=
+	if ( ( ent->driver_data =3D=3D FST_TYPE_T1U ) ||=0A=
+             (ent->driver_data =3D=3D FST_TYPE_TE1) )=0A=
+	  card->nports =3D 1;=0A=
+	else=0A=
+	  card->nports      =3D (( ent->driver_data =3D=3D FST_TYPE_T2P ) || =
=0A=
+			       ( ent->driver_data =3D=3D FST_TYPE_T2U) ) ? 2 : 4;=0A=
 =0A=
         card->state       =3D FST_UNINIT;=0A=
+	card->device      =3D pdev;=0A=
 =0A=
         dbg ( DBG_PCI,"type %d nports %d irq %d\n", card->type,=0A=
                         card->nports, card->irq );=0A=
@@ -1553,13 +2724,26 @@=0A=
                         card->pci_conf, card->phys_mem, =
card->phys_ctlmem );=0A=
 =0A=
         /* Check we can get access to the memory and I/O regions */=0A=
-        if ( ! request_region ( card->pci_conf, 0x80,"PLX config =
regs"))=0A=
-        {=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    if ( ! request_region ( card->pci_conf, 0x100,"PLX 9054 config =
regs"))=0A=
+	      {=0A=
+                printk_err ("Unable to get config I/O @ 0x%04X\n",=0A=
+			    card->pci_conf );=0A=
+                err =3D -ENODEV;=0A=
+                goto error_free_card;=0A=
+	      }=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+            if ( ! request_region ( card->pci_conf, 0x80,"PLX 9050/2 =
config regs"))=0A=
+              {=0A=
                 printk_err ("Unable to get config I/O @ 0x%04X\n",=0A=
                                                 card->pci_conf );=0A=
                 err =3D -ENODEV;=0A=
                 goto error_free_card;=0A=
-        }=0A=
+             }=0A=
+          }=0A=
         if ( ! request_mem_region ( card->phys_mem, =
FST_MEMSIZE,"Shared RAM"))=0A=
         {=0A=
                 printk_err ("Unable to get main memory @ 0x%08X\n",=0A=
@@ -1575,12 +2759,6 @@=0A=
                 goto error_release_mem;=0A=
         }=0A=
 =0A=
-        /* Try to enable the device */=0A=
-        if (( err =3D pci_enable_device ( pdev )) !=3D 0 )=0A=
-        {=0A=
-                printk_err ("Failed to enable card. Err %d\n", -err =
);=0A=
-                goto error_release_ctlmem;=0A=
-        }=0A=
 =0A=
         /* Get virtual addresses of memory regions */=0A=
         if (( card->mem =3D ioremap ( card->phys_mem, FST_MEMSIZE )) =
=3D=3D NULL )=0A=
@@ -1601,6 +2779,9 @@=0A=
         fst_cpureset ( card );=0A=
         card->state =3D FST_RESET;=0A=
 =0A=
+	/* Initialise DMA (if required) */=0A=
+	fst_init_dma ( card );=0A=
+=0A=
         /* Register the interrupt handler */=0A=
         if ( request_irq ( card->irq, fst_intr, SA_SHIRQ, =
FST_DEV_NAME, card ))=0A=
         {=0A=
@@ -1612,8 +2793,14 @@=0A=
 =0A=
         /* Record driver data for later use */=0A=
         pci_set_drvdata(pdev, card);=0A=
+	if (!pci_dma_supported(pdev, 0xffffffff))=0A=
+	  {=0A=
+	    printk("Can't do DMA on this device\n");=0A=
+	  }=0A=
 =0A=
         /* Remainder of card setup */=0A=
+        fst_card_array[no_of_cards_added] =3D card;=0A=
+	card->card_no =3D no_of_cards_added++;  /* Record instance and bump =
it */=0A=
         fst_init_card ( card );=0A=
 =0A=
         return 0;                       /* Success */=0A=
@@ -1665,9 +2852,28 @@=0A=
 =0A=
         release_mem_region ( card->phys_ctlmem, 0x10 );=0A=
         release_mem_region ( card->phys_mem, FST_MEMSIZE );=0A=
-        release_region ( card->pci_conf, 0x80 );=0A=
-=0A=
-        kfree ( card );=0A=
+	if (card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    release_region ( card->pci_conf, 0x100 );=0A=
+	  }=0A=
+	else=0A=
+	  {=0A=
+	    release_region ( card->pci_conf, 0x80 );=0A=
+	  }=0A=
+=0A=
+	if ( card->family =3D=3D FST_FAMILY_TXU)=0A=
+	  {=0A=
+	    /*=0A=
+	     * Free dma buffers=0A=
+	     */=0A=
+	    pci_free_consistent(card->device, FST_MAX_MTU, =0A=
+                                card->rx_dma_handle_host, =0A=
+				card->rx_dma_handle_card);=0A=
+	    pci_free_consistent(card->device, FST_MAX_MTU, =0A=
+                                card->tx_dma_handle_host, =0A=
+				card->tx_dma_handle_card);=0A=
+	  }=0A=
+        fst_card_array[card->card_no] =3D NULL;=0A=
 }=0A=
 =0A=
 static struct pci_driver fst_driver =3D {=0A=
@@ -1682,15 +2888,31 @@=0A=
 static int __init=0A=
 fst_init(void)=0A=
 {=0A=
+        int i;=0A=
+=0A=
+        for (i=3D0; i<FST_MAX_CARDS; i++)=0A=
+          fst_card_array[i] =3D NULL;=0A=
+        //INIT_WORK(&fst_int_task, fst_process_int_work_q, 0); =0A=
+        //INIT_WORK(&fst_tx_task, fst_process_tx_work_q, 0);=0A=
+        /*=0A=
+         * There must be a macro for this ????=0A=
+         */=0A=
+	memset (&fst_tx_task, 0, sizeof(struct tq_struct));=0A=
+	memset (&fst_int_task, 0, sizeof(struct tq_struct));=0A=
+	fst_int_task.data =3D 0; =0A=
+	fst_tx_task.data =3D 0;=0A=
+        fst_int_task.routine =3D fst_process_int_work_q; =0A=
+        fst_tx_task.routine =3D fst_process_tx_work_q;=0A=
+        spin_lock_init ( &fst_work_q_lock );=0A=
         return pci_module_init ( &fst_driver );=0A=
 }=0A=
 =0A=
 static void __exit=0A=
 fst_cleanup_module(void)=0A=
 {=0A=
+        printk_info ( "FarSync X21 driver unloading\n");=0A=
         pci_unregister_driver ( &fst_driver );=0A=
 }=0A=
 =0A=
 module_init ( fst_init );=0A=
 module_exit ( fst_cleanup_module );=0A=
-=0A=
diff -urN linux-2.4.25-orig/drivers/net/wan/farsync.h =
linux/drivers/net/wan/farsync.h=0A=
--- linux-2.4.25-orig/drivers/net/wan/farsync.h	2004-02-04 =
12:08:41.000000000 +0000=0A=
+++ linux/drivers/net/wan/farsync.h	2004-02-04 12:19:38.000000000 =
+0000=0A=
@@ -32,8 +32,13 @@=0A=
  *      A short common prefix is useful for routines within the driver =
to avoid=0A=
  *      conflict with other similar drivers and I chosen to use "fst_" =
for this=0A=
  *      purpose (FarSite T-series).=0A=
+ *=0A=
+ *      Finally the device driver needs a short network interface =
name. Since=0A=
+ *      "hdlc" is already in use I've chosen the even less informative =
"sync"=0A=
+ *      for the present.=0A=
  */=0A=
 #define FST_NAME                "fst"           /* In debug/info etc =
*/=0A=
+#define FST_NDEV_NAME           "sync"          /* For net interface =
*/=0A=
 #define FST_DEV_NAME            "farsync"       /* For misc interfaces =
*/=0A=
 =0A=
 =0A=
@@ -45,7 +50,7 @@=0A=
  *      have individual versions (or IDs) that move much faster than =
the=0A=
  *      the release version as individual updates are tracked.=0A=
  */=0A=
-#define FST_USER_VERSION        "0.09"=0A=
+#define FST_USER_VERSION        "1.04"=0A=
 =0A=
 =0A=
 /*      Ioctl call command values=0A=
@@ -100,6 +105,7 @@=0A=
         unsigned int   state;           /* State of card */=0A=
         unsigned int   index;           /* Index of port ioctl was =
issued on */=0A=
         unsigned int   smcFirmwareVersion;=0A=
+        unsigned long  kernelVersion;   /* What Kernel version we are =
working with */=0A=
         unsigned short lineInterface;   /* Physical interface type =
*/=0A=
         unsigned char  proto;           /* Line protocol */=0A=
         unsigned char  internalClock;   /* 1 =3D> internal clock, 0 =
=3D> external */=0A=
@@ -110,6 +116,31 @@=0A=
         unsigned short cableStatus;     /* lsb: 0=3D> present, 1=3D> =
absent */=0A=
         unsigned short cardMode;        /* lsb: LED id mode */=0A=
         unsigned short debug;           /* Debug flags */=0A=
+        unsigned char  transparentMode; /* Not used always 0 */=0A=
+        unsigned char  invertClock;     /* Invert clock feature for =
syncing */=0A=
+        unsigned char  startingSlot;    /* Time slot to use for start =
of tx */=0A=
+        unsigned char  clockSource;     /* External or internal */=0A=
+        unsigned char  framing;         /* E1, T1 or J1 */=0A=
+        unsigned char  structure;       /* unframed, double, crc4, f4, =
f12, */=0A=
+                                        /* f24 f72 */=0A=
+        unsigned char  interface;       /* rj48c or bnc */=0A=
+        unsigned char  coding;          /* hdb3 b8zs */=0A=
+        unsigned char  lineBuildOut;    /* 0, -7.5, -15, -22 */=0A=
+        unsigned char  equalizer;       /* short or lon haul settings =
*/=0A=
+        unsigned char  loopMode;        /* various loopbacks */=0A=
+        unsigned char  range;           /* cable lengths */=0A=
+        unsigned char  txBufferMode;    /* tx elastic buffer depth =
*/=0A=
+        unsigned char  rxBufferMode;    /* rx elastic buffer depth =
*/=0A=
+        unsigned char  losThreshold;    /* Attenuation on LOS signal =
*/=0A=
+        unsigned char  idleCode;        /* Value to send as idle =
timeslot */=0A=
+        unsigned int   receiveBufferDelay; /* delay thro rx buffer =
timeslots */=0A=
+        unsigned int   framingErrorCount; /* framing errors */=0A=
+        unsigned int   codeViolationCount; /* code violations */=0A=
+        unsigned int   crcErrorCount;   /* CRC errors */=0A=
+        int            lineAttenuation; /* in dB*/=0A=
+        unsigned short lossOfSignal;=0A=
+        unsigned short receiveRemoteAlarm;=0A=
+        unsigned short alarmIndicationSignal;=0A=
 };=0A=
 =0A=
 /* "valid" bitmask */=0A=
@@ -131,13 +162,23 @@=0A=
                                          */=0A=
 #define FSTVAL_PROTO    0x00000200      /* proto */=0A=
 #define FSTVAL_MODE     0x00000400      /* cardMode */=0A=
+#define FSTVAL_PHASE    0x00000800      /* Clock phase */=0A=
+#define FSTVAL_TE1      0x00001000      /* T1E1 Configuration */=0A=
 #define FSTVAL_DEBUG    0x80000000      /* debug */=0A=
-#define FSTVAL_ALL      0x000007FF      /* Note: does not include =
DEBUG flag */=0A=
+#define FSTVAL_ALL      0x00001FFF      /* Note: does not include =
DEBUG flag */=0A=
 =0A=
 /* "type" */=0A=
 #define FST_TYPE_NONE   0               /* Probably should never =
happen */=0A=
 #define FST_TYPE_T2P    1               /* T2P X21 2 port card */=0A=
 #define FST_TYPE_T4P    2               /* T4P X21 4 port card */=0A=
+#define FST_TYPE_T1U    3               /* T1U X21 1 port card */=0A=
+#define FST_TYPE_T2U    4               /* T2U X21 2 port card */=0A=
+#define FST_TYPE_T4U    5               /* T4U X21 4 port card */=0A=
+#define FST_TYPE_TE1    6               /* T1E1 X21 1 port card */=0A=
+=0A=
+/* "family" */=0A=
+#define FST_FAMILY_TXP  0               /* T2P or T4P */=0A=
+#define FST_FAMILY_TXU  1               /* T1U or T2U or T4U */=0A=
 =0A=
 /* "state" */=0A=
 #define FST_UNINIT      0               /* Raw uninitialised state =
following=0A=
@@ -155,6 +196,10 @@=0A=
 #define V24             1=0A=
 #define X21             2=0A=
 #define V35             3=0A=
+#define X21D            4=0A=
+#define T1              5=0A=
+#define E1              6=0A=
+#define J1              7=0A=
 =0A=
 /* "proto" */=0A=
 #define FST_HDLC        1               /* Cisco compatible HDLC */=0A=
@@ -187,6 +232,97 @@=0A=
 /* "cardMode" bitmask */=0A=
 #define CARD_MODE_IDENTIFY      0x0001=0A=
 =0A=
+/* =0A=
+ * Constants for T1/E1 configuration=0A=
+ */=0A=
+=0A=
+/*=0A=
+ * Clock source=0A=
+ */=0A=
+#define CLOCKING_SLAVE       0=0A=
+#define CLOCKING_MASTER      1=0A=
+=0A=
+/*=0A=
+ * Framing=0A=
+ */=0A=
+#define FRAMING_E1           0=0A=
+#define FRAMING_J1           1=0A=
+#define FRAMING_T1           2=0A=
+=0A=
+/*=0A=
+ * Structure=0A=
+ */=0A=
+#define STRUCTURE_UNFRAMED   0=0A=
+#define STRUCTURE_E1_DOUBLE  1=0A=
+#define STRUCTURE_E1_CRC4    2=0A=
+#define STRUCTURE_E1_CRC4M   3=0A=
+#define STRUCTURE_T1_4       4=0A=
+#define STRUCTURE_T1_12      5=0A=
+#define STRUCTURE_T1_24      6=0A=
+#define STRUCTURE_T1_72      7=0A=
+=0A=
+/*=0A=
+ * Interface=0A=
+ */=0A=
+#define INTERFACE_RJ48C      0=0A=
+#define INTERFACE_BNC        1=0A=
+=0A=
+/*=0A=
+ * Coding=0A=
+ */=0A=
+=0A=
+#define CODING_HDB3          0=0A=
+#define CODING_NRZ           1=0A=
+#define CODING_CMI           2=0A=
+#define CODING_CMI_HDB3      3=0A=
+#define CODING_CMI_B8ZS      4=0A=
+#define CODING_AMI           5=0A=
+#define CODING_AMI_ZCS       6=0A=
+#define CODING_B8ZS          7=0A=
+=0A=
+/*=0A=
+ * Line Build Out=0A=
+ */=0A=
+#define LBO_0dB              0=0A=
+#define LBO_7dB5             1=0A=
+#define LBO_15dB             2=0A=
+#define LBO_22dB5            3=0A=
+=0A=
+/*=0A=
+ * Range for long haul t1 > 655ft=0A=
+ */=0A=
+#define RANGE_0_133_FT       0=0A=
+#define RANGE_0_40_M         RANGE_0_133_FT=0A=
+#define RANGE_133_266_FT     1=0A=
+#define RANGE_40_81_M        RANGE_133_266_FT=0A=
+#define RANGE_266_399_FT     2=0A=
+#define RANGE_81_122_M       RANGE_266_399_FT=0A=
+#define RANGE_399_533_FT     3=0A=
+#define RANGE_122_162_M       RANGE_399_533_FT=0A=
+#define RANGE_533_655_FT     4=0A=
+#define RANGE_162_200_M      RANGE_533_655_FT=0A=
+/*=0A=
+ * Receive Equaliser=0A=
+ */=0A=
+#define EQUALIZER_SHORT      0=0A=
+#define EQUALIZER_LONG       1=0A=
+=0A=
+/*=0A=
+ * Loop modes=0A=
+ */=0A=
+#define LOOP_NONE            0=0A=
+#define LOOP_LOCAL           1=0A=
+#define LOOP_PAYLOAD_EXC_TS0 2=0A=
+#define LOOP_PAYLOAD_INC_TS0 3=0A=
+#define LOOP_REMOTE          4=0A=
+=0A=
+/*=0A=
+ * Buffer modes=0A=
+ */=0A=
+#define BUFFER_2_FRAME       0=0A=
+#define BUFFER_1_FRAME       1=0A=
+#define BUFFER_96_BIT        2=0A=
+#define BUFFER_NONE          3=0A=
 =0A=
 /*      Debug support=0A=
  *=0A=
diff -urN linux-2.4.25-orig/include/linux/if.h =
linux/include/linux/if.h=0A=
--- linux-2.4.25-orig/include/linux/if.h	2004-02-04 12:08:25.000000000 =
+0000=0A=
+++ linux/include/linux/if.h	2004-02-04 12:26:14.000000000 +0000=0A=
@@ -62,6 +62,7 @@=0A=
 #define IF_IFACE_T1	0x1003		/* T1 telco serial interface	*/=0A=
 #define IF_IFACE_E1	0x1004		/* E1 telco serial interface	*/=0A=
 #define IF_IFACE_SYNC_SERIAL 0x1005	/* can't be set by software	*/=0A=
+#define IF_IFACE_X21D   0x1006          /* X.21 Dual Clocking =
(FarSite) */=0A=
 =0A=
 /* For definitions see hdlc.h */=0A=
 #define IF_PROTO_HDLC	0x2000		/* raw HDLC protocol		*/=0A=
@@ -76,6 +77,7 @@=0A=
 #define IF_PROTO_FR_DEL_ETH_PVC 0x2009	/*  Delete FR Ethernet-bridged =
PVC */=0A=
 #define IF_PROTO_FR_PVC	0x200A		/* for reading PVC status	*/=0A=
 #define IF_PROTO_FR_ETH_PVC 0x200B=0A=
+#define IF_PROTO_RAW    0x200C          /* RAW Socket                  =
 */=0A=
 =0A=
 =0A=
 /*=0A=

------_=_NextPart_000_01C3EB38.D1A7D900--
