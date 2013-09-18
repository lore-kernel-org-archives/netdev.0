From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 006/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:12:25 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA5@SOLO.hq.farsitecommunications.com>
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

Patch 6 of 7

Introduce the fsflex driver.
This driver is functionally equivalent to the farsync driver, and so
can be used with the Generic HDLC, and ppp daemon.

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---
diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/fsflex.c linux-3.10.1_new/drivers/net/wan/fsflex.c
--- linux-3.10.1/drivers/net/wan/fsflex.c       1970-01-01 01:00:00.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/fsflex.c   2013-09-16 16:30:06.651104873 +0100
@@ -0,0 +1,5693 @@
+/*
+ *      FarSync Flex driver for Linux (2.6.x kernel version)
+ *
+ *      Copyright (C) 2001-2013 FarSite Communications Ltd.
+ *      www.farsite.com
+ *
+ *      This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ *      Author:      Kevin Curtis  <kevin.curtis@farsite.com>
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/fs.h>
+#include <linux/proc_fs.h>
+#include <linux/pci.h>
+#include <linux/poll.h>
+#include <linux/ioport.h>
+#include <linux/netdevice.h>
+#include <linux/init.h>
+#include <linux/if_arp.h>
+#include <linux/uaccess.h>
+#include <linux/if.h>
+#include <linux/interrupt.h>
+#include <linux/hdlc.h>
+#include <linux/io.h>
+#include <linux/usb.h>
+#include <linux/delay.h>
+#include <linux/delay.h>
+#include <linux/workqueue.h>
+/* TTY includes */
+#include <linux/tty.h>
+#include <linux/tty_flip.h>
+#include <linux/serial.h>
+#include <linux/crypto.h>
+#include <linux/err.h>
+#include <linux/scatterlist.h>
+#define FST_BUILD_NO "-k219"
+#include "farsync.h"
+#include "uss_cmn.h"
+
+/*      Module info */
+MODULE_AUTHOR("K. P. Curtis <kevin.curtis@farsite.com>");
+MODULE_DESCRIPTION("FarSync Flex WAN driver. FarSite Communications Ltd.");
+MODULE_LICENSE("GPL");
+
+/*      Driver configuration and global parameters
+ *      ==========================================
+ */
+
+#define FST_PORT_NAME "hdlc"
+#define FST_DRIVER_TYPE "WAN"
+
+/*      Number of ports (per card) and cards supported
+ */
+#define FST_MAX_PORTS           1
+#define FST_MAX_CARDS           32
+#define FST_MAX_USB_BUFFER      ((32*1024)+8)
+
+/* Enable this #define if you want an oem driver without hooks into syncppp
+ * This means the driver can be loaded without the presence of the
+ * syncppp module
+ */
+
+/* Modules parameters and associated varaibles
+ */
+#define FST_HIGH_WATER_MARK     12     /* Point at which we flow control
+                                        * network layer
+                                        */
+#define FST_LOW_WATER_MARK      8      /* Point at which we remove flow
+                                        * control from network layer
+                                        */
+#define MAX_URBS_OUTSTANDING    1
+#define FST_MIN_DMA_LEN 64     /* do DMA on transfers > 64 bytes */
+
+#define FIRST_FLEX_V2_MINOR_ID  3      /* A Minor id of 3 means flex V2 */
+
+int fst_txq_low = FST_LOW_WATER_MARK;
+int fst_txq_high = FST_HIGH_WATER_MARK;
+int fst_min_dma_len = FST_MIN_DMA_LEN;
+int fst_dmathr = 0xdd00dd00;
+int fst_iocinfo_version = FST_VERSION_CURRENT;
+int fst_max_reads = 7;
+int fst_excluded_cards;
+int fst_excluded_list[FST_MAX_CARDS];
+int fst_num_serials;
+char *fst_serials[FST_MAX_CARDS];
+
+module_param(fst_txq_low, int, S_IRUGO);
+module_param(fst_txq_high, int, S_IRUGO);
+module_param(fst_min_dma_len, int, S_IRUGO);
+module_param(fst_dmathr, int, S_IRUGO);
+module_param(fst_iocinfo_version, int, S_IRUGO);
+module_param(fst_max_reads, int, S_IRUGO);
+module_param(fst_excluded_cards, int, S_IRUGO);
+module_param_array(fst_excluded_list, int, NULL, S_IRUGO);
+module_param_array(fst_serials, charp, &fst_num_serials, S_IRUGO);
+
+/*      Default parameters for the link
+ */
+#define FST_TX_QUEUE_LEN        100    /* At 8Mbps a longer queue length is
+                                        * useful, the syncppp module forces
+                                        * this down assuming a slower line I
+                                        * guess.
+                                        */
+#define FST_TXQ_DEPTH           16     /* This one is for the buffering
+                                        * of frames on the way down to the
+                                        * card so that we can keep the card
+                                        * busy and maximise throughput
+                                        */
+#define FST_MAX_MTU           (32*1024)        /* Limitation of hdlc controller */
+#define FST_DEF_MTU             1500   /* Common sane value */
+#define FST_MAX_ATM_MTU         (32*53)        /* 1500 bytes should fit in 32 cells */
+#define MAX_PPP_HEADER          10     /* Allowance for PPP overhead when
+                                        * allocating skbs or checking lengths
+                                        */
+
+#define FST_TX_TIMEOUT          (10*HZ)
+#define FST_MAX_SEGMENTS (FST_MAX_MTU/128) /* Maximum tx/rx desriptors per
+                                           * frame
+                                           */
+
+#ifdef ARPHRD_RAWHDLC
+#define ARPHRD_MYTYPE   ARPHRD_RAWHDLC /* Raw frames */
+#else
+#define ARPHRD_MYTYPE   ARPHRD_HDLC    /* Cisco-HDLC (keepalives etc) */
+#endif
+
+/* Mailbox values. (portMailbox) */
+#define NOP             0      /* No operation */
+#define ACK             1      /* Positive acknowledgement to PC driver */
+#define NAK             2      /* Negative acknowledgement to PC driver */
+#define STARTPORT       3      /* Start an HDLC port */
+#define STOPPORT        4      /* Stop an HDLC port */
+#define ABORTTX         5      /* Abort the transmitter for a port */
+#define SETV24O         6      /* Set V24 outputs */
+#define ASSERTSIGNALS   7
+#define RELEASESIGNALS  8
+#define SETRXCONFIG     9
+#define SETTXCONFIG     10
+#define GETSIGNALS      11
+#define SETSIGNALS      SETV24O
+#define RECONFIG        12
+#define SETPRESERVE     13
+#define GETPRESERVE     14
+#define FLUSHBUFFERS    15
+#define SETXON          16
+#define SETXOFF         17
+#define GETPORTSTATS    18
+#define RESETPORTSTATS  19
+#define SETLINESPEED    20
+
+#define FST_MEMSIZE 0x100000   /* Size of card memory (1Mb) */
+
+#define REQUIRED_TX_BUFFERS 8
+#define REQUIRED_RX_BUFFERS 8
+#define REQUIRED_TX_BUFFER_SIZE (8*1024)
+#define REQUIRED_RX_BUFFER_SIZE (8*1024)
+
+/* Rx and Tx status byte bit values
+ */
+
+#define RX_FRAM         0x80   /* Rx: framing error */
+#define RX_OFLO         0x40   /* Rx: overflow error */
+#define RX_CRC          0x20   /* Rx: CRC error */
+#define RX_ABRT         0x10   /* Rx: buffer error */
+#define TX_URUN         0x40   /* Tx: Tx underrun */
+#define TX_ABRT         0x10   /* Tx: Tx abort */
+
+#define usb_buffer_alloc usb_alloc_coherent
+#define usb_buffer_free usb_free_coherent
+
+typedef struct fst_fifo {
+       u16 fifo_length;
+       u16 read_idx;
+       u16 write_idx;
+       short overflow_idx;
+       u8 data[4];
+} FIFO, *PFIFO;
+/*      Device driver private information
+ *      =================================
+ */
+
+/* Something to count interrupts
+ */
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
+/* A structure to queue received frame at the new char interface
+ */
+struct fst_char_rx_frame {
+       struct sk_buff *frame;
+       struct fst_char_rx_frame *next;
+       struct fst_char_rx_frame *prev;
+};
+
+/* A multi-part tx/rx queue structure
+ * For long frame support a frame can be upto 32*1024 - 2 bytes in length
+ * This would occupy 4 tx/rx desriptors (each of 8k)
+ */
+struct fst_queue_info {
+       int count;              /* Total size of frame */
+       int segment_cnt;        /* Number of descriptors required/used */
+       int current_seg;        /* Which segment we are currently doing */
+       unsigned char flags;    /* Start and End frame flags */
+       unsigned char error_recovery;
+       struct sk_buff *frame;  /* The complete skb */
+};
+
+/*      Per port (line or channel) information
+ */
+struct fst_port_info {
+       struct net_device *dev; /* device struct - must be first */
+       struct fst_card_info *card;     /* Card we're associated with */
+       int index;              /* Port index on the card */
+       int mode;               /* Are we transparent or not */
+       int proto;              /* Protocol we are running */
+       int hwif;               /* Line hardware (line_interface copy) */
+       int v24IpSts;
+       int v24OpSts;
+       int run;                /* Port is running */
+       int ignore_carrier;     /* Allow tx regardless of carrier state */
+       int hdlc_proto;         /* The proto as hdlc understands it */
+       int num_tx_buffers;     /* No of tx buffers in card window */
+       int num_rx_buffers;     /* No of rx buffers in card window */
+       int tx_buffer_size;     /* Size of tx buffers in card window */
+       int rx_buffer_size;     /* Size of rx buffers in card window */
+       int transmit_msb_first; /* Transmit MSB First */
+       int receive_msb_first;  /* Receive MSB First */
+       int rxpos;              /* Next Rx buffer to use */
+       int txpos;              /* Next Tx buffer to use */
+       int txipos;             /* Next Tx buffer to check for free */
+       int start;              /* Indication of start/stop to network */
+       int notify_mode;        /* Application has selected the notify event */
+       int monitor_mode;       /* Application has selected monitor */
+       unsigned int sequence;  /* Monitor sequence no */
+       int port_mode;          /* DSL normal or active */
+       /*
+        * A sixteen entry transmit queue
+        */
+       int txqs;               /* index to get next buffer to tx */
+       int txqe;               /* index to queue next packet */
+       struct fst_queue_info txq[FST_TXQ_DEPTH];  /* The sent segments info */
+       struct fst_queue_info rxq;      /* The received segments info */
+       struct file *char_file;
+       int char_opens;
+       spinlock_t rxf_lock;    /* Lock for queue head access */
+       struct fst_char_rx_frame *char_inq;
+       struct fst_char_rx_frame *char_inq_end;
+       unsigned char char_inq_max_len; /* Only allow this many frames */
+       unsigned char char_inq_threshold;       /* Generate a notify if */
+       wait_queue_head_t pollq;        /* poll() support */
+       wait_queue_head_t readq;        /* Blocking read support (char) */
+       wait_queue_head_t writeq;       /* Blocking write support (cahr) */
+       FLEX_SERCONF usb_config;
+       FLEX_CARD_INFO usb_card_info;
+       int minor_dev_no;
+       char low_latency;
+       char fstioc_info_ver;
+       char readv_mode;
+       unsigned char flow_controlled;
+       unsigned char exception;
+       struct fst_fifo *fifo_rxdata;
+       struct fst_fifo fifo_txdata;
+       char compat;
+       unsigned int features;
+};
+
+/*      Per card information
+ */
+struct fst_card_info {
+       char *mem;              /* Card memory mapped to kernel space */
+       char *ctlmem;           /* Control memory for PCI cards */
+       unsigned int phys_mem;  /* Physical memory window address */
+       unsigned int phys_ctlmem;       /* Physical control memory address */
+       unsigned int irq;       /* Interrupt request line number */
+       unsigned int nports;    /* Number of serial ports */
+       unsigned int type;      /* Type index of card */
+       unsigned int state;     /* State of card */
+       spinlock_t card_lock;   /* Lock for SMP access */
+       spinlock_t fifo_lock;
+       wait_queue_head_t fifo_waitq;   /* A queue for a fifo response */
+       int fifo_complete;
+       unsigned short pci_conf;        /* PCI card config in I/O space */
+       /* Per port info */
+       struct fst_port_info *ports[FST_MAX_PORTS];
+       struct usb_device *udev;        /* usb device  */
+       struct usb_interface *interface;/* usb interface  */
+       unsigned char *bulk_in_buffer;  /* buffer to receive data */
+       size_t bulk_in_size;            /* size of receive buffer */
+       unsigned char *bulk_out_buffer; /* buffer to xmit data */
+       size_t bulk_out_size;           /* size of xmit buffer */
+       __u8 bulk_in_endpoint_addr;     /* addr of bulk in endpoint */
+       __u8 bulk_out_endpoint_addr;    /* addr of bulk out endpoint */
+       unsigned char *int_in_buffer;   /* buffer to receive data */
+       size_t int_in_size;             /* size of receive buffer */
+       int actual_length;
+       __u8 int_in_endpoint_addr;      /* addr of bulk in endpoint */
+       __u8 int_out_endpoint_addr;     /* addr of bulk out endpoint */
+       __u8 int_interval;
+       __u8 tx_urb_cnt;                /* Outstanding Tx urbs allowed */
+       struct semaphore limit_sem;     /* limiting # of writes in progress */
+       struct urb *int_urb;
+       struct urb *bulk_urb;
+       struct urb *tx_bulk_urb;
+       char usb_trace_buffer[128];
+       int usb_trace_ptr;
+       int card_no;                    /* Inst of the card on the system */
+       int family;                     /* TxP or TxU */
+       int dmarx_in_progress;
+       int dmatx_in_progress;
+       unsigned long int_count;
+       unsigned long int_time_ave;
+       void *rx_dma_handle_host;
+       dma_addr_t rx_dma_handle_card;
+       void *tx_dma_handle_host;
+       dma_addr_t tx_dma_handle_card;
+       struct sk_buff *dma_skb_rx;
+       struct fst_port_info *dma_port_rx;
+       struct fst_port_info *dma_port_tx;
+       int dma_len_rx;
+       int dma_len_tx;
+       int dma_txpos;
+       int dma_rxpos;
+       int dma_tx_flags;
+       int last_tx_port;
+       int card_mode;          /* What we think the identify mode state is */
+       struct device *sync_cdev;
+};
+
+/* Debug support */
+#if FST_DEBUG
+
+static int fst_debug_mask = { FST_DEBUG };
+
+/* Most common debug activity is to print something if the corresponding bit
+ * is set in the debug mask. Note: this uses a non-ANSI extension in GCC to
+ * support variable numbers of macro parameters. The inverted if prevents us
+ * eating someone else's else clause.
+ */
+#define fst_dbg(F, fmt, args...)                                       \
+do {                                                           \
+       if (fst_debug_mask & (F))                               \
+               printk(KERN_DEBUG pr_fmt(fmt), ##args);         \
+} while (0)
+#else
+#define fst_dbg(F, fmt, args...)                                       \
+do {                                                           \
+       if (0)                                                  \
+               printk(KERN_DEBUG pr_fmt(fmt), ##args);         \
+} while (0)
+#endif
+
+/*      Device Driver Work Queues
+ *
+ *      So that we don't spend too much time processing events in the
+ *      Interrupt Service routine, we will declare a work queue per Card
+ *      and make the ISR schedule a task in the queue for later execution.
+ */
+
+static void do_bottom_half_tx(struct fst_card_info *card);
+static void do_bottom_half_rx(struct fst_card_info *card);
+static void fst_process_tx_work_q(unsigned long work_q);
+static void fst_process_int_work_q(unsigned long work_q);
+
+static void fst_process_threshold_work_q(struct work_struct *work);
+static void fst_process_port_stats_work_q(struct work_struct *work);
+static void fst_process_rx_status(int rx_status, char *name);
+static int gen_mon_packet(struct sk_buff *skb, struct fst_port_info *port,
+                         int tx_rx_ind);
+static void fst_q_work_item(u64 *queue, int card_index);
+static void fst_issue_cmd(struct fst_port_info *port, unsigned short cmd);
+
+DECLARE_TASKLET(fst_tx_task, fst_process_tx_work_q, 0);
+DECLARE_TASKLET(fst_int_task, fst_process_int_work_q, 0);
+
+static void fst_process_tty_work(struct work_struct *work);
+static void fst_process_async_tty_work(struct work_struct *work);
+
+static struct work_struct thresh_work_q;
+static struct work_struct port_stats_work_q;
+
+unsigned int fst_ncards;
+struct fst_card_info *fst_cards_list[FST_MAX_CARDS];
+struct fst_port_info *fst_ports_list[FST_MAX_CARDS * FST_MAX_PORTS];
+struct net_device *fst_net_list[FST_MAX_CARDS * FST_MAX_PORTS];
+spinlock_t fst_work_q_lock;
+u64 fst_work_txq;
+u64 fst_work_intq;
+u64 fst_threshq;
+u64 fst_pstatsq;
+int last_segment_cnt;
+
+/* We need to send an idle cell when using mpoa
+ * encapsulation
+ */
+char atm_idle_cell[53];
+
+static unsigned int fst_minor;
+static struct class *farsync_class;
+
+static unsigned int fst_major; /* The char driver major device number.
+                                * Setting it to 0 will cause us to use
+                                * dynamic allocation during module load
+                                */
+
+static char *type_strings[] = {
+       "no hardware",          /* Should never be seen */
+       "FarSync T2P   ",
+       "FarSync T4P   ",
+       "FarSync T1U   ",
+       "FarSync T2U   ",
+       "FarSync T4U   ",
+       "FarSync TE1   ",
+       "FarSync DSL-S1",
+       "FarSync T4E   ",
+       "FarSync Flex-1     ",
+       "FarSync T4Ue   ",
+       "FarSync T2Ue   ",
+       "FarSync T4E+   ",
+       "FarSync T2U-PMC",
+       "FarSync TE1e   ",
+       "FarSync T2Ee   ",
+       "FarSync T4Ee   ",
+       "FarSync Flex-1 (v2)"
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
+
+/* Convert an HDLC device pointer into a port info pointer and similar */
+#define dev_to_port(D)  (dev_to_hdlc(D)->priv)
+#define port_to_dev(P)  ((P)->dev)
+#define port_to_stats(P, S) (P->dev->stats.S)
+#define hdlc_stats(D) (&(D->stats))
+
+/* Sooner or later you can't avoid a forward declaration */
+static int fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
+static void fst_notify_state_change(struct fst_card_info *card,
+                                   struct fst_port_info *port);
+static int post_a_read_bulk_urb(struct fst_card_info *usb_dev);
+static int post_a_read_int_urb(struct fst_card_info *usb_dev);
+static int flex_get_config(struct fst_card_info *usb_dev,
+                          struct fst_port_info *port,
+                          struct fstioc_info *info);
+static int flex_set_config(struct fst_card_info *usb_dev,
+                          struct fstioc_info *info);
+static void flex_delete(struct fst_card_info *dev)
+{
+
+       usb_put_dev(dev->udev);
+       kfree(dev);
+}
+
+static void flex_serconf_to_le(FLEX_SERCONF *usb_config);
+static void flex_serconf_to_cpu(FLEX_SERCONF *usb_config);
+static void flex_irex_to_le(IREX *stats);
+static void flex_irex_to_cpu(IREX *stats);
+static void flex_fstioc_req_to_le(struct fstioc_req *sys_request);
+static void flex_fstioc_req_to_cpu(struct fstioc_req *sys_request);
+static void flex_card_info_to_le(FLEX_CARD_INFO *usb_card_info);
+static void flex_card_info_to_cpu(FLEX_CARD_INFO *usb_card_info);
+static void flex_txrx_preamble_to_cpu(FSCMN_TXRX_PREAMBLE *header);
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
+#define FST_RX_DATA_FIFO_LEN 4096
+#define FST_RX_DATA_FIFO_HIGH (3*1024)
+#define FST_RX_DATA_FIFO_LOW  (1*1024)
+
+#define FST_MAX_FARSYNC_PORTS   4
+#define FST_L1_DEV_NAME         "hdlc"
+
+int find_last_hdlc_device(void)
+{
+       char devname[16];
+       char devnum[16];
+       struct net_device *dev;
+       int i;
+
+       /* Ask the system how many hdlcX cards there are ...
+        */
+
+       for (i = 0; i < FST_MAX_CARDS * FST_MAX_FARSYNC_PORTS; i++) {
+               strcpy(devname, FST_L1_DEV_NAME);
+               sprintf(devnum, "%d", i);
+               strcat(devname, devnum);
+               dev = dev_get_by_name(&init_net, devname);
+               if (dev == NULL) {
+                       fst_dbg(DBG_TTY, "Missing device at %d\n", i);
+                       break;  /* End loop early */
+               } else {
+                       dev_put(dev);
+               }
+       }
+       fst_dbg(DBG_TTY,
+       "There were %d farsync tty ports, starting flex tty ports at %d\n",
+               i, i);
+       return i;
+}
+
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
+static int fst_alloc_rx_fifo(struct fst_port_info *port)
+{
+
+       /* Allocate the data for the fifo
+        */
+       port->fifo_rxdata = kmalloc(FST_RX_DATA_FIFO_LEN
+                                   + sizeof(struct fst_fifo), GFP_ATOMIC);
+       if (port->fifo_rxdata == NULL) {
+               fst_dbg(DBG_FIFO,
+                       "fifo_init: can't allocate %u bytes for Fifo\n",
+                       (unsigned int)(FST_RX_DATA_FIFO_LEN +
+                                      sizeof(struct fst_fifo)));
+               return 1;
+       }
+       fst_dbg(DBG_ASY, "%s: Fifo memory allocated at %p\n", port->dev->name,
+               port->fifo_rxdata);
+       /*
+        * Now initialise it
+        */
+       /* must setup the fifo's length */
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
+       dev = fst_ports_list[if_index]->dev;
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
+
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
+       int retval;
+
+       fst_dbg(DBG_IOCTL, "%s: Initialising async parameters\n",
+               port->dev->name);
+       flex_serconf_to_le(&port->usb_config);
+       retval = usb_control_msg(port->card->udev,
+                                usb_rcvctrlpipe(port->card->udev, 0),
+                                USS_CMD_GET_CONFIG, 0xc0, 0, 0,
+                                &port->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&port->usb_config);
+       if (retval != sizeof(port->usb_config))
+               fst_dbg(DBG_ASS, "Get Config error errno = %d\n", retval);
+       port->usb_config.flow_control = flow_control;
+       port->usb_config.xonchar = 0x11;
+       port->usb_config.xoffchar = 0x13;
+       port->usb_config.data_bits = char_size;
+       port->usb_config.stopbits = stop_bits;
+       port->usb_config.parity = parity;
+       fst_dbg(DBG_IOCTL, "%s: Reconfiguring Port\n", port->dev->name);
+       flex_serconf_to_le(&port->usb_config);
+       retval = usb_control_msg(port->card->udev,
+                                usb_sndctrlpipe(port->card->udev, 0),
+                                USS_CMD_SET_CONFIG, 0x40, 0, 0,
+                                &port->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&port->usb_config);
+       if (retval > 0)
+               fst_dbg(DBG_IOCTL, "Set config response received\n");
+       else
+         fst_dbg(DBG_ASS, "Set Config error errno = %d\n", retval);
+}
+
+static void
+configure_async_parameters(struct fst_port_info *port, unsigned int baud,
+                          unsigned int char_size, unsigned int stop_bits,
+                          unsigned int parity, unsigned int flow_control)
+{
+       int retval;
+
+       fst_dbg(DBG_IOCTL, "%s: Setting async parameters\n", port->dev->name);
+       if (port->run)
+               fst_issue_cmd(port, STOPPORT);
+       port->usb_config.flow_control = COM_FLOW_CONTROL_NONE;
+       if ((flow_control == 1) || (flow_control == 3))
+               port->usb_config.flow_control = COM_FLOW_CONTROL_RTSCTS;
+       if (flow_control == 2)
+               port->usb_config.flow_control = COM_FLOW_CONTROL_XONXOFF;
+       fst_dbg(DBG_IOCTL, "Flow control chosen as %d\n",
+               port->usb_config.flow_control);
+       port->usb_config.xonchar = 0x11;
+       port->usb_config.xoffchar = 0x13;
+       port->usb_config.line_speed = baud;
+       port->usb_config.clock = 1;
+       port->usb_config.data_bits = char_size;
+       if (stop_bits == 2)
+               port->usb_config.stopbits = COM_STOP_BITS_2;
+       else
+               port->usb_config.stopbits = COM_STOP_BITS_1;
+
+       if (parity) {
+               if (parity == 1)
+                       port->usb_config.parity = COM_ODD_PARITY;
+               else
+                       port->usb_config.parity = COM_EVEN_PARITY;
+       } else {
+               port->usb_config.parity = COM_NO_PARITY;
+       }
+       fst_dbg(DBG_IOCTL, "%s: Reconfiguring Port\n", port->dev->name);
+       flex_serconf_to_le(&port->usb_config);
+       retval = usb_control_msg(port->card->udev,
+                                usb_sndctrlpipe(port->card->udev, 0),
+                                USS_CMD_SET_CONFIG, 0x40, 0, 0,
+                                &port->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&port->usb_config);
+
+       if (retval > 0)
+               fst_dbg(DBG_IOCTL, "Set config response received\n");
+       else
+         fst_dbg(DBG_ASS, "Set Config error errno = %d\n", retval);
+       if (port->run)
+               fst_issue_cmd(port, STARTPORT);
+}
+
+#define MAX_TRANSFER           FST_MAX_USB_BUFFER
+#define FST_CHAR_INQ_MAX_LEN    100;
+
+/* Char tty interface for async PPP  */
+#define FST_TTY_NPORTS         (FST_MAX_CARDS*FST_MAX_PORTS)
+#define FST_TTY_MAJOR          191
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
+int fst_tty_tiocmset(struct tty_struct *, unsigned int, unsigned int);
+int fst_tty_tiocmget(struct tty_struct *);
+static void fst_tty_flush_buffer(struct tty_struct *tty);
+static void fst_tty_hangup(struct tty_struct *tty);
+
+static void fst_tty_set_termios(struct tty_struct *tty, struct ktermios *old);
+
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
+void fst_tty_uninit(void)
+{
+       /* Unload the tty driver
+        */
+       int res;
+
+       pr_info("Unregister the flex tty driver\n");
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
+       int base_port_number = 0;
+
+       base_port_number = find_last_hdlc_device();
+
+       /* initialize tty driver struct */
+       serial_drv = alloc_tty_driver(FST_TTY_NPORTS);
+       if (serial_drv == NULL)
+               return 0;
+       serial_drv->magic = TTY_DRIVER_MAGIC;
+       serial_drv->driver_name = "flex_tty";
+       serial_drv->name = "tty_hdlc";
+       serial_drv->major = 0;
+       serial_drv->name_base = base_port_number;
+       serial_drv->minor_start = 0;    /* Use the whole of the minor range */
+       serial_drv->num = FST_TTY_NPORTS;
+       serial_drv->type = TTY_DRIVER_TYPE_SERIAL;
+       serial_drv->subtype = SERIAL_TYPE_NORMAL;
+       serial_drv->init_termios = tty_std_termios;
+       serial_drv->init_termios.c_cflag =
+         B9600 | CS8 | CREAD | HUPCL | CLOCAL;
+       serial_drv->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
+
+       /* interface routines from the upper tty layer to the tty driver */
+       tty_set_operations(serial_drv, &fst_tty_ops);
+
+       /* register the TTY driver */
+       if (tty_register_driver(serial_drv)) {
+               pr_info("fsc: Failed to register serial driver!\n");
+               put_tty_driver(serial_drv);
+               return 0;
+       }
+       return 1;               /* OK */
+}
+
+int fst_tty_init(void)
+{
+       /* Load the tty driver
+        */
+       int retval = 0;
+
+       pr_info("Initialising flex tty driver\n");
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
+               fst_dbg(DBG_ASS, "fst_tty: open invalid flex minor %i\n",
+                       port_num);
+               return -ENODEV;
+       }
+
+       fst_tty = &fst_tty_area[port_num];
+       INIT_WORK(&fst_tty->fst_tty_work, fst_process_tty_work);
+       INIT_WORK(&fst_tty->fst_async_tty_work, fst_process_async_tty_work);
+
+       if (fst_tty->num_open == 0) {
+               /* We need to find the dev device and see if it is open
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
+                       /* It is likely that the network device is active
+                        * so refuse this open
+                        */
+                       return -EBUSY;
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
+               "%s: Initializing Flex TTY Sync Driver, tty major#%d minor#%i\n",
+                       fst_tty->name, FST_TTY_MAJOR, fst_tty->tty_minor);
+
+               /* Set a flag to indicate we are now using the char interface
+                * for data read and write
+                */
+               port->char_file = file;
+               /* Open the physical port if not already open
+                */
+               if (!port->port_mode)
+                       fst_openport(port);
+               fst_tty->port = port;
+               try_module_get(THIS_MODULE);
+               fst_tty_cnt++;
+               pr_info("TTY driver flex port %s is now open\n",
+                           fst_tty->name);
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
+               fst_dbg(DBG_ASS, "fst_tty: no Flex TTY in close\n");
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
+       module_put(THIS_MODULE);
+       pr_info("TTY driver flex port %s is now closed\n", fst_tty->name);
+       return;
+}
+
+static int fst_tty_write(struct tty_struct *tty, const unsigned char *buf,
+                        int count)
+{
+       /* Send data to the farsync port
+        */
+       st_fst_tty_area *fst_tty;
+       struct sk_buff *skb;
+       int retval;
+       int from_user = 0;
+
+       if (!tty || !tty->driver_data) {
+               fst_dbg(DBG_ASS, "Could not find Flex TTY device in write\n");
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
+                       "%s: discarding %d bytes of write data on a closed device\n",
+                       fst_tty->name, count);
+               return -ENODEV;
+       }
+       fst_dbg(DBG_TTY, "%s: fst_tty_write %s data len=%i\n", fst_tty->name,
+               (from_user) ? "from user" : "from kernel", count);
+       /* No special treatment for async mode, unlike farsync driver
+        */
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
+                       "%s: tty_write asked to transmit %d, transmitted %d\n",
+                       fst_tty->name, count, retval);
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
+       if (fst_tty->port->start)
+               room = 0;
+       fst_dbg(DBG_TTY, "%s: tty_write_room returning %d\n", fst_tty->name,
+               room);
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
+       fst_dbg(DBG_TTY, "%s: tty_chars_in_buffer returning 0\n",
+               fst_tty->name);
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
+                                          stop_bits, parity, rtscts | xonxoff);
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
+               outputs = OPSTS_RTS | fst_tty->port->v24OpSts;
+               fst_tty->port->v24OpSts = outputs;
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+
+       if (set & TIOCM_DTR) {
+               fst_dbg(DBG_TTY, "Set DTR\n");
+               outputs = OPSTS_DTR | fst_tty->port->v24OpSts;
+               fst_tty->port->v24OpSts = outputs;
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+
+       if (clear & TIOCM_RTS) {
+               fst_dbg(DBG_TTY, "Clear RTS\n");
+               outputs = OPSTS_RTS ^ fst_tty->port->v24OpSts;
+               fst_tty->port->v24OpSts = outputs;
+               if (fst_tty->port->run)
+                       fst_issue_cmd(fst_tty->port, SETV24O);
+       }
+       if (clear & TIOCM_DTR) {
+               fst_dbg(DBG_TTY, "Clear DTR\n");
+               outputs = OPSTS_DTR ^ fst_tty->port->v24OpSts;
+               fst_tty->port->v24OpSts = outputs;
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
+       signals = fst_tty->port->v24OpSts;
+       if (signals & OPSTS_RTS)
+               out |= TIOCM_RTS;
+       if (signals & OPSTS_DTR)
+               out |= TIOCM_DTR;
+       fst_issue_cmd(fst_tty->port, GETSIGNALS);
+       signals = fst_tty->port->v24IpSts;
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
+
+       st_fst_tty_area *fst_tty;
+       struct fst_port_info *port;
+       char *data;
+       int len;
+       struct tty_ldisc *ld;
+
+       if (fst_tty_cnt == 0)
+               return;
+
+       /* ToDo: Note that the third parameter to the ldisc receive_buf
+        * function is a pointer to an array of status bytes which is
+        * the same length as the data.  When we move on to getting the
+        * status bytes from the async interface we can implement this.
+        * For the moment it is a NULL pointer
+        */
+       fst_tty = container_of(work, st_fst_tty_area, fst_async_tty_work);
+       port = fst_tty->port;
+       len = fst_tty->len;
+       data = fst_tty->data;
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
+}
+
+static void fst_process_tty_work(struct work_struct *work)
+{
+       struct fst_port_info *port;
+       st_fst_tty_area *fst_tty;
+       struct sk_buff *skb;
+       struct tty_ldisc *ld;
+
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
+/* Card memory image access */
+static const struct file_operations fst_mem_fops = {
+};
+
+/*      Control signal change interrupt event
+ */
+static void
+fst_intr_ctlchg(struct fst_card_info *card, struct fst_port_info *port,
+               int signals)
+{
+       if (signals & (((port->hwif == X21) || (port->hwif == X21D))
+                      ? IPSTS_INDICATE : IPSTS_DCD)) {
+               if ((!netif_carrier_ok(port_to_dev(port)))
+                   && (!port->ignore_carrier)) {
+                       fst_dbg(DBG_ASS, "%s: DCD active\n", port->dev->name);
+                       netif_carrier_on(port_to_dev(port));
+                       fst_notify_state_change(card, port);
+               }
+       } else {
+               if ((netif_carrier_ok(port_to_dev(port)))
+                   && (!port->ignore_carrier)) {
+                       fst_dbg(DBG_ASS, "%s: DCD lost\n", port->dev->name);
+                       netif_carrier_off(port_to_dev(port));
+                       fst_notify_state_change(card, port);
+                       if (fst_tty_area[port->minor_dev_no].state ==
+                           FST_TTY_ST_DATA)
+                               tty_hangup(fst_tty_area
+                                          [port->minor_dev_no].tty);
+               }
+       }
+}
+
+/*      Log Rx Errors */
+static void
+fst_log_rx_error(struct fst_card_info *card, struct fst_port_info *port,
+                unsigned char status)
+{
+       /* Increment the appropriate error counter */
+       port_to_stats(port, rx_errors)++;
+       if (status & RX_FRAM) {
+               port_to_stats(port, rx_frame_errors)++;
+               printk_ratelimited("%s: Rx frame error %x\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (status & RX_OFLO) {
+               port_to_stats(port, rx_fifo_errors)++;
+               printk_ratelimited("%s: Rx fifo error %x\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (status & RX_CRC) {
+               port_to_stats(port, rx_crc_errors)++;
+               printk_ratelimited("%s: Rx crc error %x\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (status & RX_ABRT) {
+               port_to_stats(port, rx_length_errors)++;
+               printk_ratelimited("%s: Rx hardware error %x\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (port->notify_mode == FST_NOTIFY_EXTENDED)
+               fst_notify_state_change(port->card, port);
+}
+
+/*      Log Tx Errors */
+static void
+fst_log_tx_error(struct fst_card_info *card, struct fst_port_info *port,
+                unsigned char status)
+{
+       /* Increment the appropriate error counter
+        */
+       port_to_stats(port, tx_errors)++;
+       if (status & TX_URUN) {
+               port_to_stats(port, tx_fifo_errors)++;
+               printk_ratelimited("%s: Tx underrun error %d\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (status & TX_ABRT) {
+               port_to_stats(port, tx_aborted_errors)++;
+               printk_ratelimited("%s: Tx abort error %d\n",
+                                  port_to_dev(port)->name, status);
+       }
+       if (port->notify_mode == FST_NOTIFY_EXTENDED)
+               fst_notify_state_change(port->card, port);
+}
+
+static unsigned char reverse[256] = {
+       0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0, 0x10, 0x90, 0x50, 0xd0,
+       0x30, 0xb0, 0x70, 0xf0,
+       0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8, 0x18, 0x98, 0x58, 0xd8,
+       0x38, 0xb8, 0x78, 0xf8,
+       0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4, 0x14, 0x94, 0x54, 0xd4,
+       0x34, 0xb4, 0x74, 0xf4,
+       0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec, 0x1c, 0x9c, 0x5c, 0xdc,
+       0x3c, 0xbc, 0x7c, 0xfc,
+       0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2, 0x12, 0x92, 0x52, 0xd2,
+       0x32, 0xb2, 0x72, 0xf2,
+       0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea, 0x1a, 0x9a, 0x5a, 0xda,
+       0x3a, 0xba, 0x7a, 0xfa,
+       0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6, 0x16, 0x96, 0x56, 0xd6,
+       0x36, 0xb6, 0x76, 0xf6,
+       0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee, 0x1e, 0x9e, 0x5e, 0xde,
+       0x3e, 0xbe, 0x7e, 0xfe,
+       0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1, 0x11, 0x91, 0x51, 0xd1,
+       0x31, 0xb1, 0x71, 0xf1,
+       0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9, 0x19, 0x99, 0x59, 0xd9,
+       0x39, 0xb9, 0x79, 0xf9,
+       0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5, 0x15, 0x95, 0x55, 0xd5,
+       0x35, 0xb5, 0x75, 0xf5,
+       0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed, 0x1d, 0x9d, 0x5d, 0xdd,
+       0x3d, 0xbd, 0x7d, 0xfd,
+       0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3, 0x13, 0x93, 0x53, 0xd3,
+       0x33, 0xb3, 0x73, 0xf3,
+       0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb, 0x1b, 0x9b, 0x5b, 0xdb,
+       0x3b, 0xbb, 0x7b, 0xfb,
+       0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7, 0x17, 0x97, 0x57, 0xd7,
+       0x37, 0xb7, 0x77, 0xf7,
+       0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef, 0x1f, 0x9f, 0x5f, 0xdf,
+       0x3f, 0xbf, 0x7f, 0xff
+};
+
+void fst_reverse_bits(unsigned char *buff, int length)
+{
+       int i;
+
+       for (i = 0; i < length; i++)
+               buff[i] = reverse[buff[i]];
+       return;
+}
+
+#define usb_buffer_alloc usb_alloc_coherent
+#define usb_buffer_free usb_free_coherent
+
+static void deallocate_urbs_and_buffers(struct fst_card_info *dev)
+{
+       /* free up our allocated buffers */
+       fst_dbg(DBG_INIT, "Freeing a trace buffer at %p\n",
+               dev->int_in_buffer);
+       usb_buffer_free(dev->udev, dev->int_in_size,
+                       dev->int_in_buffer, dev->int_urb->transfer_dma);
+       fst_dbg(DBG_INIT, "Freeing a read buffer at %p\n",
+               dev->bulk_in_buffer);
+       usb_buffer_free(dev->udev, MAX_TRANSFER,
+                       dev->bulk_in_buffer, dev->bulk_urb->transfer_dma);
+       fst_dbg(DBG_INIT, "Freeing a write buffer at %p\n",
+               dev->bulk_out_buffer);
+       usb_buffer_free(dev->udev, MAX_TRANSFER, dev->bulk_out_buffer,
+                       dev->tx_bulk_urb->transfer_dma);
+       usb_free_urb(dev->int_urb);
+       usb_free_urb(dev->bulk_urb);
+       usb_free_urb(dev->tx_bulk_urb);
+}
+
+static int allocate_urbs_and_buffers(struct fst_card_info *dev)
+{
+       dev->int_urb = usb_alloc_urb(0, GFP_ATOMIC);
+       if (!dev->int_urb) {
+               fst_dbg(DBG_ASS, "Could not allocate interrupt urb\n");
+               return -ENOMEM;
+       }
+
+       dev->bulk_urb = usb_alloc_urb(0, GFP_ATOMIC);
+       if (!dev->bulk_urb) {
+               fst_dbg(DBG_ASS, "Could not allocate bulk urb\n");
+               usb_free_urb(dev->int_urb);
+               return -ENOMEM;
+       }
+       dev->tx_bulk_urb = usb_alloc_urb(0, GFP_ATOMIC);
+       if (!dev->tx_bulk_urb) {
+               fst_dbg(DBG_ASS, "Could not allocate tx bulk urb\n");
+               usb_free_urb(dev->int_urb);
+               usb_free_urb(dev->bulk_urb);
+               return -ENOMEM;
+       }
+
+       dev->int_in_buffer = usb_buffer_alloc(dev->udev,
+                                             dev->int_in_size, GFP_ATOMIC,
+                                             &dev->int_urb->transfer_dma);
+       if (!dev->int_in_buffer) {
+               usb_free_urb(dev->int_urb);
+               usb_free_urb(dev->bulk_urb);
+               usb_free_urb(dev->tx_bulk_urb);
+               return -ENOMEM;
+       }
+       fst_dbg(DBG_INIT, "Allocating a trace buffer at %p\n",
+               dev->int_in_buffer);
+       dev->bulk_in_buffer =
+           usb_buffer_alloc(dev->udev, MAX_TRANSFER, GFP_ATOMIC,
+                            &dev->bulk_urb->transfer_dma);
+       if (!dev->bulk_in_buffer) {
+               usb_buffer_free(dev->udev, dev->int_in_size,
+                               dev->int_urb->transfer_buffer,
+                               dev->int_urb->transfer_dma);
+               usb_free_urb(dev->int_urb);
+               usb_free_urb(dev->bulk_urb);
+               usb_free_urb(dev->tx_bulk_urb);
+               return -ENOMEM;
+       }
+       fst_dbg(DBG_INIT, "Allocating a read buffer at %p\n",
+               dev->bulk_in_buffer);
+       dev->bulk_out_buffer =
+           usb_buffer_alloc(dev->udev, MAX_TRANSFER, GFP_ATOMIC,
+                            &dev->tx_bulk_urb->transfer_dma);
+       if (!dev->bulk_out_buffer) {
+               usb_buffer_free(dev->udev, dev->int_in_size,
+                               dev->int_urb->transfer_buffer,
+                               dev->int_urb->transfer_dma);
+               usb_buffer_free(dev->udev, MAX_TRANSFER,
+                               dev->bulk_urb->transfer_buffer,
+                               dev->bulk_urb->transfer_dma);
+               usb_free_urb(dev->int_urb);
+               usb_free_urb(dev->bulk_urb);
+               usb_free_urb(dev->tx_bulk_urb);
+               return -ENOMEM;
+       }
+       fst_dbg(DBG_INIT, "Allocating a write buffer at %p\n",
+               dev->bulk_out_buffer);
+       return 0;
+}
+
+static void sync_write_bulk_callback(struct urb *urb)
+{
+       struct fst_card_info *dev;
+       struct fst_port_info *port;
+
+       dev = (struct fst_card_info *)urb->context;
+       port = dev->ports[0];
+       dev->tx_urb_cnt++;
+
+       /* sync/async unlink faults aren't errors */
+       if (urb->status &&
+           !(urb->status == -ENOENT ||
+             urb->status == -ECONNRESET || urb->status == -ESHUTDOWN)) {
+               pr_info("%s - nonzero write bulk status received: %d\n",
+                      __func__, urb->status);
+       }
+
+       if (urb != dev->tx_bulk_urb) {
+               fst_dbg(DBG_ASS,
+                       "Completion urb is not current outstanding urb\n");
+       }
+       /* Inc stats
+        */
+       port_to_stats(port, tx_packets)++;
+       port_to_stats(port, tx_bytes) += (urb->actual_length - 8);
+       port->dev->trans_start = jiffies;
+       /* Schedule another tx attempt
+        */
+       if ((port->run) && (!urb->status)) {
+               fst_q_work_item(&fst_work_txq, dev->card_no);
+               tasklet_schedule(&fst_tx_task);
+       } else {
+               fst_dbg(DBG_TX, "Not scheduling another send, port closed\n");
+       }
+       fst_dbg(DBG_TX, "Finished write bulk callback\n");
+}
+
+static void decode_header(char *buff, struct fst_card_info *card,
+                         struct fst_port_info *port)
+{
+       struct _FLEX_TXRX_PREAMBLE *header;
+       unsigned char status_ok_mask = 0xa0;
+
+       header = (struct _FLEX_TXRX_PREAMBLE *)buff;
+       flex_txrx_preamble_to_cpu(header);
+       if (header->port & 1) {
+               /* Ignore port B status change messages for now
+                * They shouldn't happen in the normal course of events
+                */
+               fst_dbg(DBG_ASS, "%s: Status message for port B %x\n",
+                       port_to_dev(port)->name, header->port);
+               return;
+       }
+       header->port = header->port & 0x0f0;
+       switch (header->port) {
+       case RXDATA_STATUS:
+               {
+                       if (port->mode == FST_MODE_TRANSPARENT)
+                               status_ok_mask = 0x80;
+                       header->status ^= status_ok_mask;
+                       if (header->status) {
+                               pr_err
+                                   ("%s: Rx Data status is %x should be %x\n",
+                                    port_to_dev(port)->name, header->status,
+                                    status_ok_mask);
+                               fst_log_rx_error(card, port,
+                                                header->status ^
+                                                status_ok_mask);
+                       }
+                       break;
+               }
+       case TXDATA_STATUS:
+               {
+                       if (header->status) {
+                               pr_err("%s: Tx Data status is %x\n",
+                                          port_to_dev(port)->name,
+                                          header->status);
+                               fst_log_tx_error(card, port, header->status);
+                       }
+                       break;
+               }
+       case SIGNAL_CHANGE:
+               {
+                       pr_err("%s: Signal Change Status status is %x\n",
+                                  port_to_dev(port)->name, header->status);
+                       fst_intr_ctlchg(card, port, header->status);
+                       break;
+               }
+       case TXRX_ERROR:
+               {
+                       printk_ratelimited("%s: TxRx error status is %x\n",
+                                          port_to_dev(port)->name,
+                                          header->status);
+                       fst_q_work_item(&fst_pstatsq, port->card->card_no);
+                       schedule_work(&port_stats_work_q);
+                       break;
+               }
+       default:
+               pr_err("%s: Unknown preamble status %x\n",
+                          port_to_dev(port)->name, header->port);
+       }
+}
+
+/* Mark it for our own raw sockets interface
+ */
+static __be16 farsync_type_trans(struct sk_buff *skb, struct net_device *dev)
+{
+       skb->dev = dev;
+       skb_reset_mac_header(skb);
+       skb->pkt_type = PACKET_HOST;
+       return htons(ETH_P_CUST);
+}
+
+static void sync_read_bulk_callback(struct urb *urb)
+{
+       st_fst_tty_area *fst_tty;
+
+       struct fst_card_info *dev;
+       struct fst_port_info *port;
+       int rx_status = NET_RX_SUCCESS;
+       __u16 *len_ptr;
+
+       dev = (struct fst_card_info *)urb->context;
+       port = dev->ports[0];
+
+       /* sync/async unlink faults aren't errors */
+       if (urb->status &&
+           !(urb->status == -ENOENT || urb->status == -ECONNRESET)) {
+               pr_info("%s - nonzero read bulk status received: %d\n",
+                      __func__, urb->status);
+               return;
+       }
+
+       len_ptr = (u16 *) &(dev->bulk_in_buffer[4]);
+       dev->actual_length = le16_to_cpu(*len_ptr);
+       fst_dbg(DBG_RX, "Length of data in hdr is %d\n", dev->actual_length);
+       fst_dbg(DBG_RX, "Length of data from urb is %d\n", urb->actual_length);
+       fst_dbg(DBG_RX, "Header is %x %x %x %x %x %x %x %x\n",
+               dev->bulk_in_buffer[0], dev->bulk_in_buffer[1],
+               dev->bulk_in_buffer[2], dev->bulk_in_buffer[3],
+               dev->bulk_in_buffer[4], dev->bulk_in_buffer[5],
+               dev->bulk_in_buffer[6], dev->bulk_in_buffer[7]);
+       decode_header(dev->bulk_in_buffer, dev, port);
+       if (dev->actual_length != urb->actual_length - 8) {
+               fst_dbg(DBG_RX,
+                       "Urb reports different length to header %d %d\n",
+                       urb->actual_length, dev->actual_length);
+       }
+       if (dev->actual_length > port->dev->mtu + MAX_PPP_HEADER) {
+               fst_dbg(DBG_ASS, "%s: Received frame longer %d than MTU %d\n",
+                       port->dev->name, dev->actual_length, port->dev->mtu);
+               post_a_read_bulk_urb(dev);      /* Post a read for data */
+               return;
+       }
+       if (port->mode == FST_MODE_ASYNC) {
+               if (dev->actual_length) {
+                       fst_tty = &fst_tty_area[port->minor_dev_no];
+                       fst_tty->len = dev->actual_length;
+                       fst_tty->data = &dev->bulk_in_buffer[8];
+                       schedule_work(&(fst_tty->fst_async_tty_work));
+               }
+               post_a_read_bulk_urb(dev);      /* Post a read for data */
+               return;
+       }
+       if ((dev->actual_length > 0) && (port->run)) {
+               port->rxq.frame = dev_alloc_skb(port->dev->mtu);
+               if (port->rxq.frame == NULL) {
+                       fst_dbg(DBG_ASS, "intr_rx: can't allocate buffer\n");
+                       port_to_stats(port, rx_dropped)++;
+                       port->rxq.error_recovery++;
+                       return;
+               }
+               port->rxq.flags = 0;
+               port->rxq.count = dev->actual_length;
+               port->rxq.segment_cnt = 1;
+               /* If we need to reverse the bits, then this is where we do it
+                */
+               if (port->receive_msb_first) {
+                       fst_reverse_bits(&dev->bulk_in_buffer[8],
+                                        dev->actual_length);
+               }
+               memcpy(skb_put(port->rxq.frame, dev->actual_length),
+                      &(dev->bulk_in_buffer[8]), dev->actual_length);
+               port_to_stats(port, rx_bytes) += dev->actual_length;
+               port_to_stats(port, rx_packets)++;
+               fst_dbg(DBG_RX, "Pushing frame up the stack %d bytes\n",
+                       dev->actual_length);
+               /* Push upstream */
+               skb_reset_mac_header(port->rxq.frame);
+               port->rxq.frame->dev = port->dev;
+               if (port->proto == FST_RAW)
+                       port->rxq.frame->protocol =
+                         farsync_type_trans(port->rxq.frame,
+                                            port_to_dev(port));
+               else {
+                       if (port->char_file) {
+                               port->rxq.frame->protocol =
+                                   htons(ETH_P_WAN_PPP);
+                       } else {
+                               if (port->hdlc_proto == IF_PROTO_HDLC) {
+                                       port->rxq.frame->protocol =
+                                           htons(ETH_P_IP);
+                               } else {
+                                       if (port->hdlc_proto ==
+                                           IF_PROTO_HDLC_ETH) {
+                                               port->rxq.frame->protocol =
+                                                   htons(ETH_P_8021Q);
+                                       } else {
+                                               port->rxq.frame->protocol =
+                                                   hdlc_type_trans(port->
+                                                                   rxq.frame,
+                                                                   port_to_dev
+                                                                   (port));
+                                       }
+                               }
+                       }
+               }
+               if (port->monitor_mode)
+                       gen_mon_packet(port->rxq.frame, port, FST_MON_RX);
+               if (port->run) {
+                       /* Char or network interface?
+                        */
+                       if (port->char_file) {
+                               st_fst_tty_area *fst_tty;
+                               fst_tty = &fst_tty_area[port->minor_dev_no];
+                               fst_tty->skb = port->rxq.frame;
+                               schedule_work(&(fst_tty->fst_tty_work));
+
+                       } else {
+                               if (port->run)
+                                       rx_status = netif_rx(port->rxq.frame);
+                               else {
+                                       dev_kfree_skb(port->rxq.frame);
+                                       fst_dbg(DBG_ASS,
+                                       "Discarding frame, port closed\n");
+                               }
+                               fst_process_rx_status(rx_status,
+                                                     port->dev->name);
+                       }
+                       if (rx_status == NET_RX_DROP)
+                               port_to_stats(port, rx_dropped)++;
+                       port->dev->last_rx = jiffies;
+               } else {
+                       fst_dbg(DBG_RX,
+                               "Frame received after port closed. Ignored %d\n",
+                               dev->actual_length);
+                       dev_kfree_skb(port->rxq.frame);
+               }
+               port->rxq.frame = NULL;
+       } else {
+               fst_dbg(DBG_RX, "Ignoring a zero length urb\n");
+       }
+       post_a_read_bulk_urb(dev);      /* Post a read for data */
+}
+
+static void sync_read_int_callback(struct urb *urb)
+{
+       struct fst_card_info *dev;
+
+       fst_dbg(DBG_RX, "In read int callback\n");
+       dev = (struct fst_card_info *)urb->context;
+
+       /* sync/async unlink faults aren't errors */
+       if (urb->status &&
+           !(urb->status == -ENOENT || urb->status == -ECONNRESET)) {
+               pr_info("%s - nonzero read int status received: %d\n",
+                      __func__, urb->status);
+               return;
+       }
+       dev->usb_trace_buffer[dev->usb_trace_ptr++] = dev->int_in_buffer[0];
+       if (dev->int_in_buffer[0] == 0) {
+               pr_info("fst_usb_trace: %s", dev->usb_trace_buffer);
+               dev->usb_trace_ptr = 0;
+       }
+       if (urb->actual_length)
+               post_a_read_int_urb(dev);
+}
+
+static int post_a_read_int_urb(struct fst_card_info *usb_dev)
+{
+       int retval;
+       struct urb *urb = NULL;
+
+       urb = usb_dev->int_urb;
+
+       /* initialize the urb properly */
+       usb_fill_int_urb(urb, usb_dev->udev,
+                        usb_rcvintpipe(usb_dev->udev,
+                                       usb_dev->int_in_endpoint_addr),
+                        usb_dev->int_in_buffer, usb_dev->int_in_size,
+                        sync_read_int_callback,
+                        usb_dev, usb_dev->int_interval);
+       urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+       urb->transfer_flags |= URB_ZERO_PACKET;
+
+       /* post a read on the int in port */
+       retval = usb_submit_urb(urb, GFP_ATOMIC);
+       if (retval) {
+               pr_err("%s - failed submitting an int read urb, error %d",
+                          __func__, retval);
+               return retval;
+       }
+
+       return 0;
+}
+
+static int post_a_read_bulk_urb(struct fst_card_info *usb_dev)
+{
+       int retval;
+       int read_length;
+       struct urb *urb = NULL;
+
+       urb = usb_dev->bulk_urb;
+       read_length = usb_dev->ports[0]->rx_buffer_size + 8;
+
+       /* initialize the urb properly */
+       usb_fill_bulk_urb(urb, usb_dev->udev,
+                         usb_rcvbulkpipe(usb_dev->udev,
+                                         usb_dev->bulk_in_endpoint_addr),
+                         usb_dev->bulk_in_buffer, read_length,
+                         sync_read_bulk_callback, usb_dev);
+       urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+
+       /* post a read on the bulk in port */
+       retval = usb_submit_urb(urb, GFP_ATOMIC);
+       if (retval) {
+               pr_err("%s - failed submitting aread bulk urb, error %d",
+                          __func__, retval);
+               return retval;
+       }
+
+       return 0;
+}
+
+static void fst_q_work_item(u64 *queue, int card_index)
+{
+       unsigned long flags;
+       u64 mask;
+
+       /* Grab the queue exclusively
+        */
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
+static void fst_process_threshold_work_q(struct work_struct *work)
+{
+       unsigned long flags;
+       u64 workq;
+       int i;
+       struct fst_port_info *port;
+
+       /* Grab the queue exclusively
+        */
+       fst_dbg(DBG_TX, "fst_process_threshold_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       workq = fst_threshq;
+       fst_threshq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+       /* Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (workq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               port = fst_cards_list[i]->ports[0];
+                               fst_dbg(DBG_TX,
+                                       "Calling issue command to set signals on %d\n",
+                                       i);
+                               if (port->usb_config.flow_control ==
+                                   COM_FLOW_CONTROL_RTSCTS)
+                                       fst_issue_cmd(port, SETV24O);
+                               if (port->usb_config.flow_control ==
+                                   COM_FLOW_CONTROL_XONXOFF) {
+                                       if (port->v24OpSts & OPSTS_RTS)
+                                               fst_issue_cmd(port, SETXON);
+                                       else
+                                               fst_issue_cmd(port, SETXOFF);
+                               }
+                       }
+               }
+               workq = workq >> 1;
+       }
+}
+
+static void fst_process_port_stats_work_q(struct work_struct *work)
+{
+       unsigned long flags;
+       u64 workq;
+       int i;
+       struct fst_port_info *port;
+
+       /* Grab the queue exclusively
+        */
+       fst_dbg(DBG_TX, "fst_process_port_stats_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       workq = fst_pstatsq;
+       fst_pstatsq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+       /* Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (workq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               port = fst_cards_list[i]->ports[0];
+                               fst_dbg(DBG_TX,
+                               "Calling issue command to get port stats on %d\n",
+                                       i);
+                               fst_issue_cmd(port, GETPORTSTATS);
+                               fst_dbg(DBG_TX,
+                               "Calling issue command to reset port stats on %d\n",
+                                       i);
+                               fst_issue_cmd(port, RESETPORTSTATS);
+                       }
+               }
+               workq = workq >> 1;
+       }
+}
+
+static void fst_process_tx_work_q(unsigned long work_q)
+{
+       unsigned long flags;
+       u64 work_txq;
+       int i;
+
+       /* Grab the queue exclusively
+        */
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
+       /* Grab the queue exclusively
+        */
+       fst_dbg(DBG_INTR, "fst_process_int_work_q\n");
+       spin_lock_irqsave(&fst_work_q_lock, flags);
+       work_intq = fst_work_intq;
+       fst_work_intq = 0;
+       spin_unlock_irqrestore(&fst_work_q_lock, flags);
+
+       /* Call the bottom half for each card with work waiting
+        */
+       for (i = 0; i < FST_MAX_CARDS; i++) {
+               if (work_intq & 0x01) {
+                       if (fst_cards_list[i] != NULL) {
+                               fst_dbg(DBG_INTR,
+                                       "Calling rx & tx bh for card %d\n", i);
+                               do_bottom_half_rx(fst_cards_list[i]);
+                               /*  Calling the tx BH directly could mean that
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
+static int fst_proc_info(struct seq_file *m, void *v)
+{
+       struct seq_file *buffer = m;
+       struct fst_card_info *card;
+       int c;
+       int port_count = 0;
+
+       seq_printf(buffer,
+                "FarSync Flex %s Driver version %s - Patch Level %s - Build %s\n",
+                FST_DRIVER_TYPE, FST_USER_VERSION, FST_PATCH_LEVEL,
+                FST_ADDITIONAL);
+       seq_printf(buffer, "%d Cards found\n", fst_ncards);
+       for (c = 0; c < FST_MAX_CARDS; c++) {
+               card = fst_cards_list[c];
+               if (card) {
+                       seq_printf(buffer,
+                                "\t%s-%s: %s (%s),\t%d ports,  State: %s\n",
+                                port_to_dev(card->ports[0])->name,
+                                port_to_dev(card->
+                                            ports[card->nports - 1])->name,
+                                type_strings[card->type],
+                                card->ports[0]->usb_card_info.sz_serial_no,
+                                card->nports, state_strings[card->state]);
+                       port_count += card->nports;
+               }
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
+                       /* Nothing to do here */
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
+       /* Setup the header
+        */
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
+static void
+fst_notify_state_change(struct fst_card_info *card, struct fst_port_info *port)
+{
+       struct sk_buff *skb;
+       int rx_status = NET_RX_SUCCESS;
+
+       fst_dbg(DBG_INTR, "fst_notify_state_change: %s\n",
+               port_to_dev(port)->name);
+       if (port->notify_mode) {
+               /*
+                * Notify mode is on.  Basic or Extended?
+                */
+               if (port->notify_mode == FST_NOTIFY_EXTENDED) {
+                       /*
+                        * Just signal select that something has happened
+                        */
+                       port->exception++;
+                       wake_up_interruptible(&port->pollq);
+                       return;
+               }
+               /* Basic mode is send up a zero length message
+                * Note that we can't do this for the async interface
+                * How do you write a zero length message into a fifo?
+                */
+               if (port->mode == FST_MODE_ASYNC)
+                       return;
+               /*
+                * Otherwise proceed.  Allocate the SKB
+                */
+               skb = dev_alloc_skb(0);
+               if (skb == NULL) {
+                       fst_dbg(DBG_INTR,
+                               "notify_state_change: can't allocate skb\n");
+               }
+
+               /* We know the length we need to receive, = 0
+                */
+               skb_put(skb, 0);
+
+               /* Push upstream */
+               fst_dbg(DBG_INTR, "Pushing frame up the stack\n");
+               if (port->proto == FST_HDLC || port->proto == FST_PPP) {
+                       /* Mark for further processing by sPPP module */
+                       skb->protocol = htons(ETH_P_WAN_PPP);
+               } else {
+                       /* DEC customer specific protocol (since nothing
+                        * defined for marking raw data), at least one other
+                        * driver uses this value for this purpose.
+                        */
+                       skb->protocol = htons(ETH_P_CUST);
+                       skb->pkt_type = PACKET_HOST;
+               }
+               skb_reset_mac_header(skb);
+               skb->dev = port_to_dev(port);
+               if (port->char_file) {
+                       st_fst_tty_area *fst_tty;
+                       fst_tty = &fst_tty_area[port->minor_dev_no];
+                       fst_tty->skb = skb;
+
+                       schedule_work(&(fst_tty->fst_tty_work));
+               } else {
+                       if (port->run) {
+                               rx_status = netif_rx(skb);
+                       } else {
+                               dev_kfree_skb(skb);
+                               fst_dbg(DBG_ASS,
+                                       "Discarding state change message, port closed\n");
+                       }
+                       fst_process_rx_status(rx_status,
+                                             port_to_dev(port)->name);
+               }
+               if (rx_status == NET_RX_DROP) {
+                       fst_dbg(DBG_ASS,
+                               "Could not deliver state change message");
+               }
+       } else {
+               fst_dbg(DBG_INTR, "Notify mode not on\n");
+       }
+
+}
+
+#define CMD_BUF_LEN 4
+/*      Issue a Mailbox command for a port.
+ *      Note we issue them on a fire and forget basis, not expecting to see an
+ *      error and not waiting for completion.
+ */
+static void fst_issue_cmd(struct fst_port_info *port, unsigned short cmd)
+{
+       struct fst_card_info *usb_dev;
+       int retval;
+       char sigs[CMD_BUF_LEN];
+
+       usb_dev = port->card;
+       switch (cmd) {
+       case STARTPORT:
+               {
+                       fst_dbg(DBG_CMD, "Sending start port\n");
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_START_PORT, 0x40, 0, 0,
+                                                NULL, 0, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD,
+                                       "Start port response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Start port error errno = %d\n",
+                                       retval);
+                       }
+                       break;
+               }
+
+       case STOPPORT:
+               {
+                       fst_dbg(DBG_CMD, "Sending stop port\n");
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_STOP_PORT, 0x40, 0, 0,
+                                                NULL, 0, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD,
+                                       "Stop port response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Stop port error errno = %d\n",
+                                       retval);
+                       }
+                       break;
+               }
+       case ASSERTSIGNALS:
+               {
+                       sigs[0] = 0x03;
+                       sigs[1] = 0x00;
+                       sigs[2] = 0x00;
+                       sigs[3] = 0x00;
+
+                       fst_dbg(DBG_CMD, "Raising control signals\n");
+
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SET_SIGNALS, 0x40, 0,
+                                                0, &sigs, CMD_BUF_LEN, 10000);
+
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_CMD,
+                                       "Set signals up response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set signals up error errno = %d\n",
+                                       retval);
+                       }
+                       port->v24OpSts = 0x3;
+                       break;
+               }
+       case RELEASESIGNALS:
+               {
+                       sigs[0] = 0x00;
+                       sigs[1] = 0x00;
+                       sigs[2] = 0x00;
+                       sigs[3] = 0x00;
+                       fst_dbg(DBG_CMD, "Lowering control signals\n");
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SET_SIGNALS, 0x40, 0,
+                                                0, &sigs, CMD_BUF_LEN, 10000);
+
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_CMD,
+                               "Set signals down response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set signals down error errno = %d\n",
+                                       retval);
+                       }
+                       port->v24OpSts = 0;
+                       break;
+               }
+       case GETSIGNALS:
+               {
+                       int data = 0;
+                       fst_dbg(DBG_CMD, "Getting control signals\n");
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_rcvctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_GET_SIGNALS, 0xC0, 0,
+                                                0, &data, 4, 10000);
+                       le32_to_cpus(&data);
+                       if (retval == 4) {
+                               fst_dbg(DBG_CMD,
+                                       "Get signals response received %x\n",
+                                       data);
+                               port->v24IpSts = data & 0x0f;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Get signals error errno = %d\n",
+                                       retval);
+                       }
+                       break;
+               }
+       case SETSIGNALS:
+               {
+                       int data = port->v24OpSts;
+
+                       fst_dbg(DBG_CMD, "Setting control signals\n");
+                       cpu_to_le32s(&data);
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SET_SIGNALS, 0x40, 0,
+                                                0, &data, CMD_BUF_LEN, 10000);
+                       le32_to_cpus(&data);
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_CMD,
+                                       "Set signals response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set signals up error errno = %d\n",
+                                       retval);
+                       }
+                       break;
+               }
+
+       case RECONFIG:
+               {
+                 fst_dbg(DBG_CMD, "%s: Sending Reconfig async port\n",
+                              port->dev->name);
+               }
+               break;
+
+       case FLUSHBUFFERS:
+               {
+                       int data = 0x03;
+                       fst_dbg(DBG_CMD, "%s: Sending flush buffer\n",
+                               port->dev->name);
+
+                       cpu_to_le32s(&data);
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_FLUSH_BUFFERS, 0x40, 0,
+                                                0, &data, CMD_BUF_LEN, 10000);
+                       le32_to_cpus(&data);
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_CMD,
+                                       "Flush buffers response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Flush Buffers error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case SETPRESERVE:
+               {
+                       int data = 1;
+
+                       fst_dbg(DBG_CMD, "Setting preserve control signals\n");
+                       cpu_to_le32s(&data);
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SET_PRESERVE_SIGNALS,
+                                                0x40, 0, 0, &data, CMD_BUF_LEN,
+                                                10000);
+                       le32_to_cpus(&data);
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_CMD,
+                               "Set Preserve Signals response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                               "Set Preserve Signals up error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case GETPRESERVE:
+               {
+                       int data = 0;
+                       fst_dbg(DBG_CMD, "Getting Preserve Signals\n");
+                       cpu_to_le32s(&data);
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_rcvctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_GET_PRESERVE_SIGNALS,
+                                                0xC0, 0, 0, &data, 4, 10000);
+                       le32_to_cpus(&data);
+                       if (retval == 4) {
+                               fst_dbg(DBG_CMD,
+                               "Get Preserve Signals response received %x\n",
+                                       data);
+                               if (data)
+                                       port->v24OpSts |= 0x0100;
+                               else
+                                       port->v24OpSts &= !0x0100;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                               "Get Preserve Signals error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case SETXON:
+               {
+                       fst_dbg(DBG_CMD, "%s: Sending XON Command\n",
+                               port->dev->name);
+
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SEND_XON, 0x40, 0, 0,
+                                                NULL, 0, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD, "XON response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS, "Set XON error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case SETXOFF:
+               {
+                       fst_dbg(DBG_CMD, "%s: Sending XOFF Command\n",
+                               port->dev->name);
+
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SEND_XOFF, 0x40, 0, 0,
+                                                NULL, 0, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD, "XOFF response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS, "Set XOFF error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case GETPORTSTATS:
+               {
+                       IREX stats;
+                       unsigned char tx_status = 0;
+                       unsigned char rx_status = 0;
+
+                       fst_dbg(DBG_CMD, "%s: Sending GETPORTSTATS Command\n",
+                               port->dev->name);
+                       flex_irex_to_le(&stats);
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_rcvctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_GET_PORT_STATS, 0xC0,
+                                                0, 0, &stats, sizeof(IREX),
+                                                10000);
+                       flex_irex_to_cpu(&stats);
+                       if (retval == sizeof(IREX)) {
+                               fst_dbg(DBG_CMD,
+                                       "GETPORTSTATS response received\n");
+                               fst_dbg(DBG_CMD, "Status count = %d\n",
+                                       stats.interface_record.status_count);
+                               fst_dbg(DBG_CMD, "v24_in = %x  ",
+                                       stats.interface_record.v24_in);
+                               fst_dbg(DBG_CMD, "v24_out = %x\n",
+                                       stats.interface_record.v24_out);
+                               if (stats.interface_record.status_array[0]) {
+                                       fst_dbg(DBG_CMD, "%s: Rx CRC\n",
+                                               port->dev->name);
+                                       rx_status |= RX_CRC;
+                               }
+                               if (stats.interface_record.status_array[1]) {
+                                       fst_dbg(DBG_CMD, "%s: Rx Overflow\n",
+                                               port->dev->name);
+                                       rx_status |= RX_OFLO;
+                               }
+                               if (stats.interface_record.status_array[2]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: Rx frame less than 4 bytes\n",
+                                               port->dev->name);
+                                       rx_status |= RX_FRAM;
+                               }
+                               if (stats.interface_record.status_array[3]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: Rx ending on non octet boundary\n",
+                                               port->dev->name);
+                                       rx_status |= RX_FRAM;
+                               }
+                               if (stats.interface_record.status_array[4]) {
+                                       fst_dbg(DBG_CMD,
+                                               "%s: Rx Aborted frame\n",
+                                               port->dev->name);
+                                       rx_status |= RX_ABRT;
+                               }
+                               if (stats.interface_record.status_array[5]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: Tranmitter Interrupt underrun\n",
+                                               port->dev->name);
+                                       tx_status |= TX_URUN;
+                               }
+                               if (stats.interface_record.status_array[6]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: Reciever Interrupt overrun\n",
+                                               port->dev->name);
+                                       rx_status |= RX_OFLO;
+                               }
+                               if (stats.interface_record.status_array[7]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: DCD lost during frame reception\n",
+                                               port->dev->name);
+                               }
+                               if (stats.interface_record.status_array[8]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: CTS lost while transmitting\n",
+                                               port->dev->name);
+                               }
+                               if (stats.interface_record.status_array[9]) {
+                                       fst_dbg(DBG_CMD, "%s: DSR dropped\n",
+                                               port->dev->name);
+                               }
+                               if (stats.interface_record.status_array[10]) {
+                                       fst_dbg(DBG_CMD,
+                                       "%s: Hardware Adapter Failure\n",
+                                               port->dev->name);
+                               }
+                               if (rx_status)
+                                       fst_log_rx_error(usb_dev, port,
+                                                        rx_status);
+                               if (tx_status)
+                                       fst_log_tx_error(usb_dev, port,
+                                                        tx_status);
+                       } else {
+                               fst_dbg(DBG_CMD,
+                                       "Set GETPORTSTATS error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       case RESETPORTSTATS:
+               {
+                       fst_dbg(DBG_CMD,
+                               "%s: Sending RESETPORTSTATS Command\n",
+                               port->dev->name);
+
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_RESET_PORT_STATS, 0x40,
+                                                0, 0, NULL, 0, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD,
+                                       "RESETPORTSTATS response received\n");
+                       } else {
+                         fst_dbg(DBG_CMD,
+                                 "Set RESETPORTSTATS error errno = %d\n",
+                                      retval);
+                       }
+               }
+               break;
+
+       case SETLINESPEED:
+               {
+                       fst_dbg(DBG_CMD, "%s: Setting the line speed\n",
+                               port->dev->name);
+
+                       retval = usb_control_msg(usb_dev->udev,
+                                                usb_sndctrlpipe(usb_dev->udev,
+                                                                0),
+                                                USS_CMD_SET_LINESPEED, 0x40,
+                                                0, 0,
+                                                &port->usb_config.line_speed,
+                                                4, 10000);
+                       if (retval == 0) {
+                               fst_dbg(DBG_CMD,
+                                       "set LINESPEED response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set LINESPEED error errno = %d\n",
+                                       retval);
+                       }
+               }
+               break;
+
+       default:
+               pr_err("Invalid Isuue Command %d\n", cmd);
+       }
+}
+
+/*      Port output signals control
+ */
+static inline void
+fst_op_raise(struct fst_port_info *port, unsigned int outputs)
+{
+       outputs |= port->v24OpSts;
+       port->v24OpSts = outputs;
+       if (port->run)
+               fst_issue_cmd(port, ASSERTSIGNALS);
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
+       int preserve = port->v24OpSts & 0x100;
+
+       fst_dbg(DBG_ASS, "Preserve signals = %d\n", preserve);
+       outputs = ~(outputs & port->v24OpSts);
+       port->v24OpSts = outputs & 0x03;
+       if (preserve)
+               fst_dbg(DBG_ASS, "%s: Leaving signals alone\n",
+                       port->dev->name);
+       else {
+               /* Need to lower control signals here, if we are not
+                * in the preserve signals mode
+                */
+               fst_dbg(DBG_ASS, "%s: Lowering signals\n", port->dev->name);
+               fst_issue_cmd(port, RELEASESIGNALS);
+
+               /* If we are in ignore carrier mode, then now is the
+                * time to tell the network layer that carrier is off
+                */
+               if (port->ignore_carrier)
+                       netif_carrier_off(port_to_dev(port));
+       }
+}
+
+/*      Setup port Rx buffers */
+static void fst_rx_config(struct fst_port_info *port)
+{
+       int pi;
+       struct fst_card_info *card;
+
+       pi = port->index;
+       card = port->card;
+}
+
+/*      Setup port Tx buffers */
+static void fst_tx_config(struct fst_port_info *port)
+{
+       int pi;
+       struct fst_card_info *card;
+
+       pi = port->index;
+       card = port->card;
+}
+
+/*      Check that the shared memory configuration is one that we can handle
+ *      and that some basic parameters are correct
+ */
+static void check_started_ok(struct fst_card_info *card)
+{
+       return;
+
+}
+
+static void do_bottom_half_tx(struct fst_card_info *card)
+{
+       struct fst_port_info *port;
+       int retval = 0;
+       struct urb *urb = NULL;
+       char *buf = NULL;
+       size_t writesize;
+       int pi;
+       int txq_length;
+       struct sk_buff *skb;
+       unsigned long flags;
+       int tx_length;
+       __u16 *len_ptr;
+
+       /* Find a free buffer for the transmit
+        * Step through each port on this card
+        */
+
+       fst_dbg(DBG_TX, "do_bottom_half_tx\n");
+       for (pi = 0; pi < card->nports; pi++) {
+               port = card->ports[pi];
+               if ((port->dev == NULL) || (!port->run))
+                       continue;
+
+               if (card->tx_urb_cnt <= 0) {
+                       fst_dbg(DBG_TX,
+                               "Max URBs in progress limit reached\n");
+                       return;
+               }
+
+               spin_lock_irqsave(&card->card_lock, flags);
+               txq_length = port->txqe - port->txqs;
+               if (txq_length < 0) {
+                       /* This is the case where one has wrapped and the
+                        * maths gives us a negative number
+                        */
+                       txq_length = txq_length + FST_TXQ_DEPTH;
+               }
+               spin_unlock_irqrestore(&card->card_lock, flags);
+               if (txq_length > 0) {
+                       /* There is something to send
+                        */
+                       skb = port->txq[port->txqs].frame;
+
+                       /* Decrement the segment count.  It tells us how
+                        * many more bits to the frame there are left to do
+                        */
+                       port->txq[port->txqs].segment_cnt--;
+                       tx_length = skb->len;
+                       port->txq[port->txqs].current_seg++;
+
+                       writesize =
+                          min_t(size_t, (size_t) tx_length + 8,
+                               (size_t) port->tx_buffer_size + 8);
+                       /* copy the data and set the required indicators on the
+                        * card.
+                        */
+
+                       /* verify that we actually have some data to write */
+                       if (tx_length == 0)
+                               goto exit;
+
+                       urb = card->tx_bulk_urb;
+                       buf = card->bulk_out_buffer;
+
+                       memcpy(&buf[8], skb->data, tx_length);
+                       /* If we need to reverse the bits, this is where we
+                        * do it
+                        */
+                       if (port->transmit_msb_first)
+                               fst_reverse_bits(&buf[8], tx_length);
+                       /* Set the length in the pre-able
+                        */
+                       len_ptr = (__u16 *) &buf[4];
+                       *len_ptr = cpu_to_le16((__u16) tx_length);
+                       /* initialize the urb properly */
+                       usb_fill_bulk_urb(urb, card->udev,
+                               usb_sndbulkpipe(card->udev,
+                                               card->bulk_out_endpoint_addr),
+                                         buf, writesize,
+                                         sync_write_bulk_callback, card);
+                       urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+
+                       /* send the data out the bulk port */
+                       retval = usb_submit_urb(urb, GFP_ATOMIC);
+                       if (retval) {
+                               pr_err("%s - failed submitting , ", __func__);
+                               pr_err("write urb error %d", retval);
+                               port->txqs++;
+                               if (port->txqs == FST_TXQ_DEPTH)
+                                       port->txqs = 0;
+                               goto exit;
+                       } else {
+                               card->tx_urb_cnt--;
+                       }
+                       wake_up_interruptible(&port->writeq);
+                       spin_lock_irqsave(&card->card_lock, flags);
+                       port->txqs++;
+                       if (port->txqs == FST_TXQ_DEPTH)
+                               port->txqs = 0;
+                       if (port->txqs == port->txqe) {
+                               fst_dbg(DBG_TX,
+                               "Card %d Port %d: Tx queue Now empty\n",
+                                       card->card_no, port->index);
+                               fst_notify_state_change(card, port);
+                               wake_up_interruptible(&port->pollq);
+                       }
+                       spin_unlock_irqrestore(&card->card_lock, flags);
+                       /* If we have flow control on, can we now release it?
+                        */
+                       if (port->start) {
+                               if (txq_length < fst_txq_low) {
+                                       fst_dbg(DBG_ASS,
+                                       "%s: Start the network layer\n",
+                                               port->dev->name);
+                                       if (!port->char_file) {
+                                               netif_wake_queue(port->dev);
+                                       } else {
+                                               st_fst_tty_area *fst_tty;
+                                               fst_tty =
+                                                   &fst_tty_area[port->index];
+                                               fst_dbg(DBG_TTY,
+                                               "%s: Waking up tty writes\n",
+                                                       fst_tty->name);
+                                               tty_wakeup(fst_tty->tty);
+                                       }
+                                       port->start = 0;
+                               }
+                       }
+exit:
+                       dev_kfree_skb(skb);
+                       return;
+               } else {
+                       /* Nothing to send so break out of the while loop
+                        */
+                       break;
+               }
+               if (++port->txpos >= port->num_tx_buffers)
+                       port->txpos = 0;
+       }
+       return;
+}
+
+static void do_bottom_half_rx(struct fst_card_info *card)
+{
+       fst_dbg(DBG_ASS, "Do bottom half rx\n");
+       return;
+}
+
+static int check_combination(int num, int size)
+{
+       /* Check that the number and size do not exceed the following table
+        *
+        *   num of buffs            max size
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
+                       pr_err("Number of buffers must be 2,4,8,16,32,64, ");
+                       pr_err("or 128 : %d\n",
+                            num);
+                       err++;
+               }
+       }
+       if (err)
+               return 1;
+       return 0;
+}
+
+static int validate_buffer_config(struct fstioc_info *info)
+{
+       /* We need some checks on buffer configurations because the
+        * card itself doesn't do any
+        */
+       if ((info->num_tx_buffers == 0) || (info->num_rx_buffers == 0)) {
+               pr_err("Num Tx Buffers or Num Rx Buffers is zero\n");
+               return 1;
+       }
+       if ((info->num_tx_buffers == 1) || (info->num_rx_buffers == 1)) {
+               pr_err("Num Tx Buffers or Num Rx Buffers is 1\n");
+               return 1;
+       }
+       if ((info->num_tx_buffers > 128) || (info->num_rx_buffers > 128)) {
+               pr_err("Num Tx Buffers or Num Rx Buffers > 128\n");
+               return 1;
+       }
+       if ((info->tx_buffer_size == 0) || (info->rx_buffer_size == 0)) {
+               pr_err("Tx Buffer Size or Rx Buffer Size is zero\n");
+               return 1;
+       }
+       if ((info->tx_buffer_size > 32 * 1024)
+           || (info->rx_buffer_size > 32 * 1024)) {
+               pr_err("Tx Buffer Size or Rx Buffer Size > 32*1024\n");
+               return 1;
+       }
+       if (check_combination(info->num_tx_buffers, info->tx_buffer_size)) {
+               pr_err("Invalid num/size combination on Tx Buffers\n");
+               return 1;
+       }
+       if (check_combination(info->num_rx_buffers, info->rx_buffer_size)) {
+               pr_err("Invalid num/size combination on Rx Buffers\n");
+               return 1;
+       }
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
+               /*This is the case where the next free has wrapped but the
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
+              port->dev->name, txq_length);
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
+               fst_dbg(DBG_ASS, "Custom clock rate structure is not the ");
+               fst_dbg(DBG_ASS, "version expected %d %d\n",
+                       FST_CUSTOM_RATE_CONFIG_VERSION,
+                       custom_clock_rate->version);
+               return 1;
+       }
+       if (!((custom_clock_rate->multiplier ==
+              (FST_CUSTOM_CLOCK_MULTIPLIER_1))
+             || (custom_clock_rate->multiplier ==
+                 (FST_CUSTOM_CLOCK_MULTIPLIER_16)))) {
+               fst_dbg(DBG_ASS,
+         "Custom clock rate multiplier is not expected value (1 or 16) %d\n",
+                       custom_clock_rate->multiplier);
+               return 2;
+       }
+       if (custom_clock_rate->clock_type > FST_CUSTOM_RATE_CLOCK_LOW_MASTER) {
+               fst_dbg(DBG_ASS,
+               "Custom clock type is not in the rage expected (0 - 2) %d\n",
+                       custom_clock_rate->clock_type);
+               return 3;
+       }
+       if (strlen(custom_clock_rate->rate_info) !=
+           FST_CUSTOM_RATE_CONFIG_LENGTH - 1) {
+               fst_dbg(DBG_ASS,
+               "Custom clock rate info is not the length expected %d %d\n",
+                       (int)strlen(custom_clock_rate->rate_info),
+                       FST_CUSTOM_RATE_CONFIG_LENGTH - 1);
+               return 4;
+       }
+       /* Validation passed
+        */
+       return 0;
+}
+
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
+}
+
+static int
+set_custom_clock_rate(struct fst_port_info *port,
+                     struct fstioc_custom_rate_config *custom_clock_rate)
+{
+       struct fstioc_req sys_request;
+       char sz_rate_info[(FST_CUSTOM_RATE_CONFIG_LENGTH * 2) + 1];
+       unsigned char buf[FST_CUSTOM_RATE_CONFIG_LENGTH];
+       unsigned char checksum[16];
+       struct crypto_hash *tfm;
+       struct hash_desc desc;
+       struct scatterlist sg;
+       char sz_checksum[3];
+       char *psz_clock_type = NULL;
+       int i;
+       int retval;
+
+#define MD5_SUM_LENGTH 23
+
+       /* Prepare the string and construct the usb command and send it
+        */
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
+
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
+
+       fst_dbg(DBG_IOCTL, "Temp3 ascii sz_rate_info=%s\n", sz_rate_info);
+
+       /* Use the Kernel Crypto API to calculate the MD5Sum of the updated
+        * rate string
+        */
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
+       sprintf(sz_checksum, "%02X", checksum[0]);
+       strcat(sz_rate_info, sz_checksum);
+       fst_dbg(DBG_IOCTL, "Temp7 ascii sz_rate_info=%s\n", sz_rate_info);
+       strtohex(sz_rate_info, sys_request.u_msg,
+                FST_CUSTOM_RATE_CONFIG_LENGTH);
+       crypto_free_hash(tfm);
+       /* Now we can send the request to Flex
+        */
+       flex_fstioc_req_to_le(&sys_request);
+       retval = usb_control_msg(port->card->udev,
+                                usb_sndctrlpipe(port->card->udev, 0),
+                                USS_CMD_SEND_SECURE_MSG, 0x40, 0, 0,
+                                &sys_request, sizeof(sys_request), 10000);
+       flex_fstioc_req_to_cpu(&sys_request);
+       if (retval != sizeof(sys_request)) {
+               fst_dbg(DBG_ASS, "%s: Error in sending USB Control Message, retval is %d\n",
+                       port->dev->name, retval);
+               return retval;
+       }
+       /* We are always going to wait for a reply
+        */
+       fst_dbg(DBG_IOCTL, "Waiting for a reply\n");
+       flex_fstioc_req_to_le(&sys_request);
+       retval = usb_control_msg(port->card->udev,
+                                usb_rcvctrlpipe(port->card->udev, 0),
+                                USS_CMD_RECV_SECURE_RSP, 0xC0, 0, 0,
+                                &sys_request, sizeof(sys_request), 10000);
+       flex_fstioc_req_to_cpu(&sys_request);
+       if (retval != sizeof(sys_request)) {
+               fst_dbg(DBG_ASS, "Set Custom Clock Rate: Retval is %d\n",
+                       retval);
+               return retval;
+       }
+       fst_dbg(DBG_IOCTL, "Returning from set_custom_clock_rate\n");
+       return 0;
+}
+
+static int
+fst_set_iface(struct fst_card_info *usb_dev, struct fst_port_info *port,
+             struct ifreq *ifr)
+{
+       sync_serial_settings sync;
+       int i;
+       int retval;
+
+       if (ifr->ifr_settings.size != sizeof(sync))
+               return -ENOMEM;
+       if (copy_from_user
+           (&sync, ifr->ifr_settings.ifs_ifsu.sync, sizeof(sync))) {
+               return -EFAULT;
+       }
+
+       if (sync.loopback)
+               return -EINVAL;
+
+       i = port->index;
+
+       switch (ifr->ifr_settings.type) {
+       case IF_IFACE_V35:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_V35;
+               port->hwif = V35;
+               break;
+
+       case IF_IFACE_V24:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_V24;
+               port->hwif = V24;
+               break;
+
+       case IF_IFACE_X21:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_X21;
+               port->hwif = X21;
+               break;
+
+       case IF_IFACE_X21D:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_X21D;
+               port->hwif = X21D;
+               break;
+
+       case IF_IFACE_RS530_449:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_RS530;
+               port->hwif = RS530_449;
+               break;
+
+       case IF_IFACE_RS485:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_RS485;
+               port->hwif = RS485;
+               break;
+
+       case IF_IFACE_RS485_FDX:
+               usb_dev->ports[0]->usb_config.iface =
+                 FSCMN_INTERFACE_RS485_FDX;
+               port->hwif = RS485_FDX;
+               break;
+
+       case IF_IFACE_UX35C:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_X21;
+               port->hwif = UX35C;
+               break;
+
+       case IF_IFACE_SYNC_SERIAL:
+               break;
+
+       default:
+               return -EINVAL;
+       }
+
+       switch (sync.clock_type) {
+       case CLOCK_EXT:
+               usb_dev->ports[0]->usb_config.clock = 0;
+               break;
+
+       case CLOCK_INT:
+               usb_dev->ports[0]->usb_config.clock = 1;
+               break;
+
+       default:
+               return -EINVAL;
+       }
+       usb_dev->ports[0]->usb_config.line_speed = sync.clock_rate;
+       flex_serconf_to_le(&usb_dev->ports[0]->usb_config);
+       retval = usb_control_msg(usb_dev->udev, usb_sndctrlpipe(usb_dev->udev,
+                                                               0),
+                                USS_CMD_SET_CONFIG, 0x40, 0, 0,
+                                &usb_dev->ports[0]->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&usb_dev->ports[0]->usb_config);
+       if (retval > 0) {
+               fst_dbg(DBG_IOCTL, "Set config response received\n");
+               return 0;
+       } else {
+         fst_dbg(DBG_ASS, "Set Config error errno = %d\n", retval);
+               return -EINVAL;
+       }
+}
+
+static int
+fst_get_iface(struct fst_card_info *usb_dev, struct fst_port_info *port,
+             struct ifreq *ifr)
+{
+       sync_serial_settings sync;
+       int i;
+
+       /* First check what line type is set, we'll default to reporting X.21
+        */
+       switch (port->hwif) {
+       case V35:
+               ifr->ifr_settings.type = IF_IFACE_V35;
+               break;
+       case V24:
+               ifr->ifr_settings.type = IF_IFACE_V24;
+               break;
+       case X21D:
+               ifr->ifr_settings.type = IF_IFACE_X21D;
+               break;
+       case RS530_449:
+               ifr->ifr_settings.type = IF_IFACE_RS530_449;
+               break;
+       case RS485:
+               ifr->ifr_settings.type = IF_IFACE_RS485;
+               break;
+       case RS485_FDX:
+               ifr->ifr_settings.type = IF_IFACE_RS485_FDX;
+               break;
+       case UX35C:
+               ifr->ifr_settings.type = IF_IFACE_UX35C;
+               break;
+
+       case X21:
+       default:
+               ifr->ifr_settings.type = IF_IFACE_X21;
+               break;
+       }
+       if (ifr->ifr_settings.size == 0)
+               return 0;       /* only type requested */
+       if (ifr->ifr_settings.size < sizeof(sync))
+               return -ENOMEM;
+
+       i = port->index;
+       sync.clock_rate = usb_dev->ports[0]->usb_config.line_speed;
+       /* Lucky card and linux use same encoding here */
+       sync.clock_type = usb_dev->ports[0]->usb_config.clock ==
+           INTCLK ? CLOCK_INT : CLOCK_EXT;
+       sync.loopback = 0;
+
+       if (copy_to_user(ifr->ifr_settings.ifs_ifsu.sync,
+                        &sync, sizeof(sync)))
+               return -EFAULT;
+
+       ifr->ifr_settings.size = sizeof(sync);
+       return 0;
+}
+
+static int fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+       struct fst_card_info *card;
+       struct fst_port_info *port;
+       struct fstioc_control_request *control_request;
+       struct fstioc_info info;
+       struct fstioc_status state;
+       struct fstioc_req sys_request;
+       struct fstioc_custom_rate_config custom_clock_rate;
+       int retval = 0;
+       int len;
+       struct fstioc_cmd my_cmd;
+       struct fstioc_char_data char_data;
+       char fstioc_info_ver;
+       char readv_mode;
+       int info_size;
+       unsigned char signals;
+       char sigs[CMD_BUF_LEN];
+       unsigned long copied = 0;
+       int speed;
+
+       fst_dbg(DBG_IOCTL, "ioctl: %x, %p\n", cmd, ifr->ifr_data);
+       port = dev_to_port(dev);
+       card = port->card;
+
+       if (!capable(CAP_NET_ADMIN))
+               return -EPERM;
+
+       switch (cmd) {
+       case FSTCPURESET:
+               card->state = FST_RESET;
+               return 0;
+
+       case FSTCPURELEASE:
+               card->state = FST_STARTING;
+               return 0;
+
+       case FSTWRITE:          /* Code write (download) */
+               /* First copy in the header with the length and offset of data
+                * to write
+                */
+               if (ifr->ifr_data == NULL)
+                       return -EINVAL;
+               control_request =
+                   kmalloc(sizeof(struct fst_card_info), GFP_KERNEL);
+               if (control_request == NULL) {
+                       pr_err("%s: insufficient memory for FSTWITE data\n",
+                                  port->dev->name);
+                       return -ENOMEM;
+               }
+               if (copy_from_user(control_request, ifr->ifr_data,
+                                  sizeof(struct fstioc_control_request))) {
+                       kfree(control_request);
+                       return -EFAULT;
+               }
+               /* Check the version of the request
+                * We only support version 1 so far
+                */
+               if (control_request->u_version != 1) {
+                       fst_dbg(DBG_ASS,
+                               "Invalid version number in fstwrite\n");
+                       kfree(control_request);
+                       return -EINVAL;
+               }
+               if (control_request->b_direction) {
+                       /*
+                        * To device
+                        */
+                       retval = usb_control_msg(card->udev,
+                                                usb_sndctrlpipe(card->udev,
+                                                                0),
+                                                control_request->by_request,
+                                                0x40,
+                                                control_request->w_value,
+                                                control_request->w_index,
+                                                &control_request->data,
+                                                control_request->w_data_length,
+                                                10000);
+                       if (retval > 0) {
+                               fst_dbg(DBG_IOCTL,
+                                       "Set control response received\n");
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set Control error errno = %d\n",
+                                       retval);
+                       }
+               } else {
+                       /* From device */
+                       retval = usb_control_msg(card->udev,
+                                                usb_rcvctrlpipe(card->udev, 0),
+                                                control_request->by_request,
+                                                0xc0, control_request->w_value,
+                                                control_request->w_index,
+                                                &control_request->data,
+                                                control_request->w_data_length,
+                                                10000);
+                       if (retval > 0) {
+                               fst_dbg(DBG_IOCTL,
+                                       "Get control response received\n");
+                               control_request->w_data_length = retval;
+                               if (copy_to_user(ifr->ifr_data,
+                                                control_request,
+                                   sizeof(struct fstioc_control_request))) {
+                                       kfree(control_request);
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Get Control error errno = %d\n",
+                                       retval);
+                       }
+               }
+               kfree(control_request);
+               return 0;
+
+       case FSTGETSHELL:
+
+               if (ifr->ifr_data == NULL)
+                       return -EINVAL;
+
+               info_size = flex_get_config(card, port, &info);
+               if (info_size) {
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &info, info_size);
+                       else if (copy_to_user(ifr->ifr_data,
+                                             &info, info_size)) {
+                               return -EFAULT;
+                       }
+                       return 0;
+               } else {
+                       return -EFAULT;
+               }
+
+       case FSTGETCONF:
+
+               /* If card has just been started check the shared memory config
+                * version and marker
+                */
+               if (card->state == FST_STARTING) {
+                       check_started_ok(card);
+               }
+
+               if (card->state != FST_RUNNING)
+                       return -ENODEV;
+
+               if (ifr->ifr_data == NULL)
+                       return -EINVAL;
+
+               if (!access_ok(VERIFY_WRITE, ifr->ifr_data, sizeof(info))) {
+                       fst_dbg(DBG_ASS,
+                               "%s: fstgetconf: Can't access address %p\n",
+                               dev->name, ifr->ifr_data);
+                       return -EFAULT;
+               }
+               memset(&info, 0, sizeof(struct fstioc_info));
+               info_size = flex_get_config(card, port, &info);
+               if (info_size) {
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &info, info_size);
+                       else if (copy_to_user(ifr->ifr_data,
+                                             &info, info_size)) {
+                               return -EFAULT;
+                       }
+                       return 0;
+               } else {
+                       return -EFAULT;
+               }
+
+       case FSTSETCONF:
+
+               if (card->state != FST_RUNNING) {
+                       pr_err("Attempt to configure card %d in non-running",
+                              card->card_no);
+                       pr_err(" state (%d)\n", card->state);
+                       return -EIO;
+               }
+               if (!access_ok(VERIFY_READ, ifr->ifr_data, sizeof(info))) {
+                       fst_dbg(DBG_ASS,
+                               "%s: fstsetconf: Can't access address %p\n",
+                               dev->name, ifr->ifr_data);
+                       return -EFAULT;
+               }
+               memset(&info, 0, sizeof(struct fstioc_info));
+               if (port->compat == 1)
+                       memcpy(&info, ifr->ifr_data, sizeof(info));
+               else
+                       retval = copy_from_user(&info, ifr->ifr_data,
+                                               sizeof(info));
+               if (retval)
+                       return -EFAULT;
+
+               if (validate_buffer_config(&info))
+                       return -EFAULT;
+
+               if (flex_set_config(card, &info))
+                       return 0;
+               else
+                       return -EFAULT;
+
+       case FSTSNOTIFY:
+               /* The application layer above wants to toggle the state notify
+                * mechanism.
+                */
+               if (copy_from_user
+                   (&port->notify_mode, ifr->ifr_data, sizeof(int))) {
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL, "%s: Setting Notify mode to %d\n",
+                       port->dev->name, port->notify_mode);
+               return 0;
+
+       case FSTSETMON:
+               /* The application layer above wants to monitor tx and rx data
+                * mechanism.
+                */
+               if (copy_from_user
+                   (&port->monitor_mode, ifr->ifr_data, sizeof(int))) {
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL,
+                       "Card %d port %d: Setting Monitor mode to %d\n",
+                       card->card_no, port->index, port->monitor_mode);
+               return 0;
+
+       case FSTGSTATE:
+               /* The application  layer above wants the carrier state
+                */
+               state.carrier_state = netif_carrier_ok(port->dev);
+               /* and the txq is a simple length */
+               state.txq_length = port->txqe - port->txqs;
+               if (state.txq_length < 0) {
+                       /* This is the case where the next free has wrapped
+                        * but the last used hasn't
+                        */
+                       state.txq_length = state.txq_length + FST_TXQ_DEPTH;
+               }
+               state.rxq_length = 0;
+               if (port->notify_mode == FST_NOTIFY_EXTENDED) {
+                       /*
+                        * Update the stats
+                        */
+                       memcpy(&state.stats, hdlc_stats(port->dev),
+                              sizeof(struct fst_device_stats));
+                       len = sizeof(struct fstioc_status);
+               } else {
+                       len = FST_NOTIFY_BASIC_SIZE;
+               }
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
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL, "The request is as follows:\n");
+               fst_dbg(DBG_IOCTL, "msg_type = %x\n", sys_request.msg_type);
+               fst_dbg(DBG_IOCTL, "Sending the card the request\n");
+
+               flex_fstioc_req_to_le(&sys_request);
+               retval = usb_control_msg(card->udev,
+                                        usb_sndctrlpipe(card->udev, 0),
+                                        USS_CMD_SEND_SECURE_MSG, 0x40, 0, 0,
+                                        &sys_request,
+                                        sizeof(sys_request), 10000);
+               flex_fstioc_req_to_cpu(&sys_request);
+               if (retval != sizeof(sys_request)) {
+                       fst_dbg(DBG_ASS,
+                               "%s: Error in sending USB Control Message, retval is %x\n",
+                               port->dev->name, retval);
+                       return retval;
+               }
+               /* We are always going to wait for a reply */
+               fst_dbg(DBG_IOCTL, "Waiting for a reply\n");
+               flex_fstioc_req_to_le(&sys_request);
+               retval = usb_control_msg(card->udev,
+                                        usb_rcvctrlpipe(card->udev, 0),
+                                        USS_CMD_RECV_SECURE_RSP, 0xC0, 0, 0,
+                                        &sys_request,
+                                        sizeof(sys_request), 10000);
+               flex_fstioc_req_to_cpu(&sys_request);
+
+               if (retval != sizeof(sys_request)) {
+                       fst_dbg(DBG_ASS, "fstsysreq: Retval is %d\n", retval);
+                       return retval;
+               }
+               /* Copy the buffer back and we are complete */
+               if (copy_to_user(ifr->ifr_data, &sys_request,
+                                sizeof(sys_request))) {
+                       fst_dbg(DBG_IOCTL,
+                               "Error copying data back to user\n");
+                       return -EFAULT;
+               }
+               fst_dbg(DBG_IOCTL, "Returning from FSTSYSREQ\n");
+               return 0;
+
+       case SIOCWANDEV:
+               switch (ifr->ifr_settings.type) {
+               case IF_GET_IFACE:
+                       return fst_get_iface(card, port, ifr);
+
+               case IF_IFACE_SYNC_SERIAL:
+               case IF_IFACE_V35:
+               case IF_IFACE_V24:
+               case IF_IFACE_X21:
+               case IF_IFACE_X21D:
+               case IF_IFACE_RS530_449:
+               case IF_IFACE_RS485:
+               case IF_IFACE_RS485_FDX:
+               case IF_IFACE_UX35C:
+                       return fst_set_iface(card, port, ifr);
+
+               case IF_PROTO_RAW:
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
+
+               if (port->compat == 1)
+                       memcpy(&my_cmd, ifr->ifr_data, sizeof(my_cmd));
+               else if (copy_from_user(&my_cmd, ifr->ifr_data,
+                                       sizeof(my_cmd))) {
+                       fst_dbg(DBG_ASS,
+                               "fstcmd: Could not access user buffers\n");
+                       return -EFAULT;
+               }
+               if (my_cmd.version != 1) {
+                       fst_dbg(DBG_ASS, "fstcmd: bad version %d\n",
+                               my_cmd.version);
+                       return -EINVAL;
+               }
+               switch (my_cmd.command) {
+               case FSTCMD_GET_SERIAL:
+
+                       if (copy_to_user(my_cmd.data_ptr,
+                                        card->ports[0]->
+                                        usb_card_info.sz_serial_no,
+                                        strlen(card->ports[0]->
+                                               usb_card_info.sz_serial_no))) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy serial back\n");
+                               return -EFAULT;
+                       }
+                       my_cmd.output_data_len =
+                           strlen(card->ports[0]->usb_card_info.sz_serial_no);
+                       /* And invert the status field to show we have done
+                        * the command
+                        */
+                       my_cmd.status = ~my_cmd.status;
+                       if (port->compat == 1)
+                               memcpy(ifr->ifr_data, &my_cmd, sizeof(my_cmd));
+                       else if (copy_to_user
+                                (ifr->ifr_data, &my_cmd, sizeof(my_cmd))) {
+                               fst_dbg(DBG_ASS,
+                                       "fstcmd: could not copy status back\n");
+                               return -EFAULT;
+                       }
+                       fst_dbg(DBG_IOCTL, "Returning serial number %s",
+                               card->ports[0]->usb_card_info.sz_serial_no);
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
+                       sigs[0] = signals;
+                       sigs[1] = 0x00;
+                       sigs[2] = 0x00;
+                       sigs[3] = 0x00;
+                       fst_dbg(DBG_IOCTL,
+                               "Setting V24 Signals %x\n", sigs[0]);
+                       retval = usb_control_msg(card->udev,
+                                                usb_sndctrlpipe(card->udev,
+                                                                0),
+                                                USS_CMD_SET_SIGNALS, 0x40, 0,
+                                                0, &sigs, CMD_BUF_LEN, 10000);
+                       if (retval == CMD_BUF_LEN) {
+                               fst_dbg(DBG_IOCTL,
+                               "Set signals down response received\n");
+                               card->ports[0]->v24OpSts = signals & 0x03;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                                       "Set signals down error errno = %d\n",
+                                       retval);
+                               return -EFAULT;
+                       }
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
+                                       "fstcmd: could not get fstioc_info version\n");
+                                       return -EFAULT;
+                               }
+                               if ((fstioc_info_ver < FST_VERSION_OLD) ||
+                                   (fstioc_info_ver > FST_VERSION_CURRENT)) {
+                                       fst_dbg(DBG_ASS,
+                                       "fstcmd: setting an invalid fstioc_info version %d\n",
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
+                                       "fstcmd: could not copy status back\n");
+                                       return -EFAULT;
+                               }
+                               port->fstioc_info_ver = fstioc_info_ver;
+                       } else {
+                               fst_dbg(DBG_ASS,
+                               "(%s) Cannot copy fstioc_info version, data buffer too small %d %d\n",
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
+                               "fstcmd: could not copy status back\n");
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
+                                               "fstcmd: could not copy status back\n");
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
+               case FSTCMD_GET_PRESERVE_SIGNALS:
+                       fst_issue_cmd(port, GETPRESERVE);
+                       if (port->v24OpSts & 0x100)
+                               signals = 1;
+                       else
+                               signals = 0;
+                       if (copy_to_user(my_cmd.data_ptr, &signals, 1)) {
+                               fst_dbg(DBG_ASS,
+                               "fstcmd: could not return preserve signals\n");
+                               return -EFAULT;
+                       }
+                       my_cmd.output_data_len = sizeof(signals);
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
+               case FSTCMD_SET_PRESERVE_SIGNALS:
+                       fst_issue_cmd(port, SETPRESERVE);
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
+                               "(%s) Cannot copy speed setting, data buffer too small %d %d\n",
+                                       port->dev->name, 1,
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       fst_dbg(DBG_ASS, "%s: Update clock speed to %d\n",
+                               port->dev->name, speed);
+                       port->usb_config.line_speed = speed;
+                       fst_issue_cmd(port, SETLINESPEED);
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
+               case FSTCMD_SET_CUSTOM_RATE:
+                       if (!port->features) {
+                               fst_dbg(DBG_ASS, "%s: custom clock rates not",
+                                       port->dev->name);
+                               fst_dbg(DBG_ASS, " supported on this port\n");
+                               return -EIO;
+                       }
+                       if (my_cmd.input_data_len >=
+                           (unsigned int)sizeof(struct
+                                                fstioc_custom_rate_config)) {
+                               if (copy_from_user
+                                   (&custom_clock_rate, my_cmd.data_ptr,
+                               sizeof(struct fstioc_custom_rate_config))) {
+                                       fst_dbg(DBG_ASS, "fstcmd: could not ");
+                                       fst_dbg(DBG_ASS, "get custom rate ");
+                                       fst_dbg(DBG_ASS, "config structure\n");
+
+                                       return -EFAULT;
+                               }
+                       } else {
+                               fst_dbg(DBG_ASS, "(%s) Cannot copy ",
+                                       port->dev->name);
+                               fst_dbg(DBG_ASS, "custom_rate_config, data ");
+                               fst_dbg(DBG_ASS, "buffer too small %lu %u\n",
+                               sizeof(struct fstioc_custom_rate_config),
+                                       my_cmd.input_data_len);
+                               return -EFAULT;
+                       }
+                       retval =
+                           parse_custom_clock_rate_structure(port,
+                                                     &custom_clock_rate);
+                       if (retval) {
+                               fst_dbg(DBG_ASS, "(%s) Invalid custom",
+                                       port->dev->name);
+                               fst_dbg(DBG_ASS, "_rate_config structure, ");
+                               fst_dbg(DBG_ASS, "%d\n", retval);
+                               return -EINVAL;
+                       }
+                       retval =
+                           set_custom_clock_rate(port, &custom_clock_rate);
+                       if (retval) {
+                               fst_dbg(DBG_ASS, "(%s) Error in setting ",
+                                       port->dev->name);
+                               fst_dbg(DBG_ASS, "custom clock rate, %d\n",
+                                       retval);
+                               return -EINVAL;
+                       }
+                       /* Everything worked  */
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
+               default:
+                       fst_dbg(DBG_ASS, "Unrecognised FST Command %d\n",
+                               my_cmd.command);
+                       return -EINVAL;
+               }
+       default:
+               /* Not one of ours. Pass it through to sPPP package */
+               return hdlc_ioctl(dev, ifr, cmd);
+       }
+       return -EINVAL;
+}
+
+static void fst_openport(struct fst_port_info *port)
+{
+       int txq_length;
+
+       /* Only init things if card is actually running. This allows open to
+        * succeed for downloads etc.
+        */
+       fst_dbg(DBG_OPEN, "Opening port %s\n", port->dev->name);
+       fst_dbg(DBG_OPEN, "Tx buffers = %d of size %d\n", port->num_tx_buffers,
+               port->tx_buffer_size);
+       fst_dbg(DBG_OPEN, "Rx buffers = %d of size %d\n", port->num_rx_buffers,
+               port->rx_buffer_size);
+
+       last_segment_cnt = 0;
+       if (port->card->state == FST_RUNNING) {
+               if (port->run) {
+                       fst_dbg(DBG_OPEN,
+                               "open: found port already running\n");
+               } else {
+                       fst_rx_config(port);
+                       fst_tx_config(port);
+                       fst_issue_cmd(port, STARTPORT);
+                       port->run = 1;
+                       fst_op_raise(port, OPSTS_RTS | OPSTS_DTR);
+                       txq_length = port->txqe - port->txqs;
+                       port->txqe = 0;
+                       port->txqs = 0;
+                       port->rxq.error_recovery = 0;
+                       port->char_inq = NULL;
+                       port->char_inq_end = NULL;
+               }
+       }
+}
+
+static void fst_closeport(struct fst_port_info *port)
+{
+       fst_dbg(DBG_OPEN, "Closing port %s\n", port->dev->name);
+       if (port->card->state == FST_RUNNING) {
+               /*
+                * Need to lower control signals here
+                */
+               fst_op_lower(port, OPSTS_RTS | OPSTS_DTR);
+               fst_issue_cmd(port, STOPPORT);
+               if (port->mode == FST_MODE_ASYNC)
+                       fst_reset_rx_fifo(port);
+               fst_issue_cmd(port, FLUSHBUFFERS);
+               port->run = 0;
+               purge_tx_queue(port->card, port);
+       } else {
+               fst_dbg(DBG_OPEN, "close: card not running\n");
+       }
+}
+
+static int fst_open(struct net_device *dev)
+{
+       int err;
+       struct fst_card_info *card;
+       struct fst_port_info *port;
+
+       port = dev_to_port(dev);
+       card = port->card;
+       fst_dbg(DBG_OPEN, "fst_open on port %s\n", dev->name);
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
+       if (port->proto != FST_RAW) {
+               err = hdlc_open(dev);
+               if (err)
+                       return err;
+       }
+       if (!port->char_file)
+               fst_openport(port);
+       netif_wake_queue(dev);
+       if (!try_module_get(THIS_MODULE))
+               return -EBUSY;
+       return 0;
+}
+
+static int fst_close(struct net_device *dev)
+{
+       struct fst_port_info *port;
+       struct fst_card_info *card;
+       unsigned long flags;
+
+       port = dev_to_port(dev);
+       if (port == NULL)
+               fst_dbg(DBG_ASS, "fst_close: port is NULL\n");
+       card = port->card;
+       if (card == NULL)
+               fst_dbg(DBG_ASS, "fst_close: card is NULL\n");
+       fst_dbg(DBG_OPEN, "Port Close: %s\n", dev->name);
+       netif_stop_queue(dev);
+
+       if (card->tx_urb_cnt != MAX_URBS_OUTSTANDING) {
+               if (card->tx_bulk_urb) {
+                       fst_dbg(DBG_OPEN, "Cancel a Tx urb\n");
+                       /* Stop sending data */
+                       usb_kill_urb(card->tx_bulk_urb);
+               }
+               fst_dbg(DBG_ASS, "Closing port with urbs outstanding\n");
+       }
+
+       if (!port->char_file) {
+               /* Only close the port if really not in use
+                */
+               fst_closeport(port);
+       }
+
+       spin_lock_irqsave(&card->card_lock, flags);
+       if (!port->char_file) {
+               while (port->txqe != port->txqs) {
+                       fst_dbg(DBG_OPEN, "Purging tx queue\n");
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
+       if (port->proto != FST_RAW)
+               hdlc_close(dev);
+       module_put(THIS_MODULE);
+       return 0;
+}
+
+static int
+fst_attach(struct net_device *dev, unsigned short encoding,
+          unsigned short parity)
+{
+       /* Setting currently fixed in FarSync card so we check and forget
+        */
+       if (encoding != ENCODING_NRZ || parity != PARITY_CRC16_PR1_CCITT)
+               return -EINVAL;
+       return 0;
+}
+
+static void fst_tx_timeout(struct net_device *dev)
+{
+       struct fst_port_info *port;
+       struct fst_card_info *card;
+       struct net_device_stats *stats = hdlc_stats(dev);
+
+       pr_info("fst_tx_timeout on %s\n", dev->name);
+       port = dev_to_port(dev);
+       card = port->card;
+       stats->tx_errors++;
+       stats->tx_aborted_errors++;
+       fst_dbg(DBG_ASS, "Tx timeout card %d port %d\n",
+               card->card_no, port->index);
+       purge_tx_queue(card, port);
+       dev->trans_start = jiffies;
+       netif_wake_queue(dev);
+       port->start = 0;
+       if (port->notify_mode == FST_NOTIFY_EXTENDED)
+               fst_notify_state_change(port->card, port);
+}
+
+static int fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+       struct net_device_stats *stats = hdlc_stats(dev);
+       struct fst_card_info *card;
+       struct fst_port_info *port;
+       unsigned long flags;
+       int txq_length;
+       struct sk_buff *new_skb;
+       int count = 0;
+
+       if (dev == NULL) {
+               fst_dbg(DBG_ASS, "fst_start_xmit: dev is null\n");
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               return 0;
+       }
+       port = dev_to_port(dev);
+       if (port == NULL) {
+               fst_dbg(DBG_ASS, "fst_start_xmit: port is null\n");
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               return 0;
+       }
+       card = port->card;
+       if (card == NULL) {
+               fst_dbg(DBG_ASS, "fst_start_xmit: card is null\n");
+               stats->tx_errors++;
+               dev_kfree_skb(skb);
+               stats->tx_dropped++;
+               return 0;
+       }
+       fst_dbg(DBG_TX, "fst_start_xmit: length = %d\n", skb->len);
+
+       /* Drop packet with error if we don't have carrier */
+       if ((!netif_carrier_ok(dev)) && (!port->ignore_carrier)) {
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_carrier_errors++;
+               fst_dbg(DBG_ASS,
+                       "Tried to transmit but no carrier on card %d port %d\n",
+                       card->card_no, port->index);
+               if (port->notify_mode == FST_NOTIFY_EXTENDED)
+                       fst_notify_state_change(port->card, port);
+               return 0;
+       }
+
+       /* Drop it if it's too big! MTU failure ? */
+       if (skb->len > FST_MAX_MTU) {
+               pr_err("Tx Packet too large %d vs %d\n", skb->len,
+                          FST_MAX_MTU);
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               if (port->notify_mode == FST_NOTIFY_EXTENDED)
+                       fst_notify_state_change(port->card, port);
+               return 0;
+       }
+
+       /* Drop it if it's bigger than the tx_buffer_size */
+       if (skb->len > port->tx_buffer_size) {
+               pr_err("Tx Packet too large %d vs buffer %d\n", skb->len,
+                          port->tx_buffer_size);
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               if (port->notify_mode == FST_NOTIFY_EXTENDED)
+                       fst_notify_state_change(port->card, port);
+               return 0;
+       }
+
+       /* Drop it if it's port not running */
+       if (!port->run) {
+               pr_err("Tx When port closed\n");
+               dev_kfree_skb(skb);
+               stats->tx_errors++;
+               stats->tx_dropped++;
+               if (port->notify_mode == FST_NOTIFY_EXTENDED)
+                       fst_notify_state_change(port->card, port);
+               return 0;
+       }
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
+               fst_dbg(DBG_ASS, "Transmitting a zero length frame\n");
+
+       /* We are always going to queue the packet
+        * so that the bottom half is the only place we tx from
+        * Check there is room in the port txq
+        */
+       spin_lock_irqsave(&card->card_lock, flags);
+       txq_length = port->txqe - port->txqs;
+       if (txq_length < 0) {
+               /* This is the case where the next free has wrapped but the
+                * last used hasn't
+                */
+               txq_length = txq_length + FST_TXQ_DEPTH;
+       }
+       spin_unlock_irqrestore(&card->card_lock, flags);
+       if (txq_length >= fst_txq_high) {
+               /* We have got enough buffers in the pipeline.  Ask the network
+                * layer to stop sending frames down
+                */
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
+       }
+       if (txq_length == FST_TXQ_DEPTH - 1) {
+               /* This shouldn't have happened but such is life
+                */
+               dev_kfree_skb(skb);
+               port_to_stats(port, tx_errors)++;
+               port_to_stats(port, tx_dropped)++;
+               fst_dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",
+                       card->card_no, port->index);
+               if (port->notify_mode == FST_NOTIFY_EXTENDED)
+                       fst_notify_state_change(port->card, port);
+               return 0;
+       }
+
+       /* queue the buffer
+        */
+       new_skb = skb;
+       if (new_skb == NULL) {
+               fst_dbg(DBG_ASS, "Error in queuing atm pdu\n");
+               return 0;
+       }
+       if (port->monitor_mode)
+               gen_mon_packet(new_skb, port, FST_MON_TX);
+       spin_lock_irqsave(&card->card_lock, flags);
+       port->txq[port->txqe].frame = new_skb;
+       port->txq[port->txqe].count = new_skb->len;
+       port->txq[port->txqe].segment_cnt =
+           ((new_skb->len - 1) / port->tx_buffer_size) + 1;
+       port->txq[port->txqe].current_seg = 0;
+       port->txq[port->txqe].flags = 0;
+       port->txqe++;
+       if (port->txqe == FST_TXQ_DEPTH)
+               port->txqe = 0;
+       spin_unlock_irqrestore(&card->card_lock, flags);
+
+       /* Scehdule the bottom half which now does transmit processing */
+       fst_q_work_item(&fst_work_txq, card->card_no);
+       tasklet_schedule(&fst_tx_task);
+       if (port->char_file)
+               return count;
+       else
+               return 0;
+}
+
+/* Sysdev stuff for adding the serial number attribute to the char device
+ */
+static ssize_t serial_show(struct device *dev, struct device_attribute *attr,
+                          char *buf)
+{
+       struct fst_card_info *card = dev_get_drvdata(dev);
+       ssize_t ret = 0;
+
+       /* no lock needed for this */
+
+       strcpy(buf, card->ports[0]->usb_card_info.sz_serial_no);
+       ret = strlen(buf);
+       return ret;
+}
+
+static DEVICE_ATTR(serial, 0644, serial_show, NULL);
+
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
+ *      Should be pretty bizarre if we get an error here (kernel memory
+ *      exhaustion is one possibility). If we do see a problem we report it
+ *      via a printk and leave the corresponding interface and all that follow
+ *      disabled.
+ */
+
+static void fst_init_card(struct fst_card_info *card, char *dev_name)
+{
+       int i;
+       int err;
+       struct fst_port_info *port;
+       char char_dev_name[16];
+       struct device *tty_device = NULL;
+
+       /* Assign the minor device number
+        */
+       for (i = 0; i < FST_MAX_CARDS * FST_MAX_PORTS; i++) {
+               if (fst_ports_list[i] == NULL) {
+                       fst_minor = i;
+                       break;
+               }
+       }
+       /* We're working on a number of ports based on the card ID. If the
+        * firmware detects something different later (should never happen)
+        * we'll have to revise it in some way then.
+        */
+       spin_lock_init(&card->card_lock);
+       spin_lock_init(&card->fifo_lock);
+       init_waitqueue_head(&card->fifo_waitq);
+       for (i = 0; i < card->nports; i++) {
+               struct net_device *dev;
+               hdlc_device *hdlc;
+
+               card->ports[i] = kmalloc(sizeof(struct fst_port_info),
+                                        GFP_KERNEL);
+               if (card->ports[i] == NULL) {
+                       pr_err("FarSync Flex found but insufficient memory ");
+                       pr_err("for driver device storage\n");
+                       return;
+               }
+               port = card->ports[i];
+               memset(port, 0, sizeof(struct fst_port_info));
+               dev = alloc_hdlcdev(port);
+               dev->netdev_ops = &fst_ops;
+               SET_NETDEV_DEV(dev, &card->udev->dev);
+               err = register_hdlc_device(dev);
+               if (err < 0) {
+                       int j;
+                       pr_err("Cannot register HDLC device for port %d", i);
+                       pr_err(" (errno %d)\n", -err);
+                       for (j = i; j < card->nports; j++) {
+                               free_netdev(card->ports[j]->dev);
+                               card->ports[j]->dev = NULL;
+                               kfree(card->ports[j]);
+                       }
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
+               port->hwif = X21;
+               port->v24OpSts = 0;
+               port->minor_dev_no = fst_minor;
+               spin_lock_init(&port->rxf_lock);
+               init_waitqueue_head(&port->pollq);
+               init_waitqueue_head(&port->readq);
+               init_waitqueue_head(&port->writeq);
+               fst_ports_list[fst_minor] = port;
+               hdlc = dev_to_hdlc(dev);
+               fst_dbg(DBG_INIT, "Allocated device name was %s\n", dev->name);
+               if (fst_alloc_rx_fifo(port)) {
+                       pr_err("%s: Cannot allocate rx fifo\n",
+                                  port->dev->name);
+                       kfree(dev);
+                       card->nports = i;
+                       break;
+               }
+               /* Fill in remainder of the net device info
+                * Since this is a PCI setup this is purely
+                * informational. Give them the buffer addresses
+                * and basic card I/O.
+                */
+               dev->base_addr = card->pci_conf;
+               dev->irq = card->irq;
+
+               dev->tx_queue_len = FST_TX_QUEUE_LEN;
+               dev->addr_len = 8;
+               strcpy(dev->dev_addr,
+                      card->ports[0]->usb_card_info.sz_serial_no);
+               dev->watchdog_timeo = FST_TX_TIMEOUT;
+               hdlc->attach = fst_attach;
+               hdlc->xmit = fst_start_xmit;
+               fst_dbg(DBG_INIT, "fst_major is %x: fst_minor is %d\n",
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
+               strcat(char_dev_name, dev->name);
+               card->sync_cdev = device_create(farsync_class, NULL,
+                                               MKDEV(fst_major, fst_minor),
+                                               NULL, char_dev_name,
+                                               fst_minor);
+               if (card->sync_cdev < 0) {
+                       pr_err("Cannot create udev entry for %s\n",
+                                  port_to_dev(card->ports[0])->name);
+               } else {
+                       int rc;
+
+                       dev_set_drvdata(card->sync_cdev, card);
+                       /* register the attributes */
+                       rc = device_create_file(card->sync_cdev,
+                                               &dev_attr_serial);
+                       if (rc) {
+                               fst_dbg(DBG_ASS,
+                                       "Couldn't register sync serial no attribute\n");
+                       }
+               }
+               init_async_parameters(port, 8, COM_STOP_BITS_1,
+                                     COM_NO_PARITY, COM_FLOW_CONTROL_NONE);
+               port->char_inq_max_len = FST_CHAR_INQ_MAX_LEN;
+       }
+}
+
+/* Get a minor range for your devices from the usb maintainer */
+#define USB_MINOR_BASE 192
+#define USB_VENDOR_ID  0x1afd
+#define USB_PRODUCT_ID 0x0721
+#define WRITES_IN_FLIGHT       8
+
+/* table of devices that work with this driver */
+static struct usb_device_id flex_table[] = {
+       {USB_DEVICE(USB_VENDOR_ID, USB_PRODUCT_ID)},
+       {}                      /* Terminating entry */
+};
+
+MODULE_DEVICE_TABLE(usb, flex_table);
+
+/* usb class driver info in order to get a minor number from the usb core,
+ * and to have the device registered with the driver core
+ */
+static struct usb_class_driver flex_class = {
+       .name = "flex%d",
+       .fops = &fst_mem_fops,
+       .minor_base = USB_MINOR_BASE,
+};
+
+static int flex_get_config(struct fst_card_info *usb_dev,
+                          struct fst_port_info *port,
+                          struct fstioc_info *info)
+{
+       int retval = 0;
+       int retval2 = 0;
+       int retval3 = 0;
+       int retval4 = 1;
+       int clocks = 0;
+       int features = 0;
+
+       fst_dbg(DBG_IOCTL, "Getting port config\n");
+       flex_serconf_to_le(&port->usb_config);
+       retval = usb_control_msg(usb_dev->udev, usb_rcvctrlpipe(usb_dev->udev,
+                                                               0),
+                                USS_CMD_GET_CONFIG, 0xc0, 0, 0,
+                                &port->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&port->usb_config);
+       flex_card_info_to_le(&port->usb_card_info);
+       retval2 = usb_control_msg(usb_dev->udev, usb_rcvctrlpipe(usb_dev->udev,
+                                                                0),
+                                 USS_CMD_GET_CARD_INFO, 0xc0, 0, 0,
+                                 &port->usb_card_info,
+                                 sizeof(FLEX_CARD_INFO), 10000);
+       if (info) {
+               info->card_rev_major = port->usb_card_info.u_major_rev;
+               info->card_rev_minor = port->usb_card_info.u_minor_rev;
+               info->card_rev_build = port->usb_card_info.u_build_state;
+       }
+       flex_card_info_to_cpu(&port->usb_card_info);
+       cpu_to_le32s(&clocks);
+       retval3 = usb_control_msg(usb_dev->udev,
+                                 usb_rcvctrlpipe(usb_dev->udev, 0),
+                                 USS_CMD_GET_CLOCK_STATUS, 0xC0, 0, 0,
+                                 &clocks, 4, 10000);
+       le32_to_cpus(&clocks);
+       /* If we are a Flex 2 or above then check the features
+        */
+       if (port->usb_card_info.u_minor_rev >= FIRST_FLEX_V2_MINOR_ID) {
+               cpu_to_le32s(&features);
+               retval4 = usb_control_msg(usb_dev->udev,
+                                         usb_rcvctrlpipe(usb_dev->udev, 0),
+                                         USS_CMD_GET_FEATURE_MASK, 0xC0, 0, 0,
+                                         &features, 4, 10000);
+               le32_to_cpus(&features);
+       }
+       if ((retval > 0) && (retval2 > 0) && (retval3 > 0) && (retval4 > 0)
+           && (info != NULL)) {
+               fst_dbg(DBG_IOCTL, "Get config response received\n");
+               info->valid =
+                 ((usb_dev->state == FST_RUNNING) ? FSTVAL_ALL : FSTVAL_CARD)
+#if FST_DEBUG
+                   | FSTVAL_DEBUG
+#endif
+                   ;
+               info->valid = 1;
+               if (clocks)
+                       info->clock_status = 0;
+               else
+                       info->clock_status = 1;
+               info->synth_ability = 0;
+               if (features) {
+                       /*This means it is a flex v2 or later, so synthisiser
+                        * is supported
+                        */
+                       info->synth_ability = 1;
+               }
+               port->features = features;
+               info->features = (unsigned int)features;
+               info->nports = usb_dev->nports;
+               info->iocinfo_version = port->fstioc_info_ver;
+               info->type = usb_dev->type;
+               info->state = usb_dev->state;
+               info->index = 0;
+               info->smc_firmware_version =
+                 port->usb_card_info.u_software_version;
+
+               info->line_interface = port->hwif;
+               info->proto = port->proto;
+               info->valid = FSTVAL_ALL;
+               info->internal_clock = port->usb_config.clock;
+               info->line_speed = port->usb_config.line_speed;
+               info->termination = port->usb_config.termination;
+               info->ignore_carrier = port->ignore_carrier;
+               switch (port->usb_config.encoding) {
+               case FSCMN_ENCODING_NRZ:
+                       info->coding = CODING_NRZ;
+                       break;
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
+               case FSCMN_ENCODING_DMAN:
+                       info->coding = CODING_DIFF_MANCHESTER;
+                       break;
+               default:
+                       info->coding = CODING_NRZ;
+                       break;
+               }
+               info->est_line_speed = 0;
+               fst_issue_cmd(port, GETSIGNALS);
+               info->v24IpSts = port->v24IpSts;
+               info->v24OpSts = port->v24OpSts;
+               info->extended_clocking = 0;
+               info->cable_status = 0;
+               info->card_mode = usb_dev->card_mode;
+#if FST_DEBUG
+               info->debug = fst_debug_mask;
+#else
+               info->debug = 0;
+#endif
+               info->transparent_mode = port->usb_config.mode;
+
+               info->transmit_msb_first = port->transmit_msb_first;
+               info->receive_msb_first = port->receive_msb_first;
+
+               info->async_ability = 1;
+               info->invert_clock = port->usb_config.rxclock;
+               info->num_tx_buffers = port->usb_config.num_tx_buffer;
+               info->num_rx_buffers = port->usb_config.num_rx_buffer;
+               info->tx_buffer_size = port->usb_config.size_tx_buffer;
+               info->rx_buffer_size = port->usb_config.size_rx_buffer;
+               info->enable_nrzi_clocking =
+                   port->usb_config.enable_nrzi_clocking;
+               fst_dbg(DBG_IOCTL,
+                       "Async parameters returned as bits %d parity %d stop %d fc %d xon %d xof %d\n",
+                       info->async_conf.word_length, info->async_conf.parity,
+                       info->async_conf.stop_bits,
+                       info->async_conf.flow_control,
+                       info->async_conf.xon_char, info->async_conf.xoff_char);
+               /* Extended Clocking
+                */
+               if (port->usb_config.extended_clocking) {
+                       info->extended_clocking = 0x80;
+                       if (port->usb_config.internal_tx_clock)
+                               info->extended_clocking |= 0x01;
+                       if (port->usb_config.internal_rx_clock)
+                               info->extended_clocking |= 0x02;
+               }
+               if (port->usb_config.extended_config) {
+                       info->extended_clocking |= 0x80;
+                       if (port->usb_config.extended_config & EXT_CONFIG_TTT)
+                               info->extended_clocking |= 0x04;
+                       if (port->usb_config.extended_config & EXT_CONFIG_RTT)
+                               info->extended_clocking |= 0x08;
+               }
+               if ((!port->usb_config.extended_clocking) &&
+                   (!port->usb_config.extended_config)) {
+                       info->extended_clocking = 0;
+               }
+               /* Update the stats
+                */
+               memcpy(&info->stats, hdlc_stats(port->dev),
+                      sizeof(struct fst_device_stats));
+               /* Copy in the async config
+                */
+               info->async_conf.flow_control = port->usb_config.flow_control;
+               info->async_conf.stop_bits = port->usb_config.stopbits;
+               info->async_conf.parity = port->usb_config.parity;
+               info->async_conf.word_length = port->usb_config.data_bits;
+               info->async_conf.xon_char = port->usb_config.xonchar;
+               info->async_conf.xoff_char = port->usb_config.xoffchar;
+               /* and now return the size of the structure according
+                * to the version set
+                */
+               switch (port->fstioc_info_ver) {
+               case FST_VERSION_CURRENT:
+                       return fstioc_info_sz_current;
+
+               case FST_VERSION_V1:
+                       return fstioc_info_sz_ver1;
+
+               case FST_VERSION_V2:
+                       return fstioc_info_sz_ver2;
+
+               case FST_VERSION_V3:
+                       return fstioc_info_sz_ver3;
+
+               default:
+                       return fstioc_info_sz_old;
+               }
+       } else {
+               if ((retval != sizeof(port->usb_config)) ||
+                   (retval2 != sizeof(port->usb_card_info)) ||
+                   (retval3 != 4)) {
+                       fst_dbg(DBG_ASS,
+                               "Get Config error errno = %d %d %d %p\n",
+                               retval, retval2, retval3, info);
+               }
+               return 0;
+       }
+}
+
+static int flex_set_config(struct fst_card_info *usb_dev,
+                          struct fstioc_info *info)
+{
+       int retval;
+
+       fst_dbg(DBG_IOCTL, "Setting port config\n");
+       if (info->card_mode != usb_dev->card_mode) {
+               char mode[CMD_BUF_LEN];
+               if (info->card_mode) {
+                       mode[0] = 1;
+                       mode[1] = 0;
+                       mode[2] = 0;
+                       mode[3] = 0;
+               } else {
+                       mode[0] = 0;
+                       mode[1] = 0;
+                       mode[2] = 0;
+                       mode[3] = 0;
+               }
+               retval = usb_control_msg(usb_dev->udev,
+                                        usb_sndctrlpipe(usb_dev->udev, 0),
+                                        USS_CMD_SET_IDENTIFY_MODE, 0x40, 0, 0,
+                                        &mode, CMD_BUF_LEN, 10000);
+               usb_dev->card_mode = info->card_mode;
+               if (retval == CMD_BUF_LEN) {
+                       fst_dbg(DBG_IOCTL,
+                               "Set identify mode response received\n");
+               } else {
+                       fst_dbg(DBG_ASS,
+                               "Set identify mode error errno = %d\n",
+                               retval);
+               }
+       }
+       switch (info->line_interface) {
+       case V24:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_V24;
+               break;
+       case X21:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_X21;
+               break;
+       case V35:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_V35;
+               break;
+       case X21D:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_X21D;
+               break;
+       case NOCABLE:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_NO_CABLE;
+               break;
+       case RS530_449:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_RS530;
+               break;
+       case RS485:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_RS485;
+               break;
+       case RS485_FDX:
+               usb_dev->ports[0]->usb_config.iface =
+                 FSCMN_INTERFACE_RS485_FDX;
+               break;
+       default:
+               usb_dev->ports[0]->usb_config.iface = FSCMN_INTERFACE_V24;
+               break;
+       }
+       usb_dev->ports[0]->hwif = info->line_interface;
+       usb_dev->ports[0]->proto = info->proto;
+       usb_dev->ports[0]->usb_config.clock = info->internal_clock;
+       usb_dev->ports[0]->usb_config.line_speed = info->line_speed;
+       usb_dev->ports[0]->ignore_carrier = info->ignore_carrier;
+       switch (info->coding) {
+       case CODING_NRZ:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_NRZ;
+               break;
+       case CODING_NRZI:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_NRZI;
+               break;
+       case CODING_FM0:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_FM0;
+               break;
+       case CODING_FM1:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_FM1;
+               break;
+       case CODING_MANCHESTER:
+               usb_dev->ports[0]->usb_config.encoding =
+                   FSCMN_ENCODING_MANCHESTER;
+               break;
+       case CODING_DIFF_MANCHESTER:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_DMAN;
+               break;
+       default:
+               usb_dev->ports[0]->usb_config.encoding = FSCMN_ENCODING_NRZ;
+               break;
+       }
+
+       usb_dev->ports[0]->usb_config.termination = info->termination;
+       usb_dev->ports[0]->mode = info->transparent_mode;
+       usb_dev->ports[0]->usb_config.mode = info->transparent_mode;
+       usb_dev->ports[0]->transmit_msb_first = info->transmit_msb_first;
+       usb_dev->ports[0]->receive_msb_first = info->receive_msb_first;
+       usb_dev->ports[0]->usb_config.bit_order = 0;
+       usb_dev->ports[0]->usb_config.start = info->tx_rx_start;
+       if (usb_dev->ports[0]->fstioc_info_ver > FST_VERSION_V1) {
+               usb_dev->ports[0]->usb_config.data_bits =
+                   info->async_conf.word_length;
+               usb_dev->ports[0]->usb_config.parity = info->async_conf.parity;
+               usb_dev->ports[0]->usb_config.stopbits =
+                   info->async_conf.stop_bits;
+               usb_dev->ports[0]->usb_config.flow_control =
+                   info->async_conf.flow_control;
+               usb_dev->ports[0]->usb_config.timeout_enable = 0; /* unused */
+               usb_dev->ports[0]->usb_config.timeout_length = 0; /* unused */
+               fst_dbg(DBG_IOCTL,
+                       "Async parameters set as bits %d parity %d stop %d fc %d xon %d xof %d\n",
+                       info->async_conf.word_length, info->async_conf.parity,
+                       info->async_conf.stop_bits,
+                       info->async_conf.flow_control,
+                       info->async_conf.xon_char, info->async_conf.xoff_char);
+       }
+#if FST_DEBUG
+       fst_debug_mask = info->debug;
+#endif
+       usb_dev->ports[0]->usb_config.rxclock = info->invert_clock;
+       usb_dev->ports[0]->usb_config.num_tx_buffer =
+           usb_dev->ports[0]->num_tx_buffers = info->num_tx_buffers;
+       usb_dev->ports[0]->usb_config.num_rx_buffer =
+           usb_dev->ports[0]->num_rx_buffers = info->num_rx_buffers;
+       usb_dev->ports[0]->usb_config.size_tx_buffer =
+           usb_dev->ports[0]->tx_buffer_size = info->tx_buffer_size;
+       usb_dev->ports[0]->usb_config.size_rx_buffer =
+           usb_dev->ports[0]->rx_buffer_size = info->rx_buffer_size;
+       usb_dev->ports[0]->usb_config.preserve_signals =
+           usb_dev->ports[0]->v24OpSts & 0x100;
+       usb_dev->ports[0]->usb_config.async_receive_mode = FSCMN_ASYNC_RX_CHAR;
+       usb_dev->ports[0]->usb_config.enable_nrzi_clocking =
+           info->enable_nrzi_clocking;
+       /* Extended Clocking feature */
+       if ((info->extended_clocking) && ((info->line_interface == V24)
+                                         || (info->line_interface ==
+                                             RS530_449))) {
+               usb_dev->ports[0]->usb_config.clock = 0;
+               usb_dev->ports[0]->usb_config.extended_clocking = 1;
+               if (info->extended_clocking & 1)
+                       usb_dev->ports[0]->usb_config.internal_tx_clock = 1;
+               else
+                       usb_dev->ports[0]->usb_config.internal_tx_clock = 0;
+               if (info->extended_clocking & 2)
+                       usb_dev->ports[0]->usb_config.internal_rx_clock = 1;
+               else
+                       usb_dev->ports[0]->usb_config.internal_rx_clock = 0;
+       } else {
+               /* Reset extended clocking because wrong line type
+                */
+               usb_dev->ports[0]->usb_config.extended_clocking = 0;
+               usb_dev->ports[0]->usb_config.internal_tx_clock = 0;
+               usb_dev->ports[0]->usb_config.internal_rx_clock = 0;
+       }
+       fst_dbg(DBG_IOCTL, "Extended Clocking is %x\n",
+               info->extended_clocking);
+       /* Extended Config feature */
+       if ((info->extended_clocking) && ((info->line_interface == V24)
+                                         || (info->line_interface ==
+                                             RS530_449))) {
+               usb_dev->ports[0]->usb_config.clock = 0;
+               if (info->extended_clocking & 4) {
+                       usb_dev->ports[0]->usb_config.extended_config =
+                           EXT_CONFIG_TTT;
+               }
+               if (info->extended_clocking & 8) {
+                       usb_dev->ports[0]->usb_config.extended_config =
+                           EXT_CONFIG_RTT;
+               }
+       } else {
+               /* Reset extended config because wrong line type
+                */
+               usb_dev->ports[0]->usb_config.extended_config = 0;
+       }
+       fst_dbg(DBG_IOCTL, "Extended Clocking is %x\n",
+               info->extended_clocking);
+
+       flex_serconf_to_le(&usb_dev->ports[0]->usb_config);
+       retval = usb_control_msg(usb_dev->udev, usb_sndctrlpipe(usb_dev->udev,
+                                                               0),
+                                USS_CMD_SET_CONFIG, 0x40, 0, 0,
+                                &usb_dev->ports[0]->usb_config,
+                                sizeof(FLEX_SERCONF), 10000);
+       flex_serconf_to_cpu(&usb_dev->ports[0]->usb_config);
+       if (retval > 0) {
+               fst_dbg(DBG_IOCTL, "Set config response received\n");
+               return 1;
+       } else {
+         fst_dbg(DBG_ASS, "Set Config error errno = %d\n", retval);
+               return 0;
+       }
+}
+
+/*      Initialise usb interface when detected.
+ *      Returns 0 to indicate success, or errno otherwise.
+ */
+static int flex_probe(struct usb_interface *interface,
+                     const struct usb_device_id *id)
+{
+       static int firsttime_done;
+       struct fst_card_info *dev;
+       struct usb_host_interface *iface_desc;
+       struct usb_endpoint_descriptor *endpoint;
+       size_t buffer_size;
+       int i;
+       int retval = 0;
+       int instance = 0;
+       char dev_name[16];
+
+       if (!firsttime_done) {
+               pr_info("Flex USB WAN driver " FST_USER_VERSION
+                      "-" FST_PATCH_LEVEL "-" FST_PLATFORM FST_ADDITIONAL
+                      " (c) 2001-2013 FarSite Communications Ltd.\n");
+               firsttime_done = 1;
+#if FST_DEBUG
+               fst_dbg(DBG_ASS, "The value of debug mask is %x\n",
+                       fst_debug_mask);
+#endif
+       }
+
+       /* set the defaults */
+       strcpy(dev_name, FST_PORT_NAME);
+       strcat(dev_name, "%d");
+
+       /* We are going to be clever and allow certain cards not to be
+        * configured.  An exclude list can be provided in /etc/modules.conf
+        */
+       if (fst_excluded_cards != 0) {
+               /*
+                * There are cards to exclude
+                *
+                */
+               for (i = 0; i < fst_excluded_cards; i++) {
+                       if (1 == fst_excluded_list[i]) {
+                               fst_dbg(DBG_ASS,
+                               "Flex USB device %d not assigned\n", 1);
+                               return -EBUSY;
+                       }
+               }
+       }
+
+       /* Allocate driver private data */
+       dev = kmalloc(sizeof(struct fst_card_info), GFP_KERNEL);
+       if (dev == NULL) {
+               pr_err("Flex USB device found but insufficient memory for");
+                      pr_err(" driver storage\n");
+               return -ENOMEM;
+       }
+       fst_dbg(DBG_USB, "dev allocated at %p\n", dev);
+       memset(dev, 0, sizeof(struct fst_card_info));
+
+       dev->family = 0;
+       dev->nports = 1;
+       dev->state = FST_RUNNING;
+       dev->udev = usb_get_dev(interface_to_usbdev(interface));
+       dev->interface = interface;
+
+       fst_dbg(DBG_USB, "type %d nports %d irq %d\n", dev->type,
+               dev->nports, dev->irq);
+
+       sema_init(&dev->limit_sem, WRITES_IN_FLIGHT);
+       dev->tx_urb_cnt = MAX_URBS_OUTSTANDING;
+       /* set up the endpoint information
+        * use only the first bulk-in and bulk-out endpoints
+        */
+       iface_desc = interface->cur_altsetting;
+       fst_dbg(DBG_USB, "The number of endpoints on this device are %d\n",
+               iface_desc->desc.bNumEndpoints);
+       for (i = 0; i < iface_desc->desc.bNumEndpoints; ++i) {
+               endpoint = &iface_desc->endpoint[i].desc;
+               /* Get Bulk end point addresses
+                */
+               if (!dev->bulk_in_endpoint_addr &&
+                   ((endpoint->bEndpointAddress & USB_ENDPOINT_DIR_MASK)
+                    == USB_DIR_IN) &&
+                   ((endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
+                    == USB_ENDPOINT_XFER_BULK)) {
+                       /* we found a bulk in endpoint */
+                       buffer_size = le16_to_cpu(endpoint->wMaxPacketSize);
+                       dev->bulk_in_size = buffer_size;
+                       dev->bulk_in_endpoint_addr =
+                         endpoint->bEndpointAddress;
+                       dev->bulk_in_buffer = NULL;
+               }
+
+               if (!dev->bulk_out_endpoint_addr &&
+                   ((endpoint->bEndpointAddress & USB_ENDPOINT_DIR_MASK)
+                    == USB_DIR_OUT) &&
+                   ((endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
+                    == USB_ENDPOINT_XFER_BULK)) {
+                       /* we found a bulk out endpoint */
+                       dev->bulk_out_endpoint_addr =
+                         endpoint->bEndpointAddress;
+               }
+               /* Get Interrupt end point addresses
+                */
+               if (!dev->int_in_endpoint_addr &&
+                   ((endpoint->bEndpointAddress & USB_ENDPOINT_DIR_MASK)
+                    == USB_DIR_IN) &&
+                   ((endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
+                    == USB_ENDPOINT_XFER_INT)) {
+                       /* we found a int in endpoint */
+                       buffer_size = le16_to_cpu(endpoint->wMaxPacketSize);
+                       dev->int_in_size = buffer_size;
+                       dev->int_in_endpoint_addr = endpoint->bEndpointAddress;
+                       dev->int_in_buffer = NULL;
+               }
+
+               if (!dev->int_out_endpoint_addr &&
+                   ((endpoint->bEndpointAddress & USB_ENDPOINT_DIR_MASK)
+                    == USB_DIR_OUT) &&
+                   ((endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
+                    == USB_ENDPOINT_XFER_INT)) {
+                       /* we found a int out endpoint */
+                       dev->int_out_endpoint_addr =
+                         endpoint->bEndpointAddress;
+                       dev->int_interval = endpoint->bInterval;
+                       if ((dev->int_interval != 2)
+                           && (dev->int_interval != 16)) {
+                               pr_err("Interval value on int endpoint not ");
+                               pr_err("as expected %d\n",
+                                      dev->int_interval);
+                               dev->int_interval = 4;
+                       }
+                       dev->int_interval = 4;
+                       /* Larger values can cause a problem */
+               }
+       }
+       if (!(dev->bulk_in_endpoint_addr && dev->bulk_out_endpoint_addr)) {
+               pr_err
+                   ("Could not find both bulk-in and bulk-out endpoints");
+               goto error;
+       }
+       if (!(dev->int_in_endpoint_addr && dev->int_out_endpoint_addr)) {
+               pr_err
+                   ("Could not find both int-in %d and int-out %d endpoints",
+                    dev->int_in_endpoint_addr, dev->int_out_endpoint_addr);
+       }
+
+       /* save our data pointer in this interface device */
+       usb_set_intfdata(interface, dev);
+
+       /* allocate urbs */
+       retval = allocate_urbs_and_buffers(dev);
+       if (retval)
+               goto error;
+
+       /* Remainder of card setup */
+       dev->fifo_complete = 1;
+       fst_init_card(dev, dev_name);
+       flex_get_config(dev, dev->ports[0], NULL);
+       if (dev->ports[0]->usb_card_info.u_minor_rev >=
+           FIRST_FLEX_V2_MINOR_ID) {
+               fst_dbg(DBG_USB, "Flex Type Version 2 (minor rev = %d\n",
+                       dev->ports[0]->usb_card_info.u_minor_rev);
+               dev->type = FST_TYPE_FLEX2;
+       } else {
+               fst_dbg(DBG_USB, "Flex Type Version 1 (minor rev = %d\n",
+                       dev->ports[0]->usb_card_info.u_minor_rev);
+               dev->type = FST_TYPE_FLEX1;
+       }
+       strcpy(dev->ports[0]->dev->dev_addr,
+              dev->ports[0]->usb_card_info.sz_serial_no);
+       pr_info("%s-%s: (%s) %s, %d ports\n", dev->ports[0]->dev->name,
+               dev->ports[dev->nports - 1]->dev->name,
+               dev->ports[0]->usb_card_info.sz_serial_no,
+               type_strings[dev->type],
+              dev->nports);
+       /* we can register the device now, as it is ready */
+       retval = usb_register_dev(interface, &flex_class);
+       if (retval) {
+               /* something prevented us from registering this driver */
+               pr_err("Not able to get a minor for this device.");
+               usb_set_intfdata(interface, NULL);
+               goto error;
+       }
+       /* let the user know what node this device is now attached to */
+       instance = interface->minor % USB_MINOR_BASE;
+       pr_info("USB flex device now attached to Minor %d\n", instance);
+       fst_cards_list[instance] = dev;
+       dev->card_no = instance;
+       fst_ncards++;           /* Record instance and bump it */
+       fst_dbg(DBG_USB, "Setting the interface to start switch to 80MHz\n");
+       i = usb_set_interface(dev->udev, 0, 0);
+       if (i)
+               fst_dbg(DBG_ASS, "Error in call to usb_set_interface %d\n", i);
+       dev->actual_length = 0;
+       dev->usb_trace_ptr = 0;
+       post_a_read_int_urb(dev);       /* Start reading trace from card */
+       post_a_read_bulk_urb(dev);      /* Post a read for data */
+       return 0;               /* Success */
+
+       /* Failure. Release resources */
+error:
+       if (dev)
+               flex_delete(dev);
+       return retval;
+}
+
+/*      Cleanup and close down a card
+ */
+static void flex_disconnect(struct usb_interface *interface)
+{
+       struct fst_card_info *dev;
+       int minor = interface->minor % USB_MINOR_BASE;
+       int i;
+
+       dev = usb_get_intfdata(interface);
+       fst_dbg(DBG_USB, "%s: Closing usb device for minor %d\n",
+               dev->ports[0]->dev->name, minor);
+
+       /* give back our minor */
+       device_remove_file(dev->sync_cdev, &dev_attr_serial);
+       device_destroy(farsync_class, MKDEV(fst_major, minor));
+       usb_deregister_dev(interface, &flex_class);
+       for (i = 0; i < dev->nports; i++) {
+               if (dev->ports[i]->char_file) {
+                       fst_dbg(DBG_USB, "port is %p %p\n",
+                               dev->ports[i]->char_file->private_data,
+                               &dev->ports[i]);
+                       if (dev->ports[i]->char_file->private_data ==
+                           &dev->ports[i]) {
+                               fst_dbg(DBG_USB,
+                                       "Zapped files pointer to us\n");
+                               dev->ports[i]->char_file->private_data = NULL;
+                       }
+               }
+               fst_tty_area[minor].state = FST_TTY_ST_DISC;
+               fst_dbg(DBG_TTY,
+                       "Calling tty unregister device for port %d\n", minor);
+               tty_port_destroy(&fst_tty_area[minor].tty_port);
+               tty_unregister_device(serial_drv, minor);
+               if (dev->ports[i]->fifo_rxdata) {
+                       /* Deallocate the rx fifo
+                        */
+                       u16 used_space;
+                       used_space =
+                           (u16) ((dev->ports[i]->fifo_rxdata->write_idx -
+                                   dev->ports[i]->fifo_rxdata->read_idx)
+                                  % dev->ports[i]->fifo_rxdata->fifo_length);
+                       fst_dbg(DBG_ASS, "%s: Releasing Fifo memory at %p\n",
+                               dev->ports[i]->dev->name,
+                               dev->ports[i]->fifo_rxdata);
+                       fst_dbg(DBG_ASS, "%s: %d bytes left in fifo\n",
+                               dev->ports[i]->dev->name, used_space);
+                       kfree(dev->ports[i]->fifo_rxdata);
+                       dev->ports[i]->fifo_rxdata = NULL;
+               }
+               unregister_hdlc_device(dev->ports[i]->dev);
+               kfree(dev->ports[i]->dev);
+               fst_ports_list[dev->ports[i]->minor_dev_no] = NULL;
+               while (dev->ports[i]->txqe != dev->ports[i]->txqs) {
+                       pr_info("Purging tx queue %d %d\n",
+                               dev->ports[i]->txqe,
+                              dev->ports[i]->txqs);
+                       pr_info("%s: Closing port with data in tx queue %p\n",
+                              dev->ports[i]->dev->name,
+                              dev->ports[i]->txq[dev->ports[i]->txqs].frame);
+                       dev_kfree_skb(dev->ports[i]->
+                                     txq[dev->ports[i]->txqs].frame);
+                       dev->ports[i]->txqs++;
+                       if (dev->ports[i]->txqs == FST_TXQ_DEPTH)
+                               dev->ports[i]->txqs = 0;
+               }
+               kfree(dev->ports[i]);
+       }
+       fst_cards_list[dev->card_no] = NULL;
+       fst_ncards--;
+       /* decrement our usage count */
+       deallocate_urbs_and_buffers(dev);
+       usb_set_intfdata(interface, NULL);
+       flex_delete(dev);
+}
+
+static struct usb_driver fst_driver = {
+       .name = "fsflex",
+       .probe = flex_probe,
+       .disconnect = flex_disconnect,
+       .id_table = flex_table,
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
+};
+
+static int __init fst_init(void)
+{
+       int i;
+
+       INIT_WORK(&thresh_work_q, fst_process_threshold_work_q);
+       INIT_WORK(&port_stats_work_q, fst_process_port_stats_work_q);
+       for (i = 0; i < FST_MAX_CARDS; i++)
+               fst_cards_list[i] = NULL;
+       for (i = 0; i < FST_MAX_CARDS * FST_MAX_PORTS; i++) {
+               fst_ports_list[i] = NULL;
+               fst_net_list[i] = NULL;
+       }
+       spin_lock_init(&fst_work_q_lock);
+       /* Create the /proc entry for /proc/fsflex
+        */
+       proc_create("fsflex", 0, NULL, &farsync_proc_fops);
+       /* Register the char driver */
+       fst_tty_init();
+       fst_major = FST_TTY_MAJOR;
+       fst_dbg(DBG_ASS, "Creating the device class for fsflex\n");
+       farsync_class = class_create(THIS_MODULE, "fsflex");
+       i = usb_register(&fst_driver);
+       if (i) {
+               pr_err("usb_register failed. Error number %d", i);
+               return i;
+       }
+       pr_info("fst_iocinfo_version set to %d\n", fst_iocinfo_version);
+       return 0;
+}
+
+static void __exit fst_cleanup_module(void)
+{
+       usb_deregister(&fst_driver);
+       /* Remove the char device driver entry */
+       fst_tty_uninit();
+       remove_proc_entry("fsflex", NULL);
+       class_destroy(farsync_class);
+       pr_info("Unloading module fsflex\n");
+}
+
+/* Converts the FLEX_SERCONF structure from native to Little Endian
+ */
+static void flex_serconf_to_le(FLEX_SERCONF *usb_config)
+{
+       cpu_to_le32s(&usb_config->u_version);
+       cpu_to_le32s(&usb_config->iface);
+       cpu_to_le32s(&usb_config->termination);
+       cpu_to_le32s(&usb_config->line_speed);
+       cpu_to_le32s(&usb_config->clock);
+       cpu_to_le32s(&usb_config->encoding);
+       cpu_to_le32s(&usb_config->mode);
+       cpu_to_le32s(&usb_config->sync_char);
+       cpu_to_le32s(&usb_config->bit_order);
+       cpu_to_le32s(&usb_config->rxclock);
+       cpu_to_le32s(&usb_config->start);
+       cpu_to_le32s(&usb_config->num_tx_buffer);
+       cpu_to_le32s(&usb_config->num_rx_buffer);
+       cpu_to_le32s(&usb_config->size_tx_buffer);
+       cpu_to_le32s(&usb_config->size_rx_buffer);
+       cpu_to_le32s(&usb_config->data_bits);
+       cpu_to_le32s(&usb_config->parity);
+       cpu_to_le32s(&usb_config->stopbits);
+       cpu_to_le32s(&usb_config->flow_control);
+       cpu_to_le32s(&usb_config->timeout_enable);
+       cpu_to_le32s(&usb_config->timeout_length);
+       cpu_to_le32s(&usb_config->monitor_mode);
+       cpu_to_le32s(&usb_config->extended_clocking);
+       cpu_to_le32s(&usb_config->internal_tx_clock);
+       cpu_to_le32s(&usb_config->internal_rx_clock);
+       cpu_to_le32s(&usb_config->enable_nrzi_clocking);
+       cpu_to_le32s(&usb_config->xonchar);
+       cpu_to_le32s(&usb_config->xoffchar);
+       cpu_to_le32s(&usb_config->preserve_signals);
+       cpu_to_le32s(&usb_config->async_receive_mode);
+       cpu_to_le32s(&usb_config->crc_reset);
+       cpu_to_le32s(&usb_config->extended_config);
+}
+
+/* Converts the FLEX_SERCONF struct from Little Endian to native
+ */
+static void flex_serconf_to_cpu(FLEX_SERCONF *usb_config)
+{
+       le32_to_cpus(&usb_config->u_version);
+       le32_to_cpus(&usb_config->iface);
+       le32_to_cpus(&usb_config->termination);
+       le32_to_cpus(&usb_config->line_speed);
+       le32_to_cpus(&usb_config->clock);
+       le32_to_cpus(&usb_config->encoding);
+       le32_to_cpus(&usb_config->mode);
+       le32_to_cpus(&usb_config->sync_char);
+       le32_to_cpus(&usb_config->bit_order);
+       le32_to_cpus(&usb_config->rxclock);
+       le32_to_cpus(&usb_config->start);
+       le32_to_cpus(&usb_config->num_tx_buffer);
+       le32_to_cpus(&usb_config->num_rx_buffer);
+       le32_to_cpus(&usb_config->size_tx_buffer);
+       le32_to_cpus(&usb_config->size_rx_buffer);
+       le32_to_cpus(&usb_config->data_bits);
+       le32_to_cpus(&usb_config->parity);
+       le32_to_cpus(&usb_config->stopbits);
+       le32_to_cpus(&usb_config->flow_control);
+       le32_to_cpus(&usb_config->timeout_enable);
+       le32_to_cpus(&usb_config->timeout_length);
+       le32_to_cpus(&usb_config->monitor_mode);
+       le32_to_cpus(&usb_config->extended_clocking);
+       le32_to_cpus(&usb_config->internal_tx_clock);
+       le32_to_cpus(&usb_config->internal_rx_clock);
+       le32_to_cpus(&usb_config->enable_nrzi_clocking);
+       le32_to_cpus(&usb_config->xonchar);
+       le32_to_cpus(&usb_config->xoffchar);
+       le32_to_cpus(&usb_config->preserve_signals);
+       le32_to_cpus(&usb_config->async_receive_mode);
+       le32_to_cpus(&usb_config->crc_reset);
+       le32_to_cpus(&usb_config->extended_config);
+}
+
+/* Convert the Flex Interface Record definition into Little Endian,
+ * ready for USB
+ */
+static void flex_irex_to_le(IREX *stats)
+{
+       int i;
+       cpu_to_le32s(&stats->interface_record.rx_frame_count);
+       cpu_to_le32s(&stats->interface_record.tx_max_fr_size_now);
+       cpu_to_le32s(&stats->interface_record.status_count);
+       for (i = 0; i < SAMAXSTAT; i++)
+               cpu_to_le32s(&stats->interface_record.status_array[i]);
+       cpu_to_le32s(&stats->status_count);
+       cpu_to_le32s(&stats->opened_count);
+       cpu_to_le32s(&stats->tx_request_count);
+       cpu_to_le32s(&stats->tx_complete_count);
+       cpu_to_le32s(&stats->rx_posted_count);
+       cpu_to_le32s(&stats->rx_complete_count);
+}
+
+/* Converts the IREX object from Little Endian to native byte order
+ */
+static void flex_irex_to_cpu(IREX *stats)
+{
+       int i;
+       le32_to_cpus(&stats->interface_record.rx_frame_count);
+       le32_to_cpus(&stats->interface_record.tx_max_fr_size_now);
+       le32_to_cpus(&stats->interface_record.status_count);
+       for (i = 0; i < SAMAXSTAT; i++)
+               le32_to_cpus(&stats->interface_record.status_array[i]);
+       le32_to_cpus(&stats->status_count);
+       le32_to_cpus(&stats->opened_count);
+       le32_to_cpus(&stats->tx_request_count);
+       le32_to_cpus(&stats->tx_complete_count);
+       le32_to_cpus(&stats->rx_posted_count);
+       le32_to_cpus(&stats->rx_complete_count);
+}
+
+/* Converts the struct fstioc_req from native byte order to Little Endian
+ */
+static void flex_fstioc_req_to_le(struct fstioc_req *sys_request)
+{
+       cpu_to_le16s(&sys_request->msg_type);
+       cpu_to_le16s(&sys_request->msg_len);
+       cpu_to_le16s(&sys_request->ret_code);
+       cpu_to_le16s(&sys_request->i_reg_idx);
+       cpu_to_le16s(&sys_request->value);
+}
+
+/* Converts the struct fstioc_req from native to Little Endian byte order
+ */
+static void flex_fstioc_req_to_cpu(struct fstioc_req *sys_request)
+{
+       le16_to_cpus(&sys_request->msg_type);
+       le16_to_cpus(&sys_request->msg_len);
+       le16_to_cpus(&sys_request->ret_code);
+       le16_to_cpus(&sys_request->i_reg_idx);
+       le16_to_cpus(&sys_request->value);
+}
+
+/* Converts flex_card_info from native to Little Endian (USB format)
+ */
+static void flex_card_info_to_le(FLEX_CARD_INFO *usb_card_info)
+{
+       unsigned short i;
+       cpu_to_le32s(&usb_card_info->u_version);
+       cpu_to_le32s(&usb_card_info->u_major_rev);
+       cpu_to_le32s(&usb_card_info->u_minor_rev);
+       cpu_to_le32s(&usb_card_info->u_build_state);
+       cpu_to_le32s(&usb_card_info->u_cpu_speed);
+       cpu_to_le32s(&usb_card_info->u_mode);
+       cpu_to_le32s(&usb_card_info->u_software_version);
+       cpu_to_le32s(&usb_card_info->u_arm_version);
+       cpu_to_le32s(&usb_card_info->uflash_manf_id);
+       cpu_to_le32s(&usb_card_info->uflash_dev_id);
+       cpu_to_le32s(&usb_card_info->u_serocco_version);
+       for (i = 0; i < 17; i++)
+               cpu_to_le32s(&usb_card_info->spare[i]);
+}
+
+/* Converts the flex_card_info back from USB's Little Endian format into native
+ */
+static void flex_card_info_to_cpu(FLEX_CARD_INFO *usb_card_info)
+{
+       unsigned short i;
+       le32_to_cpus(&usb_card_info->u_version);
+       le32_to_cpus(&usb_card_info->u_major_rev);
+       le32_to_cpus(&usb_card_info->u_minor_rev);
+       le32_to_cpus(&usb_card_info->u_build_state);
+       le32_to_cpus(&usb_card_info->u_cpu_speed);
+       le32_to_cpus(&usb_card_info->u_mode);
+       le32_to_cpus(&usb_card_info->u_software_version);
+       le32_to_cpus(&usb_card_info->u_arm_version);
+       le32_to_cpus(&usb_card_info->uflash_manf_id);
+       le32_to_cpus(&usb_card_info->uflash_dev_id);
+       le32_to_cpus(&usb_card_info->u_serocco_version);
+       for (i = 0; i < 17; i++)
+               le32_to_cpus(&usb_card_info->spare[i]);
+}
+
+/* Convert the header back from USB's Little Endian format to native
+ */
+static void flex_txrx_preamble_to_cpu(FSCMN_TXRX_PREAMBLE *header)
+{
+       le32_to_cpus(&header->timestamp);
+       le16_to_cpus(&header->length);
+}
+
+module_init(fst_init);
+module_exit(fst_cleanup_module);
