From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 004/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:12:10 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA3@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 4 of 7
Note that this patch must be applied with patch 5 (farsync_driver_patch)

Update the existing farsync.h file for the new features of the farsync and
flex drivers.

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---
diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/farsync.h linux-3.10.1_new/drivers/net/wan/farsync.h
--- linux-3.10.1/drivers/net/wan/farsync.h      2013-07-13 19:42:41.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/farsync.h  2013-09-16 16:30:06.483104880 +0100
@@ -1,17 +1,15 @@
 /*
- *      FarSync X21 driver for Linux
+ *      FarSync driver for Linux
  *
- *      Actually sync driver for X.21, V.35 and V.24 on FarSync T-series cards
- *
- *      Copyright (C) 2001 FarSite Communications Ltd.
- *      www.farsite.co.uk
+ *      Copyright (C) 2001-2013 FarSite Communications Ltd.
+ *      www.farsite.com
  *
  *      This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
  *
- *      Author: R.J.Dunlop      <bob.dunlop@farsite.co.uk>
+ *      Author: R.J.Dunlop      <bob.dunlop@farsite.com>
  *
  *      For the most part this file only contains structures and information
  *      that is visible to applications outside the driver. Shared memory
@@ -21,26 +19,9 @@
  *      this file may not be changed arbitrarily.
  */

-/*      What's in a name
- *
- *      The project name for this driver is Oscar. The driver is intended to be
- *      used with the FarSite T-Series cards (T2P & T4P) running in the high
- *      speed frame shifter mode. This is sometimes referred to as X.21 mode
- *      which is a complete misnomer as the card continues to support V.24 and
- *      V.35 as well as X.21.
- *
- *      A short common prefix is useful for routines within the driver to avoid
- *      conflict with other similar drivers and I chosen to use "fst_" for this
- *      purpose (FarSite T-series).
- *
- *      Finally the device driver needs a short network interface name. Since
- *      "hdlc" is already in use I've chosen the even less informative "sync"
- *      for the present.
- */
-#define FST_NAME                "fst"           /* In debug/info etc */
-#define FST_NDEV_NAME           "sync"          /* For net interface */
-#define FST_DEV_NAME            "farsync"       /* For misc interfaces */
-
+#define FST_NAME                "fst"  /* In debug/info etc */
+#define FST_NDEV_NAME           "sync" /* For net interface */
+#define FST_DEV_NAME            "farsync"      /* For misc interfaces */

 /*      User version number
  *
@@ -50,34 +31,119 @@
  *      have individual versions (or IDs) that move much faster than the
  *      the release version as individual updates are tracked.
  */
-#define FST_USER_VERSION        "1.04"
+#define FST_USER_VERSION        "2.1.7"
+#define FST_PATCH_LEVEL         "00"
+#ifdef __x86_64__
+#define FST_PLATFORM            "64bit"
+#else
+#define FST_PLATFORM            "32bit"
+#endif
+#define FST_ADDITIONAL          FST_BUILD_NO
+
+#define FST_INCLUDES_CHAR
+
+struct fst_device_stats {
+       unsigned long rx_packets;       /* total packets received       */
+       unsigned long tx_packets;       /* total packets transmitted    */
+       unsigned long rx_bytes; /* total bytes received         */
+       unsigned long tx_bytes; /* total bytes transmitted      */
+       unsigned long rx_errors;        /* bad packets received         */
+       unsigned long tx_errors;        /* packet transmit problems     */
+       unsigned long rx_dropped;       /* no space in linux buffers    */
+       unsigned long tx_dropped;       /* no space available in linux  */
+       unsigned long multicast;        /* multicast packets received   */
+       unsigned long collisions;
+
+       /* detailed rx_errors: */
+       unsigned long rx_length_errors;
+       unsigned long rx_over_errors;   /* receiver ring buff overflow  */
+       unsigned long rx_crc_errors;    /* recved pkt with crc error    */
+       unsigned long rx_frame_errors;  /* recv'd frame alignment error */
+       unsigned long rx_fifo_errors;   /* recv'r fifo overrun          */
+       unsigned long rx_missed_errors; /* receiver missed packet       */
+
+       /* detailed tx_errors */
+       unsigned long tx_aborted_errors;
+       unsigned long tx_carrier_errors;
+       unsigned long tx_fifo_errors;
+       unsigned long tx_heartbeat_errors;
+       unsigned long tx_underrun_errors;
+
+       /* for cslip etc */
+       unsigned long rx_compressed;
+       unsigned long tx_compressed;
+};

+#define COM_STOP_BITS_1       0
+#define COM_STOP_BITS_1_5     1
+#define COM_STOP_BITS_2       2
+
+#define COM_NO_PARITY         0
+#define COM_ODD_PARITY        1
+#define COM_EVEN_PARITY       2
+#define COM_FORCE_PARITY_1    3
+#define COM_FORCE_PARITY_0    4
+
+#define COM_FLOW_CONTROL_NONE     1
+#define COM_FLOW_CONTROL_RTSCTS   2
+#define COM_FLOW_CONTROL_XONXOFF  3
+
+struct fstioc_async_conf {
+       unsigned char flow_control;
+       unsigned char stop_bits;
+       unsigned char parity;
+       unsigned char word_length;
+       unsigned char xon_char;
+       unsigned char xoff_char;
+};

 /*      Ioctl call command values
+ *
+ *      The first three private ioctls are used by the sync-PPP module,
+ *      allowing a little room for expansion we start our numbering at 10.
  */
