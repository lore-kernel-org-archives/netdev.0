From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 11:12:39 -0800
Message-ID: <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391866389.10160.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208141905.GG20512@glanzmann.de>
	 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208150001.GI20512@glanzmann.de>
	 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208165732.GB22359@glanzmann.de>
	 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208171531.GA23798@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140208171531.GA23798@glanzmann.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-08 at 18:15 +0100, Thomas Glanzmann wrote:

> The iSCSI target uses one function to send all outbound data. So in
> order to do it right every function that is sending data in multiple
> chunks need to mark it correctly. Of course someone could also do some
> wild guessing and saying that everything that is below 512 Bytes gets
> pushed out. I wonder what Nab has to say about this?

I was simply thinking about something like :
(might need further changes, but I guess this should solve your case)

diff --git a/drivers/target/iscsi/iscsi_target_util.c b/drivers/target/iscsi/iscsi_target_util.c
index 0819e688a398..44f0d62a88d6 100644
--- a/drivers/target/iscsi/iscsi_target_util.c
+++ b/drivers/target/iscsi/iscsi_target_util.c
@@ -1165,7 +1165,7 @@ send_data:
 		iov_count = cmd->iov_misc_count;
 	}
 
-	tx_sent = tx_data(conn, &iov[0], iov_count, tx_size);
+	tx_sent = tx_data(conn, &iov[0], iov_count, tx_size, 0);
 	if (tx_size != tx_sent) {
 		if (tx_sent == -EAGAIN) {
 			pr_err("tx_data() returned -EAGAIN\n");
@@ -1196,7 +1196,8 @@ send_hdr:
 	iov.iov_base = cmd->pdu;
 	iov.iov_len = tx_hdr_size;
 
-	tx_sent = tx_data(conn, &iov, 1, tx_hdr_size);
+	data_len = cmd->tx_size - tx_hdr_size - cmd->padding;
+	tx_sent = tx_data(conn, &iov, 1, tx_hdr_size, data_len ? MSG_MORE : 0);
 	if (tx_hdr_size != tx_sent) {
 		if (tx_sent == -EAGAIN) {
 			pr_err("tx_data() returned -EAGAIN\n");
@@ -1205,7 +1206,6 @@ send_hdr:
 		return -1;
 	}
 
-	data_len = cmd->tx_size - tx_hdr_size - cmd->padding;
 	/*
 	 * Set iov_off used by padding and data digest tx_data() calls below
 	 * in order to determine proper offset into cmd->iov_data[]
@@ -1249,7 +1249,8 @@ send_padding:
 	if (cmd->padding) {
 		struct kvec *iov_p = &cmd->iov_data[iov_off++];
 
-		tx_sent = tx_data(conn, iov_p, 1, cmd->padding);
+		tx_sent = tx_data(conn, iov_p, 1, cmd->padding,
+				  conn->conn_ops->DataDigest ? MSG_MORE : 0);
 		if (cmd->padding != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1263,7 +1264,7 @@ send_datacrc:
 	if (conn->conn_ops->DataDigest) {
 		struct kvec *iov_d = &cmd->iov_data[iov_off];
 
-		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN);
+		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN, 0);
 		if (ISCSI_CRC_LEN != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1349,11 +1350,12 @@ static int iscsit_do_rx_data(
 
 static int iscsit_do_tx_data(
 	struct iscsi_conn *conn,
-	struct iscsi_data_count *count)
+	struct iscsi_data_count *count,
+	int flags)
 {
 	int data = count->data_length, total_tx = 0, tx_loop = 0, iov_len;
 	struct kvec *iov_p;
-	struct msghdr msg;
+	struct msghdr msg = { .msg_flags = flags };
 
 	if (!conn || !conn->sock || !conn->conn_ops)
 		return -1;
@@ -1363,8 +1365,6 @@ static int iscsit_do_tx_data(
 		return -1;
 	}
 
-	memset(&msg, 0, sizeof(struct msghdr));
-
 	iov_p = count->iov;
 	iov_len = count->iov_count;
 
@@ -1408,7 +1408,8 @@ int tx_data(
 	struct iscsi_conn *conn,
 	struct kvec *iov,
 	int iov_count,
-	int data)
+	int data,
+	int flags)
 {
 	struct iscsi_data_count c;
 
@@ -1421,7 +1422,7 @@ int tx_data(
 	c.data_length = data;
 	c.type = ISCSI_TX_DATA;
 
-	return iscsit_do_tx_data(conn, &c);
+	return iscsit_do_tx_data(conn, &c, flags);
 }
 
 void iscsit_collect_login_stats(
diff --git a/drivers/target/iscsi/iscsi_target_util.h b/drivers/target/iscsi/iscsi_target_util.h
index e4fc34a02f57..1b4f06801adc 100644
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
 
