From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Crash in tun
Date: Sat, 21 Jul 2012 08:55:18 +0100
Message-ID: <20120721075518.GY31729@ZenIV.linux.org.uk>
References: <alpine.DEB.2.00.1207190213001.16299@artax.karlin.mff.cuni.cz>
 <1342678175.2626.3849.camel@edumazet-glaptop>
 <alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz>
 <20120720.112337.474955511809249636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mikulas@artax.karlin.mff.cuni.cz, eric.dumazet@gmail.com,
	maxk@qualcomm.com, vtun@office.satix.net, netdev@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36266 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab2GUHza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 03:55:30 -0400
Content-Disposition: inline
In-Reply-To: <20120720.112337.474955511809249636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	BTW, speaking of struct file treatment related to sockets -
there's this piece of code in iscsi:
        /*
         * The SCTP stack needs struct socket->file.
         */
        if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
            (np->np_network_transport == ISCSI_SCTP_UDP)) {
                if (!new_sock->file) {
                        new_sock->file = kzalloc(
                                        sizeof(struct file), GFP_KERNEL);

For one thing, as far as I can see it'not true - sctp does *not* depend on
socket->file being non-NULL; it does, in one place, check socket->file->f_flags
for O_NONBLOCK, but there it treats NULL socket->file as "flag not set".
Which is the case here anyway - the fake struct file created in
__iscsi_target_login_thread() (and in iscsi_target_setup_login_socket(), with
the same excuse) do *not* get that flag set.

Moreover, it's a bloody serious violation of a bunch of asserts in VFS;
all struct file instances should come from filp_cachep, via get_empty_filp()
(or alloc_file(), which is a wrapper for it).  FWIW, I'm very tempted to
do this and be done with the entire mess:

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/drivers/target/iscsi/iscsi_target.c b/drivers/target/iscsi/iscsi_target.c
index d57d10c..d7dcd67 100644
--- a/drivers/target/iscsi/iscsi_target.c
+++ b/drivers/target/iscsi/iscsi_target.c
@@ -429,19 +429,8 @@ int iscsit_reset_np_thread(
 
 int iscsit_del_np_comm(struct iscsi_np *np)
 {
-	if (!np->np_socket)
-		return 0;
-
-	/*
-	 * Some network transports allocate their own struct sock->file,
-	 * see  if we need to free any additional allocated resources.
-	 */
-	if (np->np_flags & NPF_SCTP_STRUCT_FILE) {
-		kfree(np->np_socket->file);
-		np->np_socket->file = NULL;
-	}
-
-	sock_release(np->np_socket);
+	if (np->np_socket)
+		sock_release(np->np_socket);
 	return 0;
 }
 
@@ -4077,13 +4066,8 @@ int iscsit_close_connection(
 	kfree(conn->conn_ops);
 	conn->conn_ops = NULL;
 
-	if (conn->sock) {
-		if (conn->conn_flags & CONNFLAG_SCTP_STRUCT_FILE) {
-			kfree(conn->sock->file);
-			conn->sock->file = NULL;
-		}
+	if (conn->sock)
 		sock_release(conn->sock);
-	}
 	conn->thread_set = NULL;
 
 	pr_debug("Moving to TARG_CONN_STATE_FREE.\n");
diff --git a/drivers/target/iscsi/iscsi_target_core.h b/drivers/target/iscsi/iscsi_target_core.h
index 1c70144..1dd5716 100644
--- a/drivers/target/iscsi/iscsi_target_core.h
+++ b/drivers/target/iscsi/iscsi_target_core.h
@@ -224,7 +224,6 @@ enum iscsi_timer_flags_table {
 /* Used for struct iscsi_np->np_flags */
 enum np_flags_table {
 	NPF_IP_NETWORK		= 0x00,
-	NPF_SCTP_STRUCT_FILE	= 0x01 /* Bugfix */
 };
 
 /* Used for struct iscsi_np->np_thread_state */
@@ -503,7 +502,6 @@ struct iscsi_conn {
 	u16			local_port;
 	int			net_size;
 	u32			auth_id;
-#define CONNFLAG_SCTP_STRUCT_FILE			0x01
 	u32			conn_flags;
 	/* Used for iscsi_tx_login_rsp() */
 	u32			login_itt;
diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index a3656c9..ae30424 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -795,22 +795,6 @@ int iscsi_target_setup_login_socket(
 	}
 	np->np_socket = sock;
 	/*
-	 * The SCTP stack needs struct socket->file.
-	 */
-	if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
-	    (np->np_network_transport == ISCSI_SCTP_UDP)) {
-		if (!sock->file) {
-			sock->file = kzalloc(sizeof(struct file), GFP_KERNEL);
-			if (!sock->file) {
-				pr_err("Unable to allocate struct"
-						" file for SCTP\n");
-				ret = -ENOMEM;
-				goto fail;
-			}
-			np->np_flags |= NPF_SCTP_STRUCT_FILE;
-		}
-	}
-	/*
 	 * Setup the np->np_sockaddr from the passed sockaddr setup
 	 * in iscsi_target_configfs.c code..
 	 */
@@ -869,21 +853,15 @@ int iscsi_target_setup_login_socket(
 
 fail:
 	np->np_socket = NULL;
-	if (sock) {
-		if (np->np_flags & NPF_SCTP_STRUCT_FILE) {
-			kfree(sock->file);
-			sock->file = NULL;
-		}
-
+	if (sock)
 		sock_release(sock);
-	}
 	return ret;
 }
 
 static int __iscsi_target_login_thread(struct iscsi_np *np)
 {
 	u8 buffer[ISCSI_HDR_LEN], iscsi_opcode, zero_tsih = 0;
-	int err, ret = 0, set_sctp_conn_flag, stop;
+	int err, ret = 0, stop;
 	struct iscsi_conn *conn = NULL;
 	struct iscsi_login *login;
 	struct iscsi_portal_group *tpg = NULL;
@@ -894,7 +872,6 @@ static int __iscsi_target_login_thread(struct iscsi_np *np)
 	struct sockaddr_in6 sock_in6;
 
 	flush_signals(current);
-	set_sctp_conn_flag = 0;
 	sock = np->np_socket;
 
 	spin_lock_bh(&np->np_thread_lock);
@@ -917,35 +894,12 @@ static int __iscsi_target_login_thread(struct iscsi_np *np)
 		spin_unlock_bh(&np->np_thread_lock);
 		goto out;
 	}
-	/*
-	 * The SCTP stack needs struct socket->file.
-	 */
-	if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
-	    (np->np_network_transport == ISCSI_SCTP_UDP)) {
-		if (!new_sock->file) {
-			new_sock->file = kzalloc(
-					sizeof(struct file), GFP_KERNEL);
-			if (!new_sock->file) {
-				pr_err("Unable to allocate struct"
-						" file for SCTP\n");
-				sock_release(new_sock);
-				/* Get another socket */
-				return 1;
-			}
-			set_sctp_conn_flag = 1;
-		}
-	}
-
 	iscsi_start_login_thread_timer(np);
 
 	conn = kzalloc(sizeof(struct iscsi_conn), GFP_KERNEL);
 	if (!conn) {
 		pr_err("Could not allocate memory for"
 			" new connection\n");
-		if (set_sctp_conn_flag) {
-			kfree(new_sock->file);
-			new_sock->file = NULL;
-		}
 		sock_release(new_sock);
 		/* Get another socket */
 		return 1;
@@ -955,9 +909,6 @@ static int __iscsi_target_login_thread(struct iscsi_np *np)
 	conn->conn_state = TARG_CONN_STATE_FREE;
 	conn->sock = new_sock;
 
-	if (set_sctp_conn_flag)
-		conn->conn_flags |= CONNFLAG_SCTP_STRUCT_FILE;
-
 	pr_debug("Moving to TARG_CONN_STATE_XPT_UP.\n");
 	conn->conn_state = TARG_CONN_STATE_XPT_UP;
 
@@ -1205,13 +1156,8 @@ old_sess_out:
 		iscsi_release_param_list(conn->param_list);
 		conn->param_list = NULL;
 	}
-	if (conn->sock) {
-		if (conn->conn_flags & CONNFLAG_SCTP_STRUCT_FILE) {
-			kfree(conn->sock->file);
-			conn->sock->file = NULL;
-		}
+	if (conn->sock)
 		sock_release(conn->sock);
-	}
 	kfree(conn);
 
 	if (tpg) {