-#define FSTWRITE        (SIOCDEVPRIVATE+10)
-#define FSTCPURESET     (SIOCDEVPRIVATE+11)
-#define FSTCPURELEASE   (SIOCDEVPRIVATE+12)
-#define FSTGETCONF      (SIOCDEVPRIVATE+13)
-#define FSTSETCONF      (SIOCDEVPRIVATE+14)
-
+#define FSTWRITE        (SIOCDEVPRIVATE+4)
+#define FSTCPURESET     (SIOCDEVPRIVATE+5)
+#define FSTCPURELEASE   (SIOCDEVPRIVATE+6)
+#define FSTGETCONF      (SIOCDEVPRIVATE+7)
+#define FSTSETCONF      (SIOCDEVPRIVATE+8)
+#define FSTSNOTIFY      (SIOCDEVPRIVATE+9)
+#define FSTGSTATE       (SIOCDEVPRIVATE+10)
+#define FSTSYSREQ       (SIOCDEVPRIVATE+11)
+#define FSTGETSHELL     (SIOCDEVPRIVATE+12)
+#define FSTSETMON       (SIOCDEVPRIVATE+13)
+#define FSTSETPORT      (SIOCDEVPRIVATE+14)
+#define FSTCMD          (SIOCDEVPRIVATE+15)

 /*      FSTWRITE
  *
  *      Used to write a block of data (firmware etc) before the card is running
  */
 struct fstioc_write {
-        unsigned int  size;
-        unsigned int  offset;
-        unsigned char data[0];
+       unsigned int size;
+       unsigned int offset;
+       unsigned char data[0];
 };

+struct fstioc_control_request {
+#define FSCONTROLREQUEST_VERSION       1
+
+       __u32 u_version;                /* Version of this structure */
+       __u8 b_direction;       /* 1 ==> HostToDevice, 0 ==> DeviceToHost */
+       __u8 by_request;
+       __u16 w_value;
+       __u16 w_index;
+       __u16 w_data_length;
+       __u8 data[256];
+};

 /*      FSTCPURESET and FSTCPURELEASE
  *
  *      These take no additional data.
- *      FSTCPURESET forces the cards CPU into a reset state and holds it there.
- *      FSTCPURELEASE releases the CPU from this reset state allowing it to run,
+ *      FSTCPURESET   forces the cards CPU into a reset state and holds it
+ *                    there.
+ *      FSTCPURELEASE releases the CPU from this reset state allowing it
+ *                     to run,
  *      the reset vector should be setup before this ioctl is run.
  */

