From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v8 09/11] vxlan: add ipv6 proxy support
Date: Fri, 17 May 2013 08:21:37 +0800
Message-ID: <1368750099-14086-10-git-send-email-amwang@redhat.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913Ab3EQAWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 20:22:36 -0400
In-Reply-To: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch adds the IPv6 version of "arp_reduce", ndisc_send_na()
will be needed.

Cc: David S. Miller <davem@davemloft.net>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c    |   81 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/addrconf.h |    4 ++
 include/net/ndisc.h    |    5 +++
 net/ipv6/af_inet6.c    |    1 +
 net/ipv6/ndisc.c       |    8 ++--
 5 files changed, 93 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 04fd499..f4d46bf 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -991,6 +991,76 @@ out:
 	return NETDEV_TX_OK;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct neighbour *n;
+	union vxlan_addr ipa;
+	const struct ipv6hdr *iphdr;
+	const struct in6_addr *saddr, *daddr;
+	struct nd_msg *msg;
+	struct inet6_dev *in6_dev = NULL;
+
+	in6_dev = in6_dev_get(dev);
+	if (!in6_dev)
+		goto consume;
+
+	if (skb->len < sizeof(struct ipv6hdr) + sizeof(struct nd_msg) ||
+	    !pskb_may_pull(skb, skb->len))
+		goto out;
+
+	iphdr = ipv6_hdr(skb);
+	saddr = &iphdr->saddr;
+	daddr = &iphdr->daddr;
+
+	if (iphdr->nexthdr != IPPROTO_ICMPV6)
+		goto out;
+
+	if (ipv6_addr_loopback(daddr) ||
+	    ipv6_addr_is_multicast(daddr))
+		goto out;
+
+	msg = (struct nd_msg *)skb_transport_header(skb);
+	if (msg->icmph.icmp6_code != 0 ||
+	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
+		goto out;
+
+	n = neigh_lookup(&nd_tbl, daddr, dev);
+
+	if (n) {
+		struct vxlan_fdb *f;
+
+		if (!(n->nud_state & NUD_CONNECTED)) {
+			neigh_release(n);
+			goto out;
+		}
+
+		f = vxlan_find_mac(vxlan, n->ha);
+		if (f && vxlan_addr_any(&f->remote.remote_ip)) {
+			/* bridge-local neighbor */
+			neigh_release(n);
+			goto out;
+		}
+
+		ipv6_stub->ndisc_send_na(dev, n, saddr, &msg->target,
+					 !!in6_dev->cnf.forwarding,
+					 true, false, false);
+		neigh_release(n);
+	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+		ipa.sin6.sin6_addr = *daddr;
+		ipa.sa.sa_family = AF_INET6;
+		vxlan_ip_miss(dev, &ipa);
+	}
+
+out:
+	in6_dev_put(in6_dev);
+consume:
+	consume_skb(skb);
+	return NETDEV_TX_OK;
+}
+#endif
+
 static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -1410,8 +1480,15 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
 
-	if ((vxlan->flags & VXLAN_F_PROXY) && ntohs(eth->h_proto) == ETH_P_ARP)
-		return arp_reduce(dev, skb);
+	if ((vxlan->flags & VXLAN_F_PROXY)) {
+		if (ntohs(eth->h_proto) == ETH_P_ARP)
+			return arp_reduce(dev, skb);
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
+			 ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6)
+			return neigh_reduce(dev, skb);
+#endif
+	}
 
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index d09d42c..34bccff 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -151,6 +151,10 @@ struct ipv6_stub {
 	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
 				struct flowi6 *fl6);
 	void (*udpv6_encap_enable)(void);
+	void (*ndisc_send_na)(struct net_device *dev, struct neighbour *neigh,
+			      const struct in6_addr *daddr,
+			      const struct in6_addr *solicited_addr,
+			      bool router, bool solicited, bool override, bool inc_opt);
 };
 extern const struct ipv6_stub *ipv6_stub __read_mostly;
 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 745bf74..ec2da56 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -204,6 +204,11 @@ extern void			ndisc_send_ns(struct net_device *dev,
 extern void			ndisc_send_rs(struct net_device *dev,
 					      const struct in6_addr *saddr,
 					      const struct in6_addr *daddr);
+extern void			ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
+					      const struct in6_addr *daddr,
+					      const struct in6_addr *solicited_addr,
+					      bool router, bool solicited, bool override,
+					      bool inc_opt);
 
 extern void			ndisc_send_redirect(struct sk_buff *skb,
 						    const struct in6_addr *target);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 58de055..d80fe10 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -813,6 +813,7 @@ static const struct ipv6_stub ipv6_stub_impl = {
 	.ipv6_sock_mc_drop = ipv6_sock_mc_drop,
 	.ipv6_dst_lookup = ip6_dst_lookup,
 	.udpv6_encap_enable = udpv6_encap_enable,
+	.ndisc_send_na = ndisc_send_na,
 };
 
 static int __init inet6_init(void)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2712ab2..a17e4d0 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -462,10 +462,10 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
-static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-			  const struct in6_addr *daddr,
-			  const struct in6_addr *solicited_addr,
-			  bool router, bool solicited, bool override, bool inc_opt)
+void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
+		   const struct in6_addr *daddr,
+		   const struct in6_addr *solicited_addr,
+		   bool router, bool solicited, bool override, bool inc_opt)
 {
 	struct sk_buff *skb;
 	struct in6_addr tmpaddr;
-- 
1.7.7.6
