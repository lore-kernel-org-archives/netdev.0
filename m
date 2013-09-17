From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] xfrm: Guard IPsec anti replay window against replay bitmap
Date: Tue, 17 Sep 2013 14:26:05 +0800
Message-ID: <1379399165-8955-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42494 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab3IQG0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 02:26:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For legacy IPsec anti replay mechanism:

bitmap in struct xfrm_replay_state could only provide a 32 bits
window size limit in current design, thus user level parameter
sadb_sa_replay should honor this limit, otherwise misleading
outputs("replay=244") by setkey -D will be:

192.168.25.2 192.168.22.2
	esp mode=transport spi=147561170(0x08cb9ad2) reqid=0(0x00000000)
	E: aes-cbc  9a8d7468 7655cf0b 719d27be b0ddaac2
	A: hmac-sha1  2d2115c2 ebf7c126 1c54f186 3b139b58 264a7331
	seq=0x00000000 replay=244 flags=0x00000000 state=mature
	created: Sep 17 14:00:00 2013	current: Sep 17 14:00:22 2013
	diff: 22(s)	hard: 30(s)	soft: 26(s)
	last: Sep 17 14:00:00 2013	hard: 0(s)	soft: 0(s)
	current: 1408(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 22	hard: 0	soft: 0
	sadb_seq=1 pid=4854 refcnt=0
192.168.22.2 192.168.25.2
	esp mode=transport spi=255302123(0x0f3799eb) reqid=0(0x00000000)
	E: aes-cbc  6485d990 f61a6bd5 e5660252 608ad282
	A: hmac-sha1  0cca811a eb4fa893 c47ae56c 98f6e413 87379a88
	seq=0x00000000 replay=244 flags=0x00000000 state=mature
	created: Sep 17 14:00:00 2013	current: Sep 17 14:00:22 2013
	diff: 22(s)	hard: 30(s)	soft: 26(s)
	last: Sep 17 14:00:00 2013	hard: 0(s)	soft: 0(s)
	current: 1408(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 22	hard: 0	soft: 0
	sadb_seq=0 pid=4854 refcnt=0

And also, optimizing xfrm_replay_check window checking by setting the
desirable x->props.replay_window with only doing the comparison once
for all when xfrm_state is first born.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/key/af_key.c       |    3 ++-
 net/xfrm/xfrm_replay.c |    3 +--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9d58537..911ef03 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1098,7 +1098,8 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 
 	x->id.proto = proto;
 	x->id.spi = sa->sadb_sa_spi;
-	x->props.replay_window = sa->sadb_sa_replay;
+	x->props.replay_window = min_t(unsigned int, sa->sadb_sa_replay,
+					(sizeof(x->replay.bitmap) * 8));
 	if (sa->sadb_sa_flags & SADB_SAFLAGS_NOECN)
 		x->props.flags |= XFRM_STATE_NOECN;
 	if (sa->sadb_sa_flags & SADB_SAFLAGS_DECAP_DSCP)
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 8dafe6d3..eeca388 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -129,8 +129,7 @@ static int xfrm_replay_check(struct xfrm_state *x,
 		return 0;
 
 	diff = x->replay.seq - seq;
-	if (diff >= min_t(unsigned int, x->props.replay_window,
-			  sizeof(x->replay.bitmap) * 8)) {
+	if (diff >= x->props.replay_window) {
 		x->stats.replay_window++;
 		goto err;
 	}
-- 
1.7.9.5
