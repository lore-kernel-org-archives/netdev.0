From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
	vmxnet3
Date: Tue, 29 Sep 2009 01:53:33 -0700
Message-ID: <20090929085333.GC3958@sequoia.sous-sol.org>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Chris Wright <chrisw@sous-sol.org>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753535AbZI2IzC@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Shreyas Bhatewara (sbhatewara@vmware.com) wrote:
> Some of the features of vmxnet3 are :
>         PCIe 2.0 compliant PCI device: Vendor ID 0x15ad, Device ID 0x07b0
>         INTx, MSI, MSI-X (25 vectors) interrupts
>         16 Rx queues, 8 Tx queues

Driver doesn't appear to actually support more than a single MSI-X interrupt.
What is your plan for doing real multiqueue?

>         Offloads: TCP/UDP checksum, TSO over IPv4/IPv6,
>                     802.1q VLAN tag insertion, filtering, stripping
>                     Multicast filtering, Jumbo Frames

How about GRO conversion?

>         Wake-on-LAN, PCI Power Management D0-D3 states
>         PXE-ROM for boot support
> 

Whole thing appears to be space indented, and is fairly noisy w/ printk.
Also, heavy use of BUG_ON() (counted 51 of them), are you sure that none
of them can be triggered by guest or remote (esp. the ones that happen
in interrupt context)?  Some initial thoughts below.

<snip>
> diff --git a/drivers/net/vmxnet3/upt1_defs.h b/drivers/net/vmxnet3/upt1_defs.h
> new file mode 100644
> index 0000000..b50f91b
> --- /dev/null
> +++ b/drivers/net/vmxnet3/upt1_defs.h
> @@ -0,0 +1,104 @@
> +/*
> + * Linux driver for VMware's vmxnet3 ethernet NIC.
> + *
> + * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the
> + * Free Software Foundation; version 2 of the License and no later version.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
> + * NON INFRINGEMENT.  See the GNU General Public License for more
> + * details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
> + *
> + */
> +
> +/* upt1_defs.h
> + *
> + *      Definitions for Uniform Pass Through.
> + */

Most of the source files have this format (some include -- after file
name).  Could just keep it all w/in the same comment block.  Since you
went to the trouble of saying what the file does, something a tad more
descriptive would be welcome.

> +
> +#ifndef _UPT1_DEFS_H
> +#define _UPT1_DEFS_H
> +
> +#define UPT1_MAX_TX_QUEUES  64
> +#define UPT1_MAX_RX_QUEUES  64

This is different than the 16/8 described above (and seemingly all moot
since it becomes a single queue device).

> +
> +/* interrupt moderation level */
> +#define UPT1_IML_NONE     0 /* no interrupt moderation */
> +#define UPT1_IML_HIGHEST  7 /* least intr generated */
> +#define UPT1_IML_ADAPTIVE 8 /* adpative intr moderation */

enum?  also only appears to support adaptive mode?

