From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 3/5] net-timestamp: no-payload option in txtimestamp test
Date: Fri,  9 Jan 2015 12:31:57 -0500
Message-ID: <1420824719-28848-4-git-send-email-willemb@google.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:62643 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776AbbAIRcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:08 -0500
Received: by mail-yh0-f50.google.com with SMTP id b6so4704365yha.9
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:07 -0800 (PST)
In-Reply-To: <1420824719-28848-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Demonstrate how SOF_TIMESTAMPING_OPT_TSONLY can be used and
test the implementation.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 .../networking/timestamping/txtimestamp.c          | 28 ++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index 8778e68..1171ebf 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -68,6 +68,7 @@ static int do_ipv6 = 1;
 static int cfg_payload_len = 10;
 static bool cfg_show_payload;
 static bool cfg_do_pktinfo;
+static bool cfg_loop_nodata;
 static uint16_t dest_port = 9000;
 
 static struct sockaddr_in daddr;
@@ -139,6 +140,9 @@ static void print_payload(char *data, int len)
 {
 	int i;
 
+	if (!len)
+		return;
+
 	if (len > 70)
 		len = 70;
 
@@ -175,6 +179,7 @@ static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
 	struct sock_extended_err *serr = NULL;
 	struct scm_timestamping *tss = NULL;
 	struct cmsghdr *cm;
+	int batch = 0;
 
 	for (cm = CMSG_FIRSTHDR(msg);
 	     cm && cm->cmsg_len;
@@ -207,10 +212,18 @@ static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
 		} else
 			fprintf(stderr, "unknown cmsg %d,%d\n",
 					cm->cmsg_level, cm->cmsg_type);
+
+		if (serr && tss) {
+			print_timestamp(tss, serr->ee_info, serr->ee_data,
+					payload_len);
+			serr = NULL;
+			tss = NULL;
+			batch++;
+		}
 	}
 
-	if (serr && tss)
-		print_timestamp(tss, serr->ee_info, serr->ee_data, payload_len);
+	if (batch > 1)
+		fprintf(stderr, "batched %d timestamps\n", batch);
 }
 
 static int recv_errmsg(int fd)
@@ -242,7 +255,7 @@ static int recv_errmsg(int fd)
 	if (ret == -1 && errno != EAGAIN)
 		error(1, errno, "recvmsg");
 
-	if (ret > 0) {
+	if (ret >= 0) {
 		__recv_errmsg_cmsg(&msg, ret);
 		if (cfg_show_payload)
 			print_payload(data, cfg_payload_len);
@@ -307,6 +320,9 @@ static void do_test(int family, unsigned int opt)
 	opt |= SOF_TIMESTAMPING_SOFTWARE |
 	       SOF_TIMESTAMPING_OPT_CMSG |
 	       SOF_TIMESTAMPING_OPT_ID;
+	if (cfg_loop_nodata)
+		opt |= SOF_TIMESTAMPING_OPT_TSONLY;
+
 	if (setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING,
 		       (char *) &opt, sizeof(opt)))
 		error(1, 0, "setsockopt timestamping");
@@ -376,6 +392,7 @@ static void __attribute__((noreturn)) usage(const char *filepath)
 			"  -h:   show this message\n"
 			"  -I:   request PKTINFO\n"
 			"  -l N: send N bytes at a time\n"
+			"  -n:   set no-payload option\n"
 			"  -r:   use raw\n"
 			"  -R:   use raw (IP_HDRINCL)\n"
 			"  -p N: connect to port N\n"
@@ -390,7 +407,7 @@ static void parse_opt(int argc, char **argv)
 	int proto_count = 0;
 	char c;
 
-	while ((c = getopt(argc, argv, "46hIl:p:rRux")) != -1) {
+	while ((c = getopt(argc, argv, "46hIl:np:rRux")) != -1) {
 		switch (c) {
 		case '4':
 			do_ipv6 = 0;
@@ -401,6 +418,9 @@ static void parse_opt(int argc, char **argv)
 		case 'I':
 			cfg_do_pktinfo = true;
 			break;
+		case 'n':
+			cfg_loop_nodata = true;
+			break;
 		case 'r':
 			proto_count++;
 			cfg_proto = SOCK_RAW;
-- 
2.2.0.rc0.207.ga3a616c
