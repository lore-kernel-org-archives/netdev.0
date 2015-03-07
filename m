From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2] ip netns: Fix rtnl error while print netns list
Date: Sat,  7 Mar 2015 08:30:58 +0200
Message-ID: <1425709858-25644-1-git-send-email-vadim4j@gmail.com>
Cc: nicolas.dichtel@6wind.com, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:37463 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbCGGmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 01:42:35 -0500
Received: by lbdu10 with SMTP id u10so14900173lbd.4
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 22:42:33 -0800 (PST)
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
v2:
   Get rid of main func in configure script,
   it is enough to test by assigning variable with RTM_GETNSID.

 configure    | 21 ++++++++++++++++++++-
 ip/Makefile  |  4 ++++
 ip/ipnetns.c |  7 +++++++
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index c3dacdb..631938e 100755
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
@@ -218,6 +218,23 @@ EOF
     rm -f $TMPDIR/setnstest.c $TMPDIR/setnstest
 }
 
+check_netnsid()
+{
+    cat >$TMPDIR/netnsid.c <<EOF
+#include <linux/rtnetlink.h>
+int test_def = RTM_GETNSID;
+EOF
+    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
+    if [ $? -eq 0 ]
+    then
+	echo "IP_CONFIG_NETNSID:=y" >> Config
+	echo "yes"
+    else
+	echo "no"
+    fi
+    rm -f $TMPDIR/netnsid.c $TMPDIR/netnsid.o
+}
+
 check_ipset()
 {
     cat >$TMPDIR/ipsettest.c <<EOF
@@ -283,6 +300,8 @@ check_ipt_lib_dir
 
 echo -n "libc has setns: "
 check_setns
+echo -n "netns has peer id suport: "
+check_netnsid
 
 echo -n "SELinux support: "
 check_selinux
diff --git a/ip/Makefile b/ip/Makefile
index 2c742f3..5637bcf 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -16,6 +16,10 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(IP_CONFIG_NETNSID),y)
+	CFLAGS += -DHAVE_NETNSID
+endif
+
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
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
