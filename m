From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/5] vxlan: support fdb and learning in COLLECT_METADATA mode
Date: Tue, 31 Jan 2017 22:59:52 -0800
Message-ID: <1485932395-58422-3-git-send-email-roopa@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34843 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdBAHAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 02:00:03 -0500
Received: by mail-pg0-f41.google.com with SMTP id 194so106795453pgd.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 23:00:03 -0800 (PST)
In-Reply-To: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Vxlan COLLECT_METADATA mode today solves the per-vni netdev
scalability problem in l3 networks. It expects all forwarding
information to be present in dst_metadata. This patch series
enhances collect metadata mode to include the case where only
vni is present in dst_metadata, and the vxlan driver can then use
the rest of the forwarding information datbase to make forwarding
decisions. There is no change to default COLLECT_METADATA
behaviour. These changes only apply to COLLECT_METADATA when
used with the bridging use-case with a special dst_metadata
tunnel info flag (eg: where vxlan device is part of a bridge).
For all this to work, the vxlan driver will need to now support a
single fdb table hashed by mac + vni. This series essentially makes
this happen.

use-case and workflow:
vxlan collect metadata device participates in bridging vlan
to vn-segments. Bridge driver above the vxlan device,
sends the vni corresponding to the vlan in the dst_metadata.
vxlan driver will lookup forwarding database with (mac + vni)
for the required remote destination information to forward the
packet.

Changes introduced by this patch:
    - allow learning and forwarding database state in vxlan netdev in
      COLLECT_METADATA mode. Current behaviour is not changed
      by default. tunnel info flag IP_TUNNEL_INFO_BRIDGE is used
      to support the new bridge friendly mode.
    - A single fdb table hashed by (mac, vni) to allow fdb entries with
      multiple vnis in the same fdb table
    - rx path already has the vni
    - tx path expects a vni in the packet with dst_metadata
    - prior to this series, fdb remote_dsts carried remote vni and
      the vxlan device carrying the fdb table represented the
      source vni. With the vxlan device now representing multiple vnis,
      this patch adds a src vni attribute to the fdb entry. The remote
      vni already uses NDA_VNI attribute. This patch introduces
      NDA_SRC_VNI netlink attribute to represent the src vni in a multi
      vni fdb table.

iproute2 example (patched and pruned iproute2 output to just show
relevant fdb entries):
example shows same host mac learnt on two vni's.

before (netdev per vni):
$bridge fdb show | grep "00:02:00:00:00:03"
00:02:00:00:00:03 dev vxlan1001 dst 12.0.0.8 self
00:02:00:00:00:03 dev vxlan1000 dst 12.0.0.8 self

after this patch with collect metadata in bridged mode (single netdev):
$bridge fdb show | grep "00:02:00:00:00:03"
00:02:00:00:00:03 dev vxlan0 src_vni 1001 dst 12.0.0.8 self
00:02:00:00:00:03 dev vxlan0 src_vni 1000 dst 12.0.0.8 self

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c            |  196 +++++++++++++++++++++++++---------------
 include/uapi/linux/neighbour.h |    1 +
 2 files changed, 126 insertions(+), 71 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 19b1653..6f16882 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -75,6 +75,7 @@ struct vxlan_fdb {
 	struct list_head  remotes;
 	u8		  eth_addr[ETH_ALEN];
 	u16		  state;	/* see ndm_state */
+	__be32		  vni;
 	u8		  flags;	/* see ndm_flags */
 };
 
@@ -302,6 +303,10 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
 	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
 		goto nla_put_failure;
