From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when performing the upcall
Date: Fri, 24 May 2013 16:52:23 +0200
Message-ID: <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
References: <cover.1369406826.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com,
	Thomas Graf <tgraf@rhlap.localdomain>
To: netdev@vger.kernel.org, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35562 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab3EXOwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 10:52:31 -0400
In-Reply-To: <cover.1369406826.git.tgraf@suug.ch>
In-Reply-To: <cover.1369406826.git.tgraf@suug.ch>
References: <cover.1369406826.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@rhlap.localdomain>

Avoids a memcpy() that is expensive for large packets:

from:
  4.51%  [kernel]                      [k] memcpy
to:
  1.20%  [kernel]                      [k] memcpy
  1.01%  [kernel]                      [k] skb_zerocopy

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..b434adf 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -375,10 +375,11 @@ static size_t key_attr_size(void)
 }
 
 static size_t upcall_msg_size(const struct sk_buff *skb,
-			      const struct nlattr *userdata)
+			      const struct nlattr *userdata,
+			      unsigned int hdrlen)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
-		+ nla_total_size(skb->len) /* OVS_PACKET_ATTR_PACKET */
+		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
 		+ nla_total_size(key_attr_size()); /* OVS_PACKET_ATTR_KEY */
 
 	/* OVS_PACKET_ATTR_USERDATA */
@@ -396,6 +397,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
+	unsigned int plen, hlen = 0;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -416,7 +418,21 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (err = skb_checksum_help(skb)))
+		goto out;
+
+	if (!skb->head_frag ||
+	    skb_headlen(skb) < L1_CACHE_BYTES ||
+	    skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS)
+		hlen = skb_headlen(skb);
+
+	if (skb_has_frag_list(skb))
+		hlen = skb->len;
+
+	hlen = min_t(int, skb->len, hlen);
+
+	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata, hlen), GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -435,11 +451,21 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
-	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
+		goto out;
+	nla->nla_len = nla_attr_size(skb->len);
+
+	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
-	skb_copy_and_csum_dev(skb, nla_data(nla));
+	plen = NLA_ALIGN(user_skb->len) - user_skb->len;
+	if (plen > 0)
+		memset(skb_put(user_skb, plen), 0, plen);
+
+	/* Fix alignment of .nlmsg_len, OVS user space enforces a strict
+	 * total message size alignment.
+	 */
+	((struct nlmsghdr *) user_skb->data)->nlmsg_len = NLA_ALIGN(user_skb->len);
 
-	genlmsg_end(user_skb, upcall);
 	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
 
 out:
-- 
1.7.11.7
