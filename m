From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net 1/3] sctp: use the same clock as if sock source timestamps were on
Date: Fri,  4 Dec 2015 15:14:03 -0200
Message-ID: <8ff122e39159e5ccf1277c692ad7bd6431695825.1449249050.git.marcelo.leitner@gmail.com>
References: <20151203184316.GF4164@mrl.redhat.com> <cover.1449249050.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202AbbLDRPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 12:15:00 -0500
In-Reply-To: <cover.1449249050.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP echoes a cookie o INIT ACK chunks that contains a timestamp, for
detecting stale cookies. This cookie is echoed back to the server by the
client and then that timestamp is checked.

Thing is, if the listening socket is using packet timestamping, the
cookie is encoded with ktime_get() value and checked against
ktime_get_real(), as done by __net_timestamp().

The fix is to sctp also use ktime_get_real(), so we can compare bananas
with bananas later no matter if packet timestamping was enabled or not.

Fixes: 52db882f3fc2 ("net: sctp: migrate cookie life from timeval to ktime")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_make_chunk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 763e06a55155b2a9e0a9d918ecc1fe2dd6d9e0c0..5d6a03fad3789a12290f5f14c5a7efa69c98f41a 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1652,7 +1652,7 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 
 	/* Set an expiration time for the cookie.  */
 	cookie->c.expiration = ktime_add(asoc->cookie_life,
-					 ktime_get());
+					 ktime_get_real());
 
 	/* Copy the peer's init packet.  */
 	memcpy(&cookie->c.peer_init[0], init_chunk->chunk_hdr,
@@ -1780,7 +1780,7 @@ no_hmac:
 	if (sock_flag(ep->base.sk, SOCK_TIMESTAMP))
 		kt = skb_get_ktime(skb);
 	else
-		kt = ktime_get();
+		kt = ktime_get_real();
 
 	if (!asoc && ktime_before(bear_cookie->expiration, kt)) {
 		/*
-- 
2.5.0
