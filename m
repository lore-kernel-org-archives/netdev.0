From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3] linux: Report supported user features to the
	kernel
Date: Thu, 19 Dec 2013 16:20:42 +0100
Message-ID: <399ecc79d2539f4624d9b5363f37c8d358571fae.1387466318.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Following commit (''netlink: Do not enforce alignment of last Netlink
attribute''), signal the ability to receive unaligned Netlink messages
to the datapath to enable utilization of zerocopy optimizations.

Opening a datapath is now done by issueing a OVS_DP_CMD_SET in order
to overwrite previously set user features.

Signed-off-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
V3: Use OVS_DP_CMD_SET when opening the datapath

 lib/dpif-linux.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
index f64e55b..482ba77 100644
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
@@ -231,9 +232,11 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
         upcall_pid = 0;
         dp_request.upcall_pid = &upcall_pid;
     } else {
-        dp_request.cmd = OVS_DP_CMD_GET;
+        /* Use OVS_DP_CMD_SET to report user features */
+        dp_request.cmd = OVS_DP_CMD_SET;
     }
     dp_request.name = name;
+    dp_request.user_features |= OVS_DP_F_UNALIGNED;
     error = dpif_linux_dp_transact(&dp_request, &dp, &buf);
     if (error) {
         return error;
@@ -1931,6 +1934,10 @@ dpif_linux_dp_to_ofpbuf(const struct dpif_linux_dp *dp, struct ofpbuf *buf)
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
