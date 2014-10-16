From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: Add support for cim_la entry in debugfs
Date: Thu, 16 Oct 2014 06:52:02 +0530
Message-ID: <1413422524-14054-3-git-send-email-hariprasad@chelsio.com>
References: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46063
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751298AbaJPBQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:16:33 -0400
In-Reply-To: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CIM LA captures the embedded processor=E2=80=99s internal state. Op=
tionally, it can
also trace the flow of data in and out of the embedded processor. There=
fore, the
CIM LA output contains detailed information of what code the embedded p=
rocessor
executed prior to the CIM LA capture.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    7 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  129 ++++++++++++=
+++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   12 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  120 ++++++++++++=
++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    4 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   14 ++
 6 files changed, 284 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/e=
thernet/chelsio/cxgb4/cxgb4.h
index 081b7ef..d8a62cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -297,6 +297,8 @@ struct adapter_params {
 	struct devlog_params devlog;
 	enum pcie_memwin drv_memwin;
=20
+	unsigned int cim_la_size;
+
 	unsigned int sf_size;             /* serial flash size in bytes */
 	unsigned int sf_nsec;             /* # of flash sectors */
 	unsigned int sf_fw_start;         /* start of FW image in flash */
@@ -1013,6 +1015,11 @@ int t4_mc_read(struct adapter *adap, int idx, u3=
2 addr, __be32 *data,
 	       u64 *parity);
 int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 		u64 *parity);
+int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int =
n,
+		unsigned int *valp);
+int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int=
 n,
+		 const unsigned int *valp);
+int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wr=
ptr);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stat=
s *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drive=
rs/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0704af5..04b490e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -43,8 +43,132 @@
 #include "cxgb4_debugfs.h"
 #include "l2t.h"
