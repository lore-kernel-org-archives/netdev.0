From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 1/5] openvswitch: Pad OVS_PACKET_ATTR_PACKET
	if linear copy was performed
Date: Sun,  2 Feb 2014 17:08:02 -0800
Message-ID: <1391389686-34303-2-git-send-email-jesse@nicira.com>
References: <1391389686-34303-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391389686-34303-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

While the zerocopy method is correctly omitted if user space
does not support unaligned Netlink messages. The attribute is
still not padded correctly as skb_zerocopy() will not ensure
padding and the attribute size is no longer pre calculated
though nla_reserve() which ensured padding previously.

This patch applies appropriate padding if a linear data copy
was performed in skb_zerocopy().

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Acked-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index df46928..3ca9121 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -396,7 +396,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		.dst_sk = ovs_dp_get_net(dp)->genl_sock,
 		.snd_portid = upcall_info->portid,
 	};
-	size_t len;
+	size_t len, plen;
 	unsigned int hlen;
 	int err, dp_ifindex;
 
@@ -466,6 +466,11 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
+	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
+	if (!(dp->user_features & OVS_DP_F_UNALIGNED) &&
+	    (plen = (ALIGN(user_skb->len, NLA_ALIGNTO) - user_skb->len)) > 0)
+		memset(skb_put(user_skb, plen), 0, plen);
+
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
 	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
-- 
1.8.3.2
