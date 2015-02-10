From: Bryton Lee <brytonlee01@gmail.com>
Subject: [PATCH] prevent the read ahead of /proc/slabinfo in ss take 2
Date: Tue, 10 Feb 2015 10:46:00 +0800
Message-ID: <1423536360-5298-1-git-send-email-brytonlee01@gmail.com>
Cc: eric.dumazet@gmail.com, brytonlee01@gmail.com
To: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:50396 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbbBJCql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 21:46:41 -0500
Received: by mail-pa0-f51.google.com with SMTP id eu11so16144284pac.10
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 18:46:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ss reads ahead of /proc/slabinfo whatever slabstat will be used or not in future.
this will cause huge system delay when the kernel hires SLAB allocator(SLUB allocator is ok). when program reads
/proc/slabinfo, it will call s_show() in SLAB allocator level, and s_show() calls spin_lock_irq(&l3->list_lock)
then iterate on whole three lists. if one slab has about 900 million objects (for example dentry),
it will cause more than 1000ms delay.

so this patch prevents the read ahead of /proc/slabinfo, ss runs with most parameters not using slabstat at all.
and this patch also change slabstat and slabstat_valid to static.

Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
---
 misc/ss.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 7fc0a99..5fa6259 100644
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
@@ -2230,6 +2231,9 @@ static int tcp_show(struct filter *f, int socktype)
 	 * it is able to give us some memory for snapshot.
 	 */
 	if (1) {
+		if (!slabstat_valid)
+			get_slabstat(&slabstat);
+
 		int guess = slabstat.socks+slabstat.tcp_syns;
 		if (f->states&(1<<SS_TIME_WAIT))
 			guess += slabstat.tcp_tws;
@@ -3196,6 +3200,9 @@ static int print_summary(void)
 	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
 		perror("ss: get_snmpstat");
 
+	if (!slabstat_valid)
+		get_slabstat(&slabstat);
+
 	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
 
 	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
@@ -3543,8 +3550,6 @@ int main(int argc, char *argv[])
 	argc -= optind;
 	argv += optind;
 
-	get_slabstat(&slabstat);
-
 	if (do_summary) {
 		print_summary();
 		if (do_default && argc == 0)
-- 
2.0.5