=20
-/* Firmware Device Log dump.
- */
+/* generic seq_file support for showing a table of size rows x width. =
*/
+static void *seq_tab_get_idx(struct seq_tab *tb, loff_t pos)
+{
+	pos -=3D tb->skip_first;
+	return pos >=3D tb->rows ? NULL : &tb->data[pos * tb->width];
+}
+
+static void *seq_tab_start(struct seq_file *seq, loff_t *pos)
+{
+	struct seq_tab *tb =3D seq->private;
+
+	if (tb->skip_first && *pos =3D=3D 0)
+		return SEQ_START_TOKEN;
+
+	return seq_tab_get_idx(tb, *pos);
+}
+
+static void *seq_tab_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	v =3D seq_tab_get_idx(seq->private, *pos + 1);
+	if (v)
+		++*pos;
+	return v;
+}
+
+static void seq_tab_stop(struct seq_file *seq, void *v)
+{
+}
+
+static int seq_tab_show(struct seq_file *seq, void *v)
+{
+	const struct seq_tab *tb =3D seq->private;
+
+	return tb->show(seq, v, ((char *)v - tb->data) / tb->width);
+}
+
+static const struct seq_operations seq_tab_ops =3D {
+	.start =3D seq_tab_start,
+	.next  =3D seq_tab_next,
+	.stop  =3D seq_tab_stop,
+	.show  =3D seq_tab_show
+};
+
+struct seq_tab *seq_open_tab(struct file *f, unsigned int rows,
+			     unsigned int width, unsigned int have_header,
+			     int (*show)(struct seq_file *seq, void *v, int i))
+{
+	struct seq_tab *p;
+
+	p =3D __seq_open_private(f, &seq_tab_ops, sizeof(*p) + rows * width);
+	if (p) {
+		p->show =3D show;
+		p->rows =3D rows;
+		p->width =3D width;
+		p->skip_first =3D have_header !=3D 0;
+	}
+	return p;
+}
+
+static int cim_la_show(struct seq_file *seq, void *v, int idx)
+{
+	if (v =3D=3D SEQ_START_TOKEN)
+		seq_puts(seq, "Status   Data      PC     LS0Stat  LS0Addr "
+			 "            LS0Data\n");
+	else {
+		const u32 *p =3D v;
+
+		seq_printf(seq,
+			   "  %02x  %x%07x %x%07x %08x %08x %08x%08x%08x%08x\n",
+			   (p[0] >> 4) & 0xff, p[0] & 0xf, p[1] >> 4,
+			   p[1] & 0xf, p[2] >> 4, p[2] & 0xf, p[3], p[4], p[5],
+			   p[6], p[7]);
+	}
+	return 0;
+}
+
+static int cim_la_show_3in1(struct seq_file *seq, void *v, int idx)
+{
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_puts(seq, "Status   Data      PC\n");
+	} else {
+		const u32 *p =3D v;
+
+		seq_printf(seq, "  %02x   %08x %08x\n", p[5] & 0xff, p[6],
+			   p[7]);
+		seq_printf(seq, "  %02x   %02x%06x %02x%06x\n",
+			   (p[3] >> 8) & 0xff, p[3] & 0xff, p[4] >> 8,
+			   p[4] & 0xff, p[5] >> 8);
+		seq_printf(seq, "  %02x   %x%07x %x%07x\n", (p[0] >> 4) & 0xff,
+			   p[0] & 0xf, p[1] >> 4, p[1] & 0xf, p[2] >> 4);
+	}
+	return 0;
+}
+
+static int cim_la_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	unsigned int cfg;
+	struct seq_tab *p;
+	struct adapter *adap =3D inode->i_private;
+
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG, 1, &cfg);
+	if (ret)
+		return ret;
+
+	p =3D seq_open_tab(file, adap->params.cim_la_size / 8, 8 * sizeof(u32=
), 1,
+			 cfg & UPDBGLACAPTPCONLY ?
+			 cim_la_show_3in1 : cim_la_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret =3D t4_cim_read_la(adap, (u32 *)p->data, NULL);
+	if (ret)
+		seq_release_private(inode, file);
+	return ret;
+}
+
+static const struct file_operations cim_la_fops =3D {
+	.owner   =3D THIS_MODULE,
+	.open    =3D cim_la_open,
+	.read    =3D seq_read,
+	.llseek  =3D seq_lseek,
+	.release =3D seq_release_private
+};
+
+/* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] =3D {
 	[FW_DEVLOG_LEVEL_EMERG]		=3D "EMERG",
 	[FW_DEVLOG_LEVEL_CRIT]		=3D "CRIT",
@@ -320,6 +444,7 @@ int t4_setup_debugfs(struct adapter *adap)
 	u32 size;
=20
 	static struct t4_debugfs_entry t4_debugfs_files[] =3D {
+		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 	};
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h b/drive=
rs/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
index a3d8867..70fcbc9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
@@ -44,6 +44,18 @@ struct t4_debugfs_entry {
 	unsigned char data;
 };
=20
+struct seq_tab {
+	int (*show)(struct seq_file *seq, void *v, int idx);
+	unsigned int rows;        /* # of entries */
+	unsigned char width;      /* size in bytes of each entry */
+	unsigned char skip_first; /* whether the first line is a header */
+	char data[0];             /* the table data */
+};
+
+struct seq_tab *seq_open_tab(struct file *f, unsigned int rows,
+			     unsigned int width, unsigned int have_header,
+			     int (*show)(struct seq_file *seq, void *v, int i));
+
 int t4_setup_debugfs(struct adapter *adap);
 void add_debugfs_files(struct adapter *adap,
 		       struct t4_debugfs_entry *files,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/e=
thernet/chelsio/cxgb4/t4_hw.c
index 1fff149..81e1ef2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3953,6 +3953,7 @@ int t4_prep_adapter(struct adapter *adapter)
 		return -EINVAL;
 	}
=20
+	adapter->params.cim_la_size =3D CIMLA_SIZE;
 	init_cong_ctrl(adapter->params.a_wnd, adapter->params.b_wnd);
=20
 	/*
@@ -4125,3 +4126,122 @@ int t4_port_init(struct adapter *adap, int mbox=
, int pf, int vf)
 	}
 	return 0;
 }
+
+/**
+ *	t4_cim_read - read a block from CIM internal address space
+ *	@adap: the adapter
+ *	@addr: the start address within the CIM address space
+ *	@n: number of words to read
+ *	@valp: where to store the result
+ *
+ *	Reads a block of 4-byte words from the CIM intenal address space.
+ */
+int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int =
n,
+		unsigned int *valp)
+{
+	int ret =3D 0;
+
+	if (t4_read_reg(adap, CIM_HOST_ACC_CTRL) & HOSTBUSY)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr +=3D 4) {
+		t4_write_reg(adap, CIM_HOST_ACC_CTRL, addr);
+		ret =3D t4_wait_op_done(adap, CIM_HOST_ACC_CTRL, HOSTBUSY,
+				      0, 5, 2);
+		if (!ret)
+			*valp++ =3D t4_read_reg(adap, CIM_HOST_ACC_DATA);
+	}
+	return ret;
+}
+
+/**
+ *	t4_cim_write - write a block into CIM internal address space
+ *	@adap: the adapter
+ *	@addr: the start address within the CIM address space
+ *	@n: number of words to write
+ *	@valp: set of values to write
+ *
+ *	Writes a block of 4-byte words into the CIM intenal address space.
+ */
+int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int=
 n,
