From: Ed Cashin <ecashin@coraid.com>
Subject: [PATCH 2/2] net: do not disable sg for packets requiring no checksum
Date: Wed, 19 Sep 2012 18:20:28 -0700
Message-ID: <d7700b3b5e169d98c058fe086e69ed665048a475.1348088283.git.ecashin@coraid.com>
References: <1348079358.4585@cat.he.net>
	<cover.1348088283.git.ecashin@coraid.com>
Cc: ecashin@coraid.com, akpm@linux-foundation.org,
	bhutchings@solarflare.com, jesse@nicira.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1348088283.git.ecashin@coraid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A change in a series of VLAN-related changes appears to have
inadvertently disabled the use of the scatter gather feature of
network cards for transmission of non-IP ethernet protocols like ATA
over Ethernet (AoE).  Below is a reference to the commit that
introduces a "harmonize_features" function that turns off scatter
gather when the NIC does not support hardware checksumming for the
ethernet protocol of an sk buff.

  commit f01a5236bd4b140198fbcc550f085e8361fd73fa
  Author: Jesse Gross <jesse@nicira.com>
  Date:   Sun Jan 9 06:23:31 2011 +0000

      net offloading: Generalize netif_get_vlan_features().

The can_checksum_protocol function is not equipped to consider a
protocol that does not require checksumming.  Calling it for a
protocol that requires no checksum is inappropriate.

The patch below has harmonize_features call can_checksum_protocol when
the protocol needs a checksum, so that the network layer is not forced
to perform unnecessary skb linearization on the transmission of AoE
packets.  Unnecessary linearization results in decreased performance
and increased memory pressure, as reported here:

  http://www.spinics.net/lists/linux-mm/msg15184.html

The problem has probably not been widely experienced yet, because
only recently has the kernel.org-distributed aoe driver acquired the
ability to use payloads of over a page in size, with the patchset
recently included in the mm tree:

  https://lkml.org/lkml/2012/8/28/140

The coraid.com-distributed aoe driver already could use payloads of
greater than a page in size, but its users generally do not use the
newest kernels.

Signed-off-by: Ed Cashin <ecashin@coraid.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d7fe32c..9b934d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2134,7 +2134,8 @@ static bool can_checksum_protocol(netdev_features_t features, __be16 protocol)
 static netdev_features_t harmonize_features(struct sk_buff *skb,
 	__be16 protocol, netdev_features_t features)
 {
-	if (!can_checksum_protocol(features, protocol)) {
+	if (skb->ip_summed != CHECKSUM_NONE &&
+	    !can_checksum_protocol(features, protocol)) {
 		features &= ~NETIF_F_ALL_CSUM;
 		features &= ~NETIF_F_SG;
 	} else if (illegal_highdma(skb->dev, skb)) {
-- 
1.7.2.5
