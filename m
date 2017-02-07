From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 1/2] net: introduce device min_header_len
Date: Tue,  7 Feb 2017 15:57:20 -0500
Message-ID: <20170207205721.23207-2-willemdebruijn.kernel@gmail.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36161 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754721AbdBGU51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:57:27 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so20671948qth.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:57:26 -0800 (PST)
In-Reply-To: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The stack must not pass packets to device drivers that are shorter
than the minimum link layer header length.

Previously, packet sockets would drop packets smaller than or equal
to dev->hard_header_len, but this has false positives. Zero length
payload is used over Ethernet. Other link layer protocols support
variable length headers. Support for validation of these protocols
removed the min length check for all protocols.

Introduce an explicit dev->min_header_len parameter and drop all
packets below this value. Initially, set it to non-zero only for
Ethernet and loopback. Other protocols can follow in a patch to
net-next.

Fixes: 9ed988cd5915 ("packet: validate variable length ll headers")
Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/loopback.c    | 1 +
 include/linux/netdevice.h | 4 ++++
 net/ethernet/eth.c        | 1 +
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 1e05b7c2d157..0844f8496413 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -164,6 +164,7 @@ static void loopback_setup(struct net_device *dev)
 {
 	dev->mtu		= 64 * 1024;
 	dev->hard_header_len	= ETH_HLEN;	/* 14	*/
+	dev->min_header_len	= ETH_HLEN;	/* 14	*/
 	dev->addr_len		= ETH_ALEN;	/* 6	*/
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 70ad0291d517..27914672602d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1511,6 +1511,7 @@ enum netdev_priv_flags {
  *	@max_mtu:	Interface Maximum MTU value
  *	@type:		Interface hardware type
  *	@hard_header_len: Maximum hardware header length.
+ *	@min_header_len:  Minimum hardware header length
  *
  *	@needed_headroom: Extra headroom the hardware may need, but not in all
  *			  cases can this be guaranteed
@@ -1728,6 +1729,7 @@ struct net_device {
 	unsigned int		max_mtu;
 	unsigned short		type;
 	unsigned short		hard_header_len;
+	unsigned short		min_header_len;
 
 	unsigned short		needed_headroom;
 	unsigned short		needed_tailroom;
@@ -2694,6 +2696,8 @@ static inline bool dev_validate_header(const struct net_device *dev,
 {
 	if (likely(len >= dev->hard_header_len))
 		return true;
+	if (len < dev->min_header_len)
+		return false;
 
 	if (capable(CAP_SYS_RAWIO)) {
 		memset(ll_header + len, 0, dev->hard_header_len - len);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8c5a479681ca..516c87e75de7 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -356,6 +356,7 @@ void ether_setup(struct net_device *dev)
 	dev->header_ops		= &eth_header_ops;
 	dev->type		= ARPHRD_ETHER;
 	dev->hard_header_len 	= ETH_HLEN;
+	dev->min_header_len	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
 	dev->min_mtu		= ETH_MIN_MTU;
 	dev->max_mtu		= ETH_DATA_LEN;
-- 
2.11.0.483.g087da7b7c-goog