+	if ((vxlan->flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
+	    nla_put_u32(skb, NDA_SRC_VNI,
+			be32_to_cpu(fdb->vni)))
+		goto nla_put_failure;
 	if (rdst->remote_ifindex &&
 	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
 		goto nla_put_failure;
@@ -400,34 +405,51 @@ static u32 eth_hash(const unsigned char *addr)
 	return hash_64(value, FDB_HASH_BITS);
 }
 
+static u32 eth_vni_hash(const unsigned char *addr, __be32 vni)
+{
+	/* use 1 byte of OUI and 3 bytes of NIC */
+	u32 key = get_unaligned((u32 *)(addr + 2));
+
+	return jhash_2words(key, vni, vxlan_salt) & (FDB_HASH_SIZE - 1);
+}
+
 /* Hash chain to use given mac address */
 static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
-						const u8 *mac)
+						const u8 *mac, __be32 vni)
 {
-	return &vxlan->fdb_head[eth_hash(mac)];
+	if (vxlan->flags & VXLAN_F_COLLECT_METADATA)
+		return &vxlan->fdb_head[eth_vni_hash(mac, vni)];
+	else
+		return &vxlan->fdb_head[eth_hash(mac)];
 }
 
 /* Look up Ethernet address in forwarding table */
 static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
-					const u8 *mac)
+					  const u8 *mac, __be32 vni)
 {
-	struct hlist_head *head = vxlan_fdb_head(vxlan, mac);
+	struct hlist_head *head = vxlan_fdb_head(vxlan, mac, vni);
 	struct vxlan_fdb *f;
 
 	hlist_for_each_entry_rcu(f, head, hlist) {
-		if (ether_addr_equal(mac, f->eth_addr))
-			return f;
+		if (ether_addr_equal(mac, f->eth_addr)) {
+			if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+				if (vni == f->vni)
+					return f;
+			} else {
+				return f;
+			}
+		}
 	}
 
 	return NULL;
 }
 
 static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
-					const u8 *mac)
+					const u8 *mac, __be32 vni)
 {
 	struct vxlan_fdb *f;
 
-	f = __vxlan_find_mac(vxlan, mac);
+	f = __vxlan_find_mac(vxlan, mac, vni);
 	if (f)
 		f->used = jiffies;
 
@@ -605,15 +627,15 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, union vxlan_addr *ip,
 			    __u16 state, __u16 flags,
-			    __be16 port, __be32 vni, __u32 ifindex,
-			    __u8 ndm_flags)
+			    __be16 port, __be32 src_vni, __be32 vni,
+			    __u32 ifindex, __u8 ndm_flags)
 {
 	struct vxlan_rdst *rd = NULL;
 	struct vxlan_fdb *f;
 	int notify = 0;
 	int rc;
 
-	f = __vxlan_find_mac(vxlan, mac);
+	f = __vxlan_find_mac(vxlan, mac, src_vni);
 	if (f) {
 		if (flags & NLM_F_EXCL) {
 			netdev_dbg(vxlan->dev,
@@ -670,6 +692,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		f->state = state;
 		f->flags = ndm_flags;
 		f->updated = f->used = jiffies;
+		f->vni = src_vni;
 		INIT_LIST_HEAD(&f->remotes);
 		memcpy(f->eth_addr, mac, ETH_ALEN);
 
@@ -681,7 +704,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 
 		++vxlan->addrcnt;
 		hlist_add_head_rcu(&f->hlist,
-				   vxlan_fdb_head(vxlan, mac));
+				   vxlan_fdb_head(vxlan, mac, src_vni));
 	}
 
 	if (notify) {
@@ -718,8 +741,8 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 }
 
 static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
-			   union vxlan_addr *ip, __be16 *port, __be32 *vni,
-			   u32 *ifindex)
+			   union vxlan_addr *ip, __be16 *port, __be32 *src_vni,
+			   __be32 *vni, u32 *ifindex)
 {
 	struct net *net = dev_net(vxlan->dev);
 	int err;
@@ -757,6 +780,14 @@ static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
 		*vni = vxlan->default_dst.remote_vni;
 	}
 
