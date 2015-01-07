From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: Add support for cim_la entry in debugfs
Date: Wed,  7 Jan 2015 08:48:01 +0530
Message-ID: <1420600683-23289-3-git-send-email-hariprasad@chelsio.com>
References: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	anish@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8414 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754105AbbAGDOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:14:53 -0500
In-Reply-To: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
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
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   34 +++++
 6 files changed, 304 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/e=
thernet/chelsio/cxgb4/cxgb4.h
index 73b1f3a..46cd506 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -304,6 +304,8 @@ struct adapter_params {
 	struct devlog_params devlog;
 	enum pcie_memwin drv_memwin;
=20
+	unsigned int cim_la_size;
+
 	unsigned int sf_size;             /* serial flash size in bytes */
 	unsigned int sf_nsec;             /* # of flash sectors */
 	unsigned int sf_fw_start;         /* start of FW image in flash */
@@ -1034,6 +1036,11 @@ int t4_mc_read(struct adapter *adap, int idx, u3=
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
index 1d3d1c5..0f7b23f 100644
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
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG_A, 1, &cfg);
+	if (ret)
+		return ret;
+
+	p =3D seq_open_tab(file, adap->params.cim_la_size / 8, 8 * sizeof(u32=
), 1,
+			 cfg & UPDBGLACAPTPCONLY_F ?
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
@@ -318,6 +442,7 @@ int t4_setup_debugfs(struct adapter *adap)
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
index 3776279..1e30554 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4031,6 +4031,7 @@ int t4_prep_adapter(struct adapter *adapter)
 		return -EINVAL;
 	}
=20
+	adapter->params.cim_la_size =3D CIMLA_SIZE;
 	init_cong_ctrl(adapter->params.a_wnd, adapter->params.b_wnd);
=20
 	/*
@@ -4323,3 +4324,122 @@ int t4_port_init(struct adapter *adap, int mbox=
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
+	if (t4_read_reg(adap, CIM_HOST_ACC_CTRL_A) & HOSTBUSY_F)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr +=3D 4) {
+		t4_write_reg(adap, CIM_HOST_ACC_CTRL_A, addr);
+		ret =3D t4_wait_op_done(adap, CIM_HOST_ACC_CTRL_A, HOSTBUSY_F,
+				      0, 5, 2);
+		if (!ret)
+			*valp++ =3D t4_read_reg(adap, CIM_HOST_ACC_DATA_A);
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
+	if (t4_read_reg(adap, CIM_HOST_ACC_CTRL_A) & HOSTBUSY_F)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr +=3D 4) {
+		t4_write_reg(adap, CIM_HOST_ACC_DATA_A, *valp++);
+		t4_write_reg(adap, CIM_HOST_ACC_CTRL_A, addr | HOSTWRITE_F);
+		ret =3D t4_wait_op_done(adap, CIM_HOST_ACC_CTRL_A, HOSTBUSY_F,
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
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG_A, 1, &cfg);
+	if (ret)
+		return ret;
+
+	if (cfg & UPDBGLAEN_F) {	/* LA is running, freeze it */
+		ret =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG_A, 0);
+		if (ret)
+			return ret;
+	}
+
+	ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG_A, 1, &val);
+	if (ret)
+		goto restart;
+
+	idx =3D UPDBGLAWRPTR_G(val);
+	if (wrptr)
+		*wrptr =3D idx;
+
+	for (i =3D 0; i < adap->params.cim_la_size; i++) {
+		ret =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG_A,
+				    UPDBGLARDPTR_V(idx) | UPDBGLARDEN_F);
+		if (ret)
+			break;
+		ret =3D t4_cim_read(adap, UP_UP_DBG_LA_CFG_A, 1, &val);
+		if (ret)
+			break;
+		if (val & UPDBGLARDEN_F) {
+			ret =3D -ETIMEDOUT;
+			break;
+		}
+		ret =3D t4_cim_read(adap, UP_UP_DBG_LA_DATA_A, 1, &la_buf[i]);
+		if (ret)
+			break;
+		idx =3D (idx + 1) & UPDBGLARDPTR_M;
+	}
+restart:
+	if (cfg & UPDBGLAEN_F) {
+		int r =3D t4_cim_write1(adap, UP_UP_DBG_LA_CFG_A,
+				      cfg & ~UPDBGLARDEN_F);
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
index 4077227..3fe6eeb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2062,4 +2062,38 @@
 #define PL_VF_WHOAMI_A 0x0
 #define PL_VF_REVISION_A 0x8
=20
+/* registers for module CIM */
+#define CIM_HOST_ACC_CTRL_A	0x7b50
+#define CIM_HOST_ACC_DATA_A	0x7b54
+#define UP_UP_DBG_LA_CFG_A	0x140
+#define UP_UP_DBG_LA_DATA_A	0x144
+
+#define HOSTBUSY_S	17
+#define HOSTBUSY_V(x)	((x) << HOSTBUSY_S)
+#define HOSTBUSY_F	HOSTBUSY_V(1U)
+
+#define HOSTWRITE_S	16
+#define HOSTWRITE_V(x)	((x) << HOSTWRITE_S)
+#define HOSTWRITE_F	HOSTWRITE_V(1U)
+
+#define UPDBGLARDEN_S		1
+#define UPDBGLARDEN_V(x)	((x) << UPDBGLARDEN_S)
+#define UPDBGLARDEN_F		UPDBGLARDEN_V(1U)
+
+#define UPDBGLAEN_S	0
+#define UPDBGLAEN_V(x)	((x) << UPDBGLAEN_S)
+#define UPDBGLAEN_F	UPDBGLAEN_V(1U)
+
+#define UPDBGLARDPTR_S		2
+#define UPDBGLARDPTR_M		0xfffU
+#define UPDBGLARDPTR_V(x)	((x) << UPDBGLARDPTR_S)
+
+#define UPDBGLAWRPTR_S    16
+#define UPDBGLAWRPTR_M    0xfffU
+#define UPDBGLAWRPTR_G(x) (((x) >> UPDBGLAWRPTR_S) & UPDBGLAWRPTR_M)
+
+#define UPDBGLACAPTPCONLY_S	30
+#define UPDBGLACAPTPCONLY_V(x)	((x) << UPDBGLACAPTPCONLY_S)
+#define UPDBGLACAPTPCONLY_F	UPDBGLACAPTPCONLY_V(1U)
+
 #endif /* __T4_REGS_H */
--=20
1.7.1