> +/* values for UPT1_RSSConf.hashFunc */
> +enum {
> +       UPT1_RSS_HASH_TYPE_NONE      = 0x0,
> +       UPT1_RSS_HASH_TYPE_IPV4      = 0x01,
> +       UPT1_RSS_HASH_TYPE_TCP_IPV4  = 0x02,
> +       UPT1_RSS_HASH_TYPE_IPV6      = 0x04,
> +       UPT1_RSS_HASH_TYPE_TCP_IPV6  = 0x08,
> +};
> +
> +enum {
> +       UPT1_RSS_HASH_FUNC_NONE      = 0x0,
> +       UPT1_RSS_HASH_FUNC_TOEPLITZ  = 0x01,
> +};
> +
> +#define UPT1_RSS_MAX_KEY_SIZE        40
> +#define UPT1_RSS_MAX_IND_TABLE_SIZE  128
> +
> +struct UPT1_RSSConf {
> +       uint16_t   hashType;
> +       uint16_t   hashFunc;
> +       uint16_t   hashKeySize;
> +       uint16_t   indTableSize;
> +       uint8_t    hashKey[UPT1_RSS_MAX_KEY_SIZE];
> +       uint8_t    indTable[UPT1_RSS_MAX_IND_TABLE_SIZE];
> +};
> +
> +/* features */
> +enum {
> +       UPT1_F_RXCSUM      = 0x0001,   /* rx csum verification */
> +       UPT1_F_RSS         = 0x0002,
> +       UPT1_F_RXVLAN      = 0x0004,   /* VLAN tag stripping */
> +       UPT1_F_LRO         = 0x0008,
> +};
> +#endif
> diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
> new file mode 100644
> index 0000000..a33a90b
> --- /dev/null
> +++ b/drivers/net/vmxnet3/vmxnet3_defs.h
> @@ -0,0 +1,534 @@
> +/*
> + * Linux driver for VMware's vmxnet3 ethernet NIC.
> + *
> + * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the
> + * Free Software Foundation; version 2 of the License and no later version.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
> + * NON INFRINGEMENT.  See the GNU General Public License for more
> + * details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".
> + *
> + * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
> + *
> + */
> +
> +/*
> + * vmxnet3_defs.h --

Not particularly useful ;-)

> + */
> +
> +#ifndef _VMXNET3_DEFS_H_
> +#define _VMXNET3_DEFS_H_
> +
> +#include "upt1_defs.h"
> +
> +/* all registers are 32 bit wide */
> +/* BAR 1 */
> +enum {
> +       VMXNET3_REG_VRRS  = 0x0,        /* Vmxnet3 Revision Report Selection */
> +       VMXNET3_REG_UVRS  = 0x8,        /* UPT Version Report Selection */
> +       VMXNET3_REG_DSAL  = 0x10,       /* Driver Shared Address Low */
> +       VMXNET3_REG_DSAH  = 0x18,       /* Driver Shared Address High */
> +       VMXNET3_REG_CMD   = 0x20,       /* Command */
> +       VMXNET3_REG_MACL  = 0x28,       /* MAC Address Low */
> +       VMXNET3_REG_MACH  = 0x30,       /* MAC Address High */
> +       VMXNET3_REG_ICR   = 0x38,       /* Interrupt Cause Register */
> +       VMXNET3_REG_ECR   = 0x40        /* Event Cause Register */
> +};
> +
> +/* BAR 0 */
> +enum {
> +       VMXNET3_REG_IMR      = 0x0,     /* Interrupt Mask Register */
> +       VMXNET3_REG_TXPROD   = 0x600,   /* Tx Producer Index */
> +       VMXNET3_REG_RXPROD   = 0x800,   /* Rx Producer Index for ring 1 */
> +       VMXNET3_REG_RXPROD2  = 0xA00    /* Rx Producer Index for ring 2 */
> +};
> +
> +#define VMXNET3_PT_REG_SIZE     4096   /* BAR 0 */
> +#define VMXNET3_VD_REG_SIZE     4096   /* BAR 1 */
> +
> +#define VMXNET3_REG_ALIGN       8      /* All registers are 8-byte aligned. */
> +#define VMXNET3_REG_ALIGN_MASK  0x7
> +
> +/* I/O Mapped access to registers */
> +#define VMXNET3_IO_TYPE_PT              0
> +#define VMXNET3_IO_TYPE_VD              1
> +#define VMXNET3_IO_ADDR(type, reg)      (((type) << 24) | ((reg) & 0xFFFFFF))
> +#define VMXNET3_IO_TYPE(addr)           ((addr) >> 24)
> +#define VMXNET3_IO_REG(addr)            ((addr) & 0xFFFFFF)
> +
> +enum {
> +       VMXNET3_CMD_FIRST_SET = 0xCAFE0000,
> +       VMXNET3_CMD_ACTIVATE_DEV = VMXNET3_CMD_FIRST_SET,
> +       VMXNET3_CMD_QUIESCE_DEV,
> +       VMXNET3_CMD_RESET_DEV,
> +       VMXNET3_CMD_UPDATE_RX_MODE,
> +       VMXNET3_CMD_UPDATE_MAC_FILTERS,
> +       VMXNET3_CMD_UPDATE_VLAN_FILTERS,
> +       VMXNET3_CMD_UPDATE_RSSIDT,
> +       VMXNET3_CMD_UPDATE_IML,
> +       VMXNET3_CMD_UPDATE_PMCFG,
> +       VMXNET3_CMD_UPDATE_FEATURE,
> +       VMXNET3_CMD_LOAD_PLUGIN,
> +
> +       VMXNET3_CMD_FIRST_GET = 0xF00D0000,
> +       VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
> +       VMXNET3_CMD_GET_STATS,
> +       VMXNET3_CMD_GET_LINK,
> +       VMXNET3_CMD_GET_PERM_MAC_LO,
> +       VMXNET3_CMD_GET_PERM_MAC_HI,
> +       VMXNET3_CMD_GET_DID_LO,
> +       VMXNET3_CMD_GET_DID_HI,
> +       VMXNET3_CMD_GET_DEV_EXTRA_INFO,
> +       VMXNET3_CMD_GET_CONF_INTR
> +};
> +
> +struct Vmxnet3_TxDesc {
> +       uint64_t addr;
> +
> +       uint32_t len:14;
> +       uint32_t gen:1;      /* generation bit */
> +       uint32_t rsvd:1;
> +       uint32_t dtype:1;    /* descriptor type */
> +       uint32_t ext1:1;
> +       uint32_t msscof:14;  /* MSS, checksum offset, flags */
> +
> +       uint32_t hlen:10;    /* header len */
> +       uint32_t om:2;       /* offload mode */
> +       uint32_t eop:1;      /* End Of Packet */
> +       uint32_t cq:1;       /* completion request */
> +       uint32_t ext2:1;
> +       uint32_t ti:1;       /* VLAN Tag Insertion */
> +       uint32_t tci:16;     /* Tag to Insert */
> +};
> +
> +/* TxDesc.OM values */
> +#define VMXNET3_OM_NONE  0
> +#define VMXNET3_OM_CSUM  2
> +#define VMXNET3_OM_TSO   3
> +
> +/* fields in TxDesc we access w/o using bit fields */
> +#define VMXNET3_TXD_EOP_SHIFT 12
> +#define VMXNET3_TXD_CQ_SHIFT  13
> +#define VMXNET3_TXD_GEN_SHIFT 14
> +
> +#define VMXNET3_TXD_CQ  (1 << VMXNET3_TXD_CQ_SHIFT)
> +#define VMXNET3_TXD_EOP (1 << VMXNET3_TXD_EOP_SHIFT)
> +#define VMXNET3_TXD_GEN (1 << VMXNET3_TXD_GEN_SHIFT)
> +
> +#define VMXNET3_HDR_COPY_SIZE   128
> +
> +
> +struct Vmxnet3_TxDataDesc {
> +       uint8_t data[VMXNET3_HDR_COPY_SIZE];
> +};
> +
> +
> +struct Vmxnet3_TxCompDesc {
> +       uint32_t txdIdx:12;    /* Index of the EOP TxDesc */
> +       uint32_t ext1:20;
> +
> +       uint32_t ext2;
> +       uint32_t ext3;
> +
> +       uint32_t rsvd:24;
> +       uint32_t type:7;       /* completion type */
> +       uint32_t gen:1;        /* generation bit */
> +};
> +
> +
> +struct Vmxnet3_RxDesc {
> +       uint64_t addr;
> +
> +       uint32_t len:14;
> +       uint32_t btype:1;      /* Buffer Type */
> +       uint32_t dtype:1;      /* Descriptor type */
> +       uint32_t rsvd:15;
> +       uint32_t gen:1;        /* Generation bit */
> +
> +       uint32_t ext1;
> +};
> +
> +/* values of RXD.BTYPE */
> +#define VMXNET3_RXD_BTYPE_HEAD   0    /* head only */
> +#define VMXNET3_RXD_BTYPE_BODY   1    /* body only */
> +
> +/* fields in RxDesc we access w/o using bit fields */
> +#define VMXNET3_RXD_BTYPE_SHIFT  14
> +#define VMXNET3_RXD_GEN_SHIFT    31
> +
> +
> +struct Vmxnet3_RxCompDesc {
> +       uint32_t rxdIdx:12;    /* Index of the RxDesc */
> +       uint32_t ext1:2;
> +       uint32_t eop:1;        /* End of Packet */
> +       uint32_t sop:1;        /* Start of Packet */
> +       uint32_t rqID:10;      /* rx queue/ring ID */
> +       uint32_t rssType:4;    /* RSS hash type used */
> +       uint32_t cnc:1;        /* Checksum Not Calculated */
> +       uint32_t ext2:1;
> +
> +       uint32_t rssHash;      /* RSS hash value */
> +
> +       uint32_t len:14;       /* data length */
> +       uint32_t err:1;        /* Error */
> +       uint32_t ts:1;         /* Tag is stripped */
> +       uint32_t tci:16;       /* Tag stripped */
> +
> +       uint32_t csum:16;
> +       uint32_t tuc:1;        /* TCP/UDP Checksum Correct */
> +       uint32_t udp:1;        /* UDP packet */
> +       uint32_t tcp:1;        /* TCP packet */
> +       uint32_t ipc:1;        /* IP Checksum Correct */
> +       uint32_t v6:1;         /* IPv6 */
> +       uint32_t v4:1;         /* IPv4 */
> +       uint32_t frg:1;        /* IP Fragment */
> +       uint32_t fcs:1;        /* Frame CRC correct */
> +       uint32_t type:7;       /* completion type */
> +       uint32_t gen:1;        /* generation bit */
> +};
> +
> +/* fields in RxCompDesc we access via Vmxnet3_GenericDesc.dword[3] */
> +#define VMXNET3_RCD_TUC_SHIFT  16
> +#define VMXNET3_RCD_IPC_SHIFT  19
> +
> +/* fields in RxCompDesc we access via Vmxnet3_GenericDesc.qword[1] */
> +#define VMXNET3_RCD_TYPE_SHIFT 56
> +#define VMXNET3_RCD_GEN_SHIFT  63
> +
> +/* csum OK for TCP/UDP pkts over IP */
> +#define VMXNET3_RCD_CSUM_OK (1 << VMXNET3_RCD_TUC_SHIFT | \
> +                            1 << VMXNET3_RCD_IPC_SHIFT)
> +
> +/* value of RxCompDesc.rssType */
> +enum {
> +       VMXNET3_RCD_RSS_TYPE_NONE     = 0,
> +       VMXNET3_RCD_RSS_TYPE_IPV4     = 1,
> +       VMXNET3_RCD_RSS_TYPE_TCPIPV4  = 2,
> +       VMXNET3_RCD_RSS_TYPE_IPV6     = 3,
> +       VMXNET3_RCD_RSS_TYPE_TCPIPV6  = 4,
> +};
> +
> +/* a union for accessing all cmd/completion descriptors */
> +union Vmxnet3_GenericDesc {
> +       uint64_t                        qword[2];
> +       uint32_t                        dword[4];
> +       uint16_t                        word[8];
> +       struct Vmxnet3_TxDesc           txd;
> +       struct Vmxnet3_RxDesc           rxd;
> +       struct Vmxnet3_TxCompDesc       tcd;
> +       struct Vmxnet3_RxCompDesc       rcd;
> +};
> +
> +#define VMXNET3_INIT_GEN       1
> +
> +/* Max size of a single tx buffer */
> +#define VMXNET3_MAX_TX_BUF_SIZE  (1 << 14)
> +
> +/* # of tx desc needed for a tx buffer size */
> +#define VMXNET3_TXD_NEEDED(size) (((size) + VMXNET3_MAX_TX_BUF_SIZE - 1) / \
> +                                 VMXNET3_MAX_TX_BUF_SIZE)
> +
> +/* max # of tx descs for a non-tso pkt */
> +#define VMXNET3_MAX_TXD_PER_PKT 16
> +
> +/* Max size of a single rx buffer */
> +#define VMXNET3_MAX_RX_BUF_SIZE  ((1 << 14) - 1)
> +/* Minimum size of a type 0 buffer */
> +#define VMXNET3_MIN_T0_BUF_SIZE  128
> +#define VMXNET3_MAX_CSUM_OFFSET  1024
> +
> +/* Ring base address alignment */
> +#define VMXNET3_RING_BA_ALIGN   512
> +#define VMXNET3_RING_BA_MASK    (VMXNET3_RING_BA_ALIGN - 1)
> +
> +/* Ring size must be a multiple of 32 */
> +#define VMXNET3_RING_SIZE_ALIGN 32
> +#define VMXNET3_RING_SIZE_MASK  (VMXNET3_RING_SIZE_ALIGN - 1)
> +
> +/* Max ring size */
> +#define VMXNET3_TX_RING_MAX_SIZE   4096
> +#define VMXNET3_TC_RING_MAX_SIZE   4096
> +#define VMXNET3_RX_RING_MAX_SIZE   4096
> +#define VMXNET3_RC_RING_MAX_SIZE   8192
> +
> +/* a list of reasons for queue stop */
> +
> +enum {
> + VMXNET3_ERR_NOEOP        = 0x80000000,  /* cannot find the EOP desc of a pkt */
> + VMXNET3_ERR_TXD_REUSE    = 0x80000001,  /* reuse TxDesc before tx completion */
> + VMXNET3_ERR_BIG_PKT      = 0x80000002,  /* too many TxDesc for a pkt */
> + VMXNET3_ERR_DESC_NOT_SPT = 0x80000003,  /* descriptor type not supported */
> + VMXNET3_ERR_SMALL_BUF    = 0x80000004,  /* type 0 buffer too small */
> + VMXNET3_ERR_STRESS       = 0x80000005,  /* stress option firing in vmkernel */
> + VMXNET3_ERR_SWITCH       = 0x80000006,  /* mode switch failure */
> + VMXNET3_ERR_TXD_INVALID  = 0x80000007,  /* invalid TxDesc */
> +};
> +
> +/* completion descriptor types */
> +#define VMXNET3_CDTYPE_TXCOMP      0    /* Tx Completion Descriptor */
> +#define VMXNET3_CDTYPE_RXCOMP      3    /* Rx Completion Descriptor */
> +
> +enum {
> +       VMXNET3_GOS_BITS_UNK    = 0,   /* unknown */
> +       VMXNET3_GOS_BITS_32     = 1,
> +       VMXNET3_GOS_BITS_64     = 2,
> +};
> +
> +#define VMXNET3_GOS_TYPE_LINUX 1
> +
> +/* All structures in DriverShared are padded to multiples of 8 bytes */
> +
> +
> +struct Vmxnet3_GOSInfo {
> +       uint32_t   gosBits:2;   /* 32-bit or 64-bit? */
> +       uint32_t   gosType:4;   /* which guest */
> +       uint32_t   gosVer:16;   /* gos version */
> +       uint32_t   gosMisc:10;  /* other info about gos */
> +};
> +
> +
> +struct Vmxnet3_DriverInfo {
> +       uint32_t          version;        /* driver version */
> +       struct Vmxnet3_GOSInfo gos;
> +       uint32_t          vmxnet3RevSpt;  /* vmxnet3 revision supported */
> +       uint32_t          uptVerSpt;      /* upt version supported */
> +};
> +
> +#define VMXNET3_REV1_MAGIC  0xbabefee1
> 
> +
> +/*
> + * QueueDescPA must be 128 bytes aligned. It points to an array of
> + * Vmxnet3_TxQueueDesc followed by an array of Vmxnet3_RxQueueDesc.
> + * The number of Vmxnet3_TxQueueDesc/Vmxnet3_RxQueueDesc are specified by
> + * Vmxnet3_MiscConf.numTxQueues/numRxQueues, respectively.
> + */
> +#define VMXNET3_QUEUE_DESC_ALIGN  128

