From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/12: {ip,ip6,arp}_tables: fix incorrect loop detection
Date: Thu, 26 Mar 2009 20:02:40 +0100 (MET)
Message-ID: <20090326190234.23365.39498.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39223 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759042AbZCZTCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 15:02:42 -0400
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1f9352ae2253a97b07b34dcf16ffa3b4ca12c558
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 25 19:26:35 2009 +0100

    netfilter: {ip,ip6,arp}_tables: fix incorrect loop detection
    
    Commit e1b4b9f ([NETFILTER]: {ip,ip6,arp}_tables: fix exponential worst-case
    search for loops) introduced a regression in the loop detection algorithm,
    causing sporadic incorrectly detected loops.
    
    When a chain has already been visited during the check, it is treated as
    having a standard target containing a RETURN verdict directly at the
    beginning in order to not check it again. The real target of the first
    rule is then incorrectly treated as STANDARD target and checked not to
    contain invalid verdicts.
    
    Fix by making sure the rule does actually contain a standard target.
    
    Based on patch by Francis Dupont <Francis_Dupont@isc.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 4b35dba..4f454ce 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -388,7 +388,9 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 			    && unconditional(&e->arp)) || visited) {
 				unsigned int oldpos, size;
 
-				if (t->verdict < -NF_MAX_VERDICT - 1) {
+				if ((strcmp(t->target.u.user.name,
+					    ARPT_STANDARD_TARGET) == 0) &&
+				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
 								t->verdict);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 41c59e3..82ee7c9 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -488,7 +488,9 @@ mark_source_chains(struct xt_table_info *newinfo,
 			    && unconditional(&e->ip)) || visited) {
 				unsigned int oldpos, size;
 
-				if (t->verdict < -NF_MAX_VERDICT - 1) {
+				if ((strcmp(t->target.u.user.name,
+			    		    IPT_STANDARD_TARGET) == 0) &&
+				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
 								t->verdict);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index e59662b..e89cfa3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -517,7 +517,9 @@ mark_source_chains(struct xt_table_info *newinfo,
 			    && unconditional(&e->ipv6)) || visited) {
 				unsigned int oldpos, size;
 
-				if (t->verdict < -NF_MAX_VERDICT - 1) {
+				if ((strcmp(t->target.u.user.name,
+					    IP6T_STANDARD_TARGET) == 0) &&
+				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
 								t->verdict);
