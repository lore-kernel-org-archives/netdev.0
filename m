From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 2/4] net: export announce_self_create()
Date: Sat, 22 Oct 2011 13:38:47 +0800
Message-ID: <20111022053847.21526.77472.stgit@dhcp-8-146.nay.redhat.com>
References: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export and move announce_self_create() to net.c in order to be used by model
specific announcing function.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net.c    |   31 +++++++++++++++++++++++++++++++
 net.h    |    1 +
 savevm.c |   32 --------------------------------
 3 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/net.c b/net.c
index d05930c..516ff9e 100644
--- a/net.c
+++ b/net.c
@@ -42,6 +42,37 @@ static QTAILQ_HEAD(, VLANClientState) non_vlan_clients;
 
 int default_net = 1;
 
+#ifndef ETH_P_RARP
+#define ETH_P_RARP 0x8035
+#endif
+#define ARP_HTYPE_ETH 0x0001
+#define ARP_PTYPE_IP 0x0800
+#define ARP_OP_REQUEST_REV 0x3
+
+int announce_self_create(uint8_t *buf, uint8_t *mac_addr)
+{
+    /* Ethernet header. */
+    memset(buf, 0xff, 6);         /* destination MAC addr */
+    memcpy(buf + 6, mac_addr, 6); /* source MAC addr */
+    *(uint16_t *)(buf + 12) = htons(ETH_P_RARP); /* ethertype */
+
+    /* RARP header. */
+    *(uint16_t *)(buf + 14) = htons(ARP_HTYPE_ETH); /* hardware addr space */
+    *(uint16_t *)(buf + 16) = htons(ARP_PTYPE_IP); /* protocol addr space */
+    *(buf + 18) = 6; /* hardware addr length (ethernet) */
+    *(buf + 19) = 4; /* protocol addr length (IPv4) */
+    *(uint16_t *)(buf + 20) = htons(ARP_OP_REQUEST_REV); /* opcode */
+    memcpy(buf + 22, mac_addr, 6); /* source hw addr */
+    memset(buf + 28, 0x00, 4);     /* source protocol addr */
+    memcpy(buf + 32, mac_addr, 6); /* target hw addr */
+    memset(buf + 38, 0x00, 4);     /* target protocol addr */
+
+    /* Padding to get up to 60 bytes (ethernet min packet size, minus FCS). */
+    memset(buf + 42, 0x00, 18);
+
+    return 60; /* len (FCS will be added by hardware) */
+}
+
 /***********************************************************/
 /* network device redirectors */
 
diff --git a/net.h b/net.h
index 9f633f8..4943d4b 100644
--- a/net.h
+++ b/net.h
@@ -178,5 +178,6 @@ int do_netdev_del(Monitor *mon, const QDict *qdict, QObject **ret_data);
 void qdev_set_nic_properties(DeviceState *dev, NICInfo *nd);
 
 int net_handle_fd_param(Monitor *mon, const char *param);
+int announce_self_create(uint8_t *buf, uint8_t *mac_addr);
 
 #endif
diff --git a/savevm.c b/savevm.c
index bf4d0e7..8293ee6 100644
--- a/savevm.c
+++ b/savevm.c
@@ -85,38 +85,6 @@
 
 #define SELF_ANNOUNCE_ROUNDS 5
 
-#ifndef ETH_P_RARP
-#define ETH_P_RARP 0x8035
-#endif
-#define ARP_HTYPE_ETH 0x0001
-#define ARP_PTYPE_IP 0x0800
-#define ARP_OP_REQUEST_REV 0x3
-
-static int announce_self_create(uint8_t *buf,
-				uint8_t *mac_addr)
-{
-    /* Ethernet header. */
-    memset(buf, 0xff, 6);         /* destination MAC addr */
-    memcpy(buf + 6, mac_addr, 6); /* source MAC addr */
-    *(uint16_t *)(buf + 12) = htons(ETH_P_RARP); /* ethertype */
-
-    /* RARP header. */
-    *(uint16_t *)(buf + 14) = htons(ARP_HTYPE_ETH); /* hardware addr space */
-    *(uint16_t *)(buf + 16) = htons(ARP_PTYPE_IP); /* protocol addr space */
-    *(buf + 18) = 6; /* hardware addr length (ethernet) */
-    *(buf + 19) = 4; /* protocol addr length (IPv4) */
-    *(uint16_t *)(buf + 20) = htons(ARP_OP_REQUEST_REV); /* opcode */
-    memcpy(buf + 22, mac_addr, 6); /* source hw addr */
-    memset(buf + 28, 0x00, 4);     /* source protocol addr */
-    memcpy(buf + 32, mac_addr, 6); /* target hw addr */
-    memset(buf + 38, 0x00, 4);     /* target protocol addr */
-
-    /* Padding to get up to 60 bytes (ethernet min packet size, minus FCS). */
-    memset(buf + 42, 0x00, 18);
-
-    return 60; /* len (FCS will be added by hardware) */
-}
-
 static void qemu_announce_self_iter(NICState *nic, void *opaque)
 {
     uint8_t buf[60];

