From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] selftests: rtnetlink: test RTM_GETNETCONF
Date: Tue, 10 Oct 2017 16:18:05 +0200
Message-ID: <20171010141805.19194-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34056 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756446AbdJJORr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:17:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

exercise RTM_GETNETCONF call path for unspec, inet and inet6
families, they are DOIT_UNLOCKED candidates.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index e8c86c416ed0..a8a8cdf726b2 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -37,6 +37,26 @@ kci_del_dummy()
 	check_err $?
 }
 
+kci_test_netconf()
+{
+	dev="$1"
+	r=$ret
+
+	ip netconf show dev "$dev" > /dev/null
+	check_err $?
+
+	for f in 4 6; do
+		ip -$f netconf show dev "$dev" > /dev/null
+		check_err $?
+	done
+
+	if [ $ret -ne 0 ] ;then
+		echo "FAIL: ip netconf show $dev"
+		test $r -eq 0 && ret=0
+		return 1
+	fi
+}
+
 # add a bridge with vlans on top
 kci_test_bridge()
 {
@@ -63,6 +83,11 @@ kci_test_bridge()
 	check_err $?
 	ip r s t all > /dev/null
 	check_err $?
+
+	for name in "$devbr" "$vlandev" "$devdummy" ; do
+		kci_test_netconf "$name"
+	done
+
 	ip -6 addr del dev "$vlandev" dead:42::1234/64
 	check_err $?
 
@@ -100,6 +125,9 @@ kci_test_gre()
 	check_err $?
 	ip addr > /dev/null
 	check_err $?
+
+	kci_test_netconf "$gredev"
+
 	ip addr del dev "$devdummy" 10.23.7.11/24
 	check_err $?
 
-- 
2.13.6
