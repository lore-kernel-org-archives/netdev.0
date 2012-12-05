From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH 2/3] fix panic in tcp_close()
Date: Wed,  5 Dec 2012 10:54:18 +0800
Message-ID: <1bce4074c1b2db217fa206c122902cef54e22280.1354674154.git.wpan@redhat.com>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
 <cover.1354674151.git.wpan@redhat.com>
Cc: brutus@google.com, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab2LECy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 21:54:29 -0500
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
References: <cover.1354674151.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For tcp friends data skb, it has no tcp header,
and its transport_header is NULL, so it will panic if we deference tcp_hdr(skb)
in tcp_close().

So I add a check before we use tcp_hdr().

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 net/ipv4/tcp.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4327deb..e9d82e0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2512,8 +2512,12 @@ void tcp_close(struct sock *sk, long timeout)
 	 *  reader process may not have drained the data yet!
 	 */
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-		u32 len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq -
+		u32 len;
+		if (tcp_hdr(skb))
+			len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq -
 			  tcp_hdr(skb)->fin;
+		else
+			len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq;
 		data_was_unread += len;
 		__kfree_skb(skb);
 	}
-- 
1.7.4.4
