From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/5] vxlan: fix too large pskb_may_pull with remote checksum
Date: Fri, 26 Feb 2016 08:48:40 +0100
Message-ID: <d9b22ff3a50e2ae8b18d4c0f2bcfd04d10a95bad.1456472746.git.jbenc@redhat.com>
References: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753670AbcBZHtC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:49:02 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 5E782C0006EF
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:49:00 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrUx021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:48:59 -0500
In-Reply-To: <cover.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan header is pulled at this point, don't include it again in the
calculation.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 029e0e5b0b2b..81a7c1a829b9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1142,7 +1142,7 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 static bool vxlan_remcsum(struct vxlanhdr *unparsed,
 			  struct sk_buff *skb, u32 vxflags)
 {
-	size_t start, offset, plen;
+	size_t start, offset;
 
 	if (!(unparsed->vx_flags & VXLAN_HF_RCO) || skb->remcsum_offload)
 		goto out;
@@ -1150,9 +1150,7 @@ static bool vxlan_remcsum(struct vxlanhdr *unparsed,
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
