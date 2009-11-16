From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH 2.6.32-rc3] net: Getting rid of the x86 dependency to built
 vmxnet3
Date: Mon, 16 Nov 2009 15:41:33 -0800 (PST)
Message-ID: <alpine.LRH.2.00.0911161053050.23246@sbhatewara-dev1.eng.vmware.com>
References: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754768AbZKPXla@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Getting rid of the x86 dependency to built vmxnet3

From: Shreyas Bhatewara <sbhatewara@vmware.com>

This patch removes config dependency on x86 to build vmxnet3 driver. Thus 
the driver can be built on big endian architectures now. Although vmxnet3 
is not supported on VMs other than x86 architecture, all this code goes in 
to ensure correctness. If the code is not dependent on x86, it should not 
assume little endian architecture in any of its operations.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

Folks,

Device emulation for vmxnet3 expects all the data written in shared space 
to be little endian. Current vmxnet3 driver assumes X86 architecture underneath
and hence writes to the shared space directly. This patch uses cpu_to_le and
le_to_cpu calls to access data shared between device and driver, ensuring that
anything written there is little endian irrespective of CPU byte ordering. The
dependency on X86 or assumption that underlying architecture is X86 is thus 
removed.
        
I have used the conversion macros (cpu_to_le32 etc.) for accessing all multibyte
data fields. Bitfields, have been revesered in order if the code is compiled
under big endian architecture. Further if driver is running in big endian,
cpu_to_le and le_to_cpu are used after writing and before reading bitfields
respectively. Also, temporary descriptors are used while writing into
bitfields so that the shared bits are not touched twice (once while actual
writing and secondly while converting to le format).

Please consider for inclusion in the net-next-2.6 tree.

Thanking you.
->Shreyas

---


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e012c2e..6399abb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3235,7 +3235,7 @@ config VIRTIO_NET
 
 config VMXNET3
        tristate "VMware VMXNET3 ethernet driver"
-       depends on PCI && X86 && INET
+       depends on PCI && INET
        help
          This driver supports VMware's vmxnet3 virtual ethernet NIC.
          To compile this driver as a module, choose M here: the
diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index dc8ee44..b4889e6 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -90,23 +90,60 @@ enum {
 	VMXNET3_CMD_GET_CONF_INTR
 };
 
