From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] selftests: rtnetlink.sh: add vxlan and fou test cases
Date: Mon,  2 Oct 2017 12:05:29 +0200
Message-ID: <20171002100529.602-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53514 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750949AbdJBKFP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:05:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fou test lifted from ip-fou man page.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 96 ++++++++++++++++++++++++++++++++
 1 file changed, 96 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index a048f7a5f94c..62c87da92770 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -332,6 +332,101 @@ kci_test_vrf()
 	echo "PASS: vrf"
 }
 
+kci_test_encap_vxlan()
+{
+	ret=0
+	vxlan="test-vxlan0"
+	vlan="test-vlan0"
+	testns="$1"
+
+	ip netns exec "$testns" ip link add "$vxlan" type vxlan id 42 group 239.1.1.1 \
+		dev "$devdummy" dstport 4789 2>/dev/null
+	if [ $? -ne 0 ]; then
+		echo "FAIL: can't add vxlan interface, skipping test"
+		return 0
+	fi
+	check_err $?
+
+	ip netns exec "$testns" ip addr add 10.2.11.49/24 dev "$vxlan"
+	check_err $?
+
+	ip netns exec "$testns" ip link set up dev "$vxlan"
+	check_err $?
+
+	ip netns exec "$testns" ip link add link "$vxlan" name "$vlan" type vlan id 1
+	check_err $?
+
+	ip netns exec "$testns" ip link del "$vxlan"
+	check_err $?
+
+	if [ $ret -ne 0 ]; then
+		echo "FAIL: vxlan"
+		return 1
+	fi
+	echo "PASS: vxlan"
+}
+
+kci_test_encap_fou()
+{
+	ret=0
+	name="test-fou"
+	testns="$1"
+
+	ip fou help 2>&1 |grep -q 'Usage: ip fou'
+	if [ $? -ne 0 ];then
+		echo "SKIP: fou: iproute2 too old"
+		return 1
+	fi
+
+	ip netns exec "$testns" ip fou add port 7777 ipproto 47 2>/dev/null
+	if [ $? -ne 0 ];then
+		echo "FAIL: can't add fou port 7777, skipping test"
+		return 1
+	fi
+
+	ip netns exec "$testns" ip fou add port 8888 ipproto 4
+	check_err $?
+
+	ip netns exec "$testns" ip fou del port 9999 2>/dev/null
+	check_fail $?
+
+	ip netns exec "$testns" ip fou del port 7777
+	check_err $?
+
+	if [ $ret -ne 0 ]; then
+		echo "FAIL: fou"
+		return 1
+	fi
+
+	echo "PASS: fou"
+}
+
+# test various encap methods, use netns to avoid unwanted interference
+kci_test_encap()
+{
+	testns="testns"
+	ret=0
+
+	ip netns add "$testns"
+	if [ $? -ne 0 ]; then
+		echo "SKIP encap tests: cannot add net namespace $testns"
+		return 1
+	fi
+
+	ip netns exec "$testns" ip link set lo up
+	check_err $?
+
+	ip netns exec "$testns" ip link add name "$devdummy" type dummy
+	check_err $?
+	ip netns exec "$testns" ip link set "$devdummy" up
+	check_err $?
+
+	kci_test_encap_vxlan "$testns"
+	kci_test_encap_fou "$testns"
+
+	ip netns del "$testns"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -348,6 +443,7 @@ kci_test_rtnl()
 	kci_test_addrlabel
 	kci_test_ifalias
 	kci_test_vrf
+	kci_test_encap
 
 	kci_del_dummy
 }
-- 
2.13.6
