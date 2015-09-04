From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net] openvswitch: Remove conntrack Kconfig option.
Date: Fri,  4 Sep 2015 13:07:40 -0700
Message-ID: <1441397260-61272-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no particular desire to have conntrack action support in Open
vSwitch as an independently configurable bit, rather just to ensure
there is not a hard dependency. This exposed option doesn't accurately
reflect the conntrack dependency when enabled, so simplify this by
removing the option. Compile the support if NF_CONNTRACK is enabled.

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/Kconfig     | 12 +-----------
 net/openvswitch/Makefile    |  4 +++-
 net/openvswitch/conntrack.h |  4 ++--
 3 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index af7cdef..2a071f4 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -5,6 +5,7 @@
 config OPENVSWITCH
 	tristate "Open vSwitch"
 	depends on INET
+	depends on (!NF_CONNTRACK || NF_CONNTRACK)
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
@@ -31,17 +32,6 @@ config OPENVSWITCH
 
 	  If unsure, say N.
 
-config OPENVSWITCH_CONNTRACK
-	bool "Open vSwitch conntrack action support"
-	depends on OPENVSWITCH
-	depends on NF_CONNTRACK
-	default OPENVSWITCH
-	---help---
-	  If you say Y here, then Open vSwitch module will be able to pass
-	  packets through conntrack.
-
-	  Say N to exclude this support and reduce the binary size.
-
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 5b5913b..60f8090 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,7 +15,9 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
-openvswitch-$(CONFIG_OPENVSWITCH_CONNTRACK) += conntrack.o
+ifneq ($(CONFIG_NF_CONNTRACK),)
+openvswitch-y += conntrack.o
+endif
 
 obj-$(CONFIG_OPENVSWITCH_VXLAN)+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 3cb3066..43f5dd7 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -19,7 +19,7 @@
 struct ovs_conntrack_info;
 enum ovs_key_attr;
 
-#if defined(CONFIG_OPENVSWITCH_CONNTRACK)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 void ovs_ct_init(struct net *);
 void ovs_ct_exit(struct net *);
 bool ovs_ct_verify(struct net *, enum ovs_key_attr attr);
@@ -82,5 +82,5 @@ static inline int ovs_ct_put_key(const struct sw_flow_key *key,
 }
 
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
-#endif
+#endif /* CONFIG_NF_CONNTRACK */
 #endif /* ovs_conntrack.h */
-- 
2.1.4