+	if (tb[NDA_SRC_VNI]) {
+		if (nla_len(tb[NDA_SRC_VNI]) != sizeof(u32))
+			return -EINVAL;
+		*src_vni = cpu_to_be32(nla_get_u32(tb[NDA_SRC_VNI]));
+	} else {
+		*src_vni = vxlan->default_dst.remote_vni;
+	}
+
 	if (tb[NDA_IFINDEX]) {
 		struct net_device *tdev;
 
@@ -782,7 +813,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	/* struct net *net = dev_net(vxlan->dev); */
 	union vxlan_addr ip;
 	__be16 port;
-	__be32 vni;
+	__be32 src_vni, vni;
 	u32 ifindex;
 	int err;
 
@@ -795,7 +826,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (tb[NDA_DST] == NULL)
 		return -EINVAL;
 
-	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &vni, &ifindex);
+	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &src_vni, &vni, &ifindex);
 	if (err)
 		return err;
 
@@ -804,36 +835,24 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 	spin_lock_bh(&vxlan->hash_lock);
 	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags,
-			       port, vni, ifindex, ndm->ndm_flags);
+			       port, src_vni, vni, ifindex, ndm->ndm_flags);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
 }
 
-/* Delete entry (via netlink) */
-static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
-			    struct net_device *dev,
-			    const unsigned char *addr, u16 vid)
+static int __vxlan_fdb_delete(struct vxlan_dev *vxlan,
+			      const unsigned char *addr, union vxlan_addr ip,
+			      __be16 port, __be32 src_vni, u32 vni, u32 ifindex,
+			      u16 vid)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
 	struct vxlan_rdst *rd = NULL;
-	union vxlan_addr ip;
-	__be16 port;
-	__be32 vni;
-	u32 ifindex;
-	int err;
+	int err = -ENOENT;
 
-	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &vni, &ifindex);
-	if (err)
-		return err;
-
-	err = -ENOENT;
-
-	spin_lock_bh(&vxlan->hash_lock);
-	f = vxlan_find_mac(vxlan, addr);
+	f = vxlan_find_mac(vxlan, addr, src_vni);
 	if (!f)
-		goto out;
+		return err;
 
 	if (!vxlan_addr_any(&ip)) {
 		rd = vxlan_fdb_find_rdst(f, &ip, port, vni, ifindex);
@@ -841,8 +860,6 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			goto out;
 	}
 
-	err = 0;
-
 	/* remove a destination if it's not the only one on the list,
 	 * otherwise destroy the fdb entry
 	 */
@@ -856,6 +873,28 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	vxlan_fdb_destroy(vxlan, f);
 
 out:
+	return 0;
+}
+
+/* Delete entry (via netlink) */
+static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr, u16 vid)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	union vxlan_addr ip;
+	__be32 src_vni, vni;
+	__be16 port;
+	u32 ifindex;
+	int err;
+
+	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &src_vni, &vni, &ifindex);
+	if (err)
+		return err;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	err = __vxlan_fdb_delete(vxlan, addr, ip, port, src_vni, vni, ifindex,
+				 vid);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
@@ -901,12 +940,13 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
  * Return true if packet is bogus and should be dropped.
  */
 static bool vxlan_snoop(struct net_device *dev,
-			union vxlan_addr *src_ip, const u8 *src_mac)
+			union vxlan_addr *src_ip, const u8 *src_mac,
+			__be32 vni)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
 
-	f = vxlan_find_mac(vxlan, src_mac);
+	f = vxlan_find_mac(vxlan, src_mac, vni);
 	if (likely(f)) {
 		struct vxlan_rdst *rdst = first_remote_rcu(f);
 
@@ -935,6 +975,7 @@ static bool vxlan_snoop(struct net_device *dev,
 					 NUD_REACHABLE,
 					 NLM_F_EXCL|NLM_F_CREATE,
 					 vxlan->cfg.dst_port,
+					 vni,
 					 vxlan->default_dst.remote_vni,
 					 0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
@@ -1202,7 +1243,7 @@ static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
 
 static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 			  struct vxlan_sock *vs,
-			  struct sk_buff *skb)
+			  struct sk_buff *skb, __be32 vni)
 {
 	union vxlan_addr saddr;
 
@@ -1226,7 +1267,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 	}
 
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source, vni))
 		return false;
 
 	return true;
