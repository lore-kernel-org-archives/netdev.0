From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 005/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:12:18 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA4@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 5 of 7
Note that this patch must be applied with patch 4 (farsync_include_patch)

Update the current farsync driver to support all of the PCI and PCI X
cards manufactured by Farsite Communications.

Add a tty interface so that the ports can also be used by the ppp daemon.

Add support for big endian systems (the FarSite cards have a little endian
processor on board).

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---
diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/farsync.c linux-3.10.1_new/drivers/net/wan/farsync.c
--- linux-3.10.1/drivers/net/wan/farsync.c      2013-07-13 19:42:41.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/farsync.c  2013-09-16 16:30:06.391104883 +0100
@@ -3,16 +3,16 @@
  *
  *      Actually sync driver for X.21, V.35 and V.24 on FarSync T-series cards
  *
- *      Copyright (C) 2001-2004 FarSite Communications Ltd.
- *      www.farsite.co.uk
+ *      Copyright (C) 2001-2013 FarSite Communications Ltd.
+ *      www.farsite.com
  *
  *      This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
  *
- *      Author:      R.J.Dunlop    <bob.dunlop@farsite.co.uk>
- *      Maintainer:  Kevin Curtis  <kevin.curtis@farsite.co.uk>
+ *      Author:      R.J.Dunlop    <bob.dunlop@farsite.com>
+ *      Maintainer:  Kevin Curtis  <kevin.curtis@farsite.com>
  */

 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -20,18 +20,29 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/version.h>
-#include <linux/pci.h>
+#include <linux/fs.h>
 #include <linux/sched.h>
-#include <linux/slab.h>
+#include <linux/proc_fs.h>
+#include <linux/pci.h>
+#include <linux/poll.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
-#include <linux/interrupt.h>
+#include <linux/uaccess.h>
 #include <linux/if.h>
+#include <linux/interrupt.h>
 #include <linux/hdlc.h>
-#include <asm/io.h>
-#include <asm/uaccess.h>
-
+#include <linux/delay.h>
+#include <linux/delay.h>
+/* TTY includes */
+#include <linux/tty.h>
+#include <linux/tty_flip.h>
+#include <linux/serial.h>
+#include <linux/crypto.h>
+#include <linux/err.h>
+#include <linux/scatterlist.h>
+#define FST_BUILD_NO "-k219"
 #include "farsync.h"
+#include "fscmn.h"

 /*
  *      Module info
@@ -44,28 +55,65 @@ MODULE_LICENSE("GPL");
  *      ==========================================
  */

+#define FST_PORT_NAME "hdlc"
+#define FST_DRIVER_TYPE "WAN"
+
 /*      Number of ports (per card) and cards supported
  */
 #define FST_MAX_PORTS           4
 #define FST_MAX_CARDS           32

+/*
+ * Modules parameters and associated varaibles
+ */
+#define FST_HIGH_WATER_MARK     12     /* Point at which we flow control
+                                          network layer
+                                        */
+#define FST_LOW_WATER_MARK      8      /* Point at which we remove flow
+                                          control from network layer
+                                        */
+#define FST_MIN_DMA_LEN        64      /* do DMA on transfer > 64 bytes */
+
+int fst_txq_low = FST_LOW_WATER_MARK;
+int fst_txq_high = FST_HIGH_WATER_MARK;
+int fst_min_dma_len = FST_MIN_DMA_LEN;
+int fst_dmathr = 0xdd00dd00;
+int fst_iocinfo_version = FST_VERSION_CURRENT;
+int fst_max_reads = 7;
+int fst_excluded_cards;
+int fst_excluded_list[FST_MAX_CARDS];
+
+module_param(fst_txq_low, int, S_IRUGO);
+module_param(fst_txq_high, int, S_IRUGO);
+module_param(fst_min_dma_len, int, S_IRUGO);
+module_param(fst_dmathr, int, S_IRUGO);
+module_param(fst_iocinfo_version, int, S_IRUGO);
+module_param(fst_max_reads, int, S_IRUGO);
+module_param(fst_excluded_cards, int, S_IRUGO);
+module_param_array(fst_excluded_list, int, NULL, S_IRUGO);
+
 /*      Default parameters for the link
  */
 #define FST_TX_QUEUE_LEN        100    /* At 8Mbps a longer queue length is
-                                        * useful */
+                                        * useful, the syncppp module forces
+                                        * this down assuming a slower line I
+                                        * guess.
+                                        */
 #define FST_TXQ_DEPTH           16     /* This one is for the buffering
-                                        * of frames on the way down to the card
-                                        * so that we can keep the card busy
-                                        * and maximise throughput
+                                        * of frames on the way down to the
+                                        * card so that we can keep the card
+                                        * busy and maximise throughput
+                                        */
+#define FST_MAX_MTU           (32*1024)        /* Limitation of hdlc controller on
+                                        * card
                                         */
-#define FST_HIGH_WATER_MARK     12     /* Point at which we flow control
-                                        * network layer */
-#define FST_LOW_WATER_MARK      8      /* Point at which we remove flow
-                                        * control from network layer */
-#define FST_MAX_MTU             8000   /* Huge but possible */
 #define FST_DEF_MTU             1500   /* Common sane value */
-
-#define FST_TX_TIMEOUT          (2*HZ)
+#define FST_MAX_ATM_MTU         (32*53)        /* 1500 bytes should fit in 32 cells */
+#define MAX_PPP_HEADER          10     /* Allowance for PPP overhead when
+                                          allocating skbs or checking lengths
+                                        */
+#define FST_TX_TIMEOUT          (10*HZ)
+#define FST_MAX_SEGMENTS (FST_MAX_MTU/128)    /* Max tx/rx desriptors/frame */

 #ifdef ARPHRD_RAWHDLC
 #define ARPHRD_MYTYPE   ARPHRD_RAWHDLC /* Raw frames */
@@ -73,25 +121,10 @@ MODULE_LICENSE("GPL");
 #define ARPHRD_MYTYPE   ARPHRD_HDLC    /* Cisco-HDLC (keepalives etc) */
 #endif

-/*
- * Modules parameters and associated variables
- */
-static int fst_txq_low = FST_LOW_WATER_MARK;
-static int fst_txq_high = FST_HIGH_WATER_MARK;
-static int fst_max_reads = 7;
-static int fst_excluded_cards = 0;
-static int fst_excluded_list[FST_MAX_CARDS];
-
-module_param(fst_txq_low, int, 0);
-module_param(fst_txq_high, int, 0);
-module_param(fst_max_reads, int, 0);
-module_param(fst_excluded_cards, int, 0);
-module_param_array(fst_excluded_list, int, NULL, 0);
-
 /*      Card shared memory layout
  *      =========================
  */
-#pragma pack(1)
+#pragma pack(2)

 /*      This information is derived in part from the FarSite FarSync Smc.h
  *      file. Unfortunately various name clashes and the non-portability of the
@@ -103,23 +136,33 @@ module_param_array(fst_excluded_list, in
  *      be used to check that we have not got out of step with the firmware
  *      contained in the .CDE files.
  */
-#define SMC_VERSION 24
+#define SMC_VERSION 47

 #define FST_MEMSIZE 0x100000   /* Size of card memory (1Mb) */

 #define SMC_BASE 0x00002000L   /* Base offset of the shared memory window main
-                                * configuration structure */
-#define BFM_BASE 0x00010000L   /* Base offset of the shared memory window DMA
-                                * buffers */
+                                * configuration structure
+                                */
+#define BFM_BASE 0x00020000L   /* Base offset of the shared memory window DMA
+                                * buffers
+                                */
+#define AW_BASE  0x000a0000L   /* Base offset of the shared memory window
+                                * async context structure
+                                */
+#define DT_BASE  0x000afff8L   /* DSL Transmit Fifo shared memory base */
+#define DR_BASE  0x000cfff8L   /* DSL Receive FIFO shared memory base */

-#define LEN_TX_BUFFER 8192     /* Size of packet buffers */
-#define LEN_RX_BUFFER 8192
+#define MAX_LEN_TX_BUFFER (32*1024)    /* Max Size of packet buffers */
+#define MAX_LEN_RX_BUFFER (32*1024)

 #define LEN_SMALL_TX_BUFFER 256        /* Size of obsolete buffs used for DOS diags */
 #define LEN_SMALL_RX_BUFFER 256

-#define NUM_TX_BUFFER 2                /* Must be power of 2. Fixed by firmware */
-#define NUM_RX_BUFFER 8
+#define NUM_SMALL_TX_BUFFER 2  /* Must be power of 2. Fixed by firmware */
+#define NUM_SMALL_RX_BUFFER 8
+
+#define MAX_TX_BUFFER 128      /* Must be power of 2. */
+#define MAX_RX_BUFFER 128      /* configurable to this value */

 /* Interrupt retry time in milliseconds */
 #define INT_RETRY_TIME 2
@@ -189,6 +232,14 @@ struct cirbuff {
 /* Interrupt event codes.
  * Where appropriate the two low order bits indicate the port number
  */
+#define TXA_CMPL        0x10   /* Transmit complete events */
+#define TXB_CMPL        0x11
+#define TXC_CMPL        0x12
+#define TXD_CMPL        0x13
+#define RXA_CMPL        0x14
+#define RXB_CMPL        0x15
+#define RXC_CMPL        0x16
+#define RXD_CMPL        0x17
 #define CTLA_CHG        0x18   /* Control signal changed */
 #define CTLB_CHG        0x19
 #define CTLC_CHG        0x1A
@@ -211,54 +262,181 @@ struct cirbuff {
 #define M32_INT         0x2D

 #define TE1_ALMA        0x30
+#define DSL_FAIL        0x34
+#define DSL_ACST        0x38
+#define DSL_SENT        0x3c
+#define DSL_RCVD        0x40
+#define DSL_LINK        0x44
+
+#define TXA_TBUA        0x48
+#define TXB_TBUA        0x49
+#define TXC_TBUA        0x4A
+#define TXD_TBUA        0x4B
+
+#define RXA_RBUA        0x4C
+#define RXB_RBUA        0x4D
+#define RXC_RBUA        0x4E
+#define RXD_RBUA        0x4f
+
+/* Data Encoding for the T4E+ */
+
+#define FSCMN_ENCODING_NRZ               0x80
+#define FSCMN_ENCODING_NRZI              0xa0
+#define FSCMN_ENCODING_FM0               0xc0
+#define FSCMN_ENCODING_FM1               0xd0
+#define FSCMN_ENCODING_MANCHESTER        0xe0
+#define FSCMN_ENCODING_DIFF_MANCHESTER   0xf0

 /* Port physical configuration. See farsync.h for field values */
 struct port_cfg {
-       u16 lineInterface;      /* Physical interface type */
+       u16 line_interface;     /* Physical interface type */
        u8 x25op;               /* Unused at present */
-       u8 internalClock;       /* 1 => internal clock, 0 => external */
-       u8 transparentMode;     /* 1 => on, 0 => off */
-       u8 invertClock;         /* 0 => normal, 1 => inverted */
-       u8 padBytes[6];         /* Padding */
-       u32 lineSpeed;          /* Speed in bps */
+       u8 internal_clock;      /* 1 => internal clock, 0 => external */
+       u8 transparent_mode;    /* 1 => on, 0 => off */
+       u8 invert_clock;                /* 0 => normal, 1 => inverted */
+       u8 tx_rx_start;         /* 0 = start tx and rx on open */
+       /* 1 = start tx only */
+       /* 2 = start rx only */
+       u8 num_tx_buffers;      /* Number of Tx Buffers to use, max 128 */
+       u8 num_rx_buffers;      /* Number of Rx Buffers to use, max 128 */
+       u8 clock_source;        /* FS_CLOCK_REFERENCE_xxx */
+       u8 padBytes[2];         /* Padding to 16 bytes */
+       u32 line_speed;         /* Speed in bps */
+       /*
+        * Extras for T4E Mk II
+        */
+       u8 extended_clocking;   /* Enabling flag */
+       u8 internal_tx_clock;   /* only if extended_clocking is TRUE */
+       u8 internal_rx_clock;   /* only if extended_clocking is TRUE */
+       u8 terminal_tx_clock;   /* only if extended_clocking is TRUE */
+       u8 terminal_rx_clock;   /* only if extended_clocking is TRUE */
+       u8 dcd_output;          /* TRUE => v24opsts.dcd will apply */
+       u8 transmit_msb_first;  /* default (FALSE) tx lsb first */
+       /* tx MSB first is normally only used in */
+       /* (some) transparent applications */
+       u8 receive_msb_first;   /* default (FALSE) rx lsb first */
+       /* rx MSB first is normally only used in */
+       /* (some) transparent applications */
+       u32 estimated_line_speed;       /* applies only is linespeed is 0 */
+       u8 encoding;            /* default NRZ, NRZI, FM0, FM1 or Manchester */
+       u8 enable_nrzi_clocking;        /* default FALSE, set TRUE for NRZI */
+       u8 termination;         /* default FALSE no termination */
+       u8 immediate_ints;      /* set True for low latency mode */
+};
+
+struct dsl_config {
+       u32 data_rate;          /* data rate in bps */
+       u8 terminal_type;       /* central or remote */
+       u8 annex_type;          /* A (US) or B (EU) */
+       u8 test_mode;           /* Various loop modes */
+       u8 backoff;             /* Power backoff in dB */
+       u8 b_line_probing_enable;       /* set TRUE to probe line */
+       u8 snrth;               /* Signal to Noise Ratio Threshold in dB */
+       /* SNR Margin Defect when signal_quality
+        * falls below this value
+        */
+       u8 lpath;               /* Loop Attenuation Threshold in dB */
+       /* LA Defect when LineLoss exceeds this
+        * value
+        */
+       u8 spare[21];           /* adjust to keep structure size 32 bytes */
+};
+
+struct dsl_status {            /* some signed, some unsigned TBA */
+       u8 activation_status;
+       u8 no_common_mode_status;
+       u8 transceiverStatus1;
+       u8 transceiverStatus2;
+       u8 line_loss;           /* dB */
+       char signal_quality;
+       u8 near_end_block_error_count;  /* wraps after 0xff, s/w can rst */
+       char signal_to_noise_ratio;     /* dB */
+       u8 code_violation_count;
+       u8 errored_second_count;          /*  | */
+       u8 severely_errored_second_count; /*   > reset after download */
+       u8 loss_of_sync_word_second_count;/*  | */
+       u8 unavailable_second_count;
+       char frequency_deviation;
+       char negotiated_power_back_off;
+       u8 negotiated_psd;
+       u8 negotiated_b_channels;
+       u8 negotiated_z_bits;
+       u16 negotiated_sync_word;
+       u8 negotiated_stuff_bits;
+       u8 chip_version;
+       u8 firmware_version;
+       u8 rom_version;
+       u16 atm_tx_cell_count;
+       u16 atm_rx_cell_count;
+       u16 atm_hec_error_count;
+       u8 b_link_up;           /* TRUE => link is up and ready to pass data */
+       /* FALSE => link is down */
+       u8 xpld_version;                /* 8-bit XPLD version number */
+       u8 farEndCountryCode[2];        /* 2-byte T.35 Country Code */
+       u8 farEndProviderCode[4];       /* 4-byte Provider code (ascii) */
+       u8 farEndVendorInfo[2]; /* 2-byte Vendor Information */
+       u8 utopia_atm_status;   /* 1 byte status */
+       u8 spare[23];           /* adjust structure to 32 bytes */
+};
+
+struct dsl_control {
+       u32 offset_atm_rx;
+       u32 offset_atm_tx;
+       u16 bytes_to_send;      /* set by writer, reset by reader */
+       u8 spare[6];            /* adjuest to keep struct size 16 bytes */
 };

 /* TE1 port physical configuration */
 struct su_config {
-       u32 dataRate;
-       u8 clocking;
-       u8 framing;
+       u32 data_rate;          /* data rate in bps */
+       u8 clocking;            /* master or slave */
+       u8 framing;             /* E1, T1 or J1 */
        u8 structure;
-       u8 interface;
-       u8 coding;
-       u8 lineBuildOut;
-       u8 equalizer;
-       u8 transparentMode;
-       u8 loopMode;
+       u8 interface;           /* RJ48C or BNC */
+       u8 coding;              /* HDB3 or B8ZS */
+       u8 line_build_out;
+       u8 equalizer;           /* short on long haul settings */
+       u8 transparent_mode;    /* hdlc (0) or transparent (1) */
+       u8 loop_mode;
        u8 range;
-       u8 txBufferMode;
-       u8 rxBufferMode;
-       u8 startingSlot;
-       u8 losThreshold;
-       u8 enableIdleCode;
-       u8 idleCode;
-       u8 spare[44];
+       u8 tx_buffer_mode;      /* 0, 96 bits 1 frame or 2 frames */
+       u8 rx_buffer_mode;      /* 0, 96 bits 1 frame or 2 frames */
+       u8 starting_slot;       /* E1 1-31; T1/J1 0-23 */
+       u8 los_threshold;       /* 0-7 */
+       u8 enable_idle_code;    /* 0 disabled, 1 enabled */
+       u8 idle_code;           /* 0x00 to 0xff */
+       u8 ext_mode;            /* LOBYTE of HIWORD(FS_LINE_MODE_*) */
+       u8 spare1[1];           /* adjust to keep structure size 64 bytes */
+       u8 ext_sync_clock_enable;       /* TE1e: Enable external sync clock */
+       u8 ext_sync_clock_offset;       /* TE1e: Enable d.c. offset on clock */
+       u32 ext_sync_clock_rate;        /* TE1e: Sync clock rate */
+       u8 pps_enable;          /* TE1e: Enable 1PPS sync */
+       u8 pps_offset;          /* TE1e: 1PPS d.c. offset */
+       u8 spare[34];           /* Keep structure 64 bytes */
 };

 /* TE1 Status */
 struct su_status {
-       u32 receiveBufferDelay;
-       u32 framingErrorCount;
-       u32 codeViolationCount;
-       u32 crcErrorCount;
-       u32 lineAttenuation;
+       u32 receive_buffer_delay;       /* delay trhough rx buffer (o-63) */
+       u32 framing_error_count;        /* count of framing errors */
+       u32 code_violation_count;       /* count of code vilations */
+       u32 crc_error_count;    /* count of CRC errors */
+       u32 line_attenuation;   /* in dB */
        u8 portStarted;
-       u8 lossOfSignal;
-       u8 receiveRemoteAlarm;
-       u8 alarmIndicationSignal;
-       u8 spare[40];
+       u8 loss_of_signal;      /* LOS alarm */
+       u8 receive_remote_alarm;        /* RRA alarm */
+       u8 alarm_indication_signal;     /* AIS alarm */
+       u8 spare[40];           /* keep structure 64 bytes */
 };

+typedef struct fst_fifo {
+       u16 fifo_length;
+       u16 read_idx;
+       u16 write_idx;
+       short overflow_idx;
+       u8 data[4];
+} FIFO, *PFIFO;
+
 /* Finally sling all the above together into the shared memory structure.
  * Sorry it's a hodge podge of arrays, structures and unused bits, it's been
  * evolving under NT for some time so I guess we're stuck with it.
@@ -267,14 +445,16 @@ struct su_status {
  */
 struct fst_shared {
        /* DMA descriptor rings */
-       struct rxdesc rxDescrRing[FST_MAX_PORTS][NUM_RX_BUFFER];
-       struct txdesc txDescrRing[FST_MAX_PORTS][NUM_TX_BUFFER];
+       struct rxdesc rx_descr_ring[FST_MAX_PORTS][MAX_RX_BUFFER];
+       struct txdesc tx_descr_ring[FST_MAX_PORTS][MAX_TX_BUFFER];

        /* Obsolete small buffers */
-       u8 smallRxBuffer[FST_MAX_PORTS][NUM_RX_BUFFER][LEN_SMALL_RX_BUFFER];
-       u8 smallTxBuffer[FST_MAX_PORTS][NUM_TX_BUFFER][LEN_SMALL_TX_BUFFER];
+       u8 small_rx_buffer[FST_MAX_PORTS][NUM_SMALL_RX_BUFFER]
+           [LEN_SMALL_RX_BUFFER];
+       u8 small_tx_buffer[FST_MAX_PORTS][NUM_SMALL_TX_BUFFER]
+           [LEN_SMALL_TX_BUFFER];

-       u8 taskStatus;          /* 0x00 => initialising, 0x01 => running,
+       u8 task_status;         /* 0x00 => initialising, 0x01 => running,
                                 * 0xFF => halted
                                 */

@@ -282,12 +462,16 @@ struct fst_shared {
                                 * set to 0xEE by host to acknowledge interrupt
                                 */

-       u16 smcVersion;         /* Must match SMC_VERSION */
+       u16 smc_version;                /* Must match SMC_VERSION */

-       u32 smcFirmwareVersion; /* 0xIIVVRRBB where II = product ID, VV = major
+       u32 smc_firmware_version;       /* 0xIIVVRRBB where II = product ID,
+                                * VV = major
                                 * version, RR = revision and BB = build
                                 */

+       u8 async_ability[FST_MAX_PORTS];        /* TRUE  => async and sync */
+       /* FALSE => sync only */
+       u8 synth_ability;       /* TRUE => synthesizer present */
        u16 txa_done;           /* Obsolete completion flags */
        u16 rxa_done;
        u16 txb_done;
@@ -299,19 +483,20 @@ struct fst_shared {

        u16 mailbox[4];         /* Diagnostics mailbox. Not used */

-       struct cirbuff interruptEvent;  /* interrupt causes */
+       struct cirbuff interrupt_event; /* interrupt causes */

        u32 v24IpSts[FST_MAX_PORTS];    /* V.24 control input status */
        u32 v24OpSts[FST_MAX_PORTS];    /* V.24 control output status */

-       struct port_cfg portConfig[FST_MAX_PORTS];
+       struct port_cfg port_config[FST_MAX_PORTS];

-       u16 clockStatus[FST_MAX_PORTS]; /* lsb: 0=> present, 1=> absent */
+       u16 clock_status[FST_MAX_PORTS]; /* lsb: 0=> present,
+                                         * 1=> absent
+                                         */
+       u16 cable_status;                /* lsb: 0=> present, 1=> absent */

-       u16 cableStatus;        /* lsb: 0=> present, 1=> absent */
-
-       u16 txDescrIndex[FST_MAX_PORTS];        /* transmit descriptor ring index */
-       u16 rxDescrIndex[FST_MAX_PORTS];        /* receive descriptor ring index */
+       u16 tx_descr_index[FST_MAX_PORTS]; /* transmit descriptor ring index */
+       u16 rx_descr_index[FST_MAX_PORTS]; /* receive descriptor ring index */

        u16 portMailbox[FST_MAX_PORTS][2];      /* command, modifier */
        u16 cardMailbox[4];     /* Not used */
@@ -339,21 +524,61 @@ struct fst_shared {
        u32 ctsTimerRun[FST_MAX_PORTS];
        u32 dcdTimer[FST_MAX_PORTS];
        u32 dcdTimerRun[FST_MAX_PORTS];
+       u32 ri_timer[FST_MAX_PORTS];
+       u32 ri_timer_run[FST_MAX_PORTS];

-       u32 numberOfPorts;      /* Number of ports detected at startup */
+       u32 number_of_ports;    /* Number of ports detected at startup */

        u16 _reserved[64];

-       u16 cardMode;           /* Bit-mask to enable features:
+       u16 card_mode;          /* Bit-mask to enable features:
                                 * Bit 0: 1 enables LED identify mode
                                 */

        u16 portScheduleOffset;

-       struct su_config suConfig;      /* TE1 Bits */
-       struct su_status suStatus;
+       struct su_config su_config;     /* TE1 Config structure */
+       struct su_status su_status;     /* TE1 Stats structure */
+       struct dsl_config dsl_config;   /* DSL Config structure */
+       struct dsl_status dsl_status;   /* DSL Stats structure */
+       struct dsl_control dsl_control; /* DSL FiFos etc */
+
+#define NOTIFICATION_FIFO_LEN   64
+       char card_notifications[NOTIFICATION_FIFO_LEN + sizeof(FIFO)];
+
+       /* The following configuration values are processed by the CDE when
+        * it receives a CMD_FIFO_CONFIG_CT_BUS request
+        * This request can be issued at anytime regardless of whether
+        * any ports are opened or not T4E MkII
+        */
+       u32 ct_bus_primary_mode;        /* e.g. FS_CT_BUS_MODE_xxx */
+       u32 ct_bus_primary_feed;        /* e.g. FS_CLOCK_REFERENCE_xxx */
+       u32 ct_bus_backup_mode; /* e.g. FS_CT_BUS_MODE_xxx */
+       u32 ct_bus_backup_feed; /* e.g. FS_CLOCK_REFERENCE_xxx */
+       u8 cta_clock_present;   /* 1 => CTA present, 0 => CTA absent */
+       u8 b_primary_fallback;  /* 1 => Primary to Backup fallback allowed */
+       u8 b_backup_fallback;   /* 1 => Backup to Local Osc fallback allowed */
+       u8 b_primary_clock_status;      /* 0 = out-of-tolerance, 1 = good */
+       u8 b_backup_clock_status;       /* 0 = out-of-tolerance, 1 = good */
+       u8 b_ct_a_status;               /* 0 = out-of-tolerance, 1 = good */
+       u8 b_ct_b_status;               /* 0 = out-of-tolerance, 1 = good */
+
+       u16 current_status_summary;     /* Bit-mapped field indicating: */
+       /* D15-D9 n.u, default 0's
+        * D8 Slave/Master, 0=SLAVE, 1=MASTER
+        * D7 CTA/CTB, 0=A, 1=B
+        * D6-D4 A/B/C/D/LO (Master only)
+        * 000=A, 001=B, 010=C, 011=D, 100=LO
+        * D3-D0 Port A-D ClockSource CT/LO,
+        * 0=CT, 1=LO
+        */
+       u8 capability_mask;     /* T4E+ and newer, T4E+ sets bit 0 true */
+       u8 fill;                /* Temporary to fix an alignment issue */
+
+       u32 u_current_config_reference; /* e.g. FS_CONFIG_IN_USE_xxx */

-       u32 endOfSmcSignature;  /* endOfSmcSignature MUST be the last member of
+       u32 end_of_smc_signature;       /* endOfSmcSignature MUST be the
+                                * last member of
                                 * the structure and marks the end of shared
                                 * memory. Adapter code initializes it as
                                 * END_SIG.
@@ -371,11 +596,17 @@ struct fst_shared {
 #define STOPPORT        4      /* Stop an HDLC port */
 #define ABORTTX         5      /* Abort the transmitter for a port */
 #define SETV24O         6      /* Set V24 outputs */
+#define RECONFIG        7      /* Reconfigure port (esp async) */
+#define FLUSHTX         8      /* Flush the Tx Fifo (esp async) */
+#define SETXON          9      /* XON command */
+#define SETXOFF        10      /* XOFF command */
+#define RECONFIGLINE   11      /* Reconfigure the port line parameters */

 /* PLX Chip Register Offsets */
 #define CNTRL_9052      0x50   /* Control Register */
 #define CNTRL_9054      0x6c   /* Control Register */
-
+#define PCIILR          0x3c   /* Interrupt Line Register */
+#define PCICR           0x04   /* Interrupt Control Register */
 #define INTCSR_9052     0x4c   /* Interrupt control/status register */
 #define INTCSR_9054     0x68   /* Interrupt control/status register */

@@ -402,52 +633,324 @@ struct fst_shared {
 #define DMADAC1         0xb8
 #define DMAMARBR        0xac

-#define FST_MIN_DMA_LEN 64
 #define FST_RX_DMA_INT  0x01
 #define FST_TX_DMA_INT  0x02
 #define FST_CARD_INT    0x04

 /* Larger buffers are positioned in memory at offset BFM_BASE */
+#define TX_BUFFER_SPACE 0x10000
+#define RX_BUFFER_SPACE 0x10000
+#define REQUIRED_TX_BUFFERS 8
+#define REQUIRED_RX_BUFFERS 8
+#define REQUIRED_TX_BUFFER_SIZE (8*1024)
+#define REQUIRED_RX_BUFFER_SIZE (8*1024)
 struct buf_window {
-       u8 txBuffer[FST_MAX_PORTS][NUM_TX_BUFFER][LEN_TX_BUFFER];
-       u8 rxBuffer[FST_MAX_PORTS][NUM_RX_BUFFER][LEN_RX_BUFFER];
+       u8 tx_buffer[FST_MAX_PORTS][TX_BUFFER_SPACE];
+       u8 rx_buffer[FST_MAX_PORTS][RX_BUFFER_SPACE];
 };

 /* Calculate offset of a buffer object within the shared memory window */
-#define BUF_OFFSET(X)   (BFM_BASE + offsetof(struct buf_window, X))
+#define BUF_OFFSET(X)   ((unsigned long)&(((struct buf_window *)BFM_BASE)->X))
+
+#pragma pack()
+
+/*      Shared memory window access macros
+ *
+ *      We have a nice memory based structure above, which could be directly
+ *      mapped on i386 but might not work on other architectures unless we use
+ *      the readb,w,l and writeb,w,l macros. Unfortunately these macros take
+ *      physical offsets so we have to convert. The only saving grace is that
+ *      this should all collapse back to a simple indirection eventually.
+ */
+#define WIN_OFFSET(X)   ((unsigned long)&(((struct fst_shared *)SMC_BASE)->X))
+
+#define FST_RDB(C, E)    readb((C)->mem + WIN_OFFSET(E))
+#define FST_RDW(C, E)    readw((C)->mem + WIN_OFFSET(E))
+#define FST_RDL(C, E)    readl((C)->mem + WIN_OFFSET(E))
+
+#define FST_WRB(C, E, B)  writeb((B), (C)->mem + WIN_OFFSET(E))
+#define FST_WRW(C, E, W)  writew((W), (C)->mem + WIN_OFFSET(E))
+#define FST_WRL(C, E, L)  writel((L), (C)->mem + WIN_OFFSET(E))
+
+#define FIFO_RDB(M)    readb(M)
+#define FIFO_RDW(M)    readw(M)
+#define FIFO_RDL(M)    readl(M)
+#define FIFO_WRB(M, B)  writeb((B), (M))
+#define FIFO_WRW(M, W)  writew((W), (M))
+#define FIFO_WRL(M, L)  writel((L), (M))
+
+/* Async memory window definition  */
+#define FST_CMD_RECONFIG         0x0001
+#define FST_CMD_FIFO_FLUSH_TX    0x0002
+#define FST_CMD_FIFO_BREAK_ON    0x0004
+#define FST_CMD_FIFO_BREAK_OFF   0x0008
+#define FST_CMD_FIFO_XON         0x0010
+#define FST_CMD_FIFO_XOFF        0x0020
+#define FST_CMD_FIFO_RESET_TS    0x0040
+
+/* these replace the original portMailbox commands that could result in
+ * lost commands if the card was slow in processing the previous one.
+ */
+
+#define CMD_FIFO_START_PORT     0x0080
+#define CMD_FIFO_STOP_PORT      0x0100
+#define CMD_FIFO_SET_V24        0x0200
+#define CMD_FIFO_ABORT_PORT     0x0400
+
+#define CMD_FIFO_STAT_RESET     0x0800
+
+#define CMD_FIFO_CONFIG_CT_BUS  0x1000
+
+/* T4E MkII  */
+#define CMD_FIFO_RECONFIG_PORT  0x2000
+
+#define FST_CMD_FIFO_LEN         16
+#define FST_TX_DATA_FIFO_LEN   1024
+#define FST_RX_DATA_FIFO_LEN   (FST_TX_DATA_FIFO_LEN * sizeof(ASYNC_RX_EVENT))
+#define FST_RX_DATA_FIFO_HIGH  (3*FST_RX_DATA_FIFO_LEN/4)
+#define FST_RX_DATA_FIFO_LOW   (1*FST_RX_DATA_FIFO_LEN/4)
+#define FST_TX_DATA_FIFO_LOW   (1*FST_TX_DATA_FIFO_LEN/4)
+#define FST_MSG_FIFO_LEN         64
+#define FST_RSP_FIFO_LEN         64
+#define MAX_RX_EVENT_FIFO_LEN  1024
+
+#define ASYNC_STAT_VAL 0x80    /* data associated with this status */
+#define ASYNC_STAT_CD  0x40    /* state of Carrier Detect Signal */
+#define ASYNC_STAT_RI  0x20    /* state of Ring Indicate Signal */
+#define ASYNC_STAT_CTS 0x10    /* state of Clear to Send Signal */
+#define ASYNC_STAT_BRK 0x08    /* receiving Break */
+#define ASYNC_STAT_FRM 0x04    /* framing error */
+#define ASYNC_STAT_PAR 0x02    /* parity error */
+#define ASYNC_STAT_OVR 0x01    /* overrun error */
+
+#pragma pack(2)
+typedef struct async_rx_event {
+       u8 status_byte;
+       u8 character;
+       u32 timestamp;
+} ASYNC_RX_EVENT, *PASYNC_RX_EVENT;
+
+typedef struct fst_async_config {
+       u8 flow_control;
+       u8 stop_bits;
+       u8 parity;
+       u8 word_length;
+       u8 xon_char;
+       u8 xoff_char;
+       u16 rx_fifo_size;
+} ASYNC_CONFIG, *PASYNC_CONFIG;
+
+struct fst_async_window {
+       u8 async_mode[FST_MAX_PORTS];
+       ASYNC_CONFIG async_config[FST_MAX_PORTS];
+       char cmd_fifo[FST_MAX_PORTS][FST_CMD_FIFO_LEN + sizeof(FIFO)];
+       char tx_fifo[FST_MAX_PORTS][FST_TX_DATA_FIFO_LEN + sizeof(FIFO)];
+       char rx_fifo[FST_MAX_PORTS][FST_RX_DATA_FIFO_LEN + sizeof(FIFO)];
+       char rx_event_fifos[FST_MAX_PORTS][MAX_RX_EVENT_FIFO_LEN +
+                                          sizeof(FIFO)];
+       char msg_fifo[FST_MSG_FIFO_LEN + sizeof(FIFO)];
+       char rsp_fifo[FST_RSP_FIFO_LEN + sizeof(FIFO)];
+};
+#pragma pack()
+
+/*      Async memory window access macros
+ *
+ *      We have a nice memory based structure above, which could be directly
+ *      mapped on i386 but might not work on other architectures unless we use
+ *      the readb,w,l and writeb,w,l macros. Unfortunately these macros take
+ *      physical offsets so we have to convert. The only saving grace is that
+ *      this should all collapse back to a simple indirection eventually.
+ */
+
+#define ASY_OFFSET(X)                                                  \
+       ((unsigned long)&(((struct fst_async_window *)AW_BASE)->X))
+
+#define FST_A_RDB(C, E)    readb((C)->mem + ASY_OFFSET(E))
+#define FST_A_RDW(C, E)    readw((C)->mem + ASY_OFFSET(E))
+#define FST_A_RDL(C, E)    readl((C)->mem + ASY_OFFSET(E))
+
+#define FST_A_WRB(C, E, B)  writeb((B), (C)->mem + ASY_OFFSET(E))
+#define FST_A_WRW(C, E, W)  writew((W), (C)->mem + ASY_OFFSET(E))
+#define FST_A_WRL(C, E, L)  writel((L), (C)->mem + ASY_OFFSET(E))
+
+/* DSL Fifo's */
+#define MAX_DSL_TX_BUFFER (32*1024)
+#define MAX_DSL_RX_BUFFER (32*1024)
+
+#pragma pack(2)
+
+struct dsl_tx_fifo {
+       char tx_fifo[MAX_DSL_TX_BUFFER + sizeof(FIFO)];
+};
+
+struct dsl_rx_fifo {
+       char rx_fifo[MAX_DSL_RX_BUFFER + sizeof(FIFO)];
+};

 #pragma pack()

+/*      DSL memory window access macros
+ *
+ *      We have a nice memory based structure above, which could be directly
+ *      mapped on i386 but might not work on other architectures unless we use
+ *      the readb,w,l and writeb,w,l macros. Unfortunately these macros take
+ *      physical offsets so we have to convert. The only saving grace is that
+ *      this should all collapse back to a simple indirection eventually.
+ */
+#define DT_OFFSET(X)   ((unsigned long)&(((struct dsl_tx_fifo *)DT_BASE)->X))
+#define DR_OFFSET(X)   ((unsigned long)&(((struct dsl_rx_fifo *)DR_BASE)->X))
+
+#define FIFO_LENGTH    offsetof(struct fst_fifo, fifo_length)
+#define READ_IDX       offsetof(struct fst_fifo, read_idx)
+#define WRITE_IDX      offsetof(struct fst_fifo, write_idx)
+#define OVERFLOW_IDX   offsetof(struct fst_fifo, overflow_idx)
+#define DATA_0         offsetof(struct fst_fifo, data[0])
+#define DATA_1         offsetof(struct fst_fifo, data[1])
+#define DATA_2         offsetof(struct fst_fifo, data[2])
+#define DATA_3         offsetof(struct fst_fifo, data[3])
+
+/* Transmit Fifo macros  */
+#define FST_DT_RDB(C, E)    readb((C)->mem + DT_OFFSET(E))
+#define FST_DT_RDW(C, E)    readw((C)->mem + DT_OFFSET(E))
+#define FST_DT_RDL(C, E)    readl((C)->mem + DT_OFFSET(E))
+
+#define FST_DT_WRB(C, E, B)  writeb((B), (C)->mem + DT_OFFSET(E))
+#define FST_DT_WRW(C, E, W)  writew((W), (C)->mem + DT_OFFSET(E))
+#define FST_DT_WRL(C, E, L)  writel((L), (C)->mem + DT_OFFSET(E))
+
+/* Receive Fifo macros */
+#define FST_DR_RDB(C, E)    readb((C)->mem + DR_OFFSET(E))
+#define FST_DR_RDW(C, E)    readw((C)->mem + DR_OFFSET(E))
+#define FST_DR_RDL(C, E)    readl((C)->mem + DR_OFFSET(E))
+
+#define FST_DR_WRB(C, E, B)  writeb((B), (C)->mem + DR_OFFSET(E))
+#define FST_DR_WRW(C, E, W)  writew((W), (C)->mem + DR_OFFSET(E))
+#define FST_DR_WRL(C, E, L)  writel((L), (C)->mem + DR_OFFSET(E))
+
 /*      Device driver private information
  *      =================================
  */
-/*      Per port (line or channel) information
- */
+
+/* Something to count interrupts */
+struct fst_ints {
+       unsigned long int_186;
+       unsigned long int_txdma;
+       unsigned long int_rxdma;
+       unsigned long int_no_work;
+};
+
+struct fst_ints fst_int_counter[FST_MAX_CARDS];
+
+struct fst_tx_buckets {
+       unsigned long txb0;
+       unsigned long txb1;
+       unsigned long txb2;
+       unsigned long txb4;
+       unsigned long txb8;
+};
+
+struct fst_rx_buckets {
+       unsigned long rxb0;
+       unsigned long rxb1;
+       unsigned long rxb2;
+       unsigned long rxb4;
+       unsigned long rxb8;
+};
+
+struct fst_tx_buckets tx_buckets[FST_MAX_CARDS];
+struct fst_rx_buckets rx_buckets[FST_MAX_CARDS];
+
+/* A multi-part tx/rx queue structure
+ * For long frame support a frame can be upto 32*1024 - 2 bytes in length
+ * This would occupy 4 tx/rx desriptors (each of 8k)
+ */
+struct fst_queue_info {
+       int count;              /* Total size of frame */
+       int segment_cnt;        /* Number of descriptors
+                                * required/used
+                                */
+       int current_seg;        /* Which segment we are currently doing */
+       unsigned char flags;    /* Start and End frame flags */
+       unsigned char error_recovery;
+       struct sk_buff *frame;  /* The complete skb */
+};
+
+/* Per port (line or channel) information  */
 struct fst_port_info {
-        struct net_device *dev; /* Device struct - must be first */
+       struct net_device *dev; /* device struct - must be first */
        struct fst_card_info *card;     /* Card we're associated with */
        int index;              /* Port index on the card */
-       int hwif;               /* Line hardware (lineInterface copy) */
+       int mode;               /* HDLC, Transparent, Async */
+       int hwif;               /* Line hardware (line_interface copy) */
        int run;                /* Port is running */
-       int mode;               /* Normal or FarSync raw */
+       int ignore_carrier;     /* Allow tx regardless of carrier state */
+       int proto;              /* Normal or FarSync raw */
+       int hdlc_proto;         /* The proto as hdlc understands it */
+       int num_tx_buffers;     /* No of tx buffers in card window */
+       int num_rx_buffers;     /* No of rx buffers in card window */
+       int tx_buffer_size;     /* Size of tx buffers in card window */
+       int rx_buffer_size;     /* Size of rx buffers in card window */
        int rxpos;              /* Next Rx buffer to use */
        int txpos;              /* Next Tx buffer to use */
        int txipos;             /* Next Tx buffer to check for free */
        int start;              /* Indication of start/stop to network */
-       /*
-        * A sixteen entry transmit queue
-        */
+       int notify_mode;        /* Application has selected the notify event */
+       int monitor_mode;       /* Application has selected monitor */
+       unsigned int sequence;  /* Monitor sequence no */
+       int port_mode;          /* DSL normal or active */
+       unsigned int atm_cells_dropped; /* Cells discarded by driver */
+       struct net_device_stats stats;  /* Standard statistics */
+       unsigned short vpi;     /* ATM VPI for DSL-S1 */
+       unsigned short vci;     /* ATM VCI for DSL-S1 */
+       unsigned char activation_status;        /* Current trained status*/
+       unsigned char encap;    /* type of atm encap ppp or mpoa */
+       unsigned char last_act_status;  /* Last trained status of line */
+       unsigned char atm_cell_header[5];       /* Pre calculated atm header */
+       unsigned char last_atm_cell_header[5];  /* Pre cal last atm header */
+       unsigned char mpoa_header[MPOA_HEADER_LEN];
+       unsigned int rx_latency;        /* Not yet supported */
+       unsigned char *rx_latency_buffer;       /* The fifo */
+       unsigned int tx_latency;        /* How much to buffer before we start
+                                        * transmitting
+                                        */
+       unsigned char *tx_latency_buffer;       /* The fifo */
+       unsigned int latency_rate;      /* The expected line rate */
+       unsigned int latency_reached;   /* If we are in latency mode, whether
+                                        * we can tx yet
+                                        */
+       /* A sixteen entry transmit queue */
        int txqs;               /* index to get next buffer to tx */
        int txqe;               /* index to queue next packet */
-       struct sk_buff *txq[FST_TXQ_DEPTH];     /* The queue */
-       int rxqdepth;
+       struct fst_queue_info txq[FST_TXQ_DEPTH];       /* The sent segments
+                                                        * info
+                                                        */
+       struct fst_queue_info rxq;      /* The received segments info */
+       struct file *char_file;
+       int char_opens;         /* The num of opens on the char dev */
+       spinlock_t rxf_lock;    /* Lock for queue head access */
+       struct fst_char_rx_frame *char_inq;
+       struct fst_char_rx_frame *char_inq_end;
+       unsigned char char_inq_max_len; /* Only allow this many frames */
+       unsigned char char_inq_threshold;       /* Generate a notify if */
+       wait_queue_head_t pollq;        /* poll() support */
+       wait_queue_head_t readq;        /* Blocking read support (char) */
+       wait_queue_head_t writeq;       /* Blocking write support (char) */
+       int mtu_for_rx_skb;
+       int minor_dev_no;
+       char low_latency;
+       char fstioc_info_ver;
+       char readv_mode;
+       unsigned char flow_controlled;
+       unsigned char exception;
+       struct fst_fifo *fifo_rxdata;
+       struct fst_fifo fifo_txdata;
+       char compat;
 };

-/*      Per card information
- */
+/*      Per card information  */
 struct fst_card_info {
-       char __iomem *mem;      /* Card memory mapped to kernel space */
-       char __iomem *ctlmem;   /* Control memory for PCI cards */
+       char *mem;              /* Card memory mapped to kernel space */
+       char *ctlmem;           /* Control memory for PCI cards */
        unsigned int phys_mem;  /* Physical memory window address */
        unsigned int phys_ctlmem;       /* Physical control memory address */
        unsigned int irq;       /* Interrupt request line number */
@@ -455,9 +958,18 @@ struct fst_card_info {
        unsigned int type;      /* Type index of card */
        unsigned int state;     /* State of card */
        spinlock_t card_lock;   /* Lock for SMP access */
+       spinlock_t fifo_lock;
+       wait_queue_head_t fifo_waitq;   /* A queue to wait for a msg fifo
+                                        * response
+                                        */
+       wait_queue_head_t cmdfifo_waitq;/* A queue to wait for a cmd fifo
+                                        * response
+                                        */
+       int fifo_complete;
+       int cmdfifo_complete[FST_MAX_PORTS];
        unsigned short pci_conf;        /* PCI card config in I/O space */
        /* Per port info */
-       struct fst_port_info ports[FST_MAX_PORTS];
+       struct fst_port_info *ports[FST_MAX_PORTS];
        struct pci_dev *device; /* Information about the pci device */
        int card_no;            /* Inst of the card on the system */
        int family;             /* TxP or TxU */
@@ -476,35 +988,11 @@ struct fst_card_info {
        int dma_len_tx;
        int dma_txpos;
        int dma_rxpos;
+       int dma_tx_flags;
+       int last_tx_port;
 };

-/* Convert an HDLC device pointer into a port info pointer and similar */
-#define dev_to_port(D)  (dev_to_hdlc(D)->priv)
-#define port_to_dev(P)  ((P)->dev)
-
-
-/*
- *      Shared memory window access macros
- *
- *      We have a nice memory based structure above, which could be directly
- *      mapped on i386 but might not work on other architectures unless we use
- *      the readb,w,l and writeb,w,l macros. Unfortunately these macros take
- *      physical offsets so we have to convert. The only saving grace is that
- *      this should all collapse back to a simple indirection eventually.
- */
-#define WIN_OFFSET(X)   ((long)&(((struct fst_shared *)SMC_BASE)->X))
-
-#define FST_RDB(C,E)    readb ((C)->mem + WIN_OFFSET(E))
-#define FST_RDW(C,E)    readw ((C)->mem + WIN_OFFSET(E))
-#define FST_RDL(C,E)    readl ((C)->mem + WIN_OFFSET(E))
-
-#define FST_WRB(C,E,B)  writeb ((B), (C)->mem + WIN_OFFSET(E))
-#define FST_WRW(C,E,W)  writew ((W), (C)->mem + WIN_OFFSET(E))
-#define FST_WRL(C,E,L)  writel ((L), (C)->mem + WIN_OFFSET(E))
-
-/*
- *      Debug support
- */
+/* Debug support */
 #if FST_DEBUG

 static int fst_debug_mask = { FST_DEBUG };
@@ -514,57 +1002,80 @@ static int fst_debug_mask = { FST_DEBUG
  * support variable numbers of macro parameters. The inverted if prevents us
  * eating someone else's else clause.
  */
-#define dbg(F, fmt, args...)                                   \
+#define fst_dbg(F, fmt, args...)                                       \
 do {                                                           \
        if (fst_debug_mask & (F))                               \
                printk(KERN_DEBUG pr_fmt(fmt), ##args);         \
 } while (0)
 #else
-#define dbg(F, fmt, args...)                                   \
+#define fst_dbg(F, fmt, args...)                                       \
 do {                                                           \
        if (0)                                                  \
                printk(KERN_DEBUG pr_fmt(fmt), ##args);         \
 } while (0)
 #endif

-/*
- *      PCI ID lookup table
- */
+/* PCI ID lookup table  */
 static DEFINE_PCI_DEVICE_TABLE(fst_pci_dev_id) = {
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
-
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4P, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_T4P},
-
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T1U, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_T1U},
-
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2U, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_T2U},
-
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4U, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_T4U},
-
-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
+       {
+#ifdef FSC_TXP_SUPPORT
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T2P}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4P, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T4P}, {
+#endif

-       {PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1C, PCI_ANY_ID,
-        PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
-       {0,}                    /* End */
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T1U, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T1U}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2U, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T2U}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4U, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T4U}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_TE1}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1C, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_TE1e}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_DSL_S1, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_DSL_S1}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2U_PMC,
+                   PCI_ANY_ID, PCI_ANY_ID, 0, 0, FST_TYPE_T2U_PMC}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4E, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T4E}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2UE, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T2UE}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4UE, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T4UE}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2Ee, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T2Ee}, {
+       PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4Ee, PCI_ANY_ID,
+                   PCI_ANY_ID, 0, 0, FST_TYPE_T4Ee}, {
+       0,}                     /* End */
 };

 MODULE_DEVICE_TABLE(pci, fst_pci_dev_id);

-/*
- *      Device Driver Work Queues
+static const char map_interface[14] = {
+       FSCMN_INTERFACE_AUTO,   /* 0 */
+       FSCMN_INTERFACE_V24,    /* 1  V24 */
+       FSCMN_INTERFACE_X21,    /* 2  X21 */
+       FSCMN_INTERFACE_V35,    /* 3  V35 */
+       FSCMN_INTERFACE_X21D,   /* 4  X21D */
+       FSCMN_INTERFACE_NO_CABLE,       /* 5  NOCABLE */
+       FSCMN_INTERFACE_RS530,  /* 6  RS530_449 */
+       0,                      /* 7  T1 */
+       0,                      /* 8  E1 */
+       0,                      /* 9  J1 */
+       0,                      /* 10 SHDSL */
+       FSCMN_INTERFACE_RS485,  /* 11 RS485 */
+       0,                      /* 12 UX35C */
+       FSCMN_INTERFACE_RS485_FDX       /* 13 RS485_FDX */
+};
+
+/*      Device Driver Work Queues
  *
- *      So that we don't spend too much time processing events in the
- *      Interrupt Service routine, we will declare a work queue per Card
+ *      So that we don't spend too much time processing events in the
+ *      Interrupt Service routine, we will declare a work queue per Card
  *      and make the ISR schedule a task in the queue for later execution.
- *      In the 2.4 Kernel we used to use the immediate queue for BH's
- *      Now that they are gone, tasklets seem to be much better than work
- *      queues.
  */

 static void do_bottom_half_tx(struct fst_card_info *card);
@@ -572,250 +1083,3069 @@ static void do_bottom_half_rx(struct fst
 static void fst_process_tx_work_q(unsigned long work_q);
 static void fst_process_int_work_q(unsigned long work_q);

-static DECLARE_TASKLET(fst_tx_task, fst_process_tx_work_q, 0);
-static DECLARE_TASKLET(fst_int_task, fst_process_int_work_q, 0);
+DECLARE_TASKLET(fst_tx_task, fst_process_tx_work_q, 0);
+DECLARE_TASKLET(fst_int_task, fst_process_int_work_q, 0);

-static struct fst_card_info *fst_card_array[FST_MAX_CARDS];
-static spinlock_t fst_work_q_lock;
-static u64 fst_work_txq;
-static u64 fst_work_intq;
+static void fst_process_tty_work(struct work_struct *work);
+static void fst_process_async_tty_work(struct work_struct *work);

-static void
-fst_q_work_item(u64 * queue, int card_index)
-{
-       unsigned long flags;
-       u64 mask;
+static struct work_struct fst_rx_work;

-       /*
-        * Grab the queue exclusively
-        */
-       spin_lock_irqsave(&fst_work_q_lock, flags);
+unsigned int fst_ncards;
+struct fst_card_info *fst_cards_list[FST_MAX_CARDS];
+struct fst_port_info *fst_ports_list[FST_MAX_CARDS * FST_MAX_PORTS];
+spinlock_t fst_work_q_lock;
+u64 fst_work_rxq;
+u64 fst_work_txq;
+u64 fst_work_intq;
+int last_segment_cnt;
+
+/* We need to send an idle cell when using mpoa encapsulation */
+char atm_idle_cell[53];
+
+static unsigned int fst_minor;
+static struct class *farsync_class;
+
+static unsigned int fst_major; /* The char driver major device number.
+                                * Setting it to 0 will cause us to use
+                                * dynamic allocation during module load
+                                */

-       /*
-        * Making an entry in the queue is simply a matter of setting
-        * a bit for the card indicating that there is work to do in the
-        * bottom half for the card.  Note the limitation of 64 cards.
-        * That ought to be enough
-        */
-       mask = (u64)1 << card_index;
-       *queue |= mask;
-       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+static char *type_strings[] = {
+       "no hardware",          /* Should never be seen */
+       "FarSync T2P    ",
+       "FarSync T4P    ",
+       "FarSync T1U    ",
+       "FarSync T2U    ",
+       "FarSync T4U    ",
+       "FarSync TE1    ",
+       "FarSync DSL-S1 ",
+       "FarSync T4E    ",
+       "Invalid (flex) ",
+       "FarSync T4Ue   ",
+       "FarSync T2Ue   ",
+       "FarSync T4E+   ",
+       "FarSync T2U-PMC",
+       "FarSync TE1e   ",
+       "FarSync T2Ee   ",
+       "FarSync T4Ee   ",
+       "Invalid (flex2) "
+};
+
+static char *state_strings[] = {
+       "Uninitialised",        /* Should never be seen */
+       "Reset",
+       "Downloading",
+       "Starting",
+       "Running",
+       "Bad Version",
+       "Halted",
+       "I Failed"
+};
+
+static void fst_openport(struct fst_port_info *port);
+static void fst_closeport(struct fst_port_info *port);
+static int fst_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static void fst_tx_dsl_dma(struct fst_card_info *card, unsigned char *skb,
+                          unsigned char *mem, int len);
+static void fst_rx_dsl_dma(struct fst_card_info *card, unsigned char *skb,
+                          unsigned char *mem, int len);
+
+#define XTOA(x) (((x) > (9)) ? (x + 0x37) : (x + 0x30))
+static unsigned char serial[16];
+
+void extract_serial(struct fst_card_info *card)
+{
+       serial[0] = (u8) (FST_RDW(card, _reserved[6]) >> 8);
+       serial[1] = XTOA((u8) ((FST_RDW(card, _reserved[13]) & 0xf)));
+       serial[2] = XTOA((u8) (((FST_RDB(card, _reserved[6]) >> 4) & 0xf)));
+       serial[3] = XTOA((u8) ((FST_RDW(card, _reserved[6]) & 0xf)));
+       serial[4] = XTOA((u8) (((FST_RDW(card, _reserved[15]) >> 12) & 0xf)));
+       serial[5] = XTOA((u8) (((FST_RDW(card, _reserved[15]) >> 8) & 0xf)));
+       serial[6] = XTOA((u8) (((FST_RDW(card, _reserved[15]) >> 4) & 0xf)));
+       serial[7] = XTOA((u8) ((FST_RDW(card, _reserved[15]) & 0xf)));
+       serial[8] = '\0';
+       serial[9] = '\0';
 }

-static void
-fst_process_tx_work_q(unsigned long /*void **/work_q)
+/* Convert an HDLC device pointer into a port info pointer and similar */
+#define dev_to_port(D)  (dev_to_hdlc(D)->priv)
+#define port_to_dev(P)  ((P)->dev)
+#define port_to_stats(P, S) (P->dev->stats.S)
+#define hdlc_stats(D) (&(D->stats))
+
+#define FIFO_ASY_CMD    0
+#define FIFO_ASY_TX     1
+#define FIFO_ASY_MSG    2
+#define FIFO_ASY_RX     3
+#define FIFO_ASY_RSP    4
+#define FIFO_ASY_RXEVNT 5
+#define FIFO_PORT_RX    6
+#define FIFO_PORT_TX    7
+
+static char *fifo_strings[] = {
+       "Command Fifo",
+       "Transmit Fifo",
+       "Message Fifo",
+       "Receive Fifo",
+       "Response Fifo",
+       "Rx Event Fifo",
+       "Port Rx Fifo",
+       "Port Tx Fifo"
+};
+
+static void fst_issue_cmd(struct fst_port_info *port, unsigned short cmd);
+
+/* Converts the struct fstioc_req from native byte order to Little Endian */
+static void fstioc_req_to_le(struct fstioc_req *sys_request)
 {
-       unsigned long flags;
-       u64 work_txq;
+       cpu_to_le16s(&sys_request->msg_type);
+       cpu_to_le16s(&sys_request->msg_len);
+       cpu_to_le16s(&sys_request->ret_code);
+       cpu_to_le16s(&sys_request->i_reg_idx);
+       cpu_to_le16s(&sys_request->value);
+}
+
+/* Converts the struct fstioc_req from Little Endian to native byte order */
+static void fstioc_req_to_cpu(struct fstioc_req *sys_request)
+{
+       le16_to_cpus(&sys_request->msg_type);
+       le16_to_cpus(&sys_request->msg_len);
+       le16_to_cpus(&sys_request->ret_code);
+       le16_to_cpus(&sys_request->i_reg_idx);
+       le16_to_cpus(&sys_request->value);
+}
+
+static void fifo_init(struct fst_card_info *card)
+{
+       struct fst_fifo fifo;
        int i;

-       /*
-        * Grab the queue exclusively
+       /* Initialise async window to zeros */
+       fst_dbg(DBG_ASS, "Zeroing %x bytes of async window\n", 0x9000);
+       memset_io(card->mem + AW_BASE, 0, 0x9000);
+
+       /* Initiliase the local copy of the fifo header and then
+        * Copy it to shared memeory.
+        * Do the fifo's to the card first followed by the fifo's from the card
         */
-       dbg(DBG_TX, "fst_process_tx_work_q\n");
-       spin_lock_irqsave(&fst_work_q_lock, flags);
-       work_txq = fst_work_txq;
-       fst_work_txq = 0;
-       spin_unlock_irqrestore(&fst_work_q_lock, flags);

-       /*
-        * Call the bottom half for each card with work waiting
+       /* must setup the fifo's length
+        * before writing the header back
         */
-       for (i = 0; i < FST_MAX_CARDS; i++) {
-               if (work_txq & 0x01) {
-                       if (fst_card_array[i] != NULL) {
-                               dbg(DBG_TX, "Calling tx bh for card %d\n", i);
-                               do_bottom_half_tx(fst_card_array[i]);
+       fifo.fifo_length = (u16) (FST_CMD_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+       fifo.overflow_idx = -1;
+       fifo.data[0] = 'D';
+       fifo.data[1] = 'E';
+       fifo.data[2] = 'A';
+       fifo.data[3] = 'D';
+
+       for (i = 0; i < FST_MAX_PORTS; i++) {
+               fst_dbg(DBG_FIFO, "Offset of cmd fifo[%d] is %lx\n", i,
+                       ASY_OFFSET(cmd_fifo[i]));
+
+               FST_A_WRW(card, cmd_fifo[i][FIFO_LENGTH], fifo.fifo_length);
+               FST_A_WRW(card, cmd_fifo[i][READ_IDX], fifo.read_idx);
+               FST_A_WRW(card, cmd_fifo[i][WRITE_IDX], fifo.write_idx);
+               FST_A_WRW(card, cmd_fifo[i][OVERFLOW_IDX], fifo.overflow_idx);
+               FST_A_WRB(card, cmd_fifo[i][DATA_0], fifo.data[0]);
+               FST_A_WRB(card, cmd_fifo[i][DATA_1], fifo.data[1]);
+               FST_A_WRB(card, cmd_fifo[i][DATA_2], fifo.data[2]);
+               FST_A_WRB(card, cmd_fifo[i][DATA_3], fifo.data[3]);
+       }
+
+       /* must setup the fifo's length
+        * before writing the header back
+        */
+       fifo.fifo_length = (u16) (FST_TX_DATA_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+
+       for (i = 0; i < FST_MAX_PORTS; i++) {
+               fst_dbg(DBG_FIFO, "Offset of tx fifo[%d] is %lx\n", i,
+                       ASY_OFFSET(tx_fifo[i]));
+               FST_A_WRW(card, tx_fifo[i][FIFO_LENGTH], fifo.fifo_length);
+               FST_A_WRW(card, tx_fifo[i][READ_IDX], fifo.read_idx);
+               FST_A_WRW(card, tx_fifo[i][WRITE_IDX], fifo.write_idx);
+               FST_A_WRW(card, tx_fifo[i][OVERFLOW_IDX], fifo.overflow_idx);
+               FST_A_WRB(card, tx_fifo[i][DATA_0], fifo.data[0]);
+               FST_A_WRB(card, tx_fifo[i][DATA_1], fifo.data[1]);
+               FST_A_WRB(card, tx_fifo[i][DATA_2], fifo.data[2]);
+               FST_A_WRB(card, tx_fifo[i][DATA_3], fifo.data[3]);
+       }
+
+       /* must setup the fifo's length
+        * before writing the header back
+        */
+       fifo.fifo_length = (u16) (FST_MSG_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+       fst_dbg(DBG_FIFO, "Offset of msg_fifo is %lx\n", ASY_OFFSET(msg_fifo));
+
+       FST_A_WRW(card, msg_fifo[FIFO_LENGTH], fifo.fifo_length);
+       FST_A_WRW(card, msg_fifo[READ_IDX], fifo.read_idx);
+       FST_A_WRW(card, msg_fifo[WRITE_IDX], fifo.write_idx);
+       FST_A_WRW(card, msg_fifo[OVERFLOW_IDX], fifo.overflow_idx);
+       FST_A_WRB(card, msg_fifo[DATA_0], fifo.data[0]);
+       FST_A_WRB(card, msg_fifo[DATA_1], fifo.data[1]);
+       FST_A_WRB(card, msg_fifo[DATA_2], fifo.data[2]);
+       FST_A_WRB(card, msg_fifo[DATA_3], fifo.data[3]);
+
+       fifo.data[0] = 'B';
+       fifo.data[1] = 'E';
+       fifo.data[2] = 'E';
+       fifo.data[3] = 'F';
+
+       /* must setup the fifo's length
+        * before writing the header back
+        */
+       fifo.fifo_length = (u16) (FST_RX_DATA_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+       for (i = 0; i < FST_MAX_PORTS; i++) {
+               fst_dbg(DBG_FIFO, "Offset of rx fifo[%d] is %lx\n", i,
+                       ASY_OFFSET(rx_fifo[i]));
+               FST_A_WRW(card, rx_fifo[i][FIFO_LENGTH], fifo.fifo_length);
+               FST_A_WRW(card, rx_fifo[i][READ_IDX], fifo.read_idx);
+               FST_A_WRW(card, rx_fifo[i][WRITE_IDX], fifo.write_idx);
+               FST_A_WRW(card, rx_fifo[i][OVERFLOW_IDX], fifo.overflow_idx);
+               FST_A_WRB(card, rx_fifo[i][DATA_0], fifo.data[0]);
+               FST_A_WRB(card, rx_fifo[i][DATA_1], fifo.data[1]);
+               FST_A_WRB(card, rx_fifo[i][DATA_2], fifo.data[2]);
+               FST_A_WRB(card, rx_fifo[i][DATA_3], fifo.data[3]);
+       }
+
+       /* must setup the fifo's length
+        * before writing the header back
+        */
+       fifo.fifo_length = (u16) (MAX_RX_EVENT_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+
+       for (i = 0; i < FST_MAX_PORTS; i++) {
+               fst_dbg(DBG_FIFO, "Offset of rx event fifo[%d] is %lx\n", i,
+                       ASY_OFFSET(rx_event_fifos[i]));
+               FST_A_WRW(card, rx_event_fifos[i][FIFO_LENGTH],
+                         fifo.fifo_length);
+               FST_A_WRW(card, rx_event_fifos[i][READ_IDX], fifo.read_idx);
+               FST_A_WRW(card, rx_event_fifos[i][WRITE_IDX], fifo.write_idx);
+               FST_A_WRW(card, rx_event_fifos[i][OVERFLOW_IDX],
+                         fifo.overflow_idx);
+               FST_A_WRB(card, rx_event_fifos[i][DATA_0], fifo.data[0]);
+               FST_A_WRB(card, rx_event_fifos[i][DATA_1], fifo.data[1]);
+               FST_A_WRB(card, rx_event_fifos[i][DATA_2], fifo.data[2]);
+               FST_A_WRB(card, rx_event_fifos[i][DATA_3], fifo.data[3]);
+       }
+
+       /* must setup the fifo's length
+        * before writing the header back
+        */
+       fifo.fifo_length = (u16) (FST_RSP_FIFO_LEN + 1);
+       fifo.read_idx = (u16) (fifo.fifo_length - 1);
+       fifo.write_idx = (u16) (fifo.fifo_length - 1);
+       fst_dbg(DBG_FIFO, "Offset of rsp fifo is %lx\n", ASY_OFFSET(rsp_fifo));
+       FST_A_WRW(card, rsp_fifo[FIFO_LENGTH], fifo.fifo_length);
+       FST_A_WRW(card, rsp_fifo[READ_IDX], fifo.read_idx);
+       FST_A_WRW(card, rsp_fifo[WRITE_IDX], fifo.write_idx);
+       FST_A_WRW(card, rsp_fifo[OVERFLOW_IDX], fifo.overflow_idx);
+       FST_A_WRB(card, rsp_fifo[DATA_0], fifo.data[0]);
+       FST_A_WRB(card, rsp_fifo[DATA_1], fifo.data[1]);
+       FST_A_WRB(card, rsp_fifo[DATA_2], fifo.data[2]);
+       FST_A_WRB(card, rsp_fifo[DATA_3], fifo.data[3]);
+}
+
+static void fifo_reset(struct fst_card_info *card, int port_index)
+{
+       struct fst_fifo fifo;
+
+       /* Flush the tx fifo
+        * and reset the read_idx to be the same as the write_idx
+        * on the rx fifo
+        */
+       fst_issue_cmd(card->ports[port_index], FLUSHTX);
+       fifo.fifo_length = FST_A_RDW(card, rx_fifo[port_index][FIFO_LENGTH]);
+       fifo.read_idx = FST_A_RDW(card, rx_fifo[port_index][READ_IDX]);
+       fifo.write_idx = FST_A_RDW(card, rx_fifo[port_index][WRITE_IDX]);
+       fifo.overflow_idx = FST_A_RDW(card, rx_fifo[port_index][OVERFLOW_IDX]);
+
+       fst_dbg(DBG_FIFO,
+               "Re-aligning fifo indexes: read index = %d write index = %d\n",
+               fifo.read_idx, fifo.write_idx);
+
+       fifo.read_idx = fifo.write_idx;
+       FST_A_WRW(card, rx_fifo[port_index][FIFO_LENGTH], fifo.fifo_length);
+       FST_A_WRW(card, rx_fifo[port_index][READ_IDX], fifo.read_idx);
+       FST_A_WRW(card, rx_fifo[port_index][WRITE_IDX], fifo.write_idx);
+       FST_A_WRW(card, rx_fifo[port_index][OVERFLOW_IDX], fifo.overflow_idx);
+}
+
+static int check_fifo_space(char *actual_fifo, int fifo_select)
+{
+       int h_size = 0;
+       struct fst_fifo fifo;
+       u16 avail_fifo_space = 0;
+       u16 used_space = 0;
+       u16 free_space = 0;
+       u16 next_write_idx = 0;
+
+       h_size = sizeof(struct fst_fifo) - 4;
+       fst_dbg(DBG_FIFO,
+               "check_fifo_space [%s]\n", fifo_strings[fifo_select]);
+       /* Make a local copy of the fifo while we update it */
+       fifo.fifo_length = FIFO_RDW(actual_fifo + FIFO_LENGTH);
+       fifo.read_idx = FIFO_RDW(actual_fifo + READ_IDX);
+       fifo.write_idx = FIFO_RDW(actual_fifo + WRITE_IDX);
+       fifo.overflow_idx = FIFO_RDW(actual_fifo + OVERFLOW_IDX);
+
+       next_write_idx = (u16) ((fifo.write_idx + 1) % fifo.fifo_length);
+       fst_dbg(DBG_FIFO, "next_write_idx = %d\n", next_write_idx);
+       free_space = (u16) ((fifo.read_idx - next_write_idx +
+                            fifo.fifo_length) % fifo.fifo_length);
+       used_space = (u16) (fifo.fifo_length - free_space - 1);
+       avail_fifo_space = fifo.fifo_length - used_space;
+       fst_dbg(DBG_FIFO,
+       "size = %d, free_space = %d, used_space = %d, avail_fifo_space = %d\n",
+               fifo.fifo_length, free_space, used_space, avail_fifo_space);
+       avail_fifo_space = (u16) min_t(u16, avail_fifo_space,
+                                      (u16) fifo.fifo_length);
+       fst_dbg(DBG_FIFO, "Check fifo space [%s] returning %d\n",
+               fifo_strings[fifo_select], used_space);
+       return used_space;
+}
+
+static int write_into_fifo(char *actual_fifo, int fifo_select,
+                          char *request, int msg_len)
+{
+       int retval = -1;
+       int h_size = 0;
+       struct fst_fifo fifo;
+       u16 avail_fifo_space = 0;
+       u16 used_space = 0;
+       u16 free_space = 0;
+       u16 next_write_idx = 0;
+       u16 first_write_amount = 0;
+       u16 second_write_amount = 0;
+
+       h_size = sizeof(struct fst_fifo) - 4;
+       fst_dbg(DBG_FIFO, "write_into_fifo [%s]  a message of %d bytes\n",
+               fifo_strings[fifo_select], msg_len);
+       /* Make a local copy of the fifo while we update it */
+
+       fifo.fifo_length = FIFO_RDW(actual_fifo + FIFO_LENGTH);
+       fifo.read_idx = FIFO_RDW(actual_fifo + READ_IDX);
+       fifo.write_idx = FIFO_RDW(actual_fifo + WRITE_IDX);
+       fifo.overflow_idx = FIFO_RDW(actual_fifo + OVERFLOW_IDX);
+
+       next_write_idx = (u16) ((fifo.write_idx + 1) % fifo.fifo_length);
+       fst_dbg(DBG_FIFO, "next_write_idx = %d\n", next_write_idx);
+       free_space = (u16) ((fifo.read_idx - next_write_idx +
+                            fifo.fifo_length) % fifo.fifo_length);
+       used_space = (u16) (fifo.fifo_length - free_space - 1);
+       avail_fifo_space = fifo.fifo_length - used_space;
+       fst_dbg(DBG_FIFO,
+       "size = %d, free_space = %d, used_space = %d, avail_fifo_space = %d\n",
+               fifo.fifo_length, free_space, used_space, avail_fifo_space);
+       avail_fifo_space = (u16) min_t(u16, avail_fifo_space,
+                                    (u16) fifo.fifo_length);
+
+       if (fifo.overflow_idx == -1) {
+               fst_dbg(DBG_FIFO, "msg_fifo.overflow_idx = -1\n");
+               if (avail_fifo_space >= msg_len) {
+                       fst_dbg(DBG_FIFO,
+                               "And there is space to write data\n");
+                       /* How much of it can we write into the end fragment */
+                       first_write_amount = min_t(u16, msg_len,
+                                                (fifo.fifo_length -
+                                                 next_write_idx));
+                       fst_dbg(DBG_FIFO, "First write amount is %d\n",
+                               first_write_amount);
+                       fst_dbg(DBG_FIFO, "Next write index is %d\n",
+                               next_write_idx);
+                       fst_dbg(DBG_FIFO, "Copying to offset %p\n",
+                               actual_fifo + h_size + next_write_idx);
+                       if (first_write_amount > fifo.fifo_length) {
+                               fst_dbg(DBG_FIFO, "Fifo length error %d %d\n",
+                                      first_write_amount, fifo.fifo_length);
+                               return retval;
+                       }
+                       memcpy_toio(actual_fifo + h_size + next_write_idx,
+                                   request, first_write_amount);
+                       fifo.write_idx =
+                           (u16) ((fifo.write_idx + first_write_amount)
+                                  % fifo.fifo_length);
+                       fst_dbg(DBG_FIFO, "Write Index updated to %d\n",
+                               fifo.write_idx);
+                       if (first_write_amount != msg_len) {
+                               fst_dbg(DBG_FIFO,
+                               "We need a second chunk because of wrap\n");
+                               /* were do we start writing the next chunk
+                                * to
+                                */
+                               next_write_idx = (u16) ((fifo.write_idx + 1) %
+                                                       fifo.fifo_length);
+
+                               /* write the rest into the starting fragment */
+                               second_write_amount = (u16) (msg_len -
+                                                    first_write_amount);
+                               if (second_write_amount > fifo.fifo_length) {
+                                       fst_dbg(DBG_FIFO,
+                                       "Fifo length error on 2nd write %d %d\n",
+                                               second_write_amount,
+                                               fifo.fifo_length);
+                                       return retval;
+                               }
+                               fst_dbg(DBG_FIFO,
+                                       "Second write amount is %d\n",
+                                       second_write_amount);
+                               fst_dbg(DBG_FIFO, "Next write index is %d\n",
+                                       next_write_idx);
+                               fst_dbg(DBG_FIFO, "Copying to offset %p\n",
+                                       actual_fifo + h_size + next_write_idx);
+                               memcpy_toio(actual_fifo + h_size +
+                                           next_write_idx,
+                                           request + first_write_amount,
+                                           second_write_amount);
+                               fifo.write_idx =
+                                   (u16) ((fifo.write_idx +
+                                           second_write_amount)
+                                          % fifo.fifo_length);
                        }
+                       retval = 0;
+               } else {
+                 fst_dbg(DBG_FIFO,
+                         "%s: No room in fifo (%d) for %d bytes of data\n",
+                            fifo_strings[fifo_select], avail_fifo_space,
+                            msg_len);
                }
-               work_txq = work_txq >> 1;
+       } else {
+         fst_dbg(DBG_FIFO, "write_into_fifo: [%s] fifo overflow\n",
+                      fifo_strings[fifo_select]);
+               fifo.overflow_idx = fifo.write_idx;
        }
+
+       fst_dbg(DBG_FIFO, "Updating the fifo header\n");
+       /* Write the local copy back (of write_idx and overflow idx)
+        * to the fifo
+        */
+       FIFO_WRW(actual_fifo + WRITE_IDX, fifo.write_idx);
+       FIFO_WRW(actual_fifo + OVERFLOW_IDX, fifo.overflow_idx);
+
+       return retval;
 }

-static void
-fst_process_int_work_q(unsigned long /*void **/work_q)
+static int read_from_fifo(char *actual_fifo, int fifo_select,
+                         char *data, int msg_len)
 {
-       unsigned long flags;
-       u64 work_intq;
-       int i;
-
+       int h_size = 0;
+       struct fst_fifo fifo;
+       u16 next_read_idx = 0;
+       u16 amount_to_read = 0;
+       char *data1 = NULL;
+       u16 length1;
+       char *data2 = NULL;
+       u16 length2;
+       u16 data_len;
+
+       fst_dbg(DBG_FIFO, "read_from_fifo [%s] into buffer of size %d\n",
+               fifo_strings[fifo_select], msg_len);
+       h_size = sizeof(struct fst_fifo) - 4;
        /*
-        * Grab the queue exclusively
+        * Get the fifo header
         */
-       dbg(DBG_INTR, "fst_process_int_work_q\n");
-       spin_lock_irqsave(&fst_work_q_lock, flags);
-       work_intq = fst_work_intq;
-       fst_work_intq = 0;
-       spin_unlock_irqrestore(&fst_work_q_lock, flags);
-
-       /*
-        * Call the bottom half for each card with work waiting
+       fifo.fifo_length = FIFO_RDW(actual_fifo + FIFO_LENGTH);
+       fifo.read_idx = FIFO_RDW(actual_fifo + READ_IDX);
+       fifo.write_idx = FIFO_RDW(actual_fifo + WRITE_IDX);
+       fifo.overflow_idx = FIFO_RDW(actual_fifo + OVERFLOW_IDX);
+       if (fifo.fifo_length > (FST_RX_DATA_FIFO_LEN + 1)) {
+               fst_dbg(DBG_FIFO, "fifo size error! %d\n", fifo.fifo_length);
+               return 0;
+       }
+       /* Work out the length of data in the fifo */
+       data_len = (fifo.write_idx - fifo.read_idx + fifo.fifo_length)
+           % fifo.fifo_length;
+       fst_dbg(DBG_FIFO, "Actual amount of data in the fifo is %d\n",
+               data_len);
+       /* But we will only take the smaller of the length of data
+        * in the fifo or the length of the buffer we have been given
+        * to copy the data into
         */
-       for (i = 0; i < FST_MAX_CARDS; i++) {
-               if (work_intq & 0x01) {
-                       if (fst_card_array[i] != NULL) {
-                               dbg(DBG_INTR,
-                                   "Calling rx & tx bh for card %d\n", i);
-                               do_bottom_half_rx(fst_card_array[i]);
-                               do_bottom_half_tx(fst_card_array[i]);
-                       }
+       amount_to_read = (u16) min_t(u16, data_len, (u16) msg_len);
+       fst_dbg(DBG_FIFO, "amount to read is %d\n", amount_to_read);
+       if (amount_to_read > 0) {
+               /* where should we start reading from ? */
+               next_read_idx = (fifo.read_idx + 1) % fifo.fifo_length;
+               fst_dbg(DBG_FIFO, "Next read index = %d\n", next_read_idx);
+               if (next_read_idx > (FST_RX_DATA_FIFO_LEN + 1)) {
+                       fst_dbg(DBG_FIFO, "read index size error!\n");
+                       return 0;
                }
-               work_intq = work_intq >> 1;
+               data1 = &actual_fifo[next_read_idx + h_size];
+               length1 = (u16) min_t(u16, amount_to_read,
+                                   (u16) (fifo.fifo_length - next_read_idx));
+               fst_dbg(DBG_FIFO, "length1 = %d\n", length1);
+               if (amount_to_read > (FST_RX_DATA_FIFO_LEN + 1)) {
+                       fst_dbg(DBG_FIFI, "amount to read size error!\n");
+                       return 0;
+               }
+               data2 = actual_fifo + h_size;
+               length2 = amount_to_read - length1;
+               fst_dbg(DBG_FIFO, "length2 = %d\n", length2);
+               fst_dbg(DBG_FIFO,
+                       "Copying 1st blob from offset %p of length %d\n",
+                       data1, length1);
+               memcpy_fromio(data, data1, length1);
+
+               if (length2) {
+                       fst_dbg(DBG_ASS, "Copying from offset %p\n", data2);
+                       memcpy_fromio(data + length1, data2, length2);
+               }
+               fifo.read_idx = (fifo.read_idx + amount_to_read) %
+                   fifo.fifo_length;
+               /* Write the fifo header back as we have taken some data */
+               FIFO_WRW(actual_fifo + READ_IDX, fifo.read_idx);
+               fst_dbg(DBG_FIFO, "read_from_fifo: Amount read was %d\n",
+                       length1 + length2);
+               return amount_to_read;
        }
+       return 0;
 }

-/*      Card control functions
- *      ======================
- */
-/*      Place the processor in reset state
- *
- * Used to be a simple write to card control space but a glitch in the latest
- * AMD Am186CH processor means that we now have to do it by asserting and de-
- * asserting the PLX chip PCI Adapter Software Reset. Bit 30 in CNTRL register
- * at offset 9052_CNTRL.  Note the updates for the TXU.
+static void fst_reset_rx_fifo(struct fst_port_info *port)
+{
+       int used_space;
+
+       used_space = ((port->fifo_rxdata->write_idx -
+                      port->fifo_rxdata->read_idx));
+       if (used_space < 0) {
+               fst_dbg(DBG_FIFO, "adjusting used_space %d\n", used_space);
+               used_space = used_space + FST_RX_DATA_FIFO_LEN;
+       }
+       fst_dbg(DBG_FIFO, "%s: Resetting Rx Fifo %d %d\n", port->dev->name,
+               port->fifo_rxdata->write_idx, port->fifo_rxdata->read_idx);
+       fst_dbg(DBG_FIFO, "%s: %d bytes left in fifo\n", port->dev->name,
+               used_space);
+       port->fifo_rxdata->fifo_length = (u16) (FST_RX_DATA_FIFO_LEN + 1);
+       port->fifo_rxdata->read_idx =
+           (u16) (port->fifo_rxdata->fifo_length - 1);
+       port->fifo_rxdata->write_idx =
+           (u16) (port->fifo_rxdata->fifo_length - 1);
+       port->fifo_rxdata->overflow_idx = -1;
+}
+
+static void
+fst_intr_async_rx(struct fst_card_info *card, struct fst_port_info *port);
+
+static void
+fst_intr_async_rx_event(struct fst_card_info *card,
+                       struct fst_port_info *port);
+
+/* Check to see if the TX Fifo is at least half full
+ * If so then signal to select that another write can be made
  */
-static inline void
-fst_cpureset(struct fst_card_info *card)
+static void check_tx_fifos(struct fst_card_info *card)
 {
-       unsigned char interrupt_line_register;
-       unsigned long j = jiffies + 1;
-       unsigned int regval;
+       struct fst_fifo fifo;
+       int length;
+       int i;

-       if (card->family == FST_FAMILY_TXU) {
-               if (pci_read_config_byte
-                   (card->device, PCI_INTERRUPT_LINE, &interrupt_line_register)) {
-                       dbg(DBG_ASS,
-                           "Error in reading interrupt line register\n");
+       /* This is for the port shared memory tx fifo only */
+       fst_dbg(DBG_FIFO, "Check tx fifo's\n");
+       for (i = 0; i < card->nports; i++) {
+               if ((card->ports[i]->run)
+                   && (card->ports[i]->mode == FST_MODE_ASYNC)) {
+                       fifo.fifo_length =
+                           FST_A_RDW(card, tx_fifo[i][FIFO_LENGTH]);
+                       fifo.read_idx = FST_A_RDW(card, tx_fifo[i][READ_IDX]);
+                       fifo.write_idx =
+                         FST_A_RDW(card, tx_fifo[i][WRITE_IDX]);
+                       fifo.overflow_idx =
+                           FST_A_RDW(card, tx_fifo[i][OVERFLOW_IDX]);
+
+                       memcpy(&card->ports[i]->fifo_txdata, &fifo,
+                              sizeof(struct fst_fifo));
+                       length = (fifo.write_idx - fifo.read_idx);
+                       if (length < 0)
+                               length += fifo.fifo_length;
+                       if (length < fifo.fifo_length / 2) {
+                               fst_dbg(DBG_ASS,
+                                       "%s: Room in the Tx Fifo (%d)\n",
+                                       card->ports[i]->dev->name, length);
+                               wake_up_interruptible(&card->ports[i]->pollq);
+                               wake_up_interruptible(&card->ports[i]->writeq);
+                       }
+                       if (length == 0) {
+                               fst_dbg(DBG_FIFO,
+                                       "%s: We let the tx fifo stutter!\n",
+                                       card->ports[i]->dev->name);
+                       }
                }
-               /*
-                * Assert PLX software reset and Am186 hardware reset
-                * and then deassert the PLX software reset but 186 still in reset
-                */
-               outw(0x440f, card->pci_conf + CNTRL_9054 + 2);
-               outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
-               /*
-                * We are delaying here to allow the 9054 to reset itself
-                */
-               j = jiffies + 1;
+       }
+}
+
+static void check_rx_fifos(struct fst_card_info *card)
+{
+       struct fst_fifo fifo;
+       int i;
+
+       /* This is for the port shared memory rx fifos only */
+       fst_dbg(DBG_FIFO, "Check rx fifo's\n");
+       for (i = 0; i < card->nports; i++) {
+               fifo.fifo_length = FST_A_RDW(card, rx_fifo[i][FIFO_LENGTH]);
+               fifo.read_idx = FST_A_RDW(card, rx_fifo[i][READ_IDX]);
+               fifo.write_idx = FST_A_RDW(card, rx_fifo[i][WRITE_IDX]);
+               fifo.overflow_idx = FST_A_RDW(card, rx_fifo[i][OVERFLOW_IDX]);
+               if (fifo.read_idx != fifo.write_idx) {
+                       fst_dbg(DBG_FIFO, "%s: Data found in Rx Fifo\n",
+                               card->ports[i]->dev->name);
+                       fst_intr_async_rx(card, card->ports[i]);
+               }
+       }
+}
+
+static void check_rx_event_fifos(struct fst_card_info *card)
+{
+       struct fst_fifo fifo;
+       int i;
+
+       /* This is for the port shared memory rx events fifos only
+        * This is where errors are reported
+        */
+       fst_dbg(DBG_FIFO, "Check rx event fifo's\n");
+       for (i = 0; i < card->nports; i++) {
+               fifo.fifo_length =
+                   FST_A_RDW(card, rx_event_fifos[i][FIFO_LENGTH]);
+               fifo.read_idx = FST_A_RDW(card, rx_event_fifos[i][READ_IDX]);
+               fifo.write_idx = FST_A_RDW(card, rx_event_fifos[i][WRITE_IDX]);
+               fifo.overflow_idx =
+                   FST_A_RDW(card, rx_event_fifos[i][OVERFLOW_IDX]);
+               if (fifo.read_idx != fifo.write_idx) {
+                       fst_dbg(DBG_ASS, "%s: Rx Event found\n",
+                               card->ports[i]->dev->name);
+                       fst_intr_async_rx_event(card, card->ports[i]);
+                       port_to_stats(card->ports[i], rx_errors)++;
+               }
+       }
+}
+
+static void check_fifo_resp(struct fst_card_info *card)
+{
+       u16 used_space = 0;
+       u16 free_space = 0;
+       u16 next_write_idx = 0;
+       struct fst_fifo fifo;
+
+       /* This is for the command/response fifo only */
+       fst_dbg(DBG_FIFO, "Check fifo response\n");
+       fifo.fifo_length = FST_A_RDW(card, rsp_fifo[FIFO_LENGTH]);
+       fifo.read_idx = FST_A_RDW(card, rsp_fifo[READ_IDX]);
+       fifo.write_idx = FST_A_RDW(card, rsp_fifo[WRITE_IDX]);
+       fifo.overflow_idx = FST_A_RDW(card, rsp_fifo[OVERFLOW_IDX]);
+       next_write_idx = (fifo.write_idx + 1) % fifo.fifo_length;
+       free_space = (fifo.read_idx - next_write_idx + fifo.fifo_length) %
+           fifo.fifo_length;
+       used_space = fifo.fifo_length - free_space - 1;
+
+       if (used_space >= sizeof(struct fstioc_req)) {
+               /*
+                * we have a response to process so wake the queue that
+                * the process should be waiting on
+                */
+               fst_dbg(DBG_FIFO, "Rsp Fifo has data waiting\n");
+               card->fifo_complete = 1;
+               wake_up_interruptible(&card->fifo_waitq);
+       }
+}
+
+static void check_cmdfifo_done(struct fst_card_info *card)
+{
+       u16 used_space = 0;
+       u16 free_space = 0;
+       u16 next_write_idx = 0;
+       struct fst_fifo fifo;
+       int i;
+
+       /* This is for the command/response fifo only */
+       fst_dbg(DBG_FIFO, "Check command fifo processed\n");
+
+       for (i = 0; i < card->nports; i++) {
+               fifo.fifo_length = FST_A_RDW(card, cmd_fifo[i][FIFO_LENGTH]);
+               fifo.read_idx = FST_A_RDW(card, cmd_fifo[i][READ_IDX]);
+               fifo.write_idx = FST_A_RDW(card, cmd_fifo[i][WRITE_IDX]);
+               fifo.overflow_idx = FST_A_RDW(card, cmd_fifo[i][OVERFLOW_IDX]);
+
+               next_write_idx = (fifo.write_idx + 1) % fifo.fifo_length;
+               free_space =
+                   (fifo.read_idx - next_write_idx +
+                    fifo.fifo_length) % fifo.fifo_length;
+               used_space = fifo.fifo_length - free_space - 1;
+
+               if (used_space == 0) {
+                       /*
+                        * The last command we sent has been processed
+                        */
+                       fst_dbg(DBG_FIFO, "Cmd Fifo now empty\n");
+                       card->cmdfifo_complete[i] = 1;
+                       wake_up_interruptible(&card->cmdfifo_waitq);
+               } else {
+                       fst_dbg(DBG_FIFO, "Used space is still %d\n",
+                               used_space);
+               }
+       }
+}
+
+static int fst_alloc_rx_fifo(struct fst_port_info *port)
+{
+
+       /* Allocate the data for the fifo */
+       port->fifo_rxdata = kmalloc(FST_RX_DATA_FIFO_LEN
+                                   + sizeof(struct fst_fifo), GFP_ATOMIC);
+       if (port->fifo_rxdata == NULL) {
+               fst_dbg(DBG_FIFO,
+                       "fifo_init: can't allocate %u bytes for Fifo\n",
+                      (unsigned int)(FST_RX_DATA_FIFO_LEN +
+                                     sizeof(struct fst_fifo)));
+               return 1;
+       }
+       fst_dbg(DBG_FIFO, "%s: Fifo memory allocated at %p\n",
+               port->dev->name, port->fifo_rxdata);
+       /* Now initialise it
+        * must setup the fifo's length
+        */
+       port->fifo_rxdata->fifo_length = (u16) (FST_RX_DATA_FIFO_LEN + 1);
+       port->fifo_rxdata->read_idx =
+           (u16) (port->fifo_rxdata->fifo_length - 1);
+       port->fifo_rxdata->write_idx =
+           (u16) (port->fifo_rxdata->fifo_length - 1);
+       port->fifo_rxdata->overflow_idx = -1;
+       port->fifo_rxdata->data[0] = 'F';
+       port->fifo_rxdata->data[1] = '1';
+       port->fifo_rxdata->data[2] = 'D';
+       port->fifo_rxdata->data[3] = '0';
+       return 0;
+}
+
+struct net_device *get_net_device(int if_index)
+{
+       struct net_device *dev;
+
+       dev = port_to_dev(fst_ports_list[if_index]);
+       fst_dbg(DBG_ASS, "get_net_device: returning %s\n", dev->name);
+       return dev;
+}
+
+/* Sooner or later you can't avoid a forward declaration */
+static int fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
+
+static const speed_t baud_table[] = {
+       0, 50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800,
+       9600, 19200, 38400, 57600, 115200, 230400, 460800,
+       500000, 576000, 921600, 1000000, 1152000, 1500000, 2000000,
+       2500000, 3000000, 3500000, 4000000
+};
+
+static int n_baud_table = ARRAY_SIZE(baud_table);
+
+static unsigned int get_baud(tcflag_t c_cflag)
+{
+       unsigned int baud;
+
+       baud = c_cflag & CBAUD;
+       if (baud & CBAUDEX) {
+               baud &= ~CBAUDEX;
+
+               if (baud < 1 || baud + 15 > n_baud_table)
+                       c_cflag &= ~CBAUDEX;
+               else
+                       baud += 15;
+       }
+       baud = baud_table[baud];
+       fst_dbg(DBG_IOCTL, "Baud rate was %d\n", baud);
+       return baud;
+}
+
+static unsigned int get_rtscts(tcflag_t c_cflag)
+{
+       unsigned int rtscts;
+
+       rtscts = c_cflag & CRTSCTS;
+       fst_dbg(DBG_IOCTL, "rtscts was %x\n", rtscts);
+       if (rtscts)
+               return 1;
+       else
+               return 0;
+}
+
+static unsigned int get_xonxoff(tcflag_t c_iflag)
+{
+       unsigned int xon, xoff;
+
+       xon = c_iflag & IXON;
+       xoff = c_iflag & IXOFF;
+       fst_dbg(DBG_IOCTL, "xon was %x xoff was %x\n", xon, xoff);
+       if (xon && xoff)
+               return 2;
+       else
+               return 0;
+}
+
+static unsigned int get_char_size(tcflag_t c_cflag)
+{
+       unsigned int char_size;
+
+       char_size = c_cflag & CSIZE;
+       fst_dbg(DBG_IOCTL, "Character size = %d\n", char_size);
+       switch (char_size) {
+       case CS5:
+               fst_dbg(DBG_IOCTL, "Character size set as 5 bits\n");
+               return 5;
+
+       case CS6:
+               fst_dbg(DBG_IOCTL, "Character size set as 6 bits\n");
+               return 6;
+
+       case CS7:
+               fst_dbg(DBG_IOCTL, "Character size set as 7 bits\n");
+               return 7;
+
+       case CS8:
+       default:
+               fst_dbg(DBG_IOCTL, "Character size set as 8 bits\n");
+               return 8;
+       }
+}
+
+static unsigned int get_stop_bits(tcflag_t c_cflag)
+{
+       unsigned int stop_bits;
+
+       stop_bits = c_cflag & CSTOPB;
+       fst_dbg(DBG_IOCTL, "Stop bits = %d\n", stop_bits);
+       if (stop_bits) {
+               fst_dbg(DBG_IOCTL, "2 stop bits selected\n");
+               return 2;
+       }
+       fst_dbg(DBG_IOCTL, "1 stop bit selected\n");
+       return 1;
+}
+
+static unsigned int get_parity(tcflag_t c_cflag)
+{
+       unsigned int parity_enable, parity;
+
+       parity_enable = c_cflag & PARENB;
+       parity = c_cflag & PARODD;
+       fst_dbg(DBG_IOCTL, "Parity enable is %d and parity odd is %d\n",
+               parity_enable, parity);
+       if (parity_enable) {
+               if (parity) {
+                       fst_dbg(DBG_IOCTL, "Returning Odd Parity\n");
+                       return 1;
+               } else {
+                       fst_dbg(DBG_IOCTL, "Returning Even Parity\n");
+                       return 2;
+               }
+       } else {
+               fst_dbg(DBG_IOCTL, "Parity not enabled\n");
+               return 0;
+       }
+}
+
+static void
+init_async_parameters(struct fst_port_info *port,
+                     unsigned int char_size, unsigned int stop_bits,
+                     unsigned int parity, unsigned int flow_control)
+{
+       fst_dbg(DBG_IOCTL, "%s: Initialising async parameters\n",
+               port->dev->name);
+       FST_A_WRB(port->card, async_config[port->index].flow_control,
+                 flow_control);
+       FST_A_WRB(port->card, async_config[port->index].xon_char, 0x11);
+       FST_A_WRB(port->card, async_config[port->index].xoff_char, 0x13);
+       FST_A_WRB(port->card, async_config[port->index].word_length,
+                 char_size);
+       FST_A_WRB(port->card, async_config[port->index].stop_bits, stop_bits);
+       FST_A_WRB(port->card, async_config[port->index].parity, parity);
+       fst_dbg(DBG_IOCTL, "%s: Reconfiguring Port\n", port->dev->name);
+       fst_issue_cmd(port, RECONFIG);
+}
+
+static void
+configure_async_parameters(struct fst_port_info *port, unsigned int baud,
+                          unsigned int char_size, unsigned int stop_bits,
+                          unsigned int parity, unsigned int flow_control)
+{
+       unsigned char fc;
+
+       fst_dbg(DBG_IOCTL, "%s: Setting async parameters\n", port->dev->name);
+       fc = COM_FLOW_CONTROL_NONE;
+       if ((flow_control == 1) || (flow_control == 3))
+               fc = COM_FLOW_CONTROL_RTSCTS;
+       if (flow_control == 2)
+               fc = COM_FLOW_CONTROL_XONXOFF;
+       fst_dbg(DBG_IOCTL, "Flow control chosen as %d\n", fc);
+       FST_A_WRB(port->card, async_config[port->index].flow_control, fc);
+       FST_A_WRB(port->card, async_config[port->index].xon_char, 0x11);
+       FST_A_WRB(port->card, async_config[port->index].xoff_char, 0x13);
+       FST_A_WRW(port->card, async_config[port->index].rx_fifo_size,
+                 FST_RX_DATA_FIFO_LEN);
+       FST_WRL(port->card, port_config[port->index].line_speed, baud);
+       FST_WRB(port->card, port_config[port->index].internal_clock, 1);
+       FST_A_WRB(port->card, async_config[port->index].word_length,
+                 char_size);
+       if (stop_bits == 2) {
+               FST_A_WRB(port->card, async_config[port->index].stop_bits,
+                         COM_STOP_BITS_2);
+       } else {
+               FST_A_WRB(port->card, async_config[port->index].stop_bits,
+                         COM_STOP_BITS_1);
+       }
+
+       if (parity) {
+               if (parity == 1)
+                       FST_A_WRB(port->card, async_config[port->index].parity,
+                                 COM_ODD_PARITY);
+               else
+                       FST_A_WRB(port->card, async_config[port->index].parity,
+                                 COM_EVEN_PARITY);
+       } else {
+               FST_A_WRB(port->card, async_config[port->index].parity,
+                         COM_NO_PARITY);
+       }
+       fst_dbg(DBG_IOCTL, "%s: Reconfiguring Port\n", port->dev->name);
+       fst_issue_cmd(port, RECONFIG);
+}
+
+/* Char tty interface for async PPP */
+#define FST_TTY_NPORTS         (FST_MAX_CARDS*FST_MAX_PORTS)
+#define FST_TTY_MAJOR          190
+#define FST_TTY_MINOR_START    0
+/* tty interface state */
+#define        FST_TTY_ST_CLOSED      0        /* Initial state */
+#define FST_TTY_ST_OPEN               1        /* Has at least one open */
+#define FST_TTY_ST_DATA        2       /* Open and used for data */
+#define FST_TTY_ST_DISC        3       /* Open but line has dropped */
+
+/* TTY functions prototype */
+static int fst_tty_open(struct tty_struct *tty, struct file *flip);
+static void fst_tty_close(struct tty_struct *tty, struct file *flip);
+static int fst_tty_write(struct tty_struct *tty, const unsigned char *buf,
+                        int count);
+static int fst_tty_write_room(struct tty_struct *tty);
+static int fst_tty_chars_in_buffer(struct tty_struct *tty);
+int fst_tty_tiocmset(struct tty_struct *, unsigned int, unsigned int);
+int fst_tty_tiocmget(struct tty_struct *);
+static void fst_tty_flush_buffer(struct tty_struct *tty);
+static void fst_tty_hangup(struct tty_struct *tty);
+static void fst_tty_set_termios(struct tty_struct *tty, struct ktermios *old);
+static struct tty_driver *serial_drv;
+
+typedef struct _fst_tty_area {
+       struct tty_port tty_port;
+       int state;              /* state of the TTY interface */
+       int num_open;
+       unsigned int tty_minor; /* minor this interface */
+       struct fst_port_info *port;     /* ptr. to port info */
+       unsigned char name[20]; /* interf. name + "-tty" */
+       struct tty_struct *tty;
+       struct sk_buff *skb;
+       int len;                /* async */
+       char *data;             /* async */
+       struct work_struct fst_tty_work;
+       struct work_struct fst_async_tty_work;
+
+} st_fst_tty_area;
+
+static const struct tty_operations fst_tty_ops = {
+       .open = fst_tty_open,
+       .close = fst_tty_close,
+       .write = fst_tty_write,
+       .write_room = fst_tty_write_room,
+       .chars_in_buffer = fst_tty_chars_in_buffer,
+       .tiocmset = fst_tty_tiocmset,
+       .tiocmget = fst_tty_tiocmget,
+       .set_termios = fst_tty_set_termios,
+       .flush_buffer = fst_tty_flush_buffer,
+       .hangup = fst_tty_hangup,
+};
+
+st_fst_tty_area fst_tty_area[FST_TTY_NPORTS];
+int fst_tty_refcount;
+int fst_tty_unreg_flag;
+int fst_tty_cnt;
+
+static int check_tx_fifo_threshold(struct fst_port_info *port)
+{
+       u16 used_space = 0;
+
+       /* This specifically for the async tty interface to start tx's
+        * again when it had been flow controlled by retruning a zero
+        * to tty_write()
+        */
+
+       used_space =
+           (u16) check_fifo_space((char *)port->fifo_rxdata, FIFO_ASY_TX);
+       if (used_space < (u16) FST_TX_DATA_FIFO_LOW) {
+               if (port->start) {
+                       st_fst_tty_area *fst_tty;
+                       fst_tty = &fst_tty_area[port->minor_dev_no];
+                       if (fst_tty->tty) {
+                               fst_dbg(DBG_TTY,
+                               "%s: Starting tty layer transmits again\n",
+                                       fst_tty->name);
+                               tty_wakeup(fst_tty->tty);
+                       }
+                       port->start = 0;
+               }
+       }
+       return 0;
+}
+
+void fst_tty_uninit(void)
+{
+       /* Unload the tty driver
+        */
+       int res;
+
+       pr_info("Unregister the tty driver\n");
+       res = tty_unregister_driver(serial_drv);
+       if (res) {
+               fst_dbg(DBG_ASS,
+                       "ERROR ->unregister the tty driver error=%d\n",
+                       res);
+       }
+       put_tty_driver(serial_drv);
+}
+
+int fst_tty_init_body(void)
+{
+       /* initialize tty driver struct */
+       serial_drv = alloc_tty_driver(FST_TTY_NPORTS);
+       if (serial_drv == NULL)
+               return 0;
+       serial_drv->magic = TTY_DRIVER_MAGIC;
+       serial_drv->driver_name = "farsync_tty";
+       serial_drv->name = "tty_hdlc";
+       serial_drv->major = 0;
+       serial_drv->minor_start = 0;    /* Use the whole of the minor range */
+       serial_drv->num = FST_TTY_NPORTS;
+       serial_drv->type = TTY_DRIVER_TYPE_SERIAL;
+       serial_drv->subtype = SERIAL_TYPE_NORMAL;
+       serial_drv->init_termios = tty_std_termios;
+       serial_drv->init_termios.c_cflag =
+         (B9600 | CS8 | CREAD | HUPCL | CLOCAL);
+       serial_drv->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
+
+       /* interface routines from the upper tty layer to the tty driver */
+       tty_set_operations(serial_drv, &fst_tty_ops);
+
+       /* register the TTY driver */
+       if (tty_register_driver(serial_drv)) {
+               fst_dbg(DBG_ASS, "fsc: Failed to register serial driver!\n");
+               put_tty_driver(serial_drv);
+               return 0;
+       }
+       return 1;               /* OK */
+}
+
+int fst_tty_init(void)
+{
+       /* Load the tty driver */
+       int retval = 0;
+
+       pr_info("Initialising tty driver\n");
+       retval = fst_tty_init_body();
+       if (retval)
+               memset((void *)fst_tty_area, 0,
+                      sizeof(st_fst_tty_area) * FST_TTY_NPORTS);
+       return retval;
+}
+
+static int fst_tty_open(struct tty_struct *tty, struct file *file)
+{
+       /* Open a farsync port
+        * It must not already be open by the network stack
+        */
+       int port_num;
+       st_fst_tty_area *fst_tty;
+       struct net_device *dev;
+       struct fst_port_info *port;
+       char dev_name[16];
+
+       fst_dbg(DBG_ASS, "fst_tty_open\n");
+       if (!tty)
+               return -ENODEV;
+
+       port_num = tty->index;
+       if ((port_num < 0) || (port_num >= FST_TTY_NPORTS)) {
+               fst_dbg(DBG_ASS, "fst_tty: open invalid minor %i\n", port_num);
+               return -ENODEV;
+       }
+
+       fst_tty = &fst_tty_area[port_num];
+
+       INIT_WORK(&fst_tty->fst_tty_work, fst_process_tty_work);
+       INIT_WORK(&fst_tty->fst_async_tty_work, fst_process_async_tty_work);
+
+       if (fst_tty->num_open == 0) {
+               /*
+                * We need to find the dev device and see if it is open
+                */
+               dev = get_net_device(port_num);
+               if (dev == NULL) {
+                       fst_dbg(DBG_ASS,
+                       "Cannot open char device %s because net device not found\n",
+                               dev->name);
+                       return -ENXIO;
+               }
+               port = dev_to_port(dev);
+               if (port == NULL) {
+                       fst_dbg(DBG_ASS,
+                       "Cannot open char device %s because port is not created\n",
+                               dev->name);
+                       return -EACCES;
+               }
+               if (port->run) {
+                       /* We could be a DSL port, and by this time the port
+                        * will have already be opened and therefore be running
+                        */
+                       if (port->card->type != FST_TYPE_DSL_S1) {
+                               /*
+                                * It is likely that the network device is
+                                * active so refuse this open
+                                */
+                               return -EBUSY;
+                       }
+               }
+               /* first open of this tty */
+               fst_tty->state = FST_TTY_ST_OPEN;
+               fst_tty->tty = tty;
+               tty->driver_data = &fst_tty_area[port_num];
+               fst_tty->num_open = 0;
+               fst_tty->tty_minor = port_num + FST_TTY_MINOR_START;
+
+               strcpy(dev_name, "tty_");
+               strcat(dev_name, dev->name);
+               strcpy(fst_tty->name, dev->name);
+               fst_dbg(DBG_ASS,
+                       "%s: Initializing TTY Sync Driver, tty major#%d minor#%i\n",
+                       fst_tty->name, FST_TTY_MAJOR, fst_tty->tty_minor);
+               /* Set a flag to indicate we are now using the char
+                * interface for data read and write
+                */
+               port->char_file = file;
+               /*
+                * Open the physical port if not already open
+                */
+               if (!port->port_mode)
+                       fst_openport(port);
+               fst_tty->port = port;
+               try_module_get(THIS_MODULE);
+               fst_tty_cnt++;
+               pr_info("TTY driver port %s is now open\n", fst_tty->name);
+       }
+       fst_tty->num_open++;
+       return 0;
+}
+
+static void fst_tty_close(struct tty_struct *tty, struct file *flip)
+{
+       /*
+        * Close a farsync port
+        */
+       st_fst_tty_area *fst_tty;
+       unsigned long flags;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "fst_tty: no TTY in close\n");
+               return;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY is not opened\n", fst_tty->name);
+               return;
+       }
+
+       if (!fst_tty->num_open) {
+               fst_dbg(DBG_ASS, "%s: TTY is closed\n", fst_tty->name);
+               return;
+       }
+
+       if (--fst_tty->num_open > 0) {
+               fst_dbg(DBG_ASS, "%s: TTY closing the second open\n",
+                       fst_tty->name);
+               return;
+       }
+
+       fst_tty_cnt--;
+       if (fst_tty->state != FST_TTY_ST_CLOSED) {
+               spin_lock_irqsave(&fst_tty->port->card->card_lock, flags);
+               fst_tty->tty = NULL;
+               fst_tty->state = FST_TTY_ST_CLOSED;
+               spin_unlock_irqrestore(&fst_tty->port->card->card_lock, flags);
+               fst_closeport(fst_tty->port);
+               fst_tty->port->run = 0;
+               fst_tty->port->char_file = NULL;
+       }
+
+       module_put(THIS_MODULE);
+       pr_info("TTY driver port %s is now closed\n", fst_tty->name);
+       return;
+}
+
+static int fst_tty_write(struct tty_struct *tty, const unsigned char *buf,
+                        int count)
+{
+       /* Send data to the farsync port */
+       st_fst_tty_area *fst_tty;
+       struct sk_buff *skb;
+       int space_used = 0;
+       int retval;
+       int from_user = 0;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY device in write\n");
+               return -ENODEV;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY device is not opened\n",
+                       fst_tty->name);
+               return -ENODEV;
+       }
+
+       if (count > FST_MAX_MTU) {
+               fst_dbg(DBG_ASS, "%s: Size of write is too large\n",
+                       fst_tty->name);
+               return -EINVAL; /* frame too big */
+       }
+
+       if (fst_tty->state == FST_TTY_ST_CLOSED) {
+               fst_dbg(DBG_TTY,
+               "%s: discarding %d bytes of write data on a disconnected port\n",
+                       fst_tty->name, count);
+               return -ENODEV;
+       }
+       fst_dbg(DBG_TTY, "%s: fst_tty_write %s data len=%i\n", fst_tty->name,
+               (from_user) ? "from user" : "from kernel", count);
+       /* If we are in async mode, check that there is space in the
+        * tx fifo
+        */
+       if (fst_tty->port->mode == FST_MODE_ASYNC) {
+               char *fifo_ptr;
+
+               fifo_ptr =
+                   fst_tty->port->card->mem +
+                   ASY_OFFSET(tx_fifo[fst_tty->port->index]);
+               space_used = check_fifo_space(fifo_ptr, FIFO_ASY_TX);
+               if ((FST_TX_DATA_FIFO_LEN - space_used) < count) {
+                       fst_dbg(DBG_FIFO,
+                       "Couldn't accept write of %d bytes, no room in fifo %d\n",
+                               count, FST_TX_DATA_FIFO_LEN - space_used);
+                       fst_tty->port->start = 1;
+                       return 0;
+               }
+               fst_tty->port->card->dma_port_tx = fst_tty->port;
+               fst_dbg(DBG_TX, "%s: Sending %d bytes of async data %p\n",
+                       fst_tty->port->dev->name, count,
+                       (char *)(fifo_ptr - fst_tty->port->card->mem));
+               write_into_fifo(fifo_ptr, FIFO_ASY_TX, (char *)buf, count);
+               port_to_stats(fst_tty->port, tx_packets)++;
+               port_to_stats(fst_tty->port, tx_bytes) += count;
+               return count;
+       }
+       skb = dev_alloc_skb(count);
+       if (skb == NULL) {
+               fst_dbg(DBG_ASS, "fst_tty_write: can't allocate skb\n");
+               return -EFAULT;
+       }
+
+       /* Read it in */
+       if (from_user) {
+               fst_dbg(DBG_TTY, "Value of from user is %d\n", from_user);
+               if (__copy_from_user(skb_put(skb, count), buf, count)) {
+                       dev_kfree_skb(skb);
+                       return -EFAULT;
+               }
+       } else {
+               memcpy(skb_put(skb, count), buf, count);
+       }
+       fst_tty->state = FST_TTY_ST_DATA;
+       retval = fst_start_xmit(skb, port_to_dev(fst_tty->port));
+       if (retval != count) {
+               fst_dbg(DBG_TTY,
+                       "tty_write: Asked to transmit %d, transmitted %d\n",
+                       count, retval);
+       }
+       return retval;
+}
+
+static int fst_tty_write_room(struct tty_struct *tty)
+{
+       st_fst_tty_area *fst_tty;
+       int room = FST_MAX_MTU;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY device to write room\n");
+               return -ENODEV;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY device is not opened\n",
+                       fst_tty->name);
+               return -ENODEV;
+       }
+
+       fst_dbg(DBG_ASS, "%s: write room\n", fst_tty->name);
+
+       if (fst_tty->port->start)
+               room = 0;
+       fst_dbg(DBG_TTY, "%s: write room: returning %d\n",
+               fst_tty->name, room);
+
+       return room;
+}
+
+static int fst_tty_chars_in_buffer(struct tty_struct *tty)
+{
+       st_fst_tty_area *fst_tty;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS,
+                       "Could not find TTY device for chars in buffer\n");
+               return -ENODEV;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY device is not opened\n",
+                       fst_tty->name);
+               return -ENODEV;
+       }
+       fst_dbg(DBG_TTY, "%s: chars in buffer:returning 0\n", fst_tty->name);
+       return 0;
+}
+
+static void fst_tty_set_termios(struct tty_struct *tty, struct ktermios *old)
+{
+       st_fst_tty_area *fst_tty;
+       unsigned int baud;
+       unsigned int stop_bits;
+       unsigned int char_size;
+       unsigned int parity;
+       unsigned int rtscts;
+       unsigned int xonxoff;
+
+       fst_dbg(DBG_TTY, "tty_set_termios\n");
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY for tiocmset\n");
+               return;
+       }
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+       old = &fst_tty->tty->termios;
+       fst_dbg(DBG_TTY, "%s: Setting %x\n", fst_tty->name, old->c_cflag);
+       baud = get_baud(old->c_cflag);
+       char_size = get_char_size(old->c_cflag);
+       stop_bits = get_stop_bits(old->c_cflag);
+       parity = get_parity(old->c_cflag);
+       rtscts = get_rtscts(old->c_cflag);
+       xonxoff = get_xonxoff(old->c_iflag);
+       /* If we are in async mode we need to configure the async parameters
+        */
+       if (fst_tty->port->mode == FST_MODE_ASYNC) {
+               configure_async_parameters(fst_tty->port, baud, char_size,
+                                          stop_bits, parity,
+                                          rtscts | xonxoff);
+       }
+}
+
+int fst_tty_tiocmset(struct tty_struct *tty, unsigned int set,
+                    unsigned int clear)
+{
+       st_fst_tty_area *fst_tty;
+       unsigned long outputs;
+
+       fst_dbg(DBG_TTY, "%s: set:%x clear:%x\n", __func__, set, clear);
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY for tiocmset\n");
+               return -ENODEV;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if (set & TIOCM_RTS) {
+               fst_dbg(DBG_TTY, "Set RTS\n");
+               outputs = OPSTS_RTS | FST_RDL(fst_tty->port->card,
+                                             v24OpSts[fst_tty->port->index]);
+               FST_WRL(fst_tty->port->card, v24OpSts[fst_tty->port->index],
+                       outputs);
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+
+       if (set & TIOCM_DTR) {
+               fst_dbg(DBG_TTY, "Set DTR\n");
+               outputs = OPSTS_DTR | FST_RDL(fst_tty->port->card,
+                                             v24OpSts[fst_tty->port->index]);
+               FST_WRL(fst_tty->port->card, v24OpSts[fst_tty->port->index],
+                       outputs);
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+
+       if (clear & TIOCM_RTS) {
+               fst_dbg(DBG_TTY, "Clear RTS\n");
+               outputs = OPSTS_RTS ^ FST_RDL(fst_tty->port->card,
+                                             v24OpSts[fst_tty->port->index]);
+               FST_WRL(fst_tty->port->card, v24OpSts[fst_tty->port->index],
+                       outputs);
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+       if (clear & TIOCM_DTR) {
+               fst_dbg(DBG_TTY, "Clear DTR\n");
+               outputs = OPSTS_DTR ^ FST_RDL(fst_tty->port->card,
+                                             v24OpSts[fst_tty->port->index]);
+               FST_WRL(fst_tty->port->card, v24OpSts[fst_tty->port->index],
+                       outputs);
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+       return 0;
+}
+
+int fst_tty_tiocmget(struct tty_struct *tty)
+{
+       unsigned int signals = 0;
+       unsigned long out = 0;
+
+       st_fst_tty_area *fst_tty = (st_fst_tty_area *) tty->driver_data;
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       fst_dbg(DBG_TTY, "%s: tiocmget\n", fst_tty->name);
+
+       signals = FST_RDL(fst_tty->port->card, v24OpSts[fst_tty->tty_minor]);
+       if (signals & OPSTS_RTS)
+               out |= TIOCM_RTS;
+       if (signals & OPSTS_DTR)
+               out |= TIOCM_DTR;
+       signals = FST_RDL(fst_tty->port->card, v24IpSts[fst_tty->tty_minor]);
+       if (signals & IPSTS_CTS)
+               out |= TIOCM_CTS;
+       if (signals & IPSTS_DSR)
+               out |= TIOCM_DSR;
+       if (signals & IPSTS_DCD)
+               out |= TIOCM_CD;
+       fst_dbg(DBG_TTY, "Returning signals as %lx\n", out);
+       return out;
+}
+
+static void fst_tty_flush_buffer(struct tty_struct *tty)
+{
+       st_fst_tty_area *fst_tty;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY to flush buffer\n");
+               return;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY device is not opened\n",
+                       fst_tty->name);
+               return;
+       }
+
+       fst_dbg(DBG_TTY, "%s: call wake_up_interruptible\n", fst_tty->name);
+
+       wake_up_interruptible(&tty->write_wait);
+
+       return;
+}
+
+static void fst_tty_hangup(struct tty_struct *tty)
+{
+       st_fst_tty_area *fst_tty;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find TTY device to hangup\n");
+               return;
+       }
+
+       fst_tty = (st_fst_tty_area *) tty->driver_data;
+
+       if ((fst_tty->tty != tty) || (fst_tty->state < FST_TTY_ST_OPEN)) {
+               fst_dbg(DBG_ASS, "%s: TTY device is not opened\n",
+                       fst_tty->name);
+               return;
+       }
+       fst_dbg(DBG_ASS, "fst_tty_hangup\n");
+}
+
+static void fst_process_async_tty_work(struct work_struct *work)
+{
+       struct fst_port_info *port;
+       char *data;
+       int len;
+       st_fst_tty_area *fst_tty;
+       struct tty_ldisc *ld;
+
+       fst_tty = container_of(work, st_fst_tty_area, fst_async_tty_work);
+       port = fst_tty->port;
+       len = fst_tty->len;
+       data = fst_tty->data;
+
+       if (fst_tty_cnt == 0) {
+               kfree(data);
+               return;
+       }
+       /* ToDo: Note that the third parameter to the ldisc receive_buf
+        * function is a pointer to an array of status bytes which is
+        * the same length as the data.  When we move on to getting the
+        * status bytes from the async interface we can implement this.
+        * For the moment it is a NULL pointer
+        */
+
+       fst_tty->state = FST_TTY_ST_DATA;
+       ld = tty_ldisc_ref(fst_tty->tty);
+       if (ld) {
+               if (fst_tty->tty && (ld->ops->receive_buf)) {
+                       fst_dbg(DBG_TTY,
+                       "%s: call line disc. receive_buf of length %d first byte is %x\n",
+                               fst_tty->name, len, data[0]);
+                       ld->ops->receive_buf(fst_tty->tty, data, NULL, len);
+                       tty_ldisc_deref(ld);
+                       port_to_stats(port, rx_packets)++;
+                       port_to_stats(port, rx_bytes) += len;
+               } else {
+                       fst_dbg(DBG_ASS,
+                       "%s: frame dropped. receive_buf of length %d\n",
+                               fst_tty->name, len);
+                       port_to_stats(port, rx_dropped)++;
+               }
+       }
+       kfree(data);
+       return;
+}
+
+static void fst_process_tty_work(struct work_struct *work)
+{
+       struct fst_port_info *port;
+       st_fst_tty_area *fst_tty;
+       struct sk_buff *skb;
+       struct tty_ldisc *ld;
+       if (fst_tty_cnt == 0)
+               return;
+
+       fst_tty = container_of(work, st_fst_tty_area, fst_tty_work);
+       port = fst_tty->port;
+       skb = fst_tty->skb;
+
+       ld = tty_ldisc_ref(fst_tty->tty);
+       if (ld) {
+               if ((fst_tty->tty) && (ld->ops->receive_buf)) {
+                       fst_dbg(DBG_ASS,
+                       "%s: call line disc. receive_buf of length %d\n",
+                               fst_tty->name, skb->len);
+
+                       ld->ops->receive_buf(fst_tty->tty, skb->data,
+                                            NULL, skb->len);
+               } else {
+                       fst_dbg(DBG_ASS,
+                       "%s: frame dropped. receive_buf of length %d\n",
+                               fst_tty->name, skb->len);
+               }
+               tty_ldisc_deref(ld);
+       }
+       dev_kfree_skb(skb);
+}
+
+static void fst_q_work_item(u64 *queue, int card_index)
+{
+       unsigned long flags;
+       u64 mask;
+
+       /*  Grab the queue exclusively */
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+
+       /* Making an entry in the queue is simply a matter of setting
+        * a bit for the card indicating that there is work to do in the
+        * bottom half for the card.  Note the limitation of 64 cards.
+        * That ought to be enough
+        */
+       mask = (u64) 1 << card_index;
+       *queue |= mask;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+}
+
+static void fst_process_rx_work_q(struct work_struct *work_q)
+{
+       unsigned long flags;
+       u64 work_rxq;
+       int i;
+
+       /* Grab the queue exclusively */
+       fst_dbg(DBG_TX, "fst_process_rx_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       work_rxq = fst_work_rxq;
+       fst_work_rxq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+
+       /* Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (work_rxq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               fst_dbg(DBG_ASS, "Calling rx bh for card %d\n",
+                                       i);
+                               do_bottom_half_rx(fst_cards_list[i]);
+                       }
+               }
+               work_rxq = work_rxq >> 1;
+       }
+}
+
+static void fst_process_tx_work_q(unsigned long work_q)
+{
+       unsigned long flags;
+       u64 work_txq;
+       int i;
+
+       /* Grab the queue exclusively */
+       fst_dbg(DBG_TX, "fst_process_tx_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       work_txq = fst_work_txq;
+       fst_work_txq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+
+       /* Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (work_txq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               fst_dbg(DBG_TX, "Calling tx bh for card %d\n",
+                                       i);
+                               do_bottom_half_tx(fst_cards_list[i]);
+                       }
+               }
+               work_txq = work_txq >> 1;
+       }
+}
+
+static void fst_process_int_work_q(unsigned long work_q)
+{
+       unsigned long flags;
+       u64 work_intq;
+       int i;
+
+       /* Grab the queue exclusively */
+       fst_dbg(DBG_INTR, "fst_process_int_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       work_intq = fst_work_intq;
+       fst_work_intq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+
+       /*  Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (work_intq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               if (fst_cards_list[i]->type !=
+                                   FST_TYPE_DSL_S1) {
+                                       fst_dbg(DBG_INTR,
+                                       "Calling rx & tx bh for card %d\n",
+                                               i);
+                                       do_bottom_half_rx(fst_cards_list[i]);
+                               } else {
+                                       /* If it is a DSL card we need to bet
+                                        * out of Interrupt mode
+                                        * so we need to schedule some work
+                                        */
+                                       fst_dbg(DBG_ASS,
+                                       "Scheduling work for DSL rx\n");
+                                       fst_q_work_item(&fst_work_rxq, i);
+                                       schedule_work(&fst_rx_work);
+                               }
+                               /* Calling the tx BH directly could mean that
+                                * it runs twice concurrently.  So we have to
+                                * schedule it
+                                */
+                               fst_q_work_item(&fst_work_txq, i);
+                               tasklet_schedule(&fst_tx_task);
+                       }
+               }
+               work_intq = work_intq >> 1;
+       }
+}
+
+/*      Card control functions
+ *      ======================
+ */
+/*      Place the processor in reset state
+ *
+ * Used to be a simple write to card control space but a glitch in the latest
+ * AMD Am186CH processor means that we now have to do it by asserting and de-
+ * asserting the PLX chip PCI Adapter Software Reset. Bit 30 in CNTRL register
+ * at offset 9052_CNTRL.  Note the updates for the TXU.
+ */
+static inline void fst_cpureset(struct fst_card_info *card)
+{
+       unsigned char interrupt_line_register;
+       unsigned long j = jiffies + 1;
+       unsigned int regval;
+
+       if (card->family == FST_FAMILY_TXU) {
+               if (pci_read_config_byte
+                   (card->device, PCIILR, &interrupt_line_register)) {
+                       fst_dbg(DBG_ASS,
+                               "Error in reading interrupt line register\n");
+               }
+               /* Assert PLX software reset and Am186 hardware reset
+                * and then deassert the PLX software reset but 186 still
+                * in reset
+                */
+               outw(0x440f, card->pci_conf + CNTRL_9054 + 2);
+               outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
+               /* We are delaying here to allow the 9054 to reset itself
+                */
+               j = jiffies + 1;
                while (jiffies < j)
-                       /* Do nothing */ ;
+                       /* Do nothing */;
                outw(0x240f, card->pci_conf + CNTRL_9054 + 2);
-               /*
-                * We are delaying here to allow the 9054 to reload its eeprom
+               /* We are delaying here to allow the 9054 to reload its eeprom
                 */
                j = jiffies + 1;
                while (jiffies < j)
-                       /* Do nothing */ ;
+                       /* Do nothing */;
+               outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
+
+               if (pci_write_config_byte
+                   (card->device, PCIILR, interrupt_line_register)) {
+                       fst_dbg(DBG_ASS,
+                               "Error in writing interrupt line register\n");
+               }
+
+       } else {
+               regval = inl(card->pci_conf + CNTRL_9052);
+
+               outl(regval | 0x40000000, card->pci_conf + CNTRL_9052);
+               outl(regval & ~0x40000000, card->pci_conf + CNTRL_9052);
+       }
+}
+
+/*      Release the processor from reset
+ */
+static inline void fst_cpurelease(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU) {
+               /* Force posted writes to complete */
+               (void)readb(card->mem);
+
+               /* Release LRESET DO = 1
+                * Then release Local Hold, DO = 1
+                */
+               outw(0x040e, card->pci_conf + CNTRL_9054 + 2);
                outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
+       } else {
+               (void)readb(card->ctlmem);
+       }
+}
+
+/*      Interrupt the card
+ */
+static inline void fst_intr_card(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU) {
+               (void)writeb(0xff, card->ctlmem);
+       } else {
+               /* Not sure what to do here)
+                */
+               outw(0x0543, card->pci_conf + INTCSR_9052);
+       }
+}
+
+/*      Clear the cards interrupt flag
+ */
+static inline void fst_clear_intr(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU) {
+               (void)readb(card->ctlmem);
+       } else {
+               /* Poke the appropriate PLX chip register (same as enabling
+                * interrupts)
+                */
+               outw(0x0543, card->pci_conf + INTCSR_9052);
+       }
+}
+
+/*      Enable interrupts
+ */
+static inline void fst_enable_intr(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU)
+               outl(0x0f0c0900, card->pci_conf + INTCSR_9054);
+       else
+               outw(0x0543, card->pci_conf + INTCSR_9052);
+}
+
+/*      Enable 186 interrupts
+ */
+static inline void fst_enable_186_intr(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU)
+               outl(0x0f0c0900, card->pci_conf + INTCSR_9054);
+}
+
+/*      Disable interrupts
+ */
+static inline void fst_disable_intr(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU)
+               outl(0x00000000, card->pci_conf + INTCSR_9054);
+       else
+               outw(0x0000, card->pci_conf + INTCSR_9052);
+}
+
+/*      Disable 186 interrupts
+ */
+static inline void fst_disable_186_intr(struct fst_card_info *card)
+{
+       if (card->family == FST_FAMILY_TXU)
+               outl(0x0f0c0100, card->pci_conf + INTCSR_9054);
+}
+
+static int fst_proc_info(struct seq_file *m, void *v)
+{
+       struct seq_file *buffer = m;
+       struct fst_card_info *card;
+       int c;
+       int port_count = 0;
+
+       seq_printf(buffer,
+                "FarSync %s Driver version %s - Patch Level %s - Build %s\n",
+                  FST_DRIVER_TYPE, FST_USER_VERSION, FST_PATCH_LEVEL,
+                  FST_ADDITIONAL);
+       seq_printf(buffer, "%d Cards found\n", fst_ncards);
+       for (c = 0; c < fst_ncards; c++) {
+               card = fst_cards_list[c];
+               if (card->state == FST_RUNNING)
+                       extract_serial(card);
+               else
+                       strcpy(serial, "UNKNOWN ");
+               seq_printf(buffer,
+                          "\t%s-%s:(%s) %s IRQ%d,\t%d ports, State: %s\n",
+                          port_to_dev(card->ports[0])->name,
+                          port_to_dev(card->ports[card->nports - 1])->name,
+                          serial,
+                          type_strings[card->type],
+                          card->irq, card->nports, state_strings[card->state]);
+               port_count += card->nports;
+       }
+       seq_printf(buffer, "Total number of ports = %d\n", port_count);
+       seq_printf(buffer, "Total number of async connects = %d\n",
+                  fst_tty_cnt);
+       return 0;
+}
+
+/*      Process the result of trying to pass a recieved frame up the stack
+ */
+static void fst_process_rx_status(int rx_status, char *name)
+{
+       switch (rx_status) {
+       case NET_RX_SUCCESS:
+               {
+                       /*
+                        * Nothing to do here
+                        */
+                       break;
+               }
+
+       case NET_RX_DROP:
+               {
+                       pr_err("%s: Received packet dropped\n", name);
+                       break;
+               }
+       }
+}
+
+static int gen_mon_packet(struct sk_buff *skb, struct fst_port_info *port,
+                         int tx_rx_ind)
+{
+       /* We need to duplicate the skb and send it up to
+        * the monitor application
+        */
+       struct sk_buff *mon_skb;
+       int rx_status = NET_RX_SUCCESS;
+       struct fstioc_mon header;
+
+       /* Allocate SKB.  Length of frame to monitor + length of the
+        * header we prepend.
+        */
+       mon_skb = dev_alloc_skb(skb->len + sizeof(struct fstioc_mon));
+       if (mon_skb == NULL) {
+               fst_dbg(DBG_INTR, "gen_mon_packet: can't allocate skb\n");
+               return 1;
+       }
+
+       /* Setup the header */
+       header.version = FSTIOC_MON_VERSION;
+       header.tx_rx_ind = tx_rx_ind;
+       header.sequence = port->sequence++;
+       header.timestamp = jiffies * 1000 / HZ;
+       header.length = skb->len;
+
+       memcpy(skb_put(mon_skb, sizeof(struct fstioc_mon)), &header,
+              sizeof(struct fstioc_mon));
+
+       /* Push upstream */
+       fst_dbg(DBG_INTR, "Pushing monitor frame up the stack\n");
+       mon_skb->protocol = htons(ETH_P_DIAG);
+       mon_skb->pkt_type = PACKET_HOST;
+       skb_reset_mac_header(mon_skb);
+       mon_skb->dev = port_to_dev(port);
+       memcpy(skb_put(mon_skb, skb->len), skb->data, skb->len);
+       fst_dbg(DBG_INTR, "Monitor packet length is %d\n", mon_skb->len);
+       if (port->run)
+               rx_status = netif_rx(mon_skb);
+       else {
+               dev_kfree_skb(mon_skb);
+               fst_dbg(DBG_ASS, "Discarding monitor frame, port closed\n");
+       }
+       fst_process_rx_status(rx_status, port_to_dev(port)->name);
+       if (rx_status == NET_RX_DROP) {
+               fst_dbg(DBG_ASS, "Could not deleiver monitor message");
+               return 1;
+       }
+       return 0;
+}
+
+#define SDMAPOLL 0x17
+static void fst_check_send(struct fst_port_info *port)
+{
+       struct fst_card_info *card;
+       unsigned long flags;
+
+       fst_dbg(DBG_CMD, "In fst_check_send %p\n", port);
+       if (port->low_latency & LOW_LATENCY_TX) {
+               card = port->card;
+               spin_lock_irqsave(&card->card_lock, flags);
+               FST_WRW(card, mailbox[1], port->index);
+               FST_WRW(card, mailbox[0], SDMAPOLL);
+               spin_unlock_irqrestore(&card->card_lock, flags);
+       } else {
+               fst_dbg(DBG_CMD, "Low Latency Tx not enabled\n");
+       }
+}
+
+static void fst_issue_cmd(struct fst_port_info *port, unsigned short cmd)
+{
+       u16 command;
+       char *fifo_ptr;
+       int status;
+
+       fifo_ptr = port->card->mem + ASY_OFFSET(cmd_fifo[port->index]);
+       port->card->cmdfifo_complete[port->index] = 0;
+       switch (cmd) {
+       case SETV24O:
+               fst_dbg(DBG_CMD, "%s: Setting V24 Output Signals\n",
+                       port->dev->name);
+               command = cpu_to_le16(CMD_FIFO_SET_V24);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case STARTPORT:
+               fst_dbg(DBG_CMD, "%s: Sending Start Port\n", port->dev->name);
+               command = cpu_to_le16(CMD_FIFO_START_PORT);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case STOPPORT:
+               fst_dbg(DBG_CMD, "%s: Sending Stop Port\n", port->dev->name);
+               command = cpu_to_le16(CMD_FIFO_STOP_PORT);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case ABORTTX:
+               fst_dbg(DBG_CMD, "%s: Sending Abort Tx\n", port->dev->name);
+               command = cpu_to_le16(CMD_FIFO_ABORT_PORT);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case RECONFIG:
+               fst_dbg(DBG_CMD, "%s: Sending Reconfig async port\n",
+                       port->dev->name);
+               command = cpu_to_le16(FST_CMD_RECONFIG);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case FLUSHTX:
+               fst_dbg(DBG_CMD, "%s: Sending flush async tx fifo\n",
+                       port->dev->name);
+               command = cpu_to_le16(FST_CMD_FIFO_FLUSH_TX);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case SETXON:
+               fst_dbg(DBG_CMD, "%s: Sending XON command\n", port->dev->name);
+               command = cpu_to_le16(FST_CMD_FIFO_XON);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case SETXOFF:
+               fst_dbg(DBG_CMD, "%s: Sending XOFF command\n", port->dev->name);
+               command = cpu_to_le16(FST_CMD_FIFO_XOFF);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       case RECONFIGLINE:
+               fst_dbg(DBG_CMD, "%s: Sending Reconfig line parameters\n",
+                       port->dev->name);
+               command = cpu_to_le16(CMD_FIFO_RECONFIG_PORT);
+               write_into_fifo(fifo_ptr, FIFO_ASY_CMD, (char *)&command, 2);
+               break;
+
+       default:
+         fst_dbg(DBG_ASS, "%s: Issue ASY Command:  Command %d not implemented\n",
+                      port_to_dev(port)->name, cmd);
+       }
+       /* wait for a reply */
+       if (port->card->state == FST_RUNNING) {
+               fst_dbg(DBG_CMD, "Waiting for cmd fifo to be processed\n");
+               status =
+                   wait_event_interruptible_timeout(port->card->cmdfifo_waitq,
+                                                    (port->
+                                                     card->cmdfifo_complete
+                                                     [port->index]), 500);
+               if (status == -ERESTARTSYS)
+                       pr_info("Fifo command interrupted by signal\n");
+               if (status == 0)
+                       pr_err("Timeout in processing fifo cmd %d\n", cmd);
+               fst_dbg(DBG_CMD, "Reply received (%d) or interrupts (%x)\n",
+                       port->card->cmdfifo_complete[port->index], status);
+       } else {
+               fst_dbg(DBG_ASS,
+                       "Command %d issued when card not yet running\n", cmd);
+       }
+}
+
+/*      Port output signals control
+ */
+static inline void
+fst_op_raise(struct fst_port_info *port, unsigned int outputs)
+{
+       outputs |= FST_RDL(port->card, v24OpSts[port->index]);
+       FST_WRL(port->card, v24OpSts[port->index], outputs);
+
+       if (port->run)
+               fst_issue_cmd(port, SETV24O);
+       /* If we are in ignore carrier mode, then now is the
+        * time to tell the network layer that the carrier is on
+        */
+       if (port->ignore_carrier) {
+               if (!netif_carrier_ok(port_to_dev(port))) {
+                       fst_dbg(DBG_OPEN, "Net carrier on\n");
+                       netif_carrier_on(port_to_dev(port));
+               }
+       }
+}
+
+static inline void
+fst_op_lower(struct fst_port_info *port, unsigned int outputs)
+{
+       outputs = ~outputs & FST_RDL(port->card, v24OpSts[port->index]);
+       FST_WRL(port->card, v24OpSts[port->index], outputs);
+
+       if (port->run)
+               fst_issue_cmd(port, SETV24O);
+       /* If we are in ignore carrier mode, then now is the
+        * time to tell the network layer that carrier is off
+        */
+       if (port->ignore_carrier)
+               netif_carrier_off(port_to_dev(port));
+}
+
+/* Setup port Rx buffers
+ */
+static void fst_rx_config(struct fst_port_info *port)
+{
+       int i;
+       int pi;
+       unsigned int offset;
+       unsigned long flags;
+       struct fst_card_info *card;
+
+       pi = port->index;
+       card = port->card;
+       spin_lock_irqsave(&card->card_lock, flags);
+       FST_WRB(card, port_config[pi].num_rx_buffers,
+               (u8) port->num_rx_buffers);
+       for (i = 0; i < port->num_rx_buffers; i++) {
+               offset = BUF_OFFSET(rx_buffer[pi][0]) +
+                 i * port->rx_buffer_size;
+
+               FST_WRW(card, rx_descr_ring[pi][i].ladr, (u16) offset);
+               FST_WRB(card, rx_descr_ring[pi][i].hadr, (u8) (offset >> 16));
+               FST_WRW(card, rx_descr_ring[pi][i].bcnt,
+                       cnv_bcnt(port->rx_buffer_size));
+               FST_WRW(card, rx_descr_ring[pi][i].mcnt, FST_MAX_MTU - 2);
+               FST_WRB(card, rx_descr_ring[pi][i].bits, DMA_OWN);
+       }
+       port->rxpos = 0;
+       spin_unlock_irqrestore(&card->card_lock, flags);
+}
+
+/* Setup port Tx buffers
+ */
+static void fst_tx_config(struct fst_port_info *port)
+{
+       int i;
+       int pi;
+       unsigned int offset;
+       unsigned long flags;
+       struct fst_card_info *card;
+
+       pi = port->index;
+       card = port->card;
+       spin_lock_irqsave(&card->card_lock, flags);
+       FST_WRB(card, port_config[pi].num_tx_buffers,
+               (u8) port->num_tx_buffers);
+       for (i = 0; i < port->num_tx_buffers; i++) {
+               offset = BUF_OFFSET(tx_buffer[pi][0]) +
+                 i * port->tx_buffer_size;
+
+               FST_WRW(card, tx_descr_ring[pi][i].ladr, (u16) offset);
+               FST_WRB(card, tx_descr_ring[pi][i].hadr, (u8) (offset >> 16));
+               FST_WRW(card, tx_descr_ring[pi][i].bcnt, 0);
+               FST_WRB(card, tx_descr_ring[pi][i].bits, 0);
+       }
+       port->txpos = 0;
+       port->txipos = 0;
+       port->start = 0;
+       spin_unlock_irqrestore(&card->card_lock, flags);
+}
+
+/*      Check that the shared memory configuration is one that we can handle
+ *      and that some basic parameters are correct
+ */
+static void check_started_ok(struct fst_card_info *card)
+{
+       int i;
+
+       /* Check structure version and end marker */
+       if (FST_RDW(card, smc_version) != SMC_VERSION) {
+               pr_err("Bad shared memory version %d expected %d\n",
+                          FST_RDW(card, smc_version), SMC_VERSION);
+               card->state = FST_BADVERSION;
+               return;
+       }
+       if (FST_RDL(card, end_of_smc_signature) != END_SIG) {
+               pr_err("Missing shared memory signature %x\n",
+                          FST_RDL(card, end_of_smc_signature));
+               pr_err("size of shared memory structure is %u\n",
+                          (unsigned int)sizeof(struct fst_shared));
+               card->state = FST_BADVERSION;
+               return;
+       }
+       /* Firmware status flag, 0x00 = initialising, 0x01 = OK, 0xFF = fail */
+       i = FST_RDB(card, task_status);
+       if (i == 0x01) {
+               card->state = FST_RUNNING;
+               /*
+                * If there is any card specific initialisation required
+                * this is the place to do it.  After the loader has
+                * zero'd the memory
+                */
+               if (card->type == FST_TYPE_DSL_S1) {
+                       FST_WRB(card, dsl_config.snrth, 5);
+                       FST_WRB(card, dsl_config.lpath, 30);
+               }
+               if (card->type == FST_TYPE_T4E) {
+                       /*
+                        * Check to see if we really are a T4E+
+                        */
+                       if (FST_RDB(card, capability_mask) == 0x01) {
+                               /*
+                                * Yes, we are a T4E+
+                                */
+                               card->type = FST_TYPE_T4Ep;
+                       }
+               }
+       } else if (i == 0xFF) {
+               pr_err("Firmware initialisation failed. Card halted\n");
+               card->state = FST_HALTED;
+               return;
+       } else if (i != 0x00) {
+               pr_err("Unknown firmware status 0x%x\n", i);
+               card->state = FST_HALTED;
+               return;
+       }
+
+       /* Finally check the number of ports reported by firmware against the
+        * number we assumed at card detection. Should never happen with
+        * existing firmware etc so we just report it for the moment.
+        */
+       if (FST_RDL(card, number_of_ports) != card->nports) {
+               pr_warn("Port count mismatch on card %d.", card->card_no);
+               pr_warn(" Firmware thinks %d we say %d\n",
+                       FST_RDL(card, number_of_ports), card->nports);
+       }
+}
+
+/* ATM Fifo functions
+ */
+
+static void atm_fifo_init(struct fst_card_info *card)
+{
+       struct fst_fifo fifo;

-               if (pci_write_config_byte
-                   (card->device, PCI_INTERRUPT_LINE, interrupt_line_register)) {
-                       dbg(DBG_ASS,
-                           "Error in writing interrupt line register\n");
-               }
+       /* Initialise the dsl fifo's to zeros */
+       fst_dbg(DBG_INIT, "Zeroing %x bytes of dsl tx fifo\n",
+               (unsigned int)sizeof(struct dsl_tx_fifo));
+       memset_io(card->mem + DT_BASE, 0, sizeof(struct dsl_tx_fifo));
+       fst_dbg(DBG_INIT, "Zeroing %x bytes of dsl rx fifo\n",
+               (unsigned int)sizeof(struct dsl_rx_fifo));
+       memset_io(card->mem + DR_BASE, 0, sizeof(struct dsl_rx_fifo));

-       } else {
-               regval = inl(card->pci_conf + CNTRL_9052);
+       /* Initiliase the local copy of the fifo header and then
+        * Copy it to shared memeory.
+        * Do the command fifo first followed by the response
+        */
+       fifo.fifo_length = (u16) MAX_DSL_TX_BUFFER;
+       fifo.read_idx = (u16) fifo.fifo_length - 1;
+       fifo.write_idx = (u16) fifo.fifo_length - 1;
+       fifo.overflow_idx = -1;
+       fifo.data[0] = 'D';
+       fifo.data[1] = 'E';
+       fifo.data[2] = 'A';
+       fifo.data[3] = 'D';
+
+       FST_DT_WRW(card, tx_fifo[FIFO_LENGTH], fifo.fifo_length);
+       FST_DT_WRW(card, tx_fifo[READ_IDX], fifo.read_idx);
+       FST_DT_WRW(card, tx_fifo[WRITE_IDX], fifo.write_idx);
+       FST_DT_WRW(card, tx_fifo[OVERFLOW_IDX], fifo.overflow_idx);
+       FST_DT_WRB(card, tx_fifo[DATA_0], fifo.data[0]);
+       FST_DT_WRB(card, tx_fifo[DATA_1], fifo.data[1]);
+       FST_DT_WRB(card, tx_fifo[DATA_2], fifo.data[2]);
+       FST_DT_WRB(card, tx_fifo[DATA_3], fifo.data[3]);
+
+       fifo.data[0] = 'B';
+       fifo.data[1] = 'E';
+       fifo.data[2] = 'E';
+       fifo.data[3] = 'F';
+
+       FST_DR_WRW(card, rx_fifo[FIFO_LENGTH], fifo.fifo_length);
+       FST_DR_WRW(card, rx_fifo[READ_IDX], fifo.read_idx);
+       FST_DR_WRW(card, rx_fifo[WRITE_IDX], fifo.write_idx);
+       FST_DR_WRW(card, rx_fifo[OVERFLOW_IDX], fifo.overflow_idx);
+       FST_DR_WRB(card, rx_fifo[DATA_0], fifo.data[0]);
+       FST_DR_WRB(card, rx_fifo[DATA_1], fifo.data[1]);
+       FST_DR_WRB(card, rx_fifo[DATA_2], fifo.data[2]);
+       FST_DR_WRB(card, rx_fifo[DATA_3], fifo.data[3]);
+}
+
+static int atm_write_into_fifo(struct fst_card_info *card, char *data,
+                              int data_len)
+{
+       int retval = -1;
+       int h_size = 0;
+       struct fst_fifo fifo;
+       unsigned short avail_fifo_space = 0;
+       unsigned short used_space = 0;
+       unsigned short free_space = 0;
+       unsigned short next_write_idx = 0;
+       unsigned short first_write_amount = 0;
+       unsigned short second_write_amount = 0;
+       int temp = MAX_DSL_TX_BUFFER;
+
+       fst_dbg(DBG_IOCTL, "atm_write_into_fifo\n");
+       /* It's OK to read the fifo header in one go, but don't fall into
+        * the trap of writing it all back.  The fields that the card updates
+        * must not be touched.  Therefore we must write back the fields
+        * individually.
+        */
+       h_size = sizeof(struct fst_fifo) - 4;
+       fst_dbg(DBG_IOCTL, "%d: atm_write_into_fifo of length %d\n",
+               card->card_no, data_len);
+       memcpy_fromio(&fifo, card->mem + DT_OFFSET(tx_fifo), h_size);
+       next_write_idx =
+           (unsigned short)((fifo.write_idx + 1) % fifo.fifo_length);
+       fst_dbg(DBG_IOCTL, "next_write_idx = %d\n", next_write_idx);
+       free_space = (unsigned short)((fifo.read_idx - next_write_idx +
+                                      fifo.fifo_length) % fifo.fifo_length);
+       used_space = (unsigned short)(fifo.fifo_length - free_space - 1);
+       avail_fifo_space = (unsigned short)(MAX_DSL_TX_BUFFER - used_space);
+       avail_fifo_space = (unsigned short)min_t(u16, avail_fifo_space,
+                                              (unsigned short)temp);
+
+       if (fifo.overflow_idx == -1) {
+               fst_dbg(DBG_IOCTL, "tx_fifo.overflow_idx = -1\n");
+               if (free_space > data_len) {
+                       fst_dbg(DBG_IOCTL,
+                               "And there is space to write data %d\n",
+                               avail_fifo_space);
+                       /* How much of it can we write into the end fragment */
+                       first_write_amount =
+                         (unsigned short)min_t(u16, (unsigned short)data_len,
+                                               (unsigned
+                                                short)(fifo.fifo_length -
+                                                       next_write_idx));
+                       fst_dbg(DBG_IOCTL, "First write amount is %d\n",
+                               first_write_amount);
+                       fst_dbg(DBG_IOCTL, "Next write index is %d\n",
+                               next_write_idx);
+                       fst_dbg(DBG_IOCTL, "Copying to offset %lx\n",
+                               DT_OFFSET(tx_fifo) + h_size + next_write_idx);
+                       if (first_write_amount > fst_min_dma_len) {
+                               memcpy(card->tx_dma_handle_host, data,
+                                      data_len);
+                               fst_tx_dsl_dma(card,
+                                              (char *)card->tx_dma_handle_card,
+                                              (char *)DT_OFFSET(tx_fifo) +
+                                              h_size + next_write_idx,
+                                              first_write_amount);
+                       } else {
+                               memcpy_toio(card->mem + DT_OFFSET(tx_fifo) +
+                                           h_size + next_write_idx, data,
+                                           first_write_amount);
+                       }
+                       fifo.write_idx =
+                           (unsigned
+                            short)((fifo.write_idx + first_write_amount)
+                                   % fifo.fifo_length);
+                       fst_dbg(DBG_IOCTL, "Write Index updated to %d\n",
+                               fifo.write_idx);
+                       if (first_write_amount != data_len) {
+                               fst_dbg(DBG_IOCTL,
+                                       "We need a second write chunk because of wrap\n");
+                               /* were do we start writing the next chunk to */
+                               next_write_idx =
+                                   (unsigned short)((fifo.write_idx + 1) %
+                                                    fifo.fifo_length);
+
+                               /* write the rest into the starting fragment */
+                               second_write_amount =
+                                   (unsigned short)(data_len -
+                                                    first_write_amount);
+                               fst_dbg(DBG_IOCTL,
+                                       "Second write amount is %d\n",
+                                       second_write_amount);
+                               fst_dbg(DBG_IOCTL, "Next write index is %d\n",
+                                       next_write_idx);
+                               fst_dbg(DBG_IOCTL, "Copying to offset %lx\n",
+                                       DT_OFFSET(tx_fifo) + h_size +
+                                       next_write_idx);
+                               if (first_write_amount > fst_min_dma_len) {
+                                       fst_tx_dsl_dma(card,
+                                                      (char *)
+                                                      card->tx_dma_handle_card
+                                                      + first_write_amount,
+                                                      (char *)
+                                                      DT_OFFSET(tx_fifo) +
+                                                      h_size + next_write_idx,
+                                                      second_write_amount);
+                               } else {
+                                       memcpy_toio(card->mem +
+                                                   DT_OFFSET(tx_fifo) +
+                                                   h_size + next_write_idx,
+                                                   data + first_write_amount,
+                                                   second_write_amount);
+                               }
+                               fifo.write_idx =
+                                   (unsigned
+                                    short)((fifo.write_idx +
+                                            second_write_amount)
+                                           % fifo.fifo_length);
+                       }
+                       fst_dbg(DBG_IOCTL,
+                               "atm_fifo_write: returned %d bytes written\n",
+                               data_len);
+                       retval = data_len;
+                       if (data_len !=
+                           first_write_amount + second_write_amount) {
+                               pr_err("Error in atm_write_into_fifo\n");
+                               pr_err("data_len = %d  fwa=%d  swa = %d\n",
+                                          data_len, first_write_amount,
+                                          second_write_amount);
+                       }
+               } else {
+                       /* Setting the overflow condition seems to upset the
+                        * card at the moment, so don't do it
+                        *
+                        * fifo.overflow_idx = fifo.write_idx;
+                        */
+                       retval = 0;
+                       fst_dbg(DBG_ASS,
+                               "atm_fifo_write: Not enough room for next pdu %d\n",
+                               data_len);
+                       fst_dbg(DBG_ASS,
+                               "free space = %d used space = %d available = %d\n",
+                               free_space, used_space, avail_fifo_space);
+                       fst_dbg(DBG_ASS,
+                               "Fifo header is: w_idx = %d  r_idx = %d\n",
+                               fifo.write_idx, fifo.read_idx);
+                       FST_WRB(card, dsl_control.spare[0], 0xff);
+               }

-               outl(regval | 0x40000000, card->pci_conf + CNTRL_9052);
-               outl(regval & ~0x40000000, card->pci_conf + CNTRL_9052);
        }
+       fst_dbg(DBG_IOCTL, "Updating the fifo header w_idx=%x  r_idx=%x\n",
+               fifo.write_idx, fifo.read_idx);
+       FST_DT_WRW(card, tx_fifo[WRITE_IDX], fifo.write_idx);
+       FST_DT_WRW(card, tx_fifo[OVERFLOW_IDX], fifo.overflow_idx);
+       return retval;
 }

-/*      Release the processor from reset
- */
-static inline void
-fst_cpurelease(struct fst_card_info *card)
+static void atm_send_idle_cell(struct fst_card_info *card)
 {
-       if (card->family == FST_FAMILY_TXU) {
-               /*
-                * Force posted writes to complete
-                */
-               (void) readb(card->mem);
+       fst_dbg(DBG_ATM, "Sending idle cell\n");
+       atm_write_into_fifo(card, atm_idle_cell, 53);
+       FST_WRW(card, dsl_control.bytes_to_send, 53);
+       fst_intr_card(card);
+}

-               /*
-                * Release LRESET DO = 1
-                * Then release Local Hold, DO = 1
-                */
-               outw(0x040e, card->pci_conf + CNTRL_9054 + 2);
-               outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
-       } else {
-               (void) readb(card->ctlmem);
+static int atm_check_read_length(struct fst_card_info *card)
+{
+       int h_size = 0;
+       struct fst_fifo fifo;
+       unsigned short amount_to_read = 0;
+
+       /* Return the amount of data in the rx fifo
+        */
+
+       fst_dbg(DBG_IOCTL, "%d: atm_check_read_length\n", card->card_no);
+       h_size = sizeof(struct fst_fifo) - 4;
+
+       fifo.fifo_length = FST_DR_RDW(card, rx_fifo[FIFO_LENGTH]);
+       fifo.read_idx = FST_DR_RDW(card, rx_fifo[READ_IDX]);
+       fifo.write_idx = FST_DR_RDW(card, rx_fifo[WRITE_IDX]);
+       fifo.overflow_idx = FST_DR_RDW(card, rx_fifo[OVERFLOW_IDX]);
+
+       amount_to_read = (unsigned short)((fifo.write_idx - fifo.read_idx +
+                                          fifo.fifo_length) %
+                                         fifo.fifo_length);
+       fst_dbg(DBG_IOCTL,
+               "Found %d bytes of data (%d -%d) in fifo of length %d\n",
+               amount_to_read, fifo.write_idx, fifo.read_idx,
+               fifo.fifo_length);
+       /* If amount to read is less than 1 cell and the overflow index is not
+        * 0xffff then reset overflow index to 0xffff
+        */
+       if ((amount_to_read < 53) && (fifo.overflow_idx != -1)) {
+               fst_dbg(DBG_ASS, "Resetting overflow index to -1\n");
+               fifo.overflow_idx = 0xffff;
+               FST_DR_WRW(card, rx_fifo[OVERFLOW_IDX], fifo.overflow_idx);
        }
+       return amount_to_read;
 }

-/*      Clear the cards interrupt flag
- */
-static inline void
-fst_clear_intr(struct fst_card_info *card)
+static void atm_empty_rx_fifo(struct fst_card_info *card)
 {
-       if (card->family == FST_FAMILY_TXU) {
-               (void) readb(card->ctlmem);
-       } else {
-               /* Poke the appropriate PLX chip register (same as enabling interrupts)
+       int h_size = 0;
+       struct fst_fifo fifo;
+
+       /* Set the rx fifo to empty */
+
+       fst_dbg(DBG_IOCTL, "atm_empty_rx_fifo\n");
+       h_size = sizeof(struct fst_fifo) - 4;
+
+       fifo.fifo_length = FST_DR_RDW(card, rx_fifo[FIFO_LENGTH]);
+       fifo.read_idx = FST_DR_RDW(card, rx_fifo[READ_IDX]);
+       fifo.write_idx = FST_DR_RDW(card, rx_fifo[WRITE_IDX]);
+       fifo.overflow_idx = FST_DR_RDW(card, rx_fifo[OVERFLOW_IDX]);
+
+       fifo.read_idx = fifo.write_idx;
+       FST_DR_WRW(card, rx_fifo[READ_IDX], fifo.read_idx);
+       fst_dbg(DBG_IOCTL, "atm_empty_rx_fifo: Setting read_idx to %x\n",
+               fifo.read_idx);
+       return;
+}
+
+static int atm_read_from_fifo(struct fst_card_info *card, char *data,
+                             int accumulated_len)
+{
+       int h_size = 0;
+       struct fst_fifo fifo;
+       unsigned short next_read_idx = 0;
+       unsigned short amount_to_read = 0;
+       char *data1 = NULL;
+       unsigned short length1;
+       char *data2 = NULL;
+       unsigned short length2;
+       int saved_len;
+
+       /* This function will read one cell at a time
+        * We need to check each cell to see if it the last in a PDU
+        * Return 0 if not last cell
+        * Return 1 if last cell
+        */
+       fst_dbg(DBG_IOCTL, "%d: atm_read_from_fifo\n", card->card_no);
+       h_size = sizeof(struct fst_fifo) - 4;
+       memcpy_fromio(&fifo, card->mem + DR_OFFSET(rx_fifo), h_size);
+       amount_to_read = (unsigned short)((fifo.write_idx - fifo.read_idx +
+                                          fifo.fifo_length) %
+                                         fifo.fifo_length);
+       saved_len = amount_to_read;
+       if (amount_to_read >= 53) {
+               amount_to_read = 53;
+               /* where should we start reading from ? */
+               next_read_idx = (unsigned short)((fifo.read_idx + 1) %
+                                                fifo.fifo_length);
+               fst_dbg(DBG_IOCTL, "Next read index = %d\n", next_read_idx);
+               data1 = card->mem + DR_OFFSET(rx_fifo) + h_size
+                 + next_read_idx;
+               length1 = (u16)min_t(u16, (u16)amount_to_read,
+                                             (unsigned short)(fifo.fifo_length
+                                                              -
+                                                              next_read_idx));
+               fst_dbg(DBG_IOCTL, "length1 = %d\n", length1);
+
+               data2 = card->mem + DR_OFFSET(rx_fifo) + h_size;
+               length2 = (unsigned short)(amount_to_read - length1);
+               if (length1 == 53) {
+                       fst_rx_dsl_dma(card,
+                                      (char *)card->rx_dma_handle_card,
+                                      (char *)DR_OFFSET(rx_fifo) + h_size +
+                                      next_read_idx, length1);
+                       memcpy(data, card->rx_dma_handle_host, length1);
+               } else {
+                       memcpy_fromio(data, data1, length1);
+               }
+               if (length2) {
+                       fst_dbg(DBG_IOCTL, "length2 = %d\n", length2);
+                       if (length1 == 53) {
+                               fst_rx_dsl_dma(card,
+                                              (char *)card->rx_dma_handle_card,
+                                              (char *)DR_OFFSET(rx_fifo) +
+                                              h_size, length2);
+                               memcpy(data + length1, card->rx_dma_handle_host,
+                                      length2);
+                       } else {
+                               memcpy_fromio(&data[length1], data2, length2);
+                       }
+               }
+               fifo.read_idx = (unsigned short)((fifo.read_idx +
+                                                 amount_to_read) %
+                                                fifo.fifo_length);
+               FST_DR_WRW(card, rx_fifo[READ_IDX], fifo.read_idx);
+               fst_dbg(DBG_IOCTL, "Finished read from fifo\n");
+               /* if the accumulated length + this cell exceeds max then
+                * return error
                 */
-               outw(0x0543, card->pci_conf + INTCSR_9052);
+               if ((accumulated_len + 53) > FST_MAX_ATM_MTU) {
+                       pr_err
+                           ("atm_read_from_fifo: max mtu size exceeded %d\n",
+                            FST_MAX_ATM_MTU);
+                       return -1;
+               }
+               /* Check the cell PTI for last cell */
+               if (data[3] & 0x2) {
+                       /*
+                        * PTI set so last frame
+                        * Check header
+                        */
+                       if (memcmp
+                           (data, card->ports[0]->last_atm_cell_header,
+                            4) == 0) {
+                               return 1;
+                       }
+                       pr_err("Invalid last cell header ");
+                       pr_err("length so far = %d len in fifo = %d\n",
+                            accumulated_len, saved_len);
+                       pr_err("Header is %x %x %x %x\n", data[0], data[1],
+                                  data[2], data[3]);
+                       pr_err("Write Index = %d Read Index = %d\n",
+                                  fifo.write_idx, fifo.read_idx);
+                       FST_RDB(card, end_of_smc_signature);
+                       fst_dbg(DBG_ATM, "Triggering analyser %lx\n",
+                               WIN_OFFSET(end_of_smc_signature));
+                       return -1;
+               } else {
+                       /*
+                        * Check header
+                        */
+                       if (memcmp(data, card->ports[0]->atm_cell_header, 4) ==
+                           0) {
+                               return 0;
+                       }
+                       pr_err("Invalid cell header ");
+                       pr_err("length so far = %d len in fifo = %d\n",
+                            accumulated_len, saved_len);
+                       pr_err("Header is %x %x %x %x\n", data[0], data[1],
+                                  data[2], data[3]);
+                       pr_err("Write Index = %d Read Index = %d\n",
+                                  fifo.write_idx, fifo.read_idx);
+                       FST_RDB(card, end_of_smc_signature);
+                       fst_dbg(DBG_ATM, "Triggering analyser %lx\n",
+                               WIN_OFFSET(end_of_smc_signature));
+                       return -1;
+               }
        }
+       return 0;
 }

-/*      Enable card interrupts
- */
-static inline void
-fst_enable_intr(struct fst_card_info *card)
+/* ATM Interface functions */
+
+/* CRC Routines from  net/wan/sbni.c)
+ * table generated by Rocksoft^tm Model CRC Algorithm Table Generation
+ * Program V1.0
+ */
+#define crc32(crc, mem, len) calc_crc(mem, len, crc);
+#define CRC32_REMAINDER CBF43926
+#define CRC32_INITIAL 0xffffffff
+#define CRC32(c, crc) \
+       (crc32tab[((size_t)(crc>>24) ^ (c)) & 0xff] ^ (((crc) << 8)))
+unsigned long crc32tab[256] = {
+       0x00000000L, 0x04C11DB7L, 0x09823B6EL, 0x0D4326D9L,
+       0x130476DCL, 0x17C56B6BL, 0x1A864DB2L, 0x1E475005L,
+       0x2608EDB8L, 0x22C9F00FL, 0x2F8AD6D6L, 0x2B4BCB61L,
+       0x350C9B64L, 0x31CD86D3L, 0x3C8EA00AL, 0x384FBDBDL,
+       0x4C11DB70L, 0x48D0C6C7L, 0x4593E01EL, 0x4152FDA9L,
+       0x5F15ADACL, 0x5BD4B01BL, 0x569796C2L, 0x52568B75L,
+       0x6A1936C8L, 0x6ED82B7FL, 0x639B0DA6L, 0x675A1011L,
+       0x791D4014L, 0x7DDC5DA3L, 0x709F7B7AL, 0x745E66CDL,
+       0x9823B6E0L, 0x9CE2AB57L, 0x91A18D8EL, 0x95609039L,
+       0x8B27C03CL, 0x8FE6DD8BL, 0x82A5FB52L, 0x8664E6E5L,
+       0xBE2B5B58L, 0xBAEA46EFL, 0xB7A96036L, 0xB3687D81L,
+       0xAD2F2D84L, 0xA9EE3033L, 0xA4AD16EAL, 0xA06C0B5DL,
+       0xD4326D90L, 0xD0F37027L, 0xDDB056FEL, 0xD9714B49L,
+       0xC7361B4CL, 0xC3F706FBL, 0xCEB42022L, 0xCA753D95L,
+       0xF23A8028L, 0xF6FB9D9FL, 0xFBB8BB46L, 0xFF79A6F1L,
+       0xE13EF6F4L, 0xE5FFEB43L, 0xE8BCCD9AL, 0xEC7DD02DL,
+       0x34867077L, 0x30476DC0L, 0x3D044B19L, 0x39C556AEL,
+       0x278206ABL, 0x23431B1CL, 0x2E003DC5L, 0x2AC12072L,
+       0x128E9DCFL, 0x164F8078L, 0x1B0CA6A1L, 0x1FCDBB16L,
+       0x018AEB13L, 0x054BF6A4L, 0x0808D07DL, 0x0CC9CDCAL,
+       0x7897AB07L, 0x7C56B6B0L, 0x71159069L, 0x75D48DDEL,
+       0x6B93DDDBL, 0x6F52C06CL, 0x6211E6B5L, 0x66D0FB02L,
+       0x5E9F46BFL, 0x5A5E5B08L, 0x571D7DD1L, 0x53DC6066L,
+       0x4D9B3063L, 0x495A2DD4L, 0x44190B0DL, 0x40D816BAL,
+       0xACA5C697L, 0xA864DB20L, 0xA527FDF9L, 0xA1E6E04EL,
+       0xBFA1B04BL, 0xBB60ADFCL, 0xB6238B25L, 0xB2E29692L,
+       0x8AAD2B2FL, 0x8E6C3698L, 0x832F1041L, 0x87EE0DF6L,
+       0x99A95DF3L, 0x9D684044L, 0x902B669DL, 0x94EA7B2AL,
+       0xE0B41DE7L, 0xE4750050L, 0xE9362689L, 0xEDF73B3EL,
+       0xF3B06B3BL, 0xF771768CL, 0xFA325055L, 0xFEF34DE2L,
+       0xC6BCF05FL, 0xC27DEDE8L, 0xCF3ECB31L, 0xCBFFD686L,
+       0xD5B88683L, 0xD1799B34L, 0xDC3ABDEDL, 0xD8FBA05AL,
+       0x690CE0EEL, 0x6DCDFD59L, 0x608EDB80L, 0x644FC637L,
+       0x7A089632L, 0x7EC98B85L, 0x738AAD5CL, 0x774BB0EBL,
+       0x4F040D56L, 0x4BC510E1L, 0x46863638L, 0x42472B8FL,
+       0x5C007B8AL, 0x58C1663DL, 0x558240E4L, 0x51435D53L,
+       0x251D3B9EL, 0x21DC2629L, 0x2C9F00F0L, 0x285E1D47L,
+       0x36194D42L, 0x32D850F5L, 0x3F9B762CL, 0x3B5A6B9BL,
+       0x0315D626L, 0x07D4CB91L, 0x0A97ED48L, 0x0E56F0FFL,
+       0x1011A0FAL, 0x14D0BD4DL, 0x19939B94L, 0x1D528623L,
+       0xF12F560EL, 0xF5EE4BB9L, 0xF8AD6D60L, 0xFC6C70D7L,
+       0xE22B20D2L, 0xE6EA3D65L, 0xEBA91BBCL, 0xEF68060BL,
+       0xD727BBB6L, 0xD3E6A601L, 0xDEA580D8L, 0xDA649D6FL,
+       0xC423CD6AL, 0xC0E2D0DDL, 0xCDA1F604L, 0xC960EBB3L,
+       0xBD3E8D7EL, 0xB9FF90C9L, 0xB4BCB610L, 0xB07DABA7L,
+       0xAE3AFBA2L, 0xAAFBE615L, 0xA7B8C0CCL, 0xA379DD7BL,
+       0x9B3660C6L, 0x9FF77D71L, 0x92B45BA8L, 0x9675461FL,
+       0x8832161AL, 0x8CF30BADL, 0x81B02D74L, 0x857130C3L,
+       0x5D8A9099L, 0x594B8D2EL, 0x5408ABF7L, 0x50C9B640L,
+       0x4E8EE645L, 0x4A4FFBF2L, 0x470CDD2BL, 0x43CDC09CL,
+       0x7B827D21L, 0x7F436096L, 0x7200464FL, 0x76C15BF8L,
+       0x68860BFDL, 0x6C47164AL, 0x61043093L, 0x65C52D24L,
+       0x119B4BE9L, 0x155A565EL, 0x18197087L, 0x1CD86D30L,
+       0x029F3D35L, 0x065E2082L, 0x0B1D065BL, 0x0FDC1BECL,
+       0x3793A651L, 0x3352BBE6L, 0x3E119D3FL, 0x3AD08088L,
+       0x2497D08DL, 0x2056CD3AL, 0x2D15EBE3L, 0x29D4F654L,
+       0xC5A92679L, 0xC1683BCEL, 0xCC2B1D17L, 0xC8EA00A0L,
+       0xD6AD50A5L, 0xD26C4D12L, 0xDF2F6BCBL, 0xDBEE767CL,
+       0xE3A1CBC1L, 0xE760D676L, 0xEA23F0AFL, 0xEEE2ED18L,
+       0xF0A5BD1DL, 0xF464A0AAL, 0xF9278673L, 0xFDE69BC4L,
+       0x89B8FD09L, 0x8D79E0BEL, 0x803AC667L, 0x84FBDBD0L,
+       0x9ABC8BD5L, 0x9E7D9662L, 0x933EB0BBL, 0x97FFAD0CL,
+       0xAFB010B1L, 0xAB710D06L, 0xA6322BDFL, 0xA2F33668L,
+       0xBCB4666DL, 0xB8757BDAL, 0xB5365D03L, 0xB1F740B4L
+};
+
+unsigned int calc_crc(char *mem, int len, unsigned initial)
 {
-       if (card->family == FST_FAMILY_TXU) {
-               outl(0x0f0c0900, card->pci_conf + INTCSR_9054);
-       } else {
-               outw(0x0543, card->pci_conf + INTCSR_9052);
+       unsigned crc;
+       crc = initial;
+
+       fst_dbg(DBG_ATM, "Calc CRC starting at %x\n", initial);
+       for (; len; mem++, len--)
+               crc = CRC32(*mem, crc);
+       return crc;
+}
+
+static int generate_crc(char *trailer, struct sk_buff *skb, int total_length)
+{
+       /* This function is called by generate_pdu to take a pdu and
+        * generate the CRC bytes for it.  The CRC is placed in the correct
+        * position of the pdu.
+        */
+       unsigned int crc = CRC32_INITIAL;
+
+       fst_dbg(DBG_ATM, "Generate CRC\n");
+       crc = ~crc32(crc, skb->data, total_length - 4);
+       fst_dbg(DBG_ATM, "CRC calculated as %x on %d bytes\n", crc,
+               total_length - 4);
+       *trailer++ = (unsigned char)(crc >> 24);
+       *trailer++ = (unsigned char)(crc >> 16);
+       *trailer++ = (unsigned char)(crc >> 8);
+       *trailer++ = (unsigned char)(crc & 0xff);
+       return 0;
+}
+
+#define ATM_HDR_GFC_SHIFT 28
+#define ATM_HDR_VPI_SHIFT 20
+#define ATM_HDR_VCI_SHIFT 4
+#define ATM_HDR_PTI_SHIFT 1
+
+/*Tx functions
+ */
+static void set_atm_header(struct fst_port_info *port, unsigned short vpi,
+                          unsigned short vci)
+{
+       /* We use a fixed structure for the atm cells, with a special one
+        * for the last cell.  This function updates them when the vpi/vci
+        * has been configured
+        */
+
+       int i;
+       unsigned long header;
+       unsigned char gfc = 0;
+       unsigned char pti = 0x0;
+       unsigned long last_pti = 0x1;
+       unsigned char mpoa_header[] = {
+           0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x08, 0x00 };
+
+       header = 0;
+       header = ((unsigned long)gfc << ATM_HDR_GFC_SHIFT)
+           | ((unsigned long)vpi << ATM_HDR_VPI_SHIFT)
+           | ((unsigned long)vci << ATM_HDR_VCI_SHIFT)
+           | ((unsigned long)pti << ATM_HDR_PTI_SHIFT);
+       header = htonl(header);
+       memcpy(&port->atm_cell_header, &header, 4);
+       header = 0;
+       header = ((unsigned long)gfc << ATM_HDR_GFC_SHIFT)
+           | ((unsigned long)vpi << ATM_HDR_VPI_SHIFT)
+           | ((unsigned long)vci << ATM_HDR_VCI_SHIFT)
+           | ((unsigned long)last_pti << ATM_HDR_PTI_SHIFT);
+       header = htonl(header);
+       memcpy(&port->last_atm_cell_header, &header, 4);
+       fst_dbg(DBG_ATM, "ATM Header calculated as %x %x %x %x\n",
+               port->atm_cell_header[0],
+               port->atm_cell_header[1], port->atm_cell_header[2],
+               port->atm_cell_header[3]);
+       fst_dbg(DBG_ATM, "Last ATM Header calculated as %x %x %x %x\n",
+               port->last_atm_cell_header[0], port->last_atm_cell_header[1],
+               port->last_atm_cell_header[2], port->last_atm_cell_header[3]);
+       memcpy(&port->mpoa_header, &mpoa_header, MPOA_HEADER_LEN);
+       fst_dbg(DBG_ATM,
+               "MPOA Header set to 0xaa 0xaa 0x03 0x00 0x00 0x00 0x08 0x00\n");
+       /* Lastly, format an idle cell
+        */
+       atm_idle_cell[0] = 0;
+       atm_idle_cell[1] = 0;
+       atm_idle_cell[2] = 0;
+       atm_idle_cell[3] = 1;
+       atm_idle_cell[4] = 0x52;
+       for (i = 0; i < 48; i++)
+               atm_idle_cell[i + 5] = 0x6a;
+}
+
+static struct sk_buff *generate_pdu(struct fst_port_info *port,
+                                   struct sk_buff *frame_ptr)
+{
+       /* This function is called from the start_hard_xmit function when
+        * it is determined that the frame requires atm encapsulation.
+        * The function will copy the pdu payload (yes, sorry) into the
+        * payload parts of a number of atm cells.  The last cell is
+        * updated with the pdu trailer (including CRC) and then the block
+        * of cells is handed off to the driver tx_bottom_half
+        */
+
+       struct sk_buff *pdu_ptr;
+       struct sk_buff *cell_ptr;
+       int pdu_len;
+       int padded_pdu_len;
+       unsigned char *pad;
+       unsigned char *trailer;
+       int no_of_cells;
+       char *source;
+       int i, len_to_copy;
+       int mpoa_header_len;
+
+       fst_dbg(DBG_ATM, "Generate PDU of length %d\n", frame_ptr->len);
+       pdu_len = frame_ptr->len;
+       /*
+        * Take into account the mpoa header if required
+        */
+       mpoa_header_len = 0;
+       if (port->encap == ENCAP_MPOA)
+               mpoa_header_len = MPOA_HEADER_LEN;
+       padded_pdu_len =
+           ((frame_ptr->len + mpoa_header_len + 8 + 47) / 48) * 48;
+       fst_dbg(DBG_ATM, "Length with atm padding is %d\n", padded_pdu_len);
+
+       /* Calculate the number of cells required */
+       no_of_cells = padded_pdu_len / 48;
+       fst_dbg(DBG_ATM, "No of cells required is %d\n", no_of_cells);
+       pdu_ptr = dev_alloc_skb(padded_pdu_len + (no_of_cells * 5));
+       if (!pdu_ptr) {
+               fst_dbg(DBG_ASS, "Could not allocate skb for atm cells\n");
+               return NULL;
+       }
+       cell_ptr = dev_alloc_skb(padded_pdu_len + (no_of_cells * 5));
+       if (!cell_ptr) {
+               fst_dbg(DBG_ASS, "Could not allocate skb for atm cells\n");
+               return NULL;
        }
+       fst_dbg(DBG_ATM, "Allocated Cells at %p\n", cell_ptr->data);
+       /*
+        * Copy the mpoa header in first if required
+        */
+       fst_dbg(DBG_ATM, "length of pdu so far id %d\n", pdu_ptr->len);
+       if (port->encap == ENCAP_MPOA) {
+               memcpy(pdu_ptr->data, port->mpoa_header, MPOA_HEADER_LEN);
+               pad = skb_put(pdu_ptr, MPOA_HEADER_LEN);
+       }
+       fst_dbg(DBG_ATM, "length of pdu so far id %d\n", pdu_ptr->len);
+       /*
+        * Copy the frame data into the pdu_ptr structure and add the trailer
+        */
+       memcpy(pdu_ptr->data + mpoa_header_len, frame_ptr->data,
+              frame_ptr->len);
+       /* Lets now zero the pad bytes */
+       fst_dbg(DBG_ATM, "Zero the pad bytes\n");
+       pad = skb_put(pdu_ptr, pdu_len);
+       fst_dbg(DBG_ATM, "length of pdu so far id %d\n", pdu_ptr->len);
+       pad = skb_put(pdu_ptr, padded_pdu_len - (pdu_len + mpoa_header_len));
+       fst_dbg(DBG_ATM, "length of pdu so far id %d\n", pdu_ptr->len);
+       memset(pad, 0, padded_pdu_len - (pdu_len + mpoa_header_len));
+
+       /* Set the trailer fields */
+       fst_dbg(DBG_ATM, "Setting the trailer bytes\n");
+       trailer = pdu_ptr->data + padded_pdu_len - 8;
+       pdu_len += mpoa_header_len;
+       *trailer++ = (unsigned char)0;  /* UU  = 0 */
+       *trailer++ = (unsigned char)0;  /* CPI = 0 */
+       *trailer++ = (unsigned char)(pdu_len >> 8);
+       *trailer++ = (unsigned char)(pdu_len & 0xff);
+       /* and CRC32 */
+       generate_crc(trailer, pdu_ptr, padded_pdu_len);
+
+       /* Now fragment the PDU into atm cells */
+       source = pdu_ptr->data;
+       for (i = 0; i < no_of_cells; i++) {
+               if (i == no_of_cells - 1) {
+                       fst_dbg(DBG_ATM, "Formatting atm final header\n");
+                       memcpy(skb_put(cell_ptr, 5), port->last_atm_cell_header,
+                              5);
+               } else {
+                       fst_dbg(DBG_ATM, "Formatting atm header for cell %d\n",
+                               i);
+                       memcpy(skb_put(cell_ptr, 5), port->atm_cell_header, 5);
+               }
+               len_to_copy = 48;       /* length of data */
+               fst_dbg(DBG_ATM, "Copying %d bytes of data to %p\n",
+                       len_to_copy, cell_ptr->data);
+               memcpy(skb_put(cell_ptr, len_to_copy), source, len_to_copy);
+               source += 48;
+       }
+       /* Free the pdu structure */
+       kfree_skb(pdu_ptr);
+       return cell_ptr;
 }

-/*      Disable card interrupts
+/* Rx Functions
  */
-static inline void
-fst_disable_intr(struct fst_card_info *card)
+static int validate_crc(char *pdu_ptr, int padded_len, unsigned int rcv_crc)
 {
-       if (card->family == FST_FAMILY_TXU) {
-               outl(0x00000000, card->pci_conf + INTCSR_9054);
-       } else {
-               outw(0x0000, card->pci_conf + INTCSR_9052);
+       /* This function is called by the process_rx_pdu function to check
+        * that the pdu crc bytes are correct.  By this time the pdu has
+        * all the cell headers stripped, but will include any padding?
+        */
+
+       unsigned int crc = CRC32_INITIAL;
+
+       fst_dbg(DBG_ATM, "Validate CRC\n");
+       crc = ~crc32(crc, pdu_ptr, padded_len - 4);
+       fst_dbg(DBG_ATM, "CRC recalculated as %x on %d bytes\n", crc,
+               padded_len - 4);
+       if (rcv_crc != crc) {
+               pr_err("CRC anomaly, received = %x, generated = %x\n",
+                          rcv_crc, crc);
+               return 1;
        }
+       return 0;
 }

-/*      Process the result of trying to pass a received frame up the stack
- */
-static void
-fst_process_rx_status(int rx_status, char *name)
+static struct sk_buff *process_rx_pdu(struct fst_port_info *port,
+                                     struct sk_buff *frame_ptr)
 {
-       switch (rx_status) {
-       case NET_RX_SUCCESS:
-               {
+       /* This is called when a port that has been tagged as supporting
+        * atm encapsulation receives a frame.  At this stage of the
+        * implementation we know that the frame will contain a single PDU
+        * in a number of atm cells. We need to get the pdu as a continuous
+        * string of bytes (maybe we can change this later), verify the CRC
+        * is correct and then hand the PDU up the network stack
+        */
+       int pdu_len;
+       int frame_len;
+       int padded_len;
+       int no_of_cells;
+       int i;
+       struct sk_buff *pdu_ptr;
+       unsigned int crc;
+       unsigned char *trailer;
+
+       fst_dbg(DBG_ATM, "Process RX PDU of length %d\n", frame_ptr->len);
+       /* Check for minimum length
+        */
+       if (frame_ptr->len < 53) {
+               pr_err("Invalid cell length received %d\n", frame_ptr->len);
+               return NULL;
+       }
+       padded_len = 0;
+       frame_len = frame_ptr->len;
+       /* How many ATM cells is this? */
+       no_of_cells = frame_len / 53;
+       fst_dbg(DBG_ATM, "No of atm cells = %d\n", no_of_cells);
+       pdu_ptr = dev_alloc_skb(frame_len);
+       if (!pdu_ptr) {
+               fst_dbg(DBG_ATM, "Could not allocate skb for atm cells\n");
+               return NULL;
+       }
+
+       fst_dbg(DBG_ATM, "Allocated PDU at %p\n", pdu_ptr->data);
+       for (i = 0; i < no_of_cells; i++) {
+               fst_dbg(DBG_ATM, "Evaluating Cell Header\n");
+               if (i == no_of_cells - 1) {
                        /*
-                        * Nothing to do here
+                        * Last cell header comparison
                         */
-                       break;
+                       if (memcmp
+                           (port->last_atm_cell_header, frame_ptr->data,
+                            4) != 0) {
+                               fst_dbg(DBG_ASS,
+                                       "Error in last cell header comparison\n");
+                               fst_dbg(DBG_ASS, "%x %x %x %x\n",
+                                       frame_ptr->data[0], frame_ptr->data[1],
+                                       frame_ptr->data[2], frame_ptr->data[3]);
+                               dev_kfree_skb(pdu_ptr);
+                               return NULL;
+                       } else {
+                               fst_dbg(DBG_ATM, "Last cell header OK\n");
+                               fst_dbg(DBG_ATM, "%x %x %x %x\n",
+                                       frame_ptr->data[0], frame_ptr->data[1],
+                                       frame_ptr->data[2], frame_ptr->data[3]);
+                       }
+               } else {
+                       /*
+                        * Any but last cell header comparison
+                        */
+                       if (memcmp(port->atm_cell_header, frame_ptr->data, 4) !=
+                           0) {
+                               fst_dbg(DBG_ASS,
+                                       "Error in cell header comparison\n");
+                               fst_dbg(DBG_ASS, "%x %x %x %x\n",
+                                       frame_ptr->data[0], frame_ptr->data[1],
+                                       frame_ptr->data[2], frame_ptr->data[3]);
+                               dev_kfree_skb(pdu_ptr);
+                               return NULL;
+                       } else {
+                               fst_dbg(DBG_ATM, "Cell header OK\n");
+                               fst_dbg(DBG_ATM, "%x %x %x %x\n",
+                                       frame_ptr->data[0], frame_ptr->data[1],
+                                       frame_ptr->data[2], frame_ptr->data[3]);
+
+                       }
                }
-       case NET_RX_DROP:
-               {
-                       dbg(DBG_ASS, "%s: Received packet dropped\n", name);
-                       break;
+               fst_dbg(DBG_ATM, "Extracting cell header for cell %d\n", i);
+               skb_pull(frame_ptr, 5);
+               fst_dbg(DBG_ATM, "Copying %d bytes of data to %p\n", 48,
+                       pdu_ptr->data);
+               memcpy(skb_put(pdu_ptr, 48), frame_ptr->data, 48);
+               skb_pull(frame_ptr, 48);
+               padded_len += 48;
+       }
+       trailer = pdu_ptr->data + padded_len - 8;
+       memcpy(&crc, &trailer[4], 4);
+       memcpy(&pdu_len, &trailer[2], 2);
+       crc = htonl(crc);
+       pdu_len = htons(pdu_len);
+       fst_dbg(DBG_ATM, "Received CRC is %x\n", crc);
+       fst_dbg(DBG_ATM, "Received length is %d\n", pdu_len);
+       /* By now we should have the PDU padded to an integral number of cells
+        */
+       if (validate_crc(pdu_ptr->data, padded_len, crc)) {
+               /*
+                * PDU CRC error detected, abort frame
+                */
+               dev_kfree_skb(pdu_ptr);
+               FST_WRB(port->card, dsl_control.spare[2], 0xff);
+               return NULL;
+       }
+       /* Remove any mpoa header that is there */
+       if (port->encap == ENCAP_MPOA) {
+               /* We should see an mpoa header, so check it */
+               if (memcmp(pdu_ptr->data, port->mpoa_header, MPOA_HEADER_LEN) !=
+                   0) {
+                       pr_err("Error in mpoa header comparison\n");
+                       pr_err("Recvd:  %x %x %x %x %x %x %x %x\n",
+                                  pdu_ptr->data[0], pdu_ptr->data[1],
+                                  pdu_ptr->data[2], pdu_ptr->data[3],
+                                  pdu_ptr->data[4], pdu_ptr->data[5],
+                                  pdu_ptr->data[6], pdu_ptr->data[7]);
+                       pr_err("Expctd: %x %x %x %x %x %x %x %x\n",
+                                  port->mpoa_header[0], port->mpoa_header[1],
+                                  port->mpoa_header[2], port->mpoa_header[3],
+                                  port->mpoa_header[4], port->mpoa_header[5],
+                                  port->mpoa_header[6], port->mpoa_header[7]);
+                       dev_kfree_skb(pdu_ptr);
+                       return NULL;
+               } else {
+                       fst_dbg(DBG_ATM, "MPOA Header OK\n");
+                       skb_pull(pdu_ptr, MPOA_HEADER_LEN);
+                       pdu_len -= MPOA_HEADER_LEN;
                }
        }
+       /* Validate the length of the pdu against the total length
+        * received, in case the pdu length is corrupted
+        */
+       if (pdu_len > padded_len) {
+               pr_err("Invalid pdu length %d %d\n", pdu_len, padded_len);
+               dev_kfree_skb(pdu_ptr);
+               return NULL;
+       }
+       /*
+        * Set the real length of the frame
+        */
+       pdu_ptr->len = pdu_len;
+       return pdu_ptr;
 }

 /*      Initilaise DMA for PLX 9054
  */
-static inline void
-fst_init_dma(struct fst_card_info *card)
+static inline void fst_init_dma(struct fst_card_info *card)
 {
-       /*
-        * This is only required for the PLX 9054
-        */
+       unsigned short pci_cr;
+
+       /* This is only required for the PLX 9054 */
        if (card->family == FST_FAMILY_TXU) {
-               pci_set_master(card->device);
+               fst_dbg(DBG_INTR, "Initialising DMA\n");
+               pci_read_config_word(card->device, PCICR, &pci_cr);
+               pci_cr |= 0x0004;
+               /* Enable DMA Bus mastering */
+               pci_write_config_word(card->device, PCICR, pci_cr);
                outl(0x00020441, card->pci_conf + DMAMODE0);
                outl(0x00020441, card->pci_conf + DMAMODE1);
-               outl(0x0, card->pci_conf + DMATHR);
+               outl(fst_dmathr, card->pci_conf + DMATHR);
        }
 }

@@ -823,30 +4153,20 @@ fst_init_dma(struct fst_card_info *card)
  */
 static void
 fst_tx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
-                   int len, int txpos)
+                   int len, int txpos, int flags)
 {
-       struct net_device *dev = port_to_dev(port);
-
+       fst_dbg(DBG_TX, "fst_tx_dma_complete\n");
        /*
         * Everything is now set, just tell the card to go
         */
-       dbg(DBG_TX, "fst_tx_dma_complete\n");
-       FST_WRB(card, txDescrRing[port->index][txpos].bits,
-               DMA_OWN | TX_STP | TX_ENP);
-       dev->stats.tx_packets++;
-       dev->stats.tx_bytes += len;
-       dev->trans_start = jiffies;
-}
-
-/*
- * Mark it for our own raw sockets interface
- */
-static __be16 farsync_type_trans(struct sk_buff *skb, struct net_device *dev)
-{
-       skb->dev = dev;
-       skb_reset_mac_header(skb);
-       skb->pkt_type = PACKET_HOST;
-       return htons(ETH_P_CUST);
+       if (flags & TX_ENP)
+               port_to_stats(port, tx_packets)++;
+       port_to_stats(port, tx_bytes) += len;
+       port_to_dev(port)->trans_start = jiffies;
+       if (port->mode == FST_MODE_TRANSPARENT)
+               flags = flags & 0xfe;
+       FST_WRB(card, tx_descr_ring[port->index][txpos].bits, flags);
+       fst_check_send(port);
 }

 /*      Rx dma complete interrupt
@@ -855,219 +4175,237 @@ static void
 fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
                    int len, struct sk_buff *skb, int rxp)
 {
-       struct net_device *dev = port_to_dev(port);
        int pi;
-       int rx_status;
+       int rx_status = NET_RX_SUCCESS;
+       int space_left;

-       dbg(DBG_TX, "fst_rx_dma_complete\n");
+       fst_dbg(DBG_RX, "fst_rx_dma_complete\n");
        pi = port->index;
-       memcpy(skb_put(skb, len), card->rx_dma_handle_host, len);
-
+       if (port->mtu_for_rx_skb != port_to_dev(port)->mtu)
+               fst_dbg(DBG_ASS, "MTU changed after dma started\n");
+       space_left = (port->mtu_for_rx_skb + MAX_PPP_HEADER) -
+           port->rxq.frame->len;
+       if (len <= space_left)
+               memcpy(skb_put(skb, len), card->rx_dma_handle_host, len);
+       else {
+               fst_dbg(DBG_ASS,
+                       "This dma skb copy would have exceeded max mtu %d %d %d\n",
+                       port->rxq.frame->len, len, port->rxq.segment_cnt);
+               fst_dbg(DBG_ASS, "Copying %d bytes\n", space_left);
+               memcpy(skb_put(skb, space_left), card->rx_dma_handle_host,
+                      space_left);
+       }
        /* Reset buffer descriptor */
-       FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
+       FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);

        /* Update stats */
-       dev->stats.rx_packets++;
-       dev->stats.rx_bytes += len;
+       fst_dbg(DBG_RX, "Updating stats by %d bytes\n", len);
+       port_to_stats(port, rx_bytes) += len;

-       /* Push upstream */
-       dbg(DBG_RX, "Pushing the frame up the stack\n");
-       if (port->mode == FST_RAW)
-               skb->protocol = farsync_type_trans(skb, dev);
-       else
-               skb->protocol = hdlc_type_trans(skb, dev);
-       rx_status = netif_rx(skb);
-       fst_process_rx_status(rx_status, port_to_dev(port)->name);
-       if (rx_status == NET_RX_DROP)
-               dev->stats.rx_dropped++;
+       if (port->rxq.flags & RX_ENP) {
+               struct sk_buff *new_skb;
+
+               if (port->monitor_mode)
+                       gen_mon_packet(skb, port, FST_MON_RX);
+               if ((port->vpi == 0) && (port->vci == 0)) {
+                       /*
+                        * There was no atm encapsualtion to remove
+                        */
+                       new_skb = skb;
+               } else {
+                       new_skb = process_rx_pdu(port, skb);
+                       kfree_skb(skb);
+                       if (new_skb == NULL) {
+                               pr_err("Error in received atm pdu\n");
+                               return;
+                       }
+               }
+               fst_dbg(DBG_RX, "Pushing the frame up the stack\n");
+               /* Push upstream */
+               skb_reset_mac_header(new_skb);
+               new_skb->dev = port_to_dev(port);
+               if (port->proto == FST_RAW) {
+                       /*
+                        * Mark it for our own raw sockets interface
+                        */
+                       new_skb->protocol = htons(ETH_P_CUST);
+                       new_skb->pkt_type = PACKET_HOST;
+               } else {
+                       if (port->char_file) {
+                               port->rxq.frame->protocol =
+                                   htons(ETH_P_WAN_PPP);
+                       } else {
+                               if (port->hdlc_proto == IF_PROTO_HDLC) {
+                                       new_skb->protocol = htons(ETH_P_IP);
+                               } else {
+                                       if (port->hdlc_proto ==
+                                           IF_PROTO_HDLC_ETH) {
+                                               new_skb->protocol =
+                                                   htons(ETH_P_8021Q);
+                                       } else {
+                                               new_skb->protocol =
+                                               hdlc_type_trans(new_skb,
+                                                               new_skb->dev);
+                                       }
+                               }
+                       }
+               }
+               if ((port->char_file) || (port->port_mode)) {
+                       st_fst_tty_area *fst_tty;
+                       fst_tty = &fst_tty_area[port->minor_dev_no];
+                       fst_tty->skb = skb;
+                       schedule_work(&(fst_tty->fst_tty_work));
+               } else {
+                       if (port->run)
+                               rx_status = netif_rx(new_skb);
+                       else {
+                               dev_kfree_skb(new_skb);
+                               fst_dbg(DBG_ASS,
+                                       "dma_comp: Discarding data, port closed\n");
+                       }
+               }
+               fst_process_rx_status(rx_status, port_to_dev(port)->name);
+               if (rx_status == NET_RX_DROP)
+                       port_to_stats(port, rx_dropped)++;
+               port_to_dev(port)->last_rx = jiffies;
+               port->rxq.frame = NULL;
+               port->rxq.segment_cnt = 0;
+       }
 }

-/*
- *      Receive a frame through the DMA
- */
+/* Receive a frame through the DMA  */
 static inline void
-fst_rx_dma(struct fst_card_info *card, dma_addr_t skb,
-          dma_addr_t mem, int len)
+fst_rx_dma(struct fst_card_info *card, unsigned char *skb,
+          unsigned char *mem, int len)
 {
-       /*
-        * This routine will setup the DMA and start it
-        */
+       /* This routine will setup the DMA and start it */

-       dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
-           (unsigned long) skb, (unsigned long) mem, len);
+       fst_dbg(DBG_RX, "In fst_rx_dma %p %p %d\n", skb, mem, len);
        if (card->dmarx_in_progress) {
-               dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");
+               fst_dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");
        }
+       /* Copy to here */
+       outl((unsigned long)skb, card->pci_conf + DMAPADR0);
+       /* from here */
+       outl((unsigned long)mem, card->pci_conf + DMALADR0);
+       /* for this length */
+       outl(len, card->pci_conf + DMASIZ0);
+       /* In this direction */
+       outl(0x00000000c, card->pci_conf + DMADPR0);

-       outl(skb, card->pci_conf + DMAPADR0);   /* Copy to here */
-       outl(mem, card->pci_conf + DMALADR0);   /* from here */
-       outl(len, card->pci_conf + DMASIZ0);    /* for this length */
-       outl(0x00000000c, card->pci_conf + DMADPR0);    /* In this direction */
-
-       /*
-        * We use the dmarx_in_progress flag to flag the channel as busy
+       /* We use the dmarx_in_progress flag to flag the channel as busy
         */
        card->dmarx_in_progress = 1;
        outb(0x03, card->pci_conf + DMACSR0);   /* Start the transfer */
 }

-/*
- *      Send a frame through the DMA
- */
+/* Send a frame through the DMA */
 static inline void
 fst_tx_dma(struct fst_card_info *card, unsigned char *skb,
           unsigned char *mem, int len)
 {
-       /*
-        * This routine will setup the DMA and start it.
-        */
-
-       dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
-       if (card->dmatx_in_progress) {
-               dbg(DBG_ASS, "In fst_tx_dma while dma in progress\n");
-       }
+       /* This routine will setup the DMA and start it. */

-       outl((unsigned long) skb, card->pci_conf + DMAPADR1);   /* Copy from here */
-       outl((unsigned long) mem, card->pci_conf + DMALADR1);   /* to here */
-       outl(len, card->pci_conf + DMASIZ1);    /* for this length */
-       outl(0x000000004, card->pci_conf + DMADPR1);    /* In this direction */
+       fst_dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
+       if (card->dmatx_in_progress)
+               fst_dbg(DBG_ASS, "In fst_tx_dma while dma in progress\n");
+       /* Copy from here */
+       outl((unsigned long)skb, card->pci_conf + DMAPADR1);
+       /* to here */
+       outl((unsigned long)mem, card->pci_conf + DMALADR1);
+       /* for this length */
+       outl(len, card->pci_conf + DMASIZ1);
+       /* In this direction */
+       outl(0x000000004, card->pci_conf + DMADPR1);

-       /*
-        * We use the dmatx_in_progress to flag the channel as busy
-        */
+       /* We use the dmatx_in_progress to flag the channel as busy */
        card->dmatx_in_progress = 1;
        outb(0x03, card->pci_conf + DMACSR1);   /* Start the transfer */
 }

-/*      Issue a Mailbox command for a port.
- *      Note we issue them on a fire and forget basis, not expecting to see an
- *      error and not waiting for completion.
- */
-static void
-fst_issue_cmd(struct fst_port_info *port, unsigned short cmd)
-{
-       struct fst_card_info *card;
-       unsigned short mbval;
-       unsigned long flags;
-       int safety;
-
-       card = port->card;
-       spin_lock_irqsave(&card->card_lock, flags);
-       mbval = FST_RDW(card, portMailbox[port->index][0]);
-
-       safety = 0;
-       /* Wait for any previous command to complete */
-       while (mbval > NAK) {
-               spin_unlock_irqrestore(&card->card_lock, flags);
-               schedule_timeout_uninterruptible(1);
-               spin_lock_irqsave(&card->card_lock, flags);
-
-               if (++safety > 2000) {
-                       pr_err("Mailbox safety timeout\n");
-                       break;
-               }
-
-               mbval = FST_RDW(card, portMailbox[port->index][0]);
-       }
-       if (safety > 0) {
-               dbg(DBG_CMD, "Mailbox clear after %d jiffies\n", safety);
-       }
-       if (mbval == NAK) {
-               dbg(DBG_CMD, "issue_cmd: previous command was NAK'd\n");
-       }
-
-       FST_WRW(card, portMailbox[port->index][0], cmd);
-
-       if (cmd == ABORTTX || cmd == STARTPORT) {
-               port->txpos = 0;
-               port->txipos = 0;
-               port->start = 0;
-       }
-
-       spin_unlock_irqrestore(&card->card_lock, flags);
-}
-
-/*      Port output signals control
- */
-static inline void
-fst_op_raise(struct fst_port_info *port, unsigned int outputs)
-{
-       outputs |= FST_RDL(port->card, v24OpSts[port->index]);
-       FST_WRL(port->card, v24OpSts[port->index], outputs);
-
-       if (port->run)
-               fst_issue_cmd(port, SETV24O);
-}
-
-static inline void
-fst_op_lower(struct fst_port_info *port, unsigned int outputs)
-{
-       outputs = ~outputs & FST_RDL(port->card, v24OpSts[port->index]);
-       FST_WRL(port->card, v24OpSts[port->index], outputs);
-
-       if (port->run)
-               fst_issue_cmd(port, SETV24O);
-}
-
-/*
- *      Setup port Rx buffers
- */
+/* Receive a DSL cell through the DMA  */
 static void
-fst_rx_config(struct fst_port_info *port)
+fst_rx_dsl_dma(struct fst_card_info *card, unsigned char *skb,
+              unsigned char *mem, int len)
 {
+       /* This routine will setup the DMA, start it, wait for it to finsih and
+        * then return to where we were called from.
+        * This is not optimal, but I'm interested to see if it performs well
+        * enough
+        */
        int i;
-       int pi;
-       unsigned int offset;
-       unsigned long flags;
-       struct fst_card_info *card;
+       static unsigned int largest_rx_time;

-       pi = port->index;
-       card = port->card;
-       spin_lock_irqsave(&card->card_lock, flags);
-       for (i = 0; i < NUM_RX_BUFFER; i++) {
-               offset = BUF_OFFSET(rxBuffer[pi][i][0]);
+       card->dmarx_in_progress = 1;
+       fst_dbg(DBG_RX, "In fst_rx_dsl_dma %p %p %d\n", skb, mem, len);
+       /* Copy to here */
+       outl((unsigned long)skb, card->pci_conf + DMAPADR0);
+       /* from here */
+       outl((unsigned long)mem, card->pci_conf + DMALADR0);
+       /* for this length */
+       outl(len, card->pci_conf + DMASIZ0);
+       /* In this direction */
+       outl(0x00000000c, card->pci_conf + DMADPR0);

-               FST_WRW(card, rxDescrRing[pi][i].ladr, (u16) offset);
-               FST_WRB(card, rxDescrRing[pi][i].hadr, (u8) (offset >> 16));
-               FST_WRW(card, rxDescrRing[pi][i].bcnt, cnv_bcnt(LEN_RX_BUFFER));
-               FST_WRW(card, rxDescrRing[pi][i].mcnt, LEN_RX_BUFFER);
-               FST_WRB(card, rxDescrRing[pi][i].bits, DMA_OWN);
+       /* We use the dma_done flag to know when the transfer is complete
+        */
+
+       outb(0x03, card->pci_conf + DMACSR0);   /* Start the transfer */
+       for (i = 0; i < 10000; i++) {
+               udelay(10);
+               if (!card->dmarx_in_progress)
+                       break;
+       }
+       if (i > largest_rx_time) {
+               fst_dbg(DBG_ASS,
+                       "Time to transfer rxbuffer(%d) = %d microseconds\n",
+                       len, i);
+               largest_rx_time = i;
        }
-       port->rxpos = 0;
-       spin_unlock_irqrestore(&card->card_lock, flags);
 }

-/*
- *      Setup port Tx buffers
- */
+/* Send a DSL PDU through the DMA  */
 static void
-fst_tx_config(struct fst_port_info *port)
+fst_tx_dsl_dma(struct fst_card_info *card, unsigned char *skb,
+              unsigned char *mem, int len)
 {
+       /* This routine will setup the DMA, start it, wait for it to finsih and
+        * then return to where we were called from.
+        * This is not optimal, but I'm interested to see if it performs well
+        * enough
+        */
        int i;
-       int pi;
-       unsigned int offset;
-       unsigned long flags;
-       struct fst_card_info *card;
+       static unsigned int largest_tx_time;

-       pi = port->index;
-       card = port->card;
-       spin_lock_irqsave(&card->card_lock, flags);
-       for (i = 0; i < NUM_TX_BUFFER; i++) {
-               offset = BUF_OFFSET(txBuffer[pi][i][0]);
+       card->dmatx_in_progress = 1;
+       fst_dbg(DBG_TX, "In fst_tx_dsl_dma %p %p %d\n", skb, mem, len);
+       /* Copy from here */
+       outl((unsigned long)skb, card->pci_conf + DMAPADR1);
+       /* to here */
+       outl((unsigned long)mem, card->pci_conf + DMALADR1);
+       /* for this length */
+       outl(len, card->pci_conf + DMASIZ1);
+       /* In this direction */
+       outl(0x000000004, card->pci_conf + DMADPR1);
+
+       /* We use the dma_done flag to know when the transfer is complete
+        */

-               FST_WRW(card, txDescrRing[pi][i].ladr, (u16) offset);
-               FST_WRB(card, txDescrRing[pi][i].hadr, (u8) (offset >> 16));
-               FST_WRW(card, txDescrRing[pi][i].bcnt, 0);
-               FST_WRB(card, txDescrRing[pi][i].bits, 0);
+       outb(0x03, card->pci_conf + DMACSR1);   /* Start the transfer */
+       for (i = 0; i < 10000; i++) {
+               udelay(10);
+               if (!card->dmatx_in_progress)
+                       break;
+       }
+       if (i > largest_tx_time) {
+               fst_dbg(DBG_TX,
+                       "Time to transfer txbuffer(%d) = %d microseconds\n",
+                       len, i);
+               largest_tx_time = i;
        }
-       port->txpos = 0;
-       port->txipos = 0;
-       port->start = 0;
-       spin_unlock_irqrestore(&card->card_lock, flags);
 }

-/*      TE1 Alarm change interrupt event
- */
+/* TE1 Alarm change interrupt event  */
 static void
 fst_intr_te1_alarm(struct fst_card_info *card, struct fst_port_info *port)
 {
@@ -1075,16 +4413,17 @@ fst_intr_te1_alarm(struct fst_card_info
        u8 rra;
        u8 ais;

-       los = FST_RDB(card, suStatus.lossOfSignal);
-       rra = FST_RDB(card, suStatus.receiveRemoteAlarm);
-       ais = FST_RDB(card, suStatus.alarmIndicationSignal);
+       los = FST_RDB(card, su_status.loss_of_signal);
+       rra = FST_RDB(card, su_status.receive_remote_alarm);
+       ais = FST_RDB(card, su_status.alarm_indication_signal);

        if (los) {
                /*
                 * Lost the link
                 */
-               if (netif_carrier_ok(port_to_dev(port))) {
-                       dbg(DBG_INTR, "Net carrier off\n");
+               if ((netif_carrier_ok(port_to_dev(port)))
+                   && (!port->ignore_carrier)) {
+                       fst_dbg(DBG_INTR, "Net carrier off\n");
                        netif_carrier_off(port_to_dev(port));
                }
        } else {
@@ -1092,24 +4431,76 @@ fst_intr_te1_alarm(struct fst_card_info
                 * Link available
                 */
                if (!netif_carrier_ok(port_to_dev(port))) {
-                       dbg(DBG_INTR, "Net carrier on\n");
+                       fst_dbg(DBG_INTR, "Net carrier on\n");
+
                        netif_carrier_on(port_to_dev(port));
                }
        }

        if (los)
-               dbg(DBG_INTR, "Assert LOS Alarm\n");
+               fst_dbg(DBG_INTR, "Assert LOS Alarm\n");
        else
-               dbg(DBG_INTR, "De-assert LOS Alarm\n");
+               fst_dbg(DBG_INTR, "De-assert LOS Alarm\n");
        if (rra)
-               dbg(DBG_INTR, "Assert RRA Alarm\n");
+               fst_dbg(DBG_INTR, "Assert RRA Alarm\n");
        else
-               dbg(DBG_INTR, "De-assert RRA Alarm\n");
+               fst_dbg(DBG_INTR, "De-assert RRA Alarm\n");

        if (ais)
-               dbg(DBG_INTR, "Assert AIS Alarm\n");
+               fst_dbg(DBG_INTR, "Assert AIS Alarm\n");
        else
-               dbg(DBG_INTR, "De-assert AIS Alarm\n");
+               fst_dbg(DBG_INTR, "De-assert AIS Alarm\n");
+}
+
+/*      DSL Activation Status change
+ */
+static void
+fst_dsl_acstchg(struct fst_card_info *card, struct fst_port_info *port)
+{
+       /* This alarm is generated each time the activation status byte changes
+        * When it changes we have to read it and process the byte accordingly.
+        * We only need to know if we are in data state or not so that we can
+        * assert or deaasert the carrier signal indication
+        */
+
+       port->activation_status = FST_RDB(card, dsl_status.activation_status);
+       if (port->activation_status == port->last_act_status) {
+               fst_dbg(DBG_ASS,
+                       "%s State change interrupt when state hasn't changed\n",
+                       port_to_dev(port)->name);
+               return;
+       }
+       port->last_act_status = port->activation_status;
+       if (port->activation_status >= 64) {
+               if (!netif_carrier_ok(port_to_dev(port))) {
+                       pr_info("%s SHDSL sync complete OK\n",
+                                   port_to_dev(port)->name);
+                       fst_dbg(DBG_INTR, "Net carrier on\n");
+                       netif_carrier_on(port_to_dev(port));
+                       /*
+                        * temp fix: Make sure the rx fifo is empty to dispose
+                        * of bad cell that seems to be there sometimes
+                        */
+                       atm_empty_rx_fifo(card);
+                       atm_send_idle_cell(card);       /* allow rx */
+               }
+       } else {
+               if (netif_carrier_ok(port_to_dev(port))) {
+                       pr_info("%s SHDSL sync lost %d\n",
+                                   port_to_dev(port)->name,
+                                   port->activation_status);
+                       fst_dbg(DBG_INTR, "Net carrier off\n");
+                       netif_carrier_off(port_to_dev(port));
+               }
+       }
+
+       /* One more possibility for loopback testing */
+       if ((port->activation_status >= 5) &&
+           (FST_RDB(card, dsl_config.test_mode))) {
+               pr_info("SHDSL sync in TestMode\n");
+               fst_dbg(DBG_INTR, "Net carrier on\n");
+               netif_carrier_on(port_to_dev(port));
+       }
 }

 /*      Control signal change interrupt event
@@ -1121,15 +4512,19 @@ fst_intr_ctlchg(struct fst_card_info *ca

        signals = FST_RDL(card, v24DebouncedSts[port->index]);

-       if (signals & (((port->hwif == X21) || (port->hwif == X21D))
-                      ? IPSTS_INDICATE : IPSTS_DCD)) {
-               if (!netif_carrier_ok(port_to_dev(port))) {
-                       dbg(DBG_INTR, "DCD active\n");
+       if (signals &
+           (((FST_RDW(card, port_config[port->index].line_interface) == X21)
+          || (FST_RDW(card, port_config[port->index].line_interface) == X21D))
+            ? IPSTS_INDICATE : IPSTS_DCD)) {
+               if ((!netif_carrier_ok(port_to_dev(port)))
+                   && (!port->ignore_carrier)) {
+                       fst_dbg(DBG_INTR, "%s: DCD active\n", port->dev->name);
                        netif_carrier_on(port_to_dev(port));
                }
        } else {
-               if (netif_carrier_ok(port_to_dev(port))) {
-                       dbg(DBG_INTR, "DCD lost\n");
+               if ((netif_carrier_ok(port_to_dev(port)))
+                   && (!port->ignore_carrier)) {
+                       fst_dbg(DBG_INTR, "%s: DCD lost\n", port->dev->name);
                        netif_carrier_off(port_to_dev(port));
                }
        }
@@ -1141,31 +4536,34 @@ static void
 fst_log_rx_error(struct fst_card_info *card, struct fst_port_info *port,
                 unsigned char dmabits, int rxp, unsigned short len)
 {
-       struct net_device *dev = port_to_dev(port);
-
        /*
         * Increment the appropriate error counter
         */
-       dev->stats.rx_errors++;
+       port_to_stats(port, rx_errors)++;
        if (dmabits & RX_OFLO) {
-               dev->stats.rx_fifo_errors++;
-               dbg(DBG_ASS, "Rx fifo error on card %d port %d buffer %d\n",
-                   card->card_no, port->index, rxp);
+               port_to_stats(port, rx_fifo_errors)++;
+               printk_ratelimited("Rx fifo (%x) error on card %d port %d buffer %d len %d\n",
+                          dmabits, card->card_no, port->index, rxp, len);
        }
        if (dmabits & RX_CRC) {
-               dev->stats.rx_crc_errors++;
-               dbg(DBG_ASS, "Rx crc error on card %d port %d\n",
-                   card->card_no, port->index);
+               port_to_stats(port, rx_crc_errors)++;
+               printk_ratelimited("Rx crc error on card %d port %d buffer %d\n",
+                                  card->card_no, port->index, rxp);
        }
        if (dmabits & RX_FRAM) {
-               dev->stats.rx_frame_errors++;
-               dbg(DBG_ASS, "Rx frame error on card %d port %d\n",
-                   card->card_no, port->index);
+               port_to_stats(port, rx_frame_errors)++;
+               printk_ratelimited("Rx frame error on card %d port %d buffer %d\n",
+                                  card->card_no, port->index, rxp);
+       }
+       if (dmabits & RX_HBUF) {
+               port_to_stats(port, rx_length_errors)++;
+               printk_ratelimited("Rx hardware error on card %d port %d buffer %d\n",
+                                  card->card_no, port->index, rxp);
        }
        if (dmabits == (RX_STP | RX_ENP)) {
-               dev->stats.rx_length_errors++;
-               dbg(DBG_ASS, "Rx length error (%d) on card %d port %d\n",
-                   len, card->card_no, port->index);
+               port_to_stats(port, rx_length_errors)++;
+               printk_ratelimited("Rx length error (%d) on card %d port %d buffer %d\n",
+                                  len, card->card_no, port->index, rxp);
        }
 }

@@ -1179,276 +4577,1061 @@ fst_recover_rx_error(struct fst_card_inf
        int pi;

        pi = port->index;
-       /*
-        * Discard buffer descriptors until we see the start of the
+       /*
+        * Discard the skb if we have one
+        */
+       if (port->rxq.frame != NULL) {
+               dev_kfree_skb(port->rxq.frame);
+               fst_dbg(DBG_ASS, "Free'd an skb at %p, card %d port %d\n",
+                       port->rxq.frame, card->card_no, port->index);
+               port->rxq.frame = NULL;
+       }
+       /* Discard buffer descriptors until we see the start of the
         * next frame.  Note that for long frames this could be in
-        * a subsequent interrupt.
+        * a subsequent interrupt.
         */
+       port->rxq.error_recovery++;
        i = 0;
-       while ((dmabits & (DMA_OWN | RX_STP)) == 0) {
-               FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
-               rxp = (rxp+1) % NUM_RX_BUFFER;
-               if (++i > NUM_RX_BUFFER) {
-                       dbg(DBG_ASS, "intr_rx: Discarding more bufs"
-                           " than we have\n");
+       while (dmabits & RX_ERR) {
+               dmabits = FST_RDB(card, rx_descr_ring[pi][rxp].bits);
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+               if (++rxp >= port->num_rx_buffers)
+                       rxp = 0;
+               if (++i > port->num_rx_buffers) {
+                       fst_dbg(DBG_ASS,
+                              "intr_rx: Discarding more bufs than we have\n");
                        break;
                }
-               dmabits = FST_RDB(card, rxDescrRing[pi][rxp].bits);
-               dbg(DBG_ASS, "DMA Bits of next buffer was %x\n", dmabits);
+               dmabits = FST_RDB(card, rx_descr_ring[pi][rxp].bits);
+               fst_dbg(DBG_ASS, "DMA Bits of next buffer was %x\n", dmabits);
        }
-       dbg(DBG_ASS, "There were %d subsequent buffers in error\n", i);
+       fst_dbg(DBG_ASS, "There were %d subsequent buffers in error\n", i);

        /* Discard the terminal buffer */
        if (!(dmabits & DMA_OWN)) {
-               FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
-               rxp = (rxp+1) % NUM_RX_BUFFER;
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+               if (++rxp >= port->num_rx_buffers)
+                       rxp = 0;
+       } else {
+               /* Found start of packet so error recovery
+                * complete
+                */
+               port->rxq.error_recovery = 0;
        }
        port->rxpos = rxp;
        return;

 }

-/*      Rx complete interrupt
+/*      Rx complete interrupt dsl cards
+ */
+static void
+fst_intr_rx_fifo(struct fst_card_info *card, struct fst_port_info *port)
+{
+       int len;
+       int cell_state;
+       char cell[53];
+       int rx_status = NET_RX_SUCCESS;
+       struct sk_buff *new_skb;
+       int saved_len;
+
+       /* Receive a pdu through the rx fifo
+        */
+       if (card->dmarx_in_progress) {
+               pr_err("Trying to start rx dma when already in progress\n");
+               return;
+       }
+       len = atm_check_read_length(card);
+       if (len >= 53) {
+               saved_len = len;
+               /*
+                * We only want to read complete cells at a time
+                */
+               len = (len / 53) * 53;
+               while (len > 0) {
+                       /* We have to have at least one cell to get but have we
+                        * allocated a buffer for it yet?
+                        */
+                       if (port->rxq.frame == NULL) {
+                               /* We are not currently assembling a cell.
+                                * This is the first.
+                                */
+                               port->rxq.frame =
+                                   dev_alloc_skb(FST_MAX_ATM_MTU + 53);
+                               if (port->rxq.frame == NULL) {
+                                       fst_dbg(DBG_ASS,
+                                       "intr_rx: can't allocate buffer\n");
+                                       port_to_stats(port, rx_dropped)++;
+                                       port->rxq.error_recovery++;
+
+                                       /* Empty the fifo */
+                                       atm_empty_rx_fifo(card);
+                                       return;
+                               }
+                               port->rxq.flags = RX_STP;
+                               port->rxq.count = 0;
+                               port->rxq.segment_cnt = 0;
+                       }
+                       /*
+                        * Now try and get the next cell
+                        */
+                       cell_state =
+                           atm_read_from_fifo(card, cell, port->rxq.count);
+                       switch (cell_state) {
+                       case 1:
+                               {
+                                       /*
+                                        * This was the last cell of a pdu so
+                                        * Update stats
+                                        */
+                                       memcpy(skb_put(port->rxq.frame, 53),
+                                              cell, 53);
+                                       port_to_stats(port, rx_packets)++;
+                                       port_to_stats(port, rx_bytes) =
+                                           port->rxq.count + 53;
+                                       fst_dbg(DBG_RX,
+                                       "Received PDU of %d bytes, %d cells\n",
+                                               port->rxq.count + 53,
+                                               port->rxq.segment_cnt + 1);
+                                       fst_dbg(DBG_RX,
+                                       "Pushing frame up the stack\n");
+                                       if (port->monitor_mode)
+                                               gen_mon_packet(port->rxq.frame,
+                                                              port,
+                                                              FST_MON_RX);
+                                       if ((port->vpi == 0)
+                                           && (port->vci == 0)) {
+                                               /*
+                                                * There was no atm
+                                                * encapsualtion to remove
+                                                */
+                                               new_skb = port->rxq.frame;
+                                       } else {
+                                               new_skb =
+                                                   process_rx_pdu(port,
+                                                                  port->
+                                                                  rxq.frame);
+                                               kfree_skb(port->rxq.frame);
+                                               if (new_skb == NULL) {
+                                                       port->rxq.frame = NULL;
+                                                       fst_dbg(DBG_ASS,
+                                                       "Error in processing rx atm pdu\n");
+                                                       port->atm_cells_dropped++;
+                                                       return;
+                                               }
+                                       }
+                                       /* Push upstream */
+                                       skb_reset_mac_header(new_skb);
+                                       new_skb->dev = port_to_dev(port);
+                                       if (port->proto == FST_RAW) {
+                                               /* DEC customer specific
+                                                *  protocol
+                                                */
+                                               new_skb->protocol =
+                                                   htons(ETH_P_CUST);
+                                               new_skb->pkt_type =
+                                                   PACKET_HOST;
+                                       } else {
+                                               if (port->char_file) {
+                                                       port->rxq.
+                                                           frame->protocol =
+                                                           htons
+                                                           (ETH_P_WAN_PPP);
+                                               } else {
+                                                       if (port->hdlc_proto ==
+                                                           IF_PROTO_HDLC) {
+                                                               new_skb->protocol
+                                                                   =
+                                                                   htons
+                                                                   (ETH_P_IP);
+                                                       } else {
+                                                               if (port->hdlc_proto == IF_PROTO_HDLC_ETH) {
+                                                                       new_skb->protocol
+                                                                           =
+                                                                           htons
+                                                                           (ETH_P_8021Q);
+                                                               } else {
+                                                                       new_skb->protocol
+                                                                           =
+                                                                           hdlc_type_trans
+                                                                           (new_skb,
+                                                                            new_skb->dev);
+                                                               }
+                                                       }
+                                               }
+                                       }
+                                       if ((port->char_file)
+                                           || (port->port_mode)) {
+                                               st_fst_tty_area *fst_tty;
+                                               fst_tty =
+                                                   &fst_tty_area
+                                                   [port->minor_dev_no];
+                                               fst_tty->skb = new_skb;
+                                               schedule_work(&
+                                                             (fst_tty->fst_tty_work));
+                                       } else {
+                                               if (port->run)
+                                                       rx_status =
+                                                           netif_rx(new_skb);
+                                               else {
+                                                       dev_kfree_skb(new_skb);
+                                                       fst_dbg(DBG_ASS,
+                                                               "inline: Discarding data, port closed\n");
+                                               }
+                                       }
+                                       fst_process_rx_status(rx_status,
+                                                             port_to_dev
+                                                             (port)->name);
+                                       if (rx_status == NET_RX_DROP) {
+                                               port_to_stats(port,
+                                                             rx_dropped)++;
+                                       }
+                                       port_to_dev(port)->last_rx = jiffies;
+                                       port->rxq.frame = NULL;
+                                       break;
+                               }
+                       case 0:
+                               {
+                                       /*
+                                        * Not the last cell of a pdu
+                                        */
+                                       memcpy(skb_put(port->rxq.frame, 53),
+                                              cell, 53);
+                                       port->rxq.count += 53;
+                                       port->rxq.segment_cnt++;
+                                       fst_dbg(DBG_RX,
+                                               "rx cell %d, length now %d\n",
+                                               port->rxq.segment_cnt,
+                                               port->rxq.count);
+                                       break;
+                               }
+                       default:
+                               {
+                                       /*
+                                        * An error with the cell format
+                                        * free skb and start again
+                                        */
+                                       pr_err
+                        ("Error in rx cell, original length of fifo was %d\n",
+                                            saved_len);
+                                       kfree_skb(port->rxq.frame);
+                                       port->rxq.frame = NULL;
+                                       port->atm_cells_dropped++;
+                               }
+                       }       /* End case */
+                       len -= 53;
+               }               /* End while */
+       }
+}
+
+/*      Async Rx event interrupt
+ */
+static void
+fst_intr_async_rx_event(struct fst_card_info *card, struct fst_port_info *port)
+{
+       char *event_buff = NULL;
+       int len;
+       static int largest_rx;
+       int i;
+
+       fst_dbg(DBG_RX, "%s: fst_intr_async_rx_event\n", port->dev->name);
+       event_buff = kmalloc(MAX_RX_EVENT_FIFO_LEN, GFP_ATOMIC);
+       if (event_buff == NULL) {
+               fst_dbg(DBG_ASS, "%s: Cannot allocate memory for rx event\n",
+                      port->dev->name);
+               return;
+       }
+       len = read_from_fifo(card->mem +
+                            ASY_OFFSET(rx_event_fifos[port->index]),
+                            FIFO_ASY_RXEVNT,
+                            event_buff, MAX_RX_EVENT_FIFO_LEN);
+       if (len > largest_rx) {
+               fst_dbg(DBG_RX, "Largest read from asy rx event fifo is %d\n",
+                       len);
+               largest_rx = len;
+       }
+       fst_dbg(DBG_RX, "%s: Read %d bytes from rx event fifo\n",
+               port->dev->name, len);
+
+       /* On the current implementation the events are single bytes
+        * and are a bit map of events
+        */
+       for (i = 0; i < len; i++) {
+               fst_dbg(DBG_ASS, "Event was %x\n", event_buff[i]);
+               if (event_buff[i] & ASYNC_STAT_OVR) {
+                       port_to_stats(port, rx_over_errors)++;
+                       pr_info("%s: Async - Overrun error\n",
+                              port_to_dev(port)->name);
+               }
+               if (event_buff[i] & ASYNC_STAT_PAR) {
+                       port_to_stats(port, rx_crc_errors)++;
+                       pr_info("%s: Async - Parity error\n",
+                              port_to_dev(port)->name);
+               }
+               if (event_buff[i] & ASYNC_STAT_FRM) {
+                       port_to_stats(port, rx_frame_errors)++;
+                       pr_info("%s: Async - Framing error\n",
+                              port_to_dev(port)->name);
+               }
+               if (event_buff[i] & ASYNC_STAT_BRK) {
+                       port_to_stats(port, rx_length_errors)++;
+                       pr_info("%s: Async - Recieved Break\n",
+                              port_to_dev(port)->name);
+               }
+       }
+       kfree(event_buff);
+}
+
+/*      Async Rx complete interrupt
  */
 static void
-fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
+fst_intr_async_rx(struct fst_card_info *card, struct fst_port_info *port)
+{
+       st_fst_tty_area *fst_tty;
+       char *rx_buff = NULL;
+       int len;
+       static int largest_rx;
+
+       fst_dbg(DBG_RX, "%s: fst_intr_async_rx\n", port->dev->name);
+       rx_buff = kmalloc(FST_RX_DATA_FIFO_LEN, GFP_ATOMIC);
+       if (rx_buff == NULL) {
+               fst_dbg(DBG_ASS, "%s: Cannot allocate memory for rx buffer\n",
+                      port->dev->name);
+               return;
+       }
+       card->dma_port_rx = port;
+       len = read_from_fifo(card->mem + ASY_OFFSET(rx_fifo[port->index]),
+                            FIFO_ASY_RX, rx_buff, FST_RX_DATA_FIFO_LEN);
+       if (len > largest_rx) {
+               fst_dbg(DBG_RX, "Largest read from asy rx fifo is %d\n", len);
+               largest_rx = len;
+       }
+       fst_dbg(DBG_RX, "%s: Read %d bytes from rx fifo\n",
+               port->dev->name, len);
+       fst_tty = &fst_tty_area[port->minor_dev_no];
+       fst_tty->len = len;
+       fst_tty->data = rx_buff;
+       schedule_work(&(fst_tty->fst_async_tty_work));
+}
+
+/*      Rx complete interrupt normal cards
+ */
+static void fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 {
        unsigned char dmabits;
        int pi;
        int rxp;
-       int rx_status;
-       unsigned short len;
-       struct sk_buff *skb;
-       struct net_device *dev = port_to_dev(port);
+       int rx_status = NET_RX_SUCCESS;
+       unsigned short len = 0;

        /* Check we have a buffer to process */
        pi = port->index;
        rxp = port->rxpos;
-       dmabits = FST_RDB(card, rxDescrRing[pi][rxp].bits);
+       dmabits = FST_RDB(card, rx_descr_ring[pi][rxp].bits);
        if (dmabits & DMA_OWN) {
-               dbg(DBG_RX | DBG_INTR, "intr_rx: No buffer port %d pos %d\n",
-                   pi, rxp);
+               fst_dbg(DBG_RX | DBG_INTR,
+                       "intr_rx: No buffer port %d pos %d\n", pi, rxp);
                return;
        }
        if (card->dmarx_in_progress) {
                return;
        }

-       /* Get buffer length */
-       len = FST_RDW(card, rxDescrRing[pi][rxp].mcnt);
-       /* Discard the CRC */
-       len -= 2;
-       if (len == 0) {
+       /* If a multi segment message, we need to assume the frame length
+        */
+       if ((dmabits == 0) || (dmabits == RX_STP)) {
                /*
-                * This seems to happen on the TE1 interface sometimes
-                * so throw the frame away and log the event.
+                * start or middle frame, assume length is RX_LEN_BUFFER
                 */
-               pr_err("Frame received with 0 length. Card %d Port %d\n",
-                      card->card_no, port->index);
-               /* Return descriptor to card */
-               FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
-
-               rxp = (rxp+1) % NUM_RX_BUFFER;
-               port->rxpos = rxp;
-               return;
+               len = port->rx_buffer_size;
+       } else {
+               /* ... unless it is the last or only buffer
+                * In this case Get buffer length
+                */
+               len = FST_RDW(card, rx_descr_ring[pi][rxp].mcnt);
+               if (port->mode == FST_MODE_HDLC) {
+                       /*
+                        * Is the CRC in this buffer or the previous one?
+                        */
+                       if ((len % (port->rx_buffer_size)) == 2) {
+                               /*
+                                * Both crc bytes are here
+                                * The decrement below will get rid of them
+                                */
+                       }
+                       if ((len % (port->rx_buffer_size)) == 1) {
+                               /* We have 1 crc byte here and 1 as the
+                                * last byte of the previous buffer.
+                                * Decrement the overall length by 1
+                                */
+                               port->rxq.frame->len--;
+                               port_to_stats(port, rx_bytes)--;
+                       }
+                       /* Discard the CRC */
+                       len -= 2;
+               }
        }
-
-       /* Check buffer length and for other errors. We insist on one packet
-        * in one buffer. This simplifies things greatly and since we've
-        * allocated 8K it shouldn't be a real world limitation
-        */
-       dbg(DBG_RX, "intr_rx: %d,%d: flags %x len %d\n", pi, rxp, dmabits, len);
-       if (dmabits != (RX_STP | RX_ENP) || len > LEN_RX_BUFFER - 2) {
+       fst_dbg(DBG_RX, "intr_rx: %d,%d: flags %x len %d\n", pi, rxp, dmabits,
+               len);
+       if (dmabits > (RX_STP | RX_ENP) || len > FST_MAX_MTU) {
                fst_log_rx_error(card, port, dmabits, rxp, len);
                fst_recover_rx_error(card, port, dmabits, rxp, len);
                return;
        }

-       /* Allocate SKB */
-       if ((skb = dev_alloc_skb(len)) == NULL) {
-               dbg(DBG_RX, "intr_rx: can't allocate buffer\n");
+       /* Are we in error recovery mode ? */
+       if (port->rxq.error_recovery) {
+               if (dmabits & RX_STP) {
+                       fst_dbg(DBG_ASS, "Error recovery complete\n");
+                       port->rxq.error_recovery = 0;
+               } else {
+                       /*
+                        * Still waiting for the next start of packet
+                        * to complete error recovery
+                        * So discard this descriptor
+                        */
+                       FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+                       if (++rxp >= port->num_rx_buffers)
+                               port->rxpos = 0;
+                       else
+                               port->rxpos = rxp;
+                       return;
+               }
+       }

-               dev->stats.rx_dropped++;
+       /* There were no errors. */
+       fst_dbg(DBG_RX, "segments so far = %d\n", port->rxq.segment_cnt);
+       fst_dbg(DBG_RX, "Rx with no errors\n");
+       if (port->mode == FST_MODE_TRANSPARENT)
+               dmabits |= RX_STP | RX_ENP;
+       if (dmabits & RX_STP) {
+               fst_dbg(DBG_RX, "Rx first segment len = %d\n", len);
+               /* First segment of a frame so allocate SKB */
+               port->mtu_for_rx_skb = port_to_dev(port)->mtu;
+               port->rxq.frame =
+                   dev_alloc_skb(port->mtu_for_rx_skb + MAX_PPP_HEADER);
+               if (port->rxq.frame == NULL) {
+                       fst_dbg(DBG_ASS,
+                               "intr_rx: can't allocate buffer of %d\n",
+                               port->mtu_for_rx_skb + MAX_PPP_HEADER);
+
+                       port_to_stats(port, rx_dropped)++;
+                       port->rxq.error_recovery++;
+
+                       /* Return descriptor to card */
+                       FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+
+                       if (++rxp >= port->num_rx_buffers)
+                               port->rxpos = 0;
+                       else
+                               port->rxpos = rxp;
+                       return;
+               }
+               port->rxq.flags = RX_STP;
+               port->rxq.count = len;
+               port->rxq.segment_cnt = 1;
+       }

-               /* Return descriptor to card */
-               FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
+       if (dmabits & RX_ENP) {
+               if (!(port->rxq.flags & RX_STP)) {
+                       fst_dbg(DBG_ASS, "End frame without a start\n");
+                       /* Reset buffer descriptor */
+                       FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+                       if (++rxp >= port->num_rx_buffers)
+                               port->rxpos = 0;
+                       else
+                               port->rxpos = rxp;
+                       return;
+               }
+               /* Last segment.  The length we read into len is the total
+                * length across all segments.  So now we need to ajust it
+                * to get the bytes in this segment.
+                */
+               port->rxq.flags |= RX_ENP;
+               port->rxq.count = len;
+               if (!(dmabits & RX_STP))
+                       port->rxq.segment_cnt++;
+               if (port->rxq.segment_cnt > last_segment_cnt) {
+                       last_segment_cnt = port->rxq.segment_cnt;
+                       fst_dbg(DBG_RX, "Segment count up to %d\n",
+                               last_segment_cnt);
+               }
+               port_to_stats(port, rx_packets)++;
+               if (port->rxq.segment_cnt > 1) {
+                       int temp;
+                       /* More than one segment so adjustment needed
+                        */
+                       fst_dbg(DBG_RX,
+                               "Adjusting length %d for %d segments\n",
+                               len, port->rxq.segment_cnt);
+                       temp =
+                           len -
+                           ((port->rxq.segment_cnt -
+                             1) * (port->rx_buffer_size));
+                       if (temp < 0) {
+                               fst_dbg(DBG_TX,
+                                       "CRC split across segments %d!!!\n",
+                                       temp);
+                               temp = 0;
+                       }
+                       len = temp;
+               }
+               fst_dbg(DBG_RX, "Rx last segment len = %d\n", len);
+       }

-               rxp = (rxp+1) % NUM_RX_BUFFER;
-               port->rxpos = rxp;
+       if (dmabits == 0) {
+               if (!(port->rxq.flags & RX_STP)) {
+                       fst_dbg(DBG_ASS, "Middle frame without a start\n");
+                       /* Reset buffer descriptor */
+                       FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+                       if (++rxp >= port->num_rx_buffers)
+                               port->rxpos = 0;
+                       else
+                               port->rxpos = rxp;
+                       return;
+               }
+
+               fst_dbg(DBG_RX, "Rx Middle segment len = %d\n", len);
+               port->rxq.count += len;
+               port->rxq.segment_cnt++;
+       }
+
+       /* Finally, some belt and braces checks */
+       if (len == 0 && (port->rxq.segment_cnt == 1)) {
+               pr_err("Zero length hdlc frame received\n");
+               port_to_stats(port, rx_length_errors)++;
+               /* Reset buffer descriptor */
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+               if (++rxp >= port->num_rx_buffers)
+                       port->rxpos = 0;
+               else
+                       port->rxpos = rxp;
+               return;
+       }
+       if (port->rxq.segment_cnt > FST_MAX_SEGMENTS) {
+               pr_err("Too many segments received %d\n",
+                          port->rxq.segment_cnt);
+               /* Reset buffer descriptor */
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+               if (++rxp >= port->num_rx_buffers)
+                       port->rxpos = 0;
+               else
+                       port->rxpos = rxp;
                return;
        }

-       /*
-        * We know the length we need to receive, len.
+       if (port->rxq.frame == NULL) {
+               fst_dbg(DBG_ASS,
+                       "Unexpected NULL skb. flags = %x dmabits = %x\n",
+                       port->rxq.flags, dmabits);
+               /* Reset buffer descriptor */
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);
+               if (++rxp >= port->num_rx_buffers)
+                       port->rxpos = 0;
+               else
+                       port->rxpos = rxp;
+               return;
+       }
+
+       /* We know the length we need to receive, len.
         * It's not worth using the DMA for reads of less than
-        * FST_MIN_DMA_LEN
+        * fst_min_dma_len
         */

-       if ((len < FST_MIN_DMA_LEN) || (card->family == FST_FAMILY_TXP)) {
-               memcpy_fromio(skb_put(skb, len),
-                             card->mem + BUF_OFFSET(rxBuffer[pi][rxp][0]),
-                             len);
+       if ((len < fst_min_dma_len) || (card->family == FST_FAMILY_TXP)) {
+               int space_left;

+               space_left = (port->mtu_for_rx_skb + MAX_PPP_HEADER) -
+                   port->rxq.frame->len;
+               if (len <= space_left) {
+                       memcpy_fromio(skb_put(port->rxq.frame, len),
+                                     card->mem + BUF_OFFSET(rx_buffer[pi][0])
+                                     + rxp * port->rx_buffer_size, len);
+               } else {
+                       fst_dbg(DBG_ASS,
+                       "This inline skb copy would have exceeded max mtu %d %d %d\n",
+                               port->rxq.frame->len, len,
+                               port->rxq.segment_cnt);
+                       fst_dbg(DBG_ASS, "Copying %d bytes\n", space_left);
+                       memcpy_fromio(skb_put(port->rxq.frame, space_left),
+                                     card->mem + BUF_OFFSET(rx_buffer[pi][0])
+                                     + rxp*port->rx_buffer_size, space_left);
+               }
                /* Reset buffer descriptor */
-               FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
+               FST_WRB(card, rx_descr_ring[pi][rxp].bits, DMA_OWN);

                /* Update stats */
-               dev->stats.rx_packets++;
-               dev->stats.rx_bytes += len;
+               fst_dbg(DBG_RX, "Updating stats by %d bytes\n", len);
+               port_to_stats(port, rx_bytes) += len;

-               /* Push upstream */
-               dbg(DBG_RX, "Pushing frame up the stack\n");
-               if (port->mode == FST_RAW)
-                       skb->protocol = farsync_type_trans(skb, dev);
-               else
-                       skb->protocol = hdlc_type_trans(skb, dev);
-               rx_status = netif_rx(skb);
-               fst_process_rx_status(rx_status, port_to_dev(port)->name);
-               if (rx_status == NET_RX_DROP)
-                       dev->stats.rx_dropped++;
+               if (port->rxq.flags & RX_ENP) {
+                       struct sk_buff *new_skb;
+                       fst_dbg(DBG_RX, "%s: Pushing frame up the stack\n",
+                               port_to_dev(port)->name);
+                       if (port->monitor_mode)
+                               gen_mon_packet(port->rxq.frame, port,
+                                              FST_MON_RX);
+                       if ((port->vpi == 0) && (port->vci == 0)) {
+                               /*
+                                * There was no atm encapsualtion to remove
+                                */
+                               new_skb = port->rxq.frame;
+                       } else {
+                               new_skb = process_rx_pdu(port, port->rxq.
+                                                        frame);
+                               kfree_skb(port->rxq.frame);
+                               if (new_skb == NULL) {
+                                       pr_err
+                                       ("Error in processing rx atm pdu\n");
+                                       if (++rxp >= port->num_rx_buffers)
+                                               port->rxpos = 0;
+                                       else
+                                               port->rxpos = rxp;
+                                       return;
+                               }
+                       }
+                       /* Push upstream */
+                       skb_reset_mac_header(new_skb);
+                       new_skb->dev = port_to_dev(port);
+                       if (port->proto == FST_RAW) {
+                               /* DEC customer specific protocol
+                                */
+                               new_skb->protocol = htons(ETH_P_CUST);
+                               new_skb->pkt_type = PACKET_HOST;
+                       } else {
+                               if (port->char_file) {
+                                       port->rxq.frame->protocol =
+                                           htons(ETH_P_WAN_PPP);
+                               } else {
+                                       if (port->hdlc_proto == IF_PROTO_HDLC) {
+                                               new_skb->protocol =
+                                                   htons(ETH_P_IP);
+                                       } else {
+                                               if (port->hdlc_proto ==
+                                                   IF_PROTO_HDLC_ETH) {
+                                                       new_skb->protocol =
+                                                           htons(ETH_P_8021Q);
+                                               } else {
+                                                       new_skb->protocol =
+                                                           hdlc_type_trans
+                                                           (new_skb,
+                                                            new_skb->dev);
+                                               }
+                                       }
+                               }
+                       }
+                       if ((port->char_file) || (port->port_mode)) {
+                               st_fst_tty_area *fst_tty;
+                               fst_tty = &fst_tty_area[port->minor_dev_no];
+                               fst_tty->skb = new_skb;
+                               schedule_work(&(fst_tty->fst_tty_work));
+                       } else {
+                               if (port->run)
+                                       rx_status = netif_rx(new_skb);
+                               else {
+                                       dev_kfree_skb(new_skb);
+                                       fst_dbg(DBG_ASS,
+                                               "inline2: Discarding data, port closed\n");
+                               }
+                       }
+                       fst_process_rx_status(rx_status,
+                                             port_to_dev(port)->name);
+                       if (rx_status == NET_RX_DROP)
+                               port_to_stats(port, rx_dropped)++;
+                       port_to_dev(port)->last_rx = jiffies;
+                       port->rxq.frame = NULL;
+                       port->rxq.segment_cnt = 0;
+               }
        } else {
-               card->dma_skb_rx = skb;
+               card->dma_skb_rx = port->rxq.frame;
                card->dma_port_rx = port;
                card->dma_len_rx = len;
                card->dma_rxpos = rxp;
-               fst_rx_dma(card, card->rx_dma_handle_card,
-                          BUF_OFFSET(rxBuffer[pi][rxp][0]), len);
+               fst_rx_dma(card, (char *)card->rx_dma_handle_card,
+                          (char *)BUF_OFFSET(rx_buffer[pi][0]) +
+                          rxp * port->rx_buffer_size, len);
        }
        if (rxp != port->rxpos) {
-               dbg(DBG_ASS, "About to increment rxpos by more than 1\n");
-               dbg(DBG_ASS, "rxp = %d rxpos = %d\n", rxp, port->rxpos);
+               fst_dbg(DBG_ASS, "About to increment rxpos by more than 1\n");
+               fst_dbg(DBG_ASS, "rxp = %d rxpos = %d\n", rxp, port->rxpos);
        }
-       rxp = (rxp+1) % NUM_RX_BUFFER;
-       port->rxpos = rxp;
+       if (++rxp >= port->num_rx_buffers)
+               port->rxpos = 0;
+       else
+               port->rxpos = rxp;
 }

-/*
- *      The bottom halfs to the ISR
- *
- */
+/* The bottom halfs to the ISR */

-static void
-do_bottom_half_tx(struct fst_card_info *card)
+static void do_bottom_half_dsl_tx(struct fst_card_info *card)
 {
        struct fst_port_info *port;
-       int pi;
+       int bytes_to_send = 0;
        int txq_length;
        struct sk_buff *skb;
        unsigned long flags;
-       struct net_device *dev;

-       /*
-        *  Find a free buffer for the transmit
-        *  Step through each port on this card
+       port = card->ports[0];
+       fst_dbg(DBG_TX, "do_bottom_half_dsl_tx\n");
+       /* We can't do anything if the fifo is not ready
+        * Check bytes_to_send for zero
         */
+       bytes_to_send = FST_RDW(card, dsl_control.bytes_to_send);
+       if (bytes_to_send != 0) {
+               fst_dbg(DBG_ASS,
+                       "do_bottom_half_dsl_tx: bytes_to_send not zero (%d)\n",
+                       bytes_to_send);
+               /* Couldn't do anything on this visit
+                * reschedule another event
+                */
+               fst_q_work_item(&fst_work_txq, card->card_no);
+               tasklet_schedule(&fst_tx_task);
+               return;
+       }
+       /* We might be using the dma for the transfer of data into the fifo
+        * so if a transfer is already in progress then defer this write
+        * request until later
+        */
+       if (card->dmatx_in_progress) {
+               fst_dbg(DBG_ASS,
+                       "do_bottom_half_dsl_tx: dma already in progress\n");
+               /* Couldn't do anything on this visit
+                * reschedule another event
+                */
+               fst_q_work_item(&fst_work_txq, card->card_no);
+               tasklet_schedule(&fst_tx_task);
+               return;
+       }

-       dbg(DBG_TX, "do_bottom_half_tx\n");
-       for (pi = 0, port = card->ports; pi < card->nports; pi++, port++) {
-               if (!port->run)
-                       continue;
-
-               dev = port_to_dev(port);
-               while (!(FST_RDB(card, txDescrRing[pi][port->txpos].bits) &
-                        DMA_OWN) &&
-                      !(card->dmatx_in_progress)) {
-                       /*
-                        * There doesn't seem to be a txdone event per-se
-                        * We seem to have to deduce it, by checking the DMA_OWN
-                        * bit on the next buffer we think we can use
+       /* We can go ahead with a transmission
+        * So get the next pdu off the tx queue
+        */
+       spin_lock_irqsave(&card->card_lock, flags);
+       txq_length = port->txqe - port->txqs;
+       if (txq_length < 0) {
+               /* This is the case where one has wrapped and the
+                * maths gives us a negative number
+                */
+               txq_length = txq_length + FST_TXQ_DEPTH;
+       }
+       spin_unlock_irqrestore(&card->card_lock, flags);
+       if (txq_length > 0) {
+               /* There is something to send */
+               skb = port->txq[port->txqs].frame;
+               /* Now send it and update the stats */
+               if (atm_write_into_fifo(card, skb->data, skb->len)) {
+                       port_to_stats(port, tx_packets)++;
+                       port_to_stats(port, tx_bytes) += skb->len;
+                       port_to_dev(port)->trans_start = jiffies;
+                       FST_WRW(card, dsl_control.bytes_to_send, skb->len);
+                       fst_intr_card(card);
+                       /* Update the queue pointer */
+                       spin_lock_irqsave(&card->card_lock, flags);
+                       port->txqs++;
+                       if (port->txqs == FST_TXQ_DEPTH)
+                               port->txqs = 0;
+                       if (port->txqs == port->txqe) {
+                               fst_dbg(DBG_TX,
+                                       "Card %d Port %d: Tx queue Now empty\n",
+                                       card->card_no, port->index);
+                       }
+                       spin_unlock_irqrestore(&card->card_lock, flags);
+                       /* If we have flow control on, can we now release it?
+                        */
+                       if (port->start) {
+                               if (txq_length < fst_txq_low) {
+                                       fst_dbg(DBG_ASS,
+                                               "%s: Start the network layer\n",
+                                               port->dev->name);
+                                       netif_wake_queue(port_to_dev(port));
+                                       port->start = 0;
+                               }
+                       }
+                       dev_kfree_skb(skb);
+               } else {
+                       /* Couldn't do anything on this visit
+                        * reschedule another event
                         */
+                       fst_q_work_item(&fst_work_txq, card->card_no);
+                       tasklet_schedule(&fst_tx_task);
+                       fst_dbg(DBG_TX,
+                               "No Tx: txqs is now %d txqe is now %d\n",
+                               port->txqs, port->txqe);
+                       return;
+               }
+       }
+}
+
+static void do_bottom_half_tx(struct fst_card_info *card)
+{
+       struct fst_port_info *port;
+       int pi, pc;
+       int txq_length[FST_MAX_PORTS];
+       int txq_selected = 0;
+       struct sk_buff *skb;
+       unsigned long flags;
+       int tx_length;
+
+       /* Find a free buffer for the transmit
+        * Step through each port on this card
+        */
+
+       fst_dbg(DBG_TX, "do_bottom_half_tx\n");
+       /* If DSL card we need to use the fifo */
+       if (card->type == FST_TYPE_DSL_S1) {
+               do_bottom_half_dsl_tx(card);
+               return;
+       }
+
+       /* Select a port for transmit */
+       txq_selected = card->last_tx_port;
+       fst_dbg(DBG_TX, "Start tx algorithm for %d ports\n", card->nports);
+       for (pc = 0; pc < card->nports; pc++) {
+               pi = (txq_selected + pc) % card->nports;
+               port = card->ports[pi];
+               fst_dbg(DBG_TX, "Trying port %d\n", pi);
+               if (port_to_dev(port) == NULL || !port->run) {
+                       fst_dbg(DBG_TX, "%s is not running\n",
+                               port_to_dev(port)->name);
+                       continue;
+               }
+               fst_dbg(DBG_TX, "Port is running\n");
+               while (!
+                      (FST_RDB(card, tx_descr_ring[pi][port->txpos].bits) &
+                       DMA_OWN)
+&& !(card->dmatx_in_progress)) {
                        spin_lock_irqsave(&card->card_lock, flags);
-                       if ((txq_length = port->txqe - port->txqs) < 0) {
-                               /*
-                                * This is the case where one has wrapped and the
-                                * maths gives us a negative number
+                       txq_length[pi] = port->txqe - port->txqs;
+                       if (txq_length[pi] < 0) {
+                               /* This is the case where one has wrapped and
+                                * the maths gives us a negative number
                                 */
-                               txq_length = txq_length + FST_TXQ_DEPTH;
+                               txq_length[pi] = txq_length[pi] + FST_TXQ_DEPTH;
                        }
                        spin_unlock_irqrestore(&card->card_lock, flags);
-                       if (txq_length > 0) {
-                               /*
-                                * There is something to send
+                       if (txq_length[pi] > 0) {
+                               /* There is something to send */
+                               fst_dbg(DBG_TX,
+                               "%s: There is something to send port %d len %d\n",
+                                       port_to_dev(port)->name, pi,
+                                       txq_length[pi]);
+                               skb = port->txq[port->txqs].frame;
+                               card->last_tx_port = pi + 1;
+                               if (card->last_tx_port >= card->nports)
+                                       card->last_tx_port = 0;
+
+                               /* Decrement the segment count.  It tells us
+                                * how many more bits  to the frame there are
+                                * left to do
                                 */
-                               spin_lock_irqsave(&card->card_lock, flags);
-                               skb = port->txq[port->txqs];
-                               port->txqs++;
-                               if (port->txqs == FST_TXQ_DEPTH) {
-                                       port->txqs = 0;
-                               }
-                               spin_unlock_irqrestore(&card->card_lock, flags);
-                               /*
-                                * copy the data and set the required indicators on the
-                                * card.
+                               port->txq[port->txqs].segment_cnt--;
+                               /* Is this the first, last or only segment of
+                                * the frame
                                 */
-                               FST_WRW(card, txDescrRing[pi][port->txpos].bcnt,
-                                       cnv_bcnt(skb->len));
-                               if ((skb->len < FST_MIN_DMA_LEN) ||
-                                   (card->family == FST_FAMILY_TXP)) {
-                                       /* Enqueue the packet with normal io */
-                                       memcpy_toio(card->mem +
-                                                   BUF_OFFSET(txBuffer[pi]
-                                                              [port->
-                                                               txpos][0]),
-                                                   skb->data, skb->len);
-                                       FST_WRB(card,
-                                               txDescrRing[pi][port->txpos].
-                                               bits,
-                                               DMA_OWN | TX_STP | TX_ENP);
-                                       dev->stats.tx_packets++;
-                                       dev->stats.tx_bytes += skb->len;
-                                       dev->trans_start = jiffies;
+                               if (port->txq[port->txqs].segment_cnt == 0) {
+                                       if (port->txq[port->txqs].current_seg ==
+                                           0) {
+                                               fst_dbg(DBG_TX,
+                                                       "Tx first and last\n");
+                                               port->txq[port->txqs].flags =
+                                                   DMA_OWN | TX_STP | TX_ENP;
+                                               tx_length = skb->len;
+                                       } else {
+                                               fst_dbg(DBG_TX, "Tx last\n");
+                                               port->txq[port->txqs].flags =
+                                                   DMA_OWN | TX_ENP;
+                                               tx_length = skb->len;
+                                       }
                                } else {
-                                       /* Or do it through dma */
-                                       memcpy(card->tx_dma_handle_host,
-                                              skb->data, skb->len);
-                                       card->dma_port_tx = port;
-                                       card->dma_len_tx = skb->len;
-                                       card->dma_txpos = port->txpos;
-                                       fst_tx_dma(card,
-                                                  (char *) card->
-                                                  tx_dma_handle_card,
-                                                  (char *)
-                                                  BUF_OFFSET(txBuffer[pi]
-                                                             [port->txpos][0]),
-                                                  skb->len);
+                                       if (port->txq[port->txqs].current_seg ==
+                                           0) {
+                                               fst_dbg(DBG_TX, "Tx first\n");
+                                               port->txq[port->txqs].flags =
+                                                   DMA_OWN | TX_STP;
+                                               tx_length =
+                                                   port->tx_buffer_size;
+                                       } else {
+                                               fst_dbg(DBG_TX, "Tx Middle\n");
+                                               port->txq[port->txqs].flags =
+                                                   DMA_OWN;
+                                               tx_length =
+                                                   port->tx_buffer_size;
+                                       }
                                }
-                               if (++port->txpos >= NUM_TX_BUFFER)
-                                       port->txpos = 0;
-                               /*
-                                * If we have flow control on, can we now release it?
+                               port->txq[port->txqs].current_seg++;
+                               fst_dbg(DBG_TX, "Setting flags to %x\n",
+                                       port->txq[port->txqs].flags);
+                               fst_dbg(DBG_TX, "Setting length to %d\n",
+                                       tx_length);
+
+                               if (port->mode == FST_MODE_ASYNC) {
+                                       char *fifo_ptr;
+
+                                       fifo_ptr = port->card->mem +
+                                           ASY_OFFSET(tx_fifo[port->index]);
+                                       fst_dbg(DBG_TX, "%s: Sending %d bytes of async data %p\n",
+                                            port_to_dev(port)->name, tx_length,
+                                            (char *)fifo_ptr);
+                                       write_into_fifo(fifo_ptr, FIFO_ASY_TX,
+                                                       skb->data, tx_length);
+                               } else {
+                                       /* copy the data and set the required
+                                        * indicators on the card.
+                                        */
+                                       FST_WRW(card,
+                                               tx_descr_ring[pi][port->
+                                                               txpos].bcnt,
+                                               cnv_bcnt(tx_length));
+                                       if ((tx_length < fst_min_dma_len)
+                                       || (card->family == FST_FAMILY_TXP)) {
+                                               int flags =
+                                                   port->txq[port->txqs].flags;
+                                               /* Enqueue the packet with
+                                                * normal io
+                                                */
+                                               memcpy_toio(card->mem +
+                                               BUF_OFFSET(tx_buffer[pi][0]) +
+                                                          port->txpos *
+                                                          port->tx_buffer_size,
+                                                          skb->data,
+                                                          tx_length);
+                                               if (port->mode ==
+                                                   FST_MODE_TRANSPARENT) {
+                                                       flags = flags & 0xfe;
+                                               }
+                                               FST_WRB(card,
+                                                       tx_descr_ring[pi]
+                                                       [port->txpos].bits,
+                                                       flags);
+                                               if (port->
+                                                   txq[port->
+                                                       txqs].flags & TX_ENP)
+                                                       port_to_stats(port,
+                                                                     tx_packets)++;
+                                               port_to_stats(port, tx_bytes) +=
+                                                   tx_length;
+                                               port_to_dev(port)->trans_start =
+                                                   jiffies;
+                                               fst_check_send(port);
+                                       } else {
+                                               /* Or do it through dma */
+                                               memcpy(card->tx_dma_handle_host,
+                                                      skb->data, tx_length);
+                                               card->dma_port_tx = port;
+                                               card->dma_len_tx = tx_length;
+                                               card->dma_txpos = port->txpos;
+                                               card->dma_tx_flags =
+                                                   port->txq[port->txqs].flags;
+                                               fst_tx_dma(card,
+                                                          (char *)
+                                                          card->tx_dma_handle_card,
+                                                          (char *)
+                                                          BUF_OFFSET(tx_buffer
+                                                                     [pi][0]) +
+                                                          port->txpos *
+                                                          port->tx_buffer_size,
+                                                          tx_length);
+                                       }
+                               }
+                               /* If this was a first or middle segment we
+                                * have to adjust skb
+                                */
+                               if ((port->txq[port->txqs].flags == DMA_OWN) ||
+                                   (port->txq[port->txqs].flags ==
+                                    (DMA_OWN | TX_STP))) {
+                                       skb_pull(port->txq[port->txqs].frame,
+                                                tx_length);
+                               }
+
+                               /* If this was the last segment we have some
+                                *  housekeeping to do
                                 */
-                               if (port->start) {
-                                       if (txq_length < fst_txq_low) {
-                                               netif_wake_queue(port_to_dev
-                                                                (port));
+                               wake_up_interruptible(&port->writeq);
+                               if (port->txq[port->txqs].flags & TX_ENP) {
+                                       spin_lock_irqsave(&card->card_lock,
+                                                         flags);
+                                       port->txq[port->txqs].frame = NULL;
+                                       port->txqs++;
+                                       if (port->txqs == FST_TXQ_DEPTH)
+                                               port->txqs = 0;
+                                       if (port->txqs == port->txqe) {
+                                               fst_dbg(DBG_TX,
+                                                       "Card %d Port %d: Tx queue Now empty\n",
+                                                       card->card_no,
+                                                       port->index);
+                                               wake_up_interruptible
+                                                   (&port->pollq);
+                                       }
+                                       spin_unlock_irqrestore(&card->card_lock,
+                                                              flags);
+                                       /* If we have flow control on, can we
+                                        * now release it?
+                                        */
+                                       if ((txq_length[pi] < fst_txq_low)
+                                           && (port->start)) {
+                                               fst_dbg(DBG_ASS,
+                                                       "%s: Start the network layer\n",
+                                                       port_to_dev
+                                                       (port)->name);
+                                               if (!port->char_file) {
+                                                       netif_wake_queue
+                                                           (port_to_dev(port));
+                                                       wake_up_interruptible
+                                                           (&port->pollq);
+                                               } else {
+                                                       st_fst_tty_area
+                                                           *fst_tty;
+                                                       fst_tty =
+                                                           &fst_tty_area
+                                                           [port->minor_dev_no];
+                                                       if (fst_tty->tty) {
+                                                               fst_dbg(DBG_TTY,
+                                                                       "%s: Waking up tty transmits\n",
+                                                                       fst_tty->name);
+                                                               tty_wakeup
+                                                                   (fst_tty->tty);
+                                                       }
+                                               }
                                                port->start = 0;
                                        }
+                                       dev_kfree_skb(skb);
                                }
-                               dev_kfree_skb(skb);
                        } else {
-                               /*
-                                * Nothing to send so break out of the while loop
+                               /* Nothing to send so break out of the while
+                                * loop
                                 */
+                               fst_dbg(DBG_TX, "%s: Nothing to send\n",
+                                       port_to_dev(port)->name);
                                break;
                        }
+                       if (++port->txpos >= port->num_tx_buffers)
+                               port->txpos = 0;
                }
        }
+       if ((!card->dmatx_in_progress) && (!card->dmarx_in_progress))
+               fst_enable_186_intr(card);
 }

-static void
-do_bottom_half_rx(struct fst_card_info *card)
+static void do_bottom_half_rx(struct fst_card_info *card)
 {
        struct fst_port_info *port;
        int pi;
        int rx_count = 0;

        /* Check for rx completions on all ports on this card */
-       dbg(DBG_RX, "do_bottom_half_rx\n");
-       for (pi = 0, port = card->ports; pi < card->nports; pi++, port++) {
-               if (!port->run)
+       fst_dbg(DBG_RX, "do_bottom_half_rx\n");
+       for (pi = 0; pi < card->nports; pi++) {
+               port = card->ports[pi];
+               if (port_to_dev(port) == NULL || !port->run)
                        continue;
-
-               while (!(FST_RDB(card, rxDescrRing[pi][port->rxpos].bits)
+               if (card->type == FST_TYPE_DSL_S1) {
+                       /*
+                        * Only process cells if we are in data state
+                        */
+                       if (port->activation_status >= 64)
+                               fst_intr_rx_fifo(card, port);
+               }
+               while (!(FST_RDB(card, rx_descr_ring[pi][port->rxpos].bits)
                         & DMA_OWN) && !(card->dmarx_in_progress)) {
                        if (rx_count > fst_max_reads) {
                                /*
@@ -1463,16 +5646,16 @@ do_bottom_half_rx(struct fst_card_info *
                        rx_count++;
                }
        }
+       if ((!card->dmarx_in_progress) && (!card->dmatx_in_progress))
+               fst_enable_186_intr(card);
 }

-/*
- *      The interrupt service routine
+/*      The interrupt service routine
  *      Dev_id is our fst_card_info pointer
  */
-static irqreturn_t
-fst_intr(int dummy, void *dev_id)
+irqreturn_t fst_intr(int irq, void *dev_id)
 {
-       struct fst_card_info *card = dev_id;
+       struct fst_card_info *card;
        struct fst_port_info *port;
        int rdidx;              /* Event buffer indices */
        int wridx;
@@ -1480,107 +5663,159 @@ fst_intr(int dummy, void *dev_id)
        unsigned int dma_intcsr = 0;
        unsigned int do_card_interrupt;
        unsigned int int_retry_count;
+       int i;

-       /*
-        * Check to see if the interrupt was for this card
+       card = dev_id;
+       if (card == NULL) {
+               fst_dbg(DBG_INTR, "intr: spurious %d\n", irq);
+               fst_int_counter[card->card_no].int_no_work++;
+               return IRQ_NONE;
+       }
+
+       /* Check to see if the interrupt was for this card
         * return if not
         * Note that the call to clear the interrupt is important
         */
-       dbg(DBG_INTR, "intr: %d %p\n", card->irq, card);
+       fst_dbg(DBG_INTR, "intr: %d %p %d\n", irq, card, card->card_no);
        if (card->state != FST_RUNNING) {
-               pr_err("Interrupt received for card %d in a non running state (%d)\n",
-                      card->card_no, card->state);
-
-               /*
-                * It is possible to really be running, i.e. we have re-loaded
-                * a running card
-                * Clear and reprime the interrupt source
+               fst_dbg(DBG_INTR,
+               "Interrupt received for card %d in a non running state (%d)\n",
+                       card->card_no, card->state);
+
+               /* It is possible to really be running, i.e. we have
+                * re-loaded a running card
+                * Clear and reprime the interrupt source
                 */
                fst_clear_intr(card);
+               fst_int_counter[card->card_no].int_no_work++;
                return IRQ_HANDLED;
        }

        /* Clear and reprime the interrupt source */
        fst_clear_intr(card);

-       /*
-        * Is the interrupt for this card (handshake == 1)
+       /* Is the interrupt for this card (handshake == 1)
         */
        do_card_interrupt = 0;
        if (FST_RDB(card, interruptHandshake) == 1) {
+               fst_disable_186_intr(card);
                do_card_interrupt += FST_CARD_INT;
                /* Set the software acknowledge */
                FST_WRB(card, interruptHandshake, 0xEE);
+               fst_int_counter[card->card_no].int_186++;
        }
+
        if (card->family == FST_FAMILY_TXU) {
                /*
                 * Is it a DMA Interrupt
                 */
                dma_intcsr = inl(card->pci_conf + INTCSR_9054);
                if (dma_intcsr & 0x00200000) {
-                       /*
-                        * DMA Channel 0 (Rx transfer complete)
+                       /* DMA Channel 0 (Rx transfer complete)
                         */
-                       dbg(DBG_RX, "DMA Rx xfer complete\n");
+                       fst_int_counter[card->card_no].int_rxdma++;
+                       fst_dbg(DBG_RX, "DMA Rx xfer complete\n");
                        outb(0x8, card->pci_conf + DMACSR0);
-                       fst_rx_dma_complete(card, card->dma_port_rx,
-                                           card->dma_len_rx, card->dma_skb_rx,
-                                           card->dma_rxpos);
+                       /* If non DSL card, complete interrupt processing
+                        */
+                       if ((card->type != FST_TYPE_DSL_S1) &&
+                           (card->dma_port_rx->mode != FST_MODE_ASYNC)) {
+                               fst_rx_dma_complete(card, card->dma_port_rx,
+                                                   card->dma_len_rx,
+                                                   card->dma_skb_rx,
+                                                   card->dma_rxpos);
+                       }
                        card->dmarx_in_progress = 0;
                        do_card_interrupt += FST_RX_DMA_INT;
                }
                if (dma_intcsr & 0x00400000) {
-                       /*
-                        * DMA Channel 1 (Tx transfer complete)
+                       /* DMA Channel 1 (Tx transfer complete)
                         */
-                       dbg(DBG_TX, "DMA Tx xfer complete\n");
+                       fst_int_counter[card->card_no].int_txdma++;
+                       fst_dbg(DBG_TX, "DMA Tx xfer complete\n");
                        outb(0x8, card->pci_conf + DMACSR1);
-                       fst_tx_dma_complete(card, card->dma_port_tx,
-                                           card->dma_len_tx, card->dma_txpos);
+                       /* If non DSL card, complete interruot processing
+                        */
+                       if ((card->type != FST_TYPE_DSL_S1) &&
+                           (card->dma_port_tx->mode != FST_MODE_ASYNC)) {
+                               fst_tx_dma_complete(card, card->dma_port_tx,
+                                                   card->dma_len_tx,
+                                                   card->dma_txpos,
+                                                   card->dma_tx_flags);
+                       }
                        card->dmatx_in_progress = 0;
                        do_card_interrupt += FST_TX_DMA_INT;
                }
        }

-       /*
-        * Have we been missing Interrupts
+       /* Have we been missing Interrupts
         */
        int_retry_count = FST_RDL(card, interruptRetryCount);
        if (int_retry_count) {
-               dbg(DBG_ASS, "Card %d int_retry_count is  %d\n",
-                   card->card_no, int_retry_count);
+               fst_dbg(DBG_ASS, "Card %d int_retry_count is  %d\n",
+                       card->card_no, int_retry_count);
                FST_WRL(card, interruptRetryCount, 0);
        }

        if (!do_card_interrupt) {
+               fst_int_counter[card->card_no].int_no_work++;
                return IRQ_HANDLED;
        }
-
-       /* Scehdule the bottom half of the ISR */
-       fst_q_work_item(&fst_work_intq, card->card_no);
-       tasklet_schedule(&fst_int_task);
-
+       if ((!card->dmatx_in_progress) ||
+           (!card->dmarx_in_progress) ||
+           (do_card_interrupt & FST_CARD_INT)) {
+               /* Scehdule the bottom half of the ISR */
+               fst_q_work_item(&fst_work_intq, card->card_no);
+               tasklet_schedule(&fst_int_task);
+       }
        /* Drain the event queue */
-       rdidx = FST_RDB(card, interruptEvent.rdindex) & 0x1f;
-       wridx = FST_RDB(card, interruptEvent.wrindex) & 0x1f;
+       rdidx = FST_RDB(card, interrupt_event.rdindex) & 0x1f;
+       wridx = FST_RDB(card, interrupt_event.wrindex) & 0x1f;
        while (rdidx != wridx) {
-               event = FST_RDB(card, interruptEvent.evntbuff[rdidx]);
-               port = &card->ports[event & 0x03];
+               event = FST_RDB(card, interrupt_event.evntbuff[rdidx]);
+               port = card->ports[event & 0x03];

-               dbg(DBG_INTR, "Processing Interrupt event: %x\n", event);
+               fst_dbg(DBG_INTR, "Processing Interrupt event: %x\n", event);

                switch (event) {
                case TE1_ALMA:
-                       dbg(DBG_INTR, "TE1 Alarm intr\n");
-                       if (port->run)
+                       fst_dbg(DBG_INTR, "%s: TE1 Alarm intr\n",
+                               port_to_dev(port)->name);
+                       if (port->run && port_to_dev(port) != NULL)
                                fst_intr_te1_alarm(card, port);
                        break;

+               case DSL_ACST:
+                       break;
+
+               case DSL_LINK:
+                       fst_dbg(DBG_INTR,
+                               "%s: DSL Activation status change %d\n",
+                               port_to_dev(port)->name,
+                               FST_RDB(card, dsl_status.activation_status));
+                       if (port->run && port_to_dev(port) != NULL)
+                               fst_dsl_acstchg(card, port);
+                       break;
+
+               case TXA_CMPL:
+               case TXB_CMPL:
+               case TXC_CMPL:
+               case TXD_CMPL:
+                       /* TX complete for dsl fifo management */
+                       break;
+
+               case RXA_CMPL:
+               case RXB_CMPL:
+               case RXC_CMPL:
+               case RXD_CMPL:
+                       /* RX complete for dsl fifo management */
+                       break;
+
                case CTLA_CHG:
                case CTLB_CHG:
                case CTLC_CHG:
                case CTLD_CHG:
-                       if (port->run)
+                       if ((port->run) && (port_to_dev(port) != NULL))
                                fst_intr_ctlchg(card, port);
                        break;

@@ -1588,7 +5823,8 @@ fst_intr(int dummy, void *dev_id)
                case ABTB_SENT:
                case ABTC_SENT:
                case ABTD_SENT:
-                       dbg(DBG_TX, "Abort complete port %d\n", port->index);
+                       fst_dbg(DBG_TX, "Abort complete port %d\n",
+                               port->index);
                        break;

                case TXA_UNDF:
@@ -1598,24 +5834,44 @@ fst_intr(int dummy, void *dev_id)
                        /* Difficult to see how we'd get this given that we
                         * always load up the entire packet for DMA.
                         */
-                       dbg(DBG_TX, "Tx underflow port %d\n", port->index);
-                       port_to_dev(port)->stats.tx_errors++;
-                       port_to_dev(port)->stats.tx_fifo_errors++;
-                       dbg(DBG_ASS, "Tx underflow on card %d port %d\n",
-                           card->card_no, port->index);
+                       port_to_stats(port, tx_errors)++;
+                       port_to_stats(port, tx_window_errors)++;
+                       printk_ratelimited("Tx underflow on card %d port %d\n",
+                                          card->card_no, port->index);
+                       break;
+
+               case TXA_TBUA:
+               case TXB_TBUA:
+               case TXC_TBUA:
+               case TXD_TBUA:
+                       port_to_stats(port, tx_errors)++;
+                       port_to_stats(port, tx_window_errors)++;
+                       printk_ratelimited("Tx buffer unavailable on card %d port %d\n",
+                                          card->card_no, port->index);
+                       break;
+
+               case RXA_RBUA:
+               case RXB_RBUA:
+               case RXC_RBUA:
+               case RXD_RBUA:
+                       port_to_stats(port, rx_errors)++;
+                       port_to_stats(port, rx_over_errors)++;
+                       printk_ratelimited("Rx buffer unavailable on card %d port %d\n",
+                                          card->card_no, port->index);
                        break;

                case INIT_CPLT:
-                       dbg(DBG_INIT, "Card init OK intr\n");
+                       fst_dbg(DBG_INIT, "Card init OK intr\n");
                        break;

                case INIT_FAIL:
-                       dbg(DBG_INIT, "Card init FAILED intr\n");
+                       fst_dbg(DBG_INIT, "Card init FAILED intr\n");
                        card->state = FST_IFAILED;
                        break;

                default:
-                       pr_err("intr: unknown card event %d. ignored\n", event);
+                       pr_err("intr: card %d: Unknown event = 0x%x\n",
+                                  card->card_no, event);
                        break;
                }

@@ -1623,52 +5879,214 @@ fst_intr(int dummy, void *dev_id)
                if (++rdidx >= MAX_CIRBUFF)
                        rdidx = 0;
        }
-       FST_WRB(card, interruptEvent.rdindex, rdidx);
-        return IRQ_HANDLED;
+       FST_WRB(card, interrupt_event.rdindex, rdidx);
+       /*
+        * Fifo processing
+        */
+       if (!card->fifo_complete)
+               check_fifo_resp(card);
+       check_cmdfifo_done(card);
+       check_rx_fifos(card);
+       check_tx_fifos(card);
+       check_rx_event_fifos(card);
+       for (i = 0; i < card->nports; i++) {
+               if (card->ports[i]->mode == FST_MODE_ASYNC)
+                       check_tx_fifo_threshold(card->ports[i]);
+       }
+       return IRQ_HANDLED;
 }

-/*      Check that the shared memory configuration is one that we can handle
- *      and that some basic parameters are correct
- */
-static void
-check_started_ok(struct fst_card_info *card)
+static int check_combination(int num, int size)
 {
-       int i;
-
-       /* Check structure version and end marker */
-       if (FST_RDW(card, smcVersion) != SMC_VERSION) {
-               pr_err("Bad shared memory version %d expected %d\n",
-                      FST_RDW(card, smcVersion), SMC_VERSION);
-               card->state = FST_BADVERSION;
-               return;
-       }
-       if (FST_RDL(card, endOfSmcSignature) != END_SIG) {
-               pr_err("Missing shared memory signature\n");
-               card->state = FST_BADVERSION;
-               return;
+       /* Check that the number and size do not exceed the following table
+        *
+        *   num of buffs            max size
+        *     1                       32K
+        *     2                       32K
+        *     4                       16K
+        *     8                        8K
+        *    16                        4K
+        *    32                        2K
+        *    64                        1K
+        *   128                      0.5K
+        */
+       int err = 0;
+       switch (num) {
+       case 1:
+       case 2:
+               {
+                       if (size > 32 * 1024)
+                               err++;
+                       break;
+               }
+       case 4:
+               {
+                       if (size > 16 * 1024)
+                               err++;
+                       break;
+               }
+       case 8:
+               {
+                       if (size > 8 * 1024)
+                               err++;
+                       break;
+               }
+       case 16:
+               {
+                       if (size > 4 * 1024)
+                               err++;
+                       break;
+               }
+       case 32:
+               {
+                       if (size > 2 * 1024)
+                               err++;
+                       break;
+               }
+       case 64:
+               {
+                       if (size > 1 * 1024)
+                               err++;
+                       break;
+               }
+       case 128:
+               {
+                       if (size > 1024 / 2)
+                               err++;
+                       break;
+               }
+       default:
+               {
+                       pr_err("Number of buffers must be 1,2,4,8,16,32,64, ");
+                       pr_err("or 128 : %d\n", num);
+                       err++;
+               }
        }
-       /* Firmware status flag, 0x00 = initialising, 0x01 = OK, 0xFF = fail */
-       if ((i = FST_RDB(card, taskStatus)) == 0x01) {
-               card->state = FST_RUNNING;
-       } else if (i == 0xFF) {
-               pr_err("Firmware initialisation failed. Card halted\n");
-               card->state = FST_HALTED;
-               return;
-       } else if (i != 0x00) {
-               pr_err("Unknown firmware status 0x%x\n", i);
-               card->state = FST_HALTED;
-               return;
+       if (err)
+               return 1;
+       return 0;
+}
+
+static int check_te1_combination(int num, int size)
+{
+       /* Check that the number and size do not exceed the following table
+        *
+        *   num of buffs            max size
+        *     1                       32K
+        *     2                       32K
+        *     4                       32K
+        *     8                       32K
+        *    16                       16K
+        *    32                        8K
+        *    64                        4K
+        *   128                        2K
+        */
+       int err = 0;
+       switch (num) {
+       case 1:
+       case 2:
+       case 4:
+       case 8:
+               {
+                       if (size > 32 * 1024)
+                               err++;
+                       break;
+               }
+
+       case 16:
+               {
+                       if (size > 16 * 1024)
+                               err++;
+                       break;
+               }
+       case 32:
+               {
+                       if (size > 8 * 1024)
+                               err++;
+                       break;
+               }
+       case 64:
+               {
+                       if (size > 4 * 1024)
+                               err++;
+                       break;
+               }
+       case 128:
+               {
+                       if (size > 2 * 1024)
+                               err++;
+                       break;
+               }
+       default:
+               {
+                       pr_err("Number of buffers must be 1,2,4,8,16,32,64, ");
+                       pr_err("or 128 : %d\n", num);
+                       err++;
+               }
        }
+       if (err)
+               return 1;
+       return 0;
+}

-       /* Finally check the number of ports reported by firmware against the
-        * number we assumed at card detection. Should never happen with
-        * existing firmware etc so we just report it for the moment.
+static int
+validate_buffer_config(struct fstioc_info *info, struct fst_card_info *card)
+{
+       /* We need some checks on buffer configurations because the
+        * card itself doesn't do any
         */
-       if (FST_RDL(card, numberOfPorts) != card->nports) {
-               pr_warn("Port count mismatch on card %d.  Firmware thinks %d we say %d\n",
-                       card->card_no,
-                       FST_RDL(card, numberOfPorts), card->nports);
+       if ((info->num_tx_buffers == 0) || (info->num_rx_buffers == 0)) {
+               pr_err("Num Tx Buffers or Nun Rx Buffers is zero\n");
+               return 1;
+       }
+       if ((info->num_tx_buffers > 128) || (info->num_rx_buffers > 128)) {
+               pr_err("Num Tx Buffers or Nun Rx Buffers > 128\n");
+               return 1;
+       }
+       if ((info->tx_buffer_size == 0) || (info->rx_buffer_size == 0)) {
+               pr_err("Tx Buffer Size or Rx Buffer Size is zero\n");
+               return 1;
+       }
+       if ((card->type == FST_TYPE_TE1) || (card->type == FST_TYPE_TE1e)) {
+               if ((info->tx_buffer_size > 4 * 32 * 1024)
+                   || (info->rx_buffer_size > 4 * 32 * 1024)) {
+                       pr_err
+                           ("Tx Buffer Size or Rx Buffer Size > 32*1024\n");
+                       return 1;
+               }
+               if (check_te1_combination
+                   (info->num_tx_buffers, info->tx_buffer_size)) {
+                       pr_err
+                           ("Invalid num/size combination on Tx Buffers\n");
+                       return 1;
+               }
+               if (check_te1_combination
+                   (info->num_rx_buffers, info->rx_buffer_size)) {
+                       pr_err
+                           ("Invalid num/size combination on Rx Buffers\n");
+                       return 1;
+               }
+       } else {
+               if ((info->tx_buffer_size > 32 * 1024)
+                   || (info->rx_buffer_size > 32 * 1024)) {
+                       pr_err
+                           ("Tx Buffer Size or Rx Buffer Size > 32*1024\n");
+                       return 1;
+               }
+               if (check_combination(info->num_tx_buffers,
+                                     info->tx_buffer_size)) {
+                       pr_err
+                           ("Invalid num/size combination on Tx Buffers\n");
+                       return 1;
+               }
+               if (check_combination(info->num_rx_buffers,
+                                     info->rx_buffer_size)) {
+                       pr_err
+                           ("Invalid num/size combination on Rx Buffers\n");
+                       return 1;
+               }
        }
+       return 0;
 }

 static int
@@ -1676,34 +6094,183 @@ set_conf_from_info(struct fst_card_info
                   struct fstioc_info *info)
 {
        int err;
-       unsigned char my_framing;
+       int my_framing;

-       /* Set things according to the user set valid flags
-        * Several of the old options have been invalidated/replaced by the
-        * generic hdlc package.
-        */
+       /* Set things according to the user set valid flags */
        err = 0;
        if (info->valid & FSTVAL_PROTO) {
-               if (info->proto == FST_RAW)
-                       port->mode = FST_RAW;
-               else
-                       port->mode = FST_GEN_HDLC;
+               if (info->proto == FST_RAW) {
+                       struct ifreq ifr;
+                       int cmd;
+
+                       cmd = SIOCWANDEV;
+                       ifr.ifr_settings.type = IF_PROTO_PPP;
+                       hdlc_ioctl(port_to_dev(port), &ifr, cmd);
+                       port->proto = FST_RAW;
+               } else {
+                       port->proto = FST_GEN_HDLC;
+               }
        }
+       if (info->transparent_mode == FST_MODE_TRANSPARENT)
+               FST_WRB(card, port_config[port->index].transparent_mode, 1);
+       else
+               FST_WRB(card, port_config[port->index].transparent_mode, 0);
+       port->mode = info->transparent_mode;
+       if (port->mode == FST_MODE_ASYNC) {
+               if (FST_RDB(card, async_ability[port->index])) {
+                       fst_dbg(DBG_ASY,
+                       "%s: Setting the async_mode field in shared memory\n",
+                               port->dev->name);
+                       FST_A_WRB(port->card, async_mode[port->index], 1);
+               } else {
+                 fst_dbg(DBG_ASS,
+                 "%s: Request to set async mode without async capability\n",
+                            port_to_dev(port)->name);
+                       return -ENOTTY /*EMEDIUMTYPE*/;
+               }
+       } else {
+               fst_dbg(DBG_ASY,
+                       "%s: Clearing the async_mode field in shared memory\n",
+                       port->dev->name);
+               FST_A_WRB(port->card, async_mode[port->index], 0);
+       }
+       if (info->valid & FSTVAL_CABLE) {
+               if (info->line_interface > RS485_FDX) {
+                       pr_info("Can't set line interface to %d\n",
+                              info->line_interface);
+                       info->line_interface = 0;
+               }
+               port->hwif = info->line_interface;
+               if (port->hwif == UX35C)
+                       info->line_interface = X21;
+
+               if (port->hwif == RS530_449) {
+                       if ((card->type == FST_TYPE_T1U) ||
+                           (card->type == FST_TYPE_T2U) ||
+                           (card->type == FST_TYPE_T2UE) ||
+                           (card->type == FST_TYPE_T4U) ||
+                           (card->type == FST_TYPE_T4UE))
+                               info->line_interface = X21;
+               }

-       if (info->valid & FSTVAL_CABLE)
-               err = -EINVAL;
-
-       if (info->valid & FSTVAL_SPEED)
-               err = -EINVAL;
-
+               FST_WRB(card, port_config[port->index].line_interface,
+                       map_interface[info->line_interface]);
+       }
+       port->ignore_carrier = info->ignore_carrier;
+       FST_WRB(card, port_config[port->index].termination, info->termination);
+       if (info->valid & FSTVAL_CARD) {
+               if (port->fstioc_info_ver > FST_VERSION_OLD) {
+                       fst_dbg(DBG_IOCTL, "Setting low latency to %d\n",
+                               info->low_latency);
+                       if (info->low_latency & LOW_LATENCY_RX)
+                               FST_WRB(card,
+                                       port_config[port->index].immediate_ints,
+                                       info->low_latency);
+                       port->low_latency = info->low_latency;
+               }
+       }
+       if ((info->valid & FSTVAL_SPEED || (info->valid & FSTVAL_T4E))) {
+               if (((card->type == FST_TYPE_T4E) ||
+                    (card->type == FST_TYPE_T4Ep) ||
+                    (card->type == FST_TYPE_T2U_PMC) ||
+                    (card->type == FST_TYPE_T2Ee) ||
+                    (card->type == FST_TYPE_T4Ee))
+                   && (info->extended_clocking)) {
+                       /* T4E now has special clocking arrangements
+                        */
+                       FST_WRB(card,
+                               port_config[port->index].internal_clock, 0);
+                       FST_WRB(card,
+                               port_config[port->index].extended_clocking,
+                               1);
+                       if (info->extended_clocking & 1) {
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       internal_tx_clock, 1);
+                               fst_dbg(DBG_IOCTL,
+                                       "Port %d set internal_tx_clock\n",
+                                       port->index);
+                       } else
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       internal_tx_clock, 0);
+                       if (info->extended_clocking & 2) {
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       internal_rx_clock, 1);
+                               fst_dbg(DBG_IOCTL,
+                                       "Port %d set internal_rx_clock\n",
+                                       port->index);
+                       } else
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       internal_rx_clock, 0);
+                       if (info->extended_clocking & 4) {
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       terminal_tx_clock, 1);
+                               fst_dbg(DBG_IOCTL,
+                                       "Port %d set terminal_tx_clock\n",
+                                       port->index);
+                       } else
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       terminal_tx_clock, 0);
+                       if (info->extended_clocking & 8) {
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       terminal_rx_clock, 1);
+                               fst_dbg(DBG_IOCTL,
+                                       "Port %d set terminal_rx_clock\n",
+                                       port->index);
+                       } else
+                               FST_WRB(card,
+                                       port_config[port->index].
+                                       terminal_rx_clock, 0);
+                       fst_dbg(DBG_IOCTL, "T4E Clocking is %x\n",
+                               info->extended_clocking);
+               } else {
+                       FST_WRB(card, port_config[port->index].internal_clock,
+                               info->internal_clock);
+                       FST_WRB(card,
+                               port_config[port->index].extended_clocking, 0);
+               }
+               if (port->fstioc_info_ver > FST_VERSION_OLD)
+                       FST_WRB(card,
+                               port_config[port->index].enable_nrzi_clocking,
+                               info->enable_nrzi_clocking);
+               FST_WRL(card, port_config[port->index].line_speed,
+                       info->line_speed);
+               FST_WRB(card, port_config[port->index].transmit_msb_first,
+                       info->transmit_msb_first);
+               FST_WRB(card, port_config[port->index].receive_msb_first,
+                       info->receive_msb_first);
+               FST_WRB(card, port_config[port->index].tx_rx_start,
+                       info->tx_rx_start);
+       }
        if (info->valid & FSTVAL_PHASE)
-               FST_WRB(card, portConfig[port->index].invertClock,
-                       info->invertClock);
+               FST_WRB(card, port_config[port->index].invert_clock,
+                       info->invert_clock);
        if (info->valid & FSTVAL_MODE)
-               FST_WRW(card, cardMode, info->cardMode);
-       if (info->valid & FSTVAL_TE1) {
-               FST_WRL(card, suConfig.dataRate, info->lineSpeed);
-               FST_WRB(card, suConfig.clocking, info->clockSource);
+               FST_WRW(card, card_mode, info->card_mode);
+       if (info->valid & FSTVAL_BUFFERS) {
+               if (validate_buffer_config(info, card))
+                       return -ENOSPC;
+               port->num_tx_buffers = info->num_tx_buffers;
+               port->num_rx_buffers = info->num_rx_buffers;
+               port->tx_buffer_size = info->tx_buffer_size;
+               port->rx_buffer_size = info->rx_buffer_size;
+               fst_dbg(DBG_IOCTL, "txb %d rxb %d  txs %d rxs %d\n",
+                       info->num_tx_buffers, info->num_rx_buffers,
+                       info->tx_buffer_size, info->rx_buffer_size);
+       }
+       if ((info->valid & FSTVAL_TE1) ||
+           (card->type == FST_TYPE_T2U_PMC) ||
+           (card->type == FST_TYPE_T2Ee) || (card->type == FST_TYPE_T4Ee)) {
+               unsigned char encoding;
+
+               FST_WRL(card, su_config.data_rate, info->line_speed);
+               FST_WRB(card, su_config.clocking, info->clock_source);
                my_framing = FRAMING_E1;
                if (info->framing == E1)
                        my_framing = FRAMING_E1;
@@ -1711,150 +6278,743 @@ set_conf_from_info(struct fst_card_info
                        my_framing = FRAMING_T1;
                if (info->framing == J1)
                        my_framing = FRAMING_J1;
-               FST_WRB(card, suConfig.framing, my_framing);
-               FST_WRB(card, suConfig.structure, info->structure);
-               FST_WRB(card, suConfig.interface, info->interface);
-               FST_WRB(card, suConfig.coding, info->coding);
-               FST_WRB(card, suConfig.lineBuildOut, info->lineBuildOut);
-               FST_WRB(card, suConfig.equalizer, info->equalizer);
-               FST_WRB(card, suConfig.transparentMode, info->transparentMode);
-               FST_WRB(card, suConfig.loopMode, info->loopMode);
-               FST_WRB(card, suConfig.range, info->range);
-               FST_WRB(card, suConfig.txBufferMode, info->txBufferMode);
-               FST_WRB(card, suConfig.rxBufferMode, info->rxBufferMode);
-               FST_WRB(card, suConfig.startingSlot, info->startingSlot);
-               FST_WRB(card, suConfig.losThreshold, info->losThreshold);
-               if (info->idleCode)
-                       FST_WRB(card, suConfig.enableIdleCode, 1);
+               FST_WRB(card, su_config.framing, my_framing);
+               FST_WRB(card, su_config.structure, info->structure);
+               FST_WRB(card, su_config.interface, info->interface);
+               FST_WRB(card, su_config.coding, info->coding);
+
+               switch (info->coding) {
+               case CODING_NRZI:
+                       encoding = FSCMN_ENCODING_NRZI;
+                       break;
+               case CODING_FM0:
+                       encoding = FSCMN_ENCODING_FM0;
+                       break;
+               case CODING_FM1:
+                       encoding = FSCMN_ENCODING_FM1;
+                       break;
+               case CODING_MANCHESTER:
+                       encoding = FSCMN_ENCODING_MANCHESTER;
+                       break;
+               case CODING_DIFF_MANCHESTER:
+                       encoding = FSCMN_ENCODING_DIFF_MANCHESTER;
+                       break;
+               default:
+                       encoding = FSCMN_ENCODING_NRZ;
+               }
+               FST_WRB(card, port_config[port->index].encoding, encoding);
+               FST_WRB(card, su_config.line_build_out, info->line_build_out);
+               FST_WRB(card, su_config.equalizer, info->equalizer);
+               FST_WRB(card, su_config.transparent_mode,
+                       info->transparent_mode);
+               /* Note that we have hi-jacked this field to mean
+                * transparent, hdlc or async
+                */
+               port->mode = info->transparent_mode;
+               FST_WRB(card, su_config.loop_mode, info->loop_mode);
+               FST_WRB(card, su_config.range, info->range);
+               FST_WRB(card, su_config.tx_buffer_mode, info->tx_buffer_mode);
+               FST_WRB(card, su_config.rx_buffer_mode, info->rx_buffer_mode);
+               FST_WRB(card, su_config.starting_slot, info->starting_slot);
+               FST_WRB(card, su_config.los_threshold, info->los_threshold);
+               if (info->idle_code)
+                       FST_WRB(card, su_config.enable_idle_code, 1);
                else
-                       FST_WRB(card, suConfig.enableIdleCode, 0);
-               FST_WRB(card, suConfig.idleCode, info->idleCode);
-#if FST_DEBUG
-               if (info->valid & FSTVAL_TE1) {
-                       printk("Setting TE1 data\n");
-                       printk("Line Speed = %d\n", info->lineSpeed);
-                       printk("Start slot = %d\n", info->startingSlot);
-                       printk("Clock source = %d\n", info->clockSource);
-                       printk("Framing = %d\n", my_framing);
-                       printk("Structure = %d\n", info->structure);
-                       printk("interface = %d\n", info->interface);
-                       printk("Coding = %d\n", info->coding);
-                       printk("Line build out = %d\n", info->lineBuildOut);
-                       printk("Equaliser = %d\n", info->equalizer);
-                       printk("Transparent mode = %d\n",
-                              info->transparentMode);
-                       printk("Loop mode = %d\n", info->loopMode);
-                       printk("Range = %d\n", info->range);
-                       printk("Tx Buffer mode = %d\n", info->txBufferMode);
-                       printk("Rx Buffer mode = %d\n", info->rxBufferMode);
-                       printk("LOS Threshold = %d\n", info->losThreshold);
-                       printk("Idle Code = %d\n", info->idleCode);
+                       FST_WRB(card, su_config.enable_idle_code, 0);
+               FST_WRB(card, su_config.idle_code, info->idle_code);
+
+               if (card->type == FST_TYPE_TE1e) {
+                       FST_WRB(card, su_config.ext_sync_clock_enable,
+                               info->ext_sync_clock_enable);
+                       FST_WRB(card, su_config.ext_sync_clock_offset,
+                               info->ext_sync_clock_offset);
+                       FST_WRL(card, su_config.ext_sync_clock_rate,
+                               info->ext_sync_clock_rate);
+                       FST_WRB(card, su_config.pps_enable, info->pps_enable);
+                       FST_WRB(card, su_config.pps_offset, info->pps_offset);
+               }
+               if ((card->type == FST_TYPE_TE1)
+                   || (card->type == FST_TYPE_TE1e)) {
+                       fst_dbg(DBG_OPEN, "Setting TE1 data\n");
+                       fst_dbg(DBG_OPEN, "Line Speed = %d\n",
+                               info->line_speed);
+                       fst_dbg(DBG_OPEN, "Start slot = %d\n",
+                               info->starting_slot);
+                       fst_dbg(DBG_OPEN, "Clock source = %d\n",
+                               info->clock_source);
+                       fst_dbg(DBG_OPEN, "Framing = %d\n", my_framing);
+                       fst_dbg(DBG_OPEN, "Structure = %d\n", info->structure);
+                       fst_dbg(DBG_OPEN, "interface = %d\n", info->interface);
+                       fst_dbg(DBG_OPEN, "Coding = %d\n", info->coding);
+                       fst_dbg(DBG_OPEN, "Line build out = %d\n",
+                               info->line_build_out);
+                       fst_dbg(DBG_OPEN, "Equaliser = %d\n", info->equalizer);
+                       fst_dbg(DBG_OPEN, "Transparent mode = %d\n",
+                               info->transparent_mode);
+                       fst_dbg(DBG_OPEN, "Loop mode = %d\n", info->loop_mode);
+                       fst_dbg(DBG_OPEN, "Range = %d\n", info->range);
+                       fst_dbg(DBG_OPEN, "Tx Buffer mode = %d\n",
+                               info->tx_buffer_mode);
+                       fst_dbg(DBG_OPEN, "Rx Buffer mode = %d\n",
+                               info->rx_buffer_mode);
+                       fst_dbg(DBG_OPEN, "LOS Threshold = %d\n",
+                               info->los_threshold);
+                       fst_dbg(DBG_OPEN, "Idle Code = %d\n", info->idle_code);
+
+                       if (card->type == FST_TYPE_TE1e) {
+                               fst_dbg(DBG_OPEN, "Ext Sync Clock = %d\n",
+                                       info->ext_sync_clock_enable);
+                               fst_dbg(DBG_OPEN,
+                                       "Ext Sync Clock d.c. offset = %d\n",
+                                       info->ext_sync_clock_offset);
+                               fst_dbg(DBG_OPEN, "Ext Sync Clock rate = %d\n",
+                                       info->ext_sync_clock_rate);
+                               fst_dbg(DBG_OPEN, "1PPS sync = %d\n",
+                                       info->pps_enable);
+                               fst_dbg(DBG_OPEN,
+                                       "1PPS sync d.c. offset = %d\n",
+                                       info->pps_offset);
+                       }
+               }
+       }
+       if (info->valid & FSTVAL_DSL_S1) {
+               if (port->proto != FST_GEN_HDLC) {
+                       if (info->encap == ENCAP_MPOA) {
+                               pr_err
+                                   ("Can Only have ATM encapsulation MPOA ");
+                               pr_err("with HDLC proctocol %d\n",
+                                    port->proto);
+                               err++;
+                               return -EINVAL;
+                       }
+               }
+               port->encap = info->encap;
+               FST_WRL(card, dsl_config.data_rate, info->line_speed);
+               FST_WRB(card, dsl_config.terminal_type, info->terminal_type);
+               FST_WRB(card, dsl_config.annex_type, info->annex_type);
+               FST_WRB(card, dsl_config.test_mode, info->test_mode);
+               FST_WRB(card, dsl_config.backoff, info->backoff);
+               FST_WRB(card, dsl_config.b_line_probing_enable,
+                       info->b_line_probing_enable);
+               FST_WRB(card, dsl_config.snrth, info->snrth);
+               FST_WRB(card, dsl_config.lpath, info->lpath);
+               port->vpi = info->vpi;
+               port->vci = info->vci;
+               set_atm_header(port, info->vpi, info->vci);
+               if (card->type == FST_TYPE_DSL_S1) {
+                       fst_dbg(DBG_OPEN, "Setting DSL-S1 Parameters\n");
+                       fst_dbg(DBG_OPEN, "  Speed = %d\n", info->line_speed);
+                       fst_dbg(DBG_OPEN, "  Terminal Type = %d\n",
+                               info->terminal_type);
+                       fst_dbg(DBG_OPEN, "  Annex Type = %d\n",
+                               info->annex_type);
+                       fst_dbg(DBG_OPEN, "  Test Mode = %d\n",
+                               info->test_mode);
+                       fst_dbg(DBG_OPEN, "  Backoff = %d\n", info->backoff);
+                       fst_dbg(DBG_OPEN, "  Snrth = %d\n", info->snrth);
+                       fst_dbg(DBG_OPEN, "  Lpath = %d\n", info->lpath);
+                       fst_dbg(DBG_OPEN, "  VPI set to %x\n", port->vpi);
+                       fst_dbg(DBG_OPEN, "  VCI set to %x\n", port->vci);
                }
-#endif
        }
 #if FST_DEBUG
        if (info->valid & FSTVAL_DEBUG) {
                fst_debug_mask = info->debug;
        }
-#endif
+#endif
+       if ((info->valid & FSTVAL_ASYNC) &&
+           (port->fstioc_info_ver > FST_VERSION_V1)) {
+               FST_A_WRB(port->card, async_config[port->index].flow_control,
+                         info->async_conf.flow_control);
+               FST_A_WRB(port->card, async_config[port->index].xon_char,
+                         info->async_conf.xon_char);
+               FST_A_WRB(port->card, async_config[port->index].xoff_char,
+                         info->async_conf.xoff_char);
+               FST_A_WRB(port->card, async_config[port->index].word_length,
+                         info->async_conf.word_length);
+               FST_A_WRB(port->card, async_config[port->index].stop_bits,
+                         info->async_conf.stop_bits);
+               FST_A_WRB(port->card, async_config[port->index].parity,
+                         info->async_conf.parity);
+       }
+       return err;
+}
+
+static int
+gather_conf_info(struct fst_card_info *card, struct fst_port_info *port,
+                struct fstioc_info *info)
+{
+       int i;
+       int j;
+
+       /* We can zero the whole structure as info is always the current
+        * size.
+        */
+       memset(info, 0, sizeof(struct fstioc_info));
+       i = port->index;
+       info->kernel_version = 3.10;
+       info->nports = card->nports;
+       info->iocinfo_version = port->fstioc_info_ver;
+       info->type = card->type;
+       info->state = card->state;
+       info->proto = FST_GEN_HDLC;
+       info->index = i;
+#if FST_DEBUG
+       info->debug = fst_debug_mask;
+#endif
+
+       /* Only mark information as valid if card is running.
+        * Copy the data anyway in case it is useful for diagnostics
+        */
+       info->valid = ((card->state == FST_RUNNING) ? FSTVAL_ALL : FSTVAL_CARD)
+#if FST_DEBUG
+           | FSTVAL_DEBUG
+#endif
+           ;
+       if (port->hwif)
+               info->line_interface = port->hwif;
+       else
+               info->line_interface = port->hwif =
+                   FST_RDW(card, port_config[i].line_interface);
+       info->internal_clock = FST_RDB(card, port_config[i].internal_clock);
+       info->extended_clocking =
+           FST_RDB(card, port_config[i].extended_clocking);
+       info->termination = FST_RDB(card, port_config[i].termination);
+
+       if (info->extended_clocking) {
+               info->extended_clocking = 0x80;
+               if (FST_RDB(card, port_config[i].internal_tx_clock))
+                       info->extended_clocking += 0x01;
+               if (FST_RDB(card, port_config[i].internal_rx_clock))
+                       info->extended_clocking += 0x02;
+               if (FST_RDB(card, port_config[i].terminal_tx_clock))
+                       info->extended_clocking += 0x04;
+               if (FST_RDB(card, port_config[i].terminal_rx_clock))
+                       info->extended_clocking += 0x08;
+               fst_dbg(DBG_IOCTL, "Returning extended_clocking as %x\n",
+                       info->extended_clocking);
+       } else
+               info->extended_clocking = 0;
+       info->line_speed = FST_RDL(card, port_config[i].line_speed);
+       info->est_line_speed = FST_RDL(card,
+                                      port_config[i].estimated_line_speed);
+       info->invert_clock = FST_RDB(card, port_config[i].invert_clock);
+       info->synth_ability = FST_RDB(card, synth_ability);
+       info->async_ability = FST_RDB(card, async_ability[i]);
+       info->transmit_msb_first =
+           FST_RDB(card, port_config[i].transmit_msb_first);
+       info->receive_msb_first =
+           FST_RDB(card, port_config[i].receive_msb_first);
+       info->tx_rx_start = FST_RDB(card, port_config[i].tx_rx_start);
+       info->v24IpSts = FST_RDL(card, v24IpSts[i]);
+       info->v24OpSts = FST_RDL(card, v24OpSts[i]);
+       info->clock_status = FST_RDW(card, clock_status[i]);
+       info->cable_status = FST_RDW(card, cable_status);
+       info->card_mode = FST_RDW(card, card_mode);
+       info->smc_firmware_version = FST_RDL(card, smc_firmware_version);
+       /* Return the reserved area of the shared memory window
+        */
+       for (j = 0; j < 64; j++)
+               info->_reserved[j] = FST_RDW(card, _reserved[j]);
+       info->card_rev_major = ((info->_reserved[0] & 0xf000) >> 12);
+       info->card_rev_minor = ((info->_reserved[0] & 0x0f00) >> 8);
+       info->card_rev_build = info->_reserved[11] & 0xff;
+       info->ignore_carrier = port->ignore_carrier;
+       info->num_rx_buffers = port->num_rx_buffers;
+       info->num_tx_buffers = port->num_tx_buffers;
+       info->rx_buffer_size = port->rx_buffer_size;
+       info->tx_buffer_size = port->tx_buffer_size;
+       info->transparent_mode = port->mode;
+       info->low_latency = port->low_latency;
+       fst_dbg(DBG_IOCTL, "Returning low latency value of %d\n",
+               info->low_latency);
+       /* The T2U can report cable presence for both A or B
+        * in bits 0 and 1 of cable_status.  See which port we are and
+        * do the mapping.
+        */
+       if (card->family == FST_FAMILY_TXU) {
+               if (port->index == 0) {
+                       /* Port A */
+                       info->cable_status = info->cable_status & 1;
+               } else {
+                       /* Port B */
+                       info->cable_status = info->cable_status >> 1;
+                       info->cable_status = info->cable_status & 1;
+               }
+       }
+       /* Some additional bits if we are TE1 or TE1e
+        */
+       if ((card->type == FST_TYPE_TE1) || (card->type == FST_TYPE_TE1e)) {
+               info->line_speed = FST_RDL(card, su_config.data_rate);
+               info->clock_source = FST_RDB(card, su_config.clocking);
+               info->framing = FST_RDB(card, su_config.framing);
+               info->structure = FST_RDB(card, su_config.structure);
+               info->interface = FST_RDB(card, su_config.interface);
+               info->coding = FST_RDB(card, su_config.coding);
+               info->line_build_out = FST_RDB(card, su_config.line_build_out);
+               info->equalizer = FST_RDB(card, su_config.equalizer);
+               info->loop_mode = FST_RDB(card, su_config.loop_mode);
+               info->range = FST_RDB(card, su_config.range);
+               info->tx_buffer_mode = FST_RDB(card, su_config.tx_buffer_mode);
+               info->rx_buffer_mode = FST_RDB(card, su_config.rx_buffer_mode);
+               info->starting_slot = FST_RDB(card, su_config.starting_slot);
+               if (FST_RDB(card, su_config.enable_idle_code))
+                       info->idle_code = FST_RDB(card, su_config.idle_code);
+               else
+                       info->idle_code = 0;
+               info->los_threshold = FST_RDB(card, su_config.los_threshold);
+               info->receive_buffer_delay =
+                   FST_RDL(card, su_status.receive_buffer_delay);
+               info->framing_error_count =
+                   FST_RDL(card, su_status.framing_error_count);
+               info->code_violation_count =
+                   FST_RDL(card, su_status.code_violation_count);
+               info->crc_error_count = FST_RDL(card,
+                                               su_status.crc_error_count);
+               info->line_attenuation = FST_RDL(card,
+                                                su_status.line_attenuation);
+               info->loss_of_signal = FST_RDB(card, su_status.loss_of_signal);
+               info->receive_remote_alarm =
+                   FST_RDB(card, su_status.receive_remote_alarm);
+               info->alarm_indication_signal =
+                   FST_RDB(card, su_status.alarm_indication_signal);
+
+               if (card->type == FST_TYPE_TE1e) {
+                       info->ext_sync_clock_enable =
+                           FST_RDB(card, su_config.ext_sync_clock_enable);
+                       info->ext_sync_clock_offset =
+                           FST_RDB(card, su_config.ext_sync_clock_offset);
+                       info->ext_sync_clock_rate =
+                           FST_RDL(card, su_config.ext_sync_clock_rate);
+                       info->pps_enable = FST_RDB(card, su_config.pps_enable);
+                       info->pps_offset = FST_RDB(card, su_config.pps_offset);
+               }
+       }
+
+       if ((card->type == FST_TYPE_T4Ep) ||
+           (card->type == FST_TYPE_T2U_PMC) ||
+           (card->type == FST_TYPE_T2Ee) || (card->type == FST_TYPE_T4Ee)) {
+               unsigned char encoding;
+
+               encoding = FST_RDB(card, port_config[port->index].encoding);
+               switch (encoding) {
+               case FSCMN_ENCODING_NRZI:
+                       info->coding = CODING_NRZI;
+                       break;
+               case FSCMN_ENCODING_FM0:
+                       info->coding = CODING_FM0;
+                       break;
+               case FSCMN_ENCODING_FM1:
+                       info->coding = CODING_FM1;
+                       break;
+               case FSCMN_ENCODING_MANCHESTER:
+                       info->coding = CODING_MANCHESTER;
+                       break;
+               case FSCMN_ENCODING_DIFF_MANCHESTER:
+                       info->coding = CODING_DIFF_MANCHESTER;
+                       break;
+               default:
+                       info->coding = CODING_NRZ;
+               }
+               info->enable_nrzi_clocking =
+                 FST_RDB(card, port_config[port->index].enable_nrzi_clocking);
+
+       }
+
+       if (card->type == FST_TYPE_DSL_S1) {
+               info->line_interface = SHDSL;
+               info->vpi = port->vpi;
+               info->vci = port->vci;
+               info->snrth = FST_RDB(card, dsl_config.snrth);
+               info->lpath = FST_RDB(card, dsl_config.lpath);
+               info->line_speed = FST_RDL(card, dsl_config.data_rate);
+               info->terminal_type = FST_RDB(card, dsl_config.terminal_type);
+               info->annex_type = FST_RDB(card, dsl_config.annex_type);
+               info->test_mode = FST_RDB(card, dsl_config.test_mode);
+               info->backoff = FST_RDB(card, dsl_config.backoff);
+               info->activation_status =
+                   FST_RDB(card, dsl_status.activation_status);
+               info->no_common_mode_status =
+                   FST_RDB(card, dsl_status.no_common_mode_status);
+               info->transceiverStatus1 =
+                   FST_RDB(card, dsl_status.transceiverStatus1);
+               info->transceiverStatus2 =
+                   FST_RDB(card, dsl_status.transceiverStatus2);
+               info->line_loss = FST_RDB(card, dsl_status.line_loss);
+               info->signal_quality = FST_RDB(card,
+                                              dsl_status.signal_quality);
+               info->near_end_block_error_count =
+                   FST_RDB(card, dsl_status.near_end_block_error_count);
+               info->signal_to_noise_ratio =
+                   FST_RDB(card, dsl_status.signal_to_noise_ratio);
+               info->code_violation_count =
+                   FST_RDB(card, dsl_status.code_violation_count);
+               info->errored_second_count =
+                   FST_RDB(card, dsl_status.errored_second_count);
+               info->severely_errored_second_count =
+                   FST_RDB(card, dsl_status.severely_errored_second_count);
+               info->loss_of_sync_word_second_count =
+                   FST_RDB(card, dsl_status.loss_of_sync_word_second_count);
+               info->unavailable_second_count =
+                   FST_RDB(card, dsl_status.unavailable_second_count);
+               info->frequency_deviation =
+                   FST_RDB(card, dsl_status.frequency_deviation);
+               info->negotiated_power_back_off =
+                   FST_RDB(card, dsl_status.negotiated_power_back_off);
+               info->negotiated_psd = FST_RDB(card,
+                                              dsl_status.negotiated_psd);
+               info->negotiated_b_channels =
+                   FST_RDB(card, dsl_status.negotiated_b_channels);
+               info->negotiated_z_bits =
+                   FST_RDB(card, dsl_status.negotiated_z_bits);
+               info->negotiated_sync_word =
+                   FST_RDW(card, dsl_status.negotiated_sync_word);
+               info->negotiated_stuff_bits =
+                   FST_RDB(card, dsl_status.negotiated_stuff_bits);
+               info->chip_version = FST_RDB(card, dsl_status.chip_version);
+               info->firmware_version =
+                   FST_RDB(card, dsl_status.firmware_version);
+               info->rom_version = FST_RDB(card, dsl_status.rom_version);
+               info->atm_tx_cell_count = FST_RDW(card,
+                                                dsl_status.atm_tx_cell_count);
+               info->atm_rx_cell_count = FST_RDW(card,
+                                                dsl_status.atm_rx_cell_count);
+               info->atm_hec_error_count =
+                 FST_RDW(card, dsl_status.atm_hec_error_count);
+               info->atm_cells_dropped = port->atm_cells_dropped;
+               info->encap = port->encap;
+               info->xpld_version = FST_RDB(card, dsl_status.xpld_version);
+               info->farEndCountryCode[0] =
+                   FST_RDB(card, dsl_status.farEndCountryCode[0]);
+               info->farEndCountryCode[1] =
+                   FST_RDB(card, dsl_status.farEndCountryCode[1]);
+               info->farEndProviderCode[0] =
+                   FST_RDB(card, dsl_status.farEndProviderCode[0]);
+               info->farEndProviderCode[1] =
+                   FST_RDB(card, dsl_status.farEndProviderCode[1]);
+               info->farEndProviderCode[2] =
+                   FST_RDB(card, dsl_status.farEndProviderCode[2]);
+               info->farEndProviderCode[3] =
+                   FST_RDB(card, dsl_status.farEndProviderCode[3]);
+               info->farEndVendorInfo[0] =
+                   FST_RDB(card, dsl_status.farEndVendorInfo[0]);
+               info->farEndVendorInfo[1] =
+                   FST_RDB(card, dsl_status.farEndVendorInfo[1]);
+               info->utopia_atm_status =
+                   FST_RDB(card, dsl_status.utopia_atm_status);
+       }
+       /* Update the stats
+        */
+       memcpy(&info->stats, hdlc_stats(port->dev),
+              sizeof(struct fst_device_stats));
+       /* Copy in the async config
+        */
+       info->async_conf.flow_control = FST_A_RDB(port->card,
+                               async_config[port->index].flow_control);
+       info->async_conf.stop_bits =
+           FST_A_RDB(port->card, async_config[port->index].stop_bits);
+       info->async_conf.parity =
+           FST_A_RDB(port->card, async_config[port->index].parity);
+       info->async_conf.word_length =
+           FST_A_RDB(port->card, async_config[port->index].word_length);
+       info->async_conf.xon_char =
+           FST_A_RDB(port->card, async_config[port->index].xon_char);
+       info->async_conf.xoff_char =
+           FST_A_RDB(port->card, async_config[port->index].xoff_char);
+       /* and now return the size of the structure according
+        * to the version set
+        */
+       switch (port->fstioc_info_ver) {
+       case FST_VERSION_CURRENT:
+               return fstioc_info_sz_current;
+
+       case FST_VERSION_V1:
+               return fstioc_info_sz_ver1;
+
+       case FST_VERSION_V2:
+               return fstioc_info_sz_ver2;
+
+       case FST_VERSION_V3:
+               return fstioc_info_sz_ver3;
+
+       default:
+               return fstioc_info_sz_old;
+       }
+}
+
+static int set_dsl_port(struct fst_port_info *port, int mode)
+{
+       /* This function is called from processing an ioctl to startup
+        * the dsl port independantly.  It has been introduced specifically
+        * for the tty interface so that the dsl line can be controlled
+        * (up or down) independently of network opens (ifconfig up/down,
+        * or tty_open/close).
+        * Values of mode are normal (off if on)
+        *                    active (on it off and not already in use)
+        *
+        * Return values are 0 is OK
+        *                   1 is error
+        */
+
+       if (mode == FST_DSL_PORT_ACTIVE) {
+               if ((port->run) || (port->port_mode)) {
+                       /* port is already open either by tty or network
+                        * interface or port state has already been set
+                        */
+                       fst_dbg(DBG_ASS, "Port is busy, run = %d mode = %d\n",
+                               port->run, port->port_mode);
+                       return 1;
+               }
+               fst_openport(port);
+               return 0;
+       } else
+               fst_closeport(port);
+       return 0;
+}
+
+static int purge_tx_queue(struct fst_card_info *card,
+                         struct fst_port_info *port)
+{
+       int txq_length;
+       int i;
+       int start;
+       unsigned long flags;
+
+       /* Purge all frames on the tx queue
+        */
+
+       fst_dbg(DBG_TX, "Purging all frame from the tx queue\n");
+       /* Is there anything there?
+        */
+       spin_lock_irqsave(&card->card_lock, flags);
+       start = port->txqs;
+       txq_length = port->txqe - port->txqs;
+       if (txq_length < 0) {
+               /* This is the case where the next free has wrapped but the
+                * last used hasn't
+                */
+               txq_length = txq_length + FST_TXQ_DEPTH;
+       }
+       port->txqs = port->txqe;
+       spin_unlock_irqrestore(&card->card_lock, flags);
+       if (txq_length == 0)
+               return 0;       /* Nothing there */
+       /* de-queue the buffer's and deallocate the resources
+        */
+       pr_info("%s: Purging %d frames from the transmit queue\n",
+              port_to_dev(port)->name, txq_length);
+       for (i = 0; i < txq_length; i++) {
+               if (port->txq[start].frame) {
+                       fst_dbg(DBG_TX, "Purging buffer %d at %p\n", start,
+                               port->txq[start].frame);
+                       dev_kfree_skb(port->txq[start].frame);
+                       port->txq[start].frame = NULL;
+               } else {
+                       pr_info("txq purge found NULL pointer\n");
+               }
+               start++;
+               if (start == FST_TXQ_DEPTH)
+                       start = 0;
+       }
+       return 0;
+}
+
+static int parse_custom_clock_rate_structure(struct fst_port_info *port,
+                                            struct fstioc_custom_rate_config
+                                            *custom_clock_rate)
+{
+       /* Check that the supplied buffer looks like it may contain a valid
+        * set of values
+        */
+       if (custom_clock_rate->version != FST_CUSTOM_RATE_CONFIG_VERSION) {
+               pr_info("Custom clock rate structure is not the version ");
+               pr_info("expected %d %d\n", FST_CUSTOM_RATE_CONFIG_VERSION,
+                    custom_clock_rate->version);
+               return 1;
+       }
+       if (!((custom_clock_rate->multiplier ==
+              (FST_CUSTOM_CLOCK_MULTIPLIER_1))
+             || (custom_clock_rate->multiplier ==
+                 (FST_CUSTOM_CLOCK_MULTIPLIER_16)))) {
+               pr_info("Custom clock rate multiplier is not expected value");
+               pr_info(" (1 or 16) %d\n",
+                    custom_clock_rate->multiplier);
+               return 2;
+       }
+       if (custom_clock_rate->clock_type > FST_CUSTOM_RATE_CLOCK_LOW_MASTER) {
+               pr_info("Custom clock type is not in the rage expected ");
+               pr_info("(0 - 2) %d\n", custom_clock_rate->clock_type);
+               return 3;
+       }
+       if (strlen(custom_clock_rate->rate_info) !=
+           FST_CUSTOM_RATE_CONFIG_LENGTH - 1) {
+               pr_info("Custom clock rate info is not the length expected ");
+               pr_info("%d %d\n", (int)strlen(custom_clock_rate->rate_info),
+                    FST_CUSTOM_RATE_CONFIG_LENGTH - 1);
+               return 4;
+       }
+       /* Validation passed
+        */
+       return 0;
+}

-       return err;
+unsigned int to_int(char c)
+{
+       if (c >= '0' && c <= '9')
+               return c - '0';
+       if (c >= 'A' && c <= 'F')
+               return 10 + c - 'A';
+       if (c >= 'a' && c <= 'f')
+               return 10 + c - 'a';
+       return -1;
+}
+
+static int strtohex(unsigned char *source, unsigned char *dest, int size)
+{
+       int count = 0;
+       int loops = 0;
+
+       loops = (int)strlen(source) / 2;
+       fst_dbg(DBG_IOCTL, "strtohex of length %d\n", loops);
+       for (count = 0; count < loops; count++) {
+               dest[count] =
+                   16 * to_int(source[2 * count]) +
+                   to_int(source[2 * count + 1]);
+       }
+       dest[count] = 0xff;
+       return 0;
 }

-static void
-gather_conf_info(struct fst_card_info *card, struct fst_port_info *port,
-                struct fstioc_info *info)
+static int
+set_custom_clock_rate(struct fst_port_info *port,
+                     struct fstioc_custom_rate_config *custom_clock_rate)
 {
+       struct fstioc_req sys_request;
+       char sz_rate_info[(FST_CUSTOM_RATE_CONFIG_LENGTH * 2) + 1];
+       unsigned char buf[FST_CUSTOM_RATE_CONFIG_LENGTH];
+       unsigned char checksum[16];
+       struct crypto_hash *tfm;
+       struct hash_desc desc;
+       struct scatterlist sg;
+       char sx_checksum[3];
+       char *psz_clock_type = NULL;
        int i;
+       int retval;
+       unsigned long flags;
+       int status;

-       memset(info, 0, sizeof (struct fstioc_info));
-
-       i = port->index;
-       info->kernelVersion = LINUX_VERSION_CODE;
-       info->nports = card->nports;
-       info->type = card->type;
-       info->state = card->state;
-       info->proto = FST_GEN_HDLC;
-       info->index = i;
-#if FST_DEBUG
-       info->debug = fst_debug_mask;
-#endif
+#define MD5_SUM_LENGTH 23

-       /* Only mark information as valid if card is running.
-        * Copy the data anyway in case it is useful for diagnostics
+       /* Prepare the string and construct the usb command and send it
         */
-       info->valid = ((card->state == FST_RUNNING) ? FSTVAL_ALL : FSTVAL_CARD)
-#if FST_DEBUG
-           | FSTVAL_DEBUG
-#endif
-           ;
+       memset(&sys_request, 0, sizeof(struct fstioc_req));
+       memset(buf, 0x00, sizeof(buf));
+       sys_request.msg_type = custom_clock_rate->multiplier;
+       sys_request.msg_len = sizeof(struct fstioc_req);
+       sys_request.i_reg_idx = port->index;
+
+       fst_dbg(DBG_IOCTL, "Supplied rate = %d and rate info is %s\n",
+               custom_clock_rate->rate, custom_clock_rate->rate_info);
+
+       switch (custom_clock_rate->clock_type) {
+       case FST_CUSTOM_RATE_CLOCK_LOW_SLAVE:
+               psz_clock_type = "0000";
+               break;
+       case FST_CUSTOM_RATE_CLOCK_LOW_MASTER:
+               psz_clock_type = "0101";
+               break;
+       case FST_CUSTOM_RATE_CLOCK_SLAVE:
+       default:
+               psz_clock_type = "0100";
+               break;
+       }

-       info->lineInterface = FST_RDW(card, portConfig[i].lineInterface);
-       info->internalClock = FST_RDB(card, portConfig[i].internalClock);
-       info->lineSpeed = FST_RDL(card, portConfig[i].lineSpeed);
-       info->invertClock = FST_RDB(card, portConfig[i].invertClock);
-       info->v24IpSts = FST_RDL(card, v24IpSts[i]);
-       info->v24OpSts = FST_RDL(card, v24OpSts[i]);
-       info->clockStatus = FST_RDW(card, clockStatus[i]);
-       info->cableStatus = FST_RDW(card, cableStatus);
-       info->cardMode = FST_RDW(card, cardMode);
-       info->smcFirmwareVersion = FST_RDL(card, smcFirmwareVersion);
+       sprintf(sz_rate_info, "%08X", ntohl(custom_clock_rate->rate));
+       strcat(sz_rate_info, "0");
+       strcat(sz_rate_info, custom_clock_rate->rate_info);
+       strcat(sz_rate_info, psz_clock_type);
+       fst_dbg(DBG_IOCTL, "Temp1 ascii sz_rate_info=%s\n", sz_rate_info);
+       fst_dbg(DBG_IOCTL, "Length of string to convert is %d\n",
+               (int)strlen(sz_rate_info));
+       strtohex(sz_rate_info, buf, sizeof(buf) - 1);
+       fst_dbg(DBG_IOCTL, "Temp2 ascii sz_rate_info=%s\n", sz_rate_info);
+       fst_dbg(DBG_IOCTL, "Temp hex buf: ");
+       for (i = 0; i < sizeof(buf); i++)
+               fst_dbg(DBG_IOCTL, "%02x ", buf[i]);
+       fst_dbg(DBG_IOCTL, "\n");

-       /*
-        * The T2U can report cable presence for both A or B
-        * in bits 0 and 1 of cableStatus.  See which port we are and
-        * do the mapping.
+       fst_dbg(DBG_IOCTL, "Temp3 ascii sz_rate_info=%s\n", sz_rate_info);
+
+       /* Use the Kernel Crypto API to calculate the MD5Sum of the
+        * updated rate string
         */
-       if (card->family == FST_FAMILY_TXU) {
-               if (port->index == 0) {
-                       /*
-                        * Port A
-                        */
-                       info->cableStatus = info->cableStatus & 1;
-               } else {
-                       /*
-                        * Port B
-                        */
-                       info->cableStatus = info->cableStatus >> 1;
-                       info->cableStatus = info->cableStatus & 1;
-               }
-       }
-       /*
-        * Some additional bits if we are TE1
+       tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+       desc.tfm = tfm;
+       desc.flags = 0;
+       crypto_hash_init(&desc);
+       sg_init_one(&sg, buf, MD5_SUM_LENGTH);
+       crypto_hash_update(&desc, &sg, MD5_SUM_LENGTH);
+       memset(checksum, 0, sizeof(checksum));
+       crypto_hash_final(&desc, checksum);
+       fst_dbg(DBG_IOCTL, "Checksum: ");
+       for (i = 0; i < sizeof(checksum); i++)
+               fst_dbg(DBG_IOCTL, "%02x ", checksum[i]);
+       fst_dbg(DBG_IOCTL, "\n");
+
+       sprintf(sx_checksum, "%02X", checksum[0]);
+       strcat(sz_rate_info, sx_checksum);
+       fst_dbg(DBG_IOCTL, "Temp7 ascii sz_rate_info=%s\n", sz_rate_info);
+       strtohex(sz_rate_info, sys_request.u_msg,
+                FST_CUSTOM_RATE_CONFIG_LENGTH);
+       crypto_free_hash(tfm);
+
+       /* Now we can send the request to the card
+        * Use a spin lock to ensure only one request at a time
         */
-       if (card->type == FST_TYPE_TE1) {
-               info->lineSpeed = FST_RDL(card, suConfig.dataRate);
-               info->clockSource = FST_RDB(card, suConfig.clocking);
-               info->framing = FST_RDB(card, suConfig.framing);
-               info->structure = FST_RDB(card, suConfig.structure);
-               info->interface = FST_RDB(card, suConfig.interface);
-               info->coding = FST_RDB(card, suConfig.coding);
-               info->lineBuildOut = FST_RDB(card, suConfig.lineBuildOut);
-               info->equalizer = FST_RDB(card, suConfig.equalizer);
-               info->loopMode = FST_RDB(card, suConfig.loopMode);
-               info->range = FST_RDB(card, suConfig.range);
-               info->txBufferMode = FST_RDB(card, suConfig.txBufferMode);
-               info->rxBufferMode = FST_RDB(card, suConfig.rxBufferMode);
-               info->startingSlot = FST_RDB(card, suConfig.startingSlot);
-               info->losThreshold = FST_RDB(card, suConfig.losThreshold);
-               if (FST_RDB(card, suConfig.enableIdleCode))
-                       info->idleCode = FST_RDB(card, suConfig.idleCode);
-               else
-                       info->idleCode = 0;
-               info->receiveBufferDelay =
-                   FST_RDL(card, suStatus.receiveBufferDelay);
-               info->framingErrorCount =
-                   FST_RDL(card, suStatus.framingErrorCount);
-               info->codeViolationCount =
-                   FST_RDL(card, suStatus.codeViolationCount);
-               info->crcErrorCount = FST_RDL(card, suStatus.crcErrorCount);
-               info->lineAttenuation = FST_RDL(card, suStatus.lineAttenuation);
-               info->lossOfSignal = FST_RDB(card, suStatus.lossOfSignal);
-               info->receiveRemoteAlarm =
-                   FST_RDB(card, suStatus.receiveRemoteAlarm);
-               info->alarmIndicationSignal =
-                   FST_RDB(card, suStatus.alarmIndicationSignal);
+       fst_dbg(DBG_ASS, "Sending the card the request\n");
+       fstioc_req_to_le(&sys_request);
+       spin_lock_irqsave(&port->card->fifo_lock, flags);
+       if (write_into_fifo
+           (port->card->mem + ASY_OFFSET(msg_fifo), FIFO_ASY_MSG,
+            (char *)&sys_request, sizeof(sys_request))) {
+               spin_unlock_irqrestore(&port->card->fifo_lock, flags);
+               fstioc_req_to_cpu(&sys_request);
+               fst_dbg(DBG_ASS, "Not enough room in fifo\n");
+               return -ENOSPC;
+       }
+       spin_unlock_irqrestore(&port->card->fifo_lock, flags);
+       retval = 0;
+       /* We are always going to wait for a reply
+        */
+       fst_dbg(DBG_ASS, "Waiting for a reply\n");
+       port->card->fifo_complete = 0;
+       status = wait_event_interruptible_timeout(port->card->fifo_waitq,
+                                                 (port->card->fifo_complete),
+                                                 500);
+       if (status == -ERESTARTSYS)
+               retval = -EINTR;
+       if (status == 0) {
+               pr_err("Timeout in processing SYSREQ %x\n",
+                          sys_request.msg_type);
+               retval = -ETIME;
+       }
+       fst_dbg(DBG_IOCTL, "Reply received (%d) or interrupts (%x)\n",
+               port->card->fifo_complete, status);
+       /* Copy the buffer back and we are complete
+        */
+       spin_lock_irqsave(&port->card->fifo_lock, flags);
+       read_from_fifo(port->card->mem + ASY_OFFSET(rsp_fifo), FIFO_ASY_RSP,
+                      (char *)&sys_request, sys_request.msg_len);
+       spin_unlock_irqrestore(&port->card->fifo_lock, flags);
+       fstioc_req_to_cpu(&sys_request);
+
+       if (sys_request.ret_code) {
+               fst_dbg(DBG_ASS, "Set Custom Clock Rate: Retval is %d\n",
+                       sys_request.ret_code);
+               return retval;
        }
+       fst_dbg(DBG_IOCTL, "Returning from set_custom_clock_rate\n");
+       return 0;
 }

 static int
@@ -1864,12 +7024,10 @@ fst_set_iface(struct fst_card_info *card
        sync_serial_settings sync;
        int i;

-       if (ifr->ifr_settings.size != sizeof (sync)) {
+       if (ifr->ifr_settings.size != sizeof(sync))
                return -ENOMEM;
-       }
-
        if (copy_from_user
-           (&sync, ifr->ifr_settings.ifs_ifsu.sync, sizeof (sync))) {
+           (&sync, ifr->ifr_settings.ifs_ifsu.sync, sizeof(sync))) {
                return -EFAULT;
        }

@@ -1880,34 +7038,71 @@ fst_set_iface(struct fst_card_info *card

        switch (ifr->ifr_settings.type) {
        case IF_IFACE_V35:
-               FST_WRW(card, portConfig[i].lineInterface, V35);
+               FST_WRW(card, port_config[i].line_interface, V35);
                port->hwif = V35;
                break;

        case IF_IFACE_V24:
-               FST_WRW(card, portConfig[i].lineInterface, V24);
+               FST_WRW(card, port_config[i].line_interface, V24);
                port->hwif = V24;
                break;

        case IF_IFACE_X21:
-               FST_WRW(card, portConfig[i].lineInterface, X21);
+               FST_WRW(card, port_config[i].line_interface, X21);
                port->hwif = X21;
                break;

        case IF_IFACE_X21D:
-               FST_WRW(card, portConfig[i].lineInterface, X21D);
+               FST_WRW(card, port_config[i].line_interface, X21D);
                port->hwif = X21D;
                break;

        case IF_IFACE_T1:
-               FST_WRW(card, portConfig[i].lineInterface, T1);
+               FST_WRW(card, port_config[i].line_interface, T1);
                port->hwif = T1;
                break;

        case IF_IFACE_E1:
-               FST_WRW(card, portConfig[i].lineInterface, E1);
+               FST_WRW(card, port_config[i].line_interface, E1);
                port->hwif = E1;
                break;
+#if 0
+       case IF_IFACE_J1:
+               FST_WRW(card, port_config[i].line_interface, J1);
+               port->hwif = J1;
+               break;
+#endif
+       case IF_IFACE_SHDSL:
+               FST_WRW(card, port_config[i].line_interface, SHDSL);
+               port->hwif = SHDSL;
+               break;
+
+       case IF_IFACE_RS530_449:
+               if ((card->type == FST_TYPE_T1U) ||
+                   (card->type == FST_TYPE_T2U) ||
+                   (card->type == FST_TYPE_T2UE) ||
+                   (card->type == FST_TYPE_T4U) ||
+                   (card->type == FST_TYPE_T4UE))
+                       FST_WRW(card, port_config[i].line_interface, X21);
+               else
+                       FST_WRW(card, port_config[i].line_interface, RS530_449);
+               port->hwif = RS530_449;
+               break;
+
+       case IF_IFACE_RS485:
+               FST_WRW(card, port_config[i].line_interface, RS485);
+               port->hwif = RS485;
+               break;
+
+       case IF_IFACE_RS485_FDX:
+               FST_WRW(card, port_config[i].line_interface, RS485_FDX);
+               port->hwif = RS485_FDX;
+               break;
+
+       case IF_IFACE_UX35C:
+               FST_WRW(card, port_config[i].line_interface, X21);
+               port->hwif = UX35C;
+               break;

        case IF_IFACE_SYNC_SERIAL:
                break;
@@ -1918,17 +7113,17 @@ fst_set_iface(struct fst_card_info *card

        switch (sync.clock_type) {
        case CLOCK_EXT:
-               FST_WRB(card, portConfig[i].internalClock, EXTCLK);
+               FST_WRB(card, port_config[i].internal_clock, EXTCLK);
                break;

        case CLOCK_INT:
-               FST_WRB(card, portConfig[i].internalClock, INTCLK);
+               FST_WRB(card, port_config[i].internal_clock, INTCLK);
                break;

        default:
                return -EINVAL;
        }
-       FST_WRL(card, portConfig[i].lineSpeed, sync.clock_rate);
+       FST_WRL(card, port_config[i].line_speed, sync.clock_rate);
        return 0;
 }

@@ -1940,25 +7135,52 @@ fst_get_iface(struct fst_card_info *card
        int i;

        /* First check what line type is set, we'll default to reporting X.21
-        * if nothing is set as IF_IFACE_SYNC_SERIAL implies it can't be
-        * changed
         */
        switch (port->hwif) {
-       case E1:
-               ifr->ifr_settings.type = IF_IFACE_E1;
-               break;
-       case T1:
-               ifr->ifr_settings.type = IF_IFACE_T1;
+       case V24:
+               ifr->ifr_settings.type = IF_IFACE_V24;
                break;
+
        case V35:
                ifr->ifr_settings.type = IF_IFACE_V35;
                break;
-       case V24:
-               ifr->ifr_settings.type = IF_IFACE_V24;
-               break;
+
        case X21D:
                ifr->ifr_settings.type = IF_IFACE_X21D;
                break;
+
+       case RS530_449:
+               ifr->ifr_settings.type = IF_IFACE_RS530_449;
+               break;
+
+       case T1:
+               ifr->ifr_settings.type = IF_IFACE_T1;
+               break;
+
+       case E1:
+               ifr->ifr_settings.type = IF_IFACE_E1;
+               break;
+#if 0
+       case J1:
+               ifr->ifr_settings.type = IF_IFACE_J1;
+               break;
+#endif
+       case SHDSL:
+               ifr->ifr_settings.type = IF_IFACE_SHDSL;
+               break;
+
+       case RS485:
+               ifr->ifr_settings.type = IF_IFACE_RS485;
+               break;
+
+       case UX35C:
+               ifr->ifr_settings.type = IF_IFACE_UX35C;
+               break;
+
+       case RS485_FDX:
+               ifr->ifr_settings.type = IF_IFACE_RS485_FDX;
+               break;
+
        case X21:
        default:
                ifr->ifr_settings.type = IF_IFACE_X21;
@@ -1967,37 +7189,49 @@ fst_get_iface(struct fst_card_info *card
        if (ifr->ifr_settings.size == 0) {
                return 0;       /* only type requested */
        }
-       if (ifr->ifr_settings.size < sizeof (sync)) {
+       if (ifr->ifr_settings.size < sizeof(sync))
                return -ENOMEM;
-       }

        i = port->index;
-       sync.clock_rate = FST_RDL(card, portConfig[i].lineSpeed);
+       sync.clock_rate = FST_RDL(card, port_config[i].line_speed);
        /* Lucky card and linux use same encoding here */
-       sync.clock_type = FST_RDB(card, portConfig[i].internalClock) ==
+       sync.clock_type = FST_RDB(card, port_config[i].internal_clock) ==
            INTCLK ? CLOCK_INT : CLOCK_EXT;
        sync.loopback = 0;

-       if (copy_to_user(ifr->ifr_settings.ifs_ifsu.sync, &sync, sizeof (sync))) {
+       if (copy_to_user(ifr->ifr_settings.ifs_ifsu.sync,
+                        &sync, sizeof(sync)))
                return -EFAULT;
-       }

-       ifr->ifr_settings.size = sizeof (sync);
+       ifr->ifr_settings.size = sizeof(sync);
        return 0;
 }

-static int
-fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
        struct fst_card_info *card;
        struct fst_port_info *port;
        struct fstioc_write wrthdr;
        struct fstioc_info info;
        unsigned long flags;
-       void *buf;
-
-       dbg(DBG_IOCTL, "ioctl: %x, %p\n", cmd, ifr->ifr_data);
+       struct fstioc_status state;
+       struct fstioc_req sys_request;
+       struct fstioc_custom_rate_config custom_clock_rate;
+       int retval = 0;
+       int len;
+       int new_mode;
+       int info_size;
+       char fstioc_info_ver;
+       char readv_mode;
+       unsigned char signals;
+       struct fstioc_cmd my_cmd;
+       struct fstioc_char_data char_data;
+       struct fstioc_latency_data latency_data;
+       unsigned long copied = 0;
+       int status;
+       int speed;

+       fst_dbg(DBG_IOCTL, "ioctl: %x, %p\n", cmd, ifr->ifr_data);
        port = dev_to_port(dev);
        card = port->card;

@@ -2024,27 +7258,27 @@ fst_ioctl(struct net_device *dev, struct
                        return -EINVAL;
                }
                if (copy_from_user(&wrthdr, ifr->ifr_data,
-                                  sizeof (struct fstioc_write))) {
+                                  sizeof(struct fstioc_write))) {
                        return -EFAULT;
                }

                /* Sanity check the parameters. We don't support partial writes
                 * when going over the top
                 */
-               if (wrthdr.size > FST_MEMSIZE || wrthdr.offset > FST_MEMSIZE ||
-                   wrthdr.size + wrthdr.offset > FST_MEMSIZE) {
+               if (wrthdr.size > FST_MEMSIZE || wrthdr.offset > FST_MEMSIZE
+                   || wrthdr.size + wrthdr.offset > FST_MEMSIZE) {
                        return -ENXIO;
                }

-               /* Now copy the data to the card. */
-
-               buf = memdup_user(ifr->ifr_data + sizeof(struct fstioc_write),
-                                 wrthdr.size);
-               if (IS_ERR(buf))
-                       return PTR_ERR(buf);
-
-               memcpy_toio(card->mem + wrthdr.offset, buf, wrthdr.size);
-               kfree(buf);
+               /* Now copy the data to the card.
+                * This will probably break on some architectures.
+                * I'll fix it when I have something to test on.
+                */
+               if (copy_from_user(card->mem + wrthdr.offset,
+                                  ifr->ifr_data + sizeof(struct fstioc_write),
+                                  wrthdr.size)) {
+                       return -EFAULT;
+               }

                /* Writes to the memory of a card in the reset state constitute
                 * a download
@@ -2054,6 +7288,19 @@ fst_ioctl(struct net_device *dev, struct
                }
                return 0;

+       case FSTGETSHELL:
+
+               if (ifr->ifr_data == NULL)
+                       return -EINVAL;
+
+               info_size = gather_conf_info(card, port, &info);
+
+               if (port->compat == 1)
+                       memcpy(ifr->ifr_data, &info, info_size);
+               else if (copy_to_user(ifr->ifr_data, &info, info_size))
+                       return -EFAULT;
+               return 0;
+
        case FSTGETCONF:

                /* If card has just been started check the shared memory config
@@ -2064,41 +7311,192 @@ fst_ioctl(struct net_device *dev, struct

                        /* If everything checked out enable card interrupts */
                        if (card->state == FST_RUNNING) {
-                               spin_lock_irqsave(&card->card_lock, flags);
                                fst_enable_intr(card);
                                FST_WRB(card, interruptHandshake, 0xEE);
-                               spin_unlock_irqrestore(&card->card_lock, flags);
                        }
                }

-               if (ifr->ifr_data == NULL) {
+               if (card->state != FST_RUNNING)
+                       return -ENODEV;
+
+               if (ifr->ifr_data == NULL)
                        return -EINVAL;
+               if (!access_ok(VERIFY_WRITE, ifr->ifr_data, sizeof(info))) {
+                       fst_dbg(DBG_ASS,
+                               "%s: fstgetconf: Can't access address %p\n",
+                               dev->name, ifr->ifr_data);
+                       return -EFAULT;
+               }
+               memset(&info, 0, sizeof(struct fstioc_info));
+               info_size = gather_conf_info(card, port, &info);
+               if (port->compat == 1) {
+                       memcpy(ifr->ifr_data, &info, info_size);
+               } else {
+                       if (copy_to_user(ifr->ifr_data, &info, info_size))
+                               return -EFAULT;
                }
+               return 0;

-               gather_conf_info(card, port, &info);
+       case FSTSETCONF:

-               if (copy_to_user(ifr->ifr_data, &info, sizeof (info))) {
+               if (card->state != FST_RUNNING) {
+                       pr_err("Attempt to configure card %d ",
+                              card->card_no);
+                       pr_err("in non-running state (%d)\n", card->state);
+                       return -EIO;
+               }
+               if (!access_ok(VERIFY_READ, ifr->ifr_data, sizeof(info))) {
+                       fst_dbg(DBG_ASS,
+                               "%s: fstsetconf: Can't access address %p\n",
+                              dev->name, ifr->ifr_data);
                        return -EFAULT;
                }
+               memset(&info, 0, sizeof(struct fstioc_info));
+               if (port->fstioc_info_ver == FST_VERSION_CURRENT) {
+                       if (port->compat == 1) {
+                               retval =
+                                   __copy_from_user(&info, ifr->ifr_data,
+                                                    sizeof(info));
+                       } else {
+                               retval = copy_from_user(&info, ifr->ifr_data,
+                                                       sizeof(info));
+                       }
+               }
+               if (retval)
+                       return -EFAULT;
+               return set_conf_from_info(card, port, &info);
+
+       case FSTSNOTIFY:
+               /* The application layer above wants to toggle the state notify
+                * mechanism.
+                */
+               if (copy_from_user
+                   (&port->notify_mode, ifr->ifr_data, sizeof(int)))
+                       return -EFAULT;
+               fst_dbg(DBG_IOCTL, "%s: Setting Notify mode to %d\n",
+                       port->dev->name, port->notify_mode);
                return 0;

-       case FSTSETCONF:
+       case FSTSETMON:
+               /* The application layer above wants to monitor tx and rx data
+                * mechanism.
+                */
+               if (copy_from_user
+                   (&port->monitor_mode, ifr->ifr_data, sizeof(int)))
+                       return -EFAULT;
+               fst_dbg(DBG_IOCTL,
+                       "Card %d port %d: Setting Monitor mode to %d\n",
+                       card->card_no, port->index, port->monitor_mode);
+               return 0;

-               /*
-                * Most of the settings have been moved to the generic ioctls
-                * this just covers debug and board ident now
+       case FSTSETPORT:
+               /* An alternative way to activate the dsl port so that the
+                * line is already up when needed by pppd
                 */
+               if (copy_from_user(&new_mode, ifr->ifr_data, sizeof(int))) {
+                       fst_dbg(DBG_ASS,
+                               "Error in getting data, set port state\n");
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL,
+                       "Card %d port %d: Setting port mode to %d\n",
+                       card->card_no, port->index, new_mode);
+               if (set_dsl_port(port, new_mode))
+                       return -EBUSY;
+               port->port_mode = new_mode;
+               return 0;

-               if (card->state != FST_RUNNING) {
-                       pr_err("Attempt to configure card %d in non-running state (%d)\n",
-                              card->card_no, card->state);
-                       return -EIO;
+       case FSTGSTATE:
+               /* The application  layer above wants the carrier state
+                */
+               state.carrier_state = netif_carrier_ok(port_to_dev(port));
+               /* and the txq is a simple length
+                */
+               state.txq_length = port->txqe - port->txqs;
+               if (state.txq_length < 0) {
+                       /* This is the case where the next free has wrapped
+                        * but the last used hasn't
+                        */
+                       state.txq_length = state.txq_length + FST_TXQ_DEPTH;
+               }
+               state.rxq_length = 0;
+               if (port->notify_mode == FST_NOTIFY_EXTENDED) {
+                       /* Update the stats
+                        */
+
+                       memcpy(&state.stats, hdlc_stats(port->dev),
+                              sizeof(struct fst_device_stats));
+                       len = sizeof(struct fstioc_status);
+               } else {
+                       len = FST_NOTIFY_BASIC_SIZE;
                }
-               if (copy_from_user(&info, ifr->ifr_data, sizeof (info))) {
+               if (port->compat == 1)
+                       memcpy(ifr->ifr_data, &state, len);
+               else if (copy_to_user(ifr->ifr_data, &state, len))
+                       return -EFAULT;
+               return 0;
+
+       case FSTSYSREQ:
+               /* Pass the command through to the card.  If the command
+                * generates a response, wait for it.  The application
+                * suspends untill the command completes.
+                */
+               fst_dbg(DBG_IOCTL, "FSTSYSREQ received\n");
+               if (copy_from_user
+                   (&sys_request, ifr->ifr_data, sizeof(sys_request))) {
+                       fst_dbg(DBG_ASS,
+                               "Could not copy sysrequest from user\n");
                        return -EFAULT;
                }
+               fst_dbg(DBG_IOCTL, "The request is as follows:\n");
+               fst_dbg(DBG_IOCTL, "msg_type = %x\n", sys_request.msg_type);
+               /* Use a spin lock to ensure only one request at a time
+                */
+               fst_dbg(DBG_IOCTL, "Sending the card the request\n");
+               fstioc_req_to_le(&sys_request);
+               spin_lock_irqsave(&card->fifo_lock, flags);
+               if (write_into_fifo
+                   (card->mem + ASY_OFFSET(msg_fifo), FIFO_ASY_MSG,
+                    (char *)&sys_request, sizeof(sys_request))) {
+                       spin_unlock_irqrestore(&card->fifo_lock, flags);
+                       fstioc_req_to_cpu(&sys_request);
+                       fst_dbg(DBG_IOCTL, "Not enough room in fifo\n");
+                       return -ENOSPC;
+               }
+               spin_unlock_irqrestore(&card->fifo_lock, flags);
+               retval = 0;
+               /* We Are always going to wait for a reply
+                */

-               return set_conf_from_info(card, port, &info);
+               fst_dbg(DBG_IOCTL, "Waiting for a reply\n");
+               card->fifo_complete = 0;
+               status = wait_event_interruptible_timeout(card->fifo_waitq,
+                                                         (card->fifo_complete),
+                                                         500);
+               if (status == -ERESTARTSYS)
+                       retval = -EINTR;
+               if (status == 0) {
+                       pr_err("Timeout in processing SYSREQ %x\n",
+                                  sys_request.msg_type);
+                       retval = -ETIME;
+               }
+               fst_dbg(DBG_IOCTL, "Reply received (%d) or interrupts (%x)\n",
+                       card->fifo_complete, status);
+               /* Copy the buffer back and we are complete
+                */
+               spin_lock_irqsave(&card->fifo_lock, flags);
+               read_from_fifo(card->mem + ASY_OFFSET(rsp_fifo), FIFO_ASY_RSP,
+                              (char *)&sys_request, sys_request.msg_len);
+               spin_unlock_irqrestore(&card->fifo_lock, flags);
+               fstioc_req_to_cpu(&sys_request);
+               if (copy_to_user(ifr->ifr_data, &sys_request,
+                                sizeof(sys_request))) {
+                       fst_dbg(DBG_IOCTL,
+                               "Error copying data back to user\n");
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL, "Returning from FSTSYSREQ\n");
+               return retval;

        case SIOCWANDEV:
                switch (ifr->ifr_settings.type) {
@@ -2112,24 +7510,499 @@ fst_ioctl(struct net_device *dev, struct
                case IF_IFACE_X21D:
                case IF_IFACE_T1:
                case IF_IFACE_E1:
+               case IF_IFACE_SHDSL:
+               case IF_IFACE_RS530_449:
+               case IF_IFACE_RS485:
+               case IF_IFACE_RS485_FDX:
+               case IF_IFACE_UX35C:
                        return fst_set_iface(card, port, ifr);

                case IF_PROTO_RAW:
-                       port->mode = FST_RAW;
+                       port->proto = FST_RAW;
+                       return 0;
+
+               case IF_GET_PROTO:
+                       if (port->proto == FST_RAW) {
+                               ifr->ifr_settings.type = IF_PROTO_RAW;
+                               return 0;
+                       }
+                       retval = hdlc_ioctl(dev, ifr, cmd);
+                       if (retval == -EINVAL) {
+                               /*
+                                * Protocol not set yet
+                                */
+                               port->proto = FST_GEN_HDLC;
+                               ifr->ifr_settings.type = FST_GEN_HDLC;
+                               retval = 0;
+                       }
+                       return retval;
+
+               default:
+                       port->proto = FST_GEN_HDLC;
+                       fst_dbg(DBG_IOCTL, "Passing this type to hdlc %x\n",
+                               ifr->ifr_settings.type);
+                       port->hdlc_proto = ifr->ifr_settings.type;
+                       return hdlc_ioctl(dev, ifr, cmd);
+               }
+
+       case FSTCMD:
+               /* A general purpose command/response mechanism
+                * First, get it.
+                */
+               if (port->compat == 1)
+                       memcpy(&my_cmd, ifr->ifr_data, sizeof(my_cmd));
+               else if (copy_from_user(&my_cmd, ifr->ifr_data,
+                                       sizeof(my_cmd))) {
+                       fst_dbg(DBG_ASS,
+                               "fstcmd: Could not access user buffers\n");
+                       return -EFAULT;
+               }
+
+               if (my_cmd.version != 1) {
+                       fst_dbg(DBG_ASS, "fstcmd: bad version %d\n",
+                               my_cmd.version);
+                       return -EINVAL;
+               }
+               switch (my_cmd.command) {
+               case FSTCMD_GET_SERIAL:
+                       extract_serial(card);
+
+                       if (copy_to_user
+                           (my_cmd.data_ptr, serial, strlen(serial))) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy serial back\n");
+                               return -EFAULT;
+                       }
+                       my_cmd.output_data_len = strlen(serial);
+                       /* And invert the status field to show we have
+                        * understood and completed the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user
+                                (ifr->ifr_data, &my_cmd, sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       fst_dbg(DBG_IOCTL, "Returning serial number %s",
+                               serial);
+                       return 0;
+
+               case FSTCMD_SET_V24O:
+                       if (my_cmd.input_data_len < 1) {
+                               fst_dbg(DBG_ASS,
+                                       "(%s) Cannot set V24 signals , no data provided %d\n",
+                                       port->dev->name,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       if (copy_from_user(&signals, my_cmd.data_ptr, 1)) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: could not set v24 signals\n");
+                               return -EFAULT;
+                       }
+
+                       if (signals >
+                           (OPSTS_RTS + OPSTS_DTR + OPSTS_DSRS + OPSTS_SS +
+                            OPSTS_LL + OPSTS_DCD + OPSTS_RL)) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: v24 signals not valid %d\n",
+                                       signals);
+                               return -EFAULT;
+                       }
+                       FST_WRL(port->card, v24OpSts[port->index], signals);
+                       fst_issue_cmd(port, SETV24O);
+                       my_cmd.output_data_len = 0;
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user
+                                (ifr->ifr_data, &my_cmd, sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_GET_VERSION:
+                       if (copy_to_user
+                           (my_cmd.data_ptr, &port->fstioc_info_ver, 1)) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy fstioc_info version back\n");
+                               return -EFAULT;
+                       }
+                       my_cmd.output_data_len = sizeof(fstioc_info_ver);
+                       /* And invert the status field to show we have
+                        * Understood and complete the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user
+                                (ifr->ifr_data, &my_cmd, sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_SET_VERSION:
+                       if (my_cmd.input_data_len > 0) {
+                               if (copy_from_user(&fstioc_info_ver,
+                                                  my_cmd.data_ptr, 1)) {
+                                       fst_dbg(DBG_ASS,
+                                               "fstcmd: could not get fstioc_info version\n");
+                                       return -EFAULT;
+                               }
+                               if ((fstioc_info_ver < FST_VERSION_OLD) ||
+                                   (fstioc_info_ver > FST_VERSION_CURRENT)) {
+                                       fst_dbg(DBG_ASS,
+                                               "fstcmd: setting an invalid fstioc_info version %d\n",
+                                               fstioc_info_ver);
+                                       return -EFAULT;
+                               }
+                               my_cmd.output_data_len = 0;
+                               /* And invert the status field to show we
+                                * have done the command
+                                */
+                               my_cmd.status = ~my_cmd.status;
+                               if (port->compat == 1)
+                                       memcpy(ifr->ifr_data, &my_cmd,
+                                              sizeof(my_cmd));
+                               else if (copy_to_user
+                                        (ifr->ifr_data, &my_cmd,
+                                         sizeof(my_cmd))) {
+                                       fst_dbg(DBG_ASS,
+                                               "fstcmd: could not copy status back\n");
+                                       return -EFAULT;
+                               }
+                               port->fstioc_info_ver = fstioc_info_ver;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "(%s) Cannot copy fstioc_info version, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_GET_INTS:
+                       if (port->compat == 1)
+                               memcpy(my_cmd.data_ptr,
+                                      &fst_int_counter[port->card->card_no],
+                                      sizeof(struct fst_ints));
+                       else
+                               copied = copy_to_user(my_cmd.data_ptr,
+                                                     &fst_int_counter
+                                                     [port->card->card_no],
+                                                     sizeof(struct fst_ints));
+                       if (copied) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy all the int stats back %lu\n",
+                                       copied);
+                               return -EFAULT;
+                       }
+                       my_cmd.output_data_len = sizeof(struct fst_ints);
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user
+                                (ifr->ifr_data, &my_cmd, sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_RESET_INTS:
+                       memset(&fst_int_counter[port->card->card_no], 0,
+                              sizeof(struct fst_ints));
+                       my_cmd.output_data_len = 0;
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user(ifr->ifr_data, &my_cmd,
+                                             sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_RESET_STATS:
+                       memset(hdlc_stats(port->dev), 0,
+                              sizeof(struct fst_device_stats));
+                       my_cmd.output_data_len = 0;
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user(ifr->ifr_data, &my_cmd,
+                                             sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: could not get char data\n");
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_SET_READV:
+                       if (my_cmd.input_data_len > 0) {
+                               if (copy_from_user(&readv_mode,
+                                                  my_cmd.data_ptr, 1)) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not get readv_mode\n");
+                                       return -EFAULT;
+                               }
+                               fst_dbg(DBG_IOCTL,
+                                       "Setting readv mode to %d\n",
+                                       readv_mode);
+                               if ((readv_mode < FST_READV_NORMAL) ||
+                                   (readv_mode > FST_READV_SYNC2)) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: setting an invalid readv mode  %d\n",
+                                               readv_mode);
+                                       return -EFAULT;
+                               }
+                               my_cmd.output_data_len = 0;
+                               /* And invert the status field to show we
+                                * have done the command
+                                */
+                               my_cmd.status = ~my_cmd.status;
+                               if (port->compat == 1)
+                                       memcpy(ifr->ifr_data, &my_cmd,
+                                              sizeof(my_cmd));
+                               else if (copy_to_user
+                                        (ifr->ifr_data, &my_cmd,
+                                         sizeof(my_cmd))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy status back\n");
+                                       return -EFAULT;
+                               }
+                               port->readv_mode = readv_mode;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                               "(%s) Cannot copy readv_mode, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_SET_CHAR:
+                       if (my_cmd.input_data_len <=
+                           sizeof(struct fstioc_char_data)) {
+                               if (copy_from_user
+                                   (&char_data, my_cmd.data_ptr,
+                                    sizeof(struct fstioc_char_data))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not get char data\n");
+                                       return -EFAULT;
+                               }
+                               fst_dbg(DBG_IOCTL,
+                                       "Setting char data to %d %d\n",
+                                       char_data.queue_len,
+                                       char_data.threshold);
+                               port->char_inq_max_len = char_data.queue_len;
+                               port->char_inq_threshold = char_data.threshold;
+                               my_cmd.output_data_len = 0;
+                               /* And invert the status field to show we
+                                * have done the command
+                                */
+                               my_cmd.status = ~my_cmd.status;
+                               if (port->compat == 1)
+                                       memcpy(ifr->ifr_data, &my_cmd,
+                                              sizeof(my_cmd));
+                               else if (copy_to_user
+                                        (ifr->ifr_data, &my_cmd,
+                                         sizeof(my_cmd))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy status back\n");
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS,
+                               "(%s) Cannot copy char_data, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_SET_LATENCY:
+                       if (my_cmd.input_data_len >=
+                           sizeof(struct fstioc_latency_data)) {
+                               if (copy_from_user
+                                   (&latency_data, my_cmd.data_ptr,
+                                    sizeof(struct fstioc_latency_data))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not get latency data\n");
+                                       return -EFAULT;
+                               }
+                               fst_dbg(DBG_IOCTL,
+                                       "Setting latency data to %d %d %d\n",
+                                       latency_data.tx_size,
+                                       latency_data.rx_size,
+                                       latency_data.rate);
+                               if (latency_data.rx_size != 0) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: rx latency not yet supported\n");
+                                       return -EINVAL;
+
+                               }
+                               if (latency_data.rate == 0) {
+                                       fst_dbg(DBG_ASS,
+                                               "fstcmd: latency rate must be greater than zero\n");
+                                       return -EINVAL;
+
+                               }
+                               /* Save the values for when the port is openend
+                                * Which is when we will calculate the size
+                                * of the required buffer.
+                                */
+                               port->tx_latency = latency_data.tx_size;
+                               port->rx_latency = latency_data.rx_size;
+                               port->latency_rate = latency_data.rate;
+                               port->latency_reached = 0;
+                               port->rx_latency_buffer = NULL;
+                               port->tx_latency_buffer = NULL;
+                               my_cmd.output_data_len = 0;
+                               /* And invert the status field to show we
+                                * have done the command
+                                */
+                               my_cmd.status = ~my_cmd.status;
+                               if (port->compat == 1)
+                                       memcpy(ifr->ifr_data, &my_cmd,
+                                              sizeof(my_cmd));
+                               else if (copy_to_user
+                                        (ifr->ifr_data, &my_cmd,
+                                         sizeof(my_cmd))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy status back\n");
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "(%s) Cannot copy char_data, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       return 0;
+
+               case FSTCMD_UPDATE_CLOCK:
+                       if (my_cmd.input_data_len > 0) {
+                               if (copy_from_user(&speed,
+                                                  my_cmd.data_ptr,
+                                                  sizeof(int))) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: could not get speed setting\n");
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "(%s) Cannot copy speed setting, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       fst_dbg(DBG_IOCTL, "%s: Update clock speed to %d\n",
+                               port->dev->name, speed);
+                       FST_WRL(port->card,
+                               port_config[port->index].line_speed,
+                               speed);
+                       fst_issue_cmd(port, RECONFIGLINE);
+                       my_cmd.output_data_len = 0;
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user(ifr->ifr_data, &my_cmd,
+                                             sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
                        return 0;

-               case IF_GET_PROTO:
-                       if (port->mode == FST_RAW) {
-                               ifr->ifr_settings.type = IF_PROTO_RAW;
-                               return 0;
+               case FSTCMD_SET_CUSTOM_RATE:
+                       if (!FST_RDB(card, synth_ability)) {
+                               fst_dbg(DBG_ASS,
+                               "%s: custom clock rates not supported on this port\n",
+                                    port->dev->name);
+                               return -EIO;
                        }
-                       return hdlc_ioctl(dev, ifr, cmd);
+                       if (my_cmd.input_data_len >=
+                           (unsigned int)sizeof(struct
+                                                fstioc_custom_rate_config)) {
+                               if (copy_from_user(&custom_clock_rate,
+                                                  my_cmd.data_ptr,
+                                  sizeof(struct fstioc_custom_rate_config))) {
+                                       fst_dbg(DBG_ASS,
+                     "fstcmd: could not get custom rate config structure\n");
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS,
+       "(%s) Cannot copy custom_rate_config, data buffer too small %lu %u\n",
+                                    port->dev->name,
+                                    sizeof(struct fstioc_custom_rate_config),
+                                    my_cmd.input_data_len);
+
+                               return -EFAULT;
+                       }
+                       retval =
+                       parse_custom_clock_rate_structure(port,
+                                                     &custom_clock_rate);
+                       if (retval) {
+                               fst_dbg(DBG_ASS,
+                               "%s: Invalid custom_rate_config struct, %d\n",
+                                       port->dev->name, retval);
+                               return -EINVAL;
+                       }
+                       retval =
+                           set_custom_clock_rate(port, &custom_clock_rate);
+                       if (retval) {
+                               fst_dbg(DBG_ASS,
+                               "%s: Error in setting custom clock rate, %d\n",
+                                       port->dev->name, retval);
+                               return -EINVAL;
+                       }
+                       /* Everything worked
+                        */
+                       my_cmd.output_data_len = 0;
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user(ifr->ifr_data, &my_cmd,
+                                             sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       return 0;

                default:
-                       port->mode = FST_GEN_HDLC;
-                       dbg(DBG_IOCTL, "Passing this type to hdlc %x\n",
-                           ifr->ifr_settings.type);
-                       return hdlc_ioctl(dev, ifr, cmd);
+                       fst_dbg(DBG_ASS, "Unrecognised FST Command %d\n",
+                               my_cmd.command);
+                       return -EINVAL;
                }

        default:
@@ -2138,8 +8011,7 @@ fst_ioctl(struct net_device *dev, struct
        }
 }

-static void
-fst_openport(struct fst_port_info *port)
+static void fst_openport(struct fst_port_info *port)
 {
        int signals;
        int txq_length;
@@ -2147,290 +8019,540 @@ fst_openport(struct fst_port_info *port)
        /* Only init things if card is actually running. This allows open to
         * succeed for downloads etc.
         */
+       fst_dbg(DBG_OPEN, "Opening port %s\n", port->dev->name);
+       fst_dbg(DBG_OPEN, "Tx buffers = %d of size %d\n", port->num_tx_buffers,
+               port->tx_buffer_size);
+       fst_dbg(DBG_OPEN, "Rx buffers = %d of size %d\n", port->num_rx_buffers,
+               port->rx_buffer_size);
+
+       last_segment_cnt = 0;
+       /* The control information for the tx and rx fifo is in the normal
+        * shared memory window.  Initialise this structure next.
+        */
+       FST_WRW(port->card, dsl_control.bytes_to_send, 0);
+       FST_WRL(port->card, dsl_control.offset_atm_rx, DR_BASE);
+       FST_WRL(port->card, dsl_control.offset_atm_tx, DT_BASE);
        if (port->card->state == FST_RUNNING) {
                if (port->run) {
-                       dbg(DBG_OPEN, "open: found port already running\n");
-
-                       fst_issue_cmd(port, STOPPORT);
-                       port->run = 0;
+                       /* This is probably the case where the open is as a
+                        * result of the network device.  We shouldn't need
+                        * to do it again
+                        */
+                       fst_dbg(DBG_OPEN,
+                               "open: found port already running\n");
+               } else {
+                       fst_rx_config(port);
+                       fst_tx_config(port);
+                       port->run = 1;
+                       fst_op_raise(port, OPSTS_RTS | OPSTS_DTR);
+                       if (port->card->type == FST_TYPE_DSL_S1)
+                               atm_fifo_init(port->card);
+                       fst_issue_cmd(port, STARTPORT);
+                       if (!port->ignore_carrier) {
+                               signals =
+                                   FST_RDL(port->card,
+                                           v24DebouncedSts[port->index]);
+                               if (signals &
+                                   (((FST_RDW
+                                      (port->card,
+                                       port_config[port->
+                                                  index].line_interface) ==
+                                      X21)
+                                     ||
+                                     (FST_RDW
+                                      (port->card,
+                                       port_config[port->
+                                                  index].line_interface) ==
+                                      X21D))
+                                    ? IPSTS_INDICATE : IPSTS_DCD))
+                                       netif_carrier_on(port->dev);
+                               else
+                                       netif_carrier_off(port->dev);
+                       }
+                       txq_length = port->txqe - port->txqs;
+                       port->txqe = 0;
+                       port->txqs = 0;
+                       port->rxq.error_recovery = 0;
+                       port->char_inq = NULL;
+                       port->char_inq_end = NULL;
                }
-
-               fst_rx_config(port);
-               fst_tx_config(port);
-               fst_op_raise(port, OPSTS_RTS | OPSTS_DTR);
-
-               fst_issue_cmd(port, STARTPORT);
-               port->run = 1;
-
-               signals = FST_RDL(port->card, v24DebouncedSts[port->index]);
-               if (signals & (((port->hwif == X21) || (port->hwif == X21D))
-                              ? IPSTS_INDICATE : IPSTS_DCD))
-                       netif_carrier_on(port_to_dev(port));
-               else
-                       netif_carrier_off(port_to_dev(port));
-
-               txq_length = port->txqe - port->txqs;
-               port->txqe = 0;
-               port->txqs = 0;
        }
-
 }

-static void
-fst_closeport(struct fst_port_info *port)
+static void fst_closeport(struct fst_port_info *port)
 {
        if (port->card->state == FST_RUNNING) {
                if (port->run) {
-                       port->run = 0;
                        fst_op_lower(port, OPSTS_RTS | OPSTS_DTR);

                        fst_issue_cmd(port, STOPPORT);
+                       port->run = 0;
+                       if (port->mode == FST_MODE_ASYNC) {
+                               fst_reset_rx_fifo(port);
+                               fifo_reset(port->card, port->index);
+                       }
                } else {
-                       dbg(DBG_OPEN, "close: port not running\n");
+                       fst_dbg(DBG_OPEN, "close: port not running\n");
                }
+               purge_tx_queue(port->card, port);
        }
 }

-static int
-fst_open(struct net_device *dev)
+static int fst_open(struct net_device *dev)
 {
        int err;
        struct fst_port_info *port;
+       struct fst_card_info *card;

        port = dev_to_port(dev);
+       card = port->card;
+
+       if (card->state != FST_RUNNING) {
+               fst_dbg(DBG_ASS,
+                       "%s: Cannot open port if card is not loaded\n",
+                       dev->name);
+               return -ENODEV;
+       }
+       if ((port->run) && (port->char_file)) {
+               if (!port->monitor_mode) {
+                       fst_dbg(DBG_ASS, "%s: Port is already open\n",
+                               dev->name);
+                       return -EBUSY;
+               } else {
+                       fst_dbg(DBG_ASS,
+                       "%s: Opening network port to monitor char interface\n",
+                               dev->name);
+               }
+       }
+
        if (!try_module_get(THIS_MODULE))
-          return -EBUSY;
+               return -EBUSY;

-       if (port->mode != FST_RAW) {
+       if (port->proto != FST_RAW) {
                err = hdlc_open(dev);
-               if (err) {
-                       module_put(THIS_MODULE);
+               if (err)
                        return err;
-               }
        }
-
-       fst_openport(port);
+       if (!port->char_file)
+               fst_openport(port);
        netif_wake_queue(dev);
        return 0;
 }

-static int
-fst_close(struct net_device *dev)
+static int fst_close(struct net_device *dev)
 {
        struct fst_port_info *port;
        struct fst_card_info *card;
        unsigned char tx_dma_done;
        unsigned char rx_dma_done;
+       unsigned long flags;

        port = dev_to_port(dev);
        card = port->card;

+       netif_stop_queue(dev);
+       spin_lock_irqsave(&card->card_lock, flags);
+       if (!port->char_file) {
+               while (port->txqe != port->txqs) {
+                       fst_dbg(DBG_OPEN,
+                               "%s: Closing port with data in tx queue\n",
+                               dev->name);
+                       dev_kfree_skb(port->txq[port->txqs].frame);
+                       port->txq[port->txqs].frame = NULL;
+                       port->txqs++;
+                       if (port->txqs == FST_TXQ_DEPTH)
+                               port->txqs = 0;
+               }
+       }
+       spin_unlock_irqrestore(&card->card_lock, flags);
        tx_dma_done = inb(card->pci_conf + DMACSR1);
        rx_dma_done = inb(card->pci_conf + DMACSR0);
-       dbg(DBG_OPEN,
-           "Port Close: tx_dma_in_progress = %d (%x) rx_dma_in_progress = %d (%x)\n",
-           card->dmatx_in_progress, tx_dma_done, card->dmarx_in_progress,
-           rx_dma_done);
-
-       netif_stop_queue(dev);
-       fst_closeport(dev_to_port(dev));
-       if (port->mode != FST_RAW) {
-               hdlc_close(dev);
+       fst_dbg(DBG_OPEN,
+"Port Close: tx_dma_in_progress = %d (%x) rx_dma_in_progress = %d (%x)\n",
+               card->dmatx_in_progress, tx_dma_done, card->dmarx_in_progress,
+               rx_dma_done);
+
+       if (!port->char_file) {
+               /* Only close the port if really not in use */
+               fst_closeport(dev_to_port(dev));
        }
+       if (port->proto != FST_RAW)
+               hdlc_close(dev);
        module_put(THIS_MODULE);
        return 0;
 }

 static int
-fst_attach(struct net_device *dev, unsigned short encoding, unsigned short parity)
+fst_attach(struct net_device *dev, unsigned short encoding,
+          unsigned short parity)
 {
-       /*
-        * Setting currently fixed in FarSync card so we check and forget
+       /*Setting currently fixed in FarSync card so we check and forget
         */
        if (encoding != ENCODING_NRZ || parity != PARITY_CRC16_PR1_CCITT)
                return -EINVAL;
        return 0;
 }

-static void
-fst_tx_timeout(struct net_device *dev)
+static void fst_tx_timeout(struct net_device *dev)
 {
        struct fst_port_info *port;
        struct fst_card_info *card;
+       struct net_device_stats *stats = hdlc_stats(dev);

        port = dev_to_port(dev);
        card = port->card;
-       dev->stats.tx_errors++;
-       dev->stats.tx_aborted_errors++;
-       dbg(DBG_ASS, "Tx timeout card %d port %d\n",
-           card->card_no, port->index);
-       fst_issue_cmd(port, ABORTTX);
-
+       stats->tx_errors++;
+       stats->tx_aborted_errors++;
+       fst_dbg(DBG_ASS, "Tx timeout card %d port %d\n",
+               card->card_no, port->index);
+       purge_tx_queue(card, port);
        dev->trans_start = jiffies;
        netif_wake_queue(dev);
        port->start = 0;
 }

-static netdev_tx_t
-fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+       struct net_device_stats *stats = hdlc_stats(dev);
        struct fst_card_info *card;
        struct fst_port_info *port;
        unsigned long flags;
        int txq_length;
+       struct sk_buff *new_skb;
+       int count = 0;

        port = dev_to_port(dev);
        card = port->card;
-       dbg(DBG_TX, "fst_start_xmit: length = %d\n", skb->len);
+       fst_dbg(DBG_TX, "fst_start_xmit: length = %d\n", skb->len);

        /* Drop packet with error if we don't have carrier */
-       if (!netif_carrier_ok(dev)) {
+       if ((!netif_carrier_ok(dev)) && (!port->ignore_carrier)) {
                dev_kfree_skb(skb);
-               dev->stats.tx_errors++;
-               dev->stats.tx_carrier_errors++;
-               dbg(DBG_ASS,
-                   "Tried to transmit but no carrier on card %d port %d\n",
-                   card->card_no, port->index);
-               return NETDEV_TX_OK;
+               stats->tx_errors++;
+               stats->tx_carrier_errors++;
+               fst_dbg(DBG_ASS,
+               "%s: Tried to transmit but no carrier on card %d port %d\n",
+                       port_to_dev(port)->name, card->card_no, port->index);
+               /*
+                * Double check that the line is still down
+                */
+               fst_intr_ctlchg(card, port);
+               return 0;
        }

        /* Drop it if it's too big! MTU failure ? */
-       if (skb->len > LEN_TX_BUFFER) {
-               dbg(DBG_ASS, "Packet too large %d vs %d\n", skb->len,
-                   LEN_TX_BUFFER);
+       if (skb->len > FST_MAX_MTU) {
+               pr_err("Tx Packet too large %d vs %d\n", skb->len,
+                          FST_MAX_MTU);
                dev_kfree_skb(skb);
-               dev->stats.tx_errors++;
-               return NETDEV_TX_OK;
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               return 0;
        }

-       /*
-        * We are always going to queue the packet
+       /* Drop it if it's bigger than the tx_buffer_size */
+       if (skb->len > port->tx_buffer_size) {
+               pr_err("Tx Packet too large %d vs buffer %d\n", skb->len,
+                          port->tx_buffer_size);
+               dev_kfree_skb(skb);
+               port->stats.tx_errors++;
+               port->stats.tx_dropped++;
+               return 0;
+       }
+
+       /* Drop it if port not running */
+       if (!port->run) {
+               pr_err("Tx When port closed\n");
+               dev_kfree_skb(skb);
+               port->stats.tx_errors++;
+               port->stats.tx_dropped++;
+               return 0;
+       }
+
+       count = skb->len;
+       /* Drop it if it is too small */
+       if (skb->len <= 0) {
+               fst_dbg(DBG_ASS, "fst_start_xmit: packet too small %d\n",
+                       skb->len);
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               return 0;
+       }
+       if (skb->len == 0)
+               pr_info("Transmitting a zero length frame\n");
+
+       /* We are always going to queue the packet
         * so that the bottom half is the only place we tx from
         * Check there is room in the port txq
         */
        spin_lock_irqsave(&card->card_lock, flags);
        if ((txq_length = port->txqe - port->txqs) < 0) {
-               /*
-                * This is the case where the next free has wrapped but the
+               /* This is the case where the next free has wrapped but the
                 * last used hasn't
                 */
                txq_length = txq_length + FST_TXQ_DEPTH;
        }
        spin_unlock_irqrestore(&card->card_lock, flags);
-       if (txq_length > fst_txq_high) {
-               /*
-                * We have got enough buffers in the pipeline.  Ask the network
+       if (txq_length >= fst_txq_high) {
+               /* We have got enough buffers in the pipeline.  Ask the network
                 * layer to stop sending frames down
                 */
-               netif_stop_queue(dev);
-               port->start = 1;        /* I'm using this to signal stop sent up */
+               port->start = 1;    /* I'm using this to signal stop sent up */
+               if (!port->char_file) {
+                       fst_dbg(DBG_ASS, "%s: Stop the network layer\n",
+                               dev->name);
+                       netif_stop_queue(dev);
+               } else {
+                       /* If the char interface say we can't do it at all
+                        */
+                       dev_kfree_skb(skb);
+                       return 0;
+               }
        }
-
        if (txq_length == FST_TXQ_DEPTH - 1) {
-               /*
-                * This shouldn't have happened but such is life
+               /* This shouldn't have happened but such is life
                 */
                dev_kfree_skb(skb);
-               dev->stats.tx_errors++;
-               dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",
-                   card->card_no, port->index);
-               return NETDEV_TX_OK;
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               fst_dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",
+                       card->card_no, port->index);
+               return 0;
        }

        /*
         * queue the buffer
         */
+       if ((port->vpi == 0) && (port->vci == 0)) {
+               /* No ATM encapsulation required so no new skb is
+                * allocated.  Just update the pointer of new_skb
+                */
+               new_skb = skb;
+       } else {
+               new_skb = generate_pdu(port, skb);
+               kfree_skb(skb);
+       }
+       if (new_skb == NULL) {
+               fst_dbg(DBG_ASS, "Error in queuing atm pdu\n");
+               return 0;
+       }
+       if (port->monitor_mode)
+               gen_mon_packet(new_skb, port, FST_MON_TX);
        spin_lock_irqsave(&card->card_lock, flags);
-       port->txq[port->txqe] = skb;
+       port->txq[port->txqe].frame = new_skb;
+       port->txq[port->txqe].count = new_skb->len;
+       port->txq[port->txqe].segment_cnt =
+           ((new_skb->len - 1) / port->tx_buffer_size) + 1;
+       port->txq[port->txqe].current_seg = 0;
+       port->txq[port->txqe].flags = 0;
        port->txqe++;
        if (port->txqe == FST_TXQ_DEPTH)
                port->txqe = 0;
        spin_unlock_irqrestore(&card->card_lock, flags);
+       /* Note that after this point we could get an interrupt and the
+        * skb we are currenyl post processing could have been taken
+        * off the queue and dealt with.  So don't refer to it anymore
+        */

        /* Scehdule the bottom half which now does transmit processing */
        fst_q_work_item(&fst_work_txq, card->card_no);
        tasklet_schedule(&fst_tx_task);
-
-       return NETDEV_TX_OK;
+       if (port->char_file)
+               return count;
+       else
+               return 0;
 }

-/*
- *      Card setup having checked hardware resources.
+static const struct net_device_ops fst_ops = {
+       .ndo_open = fst_open,
+       .ndo_stop = fst_close,
+       .ndo_change_mtu = hdlc_change_mtu,
+       .ndo_start_xmit = hdlc_start_xmit,
+       .ndo_do_ioctl = fst_ioctl,
+       .ndo_tx_timeout = fst_tx_timeout,
+};
+
+/*      Card setup having checked hardware resources.
  *      Should be pretty bizarre if we get an error here (kernel memory
  *      exhaustion is one possibility). If we do see a problem we report it
  *      via a printk and leave the corresponding interface and all that follow
  *      disabled.
  */
-static char *type_strings[] = {
-       "no hardware",          /* Should never be seen */
-       "FarSync T2P",
-       "FarSync T4P",
-       "FarSync T1U",
-       "FarSync T2U",
-       "FarSync T4U",
-       "FarSync TE1"
-};

-static void
-fst_init_card(struct fst_card_info *card)
+static void fst_init_card(struct fst_card_info *card)
 {
-       int i;
+       int i, j;
        int err;
+       struct fst_port_info *port;
+       char char_dev_name[16];
+       struct device *tty_device = NULL;

        /* We're working on a number of ports based on the card ID. If the
         * firmware detects something different later (should never happen)
         * we'll have to revise it in some way then.
         */
+       extract_serial(card);
+       init_waitqueue_head(&card->cmdfifo_waitq);
        for (i = 0; i < card->nports; i++) {
-                err = register_hdlc_device(card->ports[i].dev);
-                if (err < 0) {
+               struct net_device *dev;
+               hdlc_device *hdlc;
+
+               /* Assign the minor device number */
+               for (j = 0; j < FST_MAX_CARDS * FST_MAX_PORTS; j++) {
+                       if (fst_ports_list[j] == NULL) {
+                               fst_minor = j;
+                               break;
+                       }
+               }
+               card->ports[i] = kmalloc(sizeof(struct fst_port_info),
+                                        GFP_KERNEL);
+               if (card->ports[i] == NULL) {
+                       pr_err("FarSync card found but insufficient memory ");
+                       pr_err("for driver device storage\n");
+                       return;
+               }
+               port = card->ports[i];
+               memset(port, 0, sizeof(struct fst_port_info));
+               dev = alloc_hdlcdev(port);
+
+               dev->netdev_ops = &fst_ops;
+               SET_NETDEV_DEV(dev, &card->device->dev);
+               err = register_hdlc_device(dev);
+               if (err < 0) {
                        int j;
-                       pr_err("Cannot register HDLC device for port %d (errno %d)\n",
-                              i, -err);
+                       pr_err("Cannot register HDLC device for port %d", i);
+                       pr_err(" (errno %d)\n", -err);
                        for (j = i; j < card->nports; j++) {
-                               free_netdev(card->ports[j].dev);
-                               card->ports[j].dev = NULL;
+                               free_netdev(card->ports[j]->dev);
+                               kfree(card->ports[j]);
+                               card->ports[j]->dev = NULL;
                        }
-                        card->nports = i;
-                        break;
-                }
+                       card->nports = i;
+                       break;
+               }
+               port->dev = dev;
+               port->card = card;
+               port->index = i;
+               port->run = 0;
+               port->proto = FST_GEN_HDLC;
+               port->num_tx_buffers = REQUIRED_TX_BUFFERS;
+               port->num_rx_buffers = REQUIRED_RX_BUFFERS;
+               port->tx_buffer_size = REQUIRED_TX_BUFFER_SIZE;
+               port->rx_buffer_size = REQUIRED_RX_BUFFER_SIZE;
+               port->fstioc_info_ver = fst_iocinfo_version;
+               port->char_file = NULL;
+               port->char_inq = NULL;
+               port->char_inq_end = NULL;
+               port->minor_dev_no = fst_minor;
+               spin_lock_init(&port->rxf_lock);
+               init_waitqueue_head(&port->pollq);
+               init_waitqueue_head(&port->readq);
+               init_waitqueue_head(&port->writeq);
+               fst_ports_list[fst_minor] = port;
+               hdlc = dev_to_hdlc(dev);
+               if (fst_alloc_rx_fifo(port)) {
+                       pr_err("%s: Cannot allocate rx fifo\n",
+                                  port->dev->name);
+                       kfree(dev);
+                       card->nports = i;
+                       break;
+               }
+               /* Fill in the net device info
+                * Since this is a PCI setup this is purely
+                * informational. Give them the buffer addresses
+                * and basic card I/O.
+                */
+               dev->mem_start = card->phys_mem + BUF_OFFSET(tx_buffer[i][0]);
+               dev->mem_end = card->phys_mem
+                   + BUF_OFFSET(tx_buffer[i][0]) +
+                   (port->num_tx_buffers * port->tx_buffer_size);
+               dev->base_addr = card->pci_conf;
+               dev->irq = card->irq;
+               dev->tx_queue_len = FST_TX_QUEUE_LEN;
+               dev->addr_len = 8;
+               strcpy(dev->dev_addr, serial);
+               dev->watchdog_timeo = FST_TX_TIMEOUT;
+               hdlc->attach = fst_attach;
+               hdlc->xmit = fst_start_xmit;
+
+               sscanf(&port_to_dev(port)->name[4], "%d", &fst_minor);
+               fst_dbg(DBG_ASS, "fst_major is %x: fst_minor is %d\n",
+                       fst_major, fst_minor);
+               fst_dbg(DBG_INIT, "Register the tty device %d\n", fst_minor);
+               tty_port_init(&fst_tty_area[fst_minor].tty_port);
+               tty_device =
+                   tty_port_register_device(&fst_tty_area[fst_minor].tty_port,
+                                            serial_drv, fst_minor, NULL);
+
+               fst_tty_area[fst_minor].tty_port.tty =
+                   fst_tty_area[fst_minor].tty;
+               strcpy(char_dev_name, "");
+               strcat(char_dev_name, port_to_dev(port)->name);
+
+               if (device_create(farsync_class, NULL,
+                                 MKDEV(fst_major, fst_minor), NULL,
+                                 char_dev_name, fst_minor) < 0) {
+                       pr_err("Cannot create udev entry for %s\n",
+                                  port_to_dev(port)->name);
+               }
+               /* Set the basic async parameters
+                */
+               init_async_parameters(port, 8, COM_STOP_BITS_1,
+                                     COM_NO_PARITY, COM_FLOW_CONTROL_NONE);
        }

-       pr_info("%s-%s: %s IRQ%d, %d ports\n",
-               port_to_dev(&card->ports[0])->name,
-               port_to_dev(&card->ports[card->nports - 1])->name,
-               type_strings[card->type], card->irq, card->nports);
-}
+       spin_lock_init(&card->card_lock);
+       spin_lock_init(&card->fifo_lock);
+       init_waitqueue_head(&card->fifo_waitq);
+
+       pr_info("%s-%s: (%s) %s IRQ%d, %d ports\n",
+              port_to_dev(card->ports[0])->name,
+              port_to_dev(card->ports[card->nports - 1])->name,
+              serial, type_strings[card->type], card->irq, card->nports);

-static const struct net_device_ops fst_ops = {
-       .ndo_open       = fst_open,
-       .ndo_stop       = fst_close,
-       .ndo_change_mtu = hdlc_change_mtu,
-       .ndo_start_xmit = hdlc_start_xmit,
-       .ndo_do_ioctl   = fst_ioctl,
-       .ndo_tx_timeout = fst_tx_timeout,
-};
+       if (card->family == FST_FAMILY_TXU) {
+               /* Allocate a dma buffer for transmit and receives
+                */
+               card->rx_dma_handle_host =
+                   pci_alloc_consistent(card->device, MAX_LEN_RX_BUFFER,
+                                        &card->rx_dma_handle_card);
+               if (card->rx_dma_handle_host == NULL) {
+                       pr_err("Could not allocate rx dma buffer\n");
+                       return;
+               }
+               card->tx_dma_handle_host =
+                   pci_alloc_consistent(card->device, MAX_LEN_TX_BUFFER,
+                                        &card->tx_dma_handle_card);
+               if (card->tx_dma_handle_host == NULL) {
+                       pr_err("Could not allocate tx dma buffer\n");
+                       return;
+               }
+       }
+}

-/*
- *      Initialise card when detected.
+/*      Initialise card when detected.
  *      Returns 0 to indicate success, or errno otherwise.
  */
-static int
-fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-       static int no_of_cards_added = 0;
+       static int firsttime_done;
        struct fst_card_info *card;
        int err = 0;
        int i;

-       printk_once(KERN_INFO
-                   pr_fmt("FarSync WAN driver " FST_USER_VERSION
-                          " (c) 2001-2004 FarSite Communications Ltd.\n"));
+       if (!firsttime_done) {
+               pr_info("FarSync WAN driver " FST_USER_VERSION
+                      "-" FST_PATCH_LEVEL "-" FST_PLATFORM FST_ADDITIONAL
+                      " (c) 2001-2012 FarSite Communications Ltd.\n");
+               firsttime_done = 1;
 #if FST_DEBUG
-       dbg(DBG_ASS, "The value of debug mask is %x\n", fst_debug_mask);
+               fst_dbg(DBG_ASS, "The value of debug mask is %x\n",
+                       fst_debug_mask);
 #endif
-       /*
-        * We are going to be clever and allow certain cards not to be
+       }
+
+       /* We are going to be clever and allow certain cards not to be
         * configured.  An exclude list can be provided in /etc/modules.conf
         */
        if (fst_excluded_cards != 0) {
@@ -2440,7 +8562,8 @@ fst_add_one(struct pci_dev *pdev, const
                 */
                for (i = 0; i < fst_excluded_cards; i++) {
                        if ((pdev->devfn) >> 3 == fst_excluded_list[i]) {
-                               pr_info("FarSync PCI device %d not assigned\n",
+                               fst_dbg(DBG_ASS,
+                                       "FarSync PCI device %d not assigned\n",
                                        (pdev->devfn) >> 3);
                                return -EBUSY;
                        }
@@ -2448,119 +8571,96 @@ fst_add_one(struct pci_dev *pdev, const
        }

        /* Allocate driver private data */
-       card = kzalloc(sizeof(struct fst_card_info), GFP_KERNEL);
-       if (card == NULL)
+       card = kmalloc(sizeof(struct fst_card_info), GFP_KERNEL);
+       if (card == NULL) {
+               pr_err("FarSync card found but insufficient memory for");
+               pr_err(" driver storage\n");
                return -ENOMEM;
+       }
+       memset(card, 0, sizeof(struct fst_card_info));

        /* Try to enable the device */
        if ((err = pci_enable_device(pdev)) != 0) {
                pr_err("Failed to enable card. Err %d\n", -err);
-               kfree(card);
-               return err;
-       }
-
-       if ((err = pci_request_regions(pdev, "FarSync")) !=0) {
-               pr_err("Failed to allocate regions. Err %d\n", -err);
-               pci_disable_device(pdev);
-               kfree(card);
-               return err;
+               goto error_free_card;
        }

-       /* Get virtual addresses of memory regions */
+       /* Record info we need */
+       card->irq = pdev->irq;
        card->pci_conf = pci_resource_start(pdev, 1);
        card->phys_mem = pci_resource_start(pdev, 2);
        card->phys_ctlmem = pci_resource_start(pdev, 3);
-       if ((card->mem = ioremap(card->phys_mem, FST_MEMSIZE)) == NULL) {
-               pr_err("Physical memory remap failed\n");
-               pci_release_regions(pdev);
-               pci_disable_device(pdev);
-               kfree(card);
-               return -ENODEV;
-       }
-       if ((card->ctlmem = ioremap(card->phys_ctlmem, 0x10)) == NULL) {
-               pr_err("Control memory remap failed\n");
-               pci_release_regions(pdev);
-               pci_disable_device(pdev);
-               iounmap(card->mem);
-               kfree(card);
-               return -ENODEV;
-       }
-       dbg(DBG_PCI, "kernel mem %p, ctlmem %p\n", card->mem, card->ctlmem);
-
-       /* Register the interrupt handler */
-       if (request_irq(pdev->irq, fst_intr, IRQF_SHARED, FST_DEV_NAME, card)) {
-               pr_err("Unable to register interrupt %d\n", card->irq);
-               pci_release_regions(pdev);
-               pci_disable_device(pdev);
-               iounmap(card->ctlmem);
-               iounmap(card->mem);
-               kfree(card);
-               return -ENODEV;
-       }

-       /* Record info we need */
-       card->irq = pdev->irq;
        card->type = ent->driver_data;
        card->family = ((ent->driver_data == FST_TYPE_T2P) ||
                        (ent->driver_data == FST_TYPE_T4P))
            ? FST_FAMILY_TXP : FST_FAMILY_TXU;
        if ((ent->driver_data == FST_TYPE_T1U) ||
-           (ent->driver_data == FST_TYPE_TE1))
+           (ent->driver_data == FST_TYPE_TE1) ||
+           (ent->driver_data == FST_TYPE_TE1e) ||
+           (ent->driver_data == FST_TYPE_DSL_S1))
                card->nports = 1;
        else
                card->nports = ((ent->driver_data == FST_TYPE_T2P) ||
-                               (ent->driver_data == FST_TYPE_T2U)) ? 2 : 4;
+                               (ent->driver_data == FST_TYPE_T2U) ||
+                               (ent->driver_data == FST_TYPE_T2U_PMC) ||
+                               (ent->driver_data == FST_TYPE_T2Ee) ||
+                               (ent->driver_data == FST_TYPE_T2UE)) ? 2 : 4;

        card->state = FST_UNINIT;
-        spin_lock_init ( &card->card_lock );
-
-        for ( i = 0 ; i < card->nports ; i++ ) {
-               struct net_device *dev = alloc_hdlcdev(&card->ports[i]);
-               hdlc_device *hdlc;
-               if (!dev) {
-                       while (i--)
-                               free_netdev(card->ports[i].dev);
-                       pr_err("FarSync: out of memory\n");
-                        free_irq(card->irq, card);
-                        pci_release_regions(pdev);
-                        pci_disable_device(pdev);
-                        iounmap(card->ctlmem);
-                        iounmap(card->mem);
-                        kfree(card);
-                        return -ENODEV;
-               }
-               card->ports[i].dev    = dev;
-                card->ports[i].card   = card;
-                card->ports[i].index  = i;
-                card->ports[i].run    = 0;
-
-               hdlc = dev_to_hdlc(dev);
+       card->device = pdev;

-                /* Fill in the net device info */
-               /* Since this is a PCI setup this is purely
-                * informational. Give them the buffer addresses
-                * and basic card I/O.
-                */
-                dev->mem_start   = card->phys_mem
-                                 + BUF_OFFSET ( txBuffer[i][0][0]);
-                dev->mem_end     = card->phys_mem
-                                 + BUF_OFFSET ( txBuffer[i][NUM_TX_BUFFER][0]);
-                dev->base_addr   = card->pci_conf;
-                dev->irq         = card->irq;
+       fst_dbg(DBG_PCI, "type %d nports %d irq %d\n", card->type,
+               card->nports, card->irq);
+       fst_dbg(DBG_PCI, "conf %04x mem %08x ctlmem %08x\n",
+               card->pci_conf, card->phys_mem, card->phys_ctlmem);

-               dev->netdev_ops = &fst_ops;
-               dev->tx_queue_len = FST_TX_QUEUE_LEN;
-               dev->watchdog_timeo = FST_TX_TIMEOUT;
-                hdlc->attach = fst_attach;
-                hdlc->xmit   = fst_start_xmit;
+       /* Check we can get access to the memory and I/O regions */
+       if (card->family == FST_FAMILY_TXU) {
+               if (!request_region
+                   (card->pci_conf, 0x100, "PLX 9054 config regs")) {
+                       pr_err("Unable to get config I/O @ 0x%04X\n",
+                                  card->pci_conf);
+                       err = -ENODEV;
+                       goto error_free_card;
+               }
+       } else {
+               if (!request_region
+                   (card->pci_conf, 0x80, "PLX 9050/2 config regs")) {
+                       pr_err("Unable to get config I/O @ 0x%04X\n",
+                                  card->pci_conf);
+                       err = -ENODEV;
+                       goto error_free_card;
+               }
+       }
+       if (!request_mem_region(card->phys_mem, FST_MEMSIZE, "Shared RAM")) {
+               pr_err("Unable to get main memory @ 0x%08X\n",
+                          card->phys_mem);
+               err = -ENODEV;
+               goto error_release_io;
+       }
+       if (!request_mem_region(card->phys_ctlmem, 0x10, "Control memory")) {
+               pr_err("Unable to get control memory @ 0x%08X\n",
+                          card->phys_ctlmem);
+               err = -ENODEV;
+               goto error_release_mem;
        }

-       card->device = pdev;
-
-       dbg(DBG_PCI, "type %d nports %d irq %d\n", card->type,
-           card->nports, card->irq);
-       dbg(DBG_PCI, "conf %04x mem %08x ctlmem %08x\n",
-           card->pci_conf, card->phys_mem, card->phys_ctlmem);
+       /* Get virtual addresses of memory regions */
+       card->mem = ioremap(card->phys_mem, FST_MEMSIZE);
+       if (card->mem == NULL) {
+               pr_err("Physical memory remap failed\n");
+               err = -ENODEV;
+               goto error_release_ctlmem;
+       }
+       card->ctlmem = ioremap(card->phys_ctlmem, 0x10);
+       if (card->ctlmem == NULL) {
+               pr_err("Control memory remap failed\n");
+               err = -ENODEV;
+               goto error_unmap_mem;
+       }
+       fst_dbg(DBG_PCI, "kernel mem %p, ctlmem %p\n",
+               card->mem, card->ctlmem);

        /* Reset the card's processor */
        fst_cpureset(card);
@@ -2569,108 +8669,179 @@ fst_add_one(struct pci_dev *pdev, const
        /* Initialise DMA (if required) */
        fst_init_dma(card);

+       /* Register the interrupt handler */
+       if (request_irq(card->irq, fst_intr, IRQF_SHARED, FST_DEV_NAME,
+                       card)) {
+               pr_err("Unable to register interrupt %d\n", card->irq);
+               err = -ENODEV;
+               goto error_unmap_ctlmem;
+       }
+
        /* Record driver data for later use */
        pci_set_drvdata(pdev, card);
+       if (!pci_dma_supported(pdev, 0xffffffff))
+               pr_info("Can't do DMA on this device\n");

        /* Remainder of card setup */
-       fst_card_array[no_of_cards_added] = card;
-       card->card_no = no_of_cards_added++;    /* Record instance and bump it */
+       fifo_init(card);
+       if (card->type == FST_TYPE_DSL_S1)
+               atm_fifo_init(card);
+       fst_cards_list[fst_ncards] = card;
+       card->card_no = fst_ncards++;   /* Record instance and bump it */
+       card->fifo_complete = 1;
        fst_init_card(card);
-       if (card->family == FST_FAMILY_TXU) {
-               /*
-                * Allocate a dma buffer for transmit and receives
-                */
-               card->rx_dma_handle_host =
-                   pci_alloc_consistent(card->device, FST_MAX_MTU,
-                                        &card->rx_dma_handle_card);
-               if (card->rx_dma_handle_host == NULL) {
-                       pr_err("Could not allocate rx dma buffer\n");
-                       fst_disable_intr(card);
-                       pci_release_regions(pdev);
-                       pci_disable_device(pdev);
-                       iounmap(card->ctlmem);
-                       iounmap(card->mem);
-                       kfree(card);
-                       return -ENOMEM;
-               }
-               card->tx_dma_handle_host =
-                   pci_alloc_consistent(card->device, FST_MAX_MTU,
-                                        &card->tx_dma_handle_card);
-               if (card->tx_dma_handle_host == NULL) {
-                       pr_err("Could not allocate tx dma buffer\n");
-                       fst_disable_intr(card);
-                       pci_release_regions(pdev);
-                       pci_disable_device(pdev);
-                       iounmap(card->ctlmem);
-                       iounmap(card->mem);
-                       kfree(card);
-                       return -ENOMEM;
-               }
-       }
+
        return 0;               /* Success */
+
+       /* Failure. Release resources */
+error_unmap_ctlmem:
+       iounmap(card->ctlmem);
+
+error_unmap_mem:
+       iounmap(card->mem);
+
+error_release_ctlmem:
+       release_mem_region(card->phys_ctlmem, 0x10);
+
+error_release_mem:
+       release_mem_region(card->phys_mem, FST_MEMSIZE);
+
+error_release_io:
+       release_region(card->pci_conf, 0x80);
+
+error_free_card:
+       kfree(card);
+       return err;
 }

-/*
- *      Cleanup and close down a card
+/*      Cleanup and close down a card
  */
-static void
-fst_remove_one(struct pci_dev *pdev)
+static void fst_remove_one(struct pci_dev *pdev)
 {
        struct fst_card_info *card;
        int i;

        card = pci_get_drvdata(pdev);
+       fst_disable_intr(card);
+       free_irq(card->irq, card);

        for (i = 0; i < card->nports; i++) {
-               struct net_device *dev = port_to_dev(&card->ports[i]);
+               struct net_device *dev = port_to_dev(card->ports[i]);
+               sscanf(&port_to_dev(card->ports[i])->name[4], "%d",
+                      &fst_minor);
+               fst_tty_area[fst_minor].state = FST_TTY_ST_DISC;
+               fst_dbg(DBG_ASS, "Calling tty unregister device for port %d\n",
+                      fst_minor);
+               tty_port_destroy(&fst_tty_area[fst_minor].tty_port);
+               tty_unregister_device(serial_drv, fst_minor);
+               if (card->ports[i]->fifo_rxdata) {
+                       /*
+                        * Deallocate the rx fifo
+                        */
+                       u16 used_space;
+                       used_space =
+                           (u16) ((card->ports[i]->fifo_rxdata->write_idx -
+                                   card->ports[i]->fifo_rxdata->read_idx)
+                                  % card->ports[i]->fifo_rxdata->fifo_length);
+                       fst_dbg(DBG_ASS, "%s: Releasing Fifo memory at %p\n",
+                               card->ports[i]->dev->name,
+                               card->ports[i]->fifo_rxdata);
+                       fst_dbg(DBG_ASS, "%s: %d bytes left in fifo\n",
+                               card->ports[i]->dev->name, used_space);
+                       kfree(card->ports[i]->fifo_rxdata);
+                       card->ports[i]->fifo_rxdata = NULL;
+               }
                unregister_hdlc_device(dev);
+               fst_ports_list[card->ports[i]->minor_dev_no] = NULL;
+               device_destroy(farsync_class, MKDEV(fst_major, fst_minor));
+               kfree(card->ports[i]);
        }

-       fst_disable_intr(card);
-       free_irq(card->irq, card);
-
        iounmap(card->ctlmem);
        iounmap(card->mem);
-       pci_release_regions(pdev);
+
+       release_mem_region(card->phys_ctlmem, 0x10);
+       release_mem_region(card->phys_mem, FST_MEMSIZE);
        if (card->family == FST_FAMILY_TXU) {
-               /*
-                * Free dma buffers
+               release_region(card->pci_conf, 0x100);
+       } else {
+               release_region(card->pci_conf, 0x80);
+       }
+
+       if (card->family == FST_FAMILY_TXU) {
+               /* Free dma buffers
                 */
-               pci_free_consistent(card->device, FST_MAX_MTU,
+               pci_free_consistent(card->device, MAX_LEN_RX_BUFFER,
                                    card->rx_dma_handle_host,
                                    card->rx_dma_handle_card);
-               pci_free_consistent(card->device, FST_MAX_MTU,
+               pci_free_consistent(card->device, MAX_LEN_TX_BUFFER,
                                    card->tx_dma_handle_host,
                                    card->tx_dma_handle_card);
        }
-       fst_card_array[card->card_no] = NULL;
+       fst_cards_list[card->card_no] = NULL;
+       fst_cpureset(card);
+       kfree(card);
 }

 static struct pci_driver fst_driver = {
-        .name          = FST_NAME,
-        .id_table      = fst_pci_dev_id,
-        .probe         = fst_add_one,
-        .remove        = fst_remove_one,
-        .suspend       = NULL,
-        .resume        = NULL,
+name: FST_NAME,
+id_table : fst_pci_dev_id,
+probe : fst_add_one,
+remove : fst_remove_one,
+suspend : NULL,
+resume : NULL,
+};
+
+static int farsync_proc_open(struct inode *inode, struct file *file)
+{
+       return single_open(file, fst_proc_info, NULL);
+}
+
+static const struct file_operations farsync_proc_fops = {
+       .open = farsync_proc_open,
+       .read = seq_read,
+       .llseek = seq_lseek,
+       .release = single_release,
 };

-static int __init
-fst_init(void)
+static int __init fst_init(void)
 {
        int i;

+       INIT_WORK(&fst_rx_work, fst_process_rx_work_q);
        for (i = 0; i < FST_MAX_CARDS; i++)
-               fst_card_array[i] = NULL;
+               fst_cards_list[i] = NULL;
+       for (i = 0; i < FST_MAX_CARDS * FST_MAX_PORTS; i++)
+               fst_ports_list[i] = NULL;
        spin_lock_init(&fst_work_q_lock);
-       return pci_register_driver(&fst_driver);
+       fst_dbg(DBG_ASS, "Creating the device class for farsync\n");
+       farsync_class = class_create(THIS_MODULE, "farsync");
+       /* Register the char driver */
+       fst_tty_init();
+       fst_major = FST_TTY_MAJOR;
+       /*
+        * Create the /proc entry for /proc/farsync
+        */
+       i = pci_register_driver(&fst_driver);
+       if (i == -ENODEV)
+               pr_err("No farsync devices found\n");
+       /* Always stay loaded even if no devices
+        */
+       proc_create("farsync", 0, NULL, &farsync_proc_fops);
+       pr_info("fst_min_dma_len set to %d\n", fst_min_dma_len);
+       pr_info("fst_dmathr set to %x\n", fst_dmathr);
+       pr_info("fst_iocinfo_version set to %d\n", fst_iocinfo_version);
+       return 0;
 }

-static void __exit
-fst_cleanup_module(void)
+static void __exit fst_cleanup_module(void)
 {
-       pr_info("FarSync WAN driver unloading\n");
        pci_unregister_driver(&fst_driver);
+       /* Remove the char device driver entry */
+       fst_tty_uninit();
+       remove_proc_entry("farsync", NULL);
+       class_destroy(farsync_class);
+       pr_info("Unloading module farsync\n");
 }

 module_init(fst_init);
