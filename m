From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 48/51] mac80211_hwsim: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:38 -0400
Message-ID: <1333335521-1348-49-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab2DBDAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:46 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/mac80211_hwsim.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index b7ce6a6..538783f 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -582,11 +582,13 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		goto nla_put_failure;
 	}
 
-	NLA_PUT(skb, HWSIM_ATTR_ADDR_TRANSMITTER,
-		     sizeof(struct mac_address), data->addresses[1].addr);
+	if (nla_put(skb, HWSIM_ATTR_ADDR_TRANSMITTER,
+		    sizeof(struct mac_address), data->addresses[1].addr))
+		goto nla_put_failure;
 
 	/* We get the skb->data */
-	NLA_PUT(skb, HWSIM_ATTR_FRAME, my_skb->len, my_skb->data);
+	if (nla_put(skb, HWSIM_ATTR_FRAME, my_skb->len, my_skb->data))
+		goto nla_put_failure;
 
 	/* We get the flags for this transmission, and we translate them to
 	   wmediumd flags  */
@@ -597,7 +599,8 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 	if (info->flags & IEEE80211_TX_CTL_NO_ACK)
 		hwsim_flags |= HWSIM_TX_CTL_NO_ACK;
 
-	NLA_PUT_U32(skb, HWSIM_ATTR_FLAGS, hwsim_flags);
+	if (nla_put_u32(skb, HWSIM_ATTR_FLAGS, hwsim_flags))
+		goto nla_put_failure;
 
 	/* We get the tx control (rate and retries) info*/
 
@@ -606,12 +609,14 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		tx_attempts[i].count = info->status.rates[i].count;
 	}
 
-	NLA_PUT(skb, HWSIM_ATTR_TX_INFO,
-		     sizeof(struct hwsim_tx_rate)*IEEE80211_TX_MAX_RATES,
-		     tx_attempts);
+	if (nla_put(skb, HWSIM_ATTR_TX_INFO,
+		    sizeof(struct hwsim_tx_rate)*IEEE80211_TX_MAX_RATES,
+		    tx_attempts))
+		goto nla_put_failure;
 
 	/* We create a cookie to identify this skb */
-	NLA_PUT_U64(skb, HWSIM_ATTR_COOKIE, (unsigned long) my_skb);
+	if (nla_put_u64(skb, HWSIM_ATTR_COOKIE, (unsigned long) my_skb))
+		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
 	genlmsg_unicast(&init_net, skb, dst_pid);
@@ -1108,7 +1113,8 @@ static int mac80211_hwsim_testmode_cmd(struct ieee80211_hw *hw,
 						nla_total_size(sizeof(u32)));
 		if (!skb)
 			return -ENOMEM;
-		NLA_PUT_U32(skb, HWSIM_TM_ATTR_PS, hwsim->ps);
+		if (nla_put_u32(skb, HWSIM_TM_ATTR_PS, hwsim->ps))
+			goto nla_put_failure;
 		return cfg80211_testmode_reply(skb);
 	default:
 		return -EOPNOTSUPP;
-- 
1.7.7.6
