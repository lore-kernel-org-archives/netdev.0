From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 3/3] net: tcp_ipv4: re-run netfilter chains for marked skbs
Date: Wed, 16 Sep 2015 17:43:00 +0200
Message-ID: <1442418180-14322-4-git-send-email-daniel@zonque.org>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47604 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbbIPPu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 11:50:56 -0400
In-Reply-To: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an skb has been marked for later re-iteration through netfilter,
do that after __inet_lookup_skb() has been called. This allows packets
sent to unconnected sockets to be filtered reliably.

Note that this will never happen for subsequent packets in the same
stream, as skb->sk will be set due to early demux, and hence
skb->nf_postponed will remain 0.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/ipv4/tcp_ipv4.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93898e0..61e0cb4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -78,6 +78,7 @@
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
+#include <linux/netfilter.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -1594,6 +1595,15 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (unlikely(skb->nf_postponed)) {
+		ret = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_IN, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret != 1) {
+			sock_put(sk);
+			return 0;
+		}
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
-- 
2.5.0
