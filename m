From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 15/15] smc: proc-fs interface for smc connections
Date: Fri,  3 Jun 2016 17:27:14 +0200
Message-ID: <201606031527.u53FPx9A037226@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50241 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753040AbcFCP1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:51 -0400
Received: from pps.filterd (m0048817.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FPx9A037226
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:51 -0400
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com [195.75.94.113])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bc7r8xag-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:51 -0400
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:49 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain a list of SMC sockets and display important SMC socket
information in /proc/net/smc.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/af_smc.c   |  14 +++
 net/smc/smc.h      |   1 +
 net/smc/smc_proc.c | 251 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_proc.h |  19 ++++
 5 files changed, 286 insertions(+), 1 deletion(-)
 create mode 100644 net/smc/smc_proc.c
 create mode 100644 net/smc/smc_proc.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index 5cf0caf..7918a45 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SMC)	+= smc.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
-smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o
+smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o smc_proc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 0a7d78d..7bf7d5a 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -39,6 +39,7 @@
 #include "smc_tx.h"
 #include "smc_rx.h"
 #include "smc_close.h"
+#include "smc_proc.h"
 
 static DEFINE_MUTEX(smc_create_lgr_pending);	/* serialize link group
 						 * creation
@@ -118,11 +119,14 @@ out:
 
 static void smc_destruct(struct sock *sk)
 {
+	struct smc_sock *smc = smc_sk(sk);
+
 	if (sk->sk_state != SMC_CLOSED)
 		return;
 	if (!sock_flag(sk, SOCK_DEAD))
 		return;
 
+	smc_proc_sock_list_del(smc);
 	sk_refcnt_debug_dec(sk);
 }
 
@@ -151,6 +155,7 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	INIT_LIST_HEAD(&smc->accept_q);
 	spin_lock_init(&smc->accept_q_lock);
 	INIT_DELAYED_WORK(&smc->sock_put_work, smc_close_sock_put_work);
+	smc_proc_sock_list_add(smc);
 
 	return sk;
 }
@@ -1326,8 +1331,16 @@ static int __init smc_init(void)
 		goto out_sock;
 	}
 
+	rc = smc_proc_init();
+	if (rc) {
+		pr_err("%s: smc_proc_init fails with %d\n", __func__, rc);
+		goto out_ibclient;
+	}
+
 	return 0;
 
+out_ibclient:
+	smc_ib_unregister_client();
 out_sock:
 	sock_unregister(PF_SMC);
 out_proto:
@@ -1350,6 +1363,7 @@ static void __exit smc_exit(void)
 		list_del_init(&lgr->list);
 		smc_lgr_free(lgr); /* free link group */
 	}
