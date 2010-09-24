From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash() dependency on destination address
Date: Fri, 24 Sep 2010 21:21:26 +0200
Message-ID: <874odfrlqh.fsf@small.ssi.corp>
References: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:40710 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757643Ab0IXTU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 15:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the new IPsec architecture [RFC4301], "for an SA used to carry
unicast traffic, the Security Parameters Index (SPI) by itself
suffices to specify an SA".  Section 4.1 of [RFC4301] provides
additional guidance on the topic.

In the old IPsec architecture [RFC2401], a SA "is uniquely identified
by a triple consisting of a Security Parameter Index (SPI), an IP
Destination Address and a security protocol (AH or ESP) identifier".

If an IPsec stack only supports the behavior mandated by the old
IPsec architecture, SAD lookup on inbound packets require the use of
both the SPI and the destination address of the SA.

For inbound IPsec traffic, IRO remapping rules may exist on the MN to
remap the destination address (CoA) into the HoA.  In that case, by
design, the address found in the destination address field of the
packet (CoA) does not match the one in the SA (HoA).

At the moment, Linux XFRM stack includes the address when computing
the hash to perform state lookup by SPI. This patch changes XFRM
state hash computation to prevent destination address to be
used. This will later allow finding states for packets w/ mangled
destination addresses.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 net/xfrm/xfrm_hash.h  |   21 +--------------------
 net/xfrm/xfrm_state.c |   20 ++++++++------------
 2 files changed, 9 insertions(+), 32 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 8e69533..19eeee7 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -4,16 +4,6 @@
 #include <linux/xfrm.h>
 #include <linux/socket.h>
 
-static inline unsigned int __xfrm4_addr_hash(xfrm_address_t *addr)
-{
-	return ntohl(addr->a4);
-}
-
-static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
-{
-	return ntohl(addr->a6[2] ^ addr->a6[3]);
-}
-
 static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
 	u32 sum = (__force u32)daddr->a4 + (__force u32)saddr->a4;
@@ -60,18 +50,9 @@ static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
 }
 
 static inline unsigned int
-__xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family,
-		unsigned int hmask)
+__xfrm_spi_hash(__be32 spi, u8 proto, unsigned int hmask)
 {
 	unsigned int h = (__force u32)spi ^ proto;
-	switch (family) {
-	case AF_INET:
-		h ^= __xfrm4_addr_hash(daddr);
-		break;
-	case AF_INET6:
-		h ^= __xfrm6_addr_hash(daddr);
-		break;
-	}
 	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
 }
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5208b12..7ad4462 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -30,7 +30,7 @@
 
 /* Each xfrm_state may be linked to two tables:
 
-   1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
+   1. Hash table by (spi,ah/esp) to find SA by SPI. (input,ctl)
    2. Hash table by (daddr,family,reqid) to find what SAs exist for given
       destination/tunnel endpoint. (output)
  */
@@ -67,9 +67,9 @@ static inline unsigned int xfrm_src_hash(struct net *net,
 }
 
 static inline unsigned int
-xfrm_spi_hash(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+xfrm_spi_hash(struct net *net, __be32 spi, u8 proto)
 {
-	return __xfrm_spi_hash(daddr, spi, proto, family, net->xfrm.state_hmask);
+	return __xfrm_spi_hash(spi, proto, net->xfrm.state_hmask);
 }
 
 static void xfrm_hash_transfer(struct hlist_head *list,
@@ -95,9 +95,7 @@ static void xfrm_hash_transfer(struct hlist_head *list,
 		hlist_add_head(&x->bysrc, nsrctable+h);
 
 		if (x->id.spi) {
-			h = __xfrm_spi_hash(&x->id.daddr, x->id.spi,
-					    x->id.proto, x->props.family,
-					    nhashmask);
+			h = __xfrm_spi_hash(x->id.spi, x->id.proto, nhashmask);
 			hlist_add_head(&x->byspi, nspitable+h);
 		}
 	}
@@ -671,7 +669,7 @@ xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 
 static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_spi_hash(net, daddr, spi, proto, family);
+	unsigned int h = xfrm_spi_hash(net, spi, proto);
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
@@ -859,7 +857,7 @@ found:
 			h = xfrm_src_hash(net, daddr, saddr, family);
 			hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 			if (x->id.spi) {
-				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, family);
+				h = xfrm_spi_hash(net, x->id.spi, x->id.proto);
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
@@ -933,9 +931,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 
 	if (x->id.spi) {
-		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto,
-				  x->props.family);
-
+		h = xfrm_spi_hash(net, x->id.spi, x->id.proto);
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 	}
 
@@ -1526,7 +1522,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	}
 	if (x->id.spi) {
 		spin_lock_bh(&xfrm_state_lock);
-		h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, x->props.family);
+		h = xfrm_spi_hash(net, x->id.spi, x->id.proto);
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 		spin_unlock_bh(&xfrm_state_lock);
 
-- 
1.7.1


