From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 12/19] batman-adv: handle race condition for claims between gateways
Date: Thu,  6 Apr 2017 16:07:34 +0200
Message-ID: <20170406140741.30745-13-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Andreas Pape <APape@phoenixcontact.com>,
        Andreas Pape <apape@phoenixcontact.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32934 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755214AbdDFOHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:51 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Pape <APape@phoenixcontact.com>

Consider the following situation which has been found in a test setup:
Gateway B has claimed client C and gateway A has the same backbone
network as B. C sends a broad- or multicast to B and directly after
this packet decides to send another packet to A due to a better TQ
value. B will forward the broad-/multicast into the backbone as it is
the responsible gw and after that A will claim C as it has been
chosen by C as the best gateway. If it now happens that A claims C
before it has received the broad-/multicast forwarded by B (due to
backbone topology or due to some delay in B when forwarding the
packet) we get a critical situation: in the current code A will
immediately unclaim C when receiving the multicast due to the
roaming client scenario although the position of C has not changed
in the mesh. If this happens the multi-/broadcast forwarded by B
will be sent back into the mesh by A and we have looping packets
until one of the gateways claims C again.
In order to prevent this, unclaiming of a client due to the roaming
client scenario is only done after a certain time is expired after
the last claim of the client. 100 ms are used here, which should be
slow enough for big backbones and slow gateways but fast enough not
to break the roaming client use case.

Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Andreas Pape <apape@phoenixcontact.com>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 852a2be19845..d07e89ec8467 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1973,10 +1973,22 @@ bool batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		/* if yes, the client has roamed and we have
 		 * to unclaim it.
 		 */
-		batadv_handle_unclaim(bat_priv, primary_if,
-				      primary_if->net_dev->dev_addr,
-				      ethhdr->h_source, vid);
-		goto allow;
+		if (batadv_has_timed_out(claim->lasttime, 100)) {
+			/* only unclaim if the last claim entry is
+			 * older than 100 ms to make sure we really
+			 * have a roaming client here.
+			 */
+			batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_tx(): Roaming client %pM detected. Unclaim it.\n",
+				   ethhdr->h_source);
+			batadv_handle_unclaim(bat_priv, primary_if,
+					      primary_if->net_dev->dev_addr,
+					      ethhdr->h_source, vid);
+			goto allow;
+		} else {
+			batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_tx(): Race for claim %pM detected. Drop packet.\n",
+				   ethhdr->h_source);
+			goto handled;
+		}
 	}
 
 	/* check if it is a multicast/broadcast frame */
-- 
2.11.0
