From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V3 net 1/3] vlan: Fix tcp checksum offloads in Q-in-Q vlans
Date: Tue, 23 May 2017 13:38:41 -0400
Message-ID: <1495561123-1819-2-git-send-email-vyasevic@redhat.com>
References: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Cc: alexander.duyck@gmail.com, makita.toshiaki@lab.ntt.co.jp,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Michal Kubecek <mkubecek@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32973 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932886AbdEWRiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 13:38:52 -0400
Received: by mail-qt0-f194.google.com with SMTP id a46so23135245qte.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 10:38:52 -0700 (PDT)
In-Reply-To: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that TCP checksum offloading has been broken for
Q-in-Q vlans.  The behavior was execerbated by the
series
    commit afb0bc972b52 ("Merge branch 'stacked_vlan_tso'")
that that enabled accleleration features on stacked vlans.

However, event without that series, it is possible to trigger
this issue.  It just requires a lot more specialized configuration.

The root cause is the interaction between how
netdev_intersect_features() works, the features actually set on
the vlan devices and HW having the ability to run checksum with
longer headers.

The issue starts when netdev_interesect_features() replaces
NETIF_F_HW_CSUM with a combination of NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM,
if the HW advertises IP|IPV6 specific checksums.  This happens
for tagged and multi-tagged packets.   However, HW that enables
IP|IPV6 checksum offloading doesn't gurantee that packets with
arbitrarily long headers can be checksummed.

This patch disables IP|IPV6 checksums on the packet for multi-tagged
packets.

CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
CC: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8d5fcd6..6686d0f 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -614,14 +614,16 @@ static inline bool skb_vlan_tagged_multi(const struct sk_buff *skb)
 static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 						    netdev_features_t features)
 {
-	if (skb_vlan_tagged_multi(skb))
-		features = netdev_intersect_features(features,
-						     NETIF_F_SG |
-						     NETIF_F_HIGHDMA |
-						     NETIF_F_FRAGLIST |
-						     NETIF_F_HW_CSUM |
-						     NETIF_F_HW_VLAN_CTAG_TX |
-						     NETIF_F_HW_VLAN_STAG_TX);
+	if (skb_vlan_tagged_multi(skb)) {
+		/* In the case of multi-tagged packets, use a direct mask
+		 * instead of using netdev_interesect_features(), to make
+		 * sure that only devices supporting NETIF_F_HW_CSUM will
+		 * have checksum offloading support.
+		 */
+		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM |
+			    NETIF_F_FRAGLIST | NETIF_F_HW_VLAN_CTAG_TX |
+			    NETIF_F_HW_VLAN_STAG_TX;
+	}
 
 	return features;
 }
-- 
2.7.4
