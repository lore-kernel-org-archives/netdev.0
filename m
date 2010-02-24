From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Wed, 24 Feb 2010 16:19:19 -0500
Message-ID: <20100224211919.GD15380@hmsreliant.think-freely.org>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430705EF62@ala-mail09.corp.ad.wrs.com>
 <20100223011116.GA2021@localhost.localdomain>
 <29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
 <20100223160936.GA16435@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
 <20100224185340.GB15380@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33234 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758074Ab0BXVTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 16:19:21 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted in my previous note, I'd agreed tht the preiviously posted patches for
the various tipc patches we encountered were sufficient for the oops at hand.
This patch closes the race condition thats left open after the application of
those patches.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/tipc/tipc.h |    3 ++-
 net/tipc/net.c          |    8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)


diff --git a/include/net/tipc/tipc.h b/include/net/tipc/tipc.h
index 9566608..14076e9 100644
--- a/include/net/tipc/tipc.h
+++ b/include/net/tipc/tipc.h
@@ -54,7 +54,8 @@ u32 tipc_get_addr(void);
 
 #define TIPC_NOT_RUNNING  0
 #define TIPC_NODE_MODE    1
-#define TIPC_NET_MODE     2
+#define TIPC_TRANS_MODE	  2
+#define TIPC_NET_MODE     3
 
 typedef void (*tipc_mode_event)(void *usr_handle, int mode, u32 addr);
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7906608..daeafe7 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -278,7 +278,7 @@ int tipc_net_start(u32 addr)
 	tipc_cfg_stop();
 
 	tipc_own_addr = addr;
-	tipc_mode = TIPC_NET_MODE;
+	tipc_mode = TIPC_TRANS_MODE;
 	tipc_named_reinit();
 	tipc_port_reinit();
 
@@ -295,18 +295,20 @@ int tipc_net_start(u32 addr)
 	info("Started in network mode\n");
 	info("Own node address %s, network identity %u\n",
 	     addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
+	tipc_mode = TIPC_NET_MODE;
 	return 0;
 }
 
 void tipc_net_stop(void)
 {
-	if (tipc_mode != TIPC_NET_MODE)
+	if (tipc_mode < TIPC_TRANS_MODE)
 		return;
+	tipc_mode = TIPC_TRANS_MODE;
 	write_lock_bh(&tipc_net_lock);
 	tipc_bearer_stop();
-	tipc_mode = TIPC_NODE_MODE;
 	tipc_bclink_stop();
 	net_stop();
+	tipc_mode = TIPC_NODE_MODE;
 	write_unlock_bh(&tipc_net_lock);
 	info("Left network mode \n");
 }
