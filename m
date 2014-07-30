From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] bridge: Don't include NDA_VLAN for FDB entries
	with vid 0
Date: Wed, 30 Jul 2014 13:31:51 +0900
Message-ID: <1406694711-8521-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

An FDB entry with vlan_id 0 doesn't mean it is used in vlan 0, but used when
vlan_filtering is disabled.

There is inconsistency around NDA_VLAN whose payload is 0 - even if we add
an entry by RTM_NEWNEIGH without any NDA_VLAN, and even though adding an
entry with NDA_VLAN 0 is prohibited, we get an entry with NDA_VLAN 0 by
RTM_GETNEIGH.

Dumping an FDB entry with vlan_id 0 shouldn't include NDA_VLAN.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b524c36..02359e8 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -631,7 +631,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
 
-	if (nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
+	if (fdb->vlan_id && nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
-- 
1.8.1.2
