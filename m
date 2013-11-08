From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2 net-next] openvswitch: Use skb_zerocopy() for upcall
Date: Fri,  8 Nov 2013 11:47:18 +0100
Message-ID: <9369d871e13fe5b6e468b269450b9f2032a970aa.1383906944.git.tgraf@suug.ch>
References: <cover.1383906944.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:47618 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757305Ab3KHKr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 05:47:26 -0500
In-Reply-To: <cover.1383906944.git.tgraf@suug.ch>
In-Reply-To: <cover.1383906944.git.tgraf@suug.ch>
References: <cover.1383906944.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of skb_zerocopy() avoids the expensive call to memcpy() when
copying the packet data into the Netlink skb. Completes checksum
through skb_checksum_help() if needed.

Netlink messaged must be properly padded and aligned to meet
sanity checks of the user space counterpart.

Cost of memcpy is significantly reduced from:
+   7.48%       vhost-8471  [k] memcpy
+   5.57%     ovs-vswitchd  [k] memcpy
+   2.81%       vhost-8471  [k] csum_partial_copy_generic

to:
+   5.72%     ovs-vswitchd  [k] memcpy
+   3.32%       vhost-5153  [k] memcpy
+   0.68%       vhost-5153  [k] skb_zerocopy

(megaflows disabled)

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/openvswitch/datapath.c | 52 +++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 45 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 1408adc..3f170e3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -381,10 +381,11 @@ static size_t key_attr_size(void)
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
@@ -402,6 +403,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
+	unsigned int plen, hlen;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -422,7 +424,13 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
+	/* Complete checksum if needed */
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (err = skb_checksum_help(skb)))
+		goto out;
+
+	hlen = skb_zerocopy_headlen(skb);
+	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata, hlen), GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -441,13 +449,43 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
-	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+	/* Only reserve room for attribute header, packet data is added
+	 * in skb_zerocopy() */
+	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
+		goto out;
+	nla->nla_len = nla_attr_size(skb->len);
 
-	skb_copy_and_csum_dev(skb, nla_data(nla));
+	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
-	genlmsg_end(user_skb, upcall);
-	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
+	/* OVS user space expects the size of the message to be aligned to
+	 * NLA_ALIGNTO. Aligning nlmsg_len is not enough, the actual bytes
+	 * read must match nlmsg_len.
+	 */
+	plen = NLA_ALIGN(user_skb->len) - user_skb->len;
+	if (plen > 0) {
+		int nr_frags = skb_shinfo(user_skb)->nr_frags;
+
+		if (nr_frags) {
+			skb_frag_t *frag;
+
+			frag = &skb_shinfo(user_skb)->frags[nr_frags -1];
+			skb_frag_size_add(frag, plen);
+			BUG_ON(frag->size > PAGE_SIZE);
+
+			user_skb->truesize += plen;
+			user_skb->len += plen;
+			user_skb->data_len += plen;
+		} else {
+			/* The linear headroom is aligned to NLMSG_ALIGN by
+			 * genlmsg_new(), room must be available.
+			 */
+			memset(skb_put(user_skb, plen), 0, plen);
+		}
+	}
 
+	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
+
+	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
 out:
 	kfree_skb(nskb);
 	return err;
-- 
1.8.3.1
