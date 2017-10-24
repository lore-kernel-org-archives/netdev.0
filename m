From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] net: updating dst lastusage is an unlikely event.
Date: Tue, 24 Oct 2017 12:41:01 +0200
Message-ID: <cb6e9e39bdcdaebba87e331d7b18392bdeefebc3.1508841595.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932148AbdJXKlH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 06:41:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0da4af00b2ed ("ipv6: only update __use and lastusetime
once per jiffy at most"), updating the dst lastuse field is an
unlikely action: it happens at most once per jiffy, out of
potentially millions of calls per second.

Mark explicitly the code as such, and let the compiler generate
better code.

Note: gcc 7.2 and several older versions do actually generate
different - better - code when the unlikely() hint is in place,
avoid jump in the fast path and keeping better code locality.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/dst.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index d70b33dc2332..0744a9630eed 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -257,7 +257,7 @@ static inline void dst_hold(struct dst_entry *dst)
 
 static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 {
-	if (time != dst->lastuse) {
+	if (unlikely(time != dst->lastuse)) {
 		dst->__use++;
 		dst->lastuse = time;
 	}
-- 
2.13.6