@@ -96,156 +162,443 @@ struct fstioc_write {
  *      might be used to indicate a different (expanded) structure.
  */
 struct fstioc_info {
-        unsigned int   valid;           /* Bits of structure that are valid */
-        unsigned int   nports;          /* Number of serial ports */
-        unsigned int   type;            /* Type index of card */
-        unsigned int   state;           /* State of card */
-        unsigned int   index;           /* Index of port ioctl was issued on */
-        unsigned int   smcFirmwareVersion;
-        unsigned long  kernelVersion;   /* What Kernel version we are working with */
-        unsigned short lineInterface;   /* Physical interface type */
-        unsigned char  proto;           /* Line protocol */
-        unsigned char  internalClock;   /* 1 => internal clock, 0 => external */
-        unsigned int   lineSpeed;       /* Speed in bps */
-        unsigned int   v24IpSts;        /* V.24 control input status */
-        unsigned int   v24OpSts;        /* V.24 control output status */
-        unsigned short clockStatus;     /* lsb: 0=> present, 1=> absent */
-        unsigned short cableStatus;     /* lsb: 0=> present, 1=> absent */
-        unsigned short cardMode;        /* lsb: LED id mode */
-        unsigned short debug;           /* Debug flags */
-        unsigned char  transparentMode; /* Not used always 0 */
-        unsigned char  invertClock;     /* Invert clock feature for syncing */
-        unsigned char  startingSlot;    /* Time slot to use for start of tx */
-        unsigned char  clockSource;     /* External or internal */
-        unsigned char  framing;         /* E1, T1 or J1 */
-        unsigned char  structure;       /* unframed, double, crc4, f4, f12, */
-                                        /* f24 f72 */
-        unsigned char  interface;       /* rj48c or bnc */
-        unsigned char  coding;          /* hdb3 b8zs */
-        unsigned char  lineBuildOut;    /* 0, -7.5, -15, -22 */
-        unsigned char  equalizer;       /* short or lon haul settings */
-        unsigned char  loopMode;        /* various loopbacks */
-        unsigned char  range;           /* cable lengths */
-        unsigned char  txBufferMode;    /* tx elastic buffer depth */
-        unsigned char  rxBufferMode;    /* rx elastic buffer depth */
-        unsigned char  losThreshold;    /* Attenuation on LOS signal */
-        unsigned char  idleCode;        /* Value to send as idle timeslot */
-        unsigned int   receiveBufferDelay; /* delay thro rx buffer timeslots */
-        unsigned int   framingErrorCount; /* framing errors */
-        unsigned int   codeViolationCount; /* code violations */
-        unsigned int   crcErrorCount;   /* CRC errors */
-        int            lineAttenuation; /* in dB*/
-        unsigned short lossOfSignal;
-        unsigned short receiveRemoteAlarm;
-        unsigned short alarmIndicationSignal;
+       unsigned int valid;     /* Bits of structure that are valid */
+       unsigned int nports;    /* Number of serial ports */
+       unsigned int type;      /* Type index of card */
+       unsigned int state;     /* State of card */
+       unsigned int index;     /* Index of port ioctl was issued on */
+       unsigned int smc_firmware_version;
+       unsigned long kernel_version;   /* Kernel ver we are working with */
+       unsigned short line_interface;  /* Physical interface type */
+       unsigned char proto;    /* Line protocol */
+       unsigned char internal_clock;   /* 1 => internal clock,
+                                        * 0 => external
+                                        */
+       unsigned int line_speed;        /* Speed in bps */
+       unsigned int est_line_speed;    /* Estimated speed in bps */
+       unsigned int v24IpSts;  /* V.24 control input status */
+       unsigned int v24OpSts;  /* V.24 control output status */
+       unsigned short clock_status;    /* lsb: 0=> present, 1=> absent */
+       unsigned short cable_status;    /* lsb: 0=> present, 1=> absent */
+       unsigned short card_mode;       /* lsb: LED id mode */
+       unsigned short debug;   /* Debug flags */
+       unsigned char transparent_mode; /* Not used always 0 */
+       unsigned char invert_clock;     /* Invert clock feature for syncing */
+       unsigned char async_ability;    /* The ability to do async */
+       unsigned char synth_ability;    /* The ability to syth a clock */
+       unsigned char extended_clocking;        /* New T4e clock modes */
+       unsigned char starting_slot;    /* Time slot to use for start of tx */
+       unsigned char clock_source;     /* External or internal */
+       unsigned char framing;  /* E1, T1 or J1 */
+       unsigned char structure;        /* unframed, double, crc4, f4, f12, */
+       /* f24 f72 */
+       unsigned char interface;        /* rj48c or bnc */
+       unsigned char coding;   /* hdb3 b8zs */
+       unsigned char line_build_out;   /* 0, -7.5, -15, -22 */
+       unsigned char equalizer;        /* short or lon haul settings */
+       unsigned char loop_mode;        /* various loopbacks */
+       unsigned char range;    /* cable lengths */
+       unsigned char tx_buffer_mode;   /* tx elastic buffer depth */
+       unsigned char rx_buffer_mode;   /* rx elastic buffer depth */
+       unsigned char los_threshold;    /* Attenuation on LOS signal */
+       unsigned char idle_code;        /* Value to send as idle timeslot */
+       unsigned int receive_buffer_delay; /* delay thro rx buffer timeslots */
+       unsigned int framing_error_count;       /* framing errors */
+       unsigned int code_violation_count;      /* code violations */
+       unsigned int crc_error_count;   /* CRC errors */
+       int line_attenuation;   /* in dB */
+       unsigned short loss_of_signal;
+       unsigned short receive_remote_alarm;
+       unsigned short alarm_indication_signal;
+       unsigned short _reserved[64];
+       unsigned char ignore_carrier;   /* If set transmit regardless of
+                                        *  carrier state
+                                        */
+       unsigned char num_tx_buffers;   /* No of tx buffers in card window */
+       unsigned char num_rx_buffers;   /* No of rx buffers in card window */
+       unsigned int tx_buffer_size;    /* Size of tx buffers in card window */
+       unsigned int rx_buffer_size;    /* Size of rx buffers in card window */
+       unsigned char terminal_type;    /* Additional hdsl */
+       unsigned char annex_type;
+       unsigned char encap;
+       unsigned char test_mode;
+       unsigned char backoff;
+       unsigned char b_line_probing_enable;
+       unsigned char snrth;
+       unsigned char lpath;
+       unsigned short vpi;
+       unsigned short vci;
+       unsigned char activation_status;
+       unsigned char no_common_mode_status;
+       unsigned char transceiverStatus1;
+       unsigned char transceiverStatus2;
+       unsigned char line_loss;
+       char signal_quality;
+       unsigned char near_end_block_error_count;
+       char signal_to_noise_ratio;
+       unsigned char errored_second_count;
+       unsigned char severely_errored_second_count;
+       unsigned char loss_of_sync_word_second_count;
+       unsigned char unavailable_second_count;
+       char frequency_deviation;
+       char negotiated_power_back_off;
+       unsigned char negotiated_psd;
+       unsigned char negotiated_b_channels;
+       unsigned char negotiated_z_bits;
+       unsigned short negotiated_sync_word;
+       unsigned char negotiated_stuff_bits;
+       unsigned char chip_version;
+       unsigned char firmware_version;
+       unsigned char rom_version;
+       unsigned short atm_tx_cell_count;
+       unsigned short atm_rx_cell_count;
+       unsigned short atm_hec_error_count;
+       unsigned int atm_cells_dropped;
+       unsigned char transmit_msb_first;
+       unsigned char receive_msb_first;
+       unsigned char xpld_version;
+       unsigned char farEndCountryCode[2];
+       unsigned char farEndProviderCode[4];
+       unsigned char farEndVendorInfo[2];
+       unsigned char utopia_atm_status;
+       unsigned int termination;
+       unsigned int tx_rx_start;
+       unsigned char enable_nrzi_clocking;     /* Ver 1 addition */
+       unsigned char low_latency;      /* Ver 1 addition */
+       struct fst_device_stats stats;  /* Ver 1 addition */
+       struct fstioc_async_conf async_conf;    /* Ver 2 addition */
+       unsigned char iocinfo_version;  /* Ver 2 addition */
+       unsigned char ext_sync_clock_enable;    /* Ver 3 addition */
+       unsigned char ext_sync_clock_offset;    /* Ver 3 addition */
+       unsigned int ext_sync_clock_rate;       /* Ver 3 addition */
+       unsigned char pps_enable;       /* Ver 3 addition */
+       unsigned char pps_offset;       /* Ver 3 addition */
+       unsigned char card_rev_major;   /* Ver 4 addition */
+       unsigned char card_rev_minor;   /* Ver 4 addition */
+       unsigned char card_rev_build;   /* Ver 4 addition */
+       unsigned int features;  /* Ver 4 addition */
+};
+
+#define FST_MODE_HDLC        0
+#define FST_MODE_TRANSPARENT 1
+#define FST_MODE_BISYNC      2
+#define FST_MODE_ASYNC       3
+#define LOW_LATENCY_DISABLE  0
+#define LOW_LATENCY_RX       1
+#define LOW_LATENCY_TX       2
+#define LOWOW_LATENCY_RXTC   3
+
+/*      FSTSNOTIFY
+ *
+ */
+#define FST_NOTIFY_OFF        0
+#define FST_NOTIFY_ON         1
+#define FST_NOTIFY_EXTENDED   2
+#define FST_NOTIFY_BASIC_SIZE (2*sizeof(int))
+
+/*      FSTGSTATE
+ *
+ *      Used to query why a state change message has been issued by the driver
+ *      It could be because there was a change in line states or that the txq
+ *      has reached an empty state
+ */
+struct fstioc_status {
+       int carrier_state;
+       int txq_length;
+       int rxq_length;
+       struct fst_device_stats stats;
+};
+
+/*      FSTSYSREQ
+ *
+ *      Used to provide a simple transparent command/repsonse interface between
+ *      an application and the firmware running on the card
+ */
+struct fstioc_req {
+       unsigned short msg_type;
+       unsigned short msg_len;
+       unsigned short ret_code;
+       unsigned short i_reg_idx;
+       unsigned short value;
+       unsigned char u_msg[16];
+       unsigned char u_msg_reserved[16];
+       unsigned char u_reserved[4];
+};
+
+#define MSG_FIFO_DEF_SLAVE_1X  0x0001
+#define MSG_FIFO_DEF_SLAVE_16X 0x0002
+#define MSG_FIFO_DEF_MASTER    0x0003
+#define MSG_FIFO_EEPROM_RD     0x769b
+#define MSG_FIFO_EEPROM_WR     0xcd4a
+#define RSP_FIFO_SUCCESS       0x0000
+#define RSP_FIFO_FAILURE       0x0001
+
+/*      FSTSETMON
+ *
+ *      Used to provide a simple monitoring data
+ */
+#define FSTIOC_MON_VERSION 0
+#define FST_MON_RX         0
+#define FST_MON_TX         1
+
+struct fstioc_mon {
+       unsigned char version;
+       unsigned char tx_rx_ind;
+       unsigned int sequence;
+       unsigned long timestamp;
+       unsigned int length;
+};
+
+/*      FSTSETPORT
+ *
+ *      Used to provide a DSL port control
+ */
+#define FST_DSL_PORT_NORMAL         0
+#define FST_DSL_PORT_ACTIVE         1
+
+/*      FSTCMD
+ *
+ *      Used to read and write card data
+ */
+#define FSTCMD_GET_SERIAL             0
+#define FSTCMD_SET_V24O               1
+#define FSTCMD_GET_VERSION            2
+#define FSTCMD_SET_VERSION            3
+#define FSTCMD_GET_INTS               4
+#define FSTCMD_RESET_INTS             5
+#define FSTCMD_RESET_STATS            6
+#define FSTCMD_SET_READV              7
+#define FSTCMD_SET_CHAR               8
+#define FSTCMD_GET_PRESERVE_SIGNALS   9
+#define FSTCMD_SET_PRESERVE_SIGNALS  10
+#define FSTCMD_SET_LATENCY           11
+#define FSTCMD_UPDATE_CLOCK          12
+#define FSTCMD_SET_CUSTOM_RATE       13
+
+#ifdef __x86_64__
+#define fstioc_info_sz_old     316
+#define fstioc_info_sz_ver1    504
+#define fstioc_info_sz_ver2    512
+#define fstioc_info_sz_ver3    528
+#define fstioc_info_sz_ver4    536
+#define fstioc_info_sz_current sizeof(struct fstioc_info)
+#else
+#define fstioc_info_sz_old     312
+#define fstioc_info_sz_ver1    408
+#define fstioc_info_sz_ver2    416
+#define fstioc_info_sz_ver3    428
+#define fstioc_info_sz_ver4    436
+#define fstioc_info_sz_current sizeof(struct fstioc_info)
+#endif
+
+#define FST_VERSION         4
+#define FST_VERSION_CURRENT FST_VERSION
+#define FST_VERSION_V3     3
+#define FST_VERSION_V2     2
+#define FST_VERSION_V1      1
+#define FST_VERSION_OLD     0
+
+#define FST_READV_NORMAL 0
+#define FST_READV_SYNC   1
+#define FST_READV_SYNC2  2
+
+struct fstioc_char_data {
+       unsigned char queue_len;
+       unsigned char threshold;
+       unsigned char pad[14];
+};
+
+struct fstioc_latency_data {
+       unsigned int tx_size;
+       unsigned int rx_size;
+       unsigned int rate;
+};
+
+struct fstioc_cmd {
+       unsigned int version;
+       unsigned int command;
+       unsigned int status;
+       unsigned int input_data_len;
+       unsigned int output_data_len;
+       unsigned char *data_ptr;
+};
+
+#define FST_CUSTOM_RATE_CONFIG_VERSION 1
+#define FST_CUSTOM_RATE_CONFIG_LENGTH (33+1)
+#define FST_CUSTOM_RATE_CLOCK_SLAVE 0
+#define FST_CUSTOM_RATE_CLOCK_LOW_SLAVE 1
+#define FST_CUSTOM_RATE_CLOCK_LOW_MASTER 2
+#define FST_CUSTOM_CLOCK_MULTIPLIER_1 1
+#define FST_CUSTOM_CLOCK_MULTIPLIER_16 2
+
+struct fstioc_custom_rate_config {
+       unsigned int version;
+       unsigned int rate;
+       unsigned int permanent;
+       unsigned int multiplier;        /* 1 or 16 */
+       unsigned int clock_type;        /* slave, low_slave, low_master */
+       char rate_info[FST_CUSTOM_RATE_CONFIG_LENGTH];
 };

 /* "valid" bitmask */
-#define FSTVAL_NONE     0x00000000      /* Nothing valid (firmware not running).
-                                         * Slight misnomer. In fact nports,
-                                         * type, state and index will be set
-                                         * based on hardware detected.
-                                         */
-#define FSTVAL_OMODEM   0x0000001F      /* First 5 bits correspond to the
-                                         * output status bits defined for
-                                         * v24OpSts
-                                         */
-#define FSTVAL_SPEED    0x00000020      /* internalClock, lineSpeed, clockStatus
-                                         */
-#define FSTVAL_CABLE    0x00000040      /* lineInterface, cableStatus */
-#define FSTVAL_IMODEM   0x00000080      /* v24IpSts */
-#define FSTVAL_CARD     0x00000100      /* nports, type, state, index,
-                                         * smcFirmwareVersion
-                                         */
-#define FSTVAL_PROTO    0x00000200      /* proto */
-#define FSTVAL_MODE     0x00000400      /* cardMode */
-#define FSTVAL_PHASE    0x00000800      /* Clock phase */
-#define FSTVAL_TE1      0x00001000      /* T1E1 Configuration */
-#define FSTVAL_DEBUG    0x80000000      /* debug */
-#define FSTVAL_ALL      0x00001FFF      /* Note: does not include DEBUG flag */
+#define FSTVAL_NONE     0x00000000     /* Nothing valid (firmware not
+                                        * running). Slight misnomer. In fact
+                                        * nports, type, state and index will
+                                        * be set based on hardware detected.
+                                        */
+#define FSTVAL_OMODEM   0x0000001F     /* First 5 bits correspond to the
+                                        * output status bits defined for
+                                        * v24OpSts
+                                        */
+#define FSTVAL_SPEED    0x00000020     /* internalClock, lineSpeed,
+                                        * clockStatus
+                                        */
+#define FSTVAL_CABLE    0x00000040     /* lineInterface, cableStatus */
+#define FSTVAL_IMODEM   0x00000080     /* v24IpSts */
+#define FSTVAL_CARD     0x00000100     /* nports, type, state, index,
+                                        * smcFirmwareVersion
+                                        */
+#define FSTVAL_PROTO    0x00000200     /* proto */
+#define FSTVAL_MODE     0x00000400     /* cardMode */
+#define FSTVAL_PHASE    0x00000800     /* Clock phase */
+#define FSTVAL_TE1      0x00001000     /* T1E1 Configuration */
+#define FSTVAL_BUFFERS  0x00002000     /* Tx and Rx buffer settings */
+#define FSTVAL_DSL_S1   0x00004000     /* DSL-S1 Configuration */
+#define FSTVAL_T4E      0x00008000     /* T4E Mk II Configuration */
+#define FSTVAL_FLEX     0x00010000     /* FarSync Flex */
+#define FSTVAL_ASYNC    0x00020000     /* Async config */
+#define FSTVAL_DEBUG    0x80000000     /* debug */
+#define FSTVAL_ALL      0x000FFFFF     /* Note: does not include DEBUG flag */

 /* "type" */