Lot of inconsistent spacing between types and names in the structure def'ns

> +struct Vmxnet3_MiscConf {
> +       struct Vmxnet3_DriverInfo driverInfo;
> +       uint64_t             uptFeatures;
> +       uint64_t             ddPA;         /* driver data PA */
> +       uint64_t             queueDescPA;  /* queue descriptor table PA */
> +       uint32_t             ddLen;        /* driver data len */
> +       uint32_t             queueDescLen; /* queue desc. table len in bytes */
> +       uint32_t             mtu;
> +       uint16_t             maxNumRxSG;
> +       uint8_t              numTxQueues;
> +       uint8_t              numRxQueues;
> +       uint32_t             reserved[4];
> +};

should this be packed (or others that are shared w/ device)?  i assume
you've already done 32 vs 64 here

> +struct Vmxnet3_TxQueueConf {
> +       uint64_t    txRingBasePA;
> +       uint64_t    dataRingBasePA;
> +       uint64_t    compRingBasePA;
> +       uint64_t    ddPA;         /* driver data */
> +       uint64_t    reserved;
> +       uint32_t    txRingSize;   /* # of tx desc */
> +       uint32_t    dataRingSize; /* # of data desc */
> +       uint32_t    compRingSize; /* # of comp desc */
> +       uint32_t    ddLen;        /* size of driver data */
> +       uint8_t     intrIdx;
> +       uint8_t     _pad[7];
> +};
> +
> +
> +struct Vmxnet3_RxQueueConf {
> +       uint64_t    rxRingBasePA[2];
> +       uint64_t    compRingBasePA;
> +       uint64_t    ddPA;            /* driver data */
> +       uint64_t    reserved;
> +       uint32_t    rxRingSize[2];   /* # of rx desc */
> +       uint32_t    compRingSize;    /* # of rx comp desc */
> +       uint32_t    ddLen;           /* size of driver data */
> +       uint8_t     intrIdx;
> +       uint8_t     _pad[7];
> +};
> +
> +enum vmxnet3_intr_mask_mode {
> +       VMXNET3_IMM_AUTO   = 0,
> +       VMXNET3_IMM_ACTIVE = 1,
> +       VMXNET3_IMM_LAZY   = 2
> +};
> +
> +enum vmxnet3_intr_type {
> +       VMXNET3_IT_AUTO = 0,
> +       VMXNET3_IT_INTX = 1,
> +       VMXNET3_IT_MSI  = 2,
> +       VMXNET3_IT_MSIX = 3
> +};
> +
> +#define VMXNET3_MAX_TX_QUEUES  8
> +#define VMXNET3_MAX_RX_QUEUES  16

