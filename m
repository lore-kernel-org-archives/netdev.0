From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Move tc related tests to testsuite/tests/tc folder
Date: Fri, 31 Oct 2014 10:03:44 +0200
Message-ID: <1414742624-1469-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:40179 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756218AbaJaIMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 04:12:53 -0400
Received: by mail-wg0-f43.google.com with SMTP id y10so2969378wgg.30
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 01:12:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this change the results of tc tests will be recorded under:

    testsuite/results/tc/

The ip related tests can be added under:

    testsuite/tests/ip

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/tests/cbq.t            | 10 ------
 testsuite/tests/cls-testbed.t    | 73 ----------------------------------------
 testsuite/tests/dsmark.t         | 31 -----------------
 testsuite/tests/policer.t        | 13 -------
 testsuite/tests/tc/cbq.t         | 10 ++++++
 testsuite/tests/tc/cls-testbed.t | 73 ++++++++++++++++++++++++++++++++++++++++
 testsuite/tests/tc/dsmark.t      | 31 +++++++++++++++++
 testsuite/tests/tc/policer.t     | 13 +++++++
 8 files changed, 127 insertions(+), 127 deletions(-)
 delete mode 100755 testsuite/tests/cbq.t
 delete mode 100755 testsuite/tests/cls-testbed.t
 delete mode 100755 testsuite/tests/dsmark.t
 delete mode 100755 testsuite/tests/policer.t
 create mode 100755 testsuite/tests/tc/cbq.t
 create mode 100755 testsuite/tests/tc/cls-testbed.t
 create mode 100755 testsuite/tests/tc/dsmark.t
 create mode 100755 testsuite/tests/tc/policer.t

