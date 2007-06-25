From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH] Age Entry For IPv4 Route Table
Date: Mon, 25 Jun 2007 10:28:38 +0530
Message-ID: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:32872 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953AbXFYE6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 00:58:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5P4woIl010726
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 00:58:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5P4woQZ554850
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 00:58:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5P4woOH020093
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 00:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in the routing table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table and providing
the interface for this value via /proc/net/route.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 net/ipv4/fib_hash.c   |   16 +++++++++++-----
 net/ipv4/fib_lookup.h |    1 +
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 07e843a..2000f1e 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -448,6 +448,7 @@ static int fn_hash_insert(struct fib_tab
 			fa->fa_info = fi;
 			fa->fa_type = cfg->fc_type;
 			fa->fa_scope = cfg->fc_scope;
+			fa->fa_age = jiffies;
 			state = fa->fa_state;
 			fa->fa_state &= ~FA_S_ACCESSED;
 			fib_hash_genid++;
@@ -507,6 +508,7 @@ static int fn_hash_insert(struct fib_tab
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
+	new_fa->fa_age = jiffies;
 
 	/*
 	 * Insert new entry to the list.
@@ -998,10 +1000,11 @@ static int fib_seq_show(struct seq_file
 	struct fib_alias *fa;
 	struct fib_info *fi;
 
+#define JIFFIES_TO_SECS(jiffies)   ((jiffies)/HZ)
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-127s\n", "Iface\tDestination\tGateway "
 			   "\tFlags\tRefCnt\tUse\tMetric\tMask\t\tMTU"
-			   "\tWindow\tIRTT");
+			   "\tWindow\tIRTT\tAge");
 		goto out;
 	}
 
@@ -1014,17 +1017,20 @@ static int fib_seq_show(struct seq_file
 	flags	= fib_flag_trans(fa->fa_type, mask, fi);
 	if (fi)
 		snprintf(bf, sizeof(bf),
-			 "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
+			 "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u\t%lu",
 			 fi->fib_dev ? fi->fib_dev->name : "*", prefix,
 			 fi->fib_nh->nh_gw, flags, 0, 0, fi->fib_priority,
 			 mask, (fi->fib_advmss ? fi->fib_advmss + 40 : 0),
 			 fi->fib_window,
-			 fi->fib_rtt >> 3);
+			 fi->fib_rtt >> 3,
+			 JIFFIES_TO_SECS(jiffies - fa->fa_age));	
 	else
 		snprintf(bf, sizeof(bf),
-			 "*\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
-			 prefix, 0, flags, 0, 0, 0, mask, 0, 0, 0);
+			 "*\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u\t%lu",
+			 prefix, 0, flags, 0, 0, 0, mask, 0, 0, 0, 0);
 	seq_printf(seq, "%-127s\n", bf);
+
+#undef JIFFIES_TO_SECS
 out:
 	return 0;
 }
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index eef9eec..cc403d4 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -13,6 +13,7 @@ struct fib_alias {
 	u8			fa_type;
 	u8			fa_scope;
 	u8			fa_state;
+	unsigned long		fa_age;
 };
 
 #define FA_S_ACCESSED	0x01
-- 
1.4.3.4

