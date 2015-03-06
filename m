From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip netns: Fix rtnl error while print netns list
Date: Fri,  6 Mar 2015 17:12:31 +0200
Message-ID: <1425654751-21166-1-git-send-email-vadim4j@gmail.com>
Cc: nicolas.dichtel@6wind.com, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:45809 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294AbbCFPYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 10:24:09 -0500
Received: by lbiz12 with SMTP id z12so30370334lbi.12
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 07:24:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Observed on the Linux 3.18:

    # ip netns
    RTNETLINK answers: Operation not supported
    net0

CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Fixes: d182ee1307c7 ("ipnetns: allow to get and set netns ids")
Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 configure    | 25 ++++++++++++++++++++++++-
 ip/Makefile  |  3 +++
 ip/ipnetns.c |  7 +++++++
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index c3dacdb..eaff342 100755
--- a/configure
+++ b/configure
@@ -201,7 +201,7 @@ check_setns()
 {
     cat >$TMPDIR/setnstest.c <<EOF
 #include <sched.h>
-int main(int argc, char **argv) 
+int main(int argc, char **argv)
 {
 	(void)setns(0,0);
 	return 0;
@@ -218,6 +218,27 @@ EOF
     rm -f $TMPDIR/setnstest.c $TMPDIR/setnstest
 }
 
+check_netnsid()
+{
+    cat >$TMPDIR/netnsid.c <<EOF
+#include <linux/rtnetlink.h>
+int main(int argc, char **argv)
+{
+	int test_def = RTM_GETNSID;
+	return 0;
+}
+EOF
+    $CC -o $TMPDIR/netnsid $TMPDIR/netnsid.c >/dev/null 2>&1
+    if [ $? -eq 0 ]
+    then
+	echo "IP_CONFIG_NETNSID:=y" >> Config
+	echo "yes"
+    else
+	echo "no"
+    fi
+    rm -f $TMPDIR/netnsid.c $TMPDIR/netnsid
+}
+
 check_ipset()
 {
     cat >$TMPDIR/ipsettest.c <<EOF
@@ -283,6 +304,8 @@ check_ipt_lib_dir
 
 echo -n "libc has setns: "
 check_setns
+echo -n "netns has peer id suport: "
+check_netnsid
 
 echo -n "SELinux support: "
 check_selinux
diff --git a/ip/Makefile b/ip/Makefile
index 2c742f3..bf152ab 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -15,6 +15,9 @@ include ../Config
 ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
+ifeq ($(IP_CONFIG_NETNSID),y)
+	CFLAGS += -DHAVE_NETNSID
+endif
 
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 5a213dc..45e234a 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -34,6 +34,7 @@ static int usage(void)
 	exit(-1);
 }
 
+#ifdef HAVE_NETNSID
 static int get_netnsid_from_name(const char *name)
 {
 	struct {
@@ -78,6 +79,12 @@ static int get_netnsid_from_name(const char *name)
 
 	return -1;
 }
+#else
+static int get_netnsid_from_name(const char *name)
+{
+	return -1;
+}
+#endif /* HAVE_NETNSID */
 
 static int netns_list(int argc, char **argv)
 {
-- 
2.3.1
