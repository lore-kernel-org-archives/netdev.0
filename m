From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 13/27] bridge: use __vlan_hwaccel helpers
Date: Tue, 13 Dec 2016 01:12:36 +0100 (CET)
Message-ID: <e6e09a2f745a652382ac7859770ec16c75d8e149.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	"open list:NETFILTER {IP, IP6, ARP, EB,
	NF}TABLES" <netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
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

This removes assumption than vlan_tci != 0 when tag is present.

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/bridge/br_netfilter_hooks.c | 14 ++++++++------
 net/bridge/br_private.h         |  2 +-
 net/bridge/br_vlan.c            |  6 +++---
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index b12501a..2cc0747 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -682,10 +682,8 @@ static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff
 		return 0;
 	}
 
-	if (data->vlan_tci) {
-		skb->vlan_tci = data->vlan_tci;
-		skb->vlan_proto = data->vlan_proto;
-	}
+	if (data->vlan_proto)
+		__vlan_hwaccel_put_tag(skb, data->vlan_proto, data->vlan_tci);
 
 	skb_copy_to_linear_data_offset(skb, -data->size, data->mac, data->size);
 	__skb_push(skb, data->encap_size);
@@ -749,8 +747,12 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 
 		data = this_cpu_ptr(&brnf_frag_data_storage);
 
-		data->vlan_tci = skb->vlan_tci;
-		data->vlan_proto = skb->vlan_proto;
+		if (skb_vlan_tag_present(skb)) {
+			data->vlan_tci = skb->vlan_tci;
+			data->vlan_proto = skb->vlan_proto;
+		} else
+			data->vlan_proto = 0;
+
 		data->encap_size = nf_bridge_encap_header_len(skb);
 		data->size = ETH_HLEN + data->encap_size;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8ce621e..2efbdaf 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -819,7 +819,7 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 	int err = 0;
 
 	if (skb_vlan_tag_present(skb)) {
-		*vid = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
+		*vid = skb_vlan_tag_get_id(skb);
 	} else {
 		*vid = 0;
 		err = -EINVAL;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b6de4f4..ef94664 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -377,7 +377,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	}
 
 	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
-		skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(skb);
 out:
 	return skb;
 }
@@ -444,8 +444,8 @@ static bool __allowed_ingress(const struct net_bridge *br,
 			__vlan_hwaccel_put_tag(skb, br->vlan_proto, pvid);
 		else
 			/* Priority-tagged Frame.
-			 * At this point, We know that skb->vlan_tci had
-			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
+			 * At this point, We know that skb->vlan_tci VID
+			 * field was 0x000.
 			 * We update only VID field and preserve PCP field.
 			 */
 			skb->vlan_tci |= pvid;
-- 
2.10.2
