From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other
 interfaces
Date: Thu, 19 Jun 2008 16:34:26 -0700 (PDT)
Message-ID: <20080619.163426.169644219.davem@davemloft.net>
References: <20080618140558.GB25004@pingi.kke.suse.de>
	<20080618.233607.20745708.yoshfuji@linux-ipv6.org>
	<20080618174907.GA31937@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753624AbYFSXe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:34:27 -0400
In-Reply-To: <20080618174907.GA31937@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@suse.de>
Date: Wed, 18 Jun 2008 19:49:07 +0200

> Verified that this patch fix the TAHI issue and that ping6 ::1 still works.
> So this should go in.

I've added the patch to net-2.6, as below.  Thanks everyone!

ipv6: Drop packets for loopback address from outside of the box.

[ Based upon original report and patch by Karsten Keil.  Karsten
  has verified that this fixes the TAHI test case "ICMPv6 test
  v6LC.5.1.2 Part F". -DaveM ]

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ipv6.h   |    6 ++++++
 net/ipv6/ip6_input.c |    9 +++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e0a612b..f422f72 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -367,6 +367,12 @@ static inline int ipv6_addr_any(const struct in6_addr *a)
 		 a->s6_addr32[2] | a->s6_addr32[3] ) == 0); 
 }
 
+static inline int ipv6_addr_loopback(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] | a->s6_addr32[1] |
+		 a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0);
+}
+
 static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1] |
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 4e5c861..17eb48b 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -102,6 +102,15 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (hdr->version != 6)
 		goto err;
 
+	/*
+	 * RFC4291 2.5.3
+	 * A packet received on an interface with a destination address
+	 * of loopback must be dropped.
+	 */
+	if (!(dev->flags & IFF_LOOPBACK) &&
+	    ipv6_addr_loopback(&hdr->daddr))
+		goto err;
+
 	skb->transport_header = skb->network_header + sizeof(*hdr);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
-- 
1.5.6.rc3.21.g8c6b5

