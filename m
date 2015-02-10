From: Bryton Lee <brytonlee01@gmail.com>
Subject: [PATCH] prevent the read ahead of /proc/slabinfo in ss - take 3
Date: Tue, 10 Feb 2015 13:52:13 +0800
Message-ID: <1423547533-6727-1-git-send-email-brytonlee01@gmail.com>
Cc: eric.dumazet@gmail.com, brytonlee01@gmail.com
To: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54980 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533AbbBJFwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 00:52:43 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so38899092pad.4
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 21:52:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prevent the read ahead of /proc/slabinfo in ss.

Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
---
 misc/ss.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 7fc0a99..74721b5 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -616,7 +616,8 @@ struct slabstat
 	int skbs;
 };
 
-struct slabstat slabstat;
+static struct slabstat slabstat;
+static int slabstat_valid = 0;
 
 static const char *slabstat_ids[] =
 {
@@ -655,6 +656,8 @@ static int get_slabstat(struct slabstat *s)
 			break;
 	}
 
+    slabstat_valid = 1;
+
 	fclose(fp);
 	return 0;
 }
@@ -2230,6 +2233,9 @@ static int tcp_show(struct filter *f, int socktype)
 	 * it is able to give us some memory for snapshot.
 	 */
 	if (1) {
+		if (!slabstat_valid)
+			get_slabstat(&slabstat);
+
 		int guess = slabstat.socks+slabstat.tcp_syns;
 		if (f->states&(1<<SS_TIME_WAIT))
 			guess += slabstat.tcp_tws;
@@ -3196,6 +3202,9 @@ static int print_summary(void)
 	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
 		perror("ss: get_snmpstat");
 
+	if (!slabstat_valid)
+		get_slabstat(&slabstat);
+
 	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
 
 	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
@@ -3543,8 +3552,6 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
-	get_slabstat(&slabstat);
-
 	if (do_summary) {
 		print_summary();
 		if (do_default && argc == 0)
-- 
2.0.5
