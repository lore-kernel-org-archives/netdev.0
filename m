From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] Add a tcp_filter hook before handle ack packet
Date: Tue, 20 Jun 2017 19:06:40 -0700
Message-ID: <1498010800-3918-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34469 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752983AbdFUCHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 22:07:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id d5so26967805pfe.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 19:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Currently in both ipv4 and ipv6 code path, the ack packet received when
sk at TCP_NEW_SYN_RECV state is not filtered by socket filter or cgroup
filter since it is handled from tcp_child_process and never reaches the
tcp_filter inside tcp_v4_rcv or tcp_v6_rcv. Adding a tcp_filter hooks
here can make sure all the ingress tcp packet can be correctly filtered.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 net/ipv4/tcp_ipv4.c | 2 ++
 net/ipv6/tcp_ipv6.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1dc8c44..ca3afb0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1675,6 +1675,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		}
 		if (nsk == sk) {
 			reqsk_put(req);
+		} else if (tcp_filter(sk, skb)) {
+			goto discard_and_relse;
 		} else if (tcp_child_process(sk, nsk, skb)) {
 			tcp_v4_send_reset(nsk, skb);
 			goto discard_and_relse;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 84ad502..565d89b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1451,6 +1451,8 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 		if (nsk == sk) {
 			reqsk_put(req);
 			tcp_v6_restore_cb(skb);
+		} else if (tcp_filter(sk, skb)) {
+			goto discard_and_relse;
 		} else if (tcp_child_process(sk, nsk, skb)) {
 			tcp_v6_send_reset(nsk, skb);
 			goto discard_and_relse;
-- 
2.7.4
