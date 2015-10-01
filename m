From: Andrey Vagin <avagin@gmail.com>
Subject: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Fri,  2 Oct 2015 00:05:36 +0300
Message-ID: <1443733536-992-1-git-send-email-avagin@gmail.com>
Cc: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:36266 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbJAVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 17:06:08 -0400
Received: by lbbti1 with SMTP id ti1so1348485lbb.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 14:06:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>

Now send with MSG_PEEK can return data from multiple SKBs.

Unfortunately we take into account the peek offset for each skb,
that is wrong. We need to apply the peek offset only once.

In addition, the peek offset should be used only if MSG_PEEK is set.

Cc: "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
Cc: Eric Dumazet <edumazet@google.com> (commit_signer:1/14=7%)
Cc: Aaron Conole <aconole@bytheb.org>
Fixes: 9f389e35674f ("af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag")
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/unix/af_unix.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ef31b40..94f6582 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2064,6 +2064,11 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 		goto out;
 	}
 
+	if (flags & MSG_PEEK)
+		skip = sk_peek_offset(sk, flags);
+	else
+		skip = 0;
+
 	do {
 		int chunk;
 		struct sk_buff *skb, *last;
@@ -2112,7 +2117,6 @@ unlock:
 			break;
 		}
 
-		skip = sk_peek_offset(sk, flags);
 		while (skip >= unix_skb_len(skb)) {
 			skip -= unix_skb_len(skb);
 			last = skb;
@@ -2179,14 +2183,12 @@ unlock:
 			if (UNIXCB(skb).fp)
 				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
-			if (skip) {
-				sk_peek_offset_fwd(sk, chunk);
-				skip -= chunk;
-			}
+			sk_peek_offset_fwd(sk, chunk);
 
 			if (UNIXCB(skb).fp)
 				break;
 
+			skip = 0;
 			last = skb;
 			last_len = skb->len;
 			unix_state_lock(sk);
-- 
2.4.3
