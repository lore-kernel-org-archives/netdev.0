From: Dan McGee <dan@archlinux.org>
Subject: [PATCH] iproute2: fix several warnings emitted by clang scan-build
Date: Fri, 15 Jul 2011 14:59:26 -0500
Message-ID: <1310759966-10465-1-git-send-email-dan@archlinux.org>
Cc: Dan McGee <dan@archlinux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61666 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab1GOT7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 15:59:30 -0400
Received: by yxi11 with SMTP id 11so687346yxi.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 12:59:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* genl/genl.c: remove unused basename logic, avoid dereference of
  possibly NULL variable
* ip/iptuntap.c: avoid double open and leak of file handle
* misc/arpd.c: zero out socklen structure
* misc/{ifstat,nstat,rtacct}.c: ensure uptime is initialized if
  /proc/uptime cannot be opened
* tc/m_xt.c: only unset fields if m is non-NULL

Signed-off-by: Dan McGee <dan@archlinux.org>
---
 genl/genl.c   |   11 ++---------
 ip/iptuntap.c |    2 +-
 misc/arpd.c   |    2 ++
 misc/ifstat.c |    2 +-
 misc/nstat.c  |    2 +-
 misc/rtacct.c |    2 +-
 tc/m_xt.c     |   15 ++++++++-------
 7 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/genl/genl.c b/genl/genl.c
index 7ec24eb..2bee1bf 100644
--- a/genl/genl.c
+++ b/genl/genl.c
@@ -109,14 +109,6 @@ static void usage(void)
 
 int main(int argc, char **argv)
 {
-	char *basename;
-
-	basename = strrchr(argv[0], '/');
-	if (basename == NULL)
-		basename = argv[0];
-	else
-		basename++;
-
 	while (argc > 1) {
 		if (argv[1][0] != '-')
 			break;
@@ -144,8 +136,9 @@ int main(int argc, char **argv)
 		int ret;
 		struct genl_util *a = NULL;
 		a = get_genl_kind(argv[1]);
-		if (NULL == a) {
+		if (!a) {
 			fprintf(stderr,"bad genl %s\n",argv[1]);
+			exit(-1);
 		}
 
 		ret = a->parse_genlopt(a, argc-1, argv+1);
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 2a8aa7f..588926c 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -47,7 +47,7 @@ static void usage(void)
 
 static int tap_add_ioctl(struct ifreq *ifr, uid_t uid, gid_t gid)
 {
-	int fd = open(TUNDEV, O_RDWR);
+	int fd;
 	int ret = -1;
 
 #ifdef IFF_TUN_EXCL
diff --git a/misc/arpd.c b/misc/arpd.c
index 128c49d..647b197 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -485,6 +485,8 @@ void get_arp_pkt(void)
 	DBT dbkey, dbdat;
 	int n;
 
+	memset(&sll, 0, sizeof(sll));
+
 	n = recvfrom(pset[0].fd, buf, sizeof(buf), MSG_DONTWAIT,
 		     (struct sockaddr*)&sll, &sll_len);
 	if (n < 0) {
diff --git a/misc/ifstat.c b/misc/ifstat.c
index 1cd55c4..7d33f5e 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -708,7 +708,7 @@ int main(int argc, char *argv[])
 		}
 		if (!ignore_history) {
 			FILE *tfp;
-			long uptime;
+			long uptime = -1;
 			if ((tfp = fopen("/proc/uptime", "r")) != NULL) {
 				if (fscanf(tfp, "%ld", &uptime) != 1)
 					uptime = -1;
diff --git a/misc/nstat.c b/misc/nstat.c
index 4f73c62..2f06ffd 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -560,7 +560,7 @@ int main(int argc, char *argv[])
 		}
 		if (!ignore_history) {
 			FILE *tfp;
-			long uptime;
+			long uptime = -1;
 			if ((tfp = fopen("/proc/uptime", "r")) != NULL) {
 				if (fscanf(tfp, "%ld", &uptime) != 1)
 					uptime = -1;
diff --git a/misc/rtacct.c b/misc/rtacct.c
index ab8fdbb..49168bd 100644
--- a/misc/rtacct.c
+++ b/misc/rtacct.c
@@ -580,7 +580,7 @@ int main(int argc, char *argv[])
 
 		if (!ignore_history) {
 			FILE *tfp;
-			long uptime;
+			long uptime = -1;
 			if ((tfp = fopen("/proc/uptime", "r")) != NULL) {
 				if (fscanf(tfp, "%ld", &uptime) != 1)
 					uptime = -1;
diff --git a/tc/m_xt.c b/tc/m_xt.c
index 86e223b..b3fdc1d 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -252,13 +252,14 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 
 	optind = 0;
 	xtables_free_opts(1);
-	/* Clear flags if target will be used again */
-        m->tflags=0;
-        m->used=0;
-	/* Free allocated memory */
-        if (m->t)
-            free(m->t);
-
+	if (m) {
+		/* Clear flags if target will be used again */
+		m->tflags = 0;
+		m->used = 0;
+		/* Free allocated memory */
+		if (m->t)
+			free(m->t);
+	}
 
 	return 0;
 
-- 
1.7.6

