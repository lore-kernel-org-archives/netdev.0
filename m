From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH ethtool 2/3] ethtool: add support for external loopback.
Date: Tue, 20 Sep 2011 03:31:34 -0700
Message-ID: <1316514695-17157-3-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:52072 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab1ITKn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 06:43:27 -0400
In-Reply-To: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

External loopback will be performed in addition to other offline tests.
User need to pass new parameter "external_lb" for the same.

Reqd. man page changes included.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 ethtool.8.in |   15 +++++++++++----
 ethtool.c    |   12 ++++++++++--
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7a0bd43..efc6098 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -68,6 +68,10 @@
 .\"
 .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
 .\"
+.\"	\(*SD - Self-diag test values
+.\"
+.ds SD \fBoffline\fP|\fBonline\fP|\fBexternal_lb\fP
+.\"
 .\"	\(*NC - Network Classifier type values
 .\"
 .ds NC \fBether\fP|\fBip4\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP
@@ -227,7 +231,7 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-t|\-\-test
 .I ethX
-.B1 offline online
+.RI [\*(SD]
 .HP
 .B ethtool \-s
 .I ethX
@@ -457,12 +461,14 @@ statistics.
 .B \-t \-\-test
 Executes adapter selftest on the specified network device. Possible test modes are:
 .TP
-.A1 offline online
+.RI \*(SD
 defines test type: 
 .B offline
 (default) means to perform full set of tests possibly causing normal operation interruption during the tests,
 .B online
-means to perform limited set of tests do not interrupting normal adapter operation.
+means to perform limited set of tests do not interrupting normal adapter operation,
+.B external_lb
+means to perform external-loopback test in addition to other offline tests.
 .TP
 .B \-s \-\-change
 Allows changing some or all settings of the specified network device.
@@ -762,7 +768,8 @@ Andre Majorel,
 Eli Kupermann,
 Scott Feldman,
 Andi Kleen,
-Alexander Duyck.
+Alexander Duyck,
+Sucheta Chakraborty.
 .SH AVAILABILITY
 .B ethtool
 is available from
diff --git a/ethtool.c b/ethtool.c
index 943dfb7..d7d2d58 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -219,7 +219,7 @@ static struct option {
     { "-p", "--identify", MODE_PHYS_ID, "Show visible port identification (e.g. blinking)",
                 "               [ TIME-IN-SECONDS ]\n" },
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
-                "               [ online | offline ]\n" },
+		"               [ online | offline | external_lb ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
     { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
 		"options",
@@ -408,6 +408,7 @@ static struct ethtool_rx_flow_spec rx_rule_fs;
 static enum {
 	ONLINE=0,
 	OFFLINE,
+	EXTERNAL_LB,
 } test_type = OFFLINE;
 
 typedef enum {
@@ -811,6 +812,8 @@ static void parse_cmdline(int argc, char **argp)
 					test_type = ONLINE;
 				} else if (!strcmp(argp[i], "offline")) {
 					test_type = OFFLINE;
+				} else if (!strcmp(argp[i], "external_lb")) {
+					test_type = EXTERNAL_LB;
 				} else {
 					exit_bad_args();
 				}
@@ -1689,6 +1692,9 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
 
 	rc = test->flags & ETH_TEST_FL_FAILED;
 	fprintf(stdout, "The test result is %s\n", rc ? "FAIL" : "PASS");
+	fprintf(stdout, "External loopback test is %s\n",
+		test->flags & ETH_TEST_FL_EXTERNAL_LB_DONE ? "executed" :
+							"not executed");
 
 	if (info->testinfo_len)
 		fprintf(stdout, "The test extra info:\n");
@@ -2749,7 +2755,9 @@ static int do_test(int fd, struct ifreq *ifr)
 	memset (test->data, 0, drvinfo.testinfo_len * sizeof(u64));
 	test->cmd = ETHTOOL_TEST;
 	test->len = drvinfo.testinfo_len;
-	if (test_type == OFFLINE)
+	if (test_type == EXTERNAL_LB)
+		test->flags = (ETH_TEST_FL_OFFLINE | ETH_TEST_FL_EXTERNAL_LB);
+	else if (test_type == OFFLINE)
 		test->flags = ETH_TEST_FL_OFFLINE;
 	else
 		test->flags = 0;
-- 
1.6.3.3
