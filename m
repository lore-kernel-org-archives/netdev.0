From: Simon Horman <horms@verge.net.au>
Subject: [patch 1/3] IPVS: Fix sysctl warnings about missing strategy
Date: Wed, 14 Nov 2007 10:06:16 -0800
Message-ID: <20071114180821.777103318@natsuko.shinjuku.tokyo.vergenet.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36759 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757274AbXKNSKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:10:16 -0500
Content-Disposition: inline; filename=fix-sysctl-warnings-about-missing-strategy.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Borntraeger <borntraeger@de.ibm.com>

Running the latest git code I get the following messages during boot:
sysctl table check failed: /net/ipv4/vs/drop_entry .3.5.21.4 Missing strategy
[...]		  
sysctl table check failed: /net/ipv4/vs/drop_packet .3.5.21.5 Missing strategy
[...]
sysctl table check failed: /net/ipv4/vs/secure_tcp .3.5.21.6 Missing strategy
[...]
sysctl table check failed: /net/ipv4/vs/sync_threshold .3.5.21.24 Missing strategy

I removed the binary sysctl handler for those messages and also removed
the definitions in ip_vs.h. The alternative would be to implement a 
proper strategy handler, but syscall sysctl is deprecated.

There are other sysctl definitions that are commented out or work with 
the default sysctl_data strategy. I did not touch these. 

Eric, IPVS team, are you ok with that change?

CC: Eric W. Biederman <ebiederm@xmission.com>
CC: Wensong Zhang <wensong@linux-vs.org>
CC: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Acked-by: Simon Horman <horms@verge.net.au>

---
 include/net/ip_vs.h       |    4 ----
 kernel/sysctl_check.c     |    4 ----
 net/ipv4/ipvs/ip_vs_ctl.c |    4 ----
 3 files changed, 12 deletions(-)

Index: linux-2.6/include/net/ip_vs.h
===================================================================
--- linux-2.6.orig/include/net/ip_vs.h
+++ linux-2.6/include/net/ip_vs.h
@@ -336,9 +336,6 @@ enum {
 	NET_IPV4_VS_DEBUG_LEVEL=1,
 	NET_IPV4_VS_AMEMTHRESH=2,
 	NET_IPV4_VS_AMDROPRATE=3,
-	NET_IPV4_VS_DROP_ENTRY=4,
-	NET_IPV4_VS_DROP_PACKET=5,
-	NET_IPV4_VS_SECURE_TCP=6,
 	NET_IPV4_VS_TO_ES=7,
 	NET_IPV4_VS_TO_SS=8,
 	NET_IPV4_VS_TO_SR=9,
@@ -355,7 +352,6 @@ enum {
 	NET_IPV4_VS_LBLCR_EXPIRE=20,
 	NET_IPV4_VS_CACHE_BYPASS=22,
 	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
-	NET_IPV4_VS_SYNC_THRESHOLD=24,
 	NET_IPV4_VS_NAT_ICMP_SEND=25,
 	NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE=26,
 	NET_IPV4_VS_LAST
Index: linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1451,7 +1451,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_DROP_ENTRY,
 		.procname	= "drop_entry",
 		.data		= &sysctl_ip_vs_drop_entry,
 		.maxlen		= sizeof(int),
@@ -1459,7 +1458,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_defense_mode,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_DROP_PACKET,
 		.procname	= "drop_packet",
 		.data		= &sysctl_ip_vs_drop_packet,
 		.maxlen		= sizeof(int),
@@ -1467,7 +1465,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_defense_mode,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_SECURE_TCP,
 		.procname	= "secure_tcp",
 		.data		= &sysctl_ip_vs_secure_tcp,
 		.maxlen		= sizeof(int),
@@ -1597,7 +1594,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_SYNC_THRESHOLD,
 		.procname	= "sync_threshold",
 		.data		= &sysctl_ip_vs_sync_threshold,
 		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
Index: linux-2.6/kernel/sysctl_check.c
===================================================================
--- linux-2.6.orig/kernel/sysctl_check.c
+++ linux-2.6/kernel/sysctl_check.c
@@ -242,9 +242,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_VS_AMEMTHRESH,	"amemthresh" },
 	{ NET_IPV4_VS_DEBUG_LEVEL,	"debug_level" },
 	{ NET_IPV4_VS_AMDROPRATE,	"am_droprate" },
-	{ NET_IPV4_VS_DROP_ENTRY,	"drop_entry" },
-	{ NET_IPV4_VS_DROP_PACKET,	"drop_packet" },
-	{ NET_IPV4_VS_SECURE_TCP,	"secure_tcp" },
 	{ NET_IPV4_VS_TO_ES,		"timeout_established" },
 	{ NET_IPV4_VS_TO_SS,		"timeout_synsent" },
 	{ NET_IPV4_VS_TO_SR,		"timeout_synrecv" },
@@ -260,7 +257,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_VS_CACHE_BYPASS,	"cache_bypass" },
 	{ NET_IPV4_VS_EXPIRE_NODEST_CONN,	"expire_nodest_conn" },
 	{ NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,	"expire_quiescent_template" },
-	{ NET_IPV4_VS_SYNC_THRESHOLD,		"sync_threshold" },
 	{ NET_IPV4_VS_NAT_ICMP_SEND,	"nat_icmp_send" },
 	{ NET_IPV4_VS_LBLC_EXPIRE,		"lblc_expiration" },
 	{ NET_IPV4_VS_LBLCR_EXPIRE,		"lblcr_expiration" },

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

