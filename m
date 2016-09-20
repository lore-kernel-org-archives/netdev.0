From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 10:27:00 -0400
Message-ID: <20160920142700.GJ8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        aduyck@mirantis.com, daniel@iogearbox.net, pabeni@redhat.com,
        sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25113 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754714AbcITO1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:27:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan header is at offset (14 + 20 + 8) into the packet,
so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
functions to modify flags and vni field in the vxh.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/vxlan.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e7d1668..f903fa4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1751,15 +1751,17 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 		goto out_free;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = VXLAN_HF_VNI;
-	vxh->vx_vni = vxlan_vni_field(vni);
+	put_unaligned(VXLAN_HF_VNI, &vxh->vx_flags);
+	put_unaligned(vxlan_vni_field(vni), &vxh->vx_vni);
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
 		unsigned int start;
+		__be32 tmpvni = get_unaligned(&vxh->vx_vni);
 
 		start = skb_checksum_start_offset(skb) - sizeof(struct vxlanhdr);
-		vxh->vx_vni |= vxlan_compute_rco(start, skb->csum_offset);
-		vxh->vx_flags |= VXLAN_HF_RCO;
+		tmpvni |= vxlan_compute_rco(start, skb->csum_offset);
+		put_unaligned(tmpvni, &vxh->vx_vni);
+		put_unaligned(VXLAN_HF_VNI | VXLAN_HF_RCO, &vxh->vx_flags);
 
 		if (!skb_is_gso(skb)) {
 			skb->ip_summed = CHECKSUM_NONE;
-- 
1.7.1