different to UPT, I must've missed some layering here

> +/* addition 1 for events */
> +#define VMXNET3_MAX_INTRS      25
> +
> +
<snip>

> --- /dev/null
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -0,0 +1,2608 @@
> +/*
> + * Linux driver for VMware's vmxnet3 ethernet NIC.
<snip>
> +/*
> + * vmxnet3_drv.c --
> + *
> + *      Linux driver for VMware's vmxnet3 NIC
> + */

Not useful

> +static void
> +vmxnet3_enable_intr(struct vmxnet3_adapter *adapter, unsigned intr_idx)
> +{
> +       VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx * 8, 0);

	writel(0, adapter->hw_addr0 + VMXNET3_REG_IMR + intr_idx * 8)

seems just as clear to me.

> +vmxnet3_enable_all_intrs(struct vmxnet3_adapter *adapter)
> +{
> +       int i;
> +
> +       for (i = 0; i < adapter->intr.num_intrs; i++)
> +               vmxnet3_enable_intr(adapter, i);
> +}
> +
> +static void
> +vmxnet3_disable_all_intrs(struct vmxnet3_adapter *adapter)
> +{
> +       int i;
> +
> +       for (i = 0; i < adapter->intr.num_intrs; i++)
> +               vmxnet3_disable_intr(adapter, i);
> +}

