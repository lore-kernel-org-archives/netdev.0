From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] selftests: rtnetlink.sh: add test case for device ifalias
Date: Tue, 19 Sep 2017 14:42:17 +0200
Message-ID: <20170919124217.25105-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54602 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751340AbdISMl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:41:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 57 ++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 57b5ff576240..4b48de565cae 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -15,6 +15,14 @@ check_err()
 	fi
 }
 
+# same but inverted -- used when command must fail for test to pass
+check_fail()
+{
+	if [ $1 -eq 0 ]; then
+		ret=1
+	fi
+}
+
 kci_add_dummy()
 {
 	ip link add name "$devdummy" type dummy
@@ -235,6 +243,54 @@ kci_test_addrlabel()
 	echo "PASS: ipv6 addrlabel"
 }
 
+kci_test_ifalias()
+{
+	ret=0
+	namewant=$(uuidgen)
+	syspathname="/sys/class/net/$devdummy/ifalias"
+
+	ip link set dev "$devdummy" alias "$namewant"
+	check_err $?
+
+	if [ $ret -ne 0 ]; then
+		echo "FAIL: cannot set interface alias of $devdummy to $namewant"
+		return 1
+	fi
+
+	ip link show "$devdummy" | grep -q "alias $namewant"
+	check_err $?
+
+	if [ -r "$syspathname" ] ; then
+		read namehave < "$syspathname"
+		if [ "$namewant" != "$namehave" ]; then
+			echo "FAIL: did set ifalias $namewant but got $namehave"
+			return 1
+		fi
+
+		namewant=$(uuidgen)
+		echo "$namewant" > "$syspathname"
+	        ip link show "$devdummy" | grep -q "alias $namewant"
+		check_err $?
+
+		# sysfs interface allows to delete alias again
+		echo "" > "$syspathname"
+
+	        ip link show "$devdummy" | grep -q "alias $namewant"
+		check_fail $?
+
+		# re-add the alias -- kernel should free mem when dummy dev is removed
+		ip link set dev "$devdummy" alias "$namewant"
+		check_err $?
+	fi
+
+	if [ $ret -ne 0 ]; then
+		echo "FAIL: set interface alias $devdummy to $namewant"
+		return 1
+	fi
+
+	echo "PASS: set ifalias $namewant for $devdummy"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -249,6 +305,7 @@ kci_test_rtnl()
 	kci_test_gre
 	kci_test_bridge
 	kci_test_addrlabel
+	kci_test_ifalias
 
 	kci_del_dummy
 }
-- 
2.13.5
