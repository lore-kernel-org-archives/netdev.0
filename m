From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH] net:  Fix sk reference counting in ip_push_pending_frames
	and ip6_push_pending_frames
Date: Sat, 11 Jul 2009 17:46:10 +0000
Message-ID: <1247334370.7128.6.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f193.google.com ([209.85.216.193]:40323 "EHLO
	mail-px0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbZGKRqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 13:46:15 -0400
Received: by pxi31 with SMTP id 31so1118470pxi.33
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 10:46:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 "net: No more expensive
sock_hold()/sock_put() on each tx" used sk_wmem_alloc rather than the struct sock reference
count to track in-flight transmit-path packets.  However, it missed the __sock_put() calls
in ip_push_pending_frames() and ip6_push_pending_frames().  This results in too-small
reference counts when UDP or RAW sockets are used to send more than one MTU of data.  This 
in turn could lead to struct sock being freed and reused while it is still part of an
active socket.

A wide variety of socket symptoms may be fixed by this patch.  It also fixes one cause 
of WARN_ON's in sk_del_node_init() and sk_nulls_del_node_init_rcu().

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/ip_output.c  |    1 -
 net/ipv6/ip6_output.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2470262..7d08210 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1243,7 +1243,6 @@ int ip_push_pending_frames(struct sock *sk)
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
 	}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7c76e3d..87f8419 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1484,7 +1484,6 @@ int ip6_push_pending_frames(struct sock *sk)
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
 	}
-- 
1.5.4.3



