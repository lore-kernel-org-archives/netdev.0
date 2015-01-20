From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4: Add debugfs options to dump the rss key, config for PF, VF, etc
Date: Tue, 20 Jan 2015 12:02:21 +0530
Message-ID: <1421735541-32400-3-git-send-email-hariprasad@chelsio.com>
References: <1421735541-32400-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22708 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752787AbbATG0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 01:26:53 -0500
In-Reply-To: <1421735541-32400-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support to dump the rss table, rss_config, rss_key, rss_pf_config and
rss_vf_config

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   10 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  407 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   18 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  141 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  402 +++++++++++++++++++
 5 files changed, 978 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 29c5232..24fc162 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1038,6 +1038,16 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 			int start, int n, const u16 *rspq, unsigned int nrspq);
 int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 		       unsigned int flags);
+int t4_read_rss(struct adapter *adapter, u16 *entries);
+void t4_read_rss_key(struct adapter *adapter, u32 *key);
+void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx);
+void t4_read_rss_pf_config(struct adapter *adapter, unsigned int index,
+			   u32 *valp);
+void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
+			   u32 *vfl, u32 *vfh);
+u32 t4_read_rss_pf_map(struct adapter *adapter);
+u32 t4_read_rss_pf_mask(struct adapter *adapter);
+
 int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 	       u64 *parity);
 int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 8b2e230..714cc70 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -36,6 +36,7 @@
 #include <linux/debugfs.h>
 #include <linux/string_helpers.h>
 #include <linux/sort.h>
+#include <linux/ctype.h>
 
 #include "cxgb4.h"
 #include "t4_regs.h"
@@ -624,6 +625,407 @@ static const struct file_operations clip_tbl_debugfs_fops = {
 };
 #endif
 
