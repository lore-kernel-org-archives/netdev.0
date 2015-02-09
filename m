From: Bryton Lee <brytonlee01@gmail.com>
Subject: [PATCH] prevent the read ahead of /proc/slabinfo in ss
Date: Mon,  9 Feb 2015 19:37:10 +0800
Message-ID: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
Cc: brytonlee01@gmail.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34313 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759670AbbBILiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 06:38:09 -0500
Received: by pdjg10 with SMTP id g10so24439879pdj.1
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 03:38:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ss reads ahead of /proc/slabinfo whatever slabstat will be used or not in future.
this will cause huge system delay when the kernel hires SLAB allocator(SLUB allocator is ok). when program reads
/proc/slabinfo, it will call s_show() in SLAB allocator level, and s_show() calls spin_lock_irq(&l3->list_lock) 
then iterate on whole three lists. if one slab has about 900 million objects (for example dentry),
it will cause more than 1000ms delay. 

so this patch prevents the read ahead of /proc/slabinfo, ss runs with most parameters not using slabstat at all.

Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
---
 misc/ss.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f434f57..987dd70 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -617,6 +617,7 @@ struct slabstat
 };
 
 struct slabstat slabstat;
+int slabstat_valid = 0;
 
 static const char *slabstat_ids[] =
 {
@@ -2128,6 +2129,9 @@ static int tcp_show(struct filter *f, int socktype)
 	 * it is able to give us some memory for snapshot.
 	 */
 	if (1) {
+		if (!slabstat_valid)
+			get_slabstat(&slabstat);
+
 		int guess = slabstat.socks+slabstat.tcp_syns;
 		if (f->states&(1<<SS_TIME_WAIT))
 			guess += slabstat.tcp_tws;
@@ -3157,6 +3161,9 @@ static int print_summary(void)
 	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
 		perror("ss: get_snmpstat");
 
+	if (!slabstat_valid)
+		get_slabstat(&slabstat);
+
 	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
 
 	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
@@ -3504,8 +3511,6 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
-	get_slabstat(&slabstat);
-
 	if (do_summary) {
 		print_summary();
 		if (do_default && argc == 0)
-- 
2.0.5
