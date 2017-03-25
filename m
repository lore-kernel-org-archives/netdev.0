From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] cfg80211: Fix array-bounds warning in fragment copy
Date: Fri, 24 Mar 2017 18:06:44 -0700
Message-ID: <20170325010644.190368-1-mka@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__ieee80211_amsdu_copy_frag intentionally initializes a pointer to
array[-1] to increment it later to valid values. clang rightfully
generates an array-bounds warning on the initialization statement.
Work around this by initializing the pointer to array[0] and
decrementing it later, which allows to leave the rest of the
algorithm untouched.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 net/wireless/util.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 68e5f2ecee1a..d3d459e4a070 100644
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
@@ -669,6 +669,7 @@ __ieee80211_amsdu_copy_frag(struct sk_buff *skb, struct sk_buff *frame,
 	frag_page = virt_to_head_page(skb->head);
 	frag_ptr = skb->data;
 	frag_size = head_size;
+	frag--;
 
 	while (offset >= frag_size) {
 		offset -= frag_size;
-- 
2.12.1.578.ge9c3154ca4-goog
