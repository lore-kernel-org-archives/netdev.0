From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] wl12xx: fix size of two memset's in
 wl1271_cmd_build_arp_rsp()
Date: Sun, 22 Apr 2012 22:53:59 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204222252000.27455@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Luciano Coelho <coelho@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:13354 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327Ab2DVUyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 16:54:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently do this:

int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
...
	struct wl12xx_arp_rsp_template *tmpl;
	struct ieee80211_hdr_3addr *hdr;
...
	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
	memset(tmpl, 0, sizeof(tmpl));
...
	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
	memset(hdr, 0, sizeof(*hdr));
...

I believe we want to set the entire structures to 0 with those
memset() calls, not just zero the initial part of them (size of the
pointer bytes).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/wl12xx/cmd.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/cmd.c b/drivers/net/wireless/wl12xx/cmd.c
index 3414fc1..8e65529 100644
--- a/drivers/net/wireless/wl12xx/cmd.c
+++ b/drivers/net/wireless/wl12xx/cmd.c
@@ -1249,7 +1249,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	skb_reserve(skb, sizeof(*hdr) + WL1271_EXTRA_SPACE_MAX);
 
 	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
-	memset(tmpl, 0, sizeof(tmpl));
+	memset(tmpl, 0, sizeof(*tmpl));
 
 	/* llc layer */
 	memcpy(tmpl->llc_hdr, rfc1042_header, sizeof(rfc1042_header));
@@ -1298,7 +1298,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	/* mac80211 header */
 	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
-	memset(hdr, 0, sizeof(hdr));
+	memset(hdr, 0, sizeof(*hdr));
 	fc = IEEE80211_FTYPE_DATA | IEEE80211_FCTL_TODS;
 	if (wlvif->sta.qos)
 		fc |= IEEE80211_STYPE_QOS_DATA;
-- 
1.7.10


Please CC me on replies.


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
