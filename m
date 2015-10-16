From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net RESEND 2/2] ipv6: protect mtu calculation of wrap-around and infinite loop by rounding issues
Date: Fri, 16 Oct 2015 11:32:43 +0200
Message-ID: <1444987963-15327-3-git-send-email-hannes@stressinduktion.org>
References: <1444987963-15327-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, dvyukov@google.com, davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444987963-15327-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Raw sockets with hdrincl enabled can insert ipv6 extension headers
right into the data stream. In case we need to fragment those packets,
we reparse the options header to find the place where we can insert
the fragment header. If the extension headers exceed the link's MTU we
actually cannot make progress in such a case.

Instead of ending up in broken arithmetic or rounding towards 0 and
entering an endless loop in ip6_fragment, just prevent those cases by
aborting early and signal -EMSGSIZE to user space.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 61d403e..00aa538 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -28,6 +28,7 @@
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
+#include <linux/overflow-arith.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/net.h>
@@ -584,7 +585,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 		if (np->frag_size)
 			mtu = np->frag_size;
 	}
-	mtu -= hlen + sizeof(struct frag_hdr);
+
+	if (overflow_usub(mtu, hlen + sizeof(struct frag_hdr), &mtu) ||
+	    mtu <= 7)
+		goto fail_toobig;
 
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
 				    &ipv6_hdr(skb)->saddr);
-- 
2.4.3