+/*RSS Table.
+ */
+
+static int rss_show(struct seq_file *seq, void *v, int idx)
+{
+	u16 *entry = v;
+
+	seq_printf(seq, "%4d:  %4u  %4u  %4u  %4u  %4u  %4u  %4u  %4u\n",
+		   idx * 8, entry[0], entry[1], entry[2], entry[3], entry[4],
+		   entry[5], entry[6], entry[7]);
+	return 0;
+}
+
+static int rss_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	struct seq_tab *p;
+	struct adapter *adap = inode->i_private;
+
+	p = seq_open_tab(file, RSS_NENTRIES / 8, 8 * sizeof(u16), 0, rss_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = t4_read_rss(adap, (u16 *)p->data);
+	if (ret)
+		seq_release_private(inode, file);
+
+	return ret;
+}
+
+static const struct file_operations rss_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = rss_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+/* RSS Configuration.
+ */
+
+/* Small utility function to return the strings "yes" or "no" if the supplied
+ * argument is non-zero.
+ */
+static const char *yesno(int x)
+{
+	static const char *yes = "yes";
+	static const char *no = "no";
+
+	return x ? yes : no;
+}
+
+static int rss_config_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adapter = seq->private;
+	static const char * const keymode[] = {
+		"global",
+		"global and per-VF scramble",
+		"per-PF and per-VF scramble",
+		"per-VF and per-VF scramble",
+	};
+	u32 rssconf;
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_A);
+	seq_printf(seq, "TP_RSS_CONFIG: %#x\n", rssconf);
+	seq_printf(seq, "  Tnl4TupEnIpv6: %3s\n", yesno(rssconf &
+							TNL4TUPENIPV6_F));
+	seq_printf(seq, "  Tnl2TupEnIpv6: %3s\n", yesno(rssconf &
+							TNL2TUPENIPV6_F));
+	seq_printf(seq, "  Tnl4TupEnIpv4: %3s\n", yesno(rssconf &
+							TNL4TUPENIPV4_F));
+	seq_printf(seq, "  Tnl2TupEnIpv4: %3s\n", yesno(rssconf &
+							TNL2TUPENIPV4_F));
+	seq_printf(seq, "  TnlTcpSel:     %3s\n", yesno(rssconf & TNLTCPSEL_F));
+	seq_printf(seq, "  TnlIp6Sel:     %3s\n", yesno(rssconf & TNLIP6SEL_F));
+	seq_printf(seq, "  TnlVrtSel:     %3s\n", yesno(rssconf & TNLVRTSEL_F));
+	seq_printf(seq, "  TnlMapEn:      %3s\n", yesno(rssconf & TNLMAPEN_F));
+	seq_printf(seq, "  OfdHashSave:   %3s\n", yesno(rssconf &
+							OFDHASHSAVE_F));
+	seq_printf(seq, "  OfdVrtSel:     %3s\n", yesno(rssconf & OFDVRTSEL_F));
+	seq_printf(seq, "  OfdMapEn:      %3s\n", yesno(rssconf & OFDMAPEN_F));
+	seq_printf(seq, "  OfdLkpEn:      %3s\n", yesno(rssconf & OFDLKPEN_F));
+	seq_printf(seq, "  Syn4TupEnIpv6: %3s\n", yesno(rssconf &
+							SYN4TUPENIPV6_F));
+	seq_printf(seq, "  Syn2TupEnIpv6: %3s\n", yesno(rssconf &
+							SYN2TUPENIPV6_F));
+	seq_printf(seq, "  Syn4TupEnIpv4: %3s\n", yesno(rssconf &
+							SYN4TUPENIPV4_F));
+	seq_printf(seq, "  Syn2TupEnIpv4: %3s\n", yesno(rssconf &
+							SYN2TUPENIPV4_F));
+	seq_printf(seq, "  Syn4TupEnIpv6: %3s\n", yesno(rssconf &
+							SYN4TUPENIPV6_F));
+	seq_printf(seq, "  SynIp6Sel:     %3s\n", yesno(rssconf & SYNIP6SEL_F));
+	seq_printf(seq, "  SynVrt6Sel:    %3s\n", yesno(rssconf & SYNVRTSEL_F));
+	seq_printf(seq, "  SynMapEn:      %3s\n", yesno(rssconf & SYNMAPEN_F));
+	seq_printf(seq, "  SynLkpEn:      %3s\n", yesno(rssconf & SYNLKPEN_F));
+	seq_printf(seq, "  ChnEn:         %3s\n", yesno(rssconf &
+							CHANNELENABLE_F));
+	seq_printf(seq, "  PrtEn:         %3s\n", yesno(rssconf &
+							PORTENABLE_F));
+	seq_printf(seq, "  TnlAllLkp:     %3s\n", yesno(rssconf &
+							TNLALLLOOKUP_F));
+	seq_printf(seq, "  VrtEn:         %3s\n", yesno(rssconf &
+							VIRTENABLE_F));
+	seq_printf(seq, "  CngEn:         %3s\n", yesno(rssconf &
+							CONGESTIONENABLE_F));
+	seq_printf(seq, "  HashToeplitz:  %3s\n", yesno(rssconf &
+							HASHTOEPLITZ_F));
+	seq_printf(seq, "  Udp4En:        %3s\n", yesno(rssconf & UDPENABLE_F));
+	seq_printf(seq, "  Disable:       %3s\n", yesno(rssconf & DISABLE_F));
+
+	seq_puts(seq, "\n");
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_TNL_A);
+	seq_printf(seq, "TP_RSS_CONFIG_TNL: %#x\n", rssconf);
+	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
+	seq_printf(seq, "  MaskFilter:    %3d\n", MASKFILTER_G(rssconf));
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) > CHELSIO_T5) {
+		seq_printf(seq, "  HashAll:     %3s\n",
+			   yesno(rssconf & HASHALL_F));
+		seq_printf(seq, "  HashEth:     %3s\n",
+			   yesno(rssconf & HASHETH_F));
+	}
+	seq_printf(seq, "  UseWireCh:     %3s\n", yesno(rssconf & USEWIRECH_F));
+
+	seq_puts(seq, "\n");
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_OFD_A);
+	seq_printf(seq, "TP_RSS_CONFIG_OFD: %#x\n", rssconf);
+	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
+	seq_printf(seq, "  RRCplMapEn:    %3s\n", yesno(rssconf &
+							RRCPLMAPEN_F));
+	seq_printf(seq, "  RRCplQueWidth: %3d\n", RRCPLQUEWIDTH_G(rssconf));
+
+	seq_puts(seq, "\n");
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_SYN_A);
+	seq_printf(seq, "TP_RSS_CONFIG_SYN: %#x\n", rssconf);
+	seq_printf(seq, "  MaskSize:      %3d\n", MASKSIZE_G(rssconf));
+	seq_printf(seq, "  UseWireCh:     %3s\n", yesno(rssconf & USEWIRECH_F));
+
+	seq_puts(seq, "\n");
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_VRT_A);
+	seq_printf(seq, "TP_RSS_CONFIG_VRT: %#x\n", rssconf);
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) > CHELSIO_T5) {
+		seq_printf(seq, "  KeyWrAddrX:     %3d\n",
+			   KEYWRADDRX_G(rssconf));
+		seq_printf(seq, "  KeyExtend:      %3s\n",
+			   yesno(rssconf & KEYEXTEND_F));
+	}
+	seq_printf(seq, "  VfRdRg:        %3s\n", yesno(rssconf & VFRDRG_F));
+	seq_printf(seq, "  VfRdEn:        %3s\n", yesno(rssconf & VFRDEN_F));
+	seq_printf(seq, "  VfPerrEn:      %3s\n", yesno(rssconf & VFPERREN_F));
+	seq_printf(seq, "  KeyPerrEn:     %3s\n", yesno(rssconf & KEYPERREN_F));
+	seq_printf(seq, "  DisVfVlan:     %3s\n", yesno(rssconf &
+							DISABLEVLAN_F));
+	seq_printf(seq, "  EnUpSwt:       %3s\n", yesno(rssconf & ENABLEUP0_F));
+	seq_printf(seq, "  HashDelay:     %3d\n", HASHDELAY_G(rssconf));
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		seq_printf(seq, "  VfWrAddr:      %3d\n", VFWRADDR_G(rssconf));
+	seq_printf(seq, "  KeyMode:       %s\n", keymode[KEYMODE_G(rssconf)]);
+	seq_printf(seq, "  VfWrEn:        %3s\n", yesno(rssconf & VFWREN_F));
+	seq_printf(seq, "  KeyWrEn:       %3s\n", yesno(rssconf & KEYWREN_F));
+	seq_printf(seq, "  KeyWrAddr:     %3d\n", KEYWRADDR_G(rssconf));
+
+	seq_puts(seq, "\n");
+
+	rssconf = t4_read_reg(adapter, TP_RSS_CONFIG_CNG_A);
+	seq_printf(seq, "TP_RSS_CONFIG_CNG: %#x\n", rssconf);
+	seq_printf(seq, "  ChnCount3:     %3s\n", yesno(rssconf & CHNCOUNT3_F));
+	seq_printf(seq, "  ChnCount2:     %3s\n", yesno(rssconf & CHNCOUNT2_F));
+	seq_printf(seq, "  ChnCount1:     %3s\n", yesno(rssconf & CHNCOUNT1_F));
+	seq_printf(seq, "  ChnCount0:     %3s\n", yesno(rssconf & CHNCOUNT0_F));
+	seq_printf(seq, "  ChnUndFlow3:   %3s\n", yesno(rssconf &
+							CHNUNDFLOW3_F));
+	seq_printf(seq, "  ChnUndFlow2:   %3s\n", yesno(rssconf &
+							CHNUNDFLOW2_F));
+	seq_printf(seq, "  ChnUndFlow1:   %3s\n", yesno(rssconf &
+							CHNUNDFLOW1_F));
+	seq_printf(seq, "  ChnUndFlow0:   %3s\n", yesno(rssconf &
+							CHNUNDFLOW0_F));
+	seq_printf(seq, "  RstChn3:       %3s\n", yesno(rssconf & RSTCHN3_F));
+	seq_printf(seq, "  RstChn2:       %3s\n", yesno(rssconf & RSTCHN2_F));
+	seq_printf(seq, "  RstChn1:       %3s\n", yesno(rssconf & RSTCHN1_F));
+	seq_printf(seq, "  RstChn0:       %3s\n", yesno(rssconf & RSTCHN0_F));
+	seq_printf(seq, "  UpdVld:        %3s\n", yesno(rssconf & UPDVLD_F));
+	seq_printf(seq, "  Xoff:          %3s\n", yesno(rssconf & XOFF_F));
+	seq_printf(seq, "  UpdChn3:       %3s\n", yesno(rssconf & UPDCHN3_F));
+	seq_printf(seq, "  UpdChn2:       %3s\n", yesno(rssconf & UPDCHN2_F));
+	seq_printf(seq, "  UpdChn1:       %3s\n", yesno(rssconf & UPDCHN1_F));
+	seq_printf(seq, "  UpdChn0:       %3s\n", yesno(rssconf & UPDCHN0_F));
+	seq_printf(seq, "  Queue:         %3d\n", QUEUE_G(rssconf));
+
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(rss_config);
+
+/* RSS Secret Key.
+ */
+
+static int rss_key_show(struct seq_file *seq, void *v)
+{
+	u32 key[10];
+
+	t4_read_rss_key(seq->private, key);
+	seq_printf(seq, "%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x\n",
+		   key[9], key[8], key[7], key[6], key[5], key[4], key[3],
+		   key[2], key[1], key[0]);
+	return 0;
+}
+
+static int rss_key_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rss_key_show, inode->i_private);
+}
+
+static ssize_t rss_key_write(struct file *file, const char __user *buf,
+			     size_t count, loff_t *pos)
+{
+	int i, j;
+	u32 key[10];
+	char s[100], *p;
+	struct adapter *adap = FILE_DATA(file)->i_private;
+
+	if (count > sizeof(s) - 1)
+		return -EINVAL;
+	if (copy_from_user(s, buf, count))
+		return -EFAULT;
+	for (i = count; i > 0 && isspace(s[i - 1]); i--)
+		;
+	s[i] = '\0';
+
+	for (p = s, i = 9; i >= 0; i--) {
+		key[i] = 0;
+		for (j = 0; j < 8; j++, p++) {
+			if (!isxdigit(*p))
+				return -EINVAL;
+			key[i] = (key[i] << 4) | hex2val(*p);
+		}
+	}
+
+	t4_write_rss_key(adap, key, -1);
+	return count;
+}
+
+static const struct file_operations rss_key_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = rss_key_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+	.write   = rss_key_write
+};
+
+/* PF RSS Configuration.
+ */
+
+struct rss_pf_conf {
+	u32 rss_pf_map;
+	u32 rss_pf_mask;
+	u32 rss_pf_config;
+};
+
+static int rss_pf_config_show(struct seq_file *seq, void *v, int idx)
+{
+	struct rss_pf_conf *pfconf;
+
+	if (v == SEQ_START_TOKEN) {
+		/* use the 0th entry to dump the PF Map Index Size */
+		pfconf = seq->private + offsetof(struct seq_tab, data);
+		seq_printf(seq, "PF Map Index Size = %d\n\n",
+			   LKPIDXSIZE_G(pfconf->rss_pf_map));
+
+		seq_puts(seq, "     RSS              PF   VF    Hash Tuple Enable         Default\n");
+		seq_puts(seq, "     Enable       IPF Mask Mask  IPv6      IPv4      UDP   Queue\n");
+		seq_puts(seq, " PF  Map Chn Prt  Map Size Size  Four Two  Four Two  Four  Ch1  Ch0\n");
+	} else {
+		#define G_PFnLKPIDX(map, n) \
+			(((map) >> PF1LKPIDX_S*(n)) & PF0LKPIDX_M)
+		#define G_PFnMSKSIZE(mask, n) \
+			(((mask) >> PF1MSKSIZE_S*(n)) & PF1MSKSIZE_M)
+
+		pfconf = v;
+		seq_printf(seq, "%3d  %3s %3s %3s  %3d  %3d  %3d   %3s %3s   %3s %3s   %3s  %3d  %3d\n",
+			   idx,
+			   yesno(pfconf->rss_pf_config & MAPENABLE_F),
+			   yesno(pfconf->rss_pf_config & CHNENABLE_F),
+			   yesno(pfconf->rss_pf_config & PRTENABLE_F),
+			   G_PFnLKPIDX(pfconf->rss_pf_map, idx),
+			   G_PFnMSKSIZE(pfconf->rss_pf_mask, idx),
+			   IVFWIDTH_G(pfconf->rss_pf_config),
+			   yesno(pfconf->rss_pf_config & IP6FOURTUPEN_F),
+			   yesno(pfconf->rss_pf_config & IP6TWOTUPEN_F),
+			   yesno(pfconf->rss_pf_config & IP4FOURTUPEN_F),
+			   yesno(pfconf->rss_pf_config & IP4TWOTUPEN_F),
+			   yesno(pfconf->rss_pf_config & UDPFOURTUPEN_F),
+			   CH1DEFAULTQUEUE_G(pfconf->rss_pf_config),
+			   CH0DEFAULTQUEUE_G(pfconf->rss_pf_config));
+
+		#undef G_PFnLKPIDX
+		#undef G_PFnMSKSIZE
+	}
+	return 0;
+}
+
+static int rss_pf_config_open(struct inode *inode, struct file *file)
+{
+	struct adapter *adapter = inode->i_private;
+	struct seq_tab *p;
+	u32 rss_pf_map, rss_pf_mask;
+	struct rss_pf_conf *pfconf;
+	int pf;
+
+	p = seq_open_tab(file, 8, sizeof(*pfconf), 1, rss_pf_config_show);
+	if (!p)
+		return -ENOMEM;
+
+	pfconf = (struct rss_pf_conf *)p->data;
+	rss_pf_map = t4_read_rss_pf_map(adapter);
+	rss_pf_mask = t4_read_rss_pf_mask(adapter);
+	for (pf = 0; pf < 8; pf++) {
+		pfconf[pf].rss_pf_map = rss_pf_map;
+		pfconf[pf].rss_pf_mask = rss_pf_mask;
+		t4_read_rss_pf_config(adapter, pf, &pfconf[pf].rss_pf_config);
+	}
+	return 0;
+}
+
+static const struct file_operations rss_pf_config_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = rss_pf_config_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+/* VF RSS Configuration.
+ */
+
+struct rss_vf_conf {
+	u32 rss_vf_vfl;
+	u32 rss_vf_vfh;
+};
+
+static int rss_vf_config_show(struct seq_file *seq, void *v, int idx)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "     RSS                     Hash Tuple Enable\n");
+		seq_puts(seq, "     Enable   IVF  Dis  Enb  IPv6      IPv4      UDP    Def  Secret Key\n");
+		seq_puts(seq, " VF  Chn Prt  Map  VLAN  uP  Four Two  Four Two  Four   Que  Idx       Hash\n");
+	} else {
+		struct rss_vf_conf *vfconf = v;
+
+		seq_printf(seq, "%3d  %3s %3s  %3d   %3s %3s   %3s %3s   %3s  %3s   %3s  %4d  %3d %#10x\n",
+			   idx,
+			   yesno(vfconf->rss_vf_vfh & VFCHNEN_F),
+			   yesno(vfconf->rss_vf_vfh & VFPRTEN_F),
+			   VFLKPIDX_G(vfconf->rss_vf_vfh),
+			   yesno(vfconf->rss_vf_vfh & VFVLNEX_F),
+			   yesno(vfconf->rss_vf_vfh & VFUPEN_F),
+			   yesno(vfconf->rss_vf_vfh & VFIP4FOURTUPEN_F),
+			   yesno(vfconf->rss_vf_vfh & VFIP6TWOTUPEN_F),
+			   yesno(vfconf->rss_vf_vfh & VFIP4FOURTUPEN_F),
+			   yesno(vfconf->rss_vf_vfh & VFIP4TWOTUPEN_F),
+			   yesno(vfconf->rss_vf_vfh & ENABLEUDPHASH_F),
+			   DEFAULTQUEUE_G(vfconf->rss_vf_vfh),
+			   KEYINDEX_G(vfconf->rss_vf_vfh),
+			   vfconf->rss_vf_vfl);
+	}
+	return 0;
+}
+
+static int rss_vf_config_open(struct inode *inode, struct file *file)
+{
+	struct adapter *adapter = inode->i_private;
+	struct seq_tab *p;
+	struct rss_vf_conf *vfconf;
+	int vf;
+
+	p = seq_open_tab(file, 128, sizeof(*vfconf), 1, rss_vf_config_show);
+	if (!p)
+		return -ENOMEM;
+
+	vfconf = (struct rss_vf_conf *)p->data;
+	for (vf = 0; vf < 128; vf++) {
+		t4_read_rss_vf_config(adapter, vf, &vfconf[vf].rss_vf_vfl,
+				      &vfconf[vf].rss_vf_vfh);
+	}
+	return 0;
+}
+
+static const struct file_operations rss_vf_config_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = rss_vf_config_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 int mem_open(struct inode *inode, struct file *file)
 {
 	unsigned int mem;
@@ -728,6 +1130,11 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
+		{ "rss", &rss_debugfs_fops, S_IRUSR, 0 },
+		{ "rss_config", &rss_config_debugfs_fops, S_IRUSR, 0 },
+		{ "rss_key", &rss_key_debugfs_fops, S_IRUSR, 0 },
+		{ "rss_pf_config", &rss_pf_config_debugfs_fops, S_IRUSR, 0 },
+		{ "rss_vf_config", &rss_vf_config_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
index e162c61..b63cfee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
@@ -39,6 +39,19 @@
 
 #define FILE_DATA(_file) ((_file)->f_path.dentry->d_inode)
 
+#define DEFINE_SIMPLE_DEBUGFS_FILE(name) \
+static int name##_open(struct inode *inode, struct file *file) \
+{ \
+	return single_open(file, name##_show, inode->i_private); \
+} \
+static const struct file_operations name##_debugfs_fops = { \
+	.owner   = THIS_MODULE, \
+	.open    = name##_open, \
+	.read    = seq_read, \
+	.llseek  = seq_lseek, \
+	.release = single_release \
+}
+
 struct t4_debugfs_entry {
 	const char *name;
 	const struct file_operations *ops;
@@ -54,6 +67,11 @@ struct seq_tab {
 	char data[0];             /* the table data */
 };
 
+static inline unsigned int hex2val(char c)
+{
+	return isdigit(c) ? c - '0' : tolower(c) - 'a' + 10;
+}
+
 struct seq_tab *seq_open_tab(struct file *f, unsigned int rows,
 			     unsigned int width, unsigned int have_header,
 			     int (*show)(struct seq_file *seq, void *v, int i));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 73da6f5..8f99878 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2200,6 +2200,147 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
 }
 
+/* Read an RSS table row */
+static int rd_rss_row(struct adapter *adap, int row, u32 *val)
+{
+	t4_write_reg(adap, TP_RSS_LKP_TABLE_A, 0xfff00000 | row);
+	return t4_wait_op_done_val(adap, TP_RSS_LKP_TABLE_A, LKPTBLROWVLD_F, 1,
+				   5, 0, val);
+}
+
+/**
+ *	t4_read_rss - read the contents of the RSS mapping table
+ *	@adapter: the adapter
+ *	@map: holds the contents of the RSS mapping table
+ *
+ *	Reads the contents of the RSS hash->queue mapping table.
+ */
+int t4_read_rss(struct adapter *adapter, u16 *map)
+{
+	u32 val;
+	int i, ret;
+
+	for (i = 0; i < RSS_NENTRIES / 2; ++i) {
+		ret = rd_rss_row(adapter, i, &val);
+		if (ret)
+			return ret;
+		*map++ = LKPTBLQUEUE0_G(val);
+		*map++ = LKPTBLQUEUE1_G(val);
+	}
+	return 0;
+}
+
+/**
+ *	t4_read_rss_key - read the global RSS key
+ *	@adap: the adapter
+ *	@key: 10-entry array holding the 320-bit RSS key
+ *
+ *	Reads the global 320-bit RSS key.
+ */
+void t4_read_rss_key(struct adapter *adap, u32 *key)
+{
+	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
+			 TP_RSS_SECRET_KEY0_A);
+}
+
+/**
+ *	t4_write_rss_key - program one of the RSS keys
+ *	@adap: the adapter
+ *	@key: 10-entry array holding the 320-bit RSS key
+ *	@idx: which RSS key to write
+ *
+ *	Writes one of the RSS keys with the given 320-bit value.  If @idx is
+ *	0..15 the corresponding entry in the RSS key table is written,
+ *	otherwise the global RSS key is written.
+ */
+void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
+{
+	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
+			  TP_RSS_SECRET_KEY0_A);
+	if (idx >= 0 && idx < 16)
+		t4_write_reg(adap, TP_RSS_CONFIG_VRT_A,
+			     KEYWRADDR_V(idx) | KEYWREN_F);
+}
+
+/**
+ *	t4_read_rss_pf_config - read PF RSS Configuration Table
+ *	@adapter: the adapter
+ *	@index: the entry in the PF RSS table to read
+ *	@valp: where to store the returned value
+ *
+ *	Reads the PF RSS Configuration Table at the specified index and returns
+ *	the value found there.
+ */
+void t4_read_rss_pf_config(struct adapter *adapter, unsigned int index,
+			   u32 *valp)
+{
+	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			 valp, 1, TP_RSS_PF0_CONFIG_A + index);
+}
+
+/**
+ *	t4_read_rss_vf_config - read VF RSS Configuration Table
+ *	@adapter: the adapter
+ *	@index: the entry in the VF RSS table to read
+ *	@vfl: where to store the returned VFL
+ *	@vfh: where to store the returned VFH
+ *
+ *	Reads the VF RSS Configuration Table at the specified index and returns
+ *	the (VFL, VFH) values found there.
+ */
+void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
+			   u32 *vfl, u32 *vfh)
+{
+	u32 vrt, mask, data;
+
+	mask = VFWRADDR_V(VFWRADDR_M);
+	data = VFWRADDR_V(index);
+
+	/* Request that the index'th VF Table values be read into VFL/VFH.
+	 */
+	vrt = t4_read_reg(adapter, TP_RSS_CONFIG_VRT_A);
+	vrt &= ~(VFRDRG_F | VFWREN_F | KEYWREN_F | mask);
+	vrt |= data | VFRDEN_F;
+	t4_write_reg(adapter, TP_RSS_CONFIG_VRT_A, vrt);
+
+	/* Grab the VFL/VFH values ...
+	 */
+	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			 vfl, 1, TP_RSS_VFL_CONFIG_A);
+	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			 vfh, 1, TP_RSS_VFH_CONFIG_A);
+}
+
+/**
+ *	t4_read_rss_pf_map - read PF RSS Map
+ *	@adapter: the adapter
+ *
+ *	Reads the PF RSS Map register and returns its value.
+ */
+u32 t4_read_rss_pf_map(struct adapter *adapter)
+{
+	u32 pfmap;
+
+	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			 &pfmap, 1, TP_RSS_PF_MAP_A);
+	return pfmap;
+}
+
+/**
+ *	t4_read_rss_pf_mask - read PF RSS Mask
+ *	@adapter: the adapter
+ *
+ *	Reads the PF RSS Mask register and returns its value.
+ */
+u32 t4_read_rss_pf_mask(struct adapter *adapter)
+{
+	u32 pfmask;
+
+	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			 &pfmask, 1, TP_RSS_PF_MSK_A);
+	return pfmask;
+}
+
 /**
  *	t4_tp_get_tcp_stats - read TP's TCP MIB counters
  *	@adap: the adapter
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 7ce55f9..e036b56 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1678,6 +1678,408 @@
 #define QUEUENUMBER_S    0
 #define QUEUENUMBER_V(x) ((x) << QUEUENUMBER_S)
 
+#define TP_RSS_CONFIG_A 0x7df0
+
+#define TNL4TUPENIPV6_S    31
+#define TNL4TUPENIPV6_V(x) ((x) << TNL4TUPENIPV6_S)
+#define TNL4TUPENIPV6_F    TNL4TUPENIPV6_V(1U)
+
+#define TNL2TUPENIPV6_S    30
+#define TNL2TUPENIPV6_V(x) ((x) << TNL2TUPENIPV6_S)
+#define TNL2TUPENIPV6_F    TNL2TUPENIPV6_V(1U)
+
+#define TNL4TUPENIPV4_S    29
+#define TNL4TUPENIPV4_V(x) ((x) << TNL4TUPENIPV4_S)
+#define TNL4TUPENIPV4_F    TNL4TUPENIPV4_V(1U)
+
+#define TNL2TUPENIPV4_S    28
+#define TNL2TUPENIPV4_V(x) ((x) << TNL2TUPENIPV4_S)
+#define TNL2TUPENIPV4_F    TNL2TUPENIPV4_V(1U)
+
+#define TNLTCPSEL_S    27
+#define TNLTCPSEL_V(x) ((x) << TNLTCPSEL_S)
+#define TNLTCPSEL_F    TNLTCPSEL_V(1U)
+
+#define TNLIP6SEL_S    26
+#define TNLIP6SEL_V(x) ((x) << TNLIP6SEL_S)
+#define TNLIP6SEL_F    TNLIP6SEL_V(1U)
+
+#define TNLVRTSEL_S    25
+#define TNLVRTSEL_V(x) ((x) << TNLVRTSEL_S)
+#define TNLVRTSEL_F    TNLVRTSEL_V(1U)
+
+#define TNLMAPEN_S    24
+#define TNLMAPEN_V(x) ((x) << TNLMAPEN_S)
+#define TNLMAPEN_F    TNLMAPEN_V(1U)
+
+#define OFDHASHSAVE_S    19
+#define OFDHASHSAVE_V(x) ((x) << OFDHASHSAVE_S)
+#define OFDHASHSAVE_F    OFDHASHSAVE_V(1U)
+
+#define OFDVRTSEL_S    18
+#define OFDVRTSEL_V(x) ((x) << OFDVRTSEL_S)
+#define OFDVRTSEL_F    OFDVRTSEL_V(1U)
+
+#define OFDMAPEN_S    17
+#define OFDMAPEN_V(x) ((x) << OFDMAPEN_S)
+#define OFDMAPEN_F    OFDMAPEN_V(1U)
+
+#define OFDLKPEN_S    16
+#define OFDLKPEN_V(x) ((x) << OFDLKPEN_S)
+#define OFDLKPEN_F    OFDLKPEN_V(1U)
+
+#define SYN4TUPENIPV6_S    15
+#define SYN4TUPENIPV6_V(x) ((x) << SYN4TUPENIPV6_S)
+#define SYN4TUPENIPV6_F    SYN4TUPENIPV6_V(1U)
+
+#define SYN2TUPENIPV6_S    14
+#define SYN2TUPENIPV6_V(x) ((x) << SYN2TUPENIPV6_S)
+#define SYN2TUPENIPV6_F    SYN2TUPENIPV6_V(1U)
+
+#define SYN4TUPENIPV4_S    13
+#define SYN4TUPENIPV4_V(x) ((x) << SYN4TUPENIPV4_S)
+#define SYN4TUPENIPV4_F    SYN4TUPENIPV4_V(1U)
+
+#define SYN2TUPENIPV4_S    12
+#define SYN2TUPENIPV4_V(x) ((x) << SYN2TUPENIPV4_S)
+#define SYN2TUPENIPV4_F    SYN2TUPENIPV4_V(1U)
+
+#define SYNIP6SEL_S    11
+#define SYNIP6SEL_V(x) ((x) << SYNIP6SEL_S)
+#define SYNIP6SEL_F    SYNIP6SEL_V(1U)
+
+#define SYNVRTSEL_S    10
+#define SYNVRTSEL_V(x) ((x) << SYNVRTSEL_S)
+#define SYNVRTSEL_F    SYNVRTSEL_V(1U)
+
+#define SYNMAPEN_S    9
+#define SYNMAPEN_V(x) ((x) << SYNMAPEN_S)
+#define SYNMAPEN_F    SYNMAPEN_V(1U)
+
+#define SYNLKPEN_S    8
+#define SYNLKPEN_V(x) ((x) << SYNLKPEN_S)
+#define SYNLKPEN_F    SYNLKPEN_V(1U)
+
+#define CHANNELENABLE_S    7
+#define CHANNELENABLE_V(x) ((x) << CHANNELENABLE_S)
+#define CHANNELENABLE_F    CHANNELENABLE_V(1U)
+
+#define PORTENABLE_S    6
+#define PORTENABLE_V(x) ((x) << PORTENABLE_S)
+#define PORTENABLE_F    PORTENABLE_V(1U)
+
+#define TNLALLLOOKUP_S    5
+#define TNLALLLOOKUP_V(x) ((x) << TNLALLLOOKUP_S)
+#define TNLALLLOOKUP_F    TNLALLLOOKUP_V(1U)
+
+#define VIRTENABLE_S    4
+#define VIRTENABLE_V(x) ((x) << VIRTENABLE_S)
+#define VIRTENABLE_F    VIRTENABLE_V(1U)
+
+#define CONGESTIONENABLE_S    3
+#define CONGESTIONENABLE_V(x) ((x) << CONGESTIONENABLE_S)
+#define CONGESTIONENABLE_F    CONGESTIONENABLE_V(1U)
+
+#define HASHTOEPLITZ_S    2
+#define HASHTOEPLITZ_V(x) ((x) << HASHTOEPLITZ_S)
+#define HASHTOEPLITZ_F    HASHTOEPLITZ_V(1U)
+
+#define UDPENABLE_S    1
+#define UDPENABLE_V(x) ((x) << UDPENABLE_S)
+#define UDPENABLE_F    UDPENABLE_V(1U)
+
+#define DISABLE_S    0
+#define DISABLE_V(x) ((x) << DISABLE_S)
+#define DISABLE_F    DISABLE_V(1U)
+
+#define TP_RSS_CONFIG_TNL_A 0x7df4
+
+#define MASKSIZE_S    28
+#define MASKSIZE_M    0xfU
+#define MASKSIZE_V(x) ((x) << MASKSIZE_S)
+#define MASKSIZE_G(x) (((x) >> MASKSIZE_S) & MASKSIZE_M)
+
+#define MASKFILTER_S    16
+#define MASKFILTER_M    0x7ffU
+#define MASKFILTER_V(x) ((x) << MASKFILTER_S)
+#define MASKFILTER_G(x) (((x) >> MASKFILTER_S) & MASKFILTER_M)
+
+#define USEWIRECH_S    0
+#define USEWIRECH_V(x) ((x) << USEWIRECH_S)
+#define USEWIRECH_F    USEWIRECH_V(1U)
+
+#define HASHALL_S    2
+#define HASHALL_V(x) ((x) << HASHALL_S)
+#define HASHALL_F    HASHALL_V(1U)
+
+#define HASHETH_S    1
+#define HASHETH_V(x) ((x) << HASHETH_S)
+#define HASHETH_F    HASHETH_V(1U)
+
+#define TP_RSS_CONFIG_OFD_A 0x7df8
+
+#define RRCPLMAPEN_S    20
+#define RRCPLMAPEN_V(x) ((x) << RRCPLMAPEN_S)
+#define RRCPLMAPEN_F    RRCPLMAPEN_V(1U)
+
+#define RRCPLQUEWIDTH_S    16
+#define RRCPLQUEWIDTH_M    0xfU
+#define RRCPLQUEWIDTH_V(x) ((x) << RRCPLQUEWIDTH_S)
+#define RRCPLQUEWIDTH_G(x) (((x) >> RRCPLQUEWIDTH_S) & RRCPLQUEWIDTH_M)
+
+#define TP_RSS_CONFIG_SYN_A 0x7dfc
+#define TP_RSS_CONFIG_VRT_A 0x7e00
+
+#define VFRDRG_S    25
+#define VFRDRG_V(x) ((x) << VFRDRG_S)
+#define VFRDRG_F    VFRDRG_V(1U)
+
+#define VFRDEN_S    24
+#define VFRDEN_V(x) ((x) << VFRDEN_S)
+#define VFRDEN_F    VFRDEN_V(1U)
+
+#define VFPERREN_S    23
+#define VFPERREN_V(x) ((x) << VFPERREN_S)
+#define VFPERREN_F    VFPERREN_V(1U)
+
+#define KEYPERREN_S    22
+#define KEYPERREN_V(x) ((x) << KEYPERREN_S)
+#define KEYPERREN_F    KEYPERREN_V(1U)
+
+#define DISABLEVLAN_S    21
+#define DISABLEVLAN_V(x) ((x) << DISABLEVLAN_S)
+#define DISABLEVLAN_F    DISABLEVLAN_V(1U)
+
+#define ENABLEUP0_S    20
+#define ENABLEUP0_V(x) ((x) << ENABLEUP0_S)
+#define ENABLEUP0_F    ENABLEUP0_V(1U)
+
+#define HASHDELAY_S    16
+#define HASHDELAY_M    0xfU
+#define HASHDELAY_V(x) ((x) << HASHDELAY_S)
+#define HASHDELAY_G(x) (((x) >> HASHDELAY_S) & HASHDELAY_M)
+
+#define VFWRADDR_S    8
+#define VFWRADDR_M    0x7fU
+#define VFWRADDR_V(x) ((x) << VFWRADDR_S)
+#define VFWRADDR_G(x) (((x) >> VFWRADDR_S) & VFWRADDR_M)
+
+#define KEYMODE_S    6
+#define KEYMODE_M    0x3U
+#define KEYMODE_V(x) ((x) << KEYMODE_S)
+#define KEYMODE_G(x) (((x) >> KEYMODE_S) & KEYMODE_M)
+
+#define VFWREN_S    5
+#define VFWREN_V(x) ((x) << VFWREN_S)
+#define VFWREN_F    VFWREN_V(1U)
+
+#define KEYWREN_S    4
+#define KEYWREN_V(x) ((x) << KEYWREN_S)
+#define KEYWREN_F    KEYWREN_V(1U)
+
+#define KEYWRADDR_S    0
+#define KEYWRADDR_M    0xfU
+#define KEYWRADDR_V(x) ((x) << KEYWRADDR_S)
+#define KEYWRADDR_G(x) (((x) >> KEYWRADDR_S) & KEYWRADDR_M)
+
+#define KEYWRADDRX_S    30
+#define KEYWRADDRX_M    0x3U
+#define KEYWRADDRX_V(x) ((x) << KEYWRADDRX_S)
+#define KEYWRADDRX_G(x) (((x) >> KEYWRADDRX_S) & KEYWRADDRX_M)
+
+#define KEYEXTEND_S    26
+#define KEYEXTEND_V(x) ((x) << KEYEXTEND_S)
+#define KEYEXTEND_F    KEYEXTEND_V(1U)
+
+#define LKPIDXSIZE_S    24
+#define LKPIDXSIZE_M    0x3U
+#define LKPIDXSIZE_V(x) ((x) << LKPIDXSIZE_S)
+#define LKPIDXSIZE_G(x) (((x) >> LKPIDXSIZE_S) & LKPIDXSIZE_M)
+
+#define TP_RSS_VFL_CONFIG_A 0x3a
+#define TP_RSS_VFH_CONFIG_A 0x3b
+
+#define ENABLEUDPHASH_S    31
+#define ENABLEUDPHASH_V(x) ((x) << ENABLEUDPHASH_S)
+#define ENABLEUDPHASH_F    ENABLEUDPHASH_V(1U)
+
+#define VFUPEN_S    30
+#define VFUPEN_V(x) ((x) << VFUPEN_S)
+#define VFUPEN_F    VFUPEN_V(1U)
+
+#define VFVLNEX_S    28
+#define VFVLNEX_V(x) ((x) << VFVLNEX_S)
+#define VFVLNEX_F    VFVLNEX_V(1U)
+
+#define VFPRTEN_S    27
+#define VFPRTEN_V(x) ((x) << VFPRTEN_S)
+#define VFPRTEN_F    VFPRTEN_V(1U)
+
+#define VFCHNEN_S    26
+#define VFCHNEN_V(x) ((x) << VFCHNEN_S)
+#define VFCHNEN_F    VFCHNEN_V(1U)
+
+#define DEFAULTQUEUE_S    16
+#define DEFAULTQUEUE_M    0x3ffU
+#define DEFAULTQUEUE_G(x) (((x) >> DEFAULTQUEUE_S) & DEFAULTQUEUE_M)
+
+#define VFIP6TWOTUPEN_S    6
+#define VFIP6TWOTUPEN_V(x) ((x) << VFIP6TWOTUPEN_S)
+#define VFIP6TWOTUPEN_F    VFIP6TWOTUPEN_V(1U)
+
+#define VFIP4FOURTUPEN_S    5
+#define VFIP4FOURTUPEN_V(x) ((x) << VFIP4FOURTUPEN_S)
+#define VFIP4FOURTUPEN_F    VFIP4FOURTUPEN_V(1U)
+
+#define VFIP4TWOTUPEN_S    4
+#define VFIP4TWOTUPEN_V(x) ((x) << VFIP4TWOTUPEN_S)
+#define VFIP4TWOTUPEN_F    VFIP4TWOTUPEN_V(1U)
+
+#define KEYINDEX_S    0
+#define KEYINDEX_M    0xfU
+#define KEYINDEX_G(x) (((x) >> KEYINDEX_S) & KEYINDEX_M)
+
+#define MAPENABLE_S    31
+#define MAPENABLE_V(x) ((x) << MAPENABLE_S)
+#define MAPENABLE_F    MAPENABLE_V(1U)
+
+#define CHNENABLE_S    30
+#define CHNENABLE_V(x) ((x) << CHNENABLE_S)
+#define CHNENABLE_F    CHNENABLE_V(1U)
+
+#define PRTENABLE_S    29
+#define PRTENABLE_V(x) ((x) << PRTENABLE_S)
+#define PRTENABLE_F    PRTENABLE_V(1U)
+
+#define UDPFOURTUPEN_S    28
+#define UDPFOURTUPEN_V(x) ((x) << UDPFOURTUPEN_S)
+#define UDPFOURTUPEN_F    UDPFOURTUPEN_V(1U)
+
+#define IP6FOURTUPEN_S    27
+#define IP6FOURTUPEN_V(x) ((x) << IP6FOURTUPEN_S)
+#define IP6FOURTUPEN_F    IP6FOURTUPEN_V(1U)
+
+#define IP6TWOTUPEN_S    26
+#define IP6TWOTUPEN_V(x) ((x) << IP6TWOTUPEN_S)
+#define IP6TWOTUPEN_F    IP6TWOTUPEN_V(1U)
+
+#define IP4FOURTUPEN_S    25
+#define IP4FOURTUPEN_V(x) ((x) << IP4FOURTUPEN_S)
+#define IP4FOURTUPEN_F    IP4FOURTUPEN_V(1U)
+
+#define IP4TWOTUPEN_S    24
+#define IP4TWOTUPEN_V(x) ((x) << IP4TWOTUPEN_S)
+#define IP4TWOTUPEN_F    IP4TWOTUPEN_V(1U)
+
+#define IVFWIDTH_S    20
+#define IVFWIDTH_M    0xfU
+#define IVFWIDTH_V(x) ((x) << IVFWIDTH_S)
+#define IVFWIDTH_G(x) (((x) >> IVFWIDTH_S) & IVFWIDTH_M)
+
+#define CH1DEFAULTQUEUE_S    10
+#define CH1DEFAULTQUEUE_M    0x3ffU
+#define CH1DEFAULTQUEUE_V(x) ((x) << CH1DEFAULTQUEUE_S)
+#define CH1DEFAULTQUEUE_G(x) (((x) >> CH1DEFAULTQUEUE_S) & CH1DEFAULTQUEUE_M)
+
+#define CH0DEFAULTQUEUE_S    0
+#define CH0DEFAULTQUEUE_M    0x3ffU
+#define CH0DEFAULTQUEUE_V(x) ((x) << CH0DEFAULTQUEUE_S)
+#define CH0DEFAULTQUEUE_G(x) (((x) >> CH0DEFAULTQUEUE_S) & CH0DEFAULTQUEUE_M)
+
+#define VFLKPIDX_S    8
+#define VFLKPIDX_M    0xffU
+#define VFLKPIDX_G(x) (((x) >> VFLKPIDX_S) & VFLKPIDX_M)
+
+#define TP_RSS_CONFIG_CNG_A 0x7e04
+#define TP_RSS_SECRET_KEY0_A 0x40
+#define TP_RSS_PF0_CONFIG_A 0x30
+#define TP_RSS_PF_MAP_A 0x38
+#define TP_RSS_PF_MSK_A 0x39
+
+#define PF1LKPIDX_S    3
+
+#define PF0LKPIDX_M    0x7U
+
+#define PF1MSKSIZE_S    4
+#define PF1MSKSIZE_M    0xfU
+
+#define CHNCOUNT3_S    31
+#define CHNCOUNT3_V(x) ((x) << CHNCOUNT3_S)
+#define CHNCOUNT3_F    CHNCOUNT3_V(1U)
+
+#define CHNCOUNT2_S    30
+#define CHNCOUNT2_V(x) ((x) << CHNCOUNT2_S)
+#define CHNCOUNT2_F    CHNCOUNT2_V(1U)
+
+#define CHNCOUNT1_S    29
+#define CHNCOUNT1_V(x) ((x) << CHNCOUNT1_S)
+#define CHNCOUNT1_F    CHNCOUNT1_V(1U)
+
+#define CHNCOUNT0_S    28
+#define CHNCOUNT0_V(x) ((x) << CHNCOUNT0_S)
+#define CHNCOUNT0_F    CHNCOUNT0_V(1U)
+
+#define CHNUNDFLOW3_S    27
+#define CHNUNDFLOW3_V(x) ((x) << CHNUNDFLOW3_S)
+#define CHNUNDFLOW3_F    CHNUNDFLOW3_V(1U)
+
+#define CHNUNDFLOW2_S    26
+#define CHNUNDFLOW2_V(x) ((x) << CHNUNDFLOW2_S)
+#define CHNUNDFLOW2_F    CHNUNDFLOW2_V(1U)
+
+#define CHNUNDFLOW1_S    25
+#define CHNUNDFLOW1_V(x) ((x) << CHNUNDFLOW1_S)
+#define CHNUNDFLOW1_F    CHNUNDFLOW1_V(1U)
+
+#define CHNUNDFLOW0_S    24
+#define CHNUNDFLOW0_V(x) ((x) << CHNUNDFLOW0_S)
+#define CHNUNDFLOW0_F    CHNUNDFLOW0_V(1U)
+
+#define RSTCHN3_S    19
+#define RSTCHN3_V(x) ((x) << RSTCHN3_S)
+#define RSTCHN3_F    RSTCHN3_V(1U)
+
+#define RSTCHN2_S    18
+#define RSTCHN2_V(x) ((x) << RSTCHN2_S)
+#define RSTCHN2_F    RSTCHN2_V(1U)
+
+#define RSTCHN1_S    17
+#define RSTCHN1_V(x) ((x) << RSTCHN1_S)
+#define RSTCHN1_F    RSTCHN1_V(1U)
+
+#define RSTCHN0_S    16
+#define RSTCHN0_V(x) ((x) << RSTCHN0_S)
+#define RSTCHN0_F    RSTCHN0_V(1U)
+
+#define UPDVLD_S    15
+#define UPDVLD_V(x) ((x) << UPDVLD_S)
+#define UPDVLD_F    UPDVLD_V(1U)
+
+#define XOFF_S    14
+#define XOFF_V(x) ((x) << XOFF_S)
+#define XOFF_F    XOFF_V(1U)
+
+#define UPDCHN3_S    13
+#define UPDCHN3_V(x) ((x) << UPDCHN3_S)
+#define UPDCHN3_F    UPDCHN3_V(1U)
+
+#define UPDCHN2_S    12
+#define UPDCHN2_V(x) ((x) << UPDCHN2_S)
+#define UPDCHN2_F    UPDCHN2_V(1U)
+
+#define UPDCHN1_S    11
+#define UPDCHN1_V(x) ((x) << UPDCHN1_S)
+#define UPDCHN1_F    UPDCHN1_V(1U)
+
+#define UPDCHN0_S    10
+#define UPDCHN0_V(x) ((x) << UPDCHN0_S)
+#define UPDCHN0_F    UPDCHN0_V(1U)
+
+#define QUEUE_S    0
+#define QUEUE_M    0x3ffU
+#define QUEUE_V(x) ((x) << QUEUE_S)
+#define QUEUE_G(x) (((x) >> QUEUE_S) & QUEUE_M)
+
 #define MPS_TRC_INT_CAUSE_A	0x985c
 
 #define MISCPERR_S    8
-- 
1.7.1
