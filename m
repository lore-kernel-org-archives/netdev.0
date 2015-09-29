From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 6/7] net: sctp: hook up LOCAL_SOCKET_IN netfilter chains
Date: Tue, 29 Sep 2015 13:12:19 +0200
Message-ID: <1443525140-13493-7-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Run the NF_INET_LOCAL_SOCKET_IN netfilter chain rules after the
destination socket for SCTP packets have been looked up.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/sctp/input.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index b6493b3..0652406 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -45,6 +45,7 @@
 #include <linux/list.h> /* For struct list_head */
 #include <linux/socket.h>
 #include <linux/ip.h>
+#include <linux/netfilter.h>
 #include <linux/time.h> /* For struct timeval */
 #include <linux/slab.h>
 #include <net/ip.h>
@@ -115,7 +116,7 @@ int sctp_rcv(struct sk_buff *skb)
 	struct sctphdr *sh;
 	union sctp_addr src;
 	union sctp_addr dest;
-	int family;
+	int ret, family;
 	struct sctp_af *af;
 	struct net *net = dev_net(skb->dev);
 
@@ -180,6 +181,14 @@ int sctp_rcv(struct sk_buff *skb)
 	rcvr = asoc ? &asoc->base : &ep->base;
 	sk = rcvr->sk;
 
+	/* Iterate through rules in LOCAL_SOCKET_IN,
+	 * now that the receiver is known.
+	 */
+	ret = nf_hook(family == AF_INET ? NFPROTO_IPV4 : NFPROTO_IPV6,
+		      NF_INET_LOCAL_SOCKET_IN, sk, skb, skb->dev, NULL, NULL);
+	if (ret != 1)
+		goto discard_release;
+
 	/*
 	 * If a frame arrives on an interface and the receiving socket is
 	 * bound to another interface, via SO_BINDTODEVICE, treat it as OOTB
-- 
2.5.0

