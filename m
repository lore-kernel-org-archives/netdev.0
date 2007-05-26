From: divy@chelsio.com
Subject: [PATCH 7/7] cxgb3 - TP SRAM update
Date: Sat, 26 May 2007 16:00:20 -0700
Message-ID: <20070526230020.12210.90635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9433 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946AbXEZXAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 19:00:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The chip executes microcode present in internal RAM, 
whose content is loaded from EEPROM on power cycle. 
This patch allows an update of the microcode through PIO
without forcing a power cycle.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |   28 +++++++++++++
 drivers/net/cxgb3/cxgb3_main.c |   43 ++++++++++++++++++++
 drivers/net/cxgb3/regs.h       |    7 +++
 drivers/net/cxgb3/t3_hw.c      |   85 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 163 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 8d13796..1637800 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -101,6 +101,7 @@ enum {
 	TCB_SIZE = 128,		/* TCB size */
 	NMTUS = 16,		/* size of MTU table */
 	NCCTRL_WIN = 32,	/* # of congestion control windows */
+	PROTO_SRAM_LINES = 128, /* size of TP sram */
 };
 
 #define MAX_RX_COALESCING_LEN 16224U
@@ -124,6 +125,30 @@ enum {				/* adapter interrupt-maintaine
 };
 
 enum {
+	TP_VERSION_MAJOR	= 1,
+	TP_VERSION_MINOR	= 0,
+	TP_VERSION_MICRO	= 44
+};
+
+#define S_TP_VERSION_MAJOR		16
+#define M_TP_VERSION_MAJOR		0xFF
+#define V_TP_VERSION_MAJOR(x)		((x) << S_TP_VERSION_MAJOR)
+#define G_TP_VERSION_MAJOR(x)		\
+	    (((x) >> S_TP_VERSION_MAJOR) & M_TP_VERSION_MAJOR)
+
+#define S_TP_VERSION_MINOR		8
+#define M_TP_VERSION_MINOR		0xFF
+#define V_TP_VERSION_MINOR(x)		((x) << S_TP_VERSION_MINOR)
+#define G_TP_VERSION_MINOR(x)		\
+	    (((x) >> S_TP_VERSION_MINOR) & M_TP_VERSION_MINOR)
+
+#define S_TP_VERSION_MICRO		0
+#define M_TP_VERSION_MICRO		0xFF
+#define V_TP_VERSION_MICRO(x)		((x) << S_TP_VERSION_MICRO)
+#define G_TP_VERSION_MICRO(x)		\
+	    (((x) >> S_TP_VERSION_MICRO) & M_TP_VERSION_MICRO)
+
+enum {
 	SGE_QSETS = 8,		/* # of SGE Tx/Rx/RspQ sets */
 	SGE_RXQ_PER_SET = 2,	/* # of Rx queues per set */
 	SGE_TXQ_PER_SET = 3	/* # of Tx queues per set */
@@ -654,6 +679,9 @@ const struct adapter_info *t3_get_adapte
 int t3_seeprom_read(struct adapter *adapter, u32 addr, u32 *data);
 int t3_seeprom_write(struct adapter *adapter, u32 addr, u32 data);
 int t3_seeprom_wp(struct adapter *adapter, int enable);
+int t3_check_tpsram_version(struct adapter *adapter);
+int t3_check_tpsram(struct adapter *adapter, u8 *tp_ram, unsigned int size);
+int t3_set_proto_sram(struct adapter *adap, u8 *data);
 int t3_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented);
 int t3_load_fw(struct adapter *adapter, const u8 * fw_data, unsigned int size);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index e0ef724..70ba719 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2089,6 +2089,42 @@ static void cxgb_netpoll(struct net_devi
 }
 #endif
 
+#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
+int update_tpsram(struct adapter *adap)
+{
+	const struct firmware *tpsram;
+	char buf[64];
+	struct device *dev = &adap->pdev->dev;
+	int ret;
+	char rev;
+	
+	rev = adap->params.rev == T3_REV_B2 ? 'b' : 'a';
+
+	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
+		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+
+	ret = request_firmware(&tpsram, buf, dev);
+	if (ret < 0) {
+		dev_err(dev, "could not load TP SRAM: unable to load %s\n",
+			buf);
+		return ret;
+	}
+	
+	ret = t3_check_tpsram(adap, tpsram->data, tpsram->size);
+	if (ret)
+		goto release_tpsram;	
+
+	ret = t3_set_proto_sram(adap, tpsram->data);
+	if (ret)
+		dev_err(dev, "loading protocol SRAM failed\n");
+
+release_tpsram:
+	release_firmware(tpsram);
+	
+	return ret;
+}
+
+
 /*
  * Periodic accumulation of MAC statistics.
  */
