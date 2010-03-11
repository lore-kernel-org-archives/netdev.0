From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: detect iptables modules dir in configure.
Date: Thu, 11 Mar 2010 20:07:40 +0100
Message-ID: <20100311190740.GA28425@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h12.telenor.se ([62.127.194.5]:54633 "EHLO
	smtprelay-h12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737Ab0CKTdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:33:36 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h12.telenor.se (Postfix) with ESMTP id 0F12DDF9B
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 20:08:33 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to automatically detect iptables modules directory.

Make the configure script look for iptables modules.
This also makes it possible to specify it on the
command line while building via "make IPT_LIB_DIR=/foo/bar".

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

---

Possibly the ifndef check in include/iptables.h
should be turned into an #error to force the person
building to manually specify it instead of just silently
using a probably incorrect path.

diff --git a/configure b/configure
index 92a0b48..600fa96 100755
--- a/configure
+++ b/configure
@@ -3,6 +3,8 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
+TABLES=
+
 check_atm()
 {
 cat >/tmp/atmtest.c <<EOF
@@ -139,9 +141,28 @@ check_ipt()
 	if ! grep TC_CONFIG_XT Config > /dev/null
 	then
 		echo "using iptables"
+		TABLES="iptables"
+	else
+		TABLES="xtables"
 	fi
 }
 
+check_ipt_lib_dir()
+{
+	IPT_LIB_DIR=""
+	for dir in /lib /usr/lib /usr/local/lib
+	do
+		for file in $dir/$TABLES/lib*t_*so ; do
+			if [ -f $file ]; then
+				echo $dir/$TABLES
+				echo "IPT_LIB_DIR:=$dir/$TABLES" >> Config
+				return
+			fi
+		done
+	done
+	echo "not found!"
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 
 echo "TC schedulers"
@@ -155,3 +176,5 @@ check_xt_old
 check_xt_old_internal_h
 check_ipt
 
+echo -n "iptables modules directory: "
+check_ipt_lib_dir
diff --git a/tc/Makefile b/tc/Makefile
index 0b5d7d3..6508ef3 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -77,6 +77,9 @@ TCLIB += tc_estimator.o
 TCLIB += tc_stab.o
 
 CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
+ifneq ($(IPT_LIB_DIR),)
+	CFLAGS += -DIPT_LIB_DIR="$(IPT_LIB_DIR)"
+endif
 
 TCSO :=
 ifeq ($(TC_CONFIG_ATM),y)
