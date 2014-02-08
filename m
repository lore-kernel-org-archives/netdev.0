From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 8 Feb 2014 22:36:08 +0100
Message-ID: <20140208213608.GA24328@glanzmann.de>
References: <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208141905.GG20512@glanzmann.de>
 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208165732.GB22359@glanzmann.de>
 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208171531.GA23798@glanzmann.de>
 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> I was simply thinking about something like :
> (might need further changes, but I guess this should solve your case)

thank you for your patch. It did not apply on top of Linux tip, so I put
in the changes manually and fixed up another call to tx_data that your
forgot in your initial patch to make it apply.

I gave it another run, can you confirm that it now behaves better?

https://thomas.glanzmann.de/tmp/tcp_auto_corking_on_patched_tcp_more.pcap.bz2

And look at that roundtrip graph it is perfect. Also filesystem is now
created in 3 seconds instead of 4.

https://thomas.glanzmann.de/tmp/screenshot-mini-2014-02-08-22:34:57.png

Nab, do you consider this patch for upstream? Would you take if I clean
it up?

Cheers,
        Thomas

PS: I'm asleep for the next 8 hours.

diff --git a/drivers/target/iscsi/iscsi_target_util.c b/drivers/target/iscsi/iscsi_target_util.c
index e655b04..0eb9681 100644
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
+        tx_sent = tx_data(conn, &iov, 1, tx_hdr_size, data_len ? MSG_MORE : 0);
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
+			          conn->conn_ops->DataDigest ? MSG_MORE : 0);
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
@@ -1352,11 +1353,13 @@ static int iscsit_do_rx_data(
 
 static int iscsit_do_tx_data(
 	struct iscsi_conn *conn,
-	struct iscsi_data_count *count)
+	struct iscsi_data_count *count,
+	int flags)
 {
 	int data = count->data_length, total_tx = 0, tx_loop = 0, iov_len;
 	struct kvec *iov_p;
 	struct msghdr msg;
+        struct msghdr msg = { .msg_flags = flags };
 
 	if (!conn || !conn->sock || !conn->conn_ops)
 		return -1;
@@ -1366,8 +1369,6 @@ static int iscsit_do_tx_data(
 		return -1;
 	}
 
-	memset(&msg, 0, sizeof(struct msghdr));
-
 	iov_p = count->iov;
 	iov_len = count->iov_count;
 
@@ -1411,7 +1412,8 @@ int tx_data(
 	struct iscsi_conn *conn,
 	struct kvec *iov,
 	int iov_count,
-	int data)
+	int data,
+	int flags)
 {
 	struct iscsi_data_count c;
 
@@ -1424,7 +1426,7 @@ int tx_data(
 	c.data_length = data;
 	c.type = ISCSI_TX_DATA;
 
-	return iscsit_do_tx_data(conn, &c);
+	return iscsit_do_tx_data(conn, &c, flags);
 }
