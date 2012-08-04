From: Jan Ariyasu <jan.ariyasu@gmail.com>
Subject: [PATCH 05/13] SCTP: register per-namespace sysctl.
Date: Sat,  4 Aug 2012 15:33:01 -0600
Message-ID: <1344115981-6330-1-git-send-email-jan.ariyasu@hp.com>
Cc: Jan Ariyasu <jan.ariyasu@hp.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated sysctl registration to be per-netns and to use per-net
protocol parameters.

Signed-off-by: Jan Ariyasu <jan.ariyasu@hp.com>
---
 include/net/sctp/sctp.h |    8 +-
 net/sctp/protocol.c     |   24 +++++-
 net/sctp/sysctl.c       |  218 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 221 insertions(+), 29 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index bda317a..eb2ec98 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -381,11 +381,15 @@ static inline void sctp_dbg_objcnt_exit(void) { return; }
 #endif /* CONFIG_SCTP_DBG_OBJCOUNT */
 
 #if defined CONFIG_SYSCTL
-void sctp_sysctl_register(void);
+int sctp_sysctl_register(void);
 void sctp_sysctl_unregister(void);
+int __net_init sctp_sysctl_init_net(struct net *net);
+void __net_exit sctp_sysctl_exit_net(struct net *net);
 #else
-static inline void sctp_sysctl_register(void) { return; }
+static inline int sctp_sysctl_register(void) { return 0; }
 static inline void sctp_sysctl_unregister(void) { return; }
+static inline int sctp_sysctl_init_net(struct net *net) { return 0; };
+static inline void sctp_sysctl_exit_net(struct net *net) { return 0; };
 #endif
 
 /* Size of Supported Address Parameter for 'x' address types. */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index dce07d6..32bb8f4e2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1582,8 +1582,15 @@ static int __net_init sctp_net_init(struct net *net)
 	if (err)
 		goto err_param_init;
 
+#ifdef CONFIG_SYSCTL
+	err = sctp_sysctl_init_net(net);
+	if (err)
+		goto err_param_init;
+#endif
+
 	sctp_get_local_addr_list(net);
 	goto out;
+
 err_param_init:
 	sctp_proc_exit(net);
 err_proc_init:
@@ -1601,6 +1608,10 @@ static void __net_exit sctp_net_exit(struct net *net)
 	sctp_free_local_addr_list(net);
 	/* Clean up procfs */
 	sctp_proc_exit(net);
+#ifdef CONFIG_SYSCTL
+	/* Clean up sysfs */
+	sctp_sysctl_exit_net(net);
+#endif
 }
 
 static __net_initdata struct pernet_operations sctp_sk_ops = {
@@ -1671,7 +1682,11 @@ SCTP_STATIC __init int sctp_init(void)
 		goto err_v6_add_protocol;
 
 	/*  Set up sysctl parameters.   */
-	sctp_sysctl_register();
+#ifdef CONFIG_SYSCTL
+	status = sctp_sysctl_register();
+	if (status)
+		goto err_sysctl_init;
+#endif
 
 	/*
 	 * Register for pernet packet handling
@@ -1694,10 +1709,13 @@ SCTP_STATIC __init int sctp_init(void)
 	goto out;
 
 err_mib_init:
-	sctp_sysctl_unregister();
 	sctp_dbg_objcnt_exit();
 	sctp_ns_exit();
 err_ns_init:
+#ifdef CONFIG_SYSCTL
+	sctp_sysctl_unregister();
+#endif
+err_sysctl_init:
 	sctp_v6_del_protocol();
 err_v6_add_protocol:
 	sctp_v4_del_protocol();
@@ -1735,7 +1753,9 @@ SCTP_STATIC __exit void sctp_exit(void)
 	sctp_v6_pf_exit();
 	sctp_v4_pf_exit();
 
+#ifdef CONFIG_SYSCTL
 	sctp_sysctl_unregister();
+#endif
 	sctp_hashtable_globals_free();
 
 	sctp_dbg_objcnt_exit();
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 2b2bfe9..0d42d90 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -219,27 +219,6 @@ static ctl_table sctp_table[] = {
 		.extra2         = &sack_timer_max,
 	},
 	{
-		.procname	= "sctp_mem",
-		.data		= &sysctl_sctp_mem,
-		.maxlen		= sizeof(sysctl_sctp_mem),
-		.mode		= 0644,
-		.proc_handler	= proc_doulongvec_minmax
-	},
-	{
-		.procname	= "sctp_rmem",
-		.data		= &sysctl_sctp_rmem,
-		.maxlen		= sizeof(sysctl_sctp_rmem),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "sctp_wmem",
-		.data		= &sysctl_sctp_wmem,
-		.maxlen		= sizeof(sysctl_sctp_wmem),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "auth_enable",
 		.data		= &sctp_auth_enable,
 		.maxlen		= sizeof(int),
@@ -284,16 +263,205 @@ static ctl_table sctp_table[] = {
 	{ /* sentinel */ }
 };
 
