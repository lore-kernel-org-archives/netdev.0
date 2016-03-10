From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/3] net: validate variable length ll headers
Date: Wed,  9 Mar 2016 21:58:32 -0500
Message-ID: <1457578714-36125-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:36635 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934806AbcCJC6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:58:41 -0500
Received: by mail-qg0-f65.google.com with SMTP id 14so4402190qgg.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:58:40 -0800 (PST)
In-Reply-To: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Netdevice parameter hard_header_len is variously interpreted both as
an upper and lower bound on link layer header length. The field is
used as upper bound when reserving room at allocation, as lower bound
when validating user input in PF_PACKET.

Clarify the definition to be maximum header length. For validation
of untrusted headers, add an optional validate member to header_ops.

Allow bypassing of validation by passing CAP_SYS_RAWIO, for instance
for deliberate testing of corrupt input. In this case, pad trailing
bytes, as some device drivers expect completely initialized headers.

See also http://comments.gmane.org/gmane.linux.network/401064

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/netdevice.h | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index efe7cec..fd30cb5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -268,6 +268,7 @@ struct header_ops {
 	void	(*cache_update)(struct hh_cache *hh,
 				const struct net_device *dev,
 				const unsigned char *haddr);
+	bool	(*validate)(const char *ll_header, unsigned int len);
 };
 
 /* These flag bits are private to the generic network queueing
@@ -1459,8 +1460,7 @@ enum netdev_priv_flags {
  *	@dma:		DMA channel
  *	@mtu:		Interface MTU value
  *	@type:		Interface hardware type
- *	@hard_header_len: Hardware header length, which means that this is the
- *			  minimum size of a packet.
+ *	@hard_header_len: Maximum hardware header length.
  *
  *	@needed_headroom: Extra headroom the hardware may need, but not in all
  *			  cases can this be guaranteed
@@ -2687,6 +2687,24 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 	return dev->header_ops->parse(skb, haddr);
 }
 
+/* ll_header must have at least hard_header_len allocated */
+static inline bool dev_validate_header(const struct net_device *dev,
+				       char *ll_header, int len)
+{
+	if (likely(len >= dev->hard_header_len))
+		return true;
+
+	if (capable(CAP_SYS_RAWIO)) {
+		memset(ll_header + len, 0, dev->hard_header_len - len);
+		return true;
+	}
+
+	if (dev->header_ops && dev->header_ops->validate)
+		return dev->header_ops->validate(ll_header, len);
+
+	return false;
+}
+
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
 static inline int unregister_gifconf(unsigned int family)
-- 
2.7.0.rc3.207.g0ac5344