-#define FST_TYPE_NONE   0               /* Probably should never happen */
-#define FST_TYPE_T2P    1               /* T2P X21 2 port card */
-#define FST_TYPE_T4P    2               /* T4P X21 4 port card */
-#define FST_TYPE_T1U    3               /* T1U X21 1 port card */
-#define FST_TYPE_T2U    4               /* T2U X21 2 port card */
-#define FST_TYPE_T4U    5               /* T4U X21 4 port card */
-#define FST_TYPE_TE1    6               /* T1E1 X21 1 port card */
+#define FST_TYPE_NONE     0    /* Probably should never happen */
+#define FST_TYPE_T2P      1    /* T2P X21 2 port card */
+#define FST_TYPE_T4P      2    /* T4P X21 4 port card */
+#define FST_TYPE_T1U      3    /* T1U X21 1 port card */
+#define FST_TYPE_T2U      4    /* T2U X21 2 port card */
+#define FST_TYPE_T4U      5    /* T4U X21 4 port card */
+#define FST_TYPE_TE1      6    /* T1E1 X21 1 port card */
+#define FST_TYPE_DSL_S1   7    /* DSL-S1 card */
+#define FST_TYPE_T4E      8    /* T4E Mk II */
+#define FST_TYPE_FLEX1    9    /* FarSync Flex 1 port */
+#define FST_TYPE_T4UE    10    /* T4UE 4 port PCI Express */
+#define FST_TYPE_T2UE    11    /* T2UE 2 port PCI Express */
+#define FST_TYPE_T4Ep    12    /* T4E+ 4 port card */
+#define FST_TYPE_T2U_PMC 13    /* T2U_PMC 2 port PCI card */
+#define FST_TYPE_TE1e    14    /* TE1e X21 1 port PCI Express */
+#define FST_TYPE_T2Ee    15    /* T2Ee 2 port PCI Express */
+#define FST_TYPE_T4Ee    16    /* T4Ee 4 port PCI Express */
+#define FST_TYPE_FLEX2   17    /* FarSync Flex 1 port (v2) */

 /* "family" */
