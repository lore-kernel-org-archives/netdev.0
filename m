From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] [NET] warn when accounting an skb that already has a
	destructor
Date: Sun, 04 May 2008 20:32:20 +0200
Message-ID: <1209925940.3655.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51469 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbYEDSc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 14:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the networking layer warn when something tries to
charge an skb to a socket that already is charged to another
socket (or has a destructor from somewhere else.)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Not sure if the code size increase is prohibitive, haven't really
checked. Might have helped in early mac80211 days (when we didn't
have the skb_orphan call) but for normal skb usage this shouldn't
ever happen.

 include/net/sock.h |    2 ++
 1 file changed, 2 insertions(+)

--- everything.orig/include/net/sock.h	2008-05-03 15:51:36.000000000 +0200
+++ everything/include/net/sock.h	2008-05-03 15:51:56.000000000 +0200
@@ -1167,6 +1167,7 @@ static inline void skb_set_owner_w(struc
 {
 	sock_hold(sk);
 	skb->sk = sk;
+	WARN_ON(skb->destructor);
 	skb->destructor = sock_wfree;
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }
@@ -1174,6 +1175,7 @@ static inline void skb_set_owner_w(struc
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
 	skb->sk = sk;
+	WARN_ON(skb->destructor);
 	skb->destructor = sock_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_charge(sk, skb->truesize);