diff --git a/testsuite/tests/cbq.t b/testsuite/tests/cbq.t
deleted file mode 100755
index bff814b..0000000
--- a/testsuite/tests/cbq.t
+++ /dev/null
@@ -1,10 +0,0 @@
-#!/bin/sh
-$TC qdisc del dev $DEV root >/dev/null 2>&1
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC qdisc list dev $DEV
-$TC qdisc del dev $DEV root
-$TC qdisc list dev $DEV
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC qdisc del dev $DEV root
diff --git a/testsuite/tests/cls-testbed.t b/testsuite/tests/cls-testbed.t
deleted file mode 100755
index 2afc26f..0000000
--- a/testsuite/tests/cls-testbed.t
+++ /dev/null
@@ -1,73 +0,0 @@
-#!/bin/bash
-# vim: ft=sh
-
-source lib/generic.sh
-
-QDISCS="cbq htb dsmark"
-
-if [ ! -d tests/cls ]; then
-    ts_log "tests/cls folder does not exist"
-    ts_skip
-fi
-
-for q in ${QDISCS}; do
-	ts_log "Preparing classifier testbed with qdisc $q"
-
-	for c in tests/cls/*.c; do
-
-		case "$q" in
-		cbq)
-			ts_tc "cls-testbed" "cbq root qdisc creation" \
-				qdisc add dev $DEV root handle 10:0 \
-				cbq bandwidth 100Mbit avpkt 1400 mpu 64
-			ts_tc "cls-testbed" "cbq root class creation" \
-				class add dev $DEV parent 10:0  classid 10:12 \
-				cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 \
-				maxburst 1 avpkt  500 bounded
-			;;
-		htb)
-			ts_qdisc_available "htb"
-			if [ $? -eq 0 ]; then
-				ts_log "cls-testbed: HTB is unsupported by $TC, skipping"
-				continue;
-			fi
-			ts_tc "cls-testbed" "htb root qdisc creation" \
-				qdisc add dev $DEV root handle 10:0 htb
-			ts_tc "cls-testbed" "htb root class creation" \
-				class add dev $DEV parent 10:0 classid 10:12 \
-				htb rate 100Mbit quantum 1514
-			;;
-		dsmark)
-			ts_qdisc_available "dsmark"
-			if [ $? -eq 0 ]; then
-				ts_log "cls-testbed: dsmark is unsupported by $TC, skipping"
-				continue;
-			fi
-			ts_tc "cls-testbed" "dsmark root qdisc creation" \
-				qdisc add dev $DEV root handle 20:0 \
-				dsmark indices 64 default_index 1 set_tc_index
-			ts_tc "cls-testbed" "dsmark class creation" \
-				class change dev $DEV parent 20:0 classid 20:12 \
-				dsmark mask 0xff value 2
-			ts_tc "cls-testbed" "prio inner qdisc creation" \
-				qdisc add dev $DEV parent 20:0 handle 10:0 prio
-			;;
-		*)
-			ts_err "cls-testbed: no testbed configuration found for qdisc $q"
-			continue
-			;;
-		esac
-
-		ts_tc "cls-testbed" "tree listing" qdisc list dev eth0
-		ts_tc "cls-testbed" "tree class listing" class list dev eth0
-		ts_log "cls-testbed: starting classifier test $c"
-		$c 
-
-		case "$q" in
-		*)
-			ts_tc "cls-testbed" "generic qdisc tree deletion" \
-				qdisc del dev $DEV root
-			;;
-		esac
-	done
-done
diff --git a/testsuite/tests/dsmark.t b/testsuite/tests/dsmark.t
deleted file mode 100755
index 6934165..0000000
--- a/testsuite/tests/dsmark.t
+++ /dev/null
@@ -1,31 +0,0 @@
-#!/bin/bash
-# vim: ft=sh
-
-source lib/generic.sh
-
-ts_qdisc_available "dsmark"
-if [ $? -eq 0 ]; then
-	ts_log "dsmark: Unsupported by $TC, skipping"
-	exit 127
-fi
-
-ts_tc "dsmark" "dsmark root qdisc creation" \
-	qdisc add dev $DEV root handle 10:0 \
-	dsmark indices 64 default_index 1 set_tc_index
-
-ts_tc "dsmark" "dsmark class 1 creation" \
-	class change dev $DEV parent 10:0 classid 10:12 \
-	dsmark mask 0xff value 2
-
-ts_tc "dsmark" "dsmark class 2 creation" \
-	class change dev $DEV parent 10:0 classid 10:13 \
-	dsmark mask 0xfc value 4
-
-ts_tc "dsmark" "dsmark dump qdisc" \
-	qdisc list dev $DEV
-
-ts_tc "dsmark" "dsmark dump class" \
-	class list dev $DEV parent 10:0
-
-ts_tc "dsmark" "generic qdisc tree deletion" \
-	qdisc del dev $DEV root
diff --git a/testsuite/tests/policer.t b/testsuite/tests/policer.t
deleted file mode 100755
index eaf16ac..0000000
--- a/testsuite/tests/policer.t
+++ /dev/null
@@ -1,13 +0,0 @@
-#!/bin/sh
-$TC qdisc del dev $DEV root >/dev/null 2>&1
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
-$TC qdisc list dev $DEV
-$TC filter list dev $DEV parent 10:0
-$TC qdisc del dev $DEV root
-$TC qdisc list dev $DEV
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
-$TC qdisc del dev $DEV root
diff --git a/testsuite/tests/tc/cbq.t b/testsuite/tests/tc/cbq.t
new file mode 100755
index 0000000..bff814b
--- /dev/null
+++ b/testsuite/tests/tc/cbq.t
@@ -0,0 +1,10 @@
+#!/bin/sh
+$TC qdisc del dev $DEV root >/dev/null 2>&1
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC qdisc list dev $DEV
+$TC qdisc del dev $DEV root
+$TC qdisc list dev $DEV
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC qdisc del dev $DEV root
diff --git a/testsuite/tests/tc/cls-testbed.t b/testsuite/tests/tc/cls-testbed.t
new file mode 100755
index 0000000..2afc26f
--- /dev/null
+++ b/testsuite/tests/tc/cls-testbed.t
@@ -0,0 +1,73 @@
+#!/bin/bash
+# vim: ft=sh
+
+source lib/generic.sh
+
+QDISCS="cbq htb dsmark"
+
+if [ ! -d tests/cls ]; then
+    ts_log "tests/cls folder does not exist"
+    ts_skip
+fi
+
+for q in ${QDISCS}; do
+	ts_log "Preparing classifier testbed with qdisc $q"
+
+	for c in tests/cls/*.c; do
+
+		case "$q" in
+		cbq)
+			ts_tc "cls-testbed" "cbq root qdisc creation" \
+				qdisc add dev $DEV root handle 10:0 \
+				cbq bandwidth 100Mbit avpkt 1400 mpu 64
+			ts_tc "cls-testbed" "cbq root class creation" \
+				class add dev $DEV parent 10:0  classid 10:12 \
+				cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 \
+				maxburst 1 avpkt  500 bounded
+			;;
+		htb)
+			ts_qdisc_available "htb"
+			if [ $? -eq 0 ]; then
+				ts_log "cls-testbed: HTB is unsupported by $TC, skipping"
+				continue;
+			fi
+			ts_tc "cls-testbed" "htb root qdisc creation" \
+				qdisc add dev $DEV root handle 10:0 htb
+			ts_tc "cls-testbed" "htb root class creation" \
+				class add dev $DEV parent 10:0 classid 10:12 \
+				htb rate 100Mbit quantum 1514
+			;;
+		dsmark)
+			ts_qdisc_available "dsmark"
+			if [ $? -eq 0 ]; then
+				ts_log "cls-testbed: dsmark is unsupported by $TC, skipping"
+				continue;
+			fi
+			ts_tc "cls-testbed" "dsmark root qdisc creation" \
+				qdisc add dev $DEV root handle 20:0 \
+				dsmark indices 64 default_index 1 set_tc_index
+			ts_tc "cls-testbed" "dsmark class creation" \
+				class change dev $DEV parent 20:0 classid 20:12 \
+				dsmark mask 0xff value 2
+			ts_tc "cls-testbed" "prio inner qdisc creation" \
+				qdisc add dev $DEV parent 20:0 handle 10:0 prio
+			;;
+		*)
+			ts_err "cls-testbed: no testbed configuration found for qdisc $q"
+			continue
+			;;
+		esac
+
+		ts_tc "cls-testbed" "tree listing" qdisc list dev eth0
+		ts_tc "cls-testbed" "tree class listing" class list dev eth0
+		ts_log "cls-testbed: starting classifier test $c"
+		$c 
+
+		case "$q" in
+		*)
+			ts_tc "cls-testbed" "generic qdisc tree deletion" \
+				qdisc del dev $DEV root
+			;;
+		esac
+	done
+done
diff --git a/testsuite/tests/tc/dsmark.t b/testsuite/tests/tc/dsmark.t
new file mode 100755
index 0000000..6934165
--- /dev/null
+++ b/testsuite/tests/tc/dsmark.t
@@ -0,0 +1,31 @@
+#!/bin/bash
+# vim: ft=sh
+
+source lib/generic.sh
+
+ts_qdisc_available "dsmark"
+if [ $? -eq 0 ]; then
+	ts_log "dsmark: Unsupported by $TC, skipping"
+	exit 127
+fi
+
+ts_tc "dsmark" "dsmark root qdisc creation" \
+	qdisc add dev $DEV root handle 10:0 \
+	dsmark indices 64 default_index 1 set_tc_index
+
+ts_tc "dsmark" "dsmark class 1 creation" \
+	class change dev $DEV parent 10:0 classid 10:12 \
+	dsmark mask 0xff value 2
+
+ts_tc "dsmark" "dsmark class 2 creation" \
+	class change dev $DEV parent 10:0 classid 10:13 \
+	dsmark mask 0xfc value 4
+
+ts_tc "dsmark" "dsmark dump qdisc" \
+	qdisc list dev $DEV
+
+ts_tc "dsmark" "dsmark dump class" \
+	class list dev $DEV parent 10:0
+
+ts_tc "dsmark" "generic qdisc tree deletion" \
+	qdisc del dev $DEV root
diff --git a/testsuite/tests/tc/policer.t b/testsuite/tests/tc/policer.t
new file mode 100755
index 0000000..eaf16ac
--- /dev/null
+++ b/testsuite/tests/tc/policer.t
@@ -0,0 +1,13 @@
+#!/bin/sh
+$TC qdisc del dev $DEV root >/dev/null 2>&1
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
+$TC qdisc list dev $DEV
+$TC filter list dev $DEV parent 10:0
+$TC qdisc del dev $DEV root
+$TC qdisc list dev $DEV
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
+$TC qdisc del dev $DEV root
-- 
2.1.0
