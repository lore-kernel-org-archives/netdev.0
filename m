From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH net v2] mld, igmp: Fix reserved tailroom calculation
Date: Mon, 29 Feb 2016 15:03:33 -0800
Message-ID: <1456787013-3277-1-git-send-email-bpoirier@suse.com>
References: <56D48DCE.3090705@stressinduktion.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36302 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbcB2XDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 18:03:53 -0500
In-Reply-To: <56D48DCE.3090705@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current reserved_tailroom calculation fails to take hlen and tlen into
account.

skb:
[__hlen__|__data____________|__tlen___|__extra__]
^                                               ^
head                                            skb_end_offset

In this representation, hlen + data + tlen is the size passed to alloc_skb.
"extra" is the extra space made available in __alloc_skb because of
rounding up by kmalloc. We can reorder the representation like so:

[__hlen__|__data____________|__extra__|__tlen___]
^                                               ^
head                                            skb_end_offset

The maximum space available for ip headers and payload without
fragmentation is min(mtu, data + extra). Therefore,
reserved_tailroom
= data + extra + tlen - min(mtu, data + extra)
= skb_end_offset - hlen - min(mtu, skb_end_offset - hlen - tlen)
= skb_tailroom - min(mtu, skb_tailroom - tlen) ; after skb_reserve(hlen)

Compare the second line to the current expression:
reserved_tailroom = skb_end_offset - min(mtu, skb_end_offset)
and we can see that hlen and tlen are not taken into account.

The min() in the third line can be expanded into:
if mtu < skb_tailroom - tlen:
	reserved_tailroom = skb_tailroom - mtu
else:
	reserved_tailroom = tlen

Depending on hlen, tlen, mtu and the number of multicast address records,
the current code may output skbs that have less tailroom than
dev->needed_tailroom or it may output more skbs than needed because not all
space available is used.

Fixes: 4c672e4b ("ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs")
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---

Notes:
    Changes v1->v2
    As suggested by Hannes, move the code to an inline helper and express it
    using "if" rather than "min".

 include/linux/skbuff.h | 24 ++++++++++++++++++++++++
 net/ipv4/igmp.c        |  3 +--
 net/ipv6/mcast.c       |  3 +--
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ce9ff7..d3fcd45 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1985,6 +1985,30 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 	skb->tail += len;
 }
 
+/**
+ *	skb_tailroom_reserve - adjust reserved_tailroom
+ *	@skb: buffer to alter
+ *	@mtu: maximum amount of headlen permitted
+ *	@needed_tailroom: minimum amount of reserved_tailroom
+ *
+ *	Set reserved_tailroom so that headlen can be as large as possible but
+ *	not larger than mtu and tailroom cannot be smaller than
+ *	needed_tailroom.
+ *	The required headroom should already have been reserved before using
+ *	this function.
+ */
+static inline void skb_tailroom_reserve(struct sk_buff *skb, unsigned int mtu,
+					unsigned int needed_tailroom)
+{
+	SKB_LINEAR_ASSERT(skb);
+	if (mtu < skb_tailroom(skb) - needed_tailroom)
+		/* use at most mtu */
+		skb->reserved_tailroom = skb_tailroom(skb) - mtu;
+	else
+		/* use up to all available space */
+		skb->reserved_tailroom = needed_tailroom;
+}
+
 #define ENCAP_TYPE_ETHER	0
 #define ENCAP_TYPE_IPPROTO	1
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 05e4cba..b3086cf 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -356,9 +356,8 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, unsigned int mtu)
 	skb_dst_set(skb, &rt->dst);
 	skb->dev = dev;
 
-	skb->reserved_tailroom = skb_end_offset(skb) -
-				 min(mtu, skb_end_offset(skb));
 	skb_reserve(skb, hlen);
+	skb_tailroom_reserve(skb, mtu, tlen);
 
 	skb_reset_network_header(skb);
 	pip = ip_hdr(skb);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5ee56d0..d64ee7e 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1574,9 +1574,8 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
 		return NULL;
 
 	skb->priority = TC_PRIO_CONTROL;
-	skb->reserved_tailroom = skb_end_offset(skb) -
-				 min(mtu, skb_end_offset(skb));
 	skb_reserve(skb, hlen);
+	skb_tailroom_reserve(skb, mtu, tlen);
 
 	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
-- 
2.7.0
