From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/2] selftests: add addrlabel add/delete to rtnetlink.sh
Date: Tue, 29 Aug 2017 13:29:41 +0200
Message-ID: <20170829112942.4791-2-fw@strlen.de>
References: <20170829112942.4791-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56346 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752881AbdH2L3f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 07:29:35 -0400
In-Reply-To: <20170829112942.4791-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 41 ++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 84b4acf5baa9..57b5ff576240 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -195,6 +195,46 @@ kci_test_route_get()
 	echo "PASS: route get"
 }
 
+kci_test_addrlabel()
+{
+	ret=0
+
+	ip addrlabel add prefix dead::/64 dev lo label 1
+	check_err $?
+
+	ip addrlabel list |grep -q "prefix dead::/64 dev lo label 1"
+	check_err $?
+
+	ip addrlabel del prefix dead::/64 dev lo label 1 2> /dev/null
+	check_err $?
+
+	ip addrlabel add prefix dead::/64 label 1 2> /dev/null
+	check_err $?
+
+	ip addrlabel del prefix dead::/64 label 1 2> /dev/null
+	check_err $?
+
+	# concurrent add/delete
+	for i in $(seq 1 1000); do
+		ip addrlabel add prefix 1c3::/64 label 12345 2>/dev/null
+	done &
+
+	for i in $(seq 1 1000); do
+		ip addrlabel del prefix 1c3::/64 label 12345 2>/dev/null
+	done
+
+	wait
+
+	ip addrlabel del prefix 1c3::/64 label 12345 2>/dev/null
+
+	if [ $ret -ne 0 ];then
+		echo "FAIL: ipv6 addrlabel"
+		return 1
+	fi
+
+	echo "PASS: ipv6 addrlabel"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -208,6 +248,7 @@ kci_test_rtnl()
 	kci_test_tc
 	kci_test_gre
 	kci_test_bridge
+	kci_test_addrlabel
 
 	kci_del_dummy
 }
-- 
2.13.0
