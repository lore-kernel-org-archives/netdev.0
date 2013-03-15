From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 5/6] openvswitch: fix the calculation of
	checksum for vlan header
Date: Thu, 14 Mar 2013 17:15:05 -0700
Message-ID: <1363306506-885-6-git-send-email-jesse@nicira.com>
References: <1363306506-885-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1363306506-885-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

In vlan_insert_tag(), we insert a 4-byte VLAN header _after_
mac header:

        memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
        ...
        veth->h_vlan_proto = htons(ETH_P_8021Q);
        ...
        veth->h_vlan_TCI = htons(vlan_tci);

so after it, we should recompute the checksum to include these 4 bytes.
skb->data still points to the mac header, therefore VLAN header is at
(2 * ETH_ALEN = 12) bytes after it, not (ETH_HLEN = 14) bytes.

This can also be observed via tcpdump:

         0x0000:  ffff ffff ffff 5254 005d 6f6e 8100 000a
         0x0010:  0806 0001 0800 0604 0001 5254 005d 6f6e
         0x0020:  c0a8 026e 0000 0000 0000 c0a8 0282

Similar for __pop_vlan_tci(), the vlan header we remove is the one
overwritten in:

	memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);

Therefore the VLAN_HLEN = 4 bytes after 2 * ETH_ALEN is the part
we want to sub from checksum.

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ac2defe..d4d5363 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -58,7 +58,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
-					+ ETH_HLEN, VLAN_HLEN, 0));
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
 	vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
 	*current_tci = vhdr->h_vlan_TCI;
@@ -115,7 +115,7 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
-					+ ETH_HLEN, VLAN_HLEN, 0));
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
 	}
 	__vlan_hwaccel_put_tag(skb, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
-- 
1.7.10.4
