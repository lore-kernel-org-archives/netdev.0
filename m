From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH v2] cfg80211: Fix array-bounds warning in fragment copy
Date: Thu, 13 Apr 2017 10:05:04 -0700
Message-ID: <20170413170504.110612-1-mka@chromium.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, grundler@chromium.org,
        Greg Hackmann <ghackmann@google.com>,
        Michael Davidson <md@google.com>,
        Matthias Kaehlcke <mka@chromium.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35108 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdDMRFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 13:05:13 -0400
Received: by mail-pg0-f50.google.com with SMTP id 72so24804342pge.2
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 10:05:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ieee80211_amsdu_copy_frag intentionally initializes a pointer to
array[-1] to increment it later to valid values. clang rightfully
generates an array-bounds warning on the initialization statement.

Initialize the pointer to array[0] and change the algorithm from
increment before to increment after consume.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
Note: Resent to include linux-wireless in cc

 net/wireless/util.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 68e5f2ecee1a..52795ae5337f 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -659,7 +659,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
 			    int offset, int len)
 {
 	struct skb_shared_info *sh = skb_shinfo(skb);
-	const skb_frag_t *frag = &sh->frags[-1];
+	const skb_frag_t *frag = &sh->frags[0];
 	struct page *frag_page;
 	void *frag_ptr;
 	int frag_len, frag_size;
@@ -672,10 +672,10 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
 
 	while (offset >= frag_size) {
 		offset -= frag_size;
-		frag++;
 		frag_page = skb_frag_page(frag);
 		frag_ptr = skb_frag_address(frag);
 		frag_size = skb_frag_size(frag);
+		frag++;
 	}
 
 	frag_ptr += offset;
@@ -687,12 +687,12 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
 	len -= cur_len;
 
 	while (len > 0) {
-		frag++;
 		frag_len = skb_frag_size(frag);
 		cur_len = min(len, frag_len);
 		__frame_add_frag(frame, skb_frag_page(frag),
 				 skb_frag_address(frag), cur_len, frag_len);
 		len -= cur_len;
+		frag++;
 	}
 }
 
-- 
2.12.2.715.g7642488e1d-goog