-#define FST_FAMILY_TXP  0               /* T2P or T4P */
-#define FST_FAMILY_TXU  1               /* T1U or T2U or T4U */
+#define FST_FAMILY_TXP  0      /* T2P or T4P */
+#define FST_FAMILY_TXU  1      /* T1U or T2U or T4U */

 /* "state" */
-#define FST_UNINIT      0               /* Raw uninitialised state following
-                                         * system startup */
-#define FST_RESET       1               /* Processor held in reset state */
-#define FST_DOWNLOAD    2               /* Card being downloaded */
-#define FST_STARTING    3               /* Released following download */
-#define FST_RUNNING     4               /* Processor running */
-#define FST_BADVERSION  5               /* Bad shared memory version detected */
-#define FST_HALTED      6               /* Processor flagged a halt */
-#define FST_IFAILED     7               /* Firmware issued initialisation failed
-                                         * interrupt
-                                         */
+#define FST_UNINIT      0      /* Raw uninitialised state following
+                                * system startup
+                                */
+#define FST_RESET       1      /* Processor held in reset state */
+#define FST_DOWNLOAD    2      /* Card being downloaded */
+#define FST_STARTING    3      /* Released following download */
+#define FST_RUNNING     4      /* Processor running */
+#define FST_BADVERSION  5      /* Bad shared memory version detected */
+#define FST_HALTED      6      /* Processor flagged a halt */
+#define FST_IFAILED     7      /* Firmware issued initialisation failed
+                                * interrupt
+                                */
 /* "lineInterface" */
 #define V24             1
 #define X21             2
 #define V35             3
 #define X21D            4
