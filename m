From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/4 v2] ipvlan: protect against concurrent link removal
Date: Sat, 28 Mar 2015 19:13:23 +0100
Message-ID: <56e26de10fa9de258124e3a1b448eb305132bf2a.1427566140.git.jbenc@redhat.com>
References: <cover.1427566140.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbbC1SNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 14:13:41 -0400
In-Reply-To: <cover.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding and removing to the 'ipvlans' list is already done using _rcu list
operations.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8a542b9340c4..568628f95aa2 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -193,7 +193,8 @@ static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_PAUSE))
 		return;
 
-	list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
 		if (local && (ipvlan == in_dev))
 			continue;
 
@@ -220,6 +221,7 @@ static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
 mcast_acct:
 		ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
 	}
+	rcu_read_unlock();
 
 	/* Locally generated? ...Forward a copy to the main-device as
 	 * well. On the RX side we'll ignore it (wont give it to any
-- 
1.8.3.1
