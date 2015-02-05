From: zhuyj <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Thu,  5 Feb 2015 02:20:37 -0500
Message-ID: <1423120837-28102-1-git-send-email-zyjzyj2000@gmail.com>
Cc: eulfsam <ulf.samuelsson@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	zhuyj <zyjzyj2000@gmail.com>
To: netdev@vger.kernel.org, stefan.costandache@windriver.com,
	alexandre.dietsch@windriver.com, yue.tao@windriver.com,
	clinton.slabbert@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38368 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbbBEHUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 02:20:17 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so9773346iga.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 23:20:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: eulfsam <ulf.samuelsson@ericsson.com> 

When the neighbor statemachine is in PROBE state, it will normally send
a number of unicast ARP requests (number defined in "ucast_probes" entry
in the proc file system, default=3) and if no reply is received, it will
change state to FAILED.

Enabling CONFIG_ARP_PROBE_BCAST, will make the statemachine try to send
broadcast ARP requests, and only enter FAILED state if the broadcast ARP
requests did not receive a reply.

Enabling CONFIG_ARP_PROBE_BCAST, makes the IPv4 ARP behaviour more
similar to the IPv6 Neighbor Discovery protocol, and is neccessary,
if the other end only responds to broadcast ARPs.

CC: David S. Miller <davem@davemloft.net>
CC: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: eulfsam <ulf.samuelsson@ericsson.com>
Signed-off-by: zhuyj <zyjzyj2000@gmail.com>
---
 net/core/neighbour.c |  4 ++++
 net/ipv4/Kconfig     | 17 +++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8d614c9..50f5ee2 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -830,10 +830,14 @@ out:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
+#ifdef CONFIG_ARP_PROBE_BCAST
+	return p->ucast_probes + p->app_probes + p->mcast_probes;
+#else
 	int max_probes = NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES);
 	if (!(n->nud_state & NUD_PROBE))
 		max_probes += NEIGH_VAR(p, MCAST_PROBES);
 	return max_probes;
+#endif
 }
 
 static void neigh_invalidate(struct neighbour *neigh)
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index bd29016..4d13edb 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -259,6 +259,23 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
 
+config ARP_PROBE_BCAST
+	bool "IP: ARP send broadcast ARP, if probing using unicast fails"
+	default	y
+	---help---
+	  When the neighbor statemachine is in PROBE state, it will
+	  normally send a number of unicast ARP requests
+	  (number defined in "ucast_probes" entry in the proc file system, default=3)
+	  and if no reply is received, it will change state to FAILED.
+  
+	  Saying Y here, will make the statemachine try to send broadcast ARP
+	  requests, and only enter FAILED state if the broadcast ARP requests did not
+	  receive a reply.
+
+	  Enabling this, makes the IPv4 ARP behaviour more similar to the IPv6
+	  Neighbor Discovery protocol, and is neccessary, if the other end
+	  only responds to broadcast ARPs.
+
 config SYN_COOKIES
 	bool "IP: TCP syncookie support"
 	---help---
-- 
1.9.1