-#define T1              5
-#define E1              6
-#define J1              7
+#define NOCABLE         5
+#define RS530_449       6
+#define T1              7
+#define E1              8
+#define J1              9
+#define SHDSL           10
+#define RS485           11
+#define UX35C           12
+#define RS485_FDX       13
+
+#ifndef IF_IFACE_SHDSL
+#define IF_IFACE_SHDSL      0x1007     /* SHDSL (FarSite)              */
+#define IF_IFACE_RS530_449  0x1008     /* RS530_449 (FarSite)          */
+#define IF_IFACE_RS485      0x1009     /* RS485     (FarSite)          */
+#endif
+#define IF_IFACE_RS485_FDX  0x100A     /* RS485 Full Duplex (Farsite)  */
+#define IF_IFACE_UX35C      0x100B     /* UX35C (Farsite)              */

 /* "proto" */
-#define FST_RAW         4               /* Two way raw packets */
-#define FST_GEN_HDLC    5               /* Using "Generic HDLC" module */
+#define FST_HDLC        1      /* Cisco compatible HDLC */
+#define FST_PPP         2      /* Sync PPP */
+#define FST_MONITOR     3      /* Monitor only (raw packet reception) */
+#define FST_RAW         4      /* Two way raw packets */
+#define FST_GEN_HDLC    5      /* Using "Generic HDLC" module */

 /* "internalClock" */
 #define INTCLK          1
 #define EXTCLK          0

