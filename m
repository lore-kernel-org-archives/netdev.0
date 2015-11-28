From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/5] get rid of remaining -Wunused-result warnings
Date: Sat, 28 Nov 2015 01:00:04 +0100
Message-ID: <1448668805-28074-5-git-send-email-phil@nwl.cc>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54952 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbbK1AAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:19 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although not fundamentally necessary to check return codes in these
spots, preventing the warnings will put new ones into focus.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c      |  6 ++++--
 misc/lnstat_util.c |  3 ++-
 misc/nstat.c       |  6 ++++--
 misc/ss.c          | 18 ++++++++++++++----
 4 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 20a8db45985be..ac5c29c89184a 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -819,7 +819,8 @@ int main(int argc, char *argv[])
 			}
 			if (uptime >= 0 && time(NULL) >= stb.st_mtime+uptime) {
 				fprintf(stderr, "ifstat: history is aged out, resetting\n");
-				ftruncate(fileno(hist_fp), 0);
+				if (ftruncate(fileno(hist_fp), 0))
+					perror("ifstat: ftruncate");
 			}
 		}
 
@@ -862,7 +863,8 @@ int main(int argc, char *argv[])
 	}
 
 	if (!no_update) {
-		ftruncate(fileno(hist_fp), 0);
+		if (ftruncate(fileno(hist_fp), 0))
+			perror("ifstat: ftruncate");
 		rewind(hist_fp);
 
 		json_output = 0;
diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index 433e992976eac..70a77c5649f9b 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -138,7 +138,8 @@ static int lnstat_scan_fields(struct lnstat_file *lf)
 	char buf[FGETS_BUF_SIZE];
 
 	rewind(lf->fp);
-	fgets(buf, sizeof(buf)-1, lf->fp);
+	if (!fgets(buf, sizeof(buf)-1, lf->fp))
+		return -1;
 
 	return __lnstat_scan_fields(lf, buf);
 }
diff --git a/misc/nstat.c b/misc/nstat.c
index 267e515ff987c..99705286d279c 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -649,7 +649,8 @@ int main(int argc, char *argv[])
 			}
 			if (uptime >= 0 && time(NULL) >= stb.st_mtime+uptime) {
 				fprintf(stderr, "nstat: history is aged out, resetting\n");
-				ftruncate(fileno(hist_fp), 0);
+				if (ftruncate(fileno(hist_fp), 0) < 0)
+					perror("nstat: ftruncate");
 			}
 		}
 
@@ -693,7 +694,8 @@ int main(int argc, char *argv[])
 			dump_incr_db(stdout);
 	}
 	if (!no_update) {
-		ftruncate(fileno(hist_fp), 0);
+		if (ftruncate(fileno(hist_fp), 0) < 0)
+			perror("nstat: ftruncate");
 		rewind(hist_fp);
 
 		json_output = 0;
diff --git a/misc/ss.c b/misc/ss.c
index 7928573285e4e..d509009429de1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -528,7 +528,8 @@ static void user_ent_hash_build(void)
 				snprintf(tmp, sizeof(tmp), "%s/%d/stat",
 					root, pid);
 				if ((fp = fopen(tmp, "r")) != NULL) {
-					fscanf(fp, "%*d (%[^)])", p);
+					if (fscanf(fp, "%*d (%[^)])", p) < 1)
+						; /* ignore */
 					fclose(fp);
 				}
 			}
@@ -660,7 +661,10 @@ static int get_slabstat(struct slabstat *s)
 
 	cnt = sizeof(*s)/sizeof(int);
 
-	fgets(buf, sizeof(buf), fp);
+	if (!fgets(buf, sizeof(buf), fp)) {
+		fclose(fp);
+		return -1;
+	}
 	while(fgets(buf, sizeof(buf), fp) != NULL) {
 		int i;
 		for (i=0; i<sizeof(slabstat_ids)/sizeof(slabstat_ids[0]); i++) {
@@ -2725,7 +2729,10 @@ static int unix_show(struct filter *f)
 
 	if ((fp = net_unix_open()) == NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
+	if (!fgets(buf, sizeof(buf)-1, fp)) {
+		fclose(fp);
+		return -1;
+	}
 
 	if (memcmp(buf, "Peer", 4) == 0)
 		newformat = 1;
@@ -3210,7 +3217,10 @@ static int netlink_show(struct filter *f)
 
 	if ((fp = net_netlink_open()) == NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
+	if (!fgets(buf, sizeof(buf)-1, fp)) {
+		fclose(fp);
+		return -1;
+	}
 
 	while (fgets(buf, sizeof(buf)-1, fp)) {
 		sscanf(buf, "%llx %d %d %x %d %d %llx %d",
-- 
2.5.0
