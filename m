From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] openvswitch: Orphan frags before sending to
	userspace via Netlink to avoid guest stall
Date: Fri, 28 Feb 2014 19:16:56 +0000
Message-ID: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

The kernel datapath now switched to zerocopy Netlink messages, but that also
means that the pages on frags array are sent straight to userspace. If those
pages came outside the kernel, we have to swap them out with local copies.

Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 36f8872..ffb563c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -464,6 +464,12 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	}
 	nla->nla_len = nla_attr_size(skb->len);
 
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC))) {
+		err = -ENOMEM;
+		skb_tx_error(skb);
+		goto out;
+	}
+
 	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
 	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