+/*
+ *  The bit pattern for extendedClocking is
+ *  8   4   2   1  |8    4    2    1
+ *  ec             |ttrx tttx irx  itx
+ */
+
+#define        EXT_CLOCK_NONE    0x00
+#define EXT_CLOCK_ERX_ETX 0x80
+#define EXT_CLOCK_ERX_ITX 0x81
+#define EXT_CLOCK_IRX_ETX 0x82
+#define EXT_CLOCK_IRX_ITX 0x83
+#define EXT_CLOCK_DTE_TT  0x84
+#define EXT_CLOCK_DCE_TT  0x8B
+
 /* "v24IpSts" bitmask */
-#define IPSTS_CTS       0x00000001      /* Clear To Send (Indicate for X.21) */
+#define IPSTS_CTS       0x00000001     /* Clear To Send (Indicate for X.21) */
 #define IPSTS_INDICATE  IPSTS_CTS
-#define IPSTS_DSR       0x00000002      /* Data Set Ready (T2P Port A) */
-#define IPSTS_DCD       0x00000004      /* Data Carrier Detect */
-#define IPSTS_RI        0x00000008      /* Ring Indicator (T2P Port A) */
-#define IPSTS_TMI       0x00000010      /* Test Mode Indicator (Not Supported)*/
-
+#define IPSTS_DSR       0x00000002     /* Data Set Ready (T2P Port A) */
+#define IPSTS_DCD       0x00000004     /* Data Carrier Detect */
+#define IPSTS_RI        0x00000008     /* Ring Indicator (T2P Port A) */
+#define IPSTS_TMI       0x00000010     /* Test Mode Indicator
+                                        * (Not Supported)
+                                        */
 /* "v24OpSts" bitmask */
-#define OPSTS_RTS       0x00000001      /* Request To Send (Control for X.21) */
+#define OPSTS_RTS       0x00000001     /* Request To Send (Ctrl for X.21) */
 #define OPSTS_CONTROL   OPSTS_RTS
-#define OPSTS_DTR       0x00000002      /* Data Terminal Ready */
-#define OPSTS_DSRS      0x00000004      /* Data Signalling Rate Select (Not
-                                         * Supported) */
-#define OPSTS_SS        0x00000008      /* Select Standby (Not Supported) */
-#define OPSTS_LL        0x00000010      /* Maintenance Test (Not Supported) */
+#define OPSTS_DTR       0x00000002     /* Data Terminal Ready */
+#define OPSTS_DSRS      0x00000004     /* Data Signalling Rate Select (Not
+                                        * Supported)
+                                        */
+#define OPSTS_SS        0x00000008     /* Select Standby (Not Supported) */
+#define OPSTS_LL        0x00000010     /* Local Loop */
+#define OPSTS_DCD       0x00000020     /* Only when DCD is enabled as an
+                                        * output
+                                        */
+#define OPSTS_RL        0x00000040     /* Remote Loop */

 /* "cardMode" bitmask */
 #define CARD_MODE_IDENTIFY      0x0001

-/*
- * Constants for T1/E1 configuration
- */
+/* TxRx Start Parameters */
+#define START_TX 1
+#define START_RX 2
+#define START_TX_AND_RX (START_TX | START_RX)
+#define START_DEFAULT START_TX_AND_RX

-/*
- * Clock source
- */
+/* Constants for T1/E1 configuration  */
+
+/* Clock source  */
 #define CLOCKING_SLAVE       0
 #define CLOCKING_MASTER      1

-/*
- * Framing
- */
+/* Framing */
 #define FRAMING_E1           0
 #define FRAMING_J1           1
 #define FRAMING_T1           2

-/*
- * Structure
- */
+/* Structure */
 #define STRUCTURE_UNFRAMED   0
 #define STRUCTURE_E1_DOUBLE  1
 #define STRUCTURE_E1_CRC4    2