only ever num_intrs=1, so there's some plan to bump this up and make
these wrappers useful?

> +static void
> +vmxnet3_ack_events(struct vmxnet3_adapter *adapter, u32 events)
> +{
> +       VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_ECR, events);
> +}
> +
> +
> +static bool
> +vmxnet3_tq_stopped(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
> +{
> +       return netif_queue_stopped(adapter->netdev);
> +}
> +
> +
> +static void
> +vmxnet3_tq_start(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter  *adapter)
> +{
> +       tq->stopped = false;

is tq->stopped used besides just toggling back and forth?

> +       netif_start_queue(adapter->netdev);
> +}

> +static void
> +vmxnet3_process_events(struct vmxnet3_adapter *adapter)

Should be trivial to break out to it's own MSI-X vector, basically set
up to do that already.

> +{
> +       u32 events = adapter->shared->ecr;
> +       if (!events)
> +               return;
> +
> +       vmxnet3_ack_events(adapter, events);
> +
> +       /* Check if link state has changed */
> +       if (events & VMXNET3_ECR_LINK)
> +               vmxnet3_check_link(adapter);
> +
> +       /* Check if there is an error on xmit/recv queues */
> +       if (events & (VMXNET3_ECR_TQERR | VMXNET3_ECR_RQERR)) {
> +               VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +                                      VMXNET3_CMD_GET_QUEUE_STATUS);
> +
> +               if (adapter->tqd_start->status.stopped) {
> +                       printk(KERN_ERR "%s: tq error 0x%x\n",
> +                              adapter->netdev->name,
> +                              adapter->tqd_start->status.error);
> +               }
> +               if (adapter->rqd_start->status.stopped) {
> +                       printk(KERN_ERR "%s: rq error 0x%x\n",
> +                              adapter->netdev->name,
> +                              adapter->rqd_start->status.error);
> +               }
> +
> +               schedule_work(&adapter->work);
> +       }
> +}
<snip>

> +
> +       tq->buf_info = kcalloc(sizeof(tq->buf_info[0]), tq->tx_ring.size,
> +                              GFP_KERNEL);

kcalloc args look backwards

<snip>
> +static int
> +vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter, bool *dma64)
> +{
> +       int err;
> +       unsigned long mmio_start, mmio_len;
> +       struct pci_dev *pdev = adapter->pdev;
> +
> +       err = pci_enable_device(pdev);

looks ioport free, can be pci_enable_device_mem()...

> +       if (err) {
> +               printk(KERN_ERR "Failed to enable adapter %s: error %d\n",
> +                      pci_name(pdev), err);
> +               return err;
> +       }
> +
> +       if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) == 0) {
> +               if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
> +                       printk(KERN_ERR "pci_set_consistent_dma_mask failed "
> +                              "for adapter %s\n", pci_name(pdev));
> +                       err = -EIO;
> +                       goto err_set_mask;
> +               }
> +               *dma64 = true;
> +       } else {
> +               if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
> +                       printk(KERN_ERR "pci_set_dma_mask failed for adapter "
> +                              "%s\n",  pci_name(pdev));
> +                       err = -EIO;
> +                       goto err_set_mask;
> +               }
> +               *dma64 = false;
> +       }
> +
> +       err = pci_request_regions(pdev, vmxnet3_driver_name);

...pci_request_selected_regions()

