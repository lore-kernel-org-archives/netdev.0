From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] bridge: do not expire mdb entry when bridge
	still uses it
Date: Fri,  8 Mar 2013 10:07:03 +0800
Message-ID: <1362708423-23932-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	Adam Baker <linux@baker-net.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
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

From: Cong Wang <amwang@redhat.com>

This is a long-standing bug and reported several times:
https://bugzilla.redhat.com/show_bug.cgi?id=880035
http://marc.info/?l=linux-netdev&m=136164389416341&w=2

This bug can be observed in virt environment, when a KVM guest
communicates with the host via multicast. After some time (should
be 260 sec, I didn't measure), the multicast traffic suddenly
terminates.

This is due to the mdb entry for bridge itself expires automatically,
it should not expire as long as the bridge still generates multicast
traffic. It should expire when the bridge leaves the multicast group,
OR when there is no multicast traffic on this bridge.

I fix this by adding another bool which is set when there is
multicast traffic goes to the bridge, cleared in the expire timer and
when IGMP leave is received. I ran omping for 15 minutes, everything
looks good now.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 828e2bc..c706619 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -99,9 +99,11 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb, vid);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
-			if ((mdst && mdst->mglist) ||
-			    br_multicast_is_router(br))
+			bool to_br = mdst && mdst->mglist;
+			if (to_br || br_multicast_is_router(br))
 				skb2 = skb;
+			if (to_br)
+				mdst->busy = true;
 			br_multicast_forward(mdst, skb, skb2);
 			skb = NULL;
 			if (!skb2)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 923fbea..4b12a0d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -228,11 +228,16 @@ static void br_multicast_group_expired(unsigned long data)
 	if (!netif_running(br->dev) || timer_pending(&mp->timer))
 		goto out;
 
-	mp->mglist = false;
-
 	if (mp->ports)
 		goto out;
 
+	if (mp->mglist && mp->busy) {
+		mp->busy = false;
+		goto out;
+	}
+
+	mp->mglist = false;
+
 	mdb = mlock_dereference(br->mdb, br);
 
 	hlist_del_rcu(&mp->hlist[mdb->ver]);
@@ -1280,6 +1285,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 			mod_timer(&mp->timer, time);
 		}
 
+		mp->busy = false;
 		goto out;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3cbf5be..bb9a3e4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -112,6 +112,7 @@ struct net_bridge_mdb_entry
 	struct timer_list		timer;
 	struct br_ip			addr;
 	bool				mglist;
+	bool				busy; /* update this only when mglist == true */
 };
 
 struct net_bridge_mdb_htable
