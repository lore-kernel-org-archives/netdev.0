From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 3/3] Slightly improve the configure script.
Date: Wed, 2 Dec 2009 16:12:30 +0100
Message-ID: <441b45d44e50503f0b7c8bf509cdd1a3cb8de8fc.1259765732.git.andreas@fatal.se>
References: <cover.1259765732.git.andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy1.bredband.net ([195.54.101.71]:38388 "EHLO
	proxy1.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788AbZLBPLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 10:11:25 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy1.bredband.net (7.3.140.3)
        id 4AD3E1C001662BED for netdev@vger.kernel.org; Wed, 2 Dec 2009 16:11:31 +0100
Content-Disposition: inline
In-Reply-To: <cover.1259765732.git.andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split up in functions. Make XT checks bail if previous XT check
was successful.

This result improves the output of the configure script to not indicate
using iptables only because the last test failed (when previous ones could
have already succeded).

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 configure |   66 +++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/configure b/configure
index 4fda7cb..a903bb0 100755
--- a/configure
+++ b/configure
@@ -3,11 +3,8 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
-echo "# Generated config based on" $INCLUDE >Config
-
-echo "TC schedulers"
-
-echo -n " ATM	"
+function check_atm
+{
 cat >/tmp/atmtest.c <<EOF
 #include <atm.h>
 int main(int argc, char **argv) {
@@ -25,9 +22,10 @@ else
     echo no
 fi
 rm -f /tmp/atmtest.c /tmp/atmtest
+}
 
-echo -n " IPT	"
-
+function check_xt
+{
 #check if we have xtables from iptables >= 1.4.5.
 cat >/tmp/ipttest.c <<EOF
 #include <xtables.h>
@@ -52,7 +50,17 @@ EOF
 if gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl -lxtables >/dev/null 2>&1
 then
 	echo "TC_CONFIG_XT:=y" >>Config
-	echo "using xtables instead of iptables"
+	echo "using xtables"
+fi
+rm -f /tmp/ipttest.c /tmp/ipttest
+}
+
+function check_xt_old
+{
+# bail if previous XT checks has already succeded.
+if grep TC_CONFIG_XT Config > /dev/null
+then
+	return
 fi
 
 #check if we need dont our internal header ..
@@ -81,9 +89,17 @@ gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 if [ $? -eq 0 ]
 then
 	echo "TC_CONFIG_XT_OLD:=y" >>Config
-	echo "using xtables seems no need for internal.h"
-else
-	echo "failed test 2"
+	echo "using old xtables (no need for xt-internal.h)"
+fi
+rm -f /tmp/ipttest.c /tmp/ipttest
+}
+
+function check_xt_old_internal_h
+{
+# bail if previous XT checks has already succeded.
+if grep TC_CONFIG_XT Config > /dev/null
+then
+	return
 fi
 
 #check if we need our own internal.h
@@ -112,10 +128,30 @@ gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
-	echo "using xtables instead of iptables (need for internal.h)"
+	echo "using old xtables with xt-internal.h"
 	echo "TC_CONFIG_XT_OLD_H:=y" >>Config
-
-else
-	echo "failed test 3 using iptables"
 fi
 rm -f /tmp/ipttest.c /tmp/ipttest
+}
+
+function check_ipt
+{
+	if ! grep TC_CONFIG_XT Config > /dev/null
+	then
+		echo "using iptables"
+	fi
+}
+
+echo "# Generated config based on" $INCLUDE >Config
+
+echo "TC schedulers"
+
+echo -n " ATM	"
+check_atm
+
+echo -n " IPT	"
+check_xt
+check_xt_old
+check_xt_old_internal_h
+check_ipt
+
-- 
1.6.5.3