> +       if (err) {
> +               printk(KERN_ERR "Failed to request region for adapter %s: "
> +                      "error %d\n", pci_name(pdev), err);
> +               goto err_set_mask;
> +       }
> +
> +       pci_set_master(pdev);
> +
> +       mmio_start = pci_resource_start(pdev, 0);
> +       mmio_len = pci_resource_len(pdev, 0);
> +       adapter->hw_addr0 = ioremap(mmio_start, mmio_len);
> +       if (!adapter->hw_addr0) {
> +               printk(KERN_ERR "Failed to map bar0 for adapter %s\n",
> +                      pci_name(pdev));
> +               err = -EIO;
> +               goto err_ioremap;
> +       }
> +
> +       mmio_start = pci_resource_start(pdev, 1);
> +       mmio_len = pci_resource_len(pdev, 1);
> +       adapter->hw_addr1 = ioremap(mmio_start, mmio_len);
> +       if (!adapter->hw_addr1) {
> +               printk(KERN_ERR "Failed to map bar1 for adapter %s\n",
> +                      pci_name(pdev));
> +               err = -EIO;
> +               goto err_bar1;
> +       }
> +       return 0;
> +
> +err_bar1:
> +       iounmap(adapter->hw_addr0);
> +err_ioremap:
> +       pci_release_regions(pdev);

...and pci_release_selected_regions()

> +err_set_mask:
> +       pci_disable_device(pdev);
> +       return err;
> +}
> +

