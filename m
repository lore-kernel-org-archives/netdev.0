From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] benet: stricter vxlan offloading check in be_features_check
Date: Tue,  3 Jan 2017 16:26:04 +0100
Message-ID: <59e720bde70fb5226313c62d89b62cbbef25b3e2.1483455910.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759036AbdACP0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 10:26:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VXLAN offloading is enabled, be_features_check() tries to check if
an encapsulated packet is indeed a VXLAN packet. The check is not strict
enough, and considers any UDP-encapsulated ethernet frame with a 8-byte
tunnel header as being VXLAN. Unfortunately, both GENEVE and VXLAN-GPE
have a 8-byte header, so they get through this check.

Force the UDP destination port to be the one that has been offloaded to
hardware.

Without this, GENEVE-encapsulated packets can end up having an incorrect
checksum when both a GENEVE and a VXLAN (offloaded) tunnel are
configured.

This is similar to commit a547224dceed ("mlx4e: Do not attempt to
offload VXLAN ports that are unrecognized").

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
mlx4/5 already do something similar, but nfp/bnx2x/qlcnic don't.

This check was introduced in commit 16dde0d6ac15, but only made invalid
when GENEVE was introduced in 2d07dc79fe04.

 drivers/net/ethernet/emulex/benet/be_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7e1633bf5a22..225e9a4877d7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5155,7 +5155,9 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 	    skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
 	    skb->inner_protocol != htons(ETH_P_TEB) ||
 	    skb_inner_mac_header(skb) - skb_transport_header(skb) !=
-	    sizeof(struct udphdr) + sizeof(struct vxlanhdr))
+		sizeof(struct udphdr) + sizeof(struct vxlanhdr) ||
+	    !adapter->vxlan_port ||
+	    udp_hdr(skb)->dest != adapter->vxlan_port)
 		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
-- 
2.11.0
