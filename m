From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [patch] iproute: fix dangerous /tmp/ handling
Date: Wed, 15 Feb 2012 16:32:23 +0400
Message-ID: <20120215123223.GA14094@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solar Designer <solar@openwall.com>
To: netdev@vger.kernel.org, security@kernel.org, shemminger@osdl.org,
	kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55017 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036Ab2BOMhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 07:37:14 -0500
Received: by bkcjm19 with SMTP id jm19so869879bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 04:37:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using "/tmp/file" without checking file owner is dangerous.
It could be a symlink pointing to user's file.  If one creates
such symlink and makes victim do "./configure", gcc executed with
UID=victim would compile attacker's source file into arbitrary
location (e.g. into ~victim/bin/).

Instead use a directory created with mktemp and handle all temporary
files in this directory only.

The same with dhcp-client-script sample script.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
--
 configure                   |   34 +++++++++++++++++++---------------
 examples/dhcp-client-script |    2 +-
 2 files changed, 20 insertions(+), 16 deletions(-)

--
diff -uNp -r iproute2-3.2.0.old/configure iproute2-3.2.0/configure
--- iproute2-3.2.0.old/configure	2012-01-05 16:34:31 +0000
+++ iproute2-3.2.0/configure	2012-02-15 12:29:16 +0000
@@ -3,9 +3,13 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
+TMPDIR="`mktemp -dt iproute.XXXXXXXXXX`" || exit
+trap 'rm -rf -- "$TMPDIR"' EXIT
+trap 'trap - EXIT; rm -rf -- "$TMPDIR"; exit 1' HUP INT QUIT TERM
+
 check_atm()
 {
-cat >/tmp/atmtest.c <<EOF
+cat >$TMPDIR/atmtest.c <<EOF
 #include <atm.h>
 int main(int argc, char **argv) {
 	struct atm_qos qos;
@@ -13,7 +17,7 @@ int main(int argc, char **argv) {
 	return 0;
 }
 EOF
-gcc -I$INCLUDE -o /tmp/atmtest /tmp/atmtest.c -latm >/dev/null 2>&1 
+gcc -I$INCLUDE -o $TMPDIR/atmtest $TMPDIR/atmtest.c -latm >/dev/null 2>&1 
 if [ $? -eq 0 ]
 then
     echo "TC_CONFIG_ATM:=y" >>Config
@@ -21,13 +25,13 @@ then
 else
     echo no
 fi
-rm -f /tmp/atmtest.c /tmp/atmtest
+rm -f $TMPDIR/atmtest.c $TMPDIR/atmtest
 }
 
 check_xt()
 {
 #check if we have xtables from iptables >= 1.4.5.
-cat >/tmp/ipttest.c <<EOF
+cat >$TMPDIR/ipttest.c <<EOF
 #include <xtables.h>
 #include <linux/netfilter.h>
 static struct xtables_globals test_globals = {
@@ -47,12 +51,12 @@ int main(int argc, char **argv)
 
 EOF
 
-if gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL $(pkg-config xtables --cflags --libs) -ldl >/dev/null 2>&1
+if gcc -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL $(pkg-config xtables --cflags --libs) -ldl >/dev/null 2>&1
 then
 	echo "TC_CONFIG_XT:=y" >>Config
 	echo "using xtables"
 fi
-rm -f /tmp/ipttest.c /tmp/ipttest
+rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
 }
 
 check_xt_old()
@@ -64,7 +68,7 @@ then
 fi
 
 #check if we dont need our internal header ..
-cat >/tmp/ipttest.c <<EOF
+cat >$TMPDIR/ipttest.c <<EOF
 #include <xtables.h>
 char *lib_dir;
 unsigned int global_option_offset = 0;
@@ -84,14 +88,14 @@ int main(int argc, char **argv) {
 }
 
 EOF
-gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+gcc -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
 	echo "TC_CONFIG_XT_OLD:=y" >>Config
 	echo "using old xtables (no need for xt-internal.h)"
 fi
-rm -f /tmp/ipttest.c /tmp/ipttest
+rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
 }
 
 check_xt_old_internal_h()
@@ -103,7 +107,7 @@ then
 fi
 
 #check if we need our own internal.h
-cat >/tmp/ipttest.c <<EOF
+cat >$TMPDIR/ipttest.c <<EOF
 #include <xtables.h>
 #include "xt-internal.h"
 char *lib_dir;
@@ -124,14 +128,14 @@ int main(int argc, char **argv) {
 }
 
 EOF
-gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+gcc -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
 	echo "using old xtables with xt-internal.h"
 	echo "TC_CONFIG_XT_OLD_H:=y" >>Config
 fi
-rm -f /tmp/ipttest.c /tmp/ipttest
+rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
 }
 
 check_ipt()
@@ -160,7 +164,7 @@ check_ipt_lib_dir()
 
 check_setns()
 {
-cat >/tmp/setnstest.c <<EOF
+cat >$TMPDIR/setnstest.c <<EOF
 #include <sched.h>
 int main(int argc, char **argv) 
 {
@@ -168,7 +172,7 @@ int main(int argc, char **argv) 
 	return 0;
 }
 EOF
-gcc -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
+gcc -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c >/dev/null 2>&1
 if [ $? -eq 0 ]
 then
 	echo "IP_CONFIG_SETNS:=y" >>Config
@@ -176,7 +180,7 @@ then
 else
 	echo "no"
 fi
-rm -f /tmp/setnstest.c /tmp/setnstest
+rm -f $TMPDIR/setnstest.c $TMPDIR/setnstest
 }
 
 echo "# Generated config based on" $INCLUDE >Config
diff -uNp -r iproute2-3.2.0.old/examples/dhcp-client-script iproute2-3.2.0/examples/dhcp-client-script
--- iproute2-3.2.0.old/examples/dhcp-client-script	2012-01-05 16:34:31 +0000
+++ iproute2-3.2.0/examples/dhcp-client-script	2012-02-15 12:29:37 +0000
@@ -14,7 +14,7 @@
 # we should install and preserve.
 #
 
-exec >> /tmp/DHS.log 2>&1
+exec >> /var/log/DHS.log 2>&1
 
 echo dhc-script $* reason=$reason
 set | grep "^\(old_\|new_\|check_\)"
-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
