From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/4] sock: convert sk_peek_offset functions to WRITE_ONCE
Date: Sun,  3 Apr 2016 19:29:50 -0400
Message-ID: <1459726193-20863-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34974 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbcDCXaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:30:08 -0400
Received: by mail-qk0-f196.google.com with SMTP id s5so6971133qkd.2
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:30:08 -0700 (PDT)
In-Reply-To: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Make the peek offset interface safe to use in lockless environments.
Use READ_ONCE and WRITE_ONCE to avoid race conditions between testing
and updating the peek offset.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e0..6435f6d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -458,26 +458,28 @@ struct sock {
 
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
-	if ((flags & MSG_PEEK) && (sk->sk_peek_off >= 0))
-		return sk->sk_peek_off;
-	else
-		return 0;
+	if (unlikely(flags & MSG_PEEK)) {
+		s32 off = READ_ONCE(sk->sk_peek_off);
+		if (off >= 0)
+			return off;
+	}
+
+	return 0;
 }
 
 static inline void sk_peek_offset_bwd(struct sock *sk, int val)
 {
-	if (sk->sk_peek_off >= 0) {
-		if (sk->sk_peek_off >= val)
-			sk->sk_peek_off -= val;
-		else
-			sk->sk_peek_off = 0;
+	s32 off = READ_ONCE(sk->sk_peek_off);
+
+	if (unlikely(off >= 0)) {
+		off = max_t(s32, off - val, 0);
+		WRITE_ONCE(sk->sk_peek_off, off);
 	}
 }
 
 static inline void sk_peek_offset_fwd(struct sock *sk, int val)
 {
-	if (sk->sk_peek_off >= 0)
-		sk->sk_peek_off += val;
+	sk_peek_offset_bwd(sk, -val);
 }
 
 /*
-- 
2.8.0.rc3.226.g39d4020
