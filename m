From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/2] openvswitch: Use skb_zerocopy() to prepare skb for upcall
Date: Thu, 25 Jul 2013 14:43:45 +0200
Message-ID: <9d4aaa5319c684e14721e0bed2ef22ddc409caf1.1374756042.git.tgraf@suug.ch>
References: <cover.1374756042.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	eric.dumazet@gmail.com, Thomas Graf <tgraf@rhlap.localdomain>
To: davem@davemloft.net, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37146 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab3GYMnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 08:43:53 -0400
In-Reply-To: <cover.1374756042.git.tgraf@suug.ch>
In-Reply-To: <cover.1374756042.git.tgraf@suug.ch>
References: <cover.1374756042.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@rhlap.localdomain>

Use of skb_zerocopy() avoids the expensive call to memcpy() when
copying the packet data into the Netlink skb. Completes checksum
through skb_checksum_help() if needed (typicall packet input from
software device) which invalidates some of the gains again.

Stock-RX
-  38.30%       swapper  [kernel.kallsyms]  [k] memcpy
   - memcpy
      + 87.46% queue_userspace_packet
      + 12.54% nla_put
+  24.72%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
+  13.80%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
-   7.68%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy
   - memcpy
      + 85.83% queue_userspace_packet
      + 14.17% nla_put
-   7.06%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
   - memcpy
      + 84.85% queue_userspace_packet
      + 15.15% nla_put
-   4.41%   ksoftirqd/0  [kernel.kallsyms]  [k] memcpy
   - memcpy
      + 83.48% queue_userspace_packet
      + 16.52% nla_put

Zerocopy-RX
+  50.35%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
-  27.78%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
   - memcpy
      + 74.53% ovs_packet_cmd_execute
      + 24.11% nla_put
      + 0.93% ovs_flow_cmd_new_or_set
+  13.49%       swapper  [kernel.kallsyms]  [k] memcpy
+   1.45%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
+   1.20%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy

10Gb remote pktgen, 1200 bytes, randomized flows, w/ UDPCSUM:
                                Hits               Missed          Lost
Stock RX                     731'945            6'315'739     3'606'678
Zerocopy RX                  764'041            6'442'761     3'947'451

local pktgen, 4/6 CPUs, 1200 bytes, randomized flows, UDPCSUM:
                                Hits               Missed          Lost
Stock TX                   2'071'030           17'929'192    16'807'785
Zerocopy TX                1'951'142           18'049'056    16'977'296

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/openvswitch/datapath.c | 47 ++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 41 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f7e3a0d..c5927ad 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -383,10 +383,11 @@ static size_t key_attr_size(void)
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
@@ -404,6 +405,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
+	unsigned int plen, hlen;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -424,7 +426,12 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (err = skb_checksum_help(skb)))
+		goto out;
+
+	hlen = skb_zerocopy_headlen(skb);
+	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata, hlen), GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -443,11 +450,39 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
-	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
+		goto out;
+	nla->nla_len = nla_attr_size(skb->len);
+
+	skb_zerocopy(user_skb, skb, skb->len, hlen);
+
+	/* Align the end of the attribute to NLA_ALIGNTO */
+	plen = NLA_ALIGN(user_skb->len) - user_skb->len;
+	if (plen > 0) {
+		int nr_frags = skb_shinfo(user_skb)->nr_frags;
 
-	skb_copy_and_csum_dev(skb, nla_data(nla));
+		if (nr_frags) {
+			skb_frag_t *frag;
+
+			/* Assumption is made that PAGE_SIZE is always alligned
+			 * to at least NLA_ALIGNTO (4) which means that we it
+			 * should be safe to add the padding bytes to the frag
+			 */
+			frag = &skb_shinfo(user_skb)->frags[nr_frags -1];
+			skb_frag_size_add(frag, plen);
+
+			user_skb->truesize += plen;
+			user_skb->len += plen;
+			user_skb->data_len += plen;
+		} else
+			memset(skb_put(user_skb, plen), 0, plen);
+	}
+
+	/* Fix alignment of .nlmsg_len, OVS user space enforces a strict
+	 * total message size alignment.
+	 */
+	((struct nlmsghdr *) user_skb->data)->nlmsg_len = NLA_ALIGN(user_skb->len);
 
-	genlmsg_end(user_skb, upcall);
 	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
 
 out:
-- 
1.8.3.1
