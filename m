From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/7] sctp: Add infrastructure for per net sysctls
Date: Tue, 07 Aug 2012 10:23:59 -0700
Message-ID: <87d332d39s.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com>
	<87ipcud3ld.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ipcud3ld.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 07 Aug 2012 10:17:02 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Start with an empty sctp_net_table that will be populated as the various
tunable sysctls are made per net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netns/sctp.h |    6 +++++-
 include/net/sctp/sctp.h  |    4 ++++
 net/sctp/protocol.c      |    7 +++++++
 net/sctp/sysctl.c        |   21 +++++++++++++++++++++
 4 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 06ccddf..9576b60 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -4,6 +4,7 @@
 struct sock;
 struct proc_dir_entry;
 struct sctp_mib;
+struct ctl_table_header;
 
 struct netns_sctp {
 	DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics);
@@ -11,7 +12,9 @@ struct netns_sctp {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc_net_sctp;
 #endif
-
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *sysctl_header;
+#endif
 	/* This is the global socket data structure used for responding to
 	 * the Out-of-the-blue (OOTB) packets.  A control sock will be created
 	 * for this socket at the initialization time.
@@ -32,6 +35,7 @@ struct netns_sctp {
 
 	/* Lock that protects the local_addr_list writers */
 	spinlock_t local_addr_lock;
+
 };
 
 #endif /* __NETNS_SCTP_H__ */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b0e6fe5..15037e7 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -375,9 +375,13 @@ static inline void sctp_dbg_objcnt_exit(void) { return; }
 #if defined CONFIG_SYSCTL
 void sctp_sysctl_register(void);
 void sctp_sysctl_unregister(void);
+int sctp_sysctl_net_register(struct net *net);
+void sctp_sysctl_net_unregister(struct net *net);
 #else
 static inline void sctp_sysctl_register(void) { return; }
 static inline void sctp_sysctl_unregister(void) { return; }
+static inline int sctp_sysctl_net_register(struct net *net) { return 0; }
+static inline void sctp_sysctl_net_unregister(struct net *net) { return; }
 #endif
 
 /* Size of Supported Address Parameter for 'x' address types. */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 69bdc72..de25d9c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1169,6 +1169,10 @@ static int sctp_net_init(struct net *net)
 {
 	int status;
 
+	status = sctp_sysctl_net_register(net);
+	if (status)
+		goto err_sysctl_register;
+
 	/* Allocate and initialise sctp mibs.  */
 	status = init_sctp_mibs(net);
 	if (status)
@@ -1205,6 +1209,8 @@ err_ctl_sock_init:
 err_init_proc:
 	cleanup_sctp_mibs(net);
 err_init_mibs:
+	sctp_sysctl_net_unregister(net);
+err_sysctl_register:
 	return status;
 }
 
@@ -1219,6 +1225,7 @@ static void sctp_net_exit(struct net *net)
 
 	sctp_proc_exit(net);
 	cleanup_sctp_mibs(net);
+	sctp_sysctl_net_unregister(net);
 }
 
 static struct pernet_operations sctp_net_ops = {
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 2b2bfe9..7528d59 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -284,6 +284,27 @@ static ctl_table sctp_table[] = {
 	{ /* sentinel */ }
 };
 
+static ctl_table sctp_net_table[] = {
+	{ /* sentinel */ }	
+};
+
+int sctp_sysctl_net_register(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
+	return 0;
+}
+
+void sctp_sysctl_net_unregister(struct net *net)
+{
+	unregister_net_sysctl_table(net->sctp.sysctl_header);
+}
+
 static struct ctl_table_header * sctp_sysctl_header;
 
 /* Sysctl registration.  */
-- 
1.7.5.4
