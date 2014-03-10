From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv2 2/2] bridge: multicast: enable snooping on general queries only
Date: Mon, 10 Mar 2014 22:25:25 +0100
Message-ID: <1394486725-4992-2-git-send-email-linus.luessing@web.de>
References: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Jan Stancek <jstancek@redhat.com>,
	Florian Westphal <fwestpha@redhat.com>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:49988 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754317AbaCJV0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 17:26:21 -0400
In-Reply-To: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this check someone could easily create a denial of service
by injecting multicast-specific queries to enable the bridge
snooping part if no real querier issuing periodic general queries
is present on the link which would result in the bridge wrongly
shutting down ports for multicast traffic as the bridge did not learn
about these listeners.

With this patch the snooping code is enabled upon receiving valid,
general queries only.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
v2: unchanged

 net/bridge/br_multicast.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index e56bae4..93067ec 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1127,9 +1127,10 @@ static void br_multicast_query_received(struct n=
et_bridge *br,
 					struct net_bridge_port *port,
 					struct bridge_mcast_querier *querier,
 					int saddr,
+					bool is_general_query,
 					unsigned long max_delay)
 {
-	if (saddr)
+	if (saddr && is_general_query)
 		br_multicast_update_querier_timer(br, querier, max_delay);
 	else if (timer_pending(&querier->timer))
 		return;
@@ -1190,7 +1191,7 @@ static int br_ip4_multicast_query(struct net_brid=
ge *br,
 	}
=20
 	br_multicast_query_received(br, port, &br->ip4_querier, !!iph->saddr,
-				    max_delay);
+				    !group, max_delay);
=20
 	if (!group)
 		goto out;
@@ -1282,7 +1283,8 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 	}
=20
 	br_multicast_query_received(br, port, &br->ip6_querier,
-				    !ipv6_addr_any(&ip6h->saddr), max_delay);
+				    !ipv6_addr_any(&ip6h->saddr),
+				    is_general_query, max_delay);
=20
 	if (!group)
 		goto out;
--=20
1.7.10.4