-static struct ctl_table_header * sctp_sysctl_header;
+static struct ctl_table sctp_mem_table[] = {
+	{
+		.procname	= "sctp_mem",
+		.data		= &sysctl_sctp_mem,
+		.maxlen		= sizeof(sysctl_sctp_mem),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax
+	},
+	{
+		.procname	= "sctp_rmem",
+		.data		= &sysctl_sctp_rmem,
+		.maxlen		= sizeof(sysctl_sctp_rmem),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sctp_wmem",
+		.data		= &sysctl_sctp_wmem,
+		.maxlen		= sizeof(sysctl_sctp_wmem),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+
+	{ /* sentinel */ }
+};
+
+static struct ctl_path sctp_path[] = {
+	{ .procname = "net", },
+	{ .procname = "sctp", },
+	{ }
+};
+
+static struct ctl_table_header *sctp_sysctl_mem_header;
 
 /* Sysctl registration.  */
-void sctp_sysctl_register(void)
+int sctp_sysctl_register(void)
 {
-	sctp_sysctl_header = register_net_sysctl(&init_net, "net/sctp", sctp_table);
+	int err = 0;
+	sctp_sysctl_mem_header = NULL;
+	sctp_sysctl_mem_header = register_sysctl_paths(sctp_path,
+							sctp_mem_table);
+	if (sctp_sysctl_mem_header == NULL) {
+		pr_err("Failed to register sctp_mem_table sysctl path\n");
+		err = -ENOMEM;
+	}
+	return err;
 }
 
 /* Sysctl deregistration.  */
 void sctp_sysctl_unregister(void)
 {
-	unregister_net_sysctl_table(sctp_sysctl_header);
+	unregister_net_sysctl_table(sctp_sysctl_mem_header);
+}
+
+/* Per-net sysctl registration */
+int __net_init sctp_sysctl_init_net(struct net *net)
+{
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	struct sctp_net_params *net_params = sctp_get_params(net);
+	struct ctl_table *table, *tmp_tbl;
+
+	table = sctp_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(table, sizeof(sctp_table), GFP_KERNEL);
+		if (table == NULL)
+			goto err_alloc;
+
+		for (tmp_tbl = table; tmp_tbl->procname; tmp_tbl++) {
+			if (strcmp(tmp_tbl->procname, "rto_initial") == 0) {
+				tmp_tbl->data = &net_params->rto_initial;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "rto_min") == 0) {
+				tmp_tbl->data = &net_params->rto_min;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "rto_max") == 0) {
+				tmp_tbl->data = &net_params->rto_max;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+				   "valid_cookie_life") == 0) {
+				tmp_tbl->data = &net_params->valid_cookie_life;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "max_burst") == 0) {
+				tmp_tbl->data = &net_params->max_burst;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+				   "association_max_retrans") == 0) {
+				tmp_tbl->data =
+					&net_params->max_retrans_association;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "sndbuf_policy") == 0) {
+				tmp_tbl->data = &net_params->sndbuf_policy;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "rcvbuf_policy") == 0) {
+				tmp_tbl->data = &net_params->rcvbuf_policy;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"path_max_retrans") == 0) {
+				tmp_tbl->data = &net_params->max_retrans_path;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "pf_retrans") == 0) {
+				tmp_tbl->data = &net_params->pf_retrans;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"max_init_retransmits") == 0) {
+				tmp_tbl->data = &net_params->max_retrans_init;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "hb_interval") == 0) {
+				tmp_tbl->data = &net_params->hb_interval;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"cookie_preserve_enable") == 0) {
+				tmp_tbl->data =
+					&net_params->cookie_preserve_enable;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"rto_alpha_exp_divisor") == 0) {
+				tmp_tbl->data = &net_params->rto_alpha;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"rto_beta_exp_divisor") == 0) {
+				tmp_tbl->data = &net_params->rto_beta;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "addip_enable") == 0) {
+				tmp_tbl->data = &net_params->addip_enable;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"default_auto_asconf") == 0) {
+				tmp_tbl->data =
+					&net_params->default_auto_asconf;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "prsctp_enable") == 0) {
+				tmp_tbl->data = &net_params->prsctp_enable;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "sack_timeout") == 0) {
+				tmp_tbl->data = &net_params->sack_timeout;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "auth_enable") == 0) {
+				tmp_tbl->data = &net_params->auth_enable;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"addip_noauth_enable") == 0) {
+				tmp_tbl->data =
+					&net_params->addip_noauth_enable;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"addr_scope_policy") == 0) {
+				tmp_tbl->data = &net_params->ipv4_scope_policy;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname,
+					"rwnd_update_shift") == 0) {
+				tmp_tbl->data = &net_params->rwnd_update_shift;
+				continue;
+			}
+			if (strcmp(tmp_tbl->procname, "max_autoclose") == 0) {
+				tmp_tbl->data = &net_params->max_autoclose;
+				continue;
+			}
+		}
+	}
+	ns_globals->sctp_sysctl_tbl = register_net_sysctl(net,
+							  "net/sctp", table);
+	if (ns_globals->sctp_sysctl_tbl == NULL)
+		goto err_reg;
+
+	return 0;
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+
+err_alloc:
+	return -ENOMEM;
+}
+
+void __net_exit sctp_sysctl_exit_net(struct net *net)
+{
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	struct ctl_table *table = ns_globals->sctp_sysctl_tbl->ctl_table_arg;
+	unregister_net_sysctl_table(ns_globals->sctp_sysctl_tbl);
+	kfree(table);
 }
-- 
1.7.9.5
