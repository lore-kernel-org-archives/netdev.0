From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Sun, 3 Dec 2006 16:32:00 +0100
Message-ID: <20061203153200.GA26888@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:21460 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S936778AbWLCPcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 10:32:01 -0500
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 2.6.19 a deauthentication from the AP doesn't start a
reassociation by the softmac code. It appears that
mac->associnfo.associating must be set and the
ieee80211softmac_assoc_work function must be scheduled. This patch
fixes that.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 net/ieee80211/softmac/ieee80211softmac_assoc.c |   14 ++++++++++++--
 net/ieee80211/softmac/ieee80211softmac_auth.c  |    2 ++
 net/ieee80211/softmac/ieee80211softmac_priv.h  |    2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index cf51c87..614aa8d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -427,6 +427,17 @@ ieee80211softmac_handle_assoc_response(s
 	return 0;
 }
 
+void
+ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->associnfo.associating = 1;
+	schedule_work(&mac->associnfo.work);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
 int
 ieee80211softmac_handle_disassoc(struct net_device * dev,
 				 struct ieee80211_disassoc *disassoc)
@@ -445,8 +456,7 @@ ieee80211softmac_handle_disassoc(struct 
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
 	ieee80211softmac_disassoc(mac);
 
-	/* try to reassociate */
-	schedule_work(&mac->associnfo.work);
+	ieee80211softmac_try_reassoc(mac);
 
 	return 0;
 }
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 4cef39e..88897e4 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -328,6 +328,8 @@ ieee80211softmac_deauth_from_net(struct 
 	/* can't transmit data right now... */
 	netif_carrier_off(mac->dev);
 	spin_unlock_irqrestore(&mac->lock, flags);
+
+	ieee80211softmac_try_reassoc(mac);
 }
 
 /* 
diff --git a/net/ieee80211/softmac/ieee80211softmac_priv.h b/net/ieee80211/softmac/ieee80211softmac_priv.h
index 0642e09..3ae894f 100644
--- a/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ b/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -238,4 +238,6 @@ void ieee80211softmac_call_events_locked
 int ieee80211softmac_notify_internal(struct ieee80211softmac_device *mac,
 	int event, void *event_context, notify_function_ptr fun, void *context, gfp_t gfp_mask);
 
+void ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac);
+
 #endif /* IEEE80211SOFTMAC_PRIV_H_ */
-- 
1.4.1
