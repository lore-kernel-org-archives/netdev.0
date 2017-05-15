From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH] arp: honour gratuitous ARP _replies_
Date: Mon, 15 May 2017 14:16:16 -0700
Message-ID: <20170515211616.26077-1-ihrachys@redhat.com>
References: <20170515.140832.354922796595622860.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Ihar Hrachyshka <ihrachys@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754546AbdEOVQf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 17:16:35 -0400
In-Reply-To: <20170515.140832.354922796595622860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When arp_accept is 1, gratuitous ARPs are supposed to override matching
entries irrespective of whether they arrive during locktime. This was
implemented in commit 56022a8fdd87 ("ipv4: arp: update neighbour address
when a gratuitous arp is received and arp_accept is set")

There is a glitch in the patch though. RFC 2002, section 4.6, "ARP,
Proxy ARP, and Gratuitous ARP", defines gratuitous ARPs so that they can
be either of Request or Reply type. Those Reply gratuitous ARPs can be
triggered with standard tooling, for example, arping -A option does just
that.

This patch fixes the glitch, making both Request and Reply flavours of
gratuitous ARPs to behave identically.

As per RFC, if gratuitous ARPs are of Reply type, their Target Hardware
Address field should also be set to the link-layer address to which this
cache entry should be updated. The field is present in ARP over Ethernet
but not in IEEE 1394. In this patch, I don't consider any broadcasted
ARP replies as gratuitous if the field is not present, to conform the
standard. It's not clear whether there is such a thing for IEEE 1394 as
a gratuitous ARP reply; until it's cleared up, we will ignore such
broadcasts. Note that they will still update existing ARP cache entries,
assuming they arrive out of locktime time interval.

Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 0937b34..d54345a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -653,6 +653,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	unsigned char *arp_ptr;
 	struct rtable *rt;
 	unsigned char *sha;
+	unsigned char *tha = NULL;
 	__be32 sip, tip;
 	u16 dev_type = dev->type;
 	int addr_type;
@@ -724,6 +725,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		break;
 #endif
 	default:
+		tha = arp_ptr;
 		arp_ptr += dev->addr_len;
 	}
 	memcpy(&tip, arp_ptr, 4);
@@ -842,8 +844,18 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
-			  addr_type == RTN_UNICAST;
+		is_garp = tip == sip && addr_type == RTN_UNICAST;
+
+		/* Unsolicited ARP _replies_ also require target hwaddr to be
+		 * the same as source.
+		 */
+		if (is_garp && arp->ar_op == htons(ARPOP_REPLY))
+			is_garp =
+				/* IPv4 over IEEE 1394 doesn't provide target
+				 * hardware address field in its ARP payload.
+				 */
+				tha &&
+				!memcmp(tha, sha, dev->addr_len);
 
 		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
-- 
2.9.3
