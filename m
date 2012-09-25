From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH net 1/2] batman-adv: Fix change mac address
	of soft iface.
Date: Tue, 25 Sep 2012 17:57:16 +0200
Message-ID: <1348588637-18441-2-git-send-email-ordex@autistici.org>
References: <1348588637-18441-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1348588637-18441-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Def <def-QFKgK+z4sOrR7s880joybQ@public.gmane.org>

Into function interface_set_mac_addr, the function tt_local_add was
invoked before updating dev->dev_addr. The new MAC address was not
tagged as NoPurge.

Signed-off-by: Def <def-QFKgK+z4sOrR7s880joybQ@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/soft-interface.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 109ea2a..21c5357 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -100,18 +100,21 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
 	struct sockaddr *addr = p;
+	uint8_t old_addr[ETH_ALEN];
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	memcpy(old_addr, dev->dev_addr, ETH_ALEN);
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+
 	/* only modify transtable if it has been initialized before */
 	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_ACTIVE) {
-		batadv_tt_local_remove(bat_priv, dev->dev_addr,
+		batadv_tt_local_remove(bat_priv, old_addr,
 				       "mac address changed", false);
 		batadv_tt_local_add(dev, addr->sa_data, BATADV_NULL_IFINDEX);
 	}
 
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	return 0;
 }
-- 
1.7.12
