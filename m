From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 4/8] mv88e6xxx: Combine mv88e6131 and
 mv88e612_61_65 drivers
Date: Sat, 26 Nov 2011 00:36:19 +0000
Message-ID: <1322267779.2839.385.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34286 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab1KZAg0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:36:26 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These drivers share a lot of code, so if we make them modular they
should be built into the same module.  Therefore, link them together
and merge their respective module init and exit functions.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dsa/Makefile          |    7 ++++---
 net/dsa/mv88e6123_61_65.c |   15 +--------------
 net/dsa/mv88e6131.c       |   15 +--------------
 net/dsa/mv88e6xxx.c       |   23 +++++++++++++++++++++++
 net/dsa/mv88e6xxx.h       |    3 +++
 5 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 5431b4a..5c48ac5 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -8,7 +8,8 @@ dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
 
 # switch drivers
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
-obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
+mv88e6xxx_drv-y += mv88e6xxx.o
+mv88e6xxx_drv-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
+mv88e6xxx_drv-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 52faaa2..7951a6c 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -419,7 +419,7 @@ static int mv88e6123_61_65_get_sset_count(struct dsa_switch *ds)
 	return ARRAY_SIZE(mv88e6123_61_65_hw_stats);
 }
 
-static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
+struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.tag_protocol		= cpu_to_be16(ETH_P_EDSA),
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_61_65_probe,
@@ -432,16 +432,3 @@ static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
 };
-
-static int __init mv88e6123_61_65_init(void)
-{
-	register_switch_driver(&mv88e6123_61_65_switch_driver);
-	return 0;
-}
-module_init(mv88e6123_61_65_init);
-
-static void __exit mv88e6123_61_65_cleanup(void)
-{
-	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
-}
-module_exit(mv88e6123_61_65_cleanup);
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 9bd1061..45f4123 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -415,7 +415,7 @@ static int mv88e6131_get_sset_count(struct dsa_switch *ds)
 	return ARRAY_SIZE(mv88e6131_hw_stats);
 }
 
-static struct dsa_switch_driver mv88e6131_switch_driver = {
+struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= cpu_to_be16(ETH_P_DSA),
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
@@ -428,16 +428,3 @@ static struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
 	.get_sset_count		= mv88e6131_get_sset_count,
 };
-
-static int __init mv88e6131_init(void)
-{
-	register_switch_driver(&mv88e6131_switch_driver);
-	return 0;
-}
-module_init(mv88e6131_init);
-
-static void __exit mv88e6131_cleanup(void)
-{
-	unregister_switch_driver(&mv88e6131_switch_driver);
-}
-module_exit(mv88e6131_cleanup);
diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index efe661a..50fd860 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -520,3 +520,26 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 
 	mutex_unlock(&ps->stats_mutex);
 }
+
+static int __init mv88e6xxx_init(void)
+{
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
+	register_switch_driver(&mv88e6131_switch_driver);
+#endif
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
+	register_switch_driver(&mv88e6123_61_65_switch_driver);
+#endif
+	return 0;
+}
+module_init(mv88e6xxx_init);
+
+static void __exit mv88e6xxx_cleanup(void)
+{
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
+	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
+#endif
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
+	unregister_switch_driver(&mv88e6131_switch_driver);
+#endif
+}
+module_exit(mv88e6xxx_cleanup);
diff --git a/net/dsa/mv88e6xxx.h b/net/dsa/mv88e6xxx.h
index 61156ca2..fc2cd7b 100644
--- a/net/dsa/mv88e6xxx.h
+++ b/net/dsa/mv88e6xxx.h
@@ -71,6 +71,9 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 				 int nr_stats, struct mv88e6xxx_hw_stat *stats,
 				 int port, uint64_t *data);
 
+extern struct dsa_switch_driver mv88e6131_switch_driver;
+extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
+
 #define REG_READ(addr, reg)						\
 	({								\
 		int __ret;						\
-- 
1.7.7.3
