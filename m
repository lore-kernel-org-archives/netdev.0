From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Rename static setns() function
Date: Fri, 15 Jul 2011 16:41:12 -0700
Message-ID: <m1d3hbm7s7.fsf@fess.ebiederm.org>
References: <1310755099-32438-1-git-send-email-dan@archlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dan McGee <dan@archlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47269 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab1GOXlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 19:41:17 -0400
In-Reply-To: <1310755099-32438-1-git-send-email-dan@archlinux.org> (Dan
	McGee's message of "Fri, 15 Jul 2011 13:38:19 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dan can you try this patch I think it does a better job at dealing
with libc defining setns but I don't have a brand new libc handy
to test with.

Eric

From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 15 Jul 2011 16:36:33 -0700
Subject: [PATCH] iproute2: Auto-detect the presence of setns in libc

If libc has setns present use that version instead of
rolling the syscall wrapper by hand.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 configure    |   24 ++++++++++++++++++++++++
 ip/Makefile  |    6 ++++++
 ip/ipnetns.c |    2 ++
 3 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 69797ab..cfcc82a 100755
--- a/configure
+++ b/configure
@@ -163,6 +163,27 @@ check_ipt_lib_dir()
 	echo "not found!"
 }
 
+check_setns()
+{
+cat >/tmp/setnstest.c <<EOF
+#include <sched.h>
+int main(int argc, char **argv) 
+{
+	(void)setns(0,0);
+	return 0;
+}
+EOF
+gcc -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+	echo "IP_CONFIG_SETNS:=y" >>Config
+	echo "yes"
+else
+	echo "no"
+fi
+rm -f /tmp/setnstest.c /tmp/setnstest
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 
 echo "TC schedulers"
@@ -178,3 +199,6 @@ check_ipt
 
 echo -n "iptables modules directory: "
 check_ipt_lib_dir
+
+echo -n "libc has setns: "
+check_setns
diff --git a/ip/Makefile b/ip/Makefile
index 2ee4e7c..8d03993 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,6 +7,12 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
 
 RTMONOBJ=rtmon.o
 
+include ../Config
+
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index db7007c..dff3497 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -28,6 +28,7 @@
 #define MNT_DETACH	0x00000002	/* Just detach from the tree */
 #endif /* MNT_DETACH */
 
+#ifndef HAVE_SETNS
 static int setns(int fd, int nstype)
 {
 #ifdef __NR_setns
@@ -37,6 +38,7 @@ static int setns(int fd, int nstype)
 	return -1;
 #endif
 }
+#endif /* HAVE_SETNS */
 
 
 static int touch(const char *path, mode_t mode)
-- 
1.7.5.1.217.g4e3aa

