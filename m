From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next] nstat: add sctp snmp support
Date: Mon,  5 Sep 2016 11:35:02 +0800
Message-ID: <1473046502-5395-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33302 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIEDfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 23:35:15 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so9003430pfe.0
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 20:35:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP module was not load by default. But this should be OK since we will not
load table if fdopen() failed, also opening the proc file won't load SCTP
kernel module.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 misc/nstat.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/misc/nstat.c b/misc/nstat.c
index 6143719..1cb6c7e 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -76,6 +76,11 @@ static int net_snmp6_open(void)
 	return generic_proc_open("PROC_NET_SNMP6", "net/snmp6");
 }
 
+static int net_sctp_snmp_open(void)
+{
+	return generic_proc_open("PROC_NET_SCTP_SNMP", "net/sctp/snmp");
+}
+
 struct nstat_ent {
 	struct nstat_ent *next;
 	char		 *id;
@@ -247,6 +252,16 @@ static void load_ugly_table(FILE *fp)
 	}
 }
 
+static void load_sctp_snmp(void)
+{
+	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
+
+	if (fp) {
+		load_good_table(fp);
+		fclose(fp);
+	}
+}
+
 static void load_snmp(void)
 {
 	FILE *fp = fdopen(net_snmp_open(), "r");
@@ -391,6 +406,7 @@ static void update_db(int interval)
 	load_netstat();
 	load_snmp6();
 	load_snmp();
+	load_sctp_snmp();
 
 	h = kern_db;
 	kern_db = n;
@@ -450,6 +466,7 @@ static void server_loop(int fd)
 	load_netstat();
 	load_snmp6();
 	load_snmp();
+	load_sctp_snmp();
 
 	for (;;) {
 		int status;
@@ -706,6 +723,7 @@ int main(int argc, char *argv[])
 		load_netstat();
 		load_snmp6();
 		load_snmp();
+		load_sctp_snmp();
 		if (info_source[0] == 0)
 			strcpy(info_source, "kernel");
 	}
-- 
2.5.5
