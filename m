From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2] bridge: multicast: start querier timer when running user-space stp
Date: Fri, 19 Jun 2015 01:45:50 -0700
Message-ID: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32953 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbbFSIqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 04:46:04 -0400
Received: by padev16 with SMTP id ev16so80998637pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 01:46:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When STP is running in user-space and querier is configured, the
querier timer is not started when a port goes to a non-blocking state.
This patch unifies the user- and kernel-space stp multicast port enable
path and enables it in all states different from blocking. Note that when a
port goes in BR_STATE_DISABLED it's not enabled because that is handled
in the beginning of the port list loop.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: Repurposed for net-next and implemented Herbert's suggestion for
    unifying both user- and kernel-space multicast enable port paths.

 net/bridge/br_stp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 45f1ff113af9..e7ab74b405a1 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -428,7 +428,6 @@ static void br_make_forwarding(struct net_bridge_port *p)
 	else
 		br_set_state(p, BR_STATE_LEARNING);
 
-	br_multicast_enable_port(p);
 	br_log_state(p);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
@@ -462,6 +461,8 @@ void br_port_state_selection(struct net_bridge *br)
 			}
 		}
 
+		if (p->state != BR_STATE_BLOCKING)
+			br_multicast_enable_port(p);
 		if (p->state == BR_STATE_FORWARDING)
 			++liveports;
 	}
-- 
2.4.3
