From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 4 Mar 2016 13:09:49 +1100
Message-ID: <20160304130949.47a94ac8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Benc <jbenc@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/vxlan.c

between commit:

  4024fcf70556 ("vxlan: fix missing options_len update on RX with collect metadata")

from the net tree and commit:

  3288af0892e3 ("vxlan: move GBP header parsing to a separate function")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/vxlan.c
index 1c32bd104797,775ddb48388d..000000000000
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@@ -1129,49 -1144,61 +1146,63 @@@ static bool vxlan_remcsum(struct vxlanh
  {
  	size_t start, offset, plen;
  
- 	if (skb->remcsum_offload)
- 		return vh;
+ 	if (!(unparsed->vx_flags & VXLAN_HF_RCO) || skb->remcsum_offload)
+ 		goto out;
  
- 	start = (data & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
- 	offset = start + ((data & VXLAN_RCO_UDP) ?
- 			  offsetof(struct udphdr, check) :
- 			  offsetof(struct tcphdr, check));
+ 	start = vxlan_rco_start(unparsed->vx_vni);
+ 	offset = start + vxlan_rco_offset(unparsed->vx_vni);
  
- 	plen = hdrlen + offset + sizeof(u16);
+ 	plen = sizeof(struct vxlanhdr) + offset + sizeof(u16);
  
  	if (!pskb_may_pull(skb, plen))
- 		return NULL;
+ 		return false;
+ 
+ 	skb_remcsum_process(skb, (void *)(vxlan_hdr(skb) + 1), start, offset,
+ 			    !!(vxflags & VXLAN_F_REMCSUM_NOPARTIAL));
+ out:
+ 	unparsed->vx_flags &= ~VXLAN_HF_RCO;
+ 	unparsed->vx_vni &= VXLAN_VNI_MASK;
+ 	return true;
+ }
+ 
+ static void vxlan_parse_gbp_hdr(struct vxlanhdr *unparsed,
+ 				struct sk_buff *skb, u32 vxflags,
+ 				struct vxlan_metadata *md)
+ {
+ 	struct vxlanhdr_gbp *gbp = (struct vxlanhdr_gbp *)unparsed;
+ 	struct metadata_dst *tun_dst;
  
- 	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
+ 	if (!(unparsed->vx_flags & VXLAN_HF_GBP))
+ 		goto out;
  
- 	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset,
- 			    nopartial);
+ 	md->gbp = ntohs(gbp->policy_id);
  
- 	return vh;
+ 	tun_dst = (struct metadata_dst *)skb_dst(skb);
 -	if (tun_dst)
++	if (tun_dst) {
+ 		tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
++		tun_dst->u.tun_info.options_len = sizeof(*md);
++	}
+ 
+ 	if (gbp->dont_learn)
+ 		md->gbp |= VXLAN_GBP_DONT_LEARN;
+ 
+ 	if (gbp->policy_applied)
+ 		md->gbp |= VXLAN_GBP_POLICY_APPLIED;
+ 
+ 	/* In flow-based mode, GBP is carried in dst_metadata */
+ 	if (!(vxflags & VXLAN_F_COLLECT_METADATA))
+ 		skb->mark = md->gbp;
+ out:
+ 	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
  }
  
- static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
- 		      struct vxlan_metadata *md, u32 vni,
- 		      struct metadata_dst *tun_dst)
+ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
+ 			  struct vxlan_sock *vs,
+ 			  struct sk_buff *skb)
  {
- 	struct iphdr *oip = NULL;
- 	struct ipv6hdr *oip6 = NULL;
- 	struct vxlan_dev *vxlan;
- 	struct pcpu_sw_netstats *stats;
  	union vxlan_addr saddr;
- 	int err = 0;
- 
- 	/* For flow based devices, map all packets to VNI 0 */
- 	if (vs->flags & VXLAN_F_COLLECT_METADATA)
- 		vni = 0;
- 
- 	/* Is this VNI defined? */
- 	vxlan = vxlan_vs_find_vni(vs, vni);
- 	if (!vxlan)
- 		goto drop;
  
  	skb_reset_mac_header(skb);
- 	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
  	skb->protocol = eth_type_trans(skb, vxlan->dev);
  	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
  
