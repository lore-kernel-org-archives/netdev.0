From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] This extends tx_data and and iscsit_do_tx_data with the
 additional parameter flags and avoids sending multiple TCP packets in
 iscsit_fe_sendpage_sg
Date: Sun, 09 Feb 2014 04:30:39 -0800
Message-ID: <1391949039.10160.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208141905.GG20512@glanzmann.de>
	 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208150001.GI20512@glanzmann.de>
	 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208165732.GB22359@glanzmann.de>
	 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208171531.GA23798@glanzmann.de>
	 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140209074027.GA8105@glanzmann.de> <20140209074227.GA8219@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, thomas@glanzmann.de
To: John Ogness <john.ogness@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:58113 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbaBIMal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 07:30:41 -0500
In-Reply-To: <20140209074227.GA8219@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-09 at 08:42 +0100, Eric Dumazet wrote:
> The new infrastructure is used in iscsit_fe_sendpage_sg to avoid sending three
> TCP packets instead of one by settings the MSG_MORE when calling kernel_sendmsg
> via the wrapper functions tx_data and iscsit_do_tx_data. This reduces the TCP
> overhead by sending the same data in less TCP packets and minimized the TCP RTP
> when TCP auto corking is enabled. When creating a 500 GB VMFS filesystem the
> filesystem is created in 3 seconds instead of 4 seconds.
> 
> Signed-off-by: Thomas Glanzmann <thomas@glanzmann.de>
> X-tested-by: Thomas Glanzmann <thomas@glanzmann.de>
> ---

Hmm, thanks but this is not how to do this.

When you submit a patch written by someone else, you should :

1) Use your own identity as the sender, not impersonate me.
( thats standard convention )

2) Put following line as first line of the mail
( Documentation/SubmittingPatches lines ~565)

From: Eric Dumazet <edumazet@google.com>

Then I'll add my :
Signed-off-by: Eric Dumazet <edumazet@google.com>

Anyway, patch is not yet complete : We also want to set
MSG_MORE/MSG_SENDPAGE_NOTLAST for all pages but last one in a sg list.


This will fix suboptimal traffic :

13:32:04.976923 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 289953:292849, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
13:32:04.976936 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 292849:295745, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
13:32:04.976944 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 295745:298193, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2448
13:32:04.976952 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 298193:301089, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
13:32:04.976960 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 301089:303985, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
13:32:04.976998 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 303985:306385, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2400

Please try following updated patch, thanks !

Once tested, we'll submit it formally.

 drivers/target/iscsi/iscsi_target_parameters.c |    2 
 drivers/target/iscsi/iscsi_target_util.c       |   38 +++++++++------
 drivers/target/iscsi/iscsi_target_util.h       |    2 
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target_parameters.c b/drivers/target/iscsi/iscsi_target_parameters.c
index 4d2e23fc76fd..b80239250a1c 100644
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
index 0819e688a398..3c529f7c61ce 100644
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
+	tx_sent = tx_data(conn, &iov, 1, tx_hdr_size,
+			  cmd->tx_size != tx_hdr_size ? MSG_MORE : 0);
 	if (tx_hdr_size != tx_sent) {
 		if (tx_sent == -EAGAIN) {
 			pr_err("tx_data() returned -EAGAIN\n");
@@ -1225,18 +1226,24 @@ send_hdr:
 	while (data_len) {
 		u32 space = (sg->length - offset);
 		u32 sub_len = min_t(u32, data_len, space);
+		int flags = 0;
+	
+		if ((data_len != sub_len) || cmd->padding ||
+		    conn->conn_ops->DataDigest)
+			flags = MSG_SENDPAGE_NOTLAST | MSG_MORE;
+
 send_pg:
 		tx_sent = conn->sock->ops->sendpage(conn->sock,
-					sg_page(sg), sg->offset + offset, sub_len, 0);
+						    sg_page(sg),
+						    sg->offset + offset,
+						    sub_len, flags);
 		if (tx_sent != sub_len) {
 			if (tx_sent == -EAGAIN) {
-				pr_err("tcp_sendpage() returned"
-						" -EAGAIN\n");
+				pr_err("tcp_sendpage() returned -EAGAIN\n");
 				goto send_pg;
 			}
 
-			pr_err("tcp_sendpage() failure: %d\n",
-					tx_sent);
+			pr_err("tcp_sendpage() failure: %d\n", tx_sent);
 			return -1;
 		}
 
@@ -1249,7 +1256,8 @@ send_padding:
 	if (cmd->padding) {
 		struct kvec *iov_p = &cmd->iov_data[iov_off++];
 
-		tx_sent = tx_data(conn, iov_p, 1, cmd->padding);
+		tx_sent = tx_data(conn, iov_p, 1, cmd->padding,
+				  conn->conn_ops->DataDigest ? MSG_MORE : 0);
 		if (cmd->padding != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1263,7 +1271,7 @@ send_datacrc:
 	if (conn->conn_ops->DataDigest) {
 		struct kvec *iov_d = &cmd->iov_data[iov_off];
 
-		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN);
+		tx_sent = tx_data(conn, iov_d, 1, ISCSI_CRC_LEN, 0);
 		if (ISCSI_CRC_LEN != tx_sent) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tx_data() returned -EAGAIN\n");
@@ -1349,11 +1357,12 @@ static int iscsit_do_rx_data(
 
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
@@ -1363,8 +1372,6 @@ static int iscsit_do_tx_data(
 		return -1;
 	}
 
-	memset(&msg, 0, sizeof(struct msghdr));
-
 	iov_p = count->iov;
 	iov_len = count->iov_count;
 
@@ -1408,7 +1415,8 @@ int tx_data(
 	struct iscsi_conn *conn,
 	struct kvec *iov,
 	int iov_count,
-	int data)
+	int data,
+	int flags)
 {
 	struct iscsi_data_count c;
 
@@ -1421,7 +1429,7 @@ int tx_data(
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
 
