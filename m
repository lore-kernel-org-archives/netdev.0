From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 1/8] odp: select group action attributes
Date: Thu, 18 Sep 2014 10:55:04 +0900
Message-ID: <1411005311-11752-2-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:64789 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbaIRB5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:38 -0400
Received: by mail-pd0-f176.google.com with SMTP id g10so323852pdj.7
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:37 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the core of a proposed ODP select group action.
It models OpenFlow select groups without any extensions.

Further work:

We believe there is scope to add OVS_SELECT_GROUP_ATTR_* attributes
to supply parameters to the selection method: for example which
selection algorithm to use. This relates to a proposed
Open Flow extension that we have made.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 datapath/linux/compat/include/linux/openvswitch.h | 31 +++++++++++++++++++++++
 lib/dpif-netdev.c                                 |  1 +
 lib/dpif.c                                        |  1 +
 lib/odp-execute.c                                 |  1 +
 lib/odp-util.c                                    |  2 ++
 5 files changed, 36 insertions(+)

diff --git a/datapath/linux/compat/include/linux/openvswitch.h b/datapath/linux/compat/include/linux/openvswitch.h
index 6910dc4..91ff939 100644
--- a/datapath/linux/compat/include/linux/openvswitch.h
+++ b/datapath/linux/compat/include/linux/openvswitch.h
@@ -510,6 +510,35 @@ enum ovs_sample_attr {
 #define OVS_SAMPLE_ATTR_MAX (__OVS_SAMPLE_ATTR_MAX - 1)
 
 /**
+ * enum ovs_bucket_attr - Bucket for * %OVS_ACTION_ATTR_SELECT_GROUP action.
+ * @OVS_BUCKET_ATTR_WEIGHT.   Relative weight of bucket.
+ * @OVS_BUCKET_ATTR_ACTIONS.  Set of actions to execute.
+ */
+enum ovs_bucket_attr {
+	OVS_BUCKET_ATTR_UNSPEC,
+	OVS_BUCKET_ATTR_WEIGHT,  /* u16. Relative weight of bucket. */
+	OVS_BUCKET_ATTR_ACTIONS, /* Nested OVS_BUCKET_ATTR_* attributes. */
+	__OVS_BUCKET_ATTR_MAX,
+};
+
+#define OVS_BUCKET_ATTR_MAX (__OVS_BUCKET_ATTR_MAX - 1)
+
+/**
+ * enum ovs_select_group_attr - Attributes for * %OVS_ACTION_ATTR_SELECT_GROUP action.
+ * @OVS_SELECT_GROUP_ATTR_BUCKET.  A bucket whose actions will be executed
+ * if the bucket is selected. One ore more buckets may be present.
+ *
+ * Selects a bucket and executes its actions.
+ */
+enum ovs_select_group_attr {
+	OVS_SELECT_GROUP_ATTR_UNSPEC,
+	OVS_SELECT_GROUP_ATTR_BUCKET, /* Nested OVS_BUCKET_ATTR_* attributes. */
+	__OVS_SELECT_GROUP_ATTR_MAX,
+};
+
+#define OVS_SELECT_GROUP_ATTR_MAX (__OVS_SELECT_GROUP_ATTR_MAX - 1)
+
+/**
  * enum ovs_userspace_attr - Attributes for %OVS_ACTION_ATTR_USERSPACE action.
  * @OVS_USERSPACE_ATTR_PID: u32 Netlink PID to which the %OVS_PACKET_CMD_ACTION
  * message should be sent.  Required.
@@ -609,6 +638,7 @@ struct ovs_action_hash {
  * indicate the new packet contents. This could potentially still be
  * %ETH_P_MPLS if the resulting MPLS label stack is not empty.  If there
  * is no MPLS label stack, as determined by ethertype, no action is taken.
+ * @OVS_ACTION_ATTR_SELECT_GROUP: Select a bucket and execute its actions.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -631,6 +661,7 @@ enum ovs_action_attr {
 				       * data immediately followed by a mask.
 				       * The data must be zero for the unmasked
 				       * bits. */
+	OVS_ACTION_ATTR_SELECT_GROUP, /* Nested OVS_SELECT_GROUP_*. */
 	__OVS_ACTION_ATTR_MAX
 };
 
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 409c9bf..bfcfd8c 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -2560,6 +2560,7 @@ dp_execute_cb(void *aux_, struct dpif_packet **packets, int cnt,
     case OVS_ACTION_ATTR_SET:
     case OVS_ACTION_ATTR_SET_MASKED:
     case OVS_ACTION_ATTR_SAMPLE:
+    case OVS_ACTION_ATTR_SELECT_GROUP:
     case OVS_ACTION_ATTR_UNSPEC:
     case __OVS_ACTION_ATTR_MAX:
         OVS_NOT_REACHED();
diff --git a/lib/dpif.c b/lib/dpif.c
index bf2c5f9..90b561f 100644
--- a/lib/dpif.c
+++ b/lib/dpif.c
@@ -1043,6 +1043,7 @@ dpif_execute_helper_cb(void *aux_, struct dpif_packet **packets, int cnt,
     case OVS_ACTION_ATTR_SET:
     case OVS_ACTION_ATTR_SET_MASKED:
     case OVS_ACTION_ATTR_SAMPLE:
+    case OVS_ACTION_ATTR_SELECT_GROUP:
     case OVS_ACTION_ATTR_UNSPEC:
     case __OVS_ACTION_ATTR_MAX:
         OVS_NOT_REACHED();
diff --git a/lib/odp-execute.c b/lib/odp-execute.c
index e4bee18..c0ba868 100644
--- a/lib/odp-execute.c
+++ b/lib/odp-execute.c
@@ -518,6 +518,7 @@ odp_execute_actions__(void *dp, struct dpif_packet **packets, int cnt,
             }
             break;
 
+        case OVS_ACTION_ATTR_SELECT_GROUP:
         case OVS_ACTION_ATTR_UNSPEC:
         case __OVS_ACTION_ATTR_MAX:
             OVS_NOT_REACHED();
diff --git a/lib/odp-util.c b/lib/odp-util.c
index d205473..77b456f 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -83,6 +83,7 @@ odp_action_len(uint16_t type)
     case OVS_ACTION_ATTR_HASH: return sizeof(struct ovs_action_hash);
     case OVS_ACTION_ATTR_SET: return -2;
     case OVS_ACTION_ATTR_SET_MASKED: return -2;
+    case OVS_ACTION_ATTR_SELECT_GROUP: return -2;
     case OVS_ACTION_ATTR_SAMPLE: return -2;
 
     case OVS_ACTION_ATTR_UNSPEC:
@@ -581,6 +582,7 @@ format_odp_action(struct ds *ds, const struct nlattr *a)
     case OVS_ACTION_ATTR_SAMPLE:
         format_odp_sample_action(ds, a);
         break;
+    case OVS_ACTION_ATTR_SELECT_GROUP:
     case OVS_ACTION_ATTR_UNSPEC:
     case __OVS_ACTION_ATTR_MAX:
     default:
-- 
2.0.1