@@ -1268,6 +1309,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	__be16 protocol = htons(ETH_P_TEB);
 	bool raw_proto = false;
 	void *oiph;
+	__be32 vni = 0;
 
 	/* Need UDP and VXLAN header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1289,7 +1331,12 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
-	vxlan = vxlan_vs_find_vni(vs, vxlan_vni(vxlan_hdr(skb)->vx_vni));
+	vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
+
+	if ((vs->flags & VXLAN_F_COLLECT_METADATA) && !vni)
+		goto drop;
+
+	vxlan = vxlan_vs_find_vni(vs, vni);
 	if (!vxlan)
 		goto drop;
 
@@ -1307,7 +1354,6 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 
 	if (vxlan_collect_metadata(vs)) {
-		__be32 vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
 		struct metadata_dst *tun_dst;
 
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
@@ -1345,7 +1391,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (!raw_proto) {
-		if (!vxlan_set_mac(vxlan, vs, skb))
+		if (!vxlan_set_mac(vxlan, vs, skb, vni))
 			goto drop;
 	} else {
 		skb_reset_mac_header(skb);
@@ -1377,7 +1423,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
+static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct arphdr *parp;
@@ -1424,7 +1470,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 			goto out;
 		}
 
-		f = vxlan_find_mac(vxlan, n->ha);
+		f = vxlan_find_mac(vxlan, n->ha, vni);
 		if (f && vxlan_addr_any(&(first_remote_rcu(f)->remote_ip))) {
 			/* bridge-local neighbor */
 			neigh_release(n);
@@ -1548,7 +1594,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	return reply;
 }
 
-static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
+static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct nd_msg *msg;
@@ -1585,7 +1631,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 			goto out;
 		}
 
-		f = vxlan_find_mac(vxlan, n->ha);
+		f = vxlan_find_mac(vxlan, n->ha, vni);
 		if (f && vxlan_addr_any(&(first_remote_rcu(f)->remote_ip))) {
 			/* bridge-local neighbor */
 			neigh_release(n);
@@ -1906,7 +1952,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
-			       struct vxlan_dev *dst_vxlan)
+			       struct vxlan_dev *dst_vxlan, __be32 vni)
 {
 	struct pcpu_sw_netstats *tx_stats, *rx_stats;
 	union vxlan_addr loopback;
@@ -1932,7 +1978,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	}
 
 	if (dst_vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source);
+		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source, vni);
 
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->tx_packets++;
@@ -1976,7 +2022,7 @@ static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 
 			return -ENOENT;
 		}
-		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+		vxlan_encap_bypass(skb, vxlan, dst_vxlan, vni);
 		return 1;
 	}
 
