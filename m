From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 36/40] iscsi: fixup of the ep_connect patch
Date: Fri, 04 May 2007 12:27:27 +0200
Message-ID: <20070504103203.911980306@chello.nl>
References: <20070504102651.923946304@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031366AbXEDKol@vger.kernel.org>
Content-Disposition: inline; filename=iscsi_ep_connect_fix.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure a malicious user-space program cannot crash the kernel module
by prematurely closing the filedesc.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/iscsi_tcp.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

Index: linux-2.6-git/drivers/scsi/iscsi_tcp.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/iscsi_tcp.c	2007-01-16 14:15:50.000000000 +0100
+++ linux-2.6-git/drivers/scsi/iscsi_tcp.c	2007-01-16 14:24:05.000000000 +0100
@@ -1830,11 +1830,25 @@ tcp_conn_alloc_fail:
 }
 
 static void
+iscsi_tcp_release_conn(struct iscsi_conn *conn)
+{
+	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
+
+	if (!tcp_conn->sock)
+		return;
+
+	sockfd_put(tcp_conn->sock);
+	tcp_conn->sock = NULL;
+	conn->recv_lock = NULL;
+}
+
+static void
 iscsi_tcp_conn_destroy(struct iscsi_cls_conn *cls_conn)
 {
 	struct iscsi_conn *conn = cls_conn->dd_data;
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 
+	iscsi_tcp_release_conn(conn);
 	iscsi_conn_teardown(cls_conn);
 	if (tcp_conn->tx_hash.tfm)
 		crypto_free_hash(tcp_conn->tx_hash.tfm);
@@ -1851,6 +1865,7 @@ iscsi_tcp_conn_stop(struct iscsi_cls_con
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 
 	iscsi_conn_stop(cls_conn, flag);
+	iscsi_tcp_release_conn(conn);
 	tcp_conn->hdr_size = sizeof(struct iscsi_hdr);
 }
 
@@ -1873,8 +1888,10 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 	}
 
 	err = iscsi_conn_bind(cls_session, cls_conn, is_leading, transport_eph);
-	if (err)
-		goto done;
+	if (err) {
+		sockfd_put(sock);
+		return err;
+	}
 
 	/* bind iSCSI connection and socket */
 	tcp_conn->sock = sock;
@@ -1898,8 +1915,6 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 	 */
 	tcp_conn->in_progress = IN_PROGRESS_WAIT_HEADER;
 
-done:
-	sockfd_put(sock);
 	return err;
 }
 

--
