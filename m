From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next] packet: always ensure that we pass hard_header_len bytes in skb_headlen() to the driver
Date: Tue, 24 Jan 2017 08:11:49 -0800
Message-ID: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20787 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAXQMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:12:03 -0500
To: davem@davemloft.net, sowmini.varadhan@oracle.com
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The contract between the socket layer and the device is that there
will be at least enough bytes in the non-paged part of the skb to
cover a link layer header, and this is ensured by copying any
application provided L2 header into the skb->data and then invoking
dev_validate_header().

If the application has provided fewer than hard_header_len bytes,
dev_validate_header() will zero out the skb->data as needed. This is
acceptable for SOCK_DGRAM/PF_PACKET sockets but in all other cases,
the application must provide a full L2 header, and the PF_PACKET Tx
paths must fail with an error when fewer than hard_header_len bytes
are detected.

All invocations to dev_validate_header() already adjusts the
skb's data, len, tail etc pointers based on hard_header_len before
invoking dev_validate_header(), so additional skb pointers should
not be needed after dev_validate_header().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/linux/netdevice.h |   11 ++++++-----
 net/packet/af_packet.c    |   27 +++++++++++++++++++++------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3868c32..9d49898 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2685,21 +2685,22 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 }
 
 /* ll_header must have at least hard_header_len allocated */
-static inline bool dev_validate_header(const struct net_device *dev,
+static inline int dev_validate_header(const struct net_device *dev,
 				       char *ll_header, int len)
 {
 	if (likely(len >= dev->hard_header_len))
-		return true;
+		return len;
 
 	if (capable(CAP_SYS_RAWIO)) {
 		memset(ll_header + len, 0, dev->hard_header_len - len);
-		return true;
+		return dev->hard_header_len;
 	}
 
 	if (dev->header_ops && dev->header_ops->validate)
-		return dev->header_ops->validate(ll_header, len);
+		if (!dev->header_ops->validate(ll_header, len))
+			return -1;
 
-	return false;
+	return dev->hard_header_len;
 }
 
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ddbda25..7af09a3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1845,6 +1845,7 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 	__be16 proto = 0;
 	int err;
 	int extra_len = 0;
+	int newlen;
 
 	/*
 	 *	Get and verify the address.
@@ -1920,7 +1921,11 @@ static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
 		goto retry;
 	}
 
-	if (!dev_validate_header(dev, skb->data, len)) {
+	newlen = dev_validate_header(dev, skb->data, len);
+	/* As comments above this function indicate, a full L2 header
+	 * must be passed to this function, so if newlen > len, bail.
+	 */
+	if (newlen < 0 || newlen > len) {
 		err = -EINVAL;
 		goto out_unlock;
 	}
@@ -2447,14 +2452,21 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 			return -EINVAL;
 	} else if (copylen) {
 		int hdrlen = min_t(int, copylen, tp_len);
+		int newlen;
 
 		skb_push(skb, dev->hard_header_len);
 		skb_put(skb, copylen - dev->hard_header_len);
 		err = skb_store_bits(skb, 0, data, hdrlen);
 		if (unlikely(err))
 			return err;
-		if (!dev_validate_header(dev, skb->data, hdrlen))
+		newlen = dev_validate_header(dev, skb->data, hdrlen);
+		if (newlen < 0)
 			return -EINVAL;
+		/* Caller has allocated for copylen in non-paged part of
+		 * skb so we should never find newlen > hdrlen
+		 */
+		WARN_ON(newlen > hdrlen);
+
 		if (!skb->protocol)
 			tpacket_set_protocol(dev, skb);
 
@@ -2857,10 +2869,13 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (err)
 		goto out_free;
 
-	if (sock->type == SOCK_RAW &&
-	    !dev_validate_header(dev, skb->data, len)) {
-		err = -EINVAL;
-		goto out_free;
+	if (sock->type == SOCK_RAW) {
+		int newlen = dev_validate_header(dev, skb->data, len);
+
+		if (newlen < 0 || newlen > len) {
+			err = -EINVAL;
+			goto out_free;
+		}
 	}
 
 	sock_tx_timestamp(sk, sockc.tsflags, &skb_shinfo(skb)->tx_flags);
-- 
1.7.1