-struct Vmxnet3_TxDesc {
-	u64		addr;
+/*
+ *	Little Endian layout of bitfields -
+ *	Byte 0 :	7.....len.....0
+ *	Byte 1 :	rsvd gen 13.len.8
+ *	Byte 2 : 	5.msscof.0 ext1  dtype
+ *	Byte 3 : 	13...msscof...6
+ *
+ *	Big Endian layout of bitfields -
+ *	Byte 0:		13...msscof...6
+ *	Byte 1 : 	5.msscof.0 ext1  dtype
+ *	Byte 2 :	rsvd gen 13.len.8
+ *	Byte 3 :	7.....len.....0
+ *
+ *	Thus, le32_to_cpu on the dword will allow the big endian driver to read
+ *	the bit fields correctly. And cpu_to_le32 will convert bitfields
+ *	bit fields written by big endian driver to format required by device.
+ */
 
-	u32		len:14;
-	u32		gen:1;      /* generation bit */
-	u32		rsvd:1;
-	u32		dtype:1;    /* descriptor type */
-	u32		ext1:1;
-	u32		msscof:14;  /* MSS, checksum offset, flags */
-
-	u32		hlen:10;    /* header len */
-	u32		om:2;       /* offload mode */
-	u32		eop:1;      /* End Of Packet */
-	u32		cq:1;       /* completion request */
-	u32		ext2:1;
-	u32		ti:1;       /* VLAN Tag Insertion */
-	u32		tci:16;     /* Tag to Insert */
+struct Vmxnet3_TxDesc {
+	__le64 addr;
+
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32 msscof:14;  /* MSS, checksum offset, flags */
+	u32 ext1:1;
+	u32 dtype:1;    /* descriptor type */
+	u32 rsvd:1;
+	u32 gen:1;      /* generation bit */
+	u32 len:14;
+#else
+	u32 len:14;
+	u32 gen:1;      /* generation bit */
+	u32 rsvd:1;
+	u32 dtype:1;    /* descriptor type */
+	u32 ext1:1;
+	u32 msscof:14;  /* MSS, checksum offset, flags */
+#endif  /* __BIG_ENDIAN_BITFIELD */
+
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32 tci:16;     /* Tag to Insert */
+	u32 ti:1;       /* VLAN Tag Insertion */
+	u32 ext2:1;
+	u32 cq:1;       /* completion request */
+	u32 eop:1;      /* End Of Packet */
+	u32 om:2;       /* offload mode */
+	u32 hlen:10;    /* header len */
+#else
+	u32 hlen:10;    /* header len */
+	u32 om:2;       /* offload mode */
+	u32 eop:1;      /* End Of Packet */
+	u32 cq:1;       /* completion request */
+	u32 ext2:1;
+	u32 ti:1;       /* VLAN Tag Insertion */
+	u32 tci:16;     /* Tag to Insert */
+#endif  /* __BIG_ENDIAN_BITFIELD */
 };
 
 /* TxDesc.OM values */
@@ -118,6 +155,8 @@ struct Vmxnet3_TxDesc {
 #define VMXNET3_TXD_EOP_SHIFT	12
 #define VMXNET3_TXD_CQ_SHIFT	13
 #define VMXNET3_TXD_GEN_SHIFT	14
+#define VMXNET3_TXD_EOP_DWORD_SHIFT 3
+#define VMXNET3_TXD_GEN_DWORD_SHIFT 2
 
 #define VMXNET3_TXD_CQ		(1 << VMXNET3_TXD_CQ_SHIFT)
 #define VMXNET3_TXD_EOP		(1 << VMXNET3_TXD_EOP_SHIFT)
@@ -130,29 +169,40 @@ struct Vmxnet3_TxDataDesc {
 	u8		data[VMXNET3_HDR_COPY_SIZE];
 };
 
+#define VMXNET3_TCD_GEN_SHIFT	31
+#define VMXNET3_TCD_GEN_SIZE	1
+#define VMXNET3_TCD_TXIDX_SHIFT	0
+#define VMXNET3_TCD_TXIDX_SIZE	12
+#define VMXNET3_TCD_GEN_DWORD_SHIFT	3
 
 struct Vmxnet3_TxCompDesc {
 	u32		txdIdx:12;    /* Index of the EOP TxDesc */
 	u32		ext1:20;
 
-	u32		ext2;
-	u32		ext3;
+	__le32		ext2;
+	__le32		ext3;
 
 	u32		rsvd:24;
 	u32		type:7;       /* completion type */
 	u32		gen:1;        /* generation bit */
 };
 
-
 struct Vmxnet3_RxDesc {
-	u64		addr;
+	__le64		addr;
 
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		gen:1;        /* Generation bit */
+	u32		rsvd:15;
+	u32		dtype:1;      /* Descriptor type */
+	u32		btype:1;      /* Buffer Type */
+	u32		len:14;
+#else
 	u32		len:14;
 	u32		btype:1;      /* Buffer Type */
 	u32		dtype:1;      /* Descriptor type */
 	u32		rsvd:15;
 	u32		gen:1;        /* Generation bit */
-
+#endif
 	u32		ext1;
 };
 
@@ -164,8 +214,17 @@ struct Vmxnet3_RxDesc {
 #define VMXNET3_RXD_BTYPE_SHIFT  14
 #define VMXNET3_RXD_GEN_SHIFT    31
 
-
 struct Vmxnet3_RxCompDesc {
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		ext2:1;
+	u32		cnc:1;        /* Checksum Not Calculated */
+	u32		rssType:4;    /* RSS hash type used */
+	u32		rqID:10;      /* rx queue/ring ID */
+	u32		sop:1;        /* Start of Packet */
+	u32		eop:1;        /* End of Packet */
+	u32		ext1:2;
+	u32		rxdIdx:12;    /* Index of the RxDesc */
+#else
 	u32		rxdIdx:12;    /* Index of the RxDesc */
 	u32		ext1:2;
 	u32		eop:1;        /* End of Packet */
@@ -174,14 +233,36 @@ struct Vmxnet3_RxCompDesc {
 	u32		rssType:4;    /* RSS hash type used */
 	u32		cnc:1;        /* Checksum Not Calculated */
 	u32		ext2:1;
+#endif  /* __BIG_ENDIAN_BITFIELD */
 
-	u32		rssHash;      /* RSS hash value */
+	__le32		rssHash;      /* RSS hash value */
 
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		tci:16;       /* Tag stripped */
+	u32		ts:1;         /* Tag is stripped */
+	u32		err:1;        /* Error */
+	u32		len:14;       /* data length */
+#else
 	u32		len:14;       /* data length */
 	u32		err:1;        /* Error */
 	u32		ts:1;         /* Tag is stripped */
 	u32		tci:16;       /* Tag stripped */
+#endif  /* __BIG_ENDIAN_BITFIELD */
+
 
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		gen:1;        /* generation bit */
+	u32		type:7;       /* completion type */
+	u32		fcs:1;        /* Frame CRC correct */
+	u32		frg:1;        /* IP Fragment */
+	u32		v4:1;         /* IPv4 */
+	u32		v6:1;         /* IPv6 */
+	u32		ipc:1;        /* IP Checksum Correct */
+	u32		tcp:1;        /* TCP packet */
+	u32		udp:1;        /* UDP packet */
+	u32		tuc:1;        /* TCP/UDP Checksum Correct */
+	u32		csum:16;
+#else
 	u32		csum:16;
 	u32		tuc:1;        /* TCP/UDP Checksum Correct */
 	u32		udp:1;        /* UDP packet */
@@ -193,6 +274,7 @@ struct Vmxnet3_RxCompDesc {
 	u32		fcs:1;        /* Frame CRC correct */
 	u32		type:7;       /* completion type */
 	u32		gen:1;        /* generation bit */
+#endif  /* __BIG_ENDIAN_BITFIELD */
 };
 
 /* fields in RxCompDesc we access via Vmxnet3_GenericDesc.dword[3] */
@@ -206,6 +288,8 @@ struct Vmxnet3_RxCompDesc {
 /* csum OK for TCP/UDP pkts over IP */
 #define VMXNET3_RCD_CSUM_OK (1 << VMXNET3_RCD_TUC_SHIFT | \
 			     1 << VMXNET3_RCD_IPC_SHIFT)
+#define VMXNET3_TXD_GEN_SIZE 1
+#define VMXNET3_TXD_EOP_SIZE 1
 
 /* value of RxCompDesc.rssType */
 enum {
@@ -219,9 +303,9 @@ enum {
 
 /* a union for accessing all cmd/completion descriptors */
 union Vmxnet3_GenericDesc {
-	u64				qword[2];
-	u32				dword[4];
-	u16				word[8];
+	__le64				qword[2];
+	__le32				dword[4];
+	__le16				word[8];
 	struct Vmxnet3_TxDesc		txd;
 	struct Vmxnet3_RxDesc		rxd;
 	struct Vmxnet3_TxCompDesc	tcd;
@@ -287,18 +371,24 @@ enum {
 
 
 struct Vmxnet3_GOSInfo {
-	u32				gosBits:2;	/* 32-bit or 64-bit? */
-	u32				gosType:4;   /* which guest */
-	u32				gosVer:16;   /* gos version */
-	u32				gosMisc:10;  /* other info about gos */
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		gosMisc:10;    /* other info about gos */
+	u32		gosVer:16;     /* gos version */
+	u32		gosType:4;     /* which guest */
+	u32		gosBits:2;    /* 32-bit or 64-bit? */
+#else
+	u32		gosBits:2;     /* 32-bit or 64-bit? */
+	u32		gosType:4;     /* which guest */
+	u32		gosVer:16;     /* gos version */
+	u32		gosMisc:10;    /* other info about gos */
+#endif  /* __BIG_ENDIAN_BITFIELD */
 };
 
-
 struct Vmxnet3_DriverInfo {
-	u32				version;
+	__le32				version;
 	struct Vmxnet3_GOSInfo		gos;
-	u32				vmxnet3RevSpt;
-	u32				uptVerSpt;
+	__le32				vmxnet3RevSpt;
+	__le32				uptVerSpt;
 };
 
 
@@ -315,42 +405,42 @@ struct Vmxnet3_DriverInfo {
 
 struct Vmxnet3_MiscConf {
 	struct Vmxnet3_DriverInfo driverInfo;
-	u64		uptFeatures;
-	u64		ddPA;         /* driver data PA */
-	u64		queueDescPA;  /* queue descriptor table PA */
-	u32		ddLen;        /* driver data len */
-	u32		queueDescLen; /* queue desc. table len in bytes */
-	u32		mtu;
-	u16		maxNumRxSG;
+	__le64		uptFeatures;
+	__le64		ddPA;         /* driver data PA */
+	__le64		queueDescPA;  /* queue descriptor table PA */
+	__le32		ddLen;        /* driver data len */
+	__le32		queueDescLen; /* queue desc. table len in bytes */
+	__le32		mtu;
+	__le16		maxNumRxSG;
 	u8		numTxQueues;
 	u8		numRxQueues;
-	u32		reserved[4];
+	__le32		reserved[4];
 };
 
 
 struct Vmxnet3_TxQueueConf {
-	u64		txRingBasePA;
-	u64		dataRingBasePA;
-	u64		compRingBasePA;
-	u64		ddPA;         /* driver data */
-	u64		reserved;
-	u32		txRingSize;   /* # of tx desc */
-	u32		dataRingSize; /* # of data desc */
-	u32		compRingSize; /* # of comp desc */
-	u32		ddLen;        /* size of driver data */
+	__le64		txRingBasePA;
+	__le64		dataRingBasePA;
+	__le64		compRingBasePA;
+	__le64		ddPA;         /* driver data */
+	__le64		reserved;
+	__le32		txRingSize;   /* # of tx desc */
+	__le32		dataRingSize; /* # of data desc */
+	__le32		compRingSize; /* # of comp desc */
+	__le32		ddLen;        /* size of driver data */
 	u8		intrIdx;
 	u8		_pad[7];
 };
 
 
 struct Vmxnet3_RxQueueConf {
-	u64		rxRingBasePA[2];
-	u64		compRingBasePA;
-	u64		ddPA;            /* driver data */
-	u64		reserved;
-	u32		rxRingSize[2];   /* # of rx desc */
-	u32		compRingSize;    /* # of rx comp desc */
-	u32		ddLen;           /* size of driver data */
+	__le64		rxRingBasePA[2];
+	__le64		compRingBasePA;
+	__le64		ddPA;            /* driver data */
+	__le64		reserved;
+	__le32		rxRingSize[2];   /* # of rx desc */
+	__le32		compRingSize;    /* # of rx comp desc */
+	__le32		ddLen;           /* size of driver data */
 	u8		intrIdx;
 	u8		_pad[7];
 };
@@ -381,7 +471,7 @@ struct Vmxnet3_IntrConf {
 	u8		eventIntrIdx;
 	u8		modLevels[VMXNET3_MAX_INTRS];	/* moderation level for
 							 * each intr */
-	u32		reserved[3];
+	__le32		reserved[3];
 };
 
 /* one bit per VLAN ID, the size is in the units of u32	*/
@@ -391,21 +481,21 @@ struct Vmxnet3_IntrConf {
 struct Vmxnet3_QueueStatus {
 	bool		stopped;
 	u8		_pad[3];
-	u32		error;
+	__le32		error;
 };
 
 
 struct Vmxnet3_TxQueueCtrl {
-	u32		txNumDeferred;
-	u32		txThreshold;
-	u64		reserved;
+	__le32		txNumDeferred;
+	__le32		txThreshold;
+	__le64		reserved;
 };
 
 
 struct Vmxnet3_RxQueueCtrl {
 	bool		updateRxProd;
 	u8		_pad[7];
-	u64		reserved;
+	__le64		reserved;
 };
 
 enum {
@@ -417,11 +507,11 @@ enum {
 };
 
 struct Vmxnet3_RxFilterConf {
-	u32		rxMode;       /* VMXNET3_RXM_xxx */
-	u16		mfTableLen;   /* size of the multicast filter table */
-	u16		_pad1;
-	u64		mfTablePA;    /* PA of the multicast filters table */
-	u32		vfTable[VMXNET3_VFT_SIZE]; /* vlan filter */
+	__le32		rxMode;       /* VMXNET3_RXM_xxx */
+	__le16		mfTableLen;   /* size of the multicast filter table */
+	__le16		_pad1;
+	__le64		mfTablePA;    /* PA of the multicast filters table */
+	__le32		vfTable[VMXNET3_VFT_SIZE]; /* vlan filter */
 };
 
 
@@ -444,7 +534,7 @@ struct Vmxnet3_PM_PktFilter {
 
 
 struct Vmxnet3_PMConf {
-	u16		wakeUpEvents;  /* VMXNET3_PM_WAKEUP_xxx */
+	__le16		wakeUpEvents;  /* VMXNET3_PM_WAKEUP_xxx */
 	u8		numFilters;
 	u8		pad[5];
 	struct Vmxnet3_PM_PktFilter filters[VMXNET3_PM_MAX_FILTERS];
@@ -452,9 +542,9 @@ struct Vmxnet3_PMConf {
 
 
 struct Vmxnet3_VariableLenConfDesc {
-	u32		confVer;
-	u32		confLen;
-	u64		confPA;
+	__le32		confVer;
+	__le32		confLen;
+	__le64		confPA;
 };
 
 
@@ -491,12 +581,12 @@ struct Vmxnet3_DSDevRead {
 
 /* All structures in DriverShared are padded to multiples of 8 bytes */
 struct Vmxnet3_DriverShared {
-	u32				magic;
+	__le32				magic;
 	/* make devRead start at 64bit boundaries */
-	u32					pad;
-	struct Vmxnet3_DSDevRead		devRead;
-	u32					ecr;
-	u32					reserved[5];
+	__le32				pad;
+	struct Vmxnet3_DSDevRead	devRead;
+	__le32				ecr;
+	__le32				reserved[5];
 };
 
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 004353a..8f24fe5 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -29,7 +29,6 @@
 char vmxnet3_driver_name[] = "vmxnet3";
 #define VMXNET3_DRIVER_DESC "VMware vmxnet3 virtual NIC driver"
 
-
 /*
  * PCI Device ID Table
  * Last entry must be all 0s
@@ -151,11 +150,10 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter)
 	}
 }
 
-
 static void
 vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 {
-	u32 events = adapter->shared->ecr;
+	u32 events = le32_to_cpu(adapter->shared->ecr);
 	if (!events)
 		return;
 
@@ -173,7 +171,7 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 		if (adapter->tqd_start->status.stopped) {
 			printk(KERN_ERR "%s: tq error 0x%x\n",
 			       adapter->netdev->name,
-			       adapter->tqd_start->status.error);
+			       le32_to_cpu(adapter->tqd_start->status.error));
 		}
 		if (adapter->rqd_start->status.stopped) {
 			printk(KERN_ERR "%s: rq error 0x%x\n",
@@ -185,6 +183,106 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 	}
 }
 
+#ifdef __BIG_ENDIAN_BITFIELD
+/*
+ * The device expects the bitfields in shared structures to be written in
+ * little endian. When CPU is big endian, the following routines are used to
+ * correctly read and write into ABI.
+ * The general technique used here is : double word bitfields are defined in
+ * opposite order for big endian architecture. Then before reading them in
+ * driver the complete double word is translated using le32_to_cpu. Similarly
+ * After the driver writes into bitfields, cpu_to_le32 is used to translate the
+ * double words into required format.
+ * In order to avoid touching bits in shared structure more than once, temporary
+ * descriptors are used. These are passed as srcDesc to following functions.
+ */
+static void vmxnet3_RxDescToCPU(const struct Vmxnet3_RxDesc *srcDesc,
+				struct Vmxnet3_RxDesc *dstDesc)
+{
+	u32 *src = (u32 *)srcDesc + 2;
+	u32 *dst = (u32 *)dstDesc + 2;
+	dstDesc->addr = le64_to_cpu(srcDesc->addr);
+	*dst = le32_to_cpu(*src);
+	dstDesc->ext1 = le32_to_cpu(srcDesc->ext1);
+}
+
+static void vmxnet3_TxDescToLe(const struct Vmxnet3_TxDesc *srcDesc,
+			       struct Vmxnet3_TxDesc *dstDesc)
+{
+	int i;
+	u32 *src = (u32 *)(srcDesc + 1);
+	u32 *dst = (u32 *)(dstDesc + 1);
+
+	/* Working backwards so that the gen bit is set at the end. */
+	for (i = 2; i > 0; i--) {
+		src--;
+		dst--;
+		*dst = cpu_to_le32(*src);
+	}
+}
+
+
+static void vmxnet3_RxCompToCPU(const struct Vmxnet3_RxCompDesc *srcDesc,
+				struct Vmxnet3_RxCompDesc *dstDesc)
+{
+	int i = 0;
+	u32 *src = (u32 *)srcDesc;
+	u32 *dst = (u32 *)dstDesc;
+	for (i = 0; i < sizeof(struct Vmxnet3_RxCompDesc) / sizeof(u32); i++) {
+		*dst = le32_to_cpu(*src);
+		src++;
+		dst++;
+	}
+}
+
+
+/* Used to read bitfield values from double words. */
+static u32 get_bitfield32(const __le32 *bitfield, u32 pos, u32 size)
+{
+	u32 temp = le32_to_cpu(*bitfield);
+	u32 mask = ((1 << size) - 1) << pos;
+	temp &= mask;
+	temp >>= pos;
+	return temp;
+}
+
+
+
+#endif  /* __BIG_ENDIAN_BITFIELD */
+
+#ifdef __BIG_ENDIAN_BITFIELD
+
+#   define VMXNET3_TXDESC_GET_GEN(txdesc) get_bitfield32(((const __le32 *) \
+			txdesc) + VMXNET3_TXD_GEN_DWORD_SHIFT, \
+			VMXNET3_TXD_GEN_SHIFT, VMXNET3_TXD_GEN_SIZE)
+#   define VMXNET3_TXDESC_GET_EOP(txdesc) get_bitfield32(((const __le32 *) \
+			txdesc) + VMXNET3_TXD_EOP_DWORD_SHIFT, \
+			VMXNET3_TXD_EOP_SHIFT, VMXNET3_TXD_EOP_SIZE)
+#   define VMXNET3_TCD_GET_GEN(tcd) get_bitfield32(((const __le32 *)tcd) + \
+			VMXNET3_TCD_GEN_DWORD_SHIFT, VMXNET3_TCD_GEN_SHIFT, \
+			VMXNET3_TCD_GEN_SIZE)
+#   define VMXNET3_TCD_GET_TXIDX(tcd) get_bitfield32((const __le32 *)tcd, \
+			VMXNET3_TCD_TXIDX_SHIFT, VMXNET3_TCD_TXIDX_SIZE)
+#   define vmxnet3_getRxComp(dstrcd, rcd, tmp) do { \
+			(dstrcd) = (tmp); \
+			vmxnet3_RxCompToCPU((rcd), (tmp)); \
+		} while (0)
+#   define vmxnet3_getRxDesc(dstrxd, rxd, tmp) do { \
+			(dstrxd) = (tmp); \
+			vmxnet3_RxDescToCPU((rxd), (tmp)); \
+		} while (0)
+
+#else
+
+#   define VMXNET3_TXDESC_GET_GEN(txdesc) ((txdesc)->gen)
+#   define VMXNET3_TXDESC_GET_EOP(txdesc) ((txdesc)->eop)
+#   define VMXNET3_TCD_GET_GEN(tcd) ((tcd)->gen)
+#   define VMXNET3_TCD_GET_TXIDX(tcd) ((tcd)->txdIdx)
+#   define vmxnet3_getRxComp(dstrcd, rcd, tmp) (dstrcd) = (rcd)
+#   define vmxnet3_getRxDesc(dstrxd, rxd, tmp) (dstrxd) = (rxd)
+
+#endif /* __BIG_ENDIAN_BITFIELD  */
+
 
 static void
 vmxnet3_unmap_tx_buf(struct vmxnet3_tx_buf_info *tbi,
@@ -212,7 +310,7 @@ vmxnet3_unmap_pkt(u32 eop_idx, struct vmxnet3_tx_queue *tq,
 
 	/* no out of order completion */
 	BUG_ON(tq->buf_info[eop_idx].sop_idx != tq->tx_ring.next2comp);
-	BUG_ON(tq->tx_ring.base[eop_idx].txd.eop != 1);
+	BUG_ON(VMXNET3_TXDESC_GET_EOP(&(tq->tx_ring.base[eop_idx].txd)) != 1);
 
 	skb = tq->buf_info[eop_idx].skb;
 	BUG_ON(skb == NULL);
@@ -246,9 +344,10 @@ vmxnet3_tq_tx_complete(struct vmxnet3_tx_queue *tq,
 	union Vmxnet3_GenericDesc *gdesc;
 
 	gdesc = tq->comp_ring.base + tq->comp_ring.next2proc;
-	while (gdesc->tcd.gen == tq->comp_ring.gen) {
-		completed += vmxnet3_unmap_pkt(gdesc->tcd.txdIdx, tq,
-					       adapter->pdev, adapter);
+	while (VMXNET3_TCD_GET_GEN(&gdesc->tcd) == tq->comp_ring.gen) {
+		completed += vmxnet3_unmap_pkt(VMXNET3_TCD_GET_TXIDX(
+					       &gdesc->tcd), tq, adapter->pdev,
+					       adapter);
 
 		vmxnet3_comp_ring_adv_next2proc(&tq->comp_ring);
 		gdesc = tq->comp_ring.base + tq->comp_ring.next2proc;
@@ -472,9 +571,9 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 		}
 
 		BUG_ON(rbi->dma_addr == 0);
-		gd->rxd.addr = rbi->dma_addr;
-		gd->dword[2] = (ring->gen << VMXNET3_RXD_GEN_SHIFT) | val |
-				rbi->len;
+		gd->rxd.addr = cpu_to_le64(rbi->dma_addr);
+		gd->dword[2] = cpu_to_le32((ring->gen << VMXNET3_RXD_GEN_SHIFT)
+					   | val | rbi->len);
 
 		num_allocated++;
 		vmxnet3_cmd_ring_adv_next2fill(ring);
@@ -531,10 +630,10 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 
 	/* no need to map the buffer if headers are copied */
 	if (ctx->copy_size) {
-		ctx->sop_txd->txd.addr = tq->data_ring.basePA +
+		ctx->sop_txd->txd.addr = cpu_to_le64(tq->data_ring.basePA +
 					tq->tx_ring.next2fill *
-					sizeof(struct Vmxnet3_TxDataDesc);
-		ctx->sop_txd->dword[2] = dw2 | ctx->copy_size;
+					sizeof(struct Vmxnet3_TxDataDesc));
+		ctx->sop_txd->dword[2] = cpu_to_le32(dw2 | ctx->copy_size);
 		ctx->sop_txd->dword[3] = 0;
 
 		tbi = tq->buf_info + tq->tx_ring.next2fill;
@@ -542,7 +641,8 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 
 		dev_dbg(&adapter->netdev->dev,
 			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
-			tq->tx_ring.next2fill, ctx->sop_txd->txd.addr,
+			tq->tx_ring.next2fill,
+			le64_to_cpu(ctx->sop_txd->txd.addr),
 			ctx->sop_txd->dword[2], ctx->sop_txd->dword[3]);
 		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
 
@@ -570,14 +670,14 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
 		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
 
-		gdesc->txd.addr = tbi->dma_addr;
-		gdesc->dword[2] = dw2 | buf_size;
+		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
+		gdesc->dword[2] = cpu_to_le32(dw2 | buf_size);
 		gdesc->dword[3] = 0;
 
 		dev_dbg(&adapter->netdev->dev,
 			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
-			tq->tx_ring.next2fill, gdesc->txd.addr,
-			gdesc->dword[2], gdesc->dword[3]);
+			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
+			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
 		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
 		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
 
@@ -599,14 +699,14 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
 		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
 
-		gdesc->txd.addr = tbi->dma_addr;
-		gdesc->dword[2] = dw2 | frag->size;
+		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
+		gdesc->dword[2] = cpu_to_le32(dw2 | frag->size);
 		gdesc->dword[3] = 0;
 
 		dev_dbg(&adapter->netdev->dev,
 			"txd[%u]: 0x%llu %u %u\n",
-			tq->tx_ring.next2fill, gdesc->txd.addr,
-			gdesc->dword[2], gdesc->dword[3]);
+			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
+			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
 		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
 		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
 	}
@@ -751,6 +851,10 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	unsigned long flags;
 	struct vmxnet3_tx_ctx ctx;
 	union Vmxnet3_GenericDesc *gdesc;
+#ifdef __BIG_ENDIAN_BITFIELD
+	/* Use temporary descriptor to avoid touching bits multiple times */
+	union Vmxnet3_GenericDesc tempTxDesc;
+#endif
 
 	/* conservatively estimate # of descriptors to use */
 	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
@@ -827,16 +931,22 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	vmxnet3_map_pkt(skb, &ctx, tq, adapter->pdev, adapter);
 
 	/* setup the EOP desc */
-	ctx.eop_txd->dword[3] = VMXNET3_TXD_CQ | VMXNET3_TXD_EOP;
+	ctx.eop_txd->dword[3] = cpu_to_le32(VMXNET3_TXD_CQ | VMXNET3_TXD_EOP);
 
 	/* setup the SOP desc */
+#ifdef __BIG_ENDIAN_BITFIELD
+	gdesc = &tempTxDesc;
+	gdesc->dword[2] = ctx.sop_txd->dword[2];
+	gdesc->dword[3] = ctx.sop_txd->dword[3];
+#else
 	gdesc = ctx.sop_txd;
+#endif
 	if (ctx.mss) {
 		gdesc->txd.hlen = ctx.eth_ip_hdr_size + ctx.l4_hdr_size;
 		gdesc->txd.om = VMXNET3_OM_TSO;
 		gdesc->txd.msscof = ctx.mss;
-		tq->shared->txNumDeferred += (skb->len - gdesc->txd.hlen +
-					     ctx.mss - 1) / ctx.mss;
+		le32_add_cpu(&tq->shared->txNumDeferred, (skb->len -
+			     gdesc->txd.hlen + ctx.mss - 1) / ctx.mss);
 	} else {
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			gdesc->txd.hlen = ctx.eth_ip_hdr_size;
@@ -847,7 +957,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			gdesc->txd.om = 0;
 			gdesc->txd.msscof = 0;
 		}
-		tq->shared->txNumDeferred++;
+		le32_add_cpu(&tq->shared->txNumDeferred, 1);
 	}
 
 	if (vlan_tx_tag_present(skb)) {
@@ -855,19 +965,27 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		gdesc->txd.tci = vlan_tx_tag_get(skb);
 	}
 
-	wmb();
-
-	/* finally flips the GEN bit of the SOP desc */
-	gdesc->dword[2] ^= VMXNET3_TXD_GEN;
+	/* finally flips the GEN bit of the SOP desc. */
+	gdesc->dword[2] = cpu_to_le32(le32_to_cpu(gdesc->dword[2]) ^
+						  VMXNET3_TXD_GEN);
+#ifdef __BIG_ENDIAN_BITFIELD
+	/* Finished updating in bitfields of Tx Desc, so write them in original
+	 * place.
+	 */
+	vmxnet3_TxDescToLe((struct Vmxnet3_TxDesc *)gdesc,
+			   (struct Vmxnet3_TxDesc *)ctx.sop_txd);
+	gdesc = ctx.sop_txd;
+#endif
 	dev_dbg(&adapter->netdev->dev,
 		"txd[%u]: SOP 0x%Lx 0x%x 0x%x\n",
 		(u32)((union Vmxnet3_GenericDesc *)ctx.sop_txd -
-		tq->tx_ring.base), gdesc->txd.addr, gdesc->dword[2],
-		gdesc->dword[3]);
+		tq->tx_ring.base), le64_to_cpu(gdesc->txd.addr),
+		le32_to_cpu(gdesc->dword[2]), le32_to_cpu(gdesc->dword[3]));
 
 	spin_unlock_irqrestore(&tq->tx_lock, flags);
 
-	if (tq->shared->txNumDeferred >= tq->shared->txThreshold) {
+	if (le32_to_cpu(tq->shared->txNumDeferred) >=
+					le32_to_cpu(tq->shared->txThreshold)) {
 		tq->shared->txNumDeferred = 0;
 		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_TXPROD,
 				       tq->tx_ring.next2fill);
@@ -889,9 +1007,8 @@ static netdev_tx_t
 vmxnet3_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	struct vmxnet3_tx_queue *tq = &adapter->tx_queue;
 
-	return vmxnet3_tq_xmit(skb, tq, adapter, netdev);
+	return vmxnet3_tq_xmit(skb, &adapter->tx_queue, adapter, netdev);
 }
 
 
@@ -902,7 +1019,7 @@ vmxnet3_rx_csum(struct vmxnet3_adapter *adapter,
 {
 	if (!gdesc->rcd.cnc && adapter->rxcsum) {
 		/* typical case: TCP/UDP over IP and both csums are correct */
-		if ((gdesc->dword[3] & VMXNET3_RCD_CSUM_OK) ==
+		if ((le32_to_cpu(gdesc->dword[3]) & VMXNET3_RCD_CSUM_OK) ==
 							VMXNET3_RCD_CSUM_OK) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			BUG_ON(!(gdesc->rcd.tcp || gdesc->rcd.udp));
@@ -957,8 +1074,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 	u32 num_rxd = 0;
 	struct Vmxnet3_RxCompDesc *rcd;
 	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
-
-	rcd = &rq->comp_ring.base[rq->comp_ring.next2proc].rcd;
+#ifdef __BIG_ENDIAN_BITFIELD
+	struct Vmxnet3_RxDesc rxCmdDesc;
+	struct Vmxnet3_RxCompDesc rxComp;
+#endif
+	vmxnet3_getRxComp(rcd, &rq->comp_ring.base[rq->comp_ring.next2proc].rcd,
+			  &rxComp);
 	while (rcd->gen == rq->comp_ring.gen) {
 		struct vmxnet3_rx_buf_info *rbi;
 		struct sk_buff *skb;
@@ -976,11 +1097,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 
 		idx = rcd->rxdIdx;
 		ring_idx = rcd->rqID == rq->qid ? 0 : 1;
-
-		rxd = &rq->rx_ring[ring_idx].base[idx].rxd;
+		vmxnet3_getRxDesc(rxd, &rq->rx_ring[ring_idx].base[idx].rxd,
+				  &rxCmdDesc);
 		rbi = rq->buf_info[ring_idx] + idx;
 
-		BUG_ON(rxd->addr != rbi->dma_addr || rxd->len != rbi->len);
+		BUG_ON(rxd->addr != rbi->dma_addr ||
+		       rxd->len != rbi->len);
 
 		if (unlikely(rcd->eop && rcd->err)) {
 			vmxnet3_rx_error(rq, rcd, ctx, adapter);
@@ -1078,7 +1200,8 @@ rcd_done:
 		}
 
 		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
-		rcd = &rq->comp_ring.base[rq->comp_ring.next2proc].rcd;
+		vmxnet3_getRxComp(rcd,
+		     &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
 	}
 
 	return num_rxd;
@@ -1094,7 +1217,11 @@ vmxnet3_rq_cleanup(struct vmxnet3_rx_queue *rq,
 
 	for (ring_idx = 0; ring_idx < 2; ring_idx++) {
 		for (i = 0; i < rq->rx_ring[ring_idx].size; i++) {
-			rxd = &rq->rx_ring[ring_idx].base[i].rxd;
+#ifdef __BIG_ENDIAN_BITFIELD
+			struct Vmxnet3_RxDesc rxDesc;
+#endif
+			vmxnet3_getRxDesc(rxd,
+				&rq->rx_ring[ring_idx].base[i].rxd, &rxDesc);
 
 			if (rxd->btype == VMXNET3_RXD_BTYPE_HEAD &&
 					rq->buf_info[ring_idx][i].skb) {
@@ -1346,12 +1473,12 @@ vmxnet3_request_irqs(struct vmxnet3_adapter *adapter)
 		err = request_irq(adapter->intr.msix_entries[0].vector,
 				  vmxnet3_intr, 0, adapter->netdev->name,
 				  adapter->netdev);
-	} else
-#endif
-	if (adapter->intr.type == VMXNET3_IT_MSI) {
+	} else if (adapter->intr.type == VMXNET3_IT_MSI) {
 		err = request_irq(adapter->pdev->irq, vmxnet3_intr, 0,
 				  adapter->netdev->name, adapter->netdev);
-	} else {
+	} else
+#endif
+	{
 		err = request_irq(adapter->pdev->irq, vmxnet3_intr,
 				  IRQF_SHARED, adapter->netdev->name,
 				  adapter->netdev);
@@ -1412,6 +1539,22 @@ vmxnet3_free_irqs(struct vmxnet3_adapter *adapter)
 }
 
 
+inline void set_flag_le16(__le16 *data, u16 flag)
+{
+	*data = cpu_to_le16(le16_to_cpu(*data) | flag);
+}
+
+inline void set_flag_le64(__le64 *data, u64 flag)
+{
+	*data = cpu_to_le64(le64_to_cpu(*data) | flag);
+}
+
+inline void reset_flag_le64(__le64 *data, u64 flag)
+{
+	*data = cpu_to_le64(le64_to_cpu(*data) & ~flag);
+}
+
+
 static void
 vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
@@ -1427,7 +1570,8 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 			adapter->vlan_grp = grp;
 
 			/* update FEATURES to device */
-			devRead->misc.uptFeatures |= UPT1_F_RXVLAN;
+			set_flag_le64(&devRead->misc.uptFeatures,
+				      UPT1_F_RXVLAN);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
 			/*
@@ -1450,7 +1594,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		struct Vmxnet3_DSDevRead *devRead = &shared->devRead;
 		adapter->vlan_grp = NULL;
 
-		if (devRead->misc.uptFeatures & UPT1_F_RXVLAN) {
+		if (le64_to_cpu(devRead->misc.uptFeatures) & UPT1_F_RXVLAN) {
 			int i;
 
 			for (i = 0; i < VMXNET3_VFT_SIZE; i++) {
@@ -1463,7 +1607,8 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
 
 			/* update FEATURES to device */
-			devRead->misc.uptFeatures &= ~UPT1_F_RXVLAN;
+			reset_flag_le64(&devRead->misc.uptFeatures,
+					UPT1_F_RXVLAN);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
 		}
@@ -1565,9 +1710,10 @@ vmxnet3_set_mc(struct net_device *netdev)
 			new_table = vmxnet3_copy_mc(netdev);
 			if (new_table) {
 				new_mode |= VMXNET3_RXM_MCAST;
-				rxConf->mfTableLen = netdev->mc_count *
-						     ETH_ALEN;
-				rxConf->mfTablePA = virt_to_phys(new_table);
+				rxConf->mfTableLen = cpu_to_le16(
+						netdev->mc_count * ETH_ALEN);
+				rxConf->mfTablePA = cpu_to_le64(virt_to_phys(
+						    new_table));
 			} else {
 				printk(KERN_INFO "%s: failed to copy mcast list"
 				       ", setting ALL_MULTI\n", netdev->name);
@@ -1582,7 +1728,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 	}
 
 	if (new_mode != rxConf->rxMode) {
-		rxConf->rxMode = new_mode;
+		rxConf->rxMode = cpu_to_le32(new_mode);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_UPDATE_RX_MODE);
 	}
@@ -1610,63 +1756,69 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 	memset(shared, 0, sizeof(*shared));
 
 	/* driver settings */
-	shared->magic = VMXNET3_REV1_MAGIC;
-	devRead->misc.driverInfo.version = VMXNET3_DRIVER_VERSION_NUM;
+	shared->magic = cpu_to_le32(VMXNET3_REV1_MAGIC);
+	devRead->misc.driverInfo.version = cpu_to_le32(
+						VMXNET3_DRIVER_VERSION_NUM);
 	devRead->misc.driverInfo.gos.gosBits = (sizeof(void *) == 4 ?
 				VMXNET3_GOS_BITS_32 : VMXNET3_GOS_BITS_64);
 	devRead->misc.driverInfo.gos.gosType = VMXNET3_GOS_TYPE_LINUX;
-	devRead->misc.driverInfo.vmxnet3RevSpt = 1;
-	devRead->misc.driverInfo.uptVerSpt = 1;
+	*((u32 *)&devRead->misc.driverInfo.gos) = cpu_to_le32(
+				*((u32 *)&devRead->misc.driverInfo.gos));
+	devRead->misc.driverInfo.vmxnet3RevSpt = cpu_to_le32(1);
+	devRead->misc.driverInfo.uptVerSpt = cpu_to_le32(1);
 
-	devRead->misc.ddPA = virt_to_phys(adapter);
-	devRead->misc.ddLen = sizeof(struct vmxnet3_adapter);
+	devRead->misc.ddPA = cpu_to_le64(virt_to_phys(adapter));
+	devRead->misc.ddLen = cpu_to_le32(sizeof(struct vmxnet3_adapter));
 
 	/* set up feature flags */
 	if (adapter->rxcsum)
-		devRead->misc.uptFeatures |= UPT1_F_RXCSUM;
+		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXCSUM);
 
 	if (adapter->lro) {
-		devRead->misc.uptFeatures |= UPT1_F_LRO;
-		devRead->misc.maxNumRxSG = 1 + MAX_SKB_FRAGS;
+		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_LRO);
+		devRead->misc.maxNumRxSG = cpu_to_le16(1 + MAX_SKB_FRAGS);
 	}
 	if ((adapter->netdev->features & NETIF_F_HW_VLAN_RX)
 			&& adapter->vlan_grp) {
-		devRead->misc.uptFeatures |= UPT1_F_RXVLAN;
+		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXVLAN);
 	}
 
-	devRead->misc.mtu = adapter->netdev->mtu;
-	devRead->misc.queueDescPA = adapter->queue_desc_pa;
-	devRead->misc.queueDescLen = sizeof(struct Vmxnet3_TxQueueDesc) +
-				     sizeof(struct Vmxnet3_RxQueueDesc);
+	devRead->misc.mtu = cpu_to_le32(adapter->netdev->mtu);
+	devRead->misc.queueDescPA = cpu_to_le64(adapter->queue_desc_pa);
+	devRead->misc.queueDescLen = cpu_to_le32(
+				     sizeof(struct Vmxnet3_TxQueueDesc) +
+				     sizeof(struct Vmxnet3_RxQueueDesc));
 
 	/* tx queue settings */
 	BUG_ON(adapter->tx_queue.tx_ring.base == NULL);
 
 	devRead->misc.numTxQueues = 1;
 	tqc = &adapter->tqd_start->conf;
-	tqc->txRingBasePA   = adapter->tx_queue.tx_ring.basePA;
-	tqc->dataRingBasePA = adapter->tx_queue.data_ring.basePA;
-	tqc->compRingBasePA = adapter->tx_queue.comp_ring.basePA;
-	tqc->ddPA           = virt_to_phys(adapter->tx_queue.buf_info);
-	tqc->txRingSize     = adapter->tx_queue.tx_ring.size;
-	tqc->dataRingSize   = adapter->tx_queue.data_ring.size;
-	tqc->compRingSize   = adapter->tx_queue.comp_ring.size;
-	tqc->ddLen          = sizeof(struct vmxnet3_tx_buf_info) *
-			      tqc->txRingSize;
+	tqc->txRingBasePA   = cpu_to_le64(adapter->tx_queue.tx_ring.basePA);
+	tqc->dataRingBasePA = cpu_to_le64(adapter->tx_queue.data_ring.basePA);
+	tqc->compRingBasePA = cpu_to_le64(adapter->tx_queue.comp_ring.basePA);
+	tqc->ddPA           = cpu_to_le64(virt_to_phys(
+						adapter->tx_queue.buf_info));
+	tqc->txRingSize     = cpu_to_le32(adapter->tx_queue.tx_ring.size);
+	tqc->dataRingSize   = cpu_to_le32(adapter->tx_queue.data_ring.size);
+	tqc->compRingSize   = cpu_to_le32(adapter->tx_queue.comp_ring.size);
+	tqc->ddLen          = cpu_to_le32(sizeof(struct vmxnet3_tx_buf_info) *
+			      tqc->txRingSize);
 	tqc->intrIdx        = adapter->tx_queue.comp_ring.intr_idx;
 
 	/* rx queue settings */
 	devRead->misc.numRxQueues = 1;
 	rqc = &adapter->rqd_start->conf;
-	rqc->rxRingBasePA[0] = adapter->rx_queue.rx_ring[0].basePA;
-	rqc->rxRingBasePA[1] = adapter->rx_queue.rx_ring[1].basePA;
-	rqc->compRingBasePA  = adapter->rx_queue.comp_ring.basePA;
-	rqc->ddPA            = virt_to_phys(adapter->rx_queue.buf_info);
-	rqc->rxRingSize[0]   = adapter->rx_queue.rx_ring[0].size;
-	rqc->rxRingSize[1]   = adapter->rx_queue.rx_ring[1].size;
-	rqc->compRingSize    = adapter->rx_queue.comp_ring.size;
-	rqc->ddLen           = sizeof(struct vmxnet3_rx_buf_info) *
-			       (rqc->rxRingSize[0] + rqc->rxRingSize[1]);
+	rqc->rxRingBasePA[0] = cpu_to_le64(adapter->rx_queue.rx_ring[0].basePA);
+	rqc->rxRingBasePA[1] = cpu_to_le64(adapter->rx_queue.rx_ring[1].basePA);
+	rqc->compRingBasePA  = cpu_to_le64(adapter->rx_queue.comp_ring.basePA);
+	rqc->ddPA            = cpu_to_le64(virt_to_phys(
+						adapter->rx_queue.buf_info));
+	rqc->rxRingSize[0]   = cpu_to_le32(adapter->rx_queue.rx_ring[0].size);
+	rqc->rxRingSize[1]   = cpu_to_le32(adapter->rx_queue.rx_ring[1].size);
+	rqc->compRingSize    = cpu_to_le32(adapter->rx_queue.comp_ring.size);
+	rqc->ddLen           = cpu_to_le32(sizeof(struct vmxnet3_rx_buf_info) *
+			       (rqc->rxRingSize[0] + rqc->rxRingSize[1]));
 	rqc->intrIdx         = adapter->rx_queue.comp_ring.intr_idx;
 
 	/* intr settings */
@@ -1715,11 +1867,10 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 
 	vmxnet3_setup_driver_shared(adapter);
 
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAL,
-			       VMXNET3_GET_ADDR_LO(adapter->shared_pa));
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAH,
-			       VMXNET3_GET_ADDR_HI(adapter->shared_pa));
-
+	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAL, VMXNET3_GET_ADDR_LO(
+			       adapter->shared_pa));
+	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAH, VMXNET3_GET_ADDR_HI(
+			       adapter->shared_pa));
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_ACTIVATE_DEV);
 	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
@@ -2425,7 +2576,7 @@ vmxnet3_suspend(struct device *device)
 		memcpy(pmConf->filters[i].pattern, netdev->dev_addr, ETH_ALEN);
 		pmConf->filters[i].mask[0] = 0x3F; /* LSB ETH_ALEN bits */
 
-		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_FILTER;
+		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
 		i++;
 	}
 
@@ -2467,19 +2618,21 @@ vmxnet3_suspend(struct device *device)
 		pmConf->filters[i].mask[5] = 0x03; /* IPv4 TIP */
 		in_dev_put(in_dev);
 
-		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_FILTER;
+		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
 		i++;
 	}
 
 skip_arp:
 	if (adapter->wol & WAKE_MAGIC)
-		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_MAGIC;
+		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_MAGIC);
 
 	pmConf->numFilters = i;
 
-	adapter->shared->devRead.pmConfDesc.confVer = 1;
-	adapter->shared->devRead.pmConfDesc.confLen = sizeof(*pmConf);
-	adapter->shared->devRead.pmConfDesc.confPA = virt_to_phys(pmConf);
+	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
+	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
+								  *pmConf));
+	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
+								 pmConf));
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_PMCFG);
@@ -2510,9 +2663,11 @@ vmxnet3_resume(struct device *device)
 	pmConf = adapter->pm_conf;
 	memset(pmConf, 0, sizeof(*pmConf));
 
