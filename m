From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] selftests: rtnetlink: add a small macsec test case
Date: Thu, 12 Oct 2017 11:11:22 +0200
Message-ID: <20171012091122.28133-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:44736 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751835AbdJLJLF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 05:11:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 42 ++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index a8a8cdf726b2..5215493166c9 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -461,6 +461,47 @@ kci_test_encap()
 	ip netns del "$testns"
 }
 
+kci_test_macsec()
+{
+	msname="test_macsec0"
+	ret=0
+
+	ip macsec help 2>&1 | grep -q "^Usage: ip macsec"
+	if [ $? -ne 0 ]; then
+		echo "SKIP: macsec: iproute2 too old"
+		return 0
+	fi
+
+	ip link add link "$devdummy" "$msname" type macsec port 42 encrypt on
+	check_err $?
+	if [ $ret -ne 0 ];then
+		echo "FAIL: can't add macsec interface, skipping test"
+		return 1
+	fi
+
+	ip macsec add "$msname" tx sa 0 pn 1024 on key 01 12345678901234567890123456789012
+	check_err $?
+
+	ip macsec add "$msname" rx port 1234 address "1c:ed:de:ad:be:ef"
+	check_err $?
+
+	ip macsec add "$msname" rx port 1234 address "1c:ed:de:ad:be:ef" sa 0 pn 1 on key 00 0123456789abcdef0123456789abcdef
+	check_err $?
+
+	ip macsec show > /dev/null
+	check_err $?
+
+	ip link del dev "$msname"
+	check_err $?
+
+	if [ $ret -ne 0 ];then
+		echo "FAIL: macsec"
+		return 1
+	fi
+
+	echo "PASS: macsec"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -478,6 +519,7 @@ kci_test_rtnl()
 	kci_test_ifalias
 	kci_test_vrf
 	kci_test_encap
+	kci_test_macsec
 
 	kci_del_dummy
 }
-- 
2.13.6
