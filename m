From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net] tcp-repair: Handle zero-length data put in rcv queue
Date: Mon, 29 Oct 2012 19:05:33 +0400
Message-ID: <508E9B3D.1050505@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Giorgos Mavrikas <gmavrikas@gmail.com>
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37293 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab2J2PFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 11:05:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending data into a tcp socket in repair state we should check
for the amount of data being 0 explicitly. Otherwise we'll have an skb 
with seq == end_seq in rcv queue, but tcp doesn't expect this to happen
(in particular a warn_on in tcp_recvmsg shoots).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Reported-by: Giorgos Mavrikas <gmavrikas@gmail.com>

---

>From 8f70f4ea4f509a3772ee7eb5d9d5c2571a86652a Mon Sep 17 00:00:00 2001
From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 29 Oct 2012 18:12:41 +0400
Subject: [PATCH] fix for repair queue getback

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 432c366..ff5b746 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4529,6 +4529,9 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	struct tcphdr *th;
 	bool fragstolen;
 
+	if (size == 0)
+		return 0;
+
 	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
 	if (!skb)
 		goto err;
-- 
1.7.6.5
