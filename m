From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 02/18] net: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:44:58 +0800
Message-ID: <1381837514-50660-3-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
are called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 net/bridge/br_fdb.c                   |  6 ++----
 net/bridge/br_multicast.c             | 13 ++++---------
 net/bridge/br_stp_bpdu.c              | 11 ++++-------
 net/mac80211/rx.c                     |  6 ++----
 net/netfilter/ipset/ip_set_hash_gen.h |  3 +--
 5 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index ffd5874..e47dfe5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -465,10 +465,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	if (likely(fdb)) {
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
-			if (net_ratelimit())
-				br_warn(br, "received packet on %s with "
-					"own address as source address\n",
-					source->dev->name);
+			net_ratelimited_function(br_warn, br, "received packet on %s "
+				"with own address as source address\n", source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
 			fdb->dst = source;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d1c5786..c00d8a2 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -530,11 +530,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 	max = mdb->max;
 
 	if (unlikely(count > br->hash_elasticity && count)) {
-		if (net_ratelimit())
-			br_info(br, "Multicast hash table "
-				"chain limit reached: %s\n",
-				port ? port->dev->name : br->dev->name);
-
+		net_ratelimited_function(br_info, br, "Multicast hash table "
+			"chain limit reached: %s\n", port ? port->dev->name : br->dev->name);
 		elasticity = br->hash_elasticity;
 	}
 
@@ -554,10 +551,8 @@ disable:
 
 	if (max > mdb->max || elasticity) {
 		if (mdb->old) {
-			if (net_ratelimit())
-				br_info(br, "Multicast hash table "
-					"on fire: %s\n",
-					port ? port->dev->name : br->dev->name);
+			net_ratelimited_function(br_info, br, "Multicast hash table "
+				"on fire: %s\n", port ? port->dev->name : br->dev->name);
 			err = -EEXIST;
 			goto err;
 		}
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 8660ea3..482ef11 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -220,13 +220,10 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 		bpdu.forward_delay = br_get_ticks(buf+30);
 
 		if (bpdu.message_age > bpdu.max_age) {
-			if (net_ratelimit())
-				br_notice(p->br,
-					  "port %u config from %pM"
-					  " (message_age %ul > max_age %ul)\n",
-					  p->port_no,
-					  eth_hdr(skb)->h_source,
-					  bpdu.message_age, bpdu.max_age);
+			net_ratelimited_function(br_notice, p->br,
+				"port %u config from %pM (message_age %ul > max_age %ul)\n",
+				p->port_no, eth_hdr(skb)->h_source,
+				bpdu.message_age, bpdu.max_age);
 			goto out;
 		}
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 54395d7..35b8b1d 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3156,10 +3156,8 @@ static bool ieee80211_prepare_and_rx_handle(struct ieee80211_rx_data *rx,
 	if (!consume) {
 		skb = skb_copy(skb, GFP_ATOMIC);
 		if (!skb) {
-			if (net_ratelimit())
-				wiphy_debug(local->hw.wiphy,
-					"failed to copy skb for %s\n",
-					sdata->name);
+			net_ratelimited_function(wiphy_debug, local->hw.wiphy,
+				"failed to copy skb for %s\n", sdata->name);
 			return true;
 		}
 
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 707bc52..6179436 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -607,8 +607,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		mtype_expire(h, NETS_LENGTH(set->family), h->dsize);
 
 	if (h->elements >= h->maxelem) {
-		if (net_ratelimit())
-			pr_warning("Set %s is full, maxelem %u reached\n",
+		net_warn_ratelimited("Set %s is full, maxelem %u reached\n",
 				   set->name, h->maxelem);
 		return -IPSET_ERR_HASH_FULL;
 	}
-- 
1.8.2.1
