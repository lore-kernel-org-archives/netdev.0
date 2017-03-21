From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH v2] bridge: ebtables: fix reception of frames
	DNAT-ed to bridge device
Date: Tue, 21 Mar 2017 23:28:45 +0100
Message-ID: <20170321222845.8373-1-linus.luessing@c0d3.blue>
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

When trying to redirect bridged frames to the bridge device itself
via the ebtables nat-prerouting chain and the dnat target then this
currently fails:

The ethernet destination of the frame is dnat'ed to the MAC address of
the bridge itself just fine and the correctly altered frame can even
be captured via a tcpdump on br0 (with or without promisc mode).

However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
as the dnat target did not update the skb->pkt_type. If after
dnat'ing the packet is now destined to us then the skb->pkt_type
needs to be updated from PACKET_OTHERHOST to PACKET_HOST, too.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>

---
Changelog v2:
* refrain from altering pkt_type for multicast packets
  with a unicast destination MAC
---
 net/bridge/br_input.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 013f2290b..fd7bc4c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -198,8 +198,13 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (dst) {
 		unsigned long now = jiffies;
 
-		if (dst->is_local)
+		if (dst->is_local) {
+			/* fix up potential DNAT inconsistencies */
+			if (skb->pkt_type == PACKET_OTHERHOST)
+				skb->pkt_type = PACKET_HOST;
+
 			return br_pass_frame_up(skb);
+		}
 
 		if (now != dst->used)
 			dst->used = now;
-- 
2.1.4
