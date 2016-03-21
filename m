From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2] vxlan: fix too large pskb_may_pull with remote checksum
Date: Mon, 21 Mar 2016 17:50:05 +0100
Message-ID: <ea0a247890814c5546b6b4490eab79478df34124.1458578979.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767AbcCUQuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 12:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_remcsum is called after iptunnel_pull_header and thus the skb has
vxlan header already pulled. Don't include vxlan header again in the
calculation.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: Changed wording of the patch description to explain where the header is
    pulled.
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7bfcb9a62a5d..1c0fa364323e 100644
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
