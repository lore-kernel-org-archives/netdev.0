From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] iwlwifi: dont pull too much payload in skb head
Date: Fri, 18 May 2012 16:48:33 +0200
Message-ID: <1337352513.7029.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43012 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab2EROsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 10:48:39 -0400
Received: by eaak11 with SMTP id k11so839410eaa.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 07:48:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since merge window is now pretty close, I would prefer David applies
this directly in net-next, if you dont mind, as this patch is more a
core network issue than an iwlwifi one.

Thanks !

[PATCH net-next] iwlwifi: dont pull too much payload in skb head

As iwlwifi use fat skbs, it should not pull too much data in skb->head,
and particularly no tcp data payload, or splice() is slower, and TCP
coalescing is disabled. Copying payload to userland also involves at
least two copies (part from header, part from fragment)

Each layer will pull its header from the fragment as needed.

(on 64bit arches, skb_tailroom(skb) at this point is 192 bytes)

With this patch applied, I have a major reduction of collapsed/pruned
TCP packets, a nice increase of TCPRcvCoalesce counter, and overall
better Internet User experience.

Small packets are still using a fragless skb, so that page can be reused
by the driver.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index 18a3837..403de96 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@ -759,7 +759,12 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 		IWL_ERR(priv, "alloc_skb failed\n");
 		return;
 	}
-	hdrlen = min_t(unsigned int, len, skb_tailroom(skb));
+	/* If frame is small enough to fit in skb->head, pull it completely.
+	 * If not, only pull ieee80211_hdr so that splice() or TCP coalesce
+	 * are more efficient.
+	 */
+	hdrlen = (len <= skb_tailroom(skb)) ? len : sizeof(*hdr);
+
 	memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
 	fraglen = len - hdrlen;
 
