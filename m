From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/2] ip6_gre: Do not allow segmentation offloads
 GRE_CSUM is enabled with FOU/GUE
Date: Wed, 18 May 2016 10:44:47 -0700
Message-ID: <20160518174447.2608.2234.stgit@localhost.localdomain>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: tom@herbertland.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33650 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932340AbcERRot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:44:49 -0400
Received: by mail-pa0-f46.google.com with SMTP id xk12so19995166pac.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:44:49 -0700 (PDT)
In-Reply-To: <20160518173605.2608.42484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses the same issue we had for IPv4 where enabling GRE with
an inner checksum cannot be supported with FOU/GUE due to the fact that
they will jump past the GRE header at it is treated like a tunnel header.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv6/ip6_gre.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6fb1b89d0178..af503f518278 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1355,11 +1355,15 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	dev->hw_features	|= GRE6_FEATURES;
 
 	if (!(nt->parms.o_flags & TUNNEL_SEQ)) {
-		/* TCP segmentation offload is not supported when we
-		 * generate output sequences.
+		/* TCP offload with GRE SEQ is not supported, nor
+		 * can we support 2 levels of outer headers requiring
+		 * an update.
 		 */
-		dev->features    |= NETIF_F_GSO_SOFTWARE;
-		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+		if (!(nt->parms.o_flags & TUNNEL_CSUM) ||
+		    (nt->encap.type == TUNNEL_ENCAP_NONE)) {
+			dev->features    |= NETIF_F_GSO_SOFTWARE;
+			dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+		}
 
 		/* Can use a lockless transmit, unless we generate
 		 * output sequences
