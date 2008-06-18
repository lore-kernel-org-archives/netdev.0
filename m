From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other
 interfaces
Date: Wed, 18 Jun 2008 23:36:07 +0900 (JST)
Message-ID: <20080618.233607.20745708.yoshfuji@linux-ipv6.org>
References: <20080618132312.GA25004@pingi.kke.suse.de>
	<20080618.223600.81071656.yoshfuji@linux-ipv6.org>
	<20080618140558.GB25004@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mironov_Sergey@emc.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	yoshfuji@linux-ipv6.org
To: kkeil@suse.de, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59882 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbYFROfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 10:35:18 -0400
In-Reply-To: <20080618140558.GB25004@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080618140558.GB25004@pingi.kke.suse.de> (at Wed, 18 Jun 2008 16:05:58 +0200), Karsten Keil <kkeil@suse.de> says:

> On Wed, Jun 18, 2008 at 10:36:00PM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <20080618132312.GA25004@pingi.kke.suse.de> (at Wed, 18 Jun 2008 15:23:12 +0200), Karsten Keil <kkeil@suse.de> says:
> > 
> > > RFC 4291 forbit the use of the loopback address as source outside a node
> > > (paragraph 2.5.3).
> > > 
> > > The latest TAHI test release 4.0.1 does have a check for this (ICMPv6 test
> > > v6LC.5.1.2 Part F), so it fails currently on Linux.
> > > 
> > > Signed-off-by: Sergey Mironov <Mironov_Sergey@emc.com>
> > > Signed-off-by: Karsten Keil <kkeil@suse.de>
> > 
> > I disagree this approach - too ad-hoc fix just to pass the tests.
> > 
> 
> So you would prefer a more general test in some common place (like
> __ip6_local_out() ) to avoid any packets with ::1 on other devices as
> loopback ?

No, we should not even accept packets for ::1 from outside of the box.
Something like this.

---
ipv6: Drop packets for loopback address from outside of the box.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
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
 


--yoshfuji
