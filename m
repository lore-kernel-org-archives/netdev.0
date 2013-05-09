From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 3/4] batman-adv: make DAT drop ARP requests targeting local clients
Date: Thu,  9 May 2013 12:56:46 +0200
Message-ID: <1368097007-817-4-git-send-email-ordex@autistici.org>
References: <1368097007-817-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44810 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab3EIK6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 06:58:35 -0400
In-Reply-To: <1368097007-817-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the outgoing ARP request snooping routine in DAT, ARP
Request sent by local clients which are supposed to be
replied by other local clients can be silently dropped.

The destination host will reply by itself through the LAN
and therefore there is no need to involve DAT.

Reported-by: Carlos Quijano <carlos@crqgestion.es>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Tested-by: Carlos Quijano <carlos@crqgestion.es>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/distributed-arp-table.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 8e15d96..2399920 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -837,6 +837,19 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 
 	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
 	if (dat_entry) {
+		/* If the ARP request is destined for a local client the local
+		 * client will answer itself. DAT would only generate a
+		 * duplicate packet.
+		 *
+		 * Moreover, if the soft-interface is enslaved into a bridge, an
+		 * additional DAT answer may trigger kernel warnings about
+		 * a packet coming from the wrong port.
+		 */
+		if (batadv_is_my_client(bat_priv, dat_entry->mac_addr)) {
+			ret = true;
+			goto out;
+		}
+
 		skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
 				     bat_priv->soft_iface, ip_dst, hw_src,
 				     dat_entry->mac_addr, hw_src);
-- 
1.8.1.5
