From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bridge: avoid unnecessary read of jiffies
Date: Tue, 7 Feb 2017 08:46:46 -0800
Message-ID: <20170207084646.70dc888a@xeon-e3>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
	<1486227909-18319-5-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1486227909-18319-5-git-send-email-nikolay@cumulusnetworks.com>
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


Jiffies is volatile so read it once.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/bridge/br_fdb.c   | 6 ++++--
 net/bridge/br_input.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5028691fa68a..5693168e88b6 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -592,13 +592,15 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				br_warn(br, "received packet on %s with own address as source address (addr:%pM, vlan:%u)\n",
 					source->dev->name, addr, vid);
 		} else {
+			unsigned long now = jiffies;
+
 			/* fastpath: update of existing entry */
 			if (unlikely(source != fdb->dst)) {
 				fdb->dst = source;
 				fdb_modified = true;
 			}
-			if (jiffies != fdb->updated)
-				fdb->updated = jiffies;
+			if (now != fdb->updated)
+				fdb->updated = now;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
 			if (unlikely(fdb_modified))
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 220943f920d2..4615a9b3e26c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -195,11 +195,13 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	}
 
 	if (dst) {
+		unsigned long now = jiffies;
+
 		if (dst->is_local)
 			return br_pass_frame_up(skb);
 
-		if (jiffies != dst->used)
-			dst->used = jiffies;
+		if (now != dst->used)
+			dst->used = now;
 		br_forward(dst->dst, skb, local_rcv, false);
 	} else {
 		if (!mcast_hit)
-- 
2.11.0