-	adapter->shared->devRead.pmConfDesc.confVer = 1;
-	adapter->shared->devRead.pmConfDesc.confLen = sizeof(*pmConf);
-	adapter->shared->devRead.pmConfDesc.confPA = virt_to_phys(pmConf);
+	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
+	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
+								  *pmConf));
+	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le32(virt_to_phys(
+								 pmConf));
 
 	netif_device_attach(netdev);
 	pci_set_power_state(pdev, PCI_D0);
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index c2c15e4..3935c44 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -50,11 +50,13 @@ vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
 		adapter->rxcsum = val;
 		if (netif_running(netdev)) {
 			if (val)
-				adapter->shared->devRead.misc.uptFeatures |=
-								UPT1_F_RXCSUM;
+				set_flag_le64(
+				&adapter->shared->devRead.misc.uptFeatures,
+				UPT1_F_RXCSUM);
 			else
-				adapter->shared->devRead.misc.uptFeatures &=
-								~UPT1_F_RXCSUM;
+				reset_flag_le64(
+				&adapter->shared->devRead.misc.uptFeatures,
+				UPT1_F_RXCSUM);
 
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 4450816..34f392f 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -330,14 +330,14 @@ struct vmxnet3_adapter {
 };
 
 #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
-	writel((val), (adapter)->hw_addr0 + (reg))
+	writel(cpu_to_le32(val), (adapter)->hw_addr0 + (reg))
 #define VMXNET3_READ_BAR0_REG(adapter, reg)        \
-	readl((adapter)->hw_addr0 + (reg))
+	le32_to_cpu(readl((adapter)->hw_addr0 + (reg)))
 
 #define VMXNET3_WRITE_BAR1_REG(adapter, reg, val)  \
-	writel((val), (adapter)->hw_addr1 + (reg))
+	writel(cpu_to_le32(val), (adapter)->hw_addr1 + (reg))
 #define VMXNET3_READ_BAR1_REG(adapter, reg)        \
-	readl((adapter)->hw_addr1 + (reg))
+	le32_to_cpu(readl((adapter)->hw_addr1 + (reg)))
 
 #define VMXNET3_WAKE_QUEUE_THRESHOLD(tq)  (5)
 #define VMXNET3_RX_ALLOC_THRESHOLD(rq, ring_idx, adapter) \
@@ -353,6 +353,10 @@ struct vmxnet3_adapter {
 #define VMXNET3_MAX_ETH_HDR_SIZE    22
 #define VMXNET3_MAX_SKB_BUF_SIZE    (3*1024)
 
+void set_flag_le16(__le16 *data, u16 flag);
+void set_flag_le64(__le64 *data, u64 flag);
+void reset_flag_le64(__le64 *data, u64 flag);
+
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
 
