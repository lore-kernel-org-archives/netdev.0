From: Yuriy Kaminskiy <yumkam@gmail.com>
Subject: [iputils][patch 01-07] setuid/capabilities fixups
Date: Wed, 09 Jan 2013 23:41:00 +0400
Message-ID: <kckh4a$taf$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602010600040601080307"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43681 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231Ab3AITou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 14:44:50 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tt1aC-0008M2-2j
	for netdev@vger.kernel.org; Wed, 09 Jan 2013 20:45:04 +0100
Received: from 37.190.36.44 ([37.190.36.44])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 20:45:04 +0100
Received: from yumkam by 37.190.36.44 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 20:45:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030602010600040601080307
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit

Run ping, look at /proc/`pidof ping`/status -> oops (capabilities are not
[permanently] dropped, some of uids are not dropped, etc). Fix assorted issues
with setuid and capabilities drop. Limited testing only, please review/check
carefully.



--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0001-arping-ping-ping6-traceroute2-clockdiff-drop-fsuid-a.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-arping-ping-ping6-traceroute2-clockdiff-drop-fsuid-a.pa";
 filename*1="tch"

>From bc01c19df465bec369ded83bf48b069c6ad462d2 Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 01:43:01 +0400
Subject: [PATCH 1/7] arping, ping, ping6, traceroute2, clockdiff: drop fsuid
 at start

Prevent ignoring netfilter -m owner checks. With this patch ping
correctly blocked by iptables rules, e.g.:
$ sudo iptables -I OUTPUT -m owner --uid-owner $UID -j DROP
$ ping www.google.com
---
 arping.c      |    9 +++++++++
 clockdiff.c   |    8 ++++++++
 ping_common.c |    9 +++++++++
 traceroute6.c |    8 ++++++++
 4 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/arping.c b/arping.c
index 35408c1..bdf81e9 100644
--- a/arping.c
+++ b/arping.c
@@ -27,6 +27,9 @@
 #include <sys/prctl.h>
 #include <sys/capability.h>
 #endif
+#ifdef __linux__
+#include <sys/fsuid.h>
+#endif
 
 #include <netdb.h>
 #include <unistd.h>
@@ -229,6 +232,12 @@ int modify_capability_raw(int on)
 		perror("arping: setuid");
 		return -1;
 	}
+#ifdef __linux__
+	if (on) {
+	    /* FIXME: error handling? setfsuid() have weird return code */
+	    setfsuid(getuid());
+	}
+#endif
 #endif
 	return 0;
 }
diff --git a/clockdiff.c b/clockdiff.c
index 7c1ea1b..f12da2d 100644
--- a/clockdiff.c
+++ b/clockdiff.c
@@ -3,6 +3,9 @@
 #include <sys/param.h>
 #include <stdio.h>
 #include <unistd.h>
+#ifdef __linux__
+#include <sys/fsuid.h>
+#endif
 #include <stdlib.h>
 #include <math.h>
 #include <string.h>
@@ -561,6 +564,11 @@ main(int argc, char *argv[])
 		usage();
 	}
 
+#ifdef __linux__
+	// FIXME: error handling? setfsuid() have weird return code
+	setfsuid(getuid());
+#endif
+
 	sock_raw = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
 	s_errno = errno;
 
diff --git a/ping_common.c b/ping_common.c
index 7f82851..12c87a4 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -2,6 +2,9 @@
 #include <ctype.h>
 #include <sched.h>
 #include <math.h>
+#ifdef __linux__
+#include <sys/fsuid.h>
+#endif
 
 int options;
 
@@ -175,6 +178,12 @@ int modify_capability(int on)
 		perror("seteuid");
 		return -1;
 	}
+#ifdef __linux__
+	if (on) {
+		/* FIXME: error handling? setfsuid() have weird return code */
+		setfsuid(uid);
+	}
+#endif
 
 	return 0;
 }
diff --git a/traceroute6.c b/traceroute6.c
index 0538d4b..a14ddb6 100644
--- a/traceroute6.c
+++ b/traceroute6.c
@@ -266,6 +266,9 @@ char copyright[] =
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
+#ifdef __linux__
+#include <sys/fsuid.h>
+#endif
 
 #include "SNAPSHOT.h"
 
