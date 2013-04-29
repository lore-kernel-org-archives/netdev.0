From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH v3 1/3] unix/dgram: peek beyond 0-sized skbs
Date: Mon, 29 Apr 2013 17:42:12 -0400
Message-ID: <1367271734-14379-1-git-send-email-bpoirier@suse.de>
References: <kll5si$544$1@ger.gmane.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:62517 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908Ab3D2Vmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 17:42:37 -0400
In-Reply-To: <kll5si$544$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"77c1090 net: fix infinite loop in __skb_recv_datagram()" (v3.8) introduced a
regression:
After that commit, recv can no longer peek beyond a 0-sized skb in the queue.
__skb_recv_datagram() instead stops at the first skb with len == 0 and results
in the system call failing with -EFAULT via skb_copy_datagram_iovec().

When peeking at an offset with 0-sized skb(s), each one of those is received
only once, in sequence. The offset starts moving forward again after receiving
datagrams with len > 0.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

---

* v1 fix the case when SO_PEEK_OFF is used to set sk_peek_off beyond a
  0-sized skb

* v2 also fix the situation when sk_peek_off must advance to and beyond a
  0-sized skb

 net/core/datagram.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 368f9c3..99c4f52 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -187,7 +187,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		skb_queue_walk(queue, skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
-				if (*off >= skb->len && skb->len) {
+				if (*off >= skb->len && (skb->len || *off ||
+							 skb->peeked)) {
 					*off -= skb->len;
 					continue;
 				}
-- 
1.7.10.4