@@ -255,36 +608,32 @@ struct fstioc_info {
 #define STRUCTURE_T1_24      6
 #define STRUCTURE_T1_72      7

-/*
- * Interface
- */
+/* Interface */
 #define INTERFACE_RJ48C      0
 #define INTERFACE_BNC        1

-/*
- * Coding
- */
-
-#define CODING_HDB3          0
-#define CODING_NRZ           1
-#define CODING_CMI           2
-#define CODING_CMI_HDB3      3
-#define CODING_CMI_B8ZS      4
-#define CODING_AMI           5
-#define CODING_AMI_ZCS       6
-#define CODING_B8ZS          7
+/* Coding */
+#define CODING_HDB3               0
+#define CODING_NRZ                1
+#define CODING_CMI                2
+#define CODING_CMI_HDB3           3
+#define CODING_CMI_B8ZS           4
+#define CODING_AMI                5
+#define CODING_AMI_ZCS            6
+#define CODING_B8ZS               7
+#define CODING_NRZI               8
+#define CODING_FM0                9
+#define CODING_FM1                10
+#define CODING_MANCHESTER         11
+#define CODING_DIFF_MANCHESTER    12

-/*
- * Line Build Out
- */
+/* Line Build Out */
 #define LBO_0dB              0
 #define LBO_7dB5             1
 #define LBO_15dB             2
 #define LBO_22dB5            3

-/*
- * Range for long haul t1 > 655ft
- */
+/* Range for long haul t1 > 655ft */
 #define RANGE_0_133_FT       0
 #define RANGE_0_40_M         RANGE_0_133_FT
 #define RANGE_133_266_FT     1
@@ -295,29 +644,52 @@ struct fstioc_info {
 #define RANGE_122_162_M       RANGE_399_533_FT
 #define RANGE_533_655_FT     4
 #define RANGE_162_200_M      RANGE_533_655_FT
-/*
- * Receive Equaliser
- */
+
+/* Receive Equaliser */
 #define EQUALIZER_SHORT      0
 #define EQUALIZER_LONG       1

-/*
- * Loop modes
- */
+/* Loop modes */
 #define LOOP_NONE            0
 #define LOOP_LOCAL           1
 #define LOOP_PAYLOAD_EXC_TS0 2
 #define LOOP_PAYLOAD_INC_TS0 3
 #define LOOP_REMOTE          4

-/*
- * Buffer modes
- */
+/* Buffer modes */
 #define BUFFER_2_FRAME       0
 #define BUFFER_1_FRAME       1
 #define BUFFER_96_BIT        2
 #define BUFFER_NONE          3

+/* DSL Equipment types */
+#define EQUIP_TYPE_REMOTE    0
+#define EQUIP_TYPE_CENTRAL   1
+
+/* DSL Operating modes */
+#define ANNEX_A              1 /* US */
+#define ANNEX_B              0 /* EU */
+
+/* DSL ATM Encapsulation methods */
+#define ENCAP_PPP            0
+#define ENCAP_MPOA           1
+#define MPOA_HEADER_LEN      8
+
+/* DSL Test Modes */
+#define TEST_MODE_NONE                        0
+#define TEST_MODE_DEFAULT TEST_MODE_NONE
+
+#define TEST_MODE_ALTERNATING_SINGLE_PULSE    1
+#define TEST_MODE_ANALOG_TRANSPARENT_LOOP     4
+#define TEST_MODE_ANALOG_NON_TRANSPARENT_LOOP 8
+#define TEST_MODE_TRANSMIT_SC_SR              9
+#define TEST_MODE_TRANSMIT_TC_PAM_SCRONE      10
+#define TEST_MODE_LINE_DRIVER_NO_SIGNAL       11
+#define TEST_MODE_AGC_TO_LINE_DRIVER_LOOP     12
+
+#define TEST_MODE_LOOP_TDM_TO_LINE            16
+#define TEST_MODE_LOOP_PAYLOAD_TO_LINE        17
+
 /*      Debug support
  *
  *      These should only be enabled for development kernels, production code
@@ -329,23 +701,26 @@ struct fstioc_info {
 #define FST_DEBUG       0x0000
 #if FST_DEBUG

-extern int fst_debug_mask;              /* Bit mask of actions to debug, bits
-                                         * listed below. Note: Bit 0 is used
-                                         * to trigger the inclusion of this
-                                         * code, without enabling any actions.
-                                         */
-#define DBG_INIT        0x0002          /* Card detection and initialisation */
-#define DBG_OPEN        0x0004          /* Open and close sequences */
-#define DBG_PCI         0x0008          /* PCI config operations */
-#define DBG_IOCTL       0x0010          /* Ioctls and other config */
-#define DBG_INTR        0x0020          /* Interrupt routines (be careful) */
-#define DBG_TX          0x0040          /* Packet transmission */
-#define DBG_RX          0x0080          /* Packet reception */
-#define DBG_CMD         0x0100          /* Port command issuing */
-
-#define DBG_ASS         0xFFFF          /* Assert like statements. Code that
-                                         * should never be reached, if you see
-                                         * one of these then I've been an ass
-                                         */
-#endif  /* FST_DEBUG */
-
+extern int fst_debug_mask;     /* Bit mask of actions to debug, bits
+                                * listed below. Note: Bit 0 is used
+                                * to trigger the inclusion of this
+                                * code, without enabling any actions.
+                                */
+#define DBG_INIT        0x0002 /* Card detection and initialisation */
+#define DBG_OPEN        0x0004 /* Open and close sequences */
+#define DBG_PCI         0x0008 /* PCI config operations */
+#define DBG_IOCTL       0x0010 /* Ioctls and other config */
+#define DBG_INTR        0x0020 /* Interrupt routines (be careful) */
+#define DBG_TX          0x0040 /* Packet transmission */
+#define DBG_RX          0x0080 /* Packet reception */
+#define DBG_CMD         0x0100 /* Port command issuing */
+#define DBG_ATM         0x0200 /* ATM processing */
+#define DBG_TTY         0x0400 /* PPPd processing */
+#define DBG_USB         0x0800 /* USB device */
+#define DBG_ASY         0x1000 /* Async functions */
+#define DBG_FIFO        0x2000 /* Fifo functions */
+#define DBG_ASS         0x0001 /* Assert like statements. Code that
+                                * should never be reached, if you see
+                                * one of these then I've been an ass
+                                */
+#endif /* FST_DEBUG */