<snip>
> +vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
> +{
> +       struct net_device *netdev = adapter->netdev;
> +
> +       netdev->features = NETIF_F_SG |
> +               NETIF_F_HW_CSUM |
> +               NETIF_F_HW_VLAN_TX |
> +               NETIF_F_HW_VLAN_RX |
> +               NETIF_F_HW_VLAN_FILTER |
> +               NETIF_F_TSO |
> +               NETIF_F_TSO6;
> +
> +       printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6");
> +
> +       adapter->rxcsum = true;
> +       adapter->jumbo_frame = true;
> +
> +       if (!disable_lro) {
> +               adapter->lro = true;
> +               printk(" lro");
> +       }

Plan to switch to GRO?

> +       if (dma64) {
> +               netdev->features |= NETIF_F_HIGHDMA;
> +               printk(" highDMA");
> +       }
> +
> +       netdev->vlan_features = netdev->features;
> +       printk("\n");
> +}
> +
> +static int __devinit
> +vmxnet3_probe_device(struct pci_dev *pdev,
> +                    const struct pci_device_id *id)
> +{
> +       static const struct net_device_ops vmxnet3_netdev_ops = {
> +               .ndo_open  = vmxnet3_open,
> +               .ndo_stop  = vmxnet3_close,
> +               .ndo_start_xmit = vmxnet3_xmit_frame,
> +               .ndo_set_mac_address = vmxnet3_set_mac_addr,
> +               .ndo_change_mtu = vmxnet3_change_mtu,
> +               .ndo_get_stats = vmxnet3_get_stats,
> +               .ndo_tx_timeout = vmxnet3_tx_timeout,
> +               .ndo_set_multicast_list = vmxnet3_set_mc,
> +               .ndo_vlan_rx_register = vmxnet3_vlan_rx_register,
> +               .ndo_vlan_rx_add_vid = vmxnet3_vlan_rx_add_vid,
> +               .ndo_vlan_rx_kill_vid = vmxnet3_vlan_rx_kill_vid,
> +#   ifdef CONFIG_NET_POLL_CONTROLLER
> +               .ndo_poll_controller = vmxnet3_netpoll,
> +#   endif

#ifdef
#endif

is more typical style here

> +       };
> +       int err;
> +       bool dma64 = false; /* stupid gcc */
> +       u32 ver;
> +       struct net_device *netdev;
> +       struct vmxnet3_adapter *adapter;
> +       u8  mac[ETH_ALEN];

extra space between type and name

> +
> +       netdev = alloc_etherdev(sizeof(struct vmxnet3_adapter));
> +       if (!netdev) {
> +               printk(KERN_ERR "Failed to alloc ethernet device for adapter "
> +                       "%s\n", pci_name(pdev));
> +               return -ENOMEM;
> +       }
> +
> +       pci_set_drvdata(pdev, netdev);
> +       adapter = netdev_priv(netdev);
> +       adapter->netdev = netdev;
> +       adapter->pdev = pdev;
> +
> +       adapter->shared = pci_alloc_consistent(adapter->pdev,
> +                         sizeof(struct Vmxnet3_DriverShared),
> +                         &adapter->shared_pa);
> +       if (!adapter->shared) {
> +               printk(KERN_ERR "Failed to allocate memory for %s\n",
> +                       pci_name(pdev));
> +               err = -ENOMEM;
> +               goto err_alloc_shared;
> +       }
> +
> +       adapter->tqd_start  = pci_alloc_consistent(adapter->pdev,

extra space before =

> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> new file mode 100644
> index 0000000..490577f
> --- /dev/null
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +#include "vmxnet3_int.h"
> +
> +struct vmxnet3_stat_desc {
> +       char desc[ETH_GSTRING_LEN];
> +       int  offset;
> +};
> +
> +
> +static u32
> +vmxnet3_get_rx_csum(struct net_device *netdev)
> +{
> +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +       return adapter->rxcsum;
> +}
> +
> +
> +static int
> +vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
> +{
> +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +
> +       if (adapter->rxcsum != val) {
> +               adapter->rxcsum = val;
> +               if (netif_running(netdev)) {
> +                       if (val)
> +                               adapter->shared->devRead.misc.uptFeatures |=
> +                                                               UPT1_F_RXCSUM;
> +                       else
> +                               adapter->shared->devRead.misc.uptFeatures &=
> +                                                               ~UPT1_F_RXCSUM;
> +
> +                       VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +                                              VMXNET3_CMD_UPDATE_FEATURE);
> +               }
> +       }
> +       return 0;
> +}
> +
> +
> +static u32
> +vmxnet3_get_tx_csum(struct net_device *netdev)
> +{
> +       return (netdev->features & NETIF_F_HW_CSUM) != 0;
> +}

Not needed

> +static int
> +vmxnet3_set_tx_csum(struct net_device *netdev, u32 val)
> +{
> +       if (val)
> +               netdev->features |= NETIF_F_HW_CSUM;
> +       else
> +               netdev->features &= ~NETIF_F_HW_CSUM;
> +
> +       return 0;
> +}

This is just ethtool_op_set_tx_hw_csum()

> +static int
> +vmxnet3_set_sg(struct net_device *netdev, u32 val)
> +{
> +       ethtool_op_set_sg(netdev, val);
> +       return 0;
> +}

Useless wrapper

> +static int
> +vmxnet3_set_tso(struct net_device *netdev, u32 val)
> +{
> +       ethtool_op_set_tso(netdev, val);
> +       return 0;
> +}

Useless wrapper

> +struct net_device_stats*
> +vmxnet3_get_stats(struct net_device *netdev)
> +{
> +       struct vmxnet3_adapter *adapter;
> +       struct vmxnet3_tq_driver_stats *drvTxStats;
> +       struct vmxnet3_rq_driver_stats *drvRxStats;
> +       struct UPT1_TxStats *devTxStats;
> +       struct UPT1_RxStats *devRxStats;
> +
> +       adapter = netdev_priv(netdev);
> +
> +       /* Collect the dev stats into the shared area */
> +       VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
> +
> +       /* Assuming that we have a single queue device */
> +       devTxStats = &adapter->tqd_start->stats;
> +       devRxStats = &adapter->rqd_start->stats;

Another single queue assumption

> +
> +       /* Get access to the driver stats per queue */
> +       drvTxStats = &adapter->tx_queue.stats;
> +       drvRxStats = &adapter->rx_queue.stats;
> +
> +       memset(&adapter->net_stats, 0, sizeof(adapter->net_stats));
> +
> +       adapter->net_stats.rx_packets = devRxStats->ucastPktsRxOK +
> +                                       devRxStats->mcastPktsRxOK +
> +                                       devRxStats->bcastPktsRxOK;
> +
> +       adapter->net_stats.tx_packets = devTxStats->ucastPktsTxOK +
> +                                       devTxStats->mcastPktsTxOK +
> +                                       devTxStats->bcastPktsTxOK;
> +
> +       adapter->net_stats.rx_bytes = devRxStats->ucastBytesRxOK +
> +                                       devRxStats->mcastBytesRxOK +
> +                                       devRxStats->bcastBytesRxOK;
> +
> +       adapter->net_stats.tx_bytes = devTxStats->ucastBytesTxOK +
> +                                       devTxStats->mcastBytesTxOK +
> +                                       devTxStats->bcastBytesTxOK;
> +
> +       adapter->net_stats.rx_errors = devRxStats->pktsRxError;
> +       adapter->net_stats.tx_errors = devTxStats->pktsTxError;
> +       adapter->net_stats.rx_dropped = drvRxStats->drop_total;
> +       adapter->net_stats.tx_dropped = drvTxStats->drop_total;
> +       adapter->net_stats.multicast =  devRxStats->mcastPktsRxOK;
> +
> +       return &adapter->net_stats;
> +}
> +
> +static int
> +vmxnet3_get_stats_count(struct net_device *netdev)
> +{
> +       return ARRAY_SIZE(vmxnet3_tq_dev_stats) +
> +               ARRAY_SIZE(vmxnet3_tq_driver_stats) +
> +               ARRAY_SIZE(vmxnet3_rq_dev_stats) +
> +               ARRAY_SIZE(vmxnet3_rq_driver_stats) +
> +               ARRAY_SIZE(vmxnet3_global_stats);
> +}
> +
> +
> +static int
> +vmxnet3_get_regs_len(struct net_device *netdev)
> +{
> +       return 20 * sizeof(u32);
> +}
> +
> +
> +static void
> +vmxnet3_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
> +{
> +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +
> +       strncpy(drvinfo->driver, vmxnet3_driver_name, sizeof(drvinfo->driver));
> +       drvinfo->driver[sizeof(drvinfo->driver) - 1] = '\0';
> +
> +       strncpy(drvinfo->version, VMXNET3_DRIVER_VERSION_REPORT,
> +               sizeof(drvinfo->version));
> +       drvinfo->driver[sizeof(drvinfo->version) - 1] = '\0';
> +
> +       strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
> +       drvinfo->fw_version[sizeof(drvinfo->fw_version) - 1] = '\0';
> +
> +       strncpy(drvinfo->bus_info,   pci_name(adapter->pdev),
> +               ETHTOOL_BUSINFO_LEN);

simplify all these to strlcpy

> +       drvinfo->n_stats = vmxnet3_get_stats_count(netdev);
> +       drvinfo->testinfo_len = 0;
> +       drvinfo->eedump_len   = 0;
> +       drvinfo->regdump_len  = vmxnet3_get_regs_len(netdev);
> +}

> +static int
> +vmxnet3_set_ringparam(struct net_device *netdev,
> +               struct ethtool_ringparam *param)
> +{
> +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +       u32 new_tx_ring_size, new_rx_ring_size;
> +       u32 sz;
> +       int err = 0;
> +
> +       if (param->tx_pending == 0 || param->tx_pending >
> +                                               VMXNET3_TX_RING_MAX_SIZE) {
> +               printk(KERN_ERR "%s: invalid tx ring size %u\n", netdev->name,
> +                       param->tx_pending);

Seems noisy

> +               return -EINVAL;
> +       }
> +       if (param->rx_pending == 0 || param->rx_pending >
> +                                       VMXNET3_RX_RING_MAX_SIZE) {
> +               printk(KERN_ERR "%s: invalid rx ring size %u\n", netdev->name,
> +                       param->rx_pending);

Same here

> +               return -EINVAL;
> +       }
> +
> +       /* round it up to a multiple of VMXNET3_RING_SIZE_ALIGN */
> +       new_tx_ring_size = (param->tx_pending + VMXNET3_RING_SIZE_MASK) &
> +                                                       ~VMXNET3_RING_SIZE_MASK;
> +       new_tx_ring_size = min_t(u32, new_tx_ring_size,
> +                                VMXNET3_TX_RING_MAX_SIZE);
> +       BUG_ON(new_tx_ring_size > VMXNET3_TX_RING_MAX_SIZE);
> +       BUG_ON(new_tx_ring_size % VMXNET3_RING_SIZE_ALIGN != 0);

Don't use BUG_ON for validating user input

> +
> +       /* ring0 has to be a multiple of
> +        * rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN
> +        */
> +       sz = adapter->rx_buf_per_pkt * VMXNET3_RING_SIZE_ALIGN;
> +       new_rx_ring_size = (param->rx_pending + sz - 1) / sz * sz;
> +       new_rx_ring_size = min_t(u32, new_rx_ring_size,
> +                                VMXNET3_RX_RING_MAX_SIZE / sz * sz);
> +       BUG_ON(new_rx_ring_size > VMXNET3_RX_RING_MAX_SIZE);
> +       BUG_ON(new_rx_ring_size % sz != 0);
> +
> +       if (new_tx_ring_size == adapter->tx_queue.tx_ring.size &&
> +                       new_rx_ring_size == adapter->rx_queue.rx_ring[0].size) {
> +               return 0;
> +       }
> +
> +       /*
> +        * Reset_work may be in the middle of resetting the device, wait for its
> +        * completion.
> +        */
> +       while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
> +               msleep(1);
> +
> +       if (netif_running(netdev)) {
> +               vmxnet3_quiesce_dev(adapter);
> +               vmxnet3_reset_dev(adapter);
> +
> +               /* recreate the rx queue and the tx queue based on the
> +                * new sizes */
> +               vmxnet3_tq_destroy(&adapter->tx_queue, adapter);
> +               vmxnet3_rq_destroy(&adapter->rx_queue, adapter);
> +
> +               err = vmxnet3_create_queues(adapter, new_tx_ring_size,
> +                       new_rx_ring_size, VMXNET3_DEF_RX_RING_SIZE);
> +               if (err) {
> +                       /* failed, most likely because of OOM, try default
> +                        * size */
> +                       printk(KERN_ERR "%s: failed to apply new sizes, try the"
> +                               " default ones\n", netdev->name);
> +                       err = vmxnet3_create_queues(adapter,
> +                                                   VMXNET3_DEF_TX_RING_SIZE,
> +                                                   VMXNET3_DEF_RX_RING_SIZE,
> +                                                   VMXNET3_DEF_RX_RING_SIZE);
> +                       if (err) {
> +                               printk(KERN_ERR "%s: failed to create queues "
> +                                       "with default sizes. Closing it\n",
> +                                       netdev->name);
> +                               goto out;
> +                       }
> +               }
> +
> +               err = vmxnet3_activate_dev(adapter);
> +               if (err) {
> +                       printk(KERN_ERR "%s: failed to re-activate, error %d."
> +                               " Closing it\n", netdev->name, err);
> +                       goto out;

Going to out: anyway...

> +               }
> +       }
> +
> +out:
> +       clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
> +       if (err)
> +               vmxnet3_force_close(adapter);
> +
> +       return err;
> +}
> +
> +
> +static struct ethtool_ops vmxnet3_ethtool_ops = {
> +       .get_settings      = vmxnet3_get_settings,
> +       .get_drvinfo       = vmxnet3_get_drvinfo,
> +       .get_regs_len      = vmxnet3_get_regs_len,
> +       .get_regs          = vmxnet3_get_regs,
> +       .get_wol           = vmxnet3_get_wol,
> +       .set_wol           = vmxnet3_set_wol,
> +       .get_link          = ethtool_op_get_link,
> +       .get_rx_csum       = vmxnet3_get_rx_csum,
> +       .set_rx_csum       = vmxnet3_set_rx_csum,
> +       .get_tx_csum       = vmxnet3_get_tx_csum,
> +       .set_tx_csum       = vmxnet3_set_tx_csum,
> +       .get_sg            = ethtool_op_get_sg,
> +       .set_sg            = vmxnet3_set_sg,
> +       .get_tso           = ethtool_op_get_tso,
> +       .set_tso           = vmxnet3_set_tso,
> +       .get_strings       = vmxnet3_get_strings,
> +       .get_stats_count   = vmxnet3_get_stats_count,

use get_sset_count instead

> +       .get_ethtool_stats = vmxnet3_get_ethtool_stats,
> +       .get_ringparam     = vmxnet3_get_ringparam,
> +       .set_ringparam     = vmxnet3_set_ringparam,
> +};
> +
> +void vmxnet3_set_ethtool_ops(struct net_device *netdev)
> +{
> +       SET_ETHTOOL_OPS(netdev, &vmxnet3_ethtool_ops);
> +}
<snip>