@@ -1984,7 +2030,8 @@ static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 }
 
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
-			   struct vxlan_rdst *rdst, bool did_rsc)
+			   __be32 default_vni, struct vxlan_rdst *rdst,
+			   bool did_rsc)
 {
 	struct dst_cache *dst_cache;
 	struct ip_tunnel_info *info;
@@ -2011,14 +2058,14 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (vxlan_addr_any(dst)) {
 			if (did_rsc) {
 				/* short-circuited back to local bridge */
-				vxlan_encap_bypass(skb, vxlan, vxlan);
+				vxlan_encap_bypass(skb, vxlan, vxlan, default_vni);
 				return;
 			}
 			goto drop;
 		}
 
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
-		vni = rdst->remote_vni;
+		vni = (rdst->remote_vni) ? : default_vni;
 		src = &vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
 		md->gbp = skb->mark;
@@ -2173,23 +2220,29 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
+	__be32 vni = 0;
 
 	info = skb_tunnel_info(skb);
 
 	skb_reset_mac_header(skb);
 
 	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
-		if (info && info->mode & IP_TUNNEL_INFO_TX)
-			vxlan_xmit_one(skb, dev, NULL, false);
-		else
-			kfree_skb(skb);
-		return NETDEV_TX_OK;
+		if (info && info->mode & IP_TUNNEL_INFO_BRIDGE &&
+		    info->mode & IP_TUNNEL_INFO_TX) {
+			vni = tunnel_id_to_key32(info->key.tun_id);
+		} else {
+			if (info && info->mode & IP_TUNNEL_INFO_TX)
+				vxlan_xmit_one(skb, dev, vni, NULL, false);
+			else
+				kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
 	}
 
 	if (vxlan->flags & VXLAN_F_PROXY) {
 		eth = eth_hdr(skb);
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
-			return arp_reduce(dev, skb);
+			return arp_reduce(dev, skb, vni);
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
 			 pskb_may_pull(skb, sizeof(struct ipv6hdr)
@@ -2200,13 +2253,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 				msg = (struct nd_msg *)skb_transport_header(skb);
 				if (msg->icmph.icmp6_code == 0 &&
 				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
-					return neigh_reduce(dev, skb);
+					return neigh_reduce(dev, skb, vni);
 		}
 #endif
 	}
 
 	eth = eth_hdr(skb);
-	f = vxlan_find_mac(vxlan, eth->h_dest);
+	f = vxlan_find_mac(vxlan, eth->h_dest, vni);
 	did_rsc = false;
 
 	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
@@ -2214,11 +2267,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
 		did_rsc = route_shortcircuit(dev, skb);
 		if (did_rsc)
-			f = vxlan_find_mac(vxlan, eth->h_dest);
+			f = vxlan_find_mac(vxlan, eth->h_dest, vni);
 	}
 
 	if (f == NULL) {
-		f = vxlan_find_mac(vxlan, all_zeros_mac);
+		f = vxlan_find_mac(vxlan, all_zeros_mac, vni);
 		if (f == NULL) {
 			if ((vxlan->flags & VXLAN_F_L2MISS) &&
 			    !is_multicast_ether_addr(eth->h_dest))
@@ -2239,11 +2292,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		skb1 = skb_clone(skb, GFP_ATOMIC);
 		if (skb1)
-			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+			vxlan_xmit_one(skb1, dev, vni, rdst, did_rsc);
 	}
 
 	if (fdst)
-		vxlan_xmit_one(skb, dev, fdst, did_rsc);
+		vxlan_xmit_one(skb, dev, vni, fdst, did_rsc);
 	else
 		kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -2307,12 +2360,12 @@ static int vxlan_init(struct net_device *dev)
 	return 0;
 }
 
-static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
+static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan, __be32 vni)
 {
 	struct vxlan_fdb *f;
 
 	spin_lock_bh(&vxlan->hash_lock);
-	f = __vxlan_find_mac(vxlan, all_zeros_mac);
+	f = __vxlan_find_mac(vxlan, all_zeros_mac, vni);
 	if (f)
 		vxlan_fdb_destroy(vxlan, f);
 	spin_unlock_bh(&vxlan->hash_lock);
@@ -2322,7 +2375,7 @@ static void vxlan_uninit(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	vxlan_fdb_delete_default(vxlan);
+	vxlan_fdb_delete_default(vxlan, vxlan->cfg.vni);
 
 	free_percpu(dev->tstats);
 }
@@ -2921,6 +2974,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 				       NLM_F_EXCL|NLM_F_CREATE,
 				       vxlan->cfg.dst_port,
 				       vxlan->default_dst.remote_vni,
+				       vxlan->default_dst.remote_vni,
 				       vxlan->default_dst.remote_ifindex,
 				       NTF_SELF);
 		if (err)
@@ -2929,7 +2983,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err) {
-		vxlan_fdb_delete_default(vxlan);
+		vxlan_fdb_delete_default(vxlan, vxlan->cfg.vni);
 		return err;
 	}
 
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index bd99a8d..f3d16db 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -26,6 +26,7 @@ enum {
 	NDA_IFINDEX,
 	NDA_MASTER,
 	NDA_LINK_NETNSID,
+	NDA_SRC_VNI,
 	__NDA_MAX
 };
 
-- 
1.7.10.4