@@ -2439,6 +2475,13 @@ static int __devinit init_one(struct pci
 		goto out_free_dev;
 	}
 
+	err = t3_check_tpsram_version(adapter);
+	if (err == -EINVAL)
+		err = update_tpsram(adapter);
+
+	if (err)
+		goto out_free_dev;
+		
 	/*
 	 * The card is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole card but rather proceed only
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 02f8731..aa80313 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1218,6 +1218,13 @@
 
 #define A_TP_PROXY_FLOW_CNTL 0x4b0
 
+#define A_TP_EMBED_OP_FIELD0 0x4e8
+#define A_TP_EMBED_OP_FIELD1 0x4ec
+#define A_TP_EMBED_OP_FIELD2 0x4f0
+#define A_TP_EMBED_OP_FIELD3 0x4f4
+#define A_TP_EMBED_OP_FIELD4 0x4f8
+#define A_TP_EMBED_OP_FIELD5 0x4fc
+
 #define A_ULPRX_CTL 0x500
 
 #define S_ROUND_ROBIN    4
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 9e3591d..ec42562 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -847,6 +847,64 @@ static int t3_write_flash(struct adapter
 	return 0;
 }
 
+/**
+ *	t3_check_tpsram_version - read the tp sram version
+ *	@adapter: the adapter
+ *
+ *	Reads the protocol sram version from serial eeprom.
+ */
+int t3_check_tpsram_version(struct adapter *adapter)
+{
+	int ret;
+	u32 vers;
+	unsigned int major, minor;
+
+	/* Get version loaded in SRAM */
+	t3_write_reg(adapter, A_TP_EMBED_OP_FIELD0, 0);
+	ret = t3_wait_op_done(adapter, A_TP_EMBED_OP_FIELD0,
+			      1, 1, 5, 1);
+	if (ret)
+		return ret;
+	
+	vers = t3_read_reg(adapter, A_TP_EMBED_OP_FIELD1);
+
+	major = G_TP_VERSION_MAJOR(vers);
+	minor = G_TP_VERSION_MINOR(vers);
+
+	if (major == TP_VERSION_MAJOR && minor == TP_VERSION_MINOR) 
+		return 0;
+
+	return -EINVAL;
+}
+
+/**
+ *	t3_check_tpsram - check if provided protocol SRAM 
+ *			  is compatible with this driver
+ *	@adapter: the adapter
+ *	@tp_sram: the firmware image to write
+ *	@size: image size
+ *
+ *	Checks if an adapter's tp sram is compatible with the driver.
+ *	Returns 0 if the versions are compatible, a negative error otherwise.
+ */
+int t3_check_tpsram(struct adapter *adapter, u8 *tp_sram, unsigned int size)
+{
+	u32 csum;
+	unsigned int i;
+	const u32 *p = (const u32 *)tp_sram;
+
+	/* Verify checksum */
+	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
+		csum += ntohl(p[i]);
+	if (csum != 0xffffffff) {
+		CH_ERR(adapter, "corrupted protocol SRAM image, checksum %u\n",
+		       csum);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 enum fw_version_type {
 	FW_VERSION_N3,
 	FW_VERSION_T3
@@ -2686,6 +2744,33 @@ static void ulp_config(struct adapter *a
 	t3_write_reg(adap, A_ULPRX_TDDP_TAGMASK, 0xffffffff);
 }
 
+/**
+ *	t3_set_proto_sram - set the contents of the protocol sram
+ *	@adapter: the adapter
+ *	@data: the protocol image
+ *
+ *	Write the contents of the protocol SRAM.
+ */
+int t3_set_proto_sram(struct adapter *adap, u8 *data)
+{
+	int i;
+	u32 *buf = (u32 *)data;
+
+	for (i = 0; i < PROTO_SRAM_LINES; i++) {
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD5, cpu_to_be32(*buf++));
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD4, cpu_to_be32(*buf++));
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD3, cpu_to_be32(*buf++));
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD2, cpu_to_be32(*buf++));
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD1, cpu_to_be32(*buf++));
+		data += sizeof(buf);
+		
+		t3_write_reg(adap, A_TP_EMBED_OP_FIELD0, i << 1 | 1 << 31);
+		if (t3_wait_op_done(adap, A_TP_EMBED_OP_FIELD0, 1, 1, 5, 1))
+			return -EIO;
+	}
+	return 0;
+}
+
 void t3_config_trace_filter(struct adapter *adapter,
 			    const struct trace_params *tp, int filter_index,
 			    int invert, int enable)
