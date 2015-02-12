From: Bryton Lee <brytonlee01@gmail.com>
Subject: [PATCH] prevent the read ahead of /proc/slabinfo in ss - take 4
Date: Thu, 12 Feb 2015 14:16:04 +0800
Message-ID: <1423721764-6778-1-git-send-email-brytonlee01@gmail.com>
Cc: eric.dumazet@gmail.com, brytonlee01@gmail.com
To: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:42292 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbbBLGQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 01:16:27 -0500
Received: by pdbfp1 with SMTP id fp1so9732724pdb.9
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 22:16:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
---
 misc/ss.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0a6a65e..e86fa5f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -617,7 +617,7 @@ struct slabstat
 	int skbs;
 };
 
-struct slabstat slabstat;
+static struct slabstat slabstat;
 
 static const char *slabstat_ids[] =
 {
@@ -633,6 +633,10 @@ static int get_slabstat(struct slabstat *s)
 	char buf[256];
 	FILE *fp;
 	int cnt;
+	static int slabstat_valid;
+
+	if (slabstat_valid)
+		return 0;
 
 	memset(s, 0, sizeof(*s));
 
@@ -656,6 +660,8 @@ static int get_slabstat(struct slabstat *s)
 			break;
 	}
 
+	slabstat_valid = 1;
+
 	fclose(fp);
 	return 0;
 }
@@ -2231,6 +2237,8 @@ static int tcp_show(struct filter *f, int socktype)
 	 * it is able to give us some memory for snapshot.
 	 */
 	if (1) {
+		get_slabstat(&slabstat);
+
 		int guess = slabstat.socks+slabstat.tcp_syns;
 		if (f->states&(1<<SS_TIME_WAIT))
 			guess += slabstat.tcp_tws;
@@ -3197,6 +3205,8 @@ static int print_summary(void)
 	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
 		perror("ss: get_snmpstat");
 
+	get_slabstat(&slabstat);
+
 	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
 
 	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
@@ -3550,8 +3560,6 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
-	get_slabstat(&slabstat);
-
 	if (do_summary) {
 		print_summary();
 		if (do_default && argc == 0)
-- 
2.0.5
