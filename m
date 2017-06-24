From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] net/icmp: restore source address if packet is NATed
Date: Sat, 24 Jun 2017 04:17:27 +0200
Message-ID: <20170624021727.17835-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:38189 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754336AbdFXCRn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 22:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ICMP routines use the source address for two reasons:

    1. Rate-limiting ICMP transmissions based on source address, so
       that one source address cannot provoke a flood of replies. If
       the source address is wrong, the rate limiting will be
       incorrectly applied.

    2. Choosing the interface and hence new source address of the
       generated ICMP packet. If the original packet source address
       is wrong, ICMP replies will be sent from the wrong source
       address, resulting in either a misdelivery, infoleak, or just
       general network admin confusion.

Most of the time, the icmp_send and icmpv6_send routines can just reach
down into the skb's IP header to determine the saddr. However, if
icmp_send or icmpv6_send is being called from a network device driver --
there are a few in the tree -- then it's possible that by the time
icmp_send or icmpv6_send looks at the packet, the packet's source
address has already been transformed by SNAT or MASQUERADE or some other
transformation that CONNTRACK knows about. In this case, the packet's
source address is most certainly the *wrong* source address to be used
for the purpose of ICMP replies.

Rather, the source address we want to use for ICMP replies is the
original one, from before the transformation occurred.

Fortunately, it's very easy to just ask CONNTRACK if it knows about this
packet, and if so, how to fix it up. The saddr is the only field in the
header we need to fix up, for the purposes of the subsequent processing
in the icmp_send and icmpv6_send functions, so we do the lookup very
early on, so that the rest of the ICMP machinery can progress as usual.
In my tests, this setup works very well.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/ipv4/icmp.c | 21 +++++++++++++++++++++
 net/ipv6/icmp.c | 21 +++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c2be26b98b5f..30aa6aa79fd2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -97,6 +97,10 @@
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
 #include <net/l3mdev.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat_core.h>
+#endif
 
 /*
  *	Build xmit assembly blocks
@@ -586,6 +590,10 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	u32 mark;
 	struct net *net;
 	struct sock *sk;
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+#endif
 
 	if (!rt)
 		goto out;
@@ -604,6 +612,19 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		goto out;
 
 	/*
+	 * 	If this function is called after the skb has already been
+	 * 	NAT transformed, the ratelimiting will apply to the wrong
+	 * 	saddr, and the reply will will be marked as coming from the
+	 * 	wrong host. So, we fix it up here in case connection tracking
+	 * 	enables that.
+	 */
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	ct = nf_ct_get(skb_in, &ctinfo);
+	if (ct)
+		iph->saddr = ct->tuplehash[0].tuple.src.u3.ip;
+#endif
+
+	/*
 	 *	No replies to physical multicast/broadcast
 	 */
 	if (skb_in->pkt_type != PACKET_HOST)
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 8d7b113958b1..ee8a2853121e 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -69,6 +69,10 @@
 #include <net/inet_common.h>
 #include <net/dsfield.h>
 #include <net/l3mdev.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat_core.h>
+#endif
 
 #include <linux/uaccess.h>
 
@@ -422,12 +426,29 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	int len;
 	int err = 0;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+#endif
 
 	if ((u8 *)hdr < skb->head ||
 	    (skb_network_header(skb) + sizeof(*hdr)) > skb_tail_pointer(skb))
 		return;
 
 	/*
+	 * 	If this function is called after the skb has already been
+	 * 	NAT transformed, the ratelimiting will apply to the wrong
+	 * 	saddr, and the reply will will be marked as coming from the
+	 * 	wrong host. So, we fix it up here in case connection tracking
+	 * 	enables that.
+	 */
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct)
+		hdr->saddr = ct->tuplehash[0].tuple.src.u3.in6;
+#endif
+
+	/*
 	 *	Make sure we respect the rules
 	 *	i.e. RFC 1885 2.4(e)
 	 *	Rule (e.1) is enforced by not using icmp6_send
-- 
2.13.1
