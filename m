From: Abdelrhman Ahmed <ab@abahmed.com>
Subject: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Fri, 07 Oct 2016 16:14:46 +0200
Message-ID: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>,
        "linux-kernel" <linux-kernel@vger.kernel.org>
To: "davem" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:21453 "EHLO
        sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751972AbcJGOOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 10:14:50 -0400
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hardware header is added without using cached one, neigh_resolve_output
and neigh_connected_output reset skb to network header before adding it.
When cached one is used, neigh_hh_output does not reset the skb to network
header.

The fix is to reset skb to network header before adding cached hardware header
to keep the behavior consistent in all cases.

Signed-off-by: Abdelrhman Ahmed <ab@abahmed.com>
---
 include/net/neighbour.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 8b68384..4d89fc2 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -424,7 +424,7 @@ static inline struct neighbour * neigh_clone(struct neighbour *neigh)
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
        unsigned long now = jiffies;
-       
+
        if (neigh->used != now)
                neigh->used = now;
        if (!(neigh->nud_state&(NUD_CONNECTED|NUD_DELAY|NUD_PROBE)))
@@ -451,6 +451,8 @@ static inline int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb
        unsigned int seq;
        int hh_len;
 
+       __skb_pull(skb, skb_network_offset(skb));
+
        do {
                seq = read_seqbegin(&hh->hh_lock);
                hh_len = hh->hh_len;
-- 
1.9.1
