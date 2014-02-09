From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] This extends tx_data and and iscsit_do_tx_data with the
 additional parameter flags and avoids sending multiple TCP packets in
 iscsit_fe_sendpage_sg
Date: Sun, 9 Feb 2014 08:42:27 +0100
Message-ID: <20140209074227.GA8219@glanzmann.de>
References: <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208141905.GG20512@glanzmann.de>
 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208165732.GB22359@glanzmann.de>
 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208171531.GA23798@glanzmann.de>
 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209074027.GA8105@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, thomas@glanzmann.de
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140209074027.GA8105@glanzmann.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new infrastructure is used in iscsit_fe_sendpage_sg to avoid sending three
TCP packets instead of one by settings the MSG_MORE when calling kernel_sendmsg
via the wrapper functions tx_data and iscsit_do_tx_data. This reduces the TCP
overhead by sending the same data in less TCP packets and minimized the TCP RTP
when TCP auto corking is enabled. When creating a 500 GB VMFS filesystem the
filesystem is created in 3 seconds instead of 4 seconds.

Signed-off-by: Thomas Glanzmann <thomas@glanzmann.de>
X-tested-by: Thomas Glanzmann <thomas@glanzmann.de>
---
 drivers/target/iscsi/iscsi_target_parameters.c |    2 +-
 drivers/target/iscsi/iscsi_target_util.c       |   23 ++++++++++++-----------
 drivers/target/iscsi/iscsi_target_util.h       |    2 +-
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target_parameters.c b/drivers/target/iscsi/iscsi_target_parameters.c
index 4d2e23f..b802392 100644
--- a/drivers/target/iscsi/iscsi_target_parameters.c
+++ b/drivers/target/iscsi/iscsi_target_parameters.c
@@ -79,7 +79,7 @@ int iscsi_login_tx_data(
 	 */
 	conn->if_marker += length;
 
-	tx_sent = tx_data(conn, &iov[0], iov_cnt, length);
+	tx_sent = tx_data(conn, &iov[0], iov_cnt, length, 0);
 	if (tx_sent != length) {
 		pr_err("tx_data returned %d, expecting %d.\n",
 				tx_sent, length);
diff --git a/drivers/target/iscsi/iscsi_target_util.c b/drivers/target/iscsi/iscsi_target_util.c
index e655b04..887fabb 100644
--- a/drivers/target/iscsi/iscsi_target_util.c
+++ b/drivers/target/iscsi/iscsi_target_util.c
@@ -1168,7 +1168,7 @@ send_data:
 		iov_count = cmd->iov_misc_count;
 	}
 
-	tx_sent = tx_data(conn, &iov[0], iov_count, tx_size);
+	tx_sent = tx_data(conn, &iov[0], iov_count, tx_size, 0);
 	if (tx_size != tx_sent) {
 		if (tx_sent == -EAGAIN) {
 			pr_err("tx_data() returned -EAGAIN\n");
@@ -1199,7 +1199,8 @@ send_hdr:
 	iov.iov_base = cmd->pdu;
 	iov.iov_len = tx_hdr_size;
 
-	tx_sent = tx_data(conn, &iov, 1, tx_hdr_size);
+	data_len = cmd->tx_size - tx_hdr_size - cmd->padding;
+	tx_sent = tx_data(conn, &iov, 1, tx_hdr_size, data_len ? MSG_MORE : 0);
 	if (tx_hdr_size != tx_sent) {
 		if (tx_sent == -EAGAIN) {
 			pr_err("tx_data() returned -EAGAIN\n");
@@ -1208,7 +1209,6 @@ send_hdr:
 		return -1;
 	}
 
-	data_len = cmd->tx_size - tx_hdr_size - cmd->padding;
 	/*
 	 * Set iov_off used by padding and data digest tx_data() calls below
 	 * in order to determine proper offset into cmd->iov_data[]
@@ -1252,7 +1252,8 @@ send_padding:
 	if (cmd->padding) {
 		struct kvec *iov_p = &cmd->iov_data[iov_off++];
 
-		tx_sent = tx_data(conn, iov_p, 1, cmd->padding);
+		tx_sent = tx_data(conn, iov_p, 1, cmd->padding,
+				  conn->conn_ops->DataDigest ? MSG_MORE : 0);
 		if (cmd->padding != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1266,7 +1267,7 @@ send_datacrc:
 	if (conn->conn_ops->DataDigest) {
 		struct kvec *iov_d = &cmd->iov_data[iov_off];
 
-		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN);
+		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN, 0);
 		if (ISCSI_CRC_LEN != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1352,11 +1353,12 @@ static int iscsit_do_rx_data(
 
 static int iscsit_do_tx_data(
 	struct iscsi_conn *conn,
-	struct iscsi_data_count *count)
+	struct iscsi_data_count *count,
+	int flags)
 {
 	int data = count->data_length, total_tx = 0, tx_loop = 0, iov_len;
 	struct kvec *iov_p;
-	struct msghdr msg;
+        struct msghdr msg = { .msg_flags = flags };
 
 	if (!conn || !conn->sock || !conn->conn_ops)
 		return -1;
@@ -1366,8 +1368,6 @@ static int iscsit_do_tx_data(
 		return -1;
 	}
 
-	memset(&msg, 0, sizeof(struct msghdr));
-
 	iov_p = count->iov;
 	iov_len = count->iov_count;
 
@@ -1411,7 +1411,8 @@ int tx_data(
 	struct iscsi_conn *conn,
 	struct kvec *iov,
 	int iov_count,
-	int data)
+	int data,
+	int flags)
 {
 	struct iscsi_data_count c;
 
@@ -1424,7 +1425,7 @@ int tx_data(
 	c.data_length = data;
 	c.type = ISCSI_TX_DATA;
 
-	return iscsit_do_tx_data(conn, &c);
+	return iscsit_do_tx_data(conn, &c, flags);
 }
 
 void iscsit_collect_login_stats(
diff --git a/drivers/target/iscsi/iscsi_target_util.h b/drivers/target/iscsi/iscsi_target_util.h
index 561a424..1b6b336 100644
--- a/drivers/target/iscsi/iscsi_target_util.h
+++ b/drivers/target/iscsi/iscsi_target_util.h
@@ -54,7 +54,7 @@ extern int iscsit_print_dev_to_proc(char *, char **, off_t, int);
 extern int iscsit_print_sessions_to_proc(char *, char **, off_t, int);
 extern int iscsit_print_tpg_to_proc(char *, char **, off_t, int);
 extern int rx_data(struct iscsi_conn *, struct kvec *, int, int);
-extern int tx_data(struct iscsi_conn *, struct kvec *, int, int);
+extern int tx_data(struct iscsi_conn *, struct kvec *, int, int, int);
 extern void iscsit_collect_login_stats(struct iscsi_conn *, u8, u8);
 extern struct iscsi_tiqn *iscsit_snmp_get_tiqn(struct iscsi_conn *);
 
-- 
1.7.10.4
