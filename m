From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/7] cxgb4: add debugfs support to dump filter
 debug logs
Date: Mon, 12 Sep 2016 10:36:06 +0200
Message-ID: <20160912083606.GC2021@nanopsycho>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
 <f10743c39acd854257a066f554f595a0cfa9f820.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35202 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756592AbcILIgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:36:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id a6so12524764wmc.2
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 01:36:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f10743c39acd854257a066f554f595a0cfa9f820.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 12, 2016 at 10:12:36AM CEST, rahul.lakkireddy@chelsio.com wrote:
>Add debugfs support to dump filter debug information.

Please no debugfs. Why would you want to use it?
Use a well defined user api instead. If not available, please introduce it.



>
>Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
>---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   4 +-
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 415 +++++++++++++++++++++
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h  |   2 +
> drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   5 +-
> 4 files changed, 424 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
>index 91fb508..72cf3de2 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
>@@ -1,7 +1,7 @@
> /*
>  * This file is part of the Chelsio T4 Ethernet driver for Linux.
>  *
>- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
>+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
>  *
>  * This software is available to you under a choice of one of two
>  * licenses.  You may choose to be licensed under the terms of the GNU
>@@ -45,6 +45,7 @@
> #include "cxgb4_debugfs.h"
> #include "clip_tbl.h"
> #include "l2t.h"
>+#include "cxgb4_filter.h"
> 
> /* generic seq_file support for showing a table of size rows x width. */
> static void *seq_tab_get_idx(struct seq_tab *tb, loff_t pos)
>@@ -3272,6 +3273,7 @@ int t4_setup_debugfs(struct adapter *adap)
> 		{ "tids", &tid_info_debugfs_fops, S_IRUSR, 0},
> 		{ "blocked_fl", &blocked_fl_fops, S_IRUSR | S_IWUSR, 0 },
> 		{ "meminfo", &meminfo_fops, S_IRUSR, 0 },
>+		{ "filters", &filters_debugfs_fops, S_IRUSR, 0 },
> 	};
> 
> 	/* Debug FS nodes common to all T5 and later adapters.
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>index 490bd94..51b6745 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>@@ -34,6 +34,7 @@
> 
> #include "cxgb4.h"
> #include "t4_regs.h"
>+#include "t4_values.h"
> #include "l2t.h"
> #include "t4fw_api.h"
> #include "cxgb4_filter.h"
>@@ -669,3 +670,417 @@ void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
> 			complete(&ctx->completion);
> 	}
> }
>+
>+/* Retrieve the packet count for the specified filter. */
>+int cxgb4_get_filter_count(struct adapter *adapter, unsigned int fidx,
>+			   u64 *c, int hash, bool get_byte)
>+{
>+	struct filter_entry *f;
>+	unsigned int tcb_base, tcbaddr;
>+	unsigned int max_ftids;
>+	int ret;
>+
>+	tcb_base = t4_read_reg(adapter, TP_CMM_TCB_BASE_A);
>+	max_ftids = adapter->tids.nftids;
>+	if ((fidx != (max_ftids + adapter->tids.nsftids - 1)) &&
>+	    (fidx >= max_ftids))
>+		return -E2BIG;
>+
>+	f = &adapter->tids.ftid_tab[fidx];
>+	if (!f->valid)
>+		return -EINVAL;
>+
>+	tcbaddr = tcb_base + f->tid * TCB_SIZE;
>+
>+	if (is_t4(adapter->params.chip)) {
>+		/* For T4, the Filter Packet Hit Count is maintained as a
>+		 * 64-bit Big Endian value in the TCB fields
>+		 * {t_rtt_ts_recent_age, t_rtseq_recent} ... The format in
>+		 * memory is swizzled/mapped in a manner such that instead
>+		 * of having this 64-bit counter show up at offset 24
>+		 * ((TCB_T_RTT_TS_RECENT_AGE_W == 6) * sizeof(u32)), it
>+		 * actually shows up at offset 16. Hence the constant "4"
>+		 * below instead of TCB_T_RTT_TS_RECENT_AGE_W.
>+		 */
>+		if (get_byte) {
>+			unsigned int word_offset = 4;
>+			__be64 be64_byte_count;
>+
>+			spin_lock(&adapter->win0_lock);
>+			ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
>+					   tcbaddr +
>+					   (word_offset * sizeof(__be32)),
>+					   sizeof(be64_byte_count),
>+					   &be64_byte_count,
>+					   T4_MEMORY_READ);
>+			spin_unlock(&adapter->win0_lock);
>+			if (ret < 0)
>+				return ret;
>+			*c = be64_to_cpu(be64_byte_count);
>+		} else {
>+			unsigned int word_offset = 4;
>+			__be64 be64_count;
>+
>+			spin_lock(&adapter->win0_lock);
>+			ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
>+					   tcbaddr +
>+					   (word_offset * sizeof(__be32)),
>+					   sizeof(be64_count),
>+					   (__be32 *)&be64_count,
>+					   T4_MEMORY_READ);
>+			spin_unlock(&adapter->win0_lock);
>+			if (ret < 0)
>+				return ret;
>+			*c = be64_to_cpu(be64_count);
>+		}
>+	} else {
>+		/* For T5, the Filter Packet Hit Count is maintained as a
>+		 * 32-bit Big Endian value in the TCB field {timestamp}.
>+		 * Instead of the filter hit count showing up at offset 20
>+		 * ((TCB_TIMESTAMP_W == 5) * sizeof(u32)), it actually shows
>+		 * up at offset 24.  Hence the constant "6" below.
>+		 */
>+		if (get_byte) {
>+			unsigned int word_offset = 4;
>+			__be64 be64_byte_count;
>+
>+			spin_lock(&adapter->win0_lock);
>+			ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
>+					   tcbaddr +
>+					   (word_offset * sizeof(__be32)),
>+					   sizeof(be64_byte_count),
>+					   &be64_byte_count,
>+					   T4_MEMORY_READ);
>+			spin_unlock(&adapter->win0_lock);
>+			if (ret < 0)
>+				return ret;
>+			*c = be64_to_cpu(be64_byte_count);
>+		} else {
>+			unsigned int word_offset = 6;
>+			__be32 be32_count;
>+
>+			spin_lock(&adapter->win0_lock);
>+			ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
>+					   tcbaddr +
>+					   (word_offset * sizeof(__be32)),
>+					   sizeof(be32_count), &be32_count,
>+					   T4_MEMORY_READ);
>+			spin_unlock(&adapter->win0_lock);
>+			if (ret < 0)
>+				return ret;
>+			*c = (u64)be32_to_cpu(be32_count);
>+		}
>+	}
>+
>+	return 0;
>+}
>+
>+/* Filter Table. */
>+static void filters_show_ipaddr(struct seq_file *seq,
>+				int type, u8 *addr, u8 *addrm)
>+{
>+	int noctets, octet;
>+
>+	seq_puts(seq, " ");
>+	if (type == 0) {
>+		noctets = 4;
>+		seq_printf(seq, "%48s", " ");
>+	} else {
>+		noctets = 16;
>+	}
>+
>+	for (octet = 0; octet < noctets; octet++)
>+		seq_printf(seq, "%02x", addr[octet]);
>+	seq_puts(seq, "/");
>+	for (octet = 0; octet < noctets; octet++)
>+		seq_printf(seq, "%02x", addrm[octet]);
>+}
>+
>+static void filters_display(struct seq_file *seq, unsigned int fidx,
>+			    struct filter_entry *f, int hash)
>+{
>+	struct adapter *adapter = seq->private;
>+	u32 fconf = adapter->params.tp.vlan_pri_map;
>+	u32 tpiconf = adapter->params.tp.ingress_config;
>+	int i;
>+
>+	/* Filter index */
>+	seq_printf(seq, "%4d%c%c", fidx,
>+		   (!f->locked  ? ' ' : '!'),
>+		   (!f->pending ? ' ' : (!f->valid ? '+' : '-')));
>+
>+	if (f->fs.hitcnts) {
>+		u64 hitcnt;
>+		int ret;
>+
>+		ret = cxgb4_get_filter_count(adapter, fidx, &hitcnt,
>+					     hash, false);
>+		if (ret)
>+			seq_printf(seq, " %20s", "hits={ERROR}");
>+		else
>+			seq_printf(seq, " %20llu", hitcnt);
>+	} else {
>+		seq_printf(seq, " %20s", "Disabled");
>+	}
>+
>+	/* Compressed header portion of filter. */
>+	for (i = FT_FIRST_S; i <= FT_LAST_S; i++) {
>+		switch (fconf & (1 << i)) {
>+		case 0:
>+			/* compressed filter field not enabled */
>+			break;
>+
>+		case FCOE_F:
>+			seq_printf(seq, "  %1d/%1d",
>+				   f->fs.val.fcoe, f->fs.mask.fcoe);
>+			break;
>+
>+		case PORT_F:
>+			seq_printf(seq, "  %1d/%1d",
>+				   f->fs.val.iport, f->fs.mask.iport);
>+			break;
>+
>+		case VNIC_ID_F:
>+			if ((tpiconf & VNIC_F) == 0)
>+				seq_printf(seq, " %1d:%04x/%1d:%04x",
>+					   f->fs.val.ovlan_vld,
>+					   f->fs.val.ovlan,
>+					   f->fs.mask.ovlan_vld,
>+					   f->fs.mask.ovlan);
>+			else
>+				seq_printf(seq, " %1d:%1x:%02x/%1d:%1x:%02x",
>+					   f->fs.val.ovlan_vld,
>+					   (f->fs.val.ovlan >> 13) & 0x7,
>+					   f->fs.val.ovlan & 0x7f,
>+					   f->fs.mask.ovlan_vld,
>+					   (f->fs.mask.ovlan >> 13) & 0x7,
>+					   f->fs.mask.ovlan & 0x7f);
>+			break;
>+
>+		case VLAN_F:
>+			seq_printf(seq, " %1d:%04x/%1d:%04x",
>+				   f->fs.val.ivlan_vld,
>+				   f->fs.val.ivlan,
>+				   f->fs.mask.ivlan_vld,
>+				   f->fs.mask.ivlan);
>+			break;
>+
>+		case TOS_F:
>+			seq_printf(seq, " %02x/%02x",
>+				   f->fs.val.tos, f->fs.mask.tos);
>+			break;
>+
>+		case PROTOCOL_F:
>+			seq_printf(seq, " %02x/%02x",
>+				   f->fs.val.proto, f->fs.mask.proto);
>+			break;
>+
>+		case ETHERTYPE_F:
>+			seq_printf(seq, " %04x/%04x",
>+				   f->fs.val.ethtype, f->fs.mask.ethtype);
>+			break;
>+
>+		case MACMATCH_F:
>+			seq_printf(seq, " %03x/%03x",
>+				   f->fs.val.macidx, f->fs.mask.macidx);
>+			break;
>+
>+		case MPSHITTYPE_F:
>+			seq_printf(seq, " %1x/%1x",
>+				   f->fs.val.matchtype,
>+				   f->fs.mask.matchtype);
>+			break;
>+
>+		case FRAGMENTATION_F:
>+			seq_printf(seq, "  %1d/%1d",
>+				   f->fs.val.frag, f->fs.mask.frag);
>+			break;
>+		}
>+	}
>+
>+	/* Fixed portion of filter. */
>+	filters_show_ipaddr(seq, f->fs.type,
>+			    f->fs.val.lip, f->fs.mask.lip);
>+	filters_show_ipaddr(seq, f->fs.type,
>+			    f->fs.val.fip, f->fs.mask.fip);
>+	seq_printf(seq, " %04x/%04x %04x/%04x",
>+		   f->fs.val.lport, f->fs.mask.lport,
>+		   f->fs.val.fport, f->fs.mask.fport);
>+
>+	/* Variable length filter action. */
>+	if (f->fs.action == FILTER_DROP) {
>+		seq_puts(seq, " Drop");
>+	} else if (f->fs.action == FILTER_SWITCH) {
>+		seq_printf(seq, " Switch: port=%d", f->fs.eport);
>+		if (f->fs.newdmac)
>+			seq_printf(seq,
>+				   ", dmac=%02x:%02x:%02x:%02x:%02x:%02x, l2tidx=%d",
>+				   f->fs.dmac[0], f->fs.dmac[1],
>+				   f->fs.dmac[2], f->fs.dmac[3],
>+				   f->fs.dmac[4], f->fs.dmac[5],
>+				   f->l2t->idx);
>+		if (f->fs.newsmac)
>+			seq_printf(seq,
>+				   ", smac=%02x:%02x:%02x:%02x:%02x:%02x, smtidx=%d",
>+				   f->fs.smac[0], f->fs.smac[1],
>+				   f->fs.smac[2], f->fs.smac[3],
>+				   f->fs.smac[4], f->fs.smac[5],
>+				   f->smtidx);
>+		if (f->fs.newvlan == VLAN_REMOVE)
>+			seq_puts(seq, ", vlan=none");
>+		else if (f->fs.newvlan == VLAN_INSERT)
>+			seq_printf(seq, ", vlan=insert(%x)",
>+				   f->fs.vlan);
>+		else if (f->fs.newvlan == VLAN_REWRITE)
>+			seq_printf(seq, ", vlan=rewrite(%x)",
>+				   f->fs.vlan);
>+	} else {
>+		seq_puts(seq, " Pass: Q=");
>+		if (f->fs.dirsteer == 0) {
>+			seq_puts(seq, "RSS");
>+			if (f->fs.maskhash)
>+				seq_puts(seq, "(TCB=hash)");
>+		} else {
>+			seq_printf(seq, "%d", f->fs.iq);
>+			if (f->fs.dirsteerhash == 0)
>+				seq_puts(seq, "(QID)");
>+			else
>+				seq_puts(seq, "(hash)");
>+		}
>+	}
>+	if (f->fs.prio)
>+		seq_puts(seq, " Prio");
>+	if (f->fs.rpttid)
>+		seq_puts(seq, " RptTID");
>+	seq_puts(seq, "\n");
>+}
>+
>+static int filters_show(struct seq_file *seq, void *v)
>+{
>+	struct adapter *adapter = seq->private;
>+	u32 fconf = adapter->params.tp.vlan_pri_map;
>+	u32 tpiconf = adapter->params.tp.ingress_config;
>+	int i;
>+
>+	if (v == SEQ_START_TOKEN) {
>+		seq_puts(seq, "[[Legend: '!' => locked; '+' => pending set; '-' => pending clear]]\n");
>+		seq_puts(seq, " Idx                   Hits");
>+		for (i = FT_FIRST_S; i <= FT_LAST_S; i++) {
>+			switch (fconf & (1 << i)) {
>+			case 0:
>+				/* compressed filter field not enabled */
>+				break;
>+
>+			case FCOE_F:
>+				seq_puts(seq, " FCoE");
>+				break;
>+
>+			case PORT_F:
>+				seq_puts(seq, " Port");
>+				break;
>+
>+			case VNIC_ID_F:
>+				if ((tpiconf & VNIC_F) == 0)
>+					seq_puts(seq, "     vld:oVLAN");
>+				else
>+					seq_puts(seq, "   VFvld:PF:VF");
>+				break;
>+
>+			case VLAN_F:
>+				seq_puts(seq, "     vld:iVLAN");
>+				break;
>+
>+			case TOS_F:
>+				seq_puts(seq, "   TOS");
>+				break;
>+
>+			case PROTOCOL_F:
>+				seq_puts(seq, "  Prot");
>+				break;
>+
>+			case ETHERTYPE_F:
>+				seq_puts(seq, "   EthType");
>+				break;
>+
>+			case MACMATCH_F:
>+				seq_puts(seq, "  MACIdx");
>+				break;
>+
>+			case MPSHITTYPE_F:
>+				seq_puts(seq, " MPS");
>+				break;
>+
>+			case FRAGMENTATION_F:
>+				seq_puts(seq, " Frag");
>+				break;
>+			}
>+		}
>+		seq_printf(seq, " %65s %65s %9s %9s %s\n",
>+			   "LIP", "FIP", "LPORT", "FPORT", "Action");
>+	} else {
>+		int fidx = (uintptr_t)v - 2;
>+		struct filter_entry *f = &adapter->tids.ftid_tab[fidx];
>+
>+		/* if this entry isn't filled in just return */
>+		if (!f->valid && !f->pending)
>+			return 0;
>+
>+		filters_display(seq, fidx, f, 0);
>+	}
>+	return 0;
>+}
>+
>+static inline void *filters_get_idx(struct adapter *adapter, loff_t pos)
>+{
>+	if (pos > (adapter->tids.nftids + adapter->tids.nsftids))
>+		return NULL;
>+
>+	return (void *)(uintptr_t)(pos + 1);
>+}
>+
>+static void *filters_start(struct seq_file *seq, loff_t *pos)
>+{
>+	struct adapter *adapter = seq->private;
>+
>+	return *pos ? filters_get_idx(adapter, *pos) : SEQ_START_TOKEN;
>+}
>+
>+static void *filters_next(struct seq_file *seq, void *v, loff_t *pos)
>+{
>+	struct adapter *adapter = seq->private;
>+
>+	(*pos)++;
>+	return filters_get_idx(adapter, *pos);
>+}
>+
>+static void filters_stop(struct seq_file *seq, void *v)
>+{
>+}
>+
>+static const struct seq_operations filters_seq_ops = {
>+	.start = filters_start,
>+	.next  = filters_next,
>+	.stop  = filters_stop,
>+	.show  = filters_show
>+};
>+
>+int filters_open(struct inode *inode, struct file *file)
>+{
>+	struct adapter *adapter = inode->i_private;
>+	int res;
>+
>+	res = seq_open(file, &filters_seq_ops);
>+	if (!res) {
>+		struct seq_file *seq = file->private_data;
>+
>+		seq->private = adapter;
>+	}
>+	return res;
>+}
>+
>+const struct file_operations filters_debugfs_fops = {
>+	.owner   = THIS_MODULE,
>+	.open    = filters_open,
>+	.read    = seq_read,
>+	.llseek  = seq_lseek,
>+};
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
>index 23742cb..e801e0b 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
>@@ -37,6 +37,8 @@
> 
> #include "t4_msg.h"
> 
>+extern const struct file_operations filters_debugfs_fops;
>+
> void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl);
> void clear_filter(struct adapter *adap, struct filter_entry *f);
> 
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
>index 36cf307..0115222 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
>+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
>@@ -1,7 +1,7 @@
> /*
>  * This file is part of the Chelsio T4 Ethernet driver for Linux.
>  *
>- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
>+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
>  *
>  * This software is available to you under a choice of one of two
>  * licenses.  You may choose to be licensed under the terms of the GNU
>@@ -121,6 +121,9 @@
>  * selects for a particular field being present.  These fields, when present
>  * in the Compressed Filter Tuple, have the following widths in bits.
>  */
>+#define FT_FIRST_S                      FCOE_S
>+#define FT_LAST_S                       FRAGMENTATION_S
>+
> #define FT_FCOE_W                       1
> #define FT_PORT_W                       3
> #define FT_VNIC_ID_W                    17
>-- 
>2.5.3
>