@@ -343,6 +346,11 @@ int main(int argc, char *argv[])
 	int ch, i, on, probe, seq, tos, ttl;
 	int socket_errno;
 
+#ifdef __linux__
+	// FIXME: error handling? setfsuid() have weird return code
+	setfsuid(getuid());
+#endif
+
 	icmp_sock = socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
 	socket_errno = errno;
 
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0002-ping-permanently-drop-capabilities-before-entering-m.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-ping-permanently-drop-capabilities-before-entering-m.pa";
 filename*1="tch"

>From da09261219322ec5116f016a858f11f83902deb9 Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 01:44:49 +0400
Subject: [PATCH 2/7] ping: permanently drop capabilities before entering main
 loop

---
 ping.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ping.c b/ping.c
index c0366cd..7ac1217 100644
--- a/ping.c
+++ b/ping.c
@@ -587,6 +587,8 @@ main(int argc, char **argv)
 
 	setup(icmp_sock);
 
+	drop_capabilities();
+
 	main_loop(icmp_sock, packet, packlen);
 }
 
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0003-arping-use-seteuid-for-temporal-uid-changes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0003-arping-use-seteuid-for-temporal-uid-changes.patch"

>From c4b6600fe72e169c64e47f85a973484053f23861 Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 01:46:44 +0400
Subject: [PATCH 3/7] arping: use seteuid for temporal uid changes

---
 arping.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arping.c b/arping.c
index bdf81e9..a35fafd 100644
--- a/arping.c
+++ b/arping.c
@@ -228,7 +228,7 @@ int modify_capability_raw(int on)
 
 	cap_free(cap_p);
 #else
-	if (setuid(on ? euid : getuid())) {
+	if (seteuid(on ? euid : getuid())) {
 		perror("arping: setuid");
 		return -1;
 	}
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0004-arping-ping_common-reset-euid-before-permanent-drop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0004-arping-ping_common-reset-euid-before-permanent-drop.pat";
 filename*1="ch"

>From d8f54230f344c92f2120230dc24ac9c5d6672da9 Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 01:53:39 +0400
Subject: [PATCH 4/7] arping, ping_common: reset euid before permanent drop

setuid drop saved uid only if euid is 0
---
 arping.c      |    4 ++++
 ping_common.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arping.c b/arping.c
index a35fafd..0033f33 100644
--- a/arping.c
+++ b/arping.c
@@ -269,6 +269,10 @@ void drop_capabilities(void)
 
 	cap_free(cap_p);
 #else
+	if (seteuid(euid)) {
+		perror("arping: setuid");
+		return -1;
+	}
 	if (setuid(getuid()) < 0) {
 		perror("arping: setuid");
 		exit(-1);
diff --git a/ping_common.c b/ping_common.c
index 12c87a4..39b2c74 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -199,6 +199,10 @@ void drop_capabilities(void)
 	}
 	cap_free(cap);
 #else
+	if (seteuid(euid)) {
+		perror("seteuid");
+		exit(-1);
+	}
 	if (setuid(getuid())) {
 		perror("ping: setuid");
 		exit(-1);
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0005-ping-ping6-arping-clockdiff-Fix-CAP_SETUID-setuid-in.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0005-ping-ping6-arping-clockdiff-Fix-CAP_SETUID-setuid-in.pa";
 filename*1="tch"

>From 00f63e1afc9d07e9793574304ef34a5bb54629b7 Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 01:56:07 +0400
Subject: [PATCH 5/7] ping, ping6, arping, clockdiff: Fix CAP_SETUID <->
 setuid() interaction

setuid() only drops saved uid if process have CAP_SETUID.
Drop capabilities only after setuid().
---
 arping.c      |   30 +++++++++++++++---------------
 clockdiff.c   |    8 +++++---
 ping_common.c |   30 +++++++++++++++---------------
 3 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/arping.c b/arping.c
index 0033f33..3c02abf 100644
--- a/arping.c
+++ b/arping.c
@@ -161,6 +161,21 @@ void limit_capabilities(void)
 #ifdef CAPABILITIES
 	cap_t cap_p;
 
+	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
+		perror("arping: prctl");
+		exit(-1);
+	}
+
+	if (setuid(getuid()) < 0) {
+		perror("arping: setuid");
+		exit(-1);
+	}
+
+	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
+		perror("arping: prctl");
+		exit(-1);
+	}
+
 	cap_p = cap_get_proc();
 	if (!cap_p) {
 		perror("arping: cap_get_proc");
@@ -184,21 +199,6 @@ void limit_capabilities(void)
 		}
 	}
 