+	smc_proc_exit();
 	smc_ib_unregister_client();
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 559cd08..19b2d4d 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -155,6 +155,7 @@ struct smc_connection {
 
 struct smc_sock {				/* smc sock container */
 	struct sock		sk;
+	struct list_head	proc_list;	/* smc socket list */
 	struct socket		*clcsock;	/* internal tcp socket */
 	struct smc_connection	conn;		/* smc connection */
 	struct sockaddr		*addr;		/* inet connect address */
diff --git a/net/smc/smc_proc.c b/net/smc/smc_proc.c
new file mode 100644
index 0000000..7cee82e
--- /dev/null
+++ b/net/smc/smc_proc.c
@@ -0,0 +1,251 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Handle /proc entries for SMC sockets
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <linux/proc_fs.h>
+
+#include "smc.h"
+#include "smc_core.h"
+#include "smc_proc.h"
+
+struct smc_proc_sock_list {
+	struct list_head list;
+	rwlock_t lock;
+};
+
+static struct smc_proc_sock_list smc_proc_socket_list = {
+	.list = LIST_HEAD_INIT(smc_proc_socket_list.list),
+	.lock = __RW_LOCK_UNLOCKED(smc_proc_socket_list.lock),
+};
+
+void smc_proc_sock_list_add(struct smc_sock *smc)
+{
+	write_lock(&smc_proc_socket_list.lock);
+	list_add_tail(&smc->proc_list, &smc_proc_socket_list.list);
+	write_unlock(&smc_proc_socket_list.lock);
+}
+
+void smc_proc_sock_list_del(struct smc_sock *smc)
+{
+	if (list_empty(&smc->proc_list))
+		return;
+	write_lock(&smc_proc_socket_list.lock);
+	list_del_init(&smc->proc_list);
+	write_unlock(&smc_proc_socket_list.lock);
+}
+
+#ifdef CONFIG_PROC_FS
+
+static struct proc_dir_entry *proc_fs_smc;
+
+static int smc_proc_gid_to_hex(char *gid, char *buf, int buf_len)
+{
+	int i;
+	int j;
+
+	if (buf_len < (2 * SMC_GID_SIZE + 1))
+		return -EINVAL;
+
+	j = 0;
+	for (i = 0; i < SMC_GID_SIZE; i++) {
+		buf[j++] = hex_asc_hi(gid[i]);
+		buf[j++] = hex_asc_lo(gid[i]);
+	}
+	buf[j] = '\0';
+
+	return 0;
+}
+
+static int smc_proc_seq_show_header(struct seq_file *m)
+{
+	seq_puts(m, "state   uid inode  local_address peer_address  ");
+	seq_puts(m, "tcp target   role ");
+	seq_puts(m, "gid_peer_0                       ");
+	seq_puts(m, "gid_peer_1                       ");
+	seq_puts(m, "sndbuf   rmbe     token    peerrmb  rxprodc  rxprodw ");
+	seq_puts(m, "rxconsc  rxconsw txprodc  txprodw txconsc  txconsw ");
+	seq_puts(m, "tx_flags rx_flags");
+	seq_pad(m, '\n');
+	return 0;
+}
+
+static void *smc_proc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(smc_proc_socket_list.lock)
+{
+	read_lock(&smc_proc_socket_list.lock);
+
+	if (!*pos)
+		return SEQ_START_TOKEN;
+
+	return seq_list_start(&smc_proc_socket_list.list, *pos);
+}
+
+static void *smc_proc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	if (v == SEQ_START_TOKEN)
+		return seq_list_start(&smc_proc_socket_list.list, *pos);
+	return seq_list_next(v, &smc_proc_socket_list.list, pos);
+}
+
+static void smc_proc_seq_stop(struct seq_file *seq, void *v)
+	__releases(smc_proc_socket_list.lock)
+{
+	read_unlock(&smc_proc_socket_list.lock);
+}
+
+static int smc_proc_seq_show(struct seq_file *m, void *v)
+{
+	struct smc_sock *smc = list_entry(v, struct smc_sock, proc_list);
+	char hex_buf[2 * SMC_GID_SIZE + 1];
+	struct sockaddr_in locl_addr;
+	struct sockaddr_in peer_addr;
+	int len;
+	int rc;
+	int i;
+
+	if (v == SEQ_START_TOKEN)
+		return smc_proc_seq_show_header(m);
+
+	if (!smc)
+		return -ENOENT;
+
+	sock_hold(&smc->sk);
+
+	seq_printf(m,
+		   "%5d %5d %6ld ",
+		   smc->sk.sk_state,
+		   from_kuid_munged(seq_user_ns(m), sock_i_uid(&smc->sk)),
+		   sock_i_ino(&smc->sk));
+
+	if (smc->sk.sk_state == SMC_INIT)
+		goto out_line;
+
+	if (smc->clcsock && smc->clcsock->sk) {
+		rc = smc->clcsock->ops->getname(smc->clcsock,
+						(struct sockaddr *)&locl_addr,
+						&len, 0);
+		if (!rc)
+			seq_printf(m,
+				   "%08X:%04X ",
+				   locl_addr.sin_addr.s_addr,
+				   locl_addr.sin_port);
+		else
+			seq_printf(m, "%13s ", " ");
+	} else {
+		seq_printf(m, "%13s ", " ");
+	}
+
+	if (smc->sk.sk_state == SMC_LISTEN)
+		goto out_line;
+
+	if (smc->clcsock && smc->clcsock->sk) {
+		rc = smc->clcsock->ops->getname(smc->clcsock,
+						(struct sockaddr *)&peer_addr,
+						&len, 1);
+		if (!rc)
+			seq_printf(m,
+				   "%08X:%04X ",
+				   peer_addr.sin_addr.s_addr,
+				   peer_addr.sin_port);
+		else
+			seq_printf(m, "%-13s ", " ");
+	} else {
+		seq_printf(m, "%13s ", " ");
+	}
+
+	seq_printf(m, "%3d ",  smc->use_fallback);
+	if (smc->use_fallback)
+		goto out_line;
+
+	if (smc->conn.lgr && (smc->sk.sk_state != SMC_CLOSED)) {
+		seq_printf(m, "%08X ", smc->conn.lgr->daddr);
+		seq_printf(m, "%4d ", smc->conn.lgr->role);
+
+		for (i = 0; i < 2; i++) {
+			smc_proc_gid_to_hex(smc->conn.lgr->lnk[i].peer_gid,
+					    hex_buf, sizeof(hex_buf));
+			seq_printf(m, "%32s ", hex_buf);
+		}
+	} else {
+		seq_printf(m, "%-80s ", " ");
+	}
+
+	seq_printf(m,
+		   "%08X %08X %08X %08X ",
+		   smc->conn.sndbuf_size,
+		   smc->conn.rmbe_size,
+		   smc->conn.alert_token_local,
+		   smc->conn.peer_rmbe_len);
+	seq_printf(m,
+		   "%08X    %04X %08X    %04X ",
+		   smc->conn.local_rx_ctrl.prod.curs.count,
+		   smc->conn.local_rx_ctrl.prod.curs.wrap,
+		   smc->conn.local_rx_ctrl.cons.curs.count,
+		   smc->conn.local_rx_ctrl.cons.curs.wrap);
+	seq_printf(m,
+		   "%08X    %04X %08X    %04X  ",
+		   smc->conn.local_tx_ctrl.prod.curs.count,
+		   smc->conn.local_tx_ctrl.prod.curs.wrap,
+		   smc->conn.local_tx_ctrl.cons.curs.count,
+		   smc->conn.local_tx_ctrl.cons.curs.wrap);
+	seq_printf(m,
+		   "%02X%02X     %02X%02X     ",
+		   *(u8 *)&smc->conn.local_tx_ctrl.prod_flags,
+		   *(u8 *)&smc->conn.local_tx_ctrl.conn_state_flags,
+		   *(u8 *)&smc->conn.local_rx_ctrl.prod_flags,
+		   *(u8 *)&smc->conn.local_rx_ctrl.conn_state_flags);
+out_line:
+	seq_putc(m, '\n');
+	sock_put(&smc->sk);
+	return 0;
+}
+
+static const struct seq_operations smc_proc_seq_ops = {
+	.start = smc_proc_seq_start,
+	.next  = smc_proc_seq_next,
+	.stop  = smc_proc_seq_stop,
+	.show  = smc_proc_seq_show,
+};
+
+static int smc_proc_seq_open(struct inode *inode, struct file *filp)
+{
+	return seq_open(filp, &smc_proc_seq_ops);
+}
+
+static const struct file_operations smc_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= smc_proc_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+int __init smc_proc_init(void)
+{
+	proc_fs_smc = proc_create("smc", S_IFREG | S_IRUGO,
+				  init_net.proc_net, &smc_proc_fops);
+	return (!proc_fs_smc) ? -EFAULT : 0;
+}
+
+void smc_proc_exit(void)
+{
+	proc_remove(proc_fs_smc);
+}
+
+#else /* CONFIG_PROC_FS */
+int __init smc_proc_init(void)
+{
+	return 0;
+}
+
+void smc_proc_exit(void)
+{
+}
+
+#endif /* CONFIG_PROC_FS */
diff --git a/net/smc/smc_proc.h b/net/smc/smc_proc.h
new file mode 100644
index 0000000..d14fb30
--- /dev/null
+++ b/net/smc/smc_proc.h
@@ -0,0 +1,19 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Handle /proc entries for SMC sockets
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#ifndef SMC_PROC_H
+#define SMC_PROC_H
+
+void smc_proc_sock_list_add(struct smc_sock *);
+void smc_proc_sock_list_del(struct smc_sock *);
+int smc_proc_init(void) __init;
+void smc_proc_exit(void);
+
+#endif /* SMC_PROC_H */
-- 
2.6.6
