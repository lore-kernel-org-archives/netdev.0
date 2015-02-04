From: Andy Zhou <azhou@nicira.com>
Subject: [RFC: add openvswitch actions using BPF 8/9] ofproto-dpif: Add datapath eBPF support detection
Date: Wed,  4 Feb 2015 14:49:22 -0800
Message-ID: <1423090163-19902-9-git-send-email-azhou@nicira.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: dev@openvswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:55497 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S966341AbbBDXTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:19:10 -0500
Received: by mail-pd0-f175.google.com with SMTP id v10so3671950pde.10
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:19:09 -0800 (PST)
In-Reply-To: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First cut in added datpath eBPF support detector. This feature has not
been fully developed. The stub implementation simply assumes the
datpath support eBPF.

Signed-off-by: Andy Zhou <azhou@nicira.com>

----
Current interface only support 'yes' or 'no' detection. Should we
consider 'support level'?
---
 ofproto/ofproto-dpif.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index b909fd9..4bcd034 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -58,6 +58,7 @@
 #include "ofproto-dpif-sflow.h"
 #include "ofproto-dpif-upcall.h"
 #include "ofproto-dpif-xlate.h"
+#include "ofproto-dpif-bpf.h"
 #include "poll-loop.h"
 #include "ovs-rcu.h"
 #include "ovs-router.h"
@@ -293,6 +294,9 @@ struct dpif_backer {
      * actions. */
     bool masked_set_action;
 
+    /* True if the datapath supports bpf actions */
+    bool enable_bpf_action;
+
     /* Maximum number of MPLS label stack entries that the datapath supports
      * in a match */
     size_t max_mpls_depth;
@@ -909,6 +913,7 @@ static bool check_variable_length_userdata(struct dpif_backer *backer);
 static size_t check_max_mpls_depth(struct dpif_backer *backer);
 static bool check_recirc(struct dpif_backer *backer);
 static bool check_ufid(struct dpif_backer *backer);
+static bool check_bpf_actions(struct dpif_backer *backer);
 static bool check_masked_set_action(struct dpif_backer *backer);
 
 static int
@@ -1007,6 +1012,7 @@ open_dpif_backer(const char *type, struct dpif_backer **backerp)
     backer->max_mpls_depth = check_max_mpls_depth(backer);
     backer->masked_set_action = check_masked_set_action(backer);
     backer->enable_ufid = check_ufid(backer);
+    backer->enable_bpf_action = check_bpf_actions(backer);
     backer->rid_pool = recirc_id_pool_create();
     ovs_mutex_init(&backer->recirc_mutex);
     cmap_init(&backer->recirc_map);
@@ -1032,6 +1038,9 @@ open_dpif_backer(const char *type, struct dpif_backer **backerp)
     backer->variable_length_userdata = check_variable_length_userdata(backer);
     backer->dp_version_string = dpif_get_dp_version(backer->dpif);
 
+    /* Load eBPF actions if datapath supports it.  */
+    error = ofproto_dpif_bpf_init(backer->enable_bpf_action);
+
     return error;
 }
 
@@ -1110,7 +1119,19 @@ check_ufid(struct dpif_backer *backer)
     return enable_ufid;
 }
 
+/* Tests whether 'dpif' supports eBPF base flow actions.
+ *
+ * Returns true if 'dpif' supports eBPF based actions.
+ */
+static bool
+check_bpf_actions( struct dpif_backer *backer OVS_UNUSED)
+{
+    /* XXX */
+    return true;
+}
+
 /* Tests whether 'backer''s datapath supports variable-length
+ *
  * OVS_USERSPACE_ATTR_USERDATA in OVS_ACTION_ATTR_USERSPACE actions.  We need
  * to disable some features on older datapaths that don't support this
  * feature.
-- 
1.9.1
