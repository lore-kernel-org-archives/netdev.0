From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 1/2] netlink: only do not deliver to tap when both sides are kernel sks
Date: Mon, 23 Dec 2013 09:48:38 +0100
Message-ID: <1387788519-17722-2-git-send-email-dborkman@redhat.com>
References: <1387788519-17722-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab3LWItO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 03:49:14 -0500
In-Reply-To: <1387788519-17722-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should also deliver packets to nlmon devices when we are in
netlink_unicast_kernel(), and only one of the {src,dst} sockets
is user sk and the other one kernel sk. That's e.g. the case in
netlink diag, netlink route, etc. Still, forbid to deliver messages
from kernel to kernel sks.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
---
 v1->v2:
  - unchanged

 net/netlink/af_netlink.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bca50b9..56e09d8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -239,6 +239,13 @@ static void netlink_deliver_tap(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+static void netlink_deliver_tap_kernel(struct sock *dst, struct sock *src,
+				       struct sk_buff *skb)
+{
+	if (!(netlink_is_kernel(dst) && netlink_is_kernel(src)))
+		netlink_deliver_tap(skb);
+}
+
 static void netlink_overrun(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1697,14 +1704,10 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
-		/* We could do a netlink_deliver_tap(skb) here as well
-		 * but since this is intended for the kernel only, we
-		 * should rather let it stay under the hood.
-		 */
-
 		ret = skb->len;
 		netlink_skb_set_owner_r(skb, sk);
 		NETLINK_CB(skb).sk = ssk;
+		netlink_deliver_tap_kernel(sk, ssk, skb);
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
 	} else {
-- 
1.7.11.7
