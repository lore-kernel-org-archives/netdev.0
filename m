From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: don't reassociate if user asked for deauthentication
Date: Sun, 30 Apr 2006 19:49:30 +0100 (BST)
Message-ID: <20060430184930.62BC3886AB6@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:18894 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750980AbWD3Stf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 14:49:35 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: softmac-dev@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When wpa_supplicant exits, it uses SIOCSIWMLME to request deauthentication.
softmac then tries to reassociate without any user intervention, which isn't
the desired behaviour of this signal.

This change makes softmac only attempt reassociation if the remote network
itself deauthenticated us.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -301,8 +301,6 @@ ieee80211softmac_deauth_from_net(struct 
 	
 	/* can't transmit data right now... */
 	netif_carrier_off(mac->dev);
-	/* let's try to re-associate */
-	schedule_work(&mac->associnfo.work);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
@@ -363,5 +361,8 @@ ieee80211softmac_deauth_resp(struct net_
 	}
 
 	ieee80211softmac_deauth_from_net(mac, net);
+
+	/* let's try to re-associate */
+	schedule_work(&mac->associnfo.work);
 	return 0;
 }
