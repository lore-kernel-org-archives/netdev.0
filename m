From: Thomas Graf <tgraf@redhat.com>
Subject: [PATCH openvswitch] linux: Signal datapath that unaligned Netlink message can be received
Date: Thu, 21 Nov 2013 19:15:27 +0100
Message-ID: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab3KUSPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 13:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following commit (''netlink: Do not enforce alignment of last Netlink
attribute''), signal the ability to receive unaligned Netlink messages
to the datapath to enable utilization of zerocopy optimizations.

Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
 include/linux/openvswitch.h | 15 ++++++++++++++-
 lib/dpif-linux.c            |  6 ++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index b429201..52dde86 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -60,7 +60,16 @@ struct ovs_header {
 
 #define OVS_DATAPATH_FAMILY  "ovs_datapath"
 #define OVS_DATAPATH_MCGROUP "ovs_datapath"
-#define OVS_DATAPATH_VERSION 0x1
+
+/**
+ * V2:
+ *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
+ *     with NLM_F_REPLACE when creating the datapath.
+ */
+#define OVS_DATAPATH_VERSION 2
+
+/* First OVS datapath version to support features */
+#define OVS_DP_VER_FEATURES 2
 
 enum ovs_datapath_cmd {
 	OVS_DP_CMD_UNSPEC,
@@ -95,6 +104,7 @@ enum ovs_datapath_attr {
 	OVS_DP_ATTR_UPCALL_PID,		/* Netlink PID to receive upcalls */
 	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
 	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
+	OVS_DP_ATTR_USER_FEATURES,	/* OVS_DP_F_*  */
 	__OVS_DP_ATTR_MAX
 };
 
@@ -126,6 +136,9 @@ struct ovs_vport_stats {
 	__u64   tx_dropped;		/* no space available in linux  */
 };
 
+/* Allow last Netlink attribute to be unaligned */
+#define OVS_DP_F_UNALIGNED (1 << 0)
+
 /* Fixed logical ports. */
 #define OVSP_LOCAL      ((__u32)0)
 
diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
index 1dcf321..5c952bc 100644
--- a/lib/dpif-linux.c
+++ b/lib/dpif-linux.c
@@ -73,6 +73,7 @@ struct dpif_linux_dp {
     /* Attributes. */
     const char *name;                  /* OVS_DP_ATTR_NAME. */
     const uint32_t *upcall_pid;        /* OVS_DP_ATTR_UPCALL_PID. */
+    uint32_t user_features;            /* OVS_DP_ATTR_USER_FEATURES */
     struct ovs_dp_stats stats;         /* OVS_DP_ATTR_STATS. */
     struct ovs_dp_megaflow_stats megaflow_stats;
                                        /* OVS_DP_ATTR_MEGAFLOW_STATS.*/
@@ -232,6 +233,7 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
         dp_request.cmd = OVS_DP_CMD_GET;
     }
     dp_request.name = name;
+    dp_request.user_features |= OVS_DP_F_UNALIGNED;
     error = dpif_linux_dp_transact(&dp_request, &dp, &buf);
     if (error) {
         return error;
@@ -1839,6 +1841,10 @@ dpif_linux_dp_to_ofpbuf(const struct dpif_linux_dp *dp, struct ofpbuf *buf)
         nl_msg_put_u32(buf, OVS_DP_ATTR_UPCALL_PID, *dp->upcall_pid);
     }
 
+    if (dp->user_features) {
+        nl_msg_put_u32(buf, OVS_DP_ATTR_USER_FEATURES, dp->user_features);
+    }
+
     /* Skip OVS_DP_ATTR_STATS since we never have a reason to serialize it. */
 }
 
-- 
1.8.3.1
