From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 15/17] openvswitch: Use skb_zerocopy()
	for upcall
Date: Mon,  6 Jan 2014 16:16:14 -0800
Message-ID: <1389053776-62865-16-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Use of skb_zerocopy() can avoid the expensive call to memcpy()
when copying the packet data into the Netlink skb. Completes
checksum through skb_checksum_help() if not already done in
GSO segmentation.

Zerocopy is only performed if user space supported unaligned
Netlink messages. memory mapped netlink i/o is preferred over
zerocopy if it is set up.

Cost of upcall is significantly reduced from:
+   7.48%       vhost-8471  [k] memcpy
+   5.57%     ovs-vswitchd  [k] memcpy
+   2.81%       vhost-8471  [k] csum_partial_copy_generic

to:
+   5.72%     ovs-vswitchd  [k] memcpy
+   3.32%       vhost-5153  [k] memcpy
+   0.68%       vhost-5153  [k] skb_zerocopy

(megaflows disabled)

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 37 +++++++++++++++++++++++++++++--------
 1 file changed, 29 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 235acae..8557834 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -371,11 +371,11 @@ static size_t key_attr_size(void)
 		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
 }
 
-static size_t upcall_msg_size(const struct sk_buff *skb,
-			      const struct nlattr *userdata)
+static size_t upcall_msg_size(const struct nlattr *userdata,
+			      unsigned int hdrlen)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
-		+ nla_total_size(skb->len) /* OVS_PACKET_ATTR_PACKET */
+		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
 		+ nla_total_size(key_attr_size()); /* OVS_PACKET_ATTR_KEY */
 
 	/* OVS_PACKET_ATTR_USERDATA */
@@ -397,6 +397,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		.snd_portid = upcall_info->portid,
 	};
 	size_t len;
+	unsigned int hlen;
 	int err, dp_ifindex;
 
 	dp_ifindex = get_dpifindex(dp);
@@ -421,7 +422,21 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		goto out;
 	}
 
-	len = upcall_msg_size(skb, upcall_info->userdata);
+	/* Complete checksum if needed */
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (err = skb_checksum_help(skb)))
+		goto out;
+
+	/* Older versions of OVS user space enforce alignment of the last
+	 * Netlink attribute to NLA_ALIGNTO which would require extensive
+	 * padding logic. Only perform zerocopy if padding is not required.
+	 */
+	if (dp->user_features & OVS_DP_F_UNALIGNED)
+		hlen = skb_zerocopy_headlen(skb);
+	else
+		hlen = skb->len;
+
+	len = upcall_msg_size(upcall_info->userdata, hlen);
 	user_skb = genlmsg_new_unicast(len, &info, GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
@@ -441,13 +456,19 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
-	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+	/* Only reserve room for attribute header, packet data is added
+	 * in skb_zerocopy() */
+	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
+		err = -ENOBUFS;
+		goto out;
+	}
+	nla->nla_len = nla_attr_size(skb->len);
 
-	skb_copy_and_csum_dev(skb, nla_data(nla));
+	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
-	genlmsg_end(user_skb, upcall);
-	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
+	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
+	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
 out:
 	kfree_skb(nskb);
 	return err;
-- 
1.8.3.2
