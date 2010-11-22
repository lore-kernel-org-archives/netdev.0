From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 6/9] AF_UNIX: Apply Linux Socket Filtering to Unix sockets
Date: Mon, 22 Nov 2010 18:36:19 +0000
Message-ID: <1290450982-17480-6-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Socket Filters can already be attached to Unix sockets with
setsockopt(sockfd, SOL_SOCKET, SO_{ATTACH,DETACH}_FILTER, ...) But the filter
was never used in Unix sockets so it did not work. This patch uses sk_filter()
to filter buffers before delivery.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 9207393..52e2aa2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1669,6 +1669,7 @@ restart:
 
 	for (i = 0 ; i < others_set->cnt ; i++) {
 		struct sock *cur = others_set->items[i].s;
+		unsigned int pkt_len;
 
 		others_set->items[i].skb = skb_clone(skb, GFP_KERNEL);
 		if (!others_set->items[i].skb) {
@@ -1676,6 +1677,13 @@ restart:
 			goto out_free;
 		}
 		skb_set_owner_w(others_set->items[i].skb, sk);
+
+		pkt_len = sk_filter(cur, others_set->items[i].skb);
+		if (pkt_len != 0) {
+			others_set->items[i].to_deliver = 0;
+			kfree_skb(others_set->items[i].skb);
+			continue;
+		}
 	}
 
 	for (i = 0 ; i < others_set->cnt ; i++) {
-- 
1.7.1
