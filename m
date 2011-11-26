From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 6/8] dsa: Allow core and drivers to be built as
 modules
Date: Sat, 26 Nov 2011 00:38:38 +0000
Message-ID: <1322267918.2839.388.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34302 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab1KZAiq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:38:46 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the kconfig types to tristate and adjust the condition for
declaring net_device::dsa_ptr to allow for this.

Adjust the makefile so that if NET_DSA_MV88E6123_61_65=y and
NET_DSA_MV88E6131=m or vice versa then both drivers are built-in.  We
could leave these options as bool and make NET_DSA_MV88E6XXX a
user-selected option, but that would break existing configurations.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I've tested that the all-modules configuration works as far as building
and loading them, but no further.

Ben.

 include/linux/netdevice.h |    2 +-
 net/dsa/Kconfig           |   10 +++++-----
 net/dsa/Makefile          |    8 ++++++--
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 63721a6..87f7353 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1079,7 +1079,7 @@ struct net_device {
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	struct vlan_group __rcu	*vlgrp;		/* VLAN group */
 #endif
-#ifdef CONFIG_NET_DSA
+#if IS_ENABLED(CONFIG_NET_DSA)
 	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
 #endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index c53ded2..7e12303 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,5 +1,5 @@
 menuconfig NET_DSA
-	bool "Distributed Switch Architecture support"
+	tristate "Distributed Switch Architecture support"
 	default n
 	depends on EXPERIMENTAL && NETDEVICES && !S390
 	select PHYLIB
@@ -26,11 +26,11 @@ config NET_DSA_TAG_TRAILER
 
 # switch drivers
 config NET_DSA_MV88E6XXX
-	bool
+	tristate
 	default n
 
 config NET_DSA_MV88E6060
-	bool "Marvell 88E6060 ethernet switch chip support"
+	tristate "Marvell 88E6060 ethernet switch chip support"
 	select NET_DSA_TAG_TRAILER
 	---help---
 	  This enables support for the Marvell 88E6060 ethernet switch
@@ -41,7 +41,7 @@ config NET_DSA_MV88E6XXX_NEED_PPU
 	default n
 
 config NET_DSA_MV88E6131
-	bool "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
+	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
@@ -50,7 +50,7 @@ config NET_DSA_MV88E6131
 	  ethernet switch chips.
 
 config NET_DSA_MV88E6123_61_65
-	bool "Marvell 88E6123/6161/6165 ethernet switch chip support"
+	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 5c48ac5..191dd48 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -11,5 +11,9 @@ dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
 mv88e6xxx_drv-y += mv88e6xxx.o
-mv88e6xxx_drv-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
-mv88e6xxx_drv-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
+ifdef CONFIG_NET_DSA_MV88E6123_61_65
+mv88e6xxx_drv-y += mv88e6123_61_65.o
+endif
+ifdef CONFIG_NET_DSA_MV88E6131
+mv88e6xxx_drv-y += mv88e6131.o
+endif
-- 
1.7.7.3
