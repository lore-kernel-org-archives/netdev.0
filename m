From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 1/5] ipvs: Initialize mcast addr at compile time
Date: Thu, 17 Jul 2008 00:04:45 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0807162344420.17284@titan.stealer.net>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net> <1214760766-1526-2-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:51429 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039AbYGPWFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 18:05:05 -0400
In-Reply-To: <1214760766-1526-2-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to do it at runtime, the values are constant.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

The hton* in the last version should be __constant_hton*. hton* normally 
works for initialization in global scope, but the check for constant 
values seems to be hidden in some ifdef and is not available in all cases.

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index eff54ef..b889276 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -141,7 +141,11 @@ char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 
 /* multicast addr */
-static struct sockaddr_in mcast_addr;
+static struct sockaddr_in mcast_addr = {
+	.sin_family		= AF_INET,
+	.sin_port		= __constant_htons(IP_VS_SYNC_PORT),
+	.sin_addr.s_addr	= __constant_htonl(IP_VS_SYNC_GROUP),
+};
 
 
 static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
@@ -864,11 +868,6 @@ static int sync_thread(void *startup)
 	/* set the maximum length of sync message */
 	set_sync_mesg_maxlen(state);
 
-	/* set up multicast address */
-	mcast_addr.sin_family = AF_INET;
-	mcast_addr.sin_port = htons(IP_VS_SYNC_PORT);
-	mcast_addr.sin_addr.s_addr = htonl(IP_VS_SYNC_GROUP);
-
 	add_wait_queue(&sync_wait, &wait);
 
 	set_sync_pid(state, task_pid_nr(current));
