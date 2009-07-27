From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific members
Date: Mon, 27 Jul 2009 18:09:08 +0300
Message-ID: <4A6DC314.2010303@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13487 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750735AbZG0PJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 11:09:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some members of net_device are used only by some protocols.

If those protocols are not compiled (as modules or linked in) they
should not take up space in the structure.

These members are also used in inline functions defined in headers not
protected by the protocol-specific CONFIG_ guards. Adding #ifdef CONFIG_*
guards header wide is against the current style and more invasive than
guarding only the definitions.

This patch includes a fix for an error spotted by Eric Dumazet
<eric.dumazet@gmail.com> regarding mishandlement of modules in a
previous version of the patch.

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 include/linux/inetdevice.h |    2 ++
 include/linux/netdevice.h  |   14 ++++++++++++++
 include/net/ax25.h         |    2 ++
 net/core/dev.c             |    6 ++++++
 4 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index acef2a7..88132ff 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -166,6 +166,7 @@ static __inline__ int bad_mask(__be32 mask, __be32 addr)

 #define endfor_ifa(in_dev) }

+#ifdef CONFIG_INET
 static inline struct in_device *__in_dev_get_rcu(const struct
net_device *dev)
 {
 	struct in_device *in_dev = dev->ip_ptr;
@@ -192,6 +193,7 @@ __in_dev_get_rtnl(const struct net_device *dev)
 {
 	return (struct in_device*)dev->ip_ptr;
 }
+#endif /* CONFIG_INET */

 extern void in_dev_finish_destroy(struct in_device *idev);

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8a17b6c..465c3de 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -762,14 +762,28 @@ struct net_device
 #ifdef CONFIG_NET_DSA
 	void			*dsa_ptr;	/* dsa specific data */
 #endif
+#if defined(CONFIG_ATALK) || defined(CONFIG_ATALK_MODULE)
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
+#endif
+#ifdef CONFIG_INET
 	void			*ip_ptr;	/* IPv4 specific data	*/
+#endif
+#if defined(CONFIG_DECNET) || defined(CONFIG_DECNET_MODULE)
 	void                    *dn_ptr;        /* DECnet specific data */
+#endif
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	void                    *ip6_ptr;       /* IPv6 specific data */
+#endif
+#if defined(CONFIG_ECONET) || defined(CONFIG_ECONET_MODULE)
 	void			*ec_ptr;	/* Econet specific data	*/
+#endif
+#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	void			*ax25_ptr;	/* AX.25 specific data */
+#endif
+#ifdef CONFIG_WIRELESS
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
+#endif

 /*
  * Cache line mostly used on receive path (including eth_type_trans())
diff --git a/include/net/ax25.h b/include/net/ax25.h
index 717e219..37f86ac 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -300,10 +300,12 @@ extern void ax25_digi_invert(const ax25_digi *,
ax25_digi *);
 extern ax25_dev *ax25_dev_list;
 extern spinlock_t ax25_dev_lock;

+#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 static inline ax25_dev *ax25_dev_ax25dev(struct net_device *dev)
 {
 	return dev->ax25_ptr;
 }
+#endif

 extern ax25_dev *ax25_addr_ax25dev(ax25_address *);
 extern void ax25_dev_device_up(struct net_device *);
diff --git a/net/core/dev.c b/net/core/dev.c
index e2e9e4a..d8e85ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4686,9 +4686,15 @@ void netdev_run_todo(void)

 		/* paranoia */
 		BUG_ON(atomic_read(&dev->refcnt));
+#ifdef CONFIG_INET
 		WARN_ON(dev->ip_ptr);
+#endif
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		WARN_ON(dev->ip6_ptr);
+#endif
+#if defined(CONFIG_DECNET) || defined(CONFIG_DECNET_MODULE)
 		WARN_ON(dev->dn_ptr);
+#endif

 		if (dev->destructor)
 			dev->destructor(dev);
-- 
1.6.3.3