-	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
-		perror("arping: prctl");
-		exit(-1);
-	}
-
-	if (setuid(getuid()) < 0) {
-		perror("arping: setuid");
-		exit(-1);
-	}
-
-	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
-		perror("arping: prctl");
-		exit(-1);
-	}
-
 	cap_free(cap_p);
 #else
 	euid = geteuid();
diff --git a/clockdiff.c b/clockdiff.c
index f12da2d..540366d 100644
--- a/clockdiff.c
+++ b/clockdiff.c
@@ -536,6 +536,11 @@ usage() {
 }
 
 void drop_rights(void) {
+	if (setuid(getuid())) {
+		perror("clockdiff: setuid");
+		exit(-1);
+	}
+	{
 #ifdef CAPABILITIES
 	cap_t caps = cap_init();
 	if (cap_set_proc(caps)) {
@@ -544,9 +549,6 @@ void drop_rights(void) {
 	}
 	cap_free(caps);
 #endif
-	if (setuid(getuid())) {
-		perror("clockdiff: setuid");
-		exit(-1);
 	}
 }
 
diff --git a/ping_common.c b/ping_common.c
index 39b2c74..08c8582 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -80,6 +80,21 @@ void limit_capabilities(void)
 	cap_t cap_p;
 	cap_flag_value_t cap_ok;
 
+	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
+		perror("ping: prctl");
+		exit(-1);
+	}
+
+	if (setuid(getuid()) < 0) {
+		perror("setuid");
+		exit(-1);
+	}
+
+	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
+		perror("ping: prctl");
+		exit(-1);
+	}
+
 	cap_cur_p = cap_get_proc();
 	if (!cap_cur_p) {
 		perror("ping: cap_get_proc");
@@ -109,21 +124,6 @@ void limit_capabilities(void)
 		exit(-1);
 	}
 
-	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
-		perror("ping: prctl");
-		exit(-1);
-	}
-
-	if (setuid(getuid()) < 0) {
-		perror("setuid");
-		exit(-1);
-	}
-
-	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
-		perror("ping: prctl");
-		exit(-1);
-	}
-
 	cap_free(cap_p);
 	cap_free(cap_cur_p);
 #endif
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0006-ninfod-use-u-without-capabilities-too.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0006-ninfod-use-u-without-capabilities-too.patch"

>From 32ad925cba9aca3513561c7655c9f61642a341ca Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 02:57:15 +0400
Subject: [PATCH 6/7] ninfod: use -u without capabilities too

---
 ninfod/ninfod.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ninfod/ninfod.c b/ninfod/ninfod.c
index d1b99d9..0f54da3 100644
--- a/ninfod/ninfod.c
+++ b/ninfod/ninfod.c
@@ -561,7 +561,7 @@ static void drop_capabilities(void)
 
 	cap_free(cap_p);
 #else
-	if (setuid(getuid()) < 0) {
+	if (setuid(opt_u ? opt_u : getuid()) < 0) {
 		DEBUG(LOG_ERR, "setuid: %s\n", strerror(errno));
 		exit(-1);
 	}
-- 
1.7.6.3


--------------030602010600040601080307
Content-Type: text/x-diff;
 name="0007-ninfod-fix-capabilities-setting.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0007-ninfod-fix-capabilities-setting.patch"

>From ab1b55fd572c1e28f762ef4feff911053c5eb1fd Mon Sep 17 00:00:00 2001
From: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Date: Wed, 2 Jan 2013 03:08:30 +0400
Subject: [PATCH 7/7] ninfod: fix capabilities setting

1) -u option failed to change real uid too (likely leaving it as root);
2) it failed to drop saved uid;
---
 ninfod/ninfod.c |   58 +++++++++++++++++-------------------------------------
 1 files changed, 18 insertions(+), 40 deletions(-)

