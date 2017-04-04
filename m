From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/14] nfp: allow multi-stage NSP configuration
Date: Tue,  4 Apr 2017 16:12:31 -0700
Message-ID: <20170404231235.32027-11-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35139 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755279AbdDDXNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:02 -0400
Received: by mail-pf0-f180.google.com with SMTP id i5so25011711pfc.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:02 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NSP commands may be slow to respond, we should try to avoid doing
a command-per-item when user requested to change multiple parameters
for instance with an ethtool .set_settings() command.

Introduce a way of internal NSP code to carry state in NSP structure
and add start/finish calls to perform the initialization and kick off
of the configuration request, with potentially many parameters being
modified in between.

nfp_eth_set_mod_enable() will make use of the new code internally,
other "set" functions to follow.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   8 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  43 ++++++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   4 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 114 +++++++++++++++------
 4 files changed, 138 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 778bd9424d5d..8afef7593f13 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -52,6 +52,14 @@ const char *nfp_hwinfo_lookup(struct nfp_cpp *cpp, const char *lookup);
 
 struct nfp_nsp;
 
+struct nfp_cpp *nfp_nsp_cpp(struct nfp_nsp *state);
+bool nfp_nsp_config_modified(struct nfp_nsp *state);
+void nfp_nsp_config_set_modified(struct nfp_nsp *state, bool modified);
+void *nfp_nsp_config_entries(struct nfp_nsp *state);
+unsigned int nfp_nsp_config_idx(struct nfp_nsp *state);
+void nfp_nsp_config_set_state(struct nfp_nsp *state, void *entries,
+			      unsigned int idx);
+void nfp_nsp_config_clear_state(struct nfp_nsp *state);
 int nfp_nsp_read_eth_table(struct nfp_nsp *state, void *buf, unsigned int size);
 int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 			    const void *buf, unsigned int size);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 6482831282b2..225d07815375 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -104,8 +104,51 @@ struct nfp_nsp {
 		u16 major;
 		u16 minor;
 	} ver;
+
+	/* Eth table config state */
+	bool modified;
+	unsigned int idx;
+	void *entries;
 };
 
+struct nfp_cpp *nfp_nsp_cpp(struct nfp_nsp *state)
+{
+	return state->cpp;
+}
+
+bool nfp_nsp_config_modified(struct nfp_nsp *state)
+{
+	return state->modified;
+}
+
+void nfp_nsp_config_set_modified(struct nfp_nsp *state, bool modified)
+{
+	state->modified = modified;
+}
+
+void *nfp_nsp_config_entries(struct nfp_nsp *state)
+{
+	return state->entries;
+}
+
+unsigned int nfp_nsp_config_idx(struct nfp_nsp *state)
+{
+	return state->idx;
+}
+
+void
+nfp_nsp_config_set_state(struct nfp_nsp *state, void *entries, unsigned int idx)
+{
+	state->entries = entries;
+	state->idx = idx;
+}
+
+void nfp_nsp_config_clear_state(struct nfp_nsp *state)
+{
+	state->entries = NULL;
+	state->idx = 0;
+}
+
 static int nfp_nsp_check(struct nfp_nsp *state)
 {
 	struct nfp_cpp *cpp = state->cpp;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
index e3baec3cccc2..c452ad311993 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
@@ -136,4 +136,8 @@ struct nfp_eth_table *
 __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp);
 int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable);
 
+struct nfp_nsp *nfp_eth_config_start(struct nfp_cpp *cpp, unsigned int idx);
+int nfp_eth_config_commit_end(struct nfp_nsp *nsp);
+void nfp_eth_config_cleanup_end(struct nfp_nsp *nsp);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 837de15ed720..55d8e073ccbd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -268,63 +268,115 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 	return NULL;
 }
 
