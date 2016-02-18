From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: tun_id is 64bit, not 32bit
Date: Thu, 18 Feb 2016 19:19:29 +0100
Message-ID: <7fe6a16a4d1170ed72b7d5c36ca5e4fc4ee54488.1455819507.git.jbenc@redhat.com>
Cc: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426881AbcBRSTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 13:19:43 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 501FE12BE0
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 18:19:43 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun_id field in struct ip_tunnel_key is __be64, not __be32. We need to
convert the vni to tun_id correctly.

Fixes: 54bfd872bf16 ("vxlan: keep flags and vni in network byte order")
Reported-by: Paolo Abeni <pabeni@redhat.com>
Tested-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 5 +++--
 include/net/vxlan.h | 9 +++++++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3a84680b5117..75bccb360599 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1310,9 +1310,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if (vxlan_collect_metadata(vs)) {
+		__be32 vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
+
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
-					 vxlan_vni(vxlan_hdr(skb)->vx_vni),
-					 sizeof(*md));
+					 vxlan_vni_to_tun_id(vni), sizeof(*md));
 
 		if (!tun_dst)
 			goto drop;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 1b85a3b40c5a..748083de367a 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -294,6 +294,15 @@ static inline __be32 vxlan_tun_id_to_vni(__be64 tun_id)
 #endif
 }
 
+static inline __be64 vxlan_vni_to_tun_id(__be32 vni)
+{
+#if defined(__BIG_ENDIAN)
+	return (__be64)vni;
+#else
+	return (__be64)vni << 32;
+#endif
+}
+
 static inline size_t vxlan_rco_start(__be32 vni_field)
 {
 	return be32_to_cpu(vni_field & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
-- 
1.8.3.1