diff --git a/ninfod/ninfod.c b/ninfod/ninfod.c
index 0f54da3..3e24c18 100644
--- a/ninfod/ninfod.c
+++ b/ninfod/ninfod.c
@@ -469,16 +469,28 @@ static void do_daemonize(void)
 /* --------- */
 #ifdef HAVE_LIBCAP
 static const cap_value_t cap_net_raw = CAP_NET_RAW;
-static const cap_value_t cap_setuid =  CAP_SETUID; 
-static cap_flag_value_t cap_ok;
-#else
-static uid_t euid;
 #endif
 
 static void limit_capabilities(void)
 {
 #ifdef HAVE_LIBCAP
 	cap_t cap_p, cap_cur_p;
+	cap_flag_value_t cap_ok;
+
+	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
+		DEBUG(LOG_ERR, "prctl: %s\n", strerror(errno));
+		exit(-1);
+	}
+
+	if (setuid(opt_u ? opt_u : getuid()) < 0) {
+		DEBUG(LOG_ERR, "setuid: %s\n", strerror(errno));
+		exit(-1);
+	}
+
+	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
+		DEBUG(LOG_ERR, "prctl: %s\n", strerror(errno));
+		exit(-1);
+	}
 
 	cap_p = cap_init();
 	if (!cap_p) {
@@ -492,32 +504,20 @@ static void limit_capabilities(void)
 		exit(-1);
         }
 
-	/* net_raw + setuid / net_raw */
 	cap_get_flag(cap_cur_p, CAP_NET_RAW, CAP_PERMITTED, &cap_ok);
 	if (cap_ok != CAP_CLEAR) {
 		cap_set_flag(cap_p, CAP_PERMITTED, 1, &cap_net_raw, CAP_SET);
 		cap_set_flag(cap_p, CAP_EFFECTIVE, 1, &cap_net_raw, CAP_SET);
 	}
 
-	cap_get_flag(cap_cur_p, CAP_SETUID, CAP_PERMITTED, &cap_ok);
-	if (cap_ok != CAP_CLEAR)
-		cap_set_flag(cap_p, CAP_PERMITTED, 1, &cap_setuid, CAP_SET);
-
 	if (cap_set_proc(cap_p) < 0) {
 		DEBUG(LOG_ERR, "cap_set_proc: %s\n", strerror(errno));
 		if (errno != EPERM)
 			exit(-1);
 	}
 
-	if (prctl(PR_SET_KEEPCAPS, 1) < 0) {
-		DEBUG(LOG_ERR, "prctl: %s\n", strerror(errno));
-		exit(-1);
-	}
-
 	cap_free(cap_cur_p);
 	cap_free(cap_p);
-#else
-	euid = geteuid();
 #endif
 }
 
@@ -532,28 +532,6 @@ static void drop_capabilities(void)
 		exit(-1);
 	}
 
-	/* setuid / setuid */
-	if (cap_ok != CAP_CLEAR) {
-		cap_set_flag(cap_p, CAP_PERMITTED, 1, &cap_setuid, CAP_SET);
-		cap_set_flag(cap_p, CAP_EFFECTIVE, 1, &cap_setuid, CAP_SET);
-
-		if (cap_set_proc(cap_p) < 0) {
-			DEBUG(LOG_ERR, "cap_set_proc: %s\n", strerror(errno));
-			exit(-1);
-		}
-	}
-
-	if (seteuid(opt_u ? opt_u : getuid()) < 0) {
-		DEBUG(LOG_ERR, "setuid: %s\n", strerror(errno));
-		exit(-1);
-	}
-
-	if (prctl(PR_SET_KEEPCAPS, 0) < 0) {
-		DEBUG(LOG_ERR, "prctl: %s\n", strerror(errno));
-		exit(-1);
-	}
-
-	cap_clear(cap_p);
 	if (cap_set_proc(cap_p) < 0) {
 		DEBUG(LOG_ERR, "cap_set_proc: %s\n", strerror(errno));
 		exit(-1);
@@ -637,14 +615,14 @@ int main (int argc, char **argv)
 
 	appname = argv[0];
 
+	parse_args(argc, argv);
+
 	limit_capabilities();
 
 	sock = open_sock();
 	if (sock < 0)
 		sock_errno = errno;
 
-	parse_args(argc, argv);
-
 	drop_capabilities();
 
 	if (opt_h || opt_v)
-- 
1.7.6.3


--------------030602010600040601080307--