+		 const unsigned int *valp)
+{
+	int ret =3D 0;
+
+	if (t4_read_reg(adap, CIM_HOST_ACC_CTRL) & HOSTBUSY)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr +=3D 4) {
+		t4_write_reg(adap, CIM_HOST_ACC_DATA, *valp++);
+		t4_write_reg(adap, CIM_HOST_ACC_CTRL, addr | HOSTWRITE);
+		ret =3D t4_wait_op_done(adap, CIM_HOST_ACC_CTRL, HOSTBUSY,
+				      0, 5, 2);
+	}
+	return ret;
+}
+
+static int t4_cim_write1(struct adapter *adap, unsigned int addr,
+			 unsigned int val)
+{
+	return t4_cim_write(adap, addr, 1, &val);
+}
+
+/**
+ *	t4_cim_read_la - read CIM LA capture buffer
+ *	@adap: the adapter
+ *	@la_buf: where to store the LA data
+ *	@wrptr: the HW write pointer within the capture buffer
+ *
+ *	Reads the contents of the CIM LA buffer with the most recent entry =
at
+ *	the end	of the returned data and with the entry at @wrptr first.
+ *	We try to leave the LA in the running state we find it in.
+ */
+int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wr=
ptr)
+{
+	int i, ret;
+	unsigned int cfg, val, idx;
+
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG, 1, &cfg);
+	if (ret)
+		return ret;
+
+	if (cfg & UPDBGLAEN) {                /* LA is running, freeze it */
+		ret =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG, 0);
+		if (ret)
+			return ret;
+	}
+
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG, 1, &val);
+	if (ret)
+		goto restart;
+
+	idx =3D UPDBGLAWRPTR_GET(val);
+	if (wrptr)
+		*wrptr =3D idx;
+
+	for (i =3D 0; i < adap->params.cim_la_size; i++) {
+		ret =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG,
+				    UPDBGLARDPTR(idx) | UPDBGLARDEN);
+		if (ret)
+			break;
+		ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG, 1, &val);
+		if (ret)
+			break;
+		if (val & UPDBGLARDEN) {
+			ret =3D -ETIMEDOUT;
+			break;
+		}
+		ret =3D t4_cim_read(adap, UP_UP_DBG_LA_DATA, 1, &la_buf[i]);
+		if (ret)
+			break;
+		idx =3D (idx + 1) & UPDBGLARDPTR_MASK;
+	}
+restart:
+	if (cfg & UPDBGLAEN) {
+		int r =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG,
+				      cfg & ~UPDBGLARDEN);
+		if (!ret)
+			ret =3D r;
+	}
+	return ret;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/e=
thernet/chelsio/cxgb4/t4_hw.h
index 5e5eee6..bcc925b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -56,6 +56,10 @@ enum {
 };
=20
 enum {
+	CIMLA_SIZE     =3D 2048,  /* # of 32-bit words in CIM LA */
+};
+
+enum {
 	SF_PAGE_SIZE =3D 256,           /* serial flash page size */
 	SF_SEC_SIZE =3D 64 * 1024,      /* serial flash sector size */
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net=
/ethernet/chelsio/cxgb4/t4_regs.h
index a1024db..4f6d6fa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1331,4 +1331,18 @@
 #define S_FT_VNID_ID_VLD                16
 #define V_FT_VNID_ID_VLD(x)             ((x) << S_FT_VNID_ID_VLD)
=20
+/* registers for module CIM */
+#define CIM_HOST_ACC_CTRL	0x7b50
+#define CIM_HOST_ACC_DATA	0x7b54
+#define UP_UP_DBG_LA_CFG	0x140
+#define HOSTBUSY	(1U << 17)
+#define HOSTWRITE	(1U << 16)
+#define UPDBGLAEN	(1U << 0)
+#define UPDBGLARDEN	(1U << 1)
+#define UP_UP_DBG_LA_DATA	0x144
+#define UPDBGLARDPTR_MASK	0xfffU
+#define UPDBGLARDPTR(x)	((x) << 2)
+#define UPDBGLAWRPTR_GET(x)	(((x) >> 16) & 0xfffU)
+#define UPDBGLACAPTPCONLY	(1U << 30)
+
 #endif /* __T4_REGS_H */
--=20
1.7.1
