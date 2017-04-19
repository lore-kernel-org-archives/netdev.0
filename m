From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH net v3] bridge: ebtables: fix reception of frames
	DNAT-ed to bridge device/port
Date: Wed, 19 Apr 2017 21:47:33 +0200
Message-ID: <20170419194733.19006-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When trying to redirect bridged frames to the bridge device itself or
a bridge port (brouting) via the dnat target then this currently fails:

The ethernet destination of the frame is dnat'ed to the MAC address of
the bridge device or port just fine. However, the IP code drops it in
the beginning of ip_input.c/ip_rcv() as the dnat target left
the skb->pkt_type as PACKET_OTHERHOST.

Fixing this by resetting skb->pkt_type to an appropriate type after
dnat'ing.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>

---

Changelog v3:
- moved pkt_type fixup into ebtable dnat code
  -> v1/v2 only fixed it for prerouting/dnat so far, now tested
     and verified that v3 fixes it for brouting/dnat, too
- updated commit message

Changelog v2:
- refrain from altering pkt_type for multicast packets
  with a unicast destination MAC
---
 net/bridge/netfilter/ebt_dnat.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 4e0b0c3..21acb53 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -9,6 +9,7 @@
  */
 #include <linux/module.h>
 #include <net/sock.h>
+#include "../br_private.h"
 #include <linux/netfilter.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_bridge/ebtables.h>
@@ -18,11 +19,32 @@ static unsigned int
 ebt_dnat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
+	struct net_device *dev;
 
 	if (!skb_make_writable(skb, 0))
 		return EBT_DROP;
 
 	ether_addr_copy(eth_hdr(skb)->h_dest, info->mac);
+
+	if (is_multicast_ether_addr(info->mac)) {
+		if (is_broadcast_ether_addr(info->mac))
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_MULTICAST;
+	} else {
+		rcu_read_lock();
+		if (xt_hooknum(par) != NF_BR_BROUTING)
+			dev = br_port_get_rcu(xt_in(par))->br->dev;
+		else
+			dev = xt_in(par);
+
+		if (ether_addr_equal(info->mac, dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+		rcu_read_unlock();
+	}
+
 	return info->target;
 }
 
-- 
2.1.4
