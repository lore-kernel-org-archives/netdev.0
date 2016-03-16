From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: fix too large pskb_may_pull with remote checksum
Date: Wed, 16 Mar 2016 17:35:47 +0100
Message-ID: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316AbcCPQgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 12:36:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan header is pulled at this point, don't include it again in the
calculation.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
This was previously part of the VXLAN-GPE patchset but it's not really
related (especially not after the discussion that RCO should not be allowed
together with GPE). I'm sending it separately.
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 800106a7246c..1eb8347f440c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1143,7 +1143,7 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 static bool vxlan_remcsum(struct vxlanhdr *unparsed,
 			  struct sk_buff *skb, u32 vxflags)
 {
-	size_t start, offset, plen;
+	size_t start, offset;
 
 	if (!(unparsed->vx_flags & VXLAN_HF_RCO) || skb->remcsum_offload)
 		goto out;
@@ -1151,9 +1151,7 @@ static bool vxlan_remcsum(struct vxlanhdr *unparsed,
 	start = vxlan_rco_start(unparsed->vx_vni);
 	offset = start + vxlan_rco_offset(unparsed->vx_vni);
 
-	plen = sizeof(struct vxlanhdr) + offset + sizeof(u16);
-
-	if (!pskb_may_pull(skb, plen))
+	if (!pskb_may_pull(skb, offset + sizeof(u16)))
 		return false;
 
 	skb_remcsum_process(skb, (void *)(vxlan_hdr(skb) + 1), start, offset,
-- 
1.8.3.1
