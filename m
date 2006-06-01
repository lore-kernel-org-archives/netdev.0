From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: unified capabilities computation
Date: Thu,  1 Jun 2006 17:12:49 +0100 (BST)
Message-ID: <20060601161249.8C9F289CF8D@zog.reactivated.net>
Cc: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:47381 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030203AbWFAQMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 12:12:55 -0400
To: linville@tuxdriver.com
Cc: josejx@gentoo.org
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph Jezak <josejx@gentoo.org>

This patch moves the capabilities field computation to a function for clarity
and adds some previously unimplemented bits.

Signed off by Joseph Jezak <josejx@gentoo.org>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-By: Johannes Berg <johannes@sipsolutions.net>
---

Index: linux/net/ieee80211/softmac/ieee80211softmac_io.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_io.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -149,6 +149,56 @@ ieee80211softmac_hdr_3addr(struct ieee80
 	 * shouldn't the sequence number be in ieee80211? */
 }
 
+static u16
+ieee80211softmac_capabilities(struct ieee80211softmac_device *mac,
+	struct ieee80211softmac_network *net)
+{
+	u16 capability = 0;
+
+	/* ESS and IBSS bits are set according to the current mode */
+	switch (mac->ieee->iw_mode) {
+	case IW_MODE_INFRA:
+		capability = cpu_to_le16(WLAN_CAPABILITY_ESS);
+		break;
+	case IW_MODE_ADHOC:
+		capability = cpu_to_le16(WLAN_CAPABILITY_IBSS);
+		break;
+	case IW_MODE_AUTO:
+		capability = net->capabilities &
+			(WLAN_CAPABILITY_ESS|WLAN_CAPABILITY_IBSS);
+		break;
+	default:
+		/* bleh. we don't ever go to these modes */
+		printk(KERN_ERR PFX "invalid iw_mode!\n");
+		break;
+	}
+
+	/* CF Pollable / CF Poll Request */
+	/* Needs to be implemented, for now, the 0's == not supported */
+
+	/* Privacy Bit */
+	capability |= mac->ieee->sec.level ?
+		cpu_to_le16(WLAN_CAPABILITY_PRIVACY) : 0;
+
+	/* Short Preamble */
+	/* Always supported: we probably won't ever be powering devices which
+	 * dont support this... */
+	capability |= WLAN_CAPABILITY_SHORT_PREAMBLE;
+
+	/* PBCC */
+	/* Not widely used */
+
+	/* Channel Agility */
+	/* Not widely used */
+
+	/* Short Slot */
+	/* Will be implemented later */
+
+	/* DSSS-OFDM */
+	/* Not widely used */
+
+	return capability;
+}
 
 /*****************************************************************************
  * Create Management packets
@@ -179,27 +229,6 @@ ieee80211softmac_assoc_req(struct ieee80
 		return 0;
 	ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_ASSOC_REQ, net->bssid, net->bssid);
 
-	/* Fill in capability Info */
-	switch (mac->ieee->iw_mode) {
-	case IW_MODE_INFRA:
-		(*pkt)->capability = cpu_to_le16(WLAN_CAPABILITY_ESS);
-		break;
-	case IW_MODE_ADHOC:
-		(*pkt)->capability = cpu_to_le16(WLAN_CAPABILITY_IBSS);
-		break;
-	case IW_MODE_AUTO:
-		(*pkt)->capability = net->capabilities & (WLAN_CAPABILITY_ESS|WLAN_CAPABILITY_IBSS);
-		break;
-	default:
-		/* bleh. we don't ever go to these modes */
-		printk(KERN_ERR PFX "invalid iw_mode!\n");
-		break;
-	}
-	/* Need to add this
-	(*pkt)->capability |= mac->ieee->short_slot ? 
-			cpu_to_le16(WLAN_CAPABILITY_SHORT_SLOT_TIME) : 0;
-	 */
-	(*pkt)->capability |= mac->ieee->sec.level ? cpu_to_le16(WLAN_CAPABILITY_PRIVACY) : 0;
 	/* Fill in Listen Interval (?) */
 	(*pkt)->listen_interval = cpu_to_le16(10);
 	
@@ -239,17 +268,9 @@ ieee80211softmac_reassoc_req(struct ieee
 		return 0;
 	ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_REASSOC_REQ, net->bssid, net->bssid);
 
-	/* Fill in capability Info */
-	(*pkt)->capability = mac->ieee->iw_mode == IW_MODE_MASTER ? 
-				cpu_to_le16(WLAN_CAPABILITY_ESS) :
-				cpu_to_le16(WLAN_CAPABILITY_IBSS);
-	/*
-	(*pkt)->capability |= mac->ieee->short_slot ? 
-			cpu_to_le16(WLAN_CAPABILITY_SHORT_SLOT_TIME) : 0;
-	 */
-	(*pkt)->capability |= mac->ieee->sec.level ?
-			cpu_to_le16(WLAN_CAPABILITY_PRIVACY) : 0;
-		
+	/* Fill in the capabilities */
+	(*pkt)->capability = ieee80211softmac_capabilities(mac, net);
+
 	/* Fill in Listen Interval (?) */
 	(*pkt)->listen_interval = cpu_to_le16(10);
 	/* Fill in the current AP MAC */