-/**
- * nfp_eth_set_mod_enable() - set PHY module enable control bit
- * @cpp:	NFP CPP handle
- * @idx:	NFP chip-wide port index
- * @enable:	Desired state
- *
- * Enable or disable PHY module (this usually means setting the TX lanes
- * disable bits).
- *
- * Return: 0 or -ERRNO.
- */
-int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
+struct nfp_nsp *nfp_eth_config_start(struct nfp_cpp *cpp, unsigned int idx)
 {
 	struct eth_table_entry *entries;
 	struct nfp_nsp *nsp;
-	u64 reg;
 	int ret;
 
 	entries = kzalloc(NSP_ETH_TABLE_SIZE, GFP_KERNEL);
 	if (!entries)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	nsp = nfp_nsp_open(cpp);
 	if (IS_ERR(nsp)) {
 		kfree(entries);
-		return PTR_ERR(nsp);
+		return nsp;
 	}
 
 	ret = nfp_nsp_read_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
 	if (ret < 0) {
 		nfp_err(cpp, "reading port table failed %d\n", ret);
-		goto exit_close_nsp;
+		goto err;
 	}
 
 	if (!(entries[idx].port & NSP_ETH_PORT_LANES_MASK)) {
 		nfp_warn(cpp, "trying to set port state on disabled port %d\n",
 			 idx);
-		ret = -EINVAL;
-		goto exit_close_nsp;
+		goto err;
 	}
 
-	/* Check if we are already in requested state */
-	reg = le64_to_cpu(entries[idx].state);
-	if (enable == FIELD_GET(NSP_ETH_CTRL_ENABLED, reg)) {
-		ret = 0;
-		goto exit_close_nsp;
-	}
+	nfp_nsp_config_set_state(nsp, entries, idx);
+	return nsp;
+
+err:
+	nfp_nsp_close(nsp);
+	kfree(entries);
+	return ERR_PTR(-EIO);
+}
 
-	reg = le64_to_cpu(entries[idx].control);
-	reg &= ~NSP_ETH_CTRL_ENABLED;
-	reg |= FIELD_PREP(NSP_ETH_CTRL_ENABLED, enable);
-	entries[idx].control = cpu_to_le64(reg);
+void nfp_eth_config_cleanup_end(struct nfp_nsp *nsp)
+{
+	struct eth_table_entry *entries = nfp_nsp_config_entries(nsp);
 
-	ret = nfp_nsp_write_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
-exit_close_nsp:
+	nfp_nsp_config_set_modified(nsp, false);
+	nfp_nsp_config_clear_state(nsp);
 	nfp_nsp_close(nsp);
 	kfree(entries);
+}
+
+/**
+ * nfp_eth_config_commit_end() - perform recorded configuration changes
+ * @nsp:	NFP NSP handle returned from nfp_eth_config_start()
+ *
+ * Perform the configuration which was requested with __nfp_eth_set_*()
+ * helpers and recorded in @nsp state.  If device was already configured
+ * as requested or no __nfp_eth_set_*() operations were made no NSP command
+ * will be performed.
+ *
+ * Return:
+ * 0 - configuration successful;
+ * 1 - no changes were needed;
+ * -ERRNO - configuration failed.
+ */
+int nfp_eth_config_commit_end(struct nfp_nsp *nsp)
+{
+	struct eth_table_entry *entries = nfp_nsp_config_entries(nsp);
+	int ret = 1;
+
+	if (nfp_nsp_config_modified(nsp)) {
+		ret = nfp_nsp_write_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
+		ret = ret < 0 ? ret : 0;
+	}
+
+	nfp_eth_config_cleanup_end(nsp);
+
+	return ret;
+}
+
+/**
+ * nfp_eth_set_mod_enable() - set PHY module enable control bit
+ * @cpp:	NFP CPP handle
+ * @idx:	NFP chip-wide port index
+ * @enable:	Desired state
+ *
+ * Enable or disable PHY module (this usually means setting the TX lanes
+ * disable bits).
+ *
+ * Return: 0 or -ERRNO.
+ */
+int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
+{
+	struct eth_table_entry *entries;
+	struct nfp_nsp *nsp;
+	u64 reg;
+
+	nsp = nfp_eth_config_start(cpp, idx);
+	if (IS_ERR(nsp))
+		return PTR_ERR(nsp);
+
+	entries = nfp_nsp_config_entries(nsp);
+
+	/* Check if we are already in requested state */
+	reg = le64_to_cpu(entries[idx].state);
+	if (enable != FIELD_GET(NSP_ETH_CTRL_ENABLED, reg)) {
+		reg = le64_to_cpu(entries[idx].control);
+		reg &= ~NSP_ETH_CTRL_ENABLED;
+		reg |= FIELD_PREP(NSP_ETH_CTRL_ENABLED, enable);
+		entries[idx].control = cpu_to_le64(reg);
+
+		nfp_nsp_config_set_modified(nsp, true);
+	}
 
-	return ret < 0 ? ret : 0;
+	return nfp_eth_config_commit_end(nsp);
 }
-- 
2.11.0
