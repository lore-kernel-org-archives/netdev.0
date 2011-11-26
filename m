From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/8] dsa: Combine core and tagging code
Date: Sat, 26 Nov 2011 00:35:02 +0000
Message-ID: <1322267702.2839.383.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34273 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754035Ab1KZAfJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:35:09 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These files have circular dependencies, so if we make DSA modular then
they must be built into the same module.  Therefore, link them
together and merge their respective module init and exit functions.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dsa/Makefile      |   13 +++++++------
 net/dsa/dsa.c         |   26 +++++++++++++++++++++++++-
 net/dsa/dsa_priv.h    |    3 +++
 net/dsa/tag_dsa.c     |   15 +--------------
 net/dsa/tag_edsa.c    |   15 +--------------
 net/dsa/tag_trailer.c |   15 +--------------
 6 files changed, 38 insertions(+), 49 deletions(-)

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 2374faf..5431b4a 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,13 +1,14 @@
+# the core
+obj-$(CONFIG_NET_DSA) += dsa_core.o
+dsa_core-y += dsa.o slave.o
+
 # tagging formats
-obj-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
-obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
-obj-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
+dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
+dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
+dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
 
 # switch drivers
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
 obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
-
-# the core
-obj-$(CONFIG_NET_DSA) += dsa.o slave.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fc93088..88e7c2f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -398,12 +398,36 @@ static struct platform_driver dsa_driver = {
 
 static int __init dsa_init_module(void)
 {
-	return platform_driver_register(&dsa_driver);
+	int rc;
+
+	rc = platform_driver_register(&dsa_driver);
+	if (rc)
+		return rc;
+
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	dev_add_pack(&dsa_packet_type);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+	dev_add_pack(&edsa_packet_type);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	dev_add_pack(&trailer_packet_type);
+#endif
+	return 0;
 }
 module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	dev_remove_pack(&trailer_packet_type);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+	dev_remove_pack(&edsa_packet_type);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	dev_remove_pack(&dsa_packet_type);
+#endif
 	platform_driver_unregister(&dsa_driver);
 }
 module_exit(dsa_cleanup_module);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index a45186cb..89a2eb4 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -137,12 +137,15 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds,
 
 /* tag_dsa.c */
 netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev);
+extern struct packet_type dsa_packet_type;
 
 /* tag_edsa.c */
 netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev);
+extern struct packet_type edsa_packet_type;
 
 /* tag_trailer.c */
 netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev);
+extern struct packet_type trailer_packet_type;
 

 #endif
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 98dfe80..cacce1e 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -186,20 +186,7 @@ out:
 	return 0;
 }
 
-static struct packet_type dsa_packet_type __read_mostly = {
+struct packet_type dsa_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_DSA),
 	.func	= dsa_rcv,
 };
-
-static int __init dsa_init_module(void)
-{
-	dev_add_pack(&dsa_packet_type);
-	return 0;
-}
-module_init(dsa_init_module);
-
-static void __exit dsa_cleanup_module(void)
-{
-	dev_remove_pack(&dsa_packet_type);
-}
-module_exit(dsa_cleanup_module);
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 6f38332..e70c43c 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -205,20 +205,7 @@ out:
 	return 0;
 }
 
-static struct packet_type edsa_packet_type __read_mostly = {
+struct packet_type edsa_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_EDSA),
 	.func	= edsa_rcv,
 };
-
-static int __init edsa_init_module(void)
-{
-	dev_add_pack(&edsa_packet_type);
-	return 0;
-}
-module_init(edsa_init_module);
-
-static void __exit edsa_cleanup_module(void)
-{
-	dev_remove_pack(&edsa_packet_type);
-}
-module_exit(edsa_cleanup_module);
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d6d7d0a..94bc260 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -114,20 +114,7 @@ out:
 	return 0;
 }
 
-static struct packet_type trailer_packet_type __read_mostly = {
+struct packet_type trailer_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_TRAILER),
 	.func	= trailer_rcv,
 };
-
-static int __init trailer_init_module(void)
-{
-	dev_add_pack(&trailer_packet_type);
-	return 0;
-}
-module_init(trailer_init_module);
-
-static void __exit trailer_cleanup_module(void)
-{
-	dev_remove_pack(&trailer_packet_type);
-}
-module_exit(trailer_cleanup_module);
-- 
1.7.7.3
