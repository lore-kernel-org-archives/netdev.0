From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Add output testing
Date: Thu, 18 Jun 2015 00:28:18 +0300
Message-ID: <1434576498-6657-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36848 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbbFQV3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 17:29:45 -0400
Received: by lbbqq2 with SMTP id qq2so40300301lbb.3
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 14:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added possibility to check command output by grep from the testing
script.

Now TMP_OUT & TMP_ERR are passed from Makefile and changed to
STD_ERR & STD_OUT.

Also changed some existing tests to make output testing.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile                           |  4 ++
 testsuite/lib/generic.sh                     | 80 ++++++++++++++++++++--------
 testsuite/tests/ip/link/new_link.t           |  4 ++
 testsuite/tests/ip/route/add_default_route.t | 23 +++++++-
 4 files changed, 88 insertions(+), 23 deletions(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index 4b945b0..2027650 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -52,6 +52,9 @@ endif
 	@for i in $(IPVERS); do \
 		o=`echo $$i | sed -e 's/iproute2\///'`; \
 		echo -n "Running $@ [$$o/`uname -r`]: "; \
+		TMP_ERR=`mktemp /tmp/tc_testsuite.XXXXXX`; \
+		TMP_OUT=`mktemp /tmp/tc_testsuite.XXXXXX`; \
+		STD_ERR="$$TMP_ERR" STD_OUT="$$TMP_OUT" \
 		TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
 		ERRF="$(RESULTS_DIR)/$@.$$o.err" $(KENV) $(PREFIX) tests/$@ > $(RESULTS_DIR)/$@.$$o.out; \
 		if [ "$$?" = "127" ]; then \
@@ -61,5 +64,6 @@ endif
 		else \
 			echo "PASS"; \
 		fi; \
+		rm "$$TMP_ERR" "$$TMP_OUT"; \
 		dmesg > $(RESULTS_DIR)/$@.$$o.dmesg; \
 	done
diff --git a/testsuite/lib/generic.sh b/testsuite/lib/generic.sh
index 3473cc1..b7de704 100644
--- a/testsuite/lib/generic.sh
+++ b/testsuite/lib/generic.sh
@@ -30,57 +30,49 @@ ts_tc()
 {
 	SCRIPT=$1; shift
 	DESC=$1; shift
-	TMP_ERR=`mktemp /tmp/tc_testsuite.XXXXXX` || exit
-	TMP_OUT=`mktemp /tmp/tc_testsuite.XXXXXX` || exit
 
-	$TC $@ 2> $TMP_ERR > $TMP_OUT
+	$TC $@ 2> $STD_ERR > $STD_OUT
 
-	if [ -s $TMP_ERR ]; then
+	if [ -s $STD_ERR ]; then
 		ts_err "${SCRIPT}: ${DESC} failed:"
 		ts_err "command: $TC $@"
 		ts_err "stderr output:"
-		ts_err_cat $TMP_ERR
-		if [ -s $TMP_OUT ]; then
+		ts_err_cat $STD_ERR
+		if [ -s $STD_OUT ]; then
 			ts_err "stdout output:"
-			ts_err_cat $TMP_OUT
+			ts_err_cat $STD_OUT
 		fi
-	elif [ -s $TMP_OUT ]; then
+	elif [ -s $STD_OUT ]; then
 		echo "${SCRIPT}: ${DESC} succeeded with output:"
-		cat $TMP_OUT
+		cat $STD_OUT
 	else
 		echo "${SCRIPT}: ${DESC} succeeded"
 	fi
-
-	rm $TMP_ERR $TMP_OUT
 }
 
 ts_ip()
 {
 	SCRIPT=$1; shift
 	DESC=$1; shift
-	TMP_ERR=`mktemp /tmp/tc_testsuite.XXXXXX` || exit
-	TMP_OUT=`mktemp /tmp/tc_testsuite.XXXXXX` || exit
 
-	$IP $@ 2> $TMP_ERR > $TMP_OUT
+	$IP $@ 2> $STD_ERR > $STD_OUT
         RET=$?
 
-	if [ -s $TMP_ERR ] || [ "$RET" != "0" ]; then
+	if [ -s $STD_ERR ] || [ "$RET" != "0" ]; then
 		ts_err "${SCRIPT}: ${DESC} failed:"
 		ts_err "command: $IP $@"
 		ts_err "stderr output:"
-		ts_err_cat $TMP_ERR
-		if [ -s $TMP_OUT ]; then
+		ts_err_cat $STD_ERR
+		if [ -s $STD_OUT ]; then
 			ts_err "stdout output:"
-			ts_err_cat $TMP_OUT
+			ts_err_cat $STD_OUT
 		fi
-	elif [ -s $TMP_OUT ]; then
+	elif [ -s $STD_OUT ]; then
 		echo "${SCRIPT}: ${DESC} succeeded with output:"
-		cat $TMP_OUT
+		cat $STD_OUT
 	else
 		echo "${SCRIPT}: ${DESC} succeeded"
 	fi
-
-	rm $TMP_ERR $TMP_OUT
 }
 
 ts_qdisc_available()
@@ -97,3 +89,47 @@ rand_dev()
 {
     echo "dev-$(tr -dc "[:alpha:]" < /dev/urandom | head -c 6)"
 }
+
+pr_failed()
+{
+	echo " [FAILED]"
+	ts_err "matching failed"
+}
+
+pr_success()
+{
+	echo " [SUCCESS]"
+}
+
+test_on()
+{
+	echo -n "test on: \"$1\""
+	if cat "$STD_OUT" | grep -qE "$1"
+	then
+		pr_success
+	else
+		pr_failed
+	fi
+}
+
+test_on_not()
+{
+	echo -n "test on: \"$1\""
+	if cat "$STD_OUT" | grep -vqE "$1"
+	then
+		pr_success
+	else
+		pr_failed
+	fi
+}
+
+test_lines_count()
+{
+	echo -n "test on lines count ($1): "
+	if cat "$STD_OUT" | wc -l | grep -q "$1"
+	then
+		pr_success
+	else
+		pr_failed
+	fi
+}
diff --git a/testsuite/tests/ip/link/new_link.t b/testsuite/tests/ip/link/new_link.t
index 549ff25..699adbc 100755
--- a/testsuite/tests/ip/link/new_link.t
+++ b/testsuite/tests/ip/link/new_link.t
@@ -7,5 +7,9 @@ ts_log "[Testing add/del virtual links]"
 NEW_DEV="$(rand_dev)"
 
 ts_ip "$0" "Add $NEW_DEV dummy interface"  link add dev $NEW_DEV type dummy
+
 ts_ip "$0" "Show $NEW_DEV dummy interface" link show dev $NEW_DEV
+test_on "$NEW_DEV"
+test_lines_count 2
+
 ts_ip "$0" "Del $NEW_DEV dummy interface"  link del dev $NEW_DEV
diff --git a/testsuite/tests/ip/route/add_default_route.t b/testsuite/tests/ip/route/add_default_route.t
index 2908528..e5ea647 100755
--- a/testsuite/tests/ip/route/add_default_route.t
+++ b/testsuite/tests/ip/route/add_default_route.t
@@ -8,5 +8,26 @@ DEV=dummy0
 
 ts_ip "$0" "Add new interface $DEV" link add $DEV type dummy
 ts_ip "$0" "Set $DEV into UP state" link set up dev $DEV
+
 ts_ip "$0" "Add 1.1.1.1/24 addr on $DEV" addr add 1.1.1.1/24 dev $DEV
-ts_ip "$0" "Add default route via 1.1.1.1" route add default via 1.1.1.1
+ts_ip "$0" "Add default route via 1.1.1.2" route add default via 1.1.1.2
+
+ts_ip "$0" "Show IPv4 default route" -4 route show default
+test_on "default via 1.1.1.2 dev $DEV"
+test_lines_count 1
+
+ts_ip "$0" "Add another IPv4 route dst 2.2.2.0/24" -4 route add 2.2.2.0/24 dev $DEV
+ts_ip "$0" "Show IPv4 default route" -4 route show default
+test_on "default via 1.1.1.2 dev $DEV"
+test_lines_count 1
+
+ts_ip "$0" "Add dead:beef::1/64 addr on $DEV" -6 addr add dead:beef::1/64 dev $DEV
+ts_ip "$0" "Add default route via dead:beef::2" route add default via dead:beef::2
+ts_ip "$0" "Show IPv6 default route" -6 route show default
+test_on "default via dead:beef::2 dev $DEV"
+test_lines_count 1
+
+ts_ip "$0" "Add another IPv6 route dst cafe:babe::/64" -6 route add cafe:babe::/64 dev $DEV
+ts_ip "$0" "Show IPv6 default route" -6 route show default
+test_on "default via dead:beef::2 dev $DEV"
+test_lines_count 1
-- 
2.4.2
