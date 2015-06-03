From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH WIP RFC 3/3] mpls: register lwtunnel ops
Date: Wed,  3 Jun 2015 07:21:46 -0700
Message-ID: <1433341306-29288-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33450 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbbFCOV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 10:21:58 -0400
Received: by qkhg32 with SMTP id g32so6029111qkh.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 07:21:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

- This is just part of the patch. Unfortunately
i realized that my tree has other changes for mpls
unrelated to ler

- also, The nla_put and nla_get label are different in the patch
than upstream because of some other changes in my tree

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  |  143 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/mpls/internal.h |    5 ++
 2 files changed, 148 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732..180c783 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -13,6 +13,7 @@
 #include <net/sock.h>
 #include <net/arp.h>
 #include <net/ip_fib.h>
+#include <net/lwtunnel.h>
 #include <net/netevent.h>
 #include <net/netns/generic.h>
 #include "internal.h"
@@ -133,6 +134,84 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	return success;
 }
 
+int mpls_output(struct sock *sk, struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct mpls_shim_hdr *hdr;
+	struct mpls_entry_decoded dec;
+	struct net_device *out_dev;
+	unsigned int hh_len;
+	unsigned int new_header_size;
+	unsigned int mtu;
+	struct lwtunnel_state *lwtstate;
+	struct mpls_nhlfe_labels *hdr_labels;
+	struct rtable *rt = (struct rtable *)dst;
+	int err;
+	bool bos;
+	int i;
+
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		goto drop;
+
+	/* Find the output device */
+	out_dev = rcu_dereference(skb_dst(skb)->dev);
+	if (!mpls_output_possible(out_dev))
+		goto drop;
+
+	if (skb_warn_if_lro(skb))
+		goto drop;
+	skb_forward_csum(skb);
+
+	lwtstate = dst->lwtstate;
+	if (!lwtstate)
+		goto drop;
+
+	hdr_labels = &(lwtstate->tunnel.data);
+
+	/* Verify the destination can hold the packet */
+	new_header_size = mpls_header_size(hdr_labels);
+	mtu = mpls_dev_mtu(out_dev);
+	if (mpls_pkt_too_big(skb, mtu - new_header_size))
+		goto drop;
+
+	hh_len = LL_RESERVED_SPACE(out_dev);
+	if (!out_dev->header_ops)
+		hh_len = 0;
+
+	/* Ensure there is enough space for the headers in the skb */
+	if (skb_cow(skb, hh_len + new_header_size))
+		goto drop;
+
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	skb_push(skb, new_header_size);
+	skb_reset_network_header(skb);
+
+	/* Push the new labels */
+	hdr = mpls_hdr(skb);
+	bos = true;
+	for (i = hdr_labels->nh_labels - 1; i >= 0; i--) {
+		hdr[i] = mpls_entry_encode(hdr_labels->nh_label[i],
+					   dec.ttl, 0, bos);
+		bos = false;
+	}
+	err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, rt->rt_gateway,
+			 skb);
+	if (err)
+		net_dbg_ratelimited("%s: packet transmission failed: "
+					"%d\n", __func__, err);
+
+	return 0;
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 			struct packet_type *pt, struct net_device *orig_dev)
 {
@@ -1094,6 +1173,68 @@ static void mpls_net_exit(struct net *net)
 	kvfree(platform_label);
 }
 
+static int mpls_build_state(struct rtencap *e, int len,
+			    struct lwtunnel_state **ts)
+{
+	unsigned dstlen;
+	struct lwtunnel_state *newts;
+	struct mpls_nhlfe_labels *hdr_labels;
+	int hdr_len;
+	int ret;
+
+	dstlen = len - sizeof(struct rtencap);
+	hdr_len = sizeof(*hdr_labels);
+
+	newts = lwtunnel_state_alloc(hdr_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->type = e->type;
+	newts->tunnel.len = hdr_len;
+	hdr_labels = &newts->tunnel.data;
+	ret = nla_get_labels(&e->dst, dstlen, MAX_NEW_LABELS,
+			     &hdr_labels->nh_labels, hdr_labels->nh_label);
+	if (ret)
+		goto errout;
+
+	*ts = newts;
+
+	return 0;
+
+errout:
+	kfree(newts);
+	*ts = NULL;
+
+	return ret;
+}
+
+static int mpls_dump_encap_hdr(struct sk_buff *skb, int attr,
+                               struct lwtunnel_state *lwtstate)
+{
+    struct rtencap *en;
+    struct mpls_nhlfe_labels *hdr;
+    struct nlattr *nla;
+    int alen;
+
+    hdr = &lwtstate->tunnel.data;
+    alen = mpls_header_size(hdr);
+
+    nla = nla_reserve(skb, attr, alen + 2);
+    if (!nla)
+	return -EMSGSIZE;
+    en = nla_data(nla);
+    nla_put_labels(skb, &en->dst, hdr->nh_labels, hdr->nh_label);
+    en->type = LW_TUNNEL_ENCAP_MPLS;
+
+    return 0;
+}
+
+static const struct lwtunnel_encap_ops mpls_iptun_ops = {
+	.build_state = mpls_build_state,
+	.dump_encap_hdr = mpls_dump_encap_hdr,
+	.output = mpls_output,
+};
+
 static struct pernet_operations mpls_net_ops = {
 	.init = mpls_net_init,
 	.exit = mpls_net_exit,
@@ -1115,6 +1256,8 @@ static int __init mpls_init(void)
 
 	dev_add_pack(&mpls_packet_type);
 
+	lwtunnel_encap_add_ops(&mpls_iptun_ops, LW_TUNNEL_ENCAP_MPLS);
+
 	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes, NULL);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index b064c34..53160ec 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -18,6 +18,11 @@ struct mpls_dev {
 	struct ctl_table_header *sysctl;
 };
 
+struct mpls_nhlfe_labels {
+	u32	nh_label[MAX_NEW_LABELS];
+	u8	nh_labels;
+};
+
 struct sk_buff;
 
 static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
-- 
1.7.10.4
