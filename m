From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 08/14] net: wireless: mac80211: shrink ieee80211_tx_info
Date: Mon,  2 Mar 2015 18:40:22 +0100
Message-ID: <1425318028-26531-9-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, linux-wireless@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54115 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754648AbbCBRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:47 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to make it fit into (future) 44-byte sized skb->cb[].

This works, since flags is only used to store values
from mac80211_tx_control_flags enum, and these are just 2 bits.
We can thus move this to the padding hole inside the union.

Also add BUILD_BUG_ON magic to make sure that the new flags
field doesn't share storage w. other members of the union.

Cc: linux-wireless@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/mac80211.h | 11 ++++++++---
 net/mac80211/main.c    |  3 +++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 63c3708..36c2599 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -737,16 +737,21 @@ struct ieee80211_tx_info {
 					u8 use_cts_prot:1;
 					u8 short_preamble:1;
 					u8 skip_table:1;
-					/* 2 bytes free */
+					enum mac80211_tx_control_flags flags:2;
+					/* used for BUILD_BUG_ON validation that ->flags won't
+					 * overlap with jiffies below */
+					char flags_end[0];
 				};
 				/* only needed before rate control */
 				unsigned long jiffies;
+
+				/* used for BUILD_BUG_ON validation that ->flags won't
+				 * overlap with other members of this union. */
+				char union_end[0];
 			};
 			/* NB: vif can be NULL for injected frames */
 			struct ieee80211_vif *vif;
 			struct ieee80211_key_conf *hw_key;
-			u32 flags;
-			/* 4 bytes free */
 		} control;
 		struct {
 			struct ieee80211_tx_rate rates[IEEE80211_TX_MAX_RATES];
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 5e09d35..9e8c807 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1218,6 +1218,9 @@ static int __init ieee80211_init(void)
 	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, driver_data) +
 		     IEEE80211_TX_INFO_DRIVER_DATA_SIZE > sizeof(skb->cb));
 
+	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, control.flags_end) <
+		     offsetof(struct ieee80211_tx_info, control.union_end));
+
 	ret = rc80211_minstrel_init();
 	if (ret)
 		return ret;
-- 
2.0.5
