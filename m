From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 2/4] ss: create a function to print info about netlink sockets
Date: Thu, 21 Mar 2013 13:33:24 +0400
Message-ID: <1363858406-1489-3-git-send-email-avagin@openvz.org>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
 <1363858406-1489-1-git-send-email-avagin@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Andrey Vagin <avagin@openvz.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28913 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab3CUJfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 05:35:05 -0400
In-Reply-To: <1363858406-1489-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be reused for printing info about netlink sockets, when
socket diag is used for retrieving information.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 misc/ss.c | 130 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 72 insertions(+), 58 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index bde344a..962f304 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2474,6 +2474,73 @@ static int packet_show(struct filter *f)
 	return 0;
 }
 
+static void netlink_show_one(struct filter *f,
+				int prot, int pid, unsigned groups,
+				int rq, int wq,
+				unsigned long long sk, unsigned long long cb)
+{
+	if (f->f) {
+		struct tcpstat tst;
+		tst.local.family = AF_NETLINK;
+		tst.remote.family = AF_NETLINK;
+		tst.rport = -1;
+		tst.lport = pid;
+		tst.local.data[0] = prot;
+		tst.remote.data[0] = 0;
+		if (run_ssfilter(f->f, &tst) == 0)
+			return;
+	}
+
+	if (netid_width)
+		printf("%-*s ", netid_width, "nl");
+	if (state_width)
+		printf("%-*s ", state_width, "UNCONN");
+	printf("%-6d %-6d ", rq, wq);
+	if (resolve_services && prot == 0)
+		printf("%*s:", addr_width, "rtnl");
+	else if (resolve_services && prot == 3)
+		printf("%*s:", addr_width, "fw");
+	else if (resolve_services && prot == 4)
+		printf("%*s:", addr_width, "tcpdiag");
+	else
+		printf("%*d:", addr_width, prot);
+	if (pid == -1) {
+		printf("%-*s ", serv_width, "*");
+	} else if (resolve_services) {
+		int done = 0;
+		if (!pid) {
+			done = 1;
+			printf("%-*s ", serv_width, "kernel");
+		} else if (pid > 0) {
+			char procname[64];
+			FILE *fp;
+			sprintf(procname, "%s/%d/stat",
+				getenv("PROC_ROOT") ? : "/proc", pid);
+			if ((fp = fopen(procname, "r")) != NULL) {
+				if (fscanf(fp, "%*d (%[^)])", procname) == 1) {
+					sprintf(procname+strlen(procname), "/%d", pid);
+					printf("%-*s ", serv_width, procname);
+					done = 1;
+				}
+				fclose(fp);
+			}
+		}
+		if (!done)
+			printf("%-*d ", serv_width, pid);
+	} else {
+		printf("%-*d ", serv_width, pid);
+	}
+	printf("%*s*%-*s",
+	       addr_width, "", serv_width, "");
+
+	if (show_details) {
+		printf(" sk=%llx cb=%llx groups=0x%08x", sk, cb, groups);
+	}
+	printf("\n");
+
+	return;
+}
+
 static int netlink_show(struct filter *f)
 {
 	FILE *fp;
@@ -2486,6 +2553,10 @@ static int netlink_show(struct filter *f)
 	if (!(f->states & (1<<SS_CLOSE)))
 		return 0;
 
+	if (!getenv("PROC_NET_NETLINK") && !getenv("PROC_ROOT") &&
+		netlink_show_netlink(f, NULL) == 0)
+		return 0;
+
 	if ((fp = net_netlink_open()) == NULL)
 		return -1;
 	fgets(buf, sizeof(buf)-1, fp);
@@ -2495,64 +2566,7 @@ static int netlink_show(struct filter *f)
 		       &sk,
 		       &prot, &pid, &groups, &rq, &wq, &cb, &rc);
 
-		if (f->f) {
-			struct tcpstat tst;
-			tst.local.family = AF_NETLINK;
-			tst.remote.family = AF_NETLINK;
-			tst.rport = -1;
-			tst.lport = pid;
-			tst.local.data[0] = prot;
-			tst.remote.data[0] = 0;
-			if (run_ssfilter(f->f, &tst) == 0)
-				continue;
-		}
-
-		if (netid_width)
-			printf("%-*s ", netid_width, "nl");
-		if (state_width)
-			printf("%-*s ", state_width, "UNCONN");
-		printf("%-6d %-6d ", rq, wq);
-		if (resolve_services && prot == 0)
-			printf("%*s:", addr_width, "rtnl");
-		else if (resolve_services && prot == 3)
-			printf("%*s:", addr_width, "fw");
-		else if (resolve_services && prot == 4)
-			printf("%*s:", addr_width, "tcpdiag");
-		else
-			printf("%*d:", addr_width, prot);
-		if (pid == -1) {
-			printf("%-*s ", serv_width, "*");
-		} else if (resolve_services) {
-			int done = 0;
-			if (!pid) {
-				done = 1;
-				printf("%-*s ", serv_width, "kernel");
-			} else if (pid > 0) {
-				char procname[64];
-				FILE *fp;
-				sprintf(procname, "%s/%d/stat",
-					getenv("PROC_ROOT") ? : "/proc", pid);
-				if ((fp = fopen(procname, "r")) != NULL) {
-					if (fscanf(fp, "%*d (%[^)])", procname) == 1) {
-						sprintf(procname+strlen(procname), "/%d", pid);
-						printf("%-*s ", serv_width, procname);
-						done = 1;
-					}
-					fclose(fp);
-				}
-			}
-			if (!done)
-				printf("%-*d ", serv_width, pid);
-		} else {
-			printf("%-*d ", serv_width, pid);
-		}
-		printf("%*s*%-*s",
-		       addr_width, "", serv_width, "");
-
-		if (show_details) {
-			printf(" sk=%llx cb=%llx groups=0x%08x", sk, cb, groups);
-		}
-		printf("\n");
+		netlink_show_one(f, prot, pid, groups, rq, wq, sk, cb);
 	}
 
 	return 0;
-- 
1.7.11.7
