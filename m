From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Thu, 18 May 2017 09:31:03 -0400
Message-ID: <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35723 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755253AbdERNb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:31:26 -0400
Received: by mail-qt0-f193.google.com with SMTP id r58so5699200qtb.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 06:31:21 -0700 (PDT)
In-Reply-To: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that since commit 8cb65d000, Q-in-Q vlans have been
broken.  The series that commit is part of enabled TSO and checksum
offloading on Q-in-Q vlans.  However, most HW we support can't handle
it.  To work around the issue, the above commit added a function that
turns off offloads on Q-in-Q devices, but it left the checksum offload.
That will cause issues with most older devices that supprort very basic
checksum offload capabilities as well as some newer devices (we've
reproduced te problem with both be2net and bnx).

To solve this for everyone, turn off checksum offloading feature
by default when sending Q-in-Q traffic.  Devices that are proven to
work can provided a corrected ndo_features_check implemetation.

Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8d5fcd6..ae537f0 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -619,7 +619,6 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 						     NETIF_F_SG |
 						     NETIF_F_HIGHDMA |
 						     NETIF_F_FRAGLIST |
-						     NETIF_F_HW_CSUM |
 						     NETIF_F_HW_VLAN_CTAG_TX |
 						     NETIF_F_HW_VLAN_STAG_TX);
 
-- 
2.7.4
