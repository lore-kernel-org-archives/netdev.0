From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/4] ipvlan: protect against concurrent link removal
Date: Fri, 27 Mar 2015 18:30:24 +0100
Message-ID: <c29592aedc0b747cfd8be4889566cbb7587da7e6.1427476903.git.jbenc@redhat.com>
References: <cover.1427476903.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548AbbC0Rao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 13:30:44 -0400
In-Reply-To: <cover.1427476903.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding and removing to the 'ipvlans' list is already done using _rcu list
operations.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 9f705fc9e0ef..77b7f56d1551 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -192,7 +192,8 @@ static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_PAUSE))
 		return;
 
-	list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
 		if (local && (ipvlan == in_dev))
 			continue;
 
@@ -219,6 +220,7 @@ static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
 mcast_acct:
 		ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
 	}
+	rcu_read_unlock();
 
 	/* Locally generated? ...Forward a copy to the main-device as
 	 * well. On the RX side we'll ignore it (wont give it to any
-- 
1.8.3.1
