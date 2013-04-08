From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 4/4] Avoid recirculation id collision
Date: Mon,  8 Apr 2013 15:43:51 +0900
Message-ID: <1365403431-18102-5-git-send-email-horms@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1365403431-18102-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Avoid recirculation id collision by checking that an id is
not already associated with a facet.

Consecutive recirculation ids are used and thus it is possible for
there to be situations where a very large number of ids have to
be checked before finding one that is not already associated with a facet.

To mitigate the performance impact of such situations a limit on
the number of checks is in place and if no unused recirculation id
can be found then the miss is handled without facets as this can
be done using a dummy recirculation id.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

This patch depends on the patch "Allow recirculation without facets"

---

v5
* First post
---
 ofproto/ofproto-dpif.c |   55 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 45 insertions(+), 10 deletions(-)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 67121f2..e9ab58c 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -3455,24 +3455,51 @@ port_is_lacp_current(const struct ofport *ofport_)
 #define RECIRCULATION_ID_DUMMY 2
 #define RECIRCULATION_ID_MIN   RECIRCULATION_ID_DUMMY
 
+#define RECIRCULATION_ID_MAX_LOOP 1024  /* Arbitrary value to prevent
+                                         * endless loop */
+
 static uint32_t recirculation_id_hash(uint32_t id)
 {
     return hash_words(&id, 1, 0);
 }
 
-/* XXX: This does not prevent id collision */
-static uint32_t get_recirculation_id(void)
+static uint32_t recirculation_id = RECIRCULATION_ID_MIN;
+static uint32_t validated_recirculation_id = RECIRCULATION_ID_NONE;
+
+static uint32_t peek_recirculation_id(struct ofproto_dpif *ofproto)
 {
-    static uint32_t id = RECIRCULATION_ID_MIN;
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+
+    int loop = RECIRCULATION_ID_MAX_LOOP;
 
-    if (id < RECIRCULATION_ID_MIN)
-        id = RECIRCULATION_ID_MIN;
-    /* Skip IPSEC_MARK bit it is reserved */
-    if (id & IPSEC_MARK) {
-        id++;
-        ovs_assert(!(id & IPSEC_MARK));
+    if (validated_recirculation_id == recirculation_id) {
+        return recirculation_id;
+    }
+
+    while (loop--) {
+        if (recirculation_id < RECIRCULATION_ID_MIN)
+            recirculation_id = RECIRCULATION_ID_MIN;
+        /* Skip IPSEC_MARK bit it is reserved */
+        if (recirculation_id & IPSEC_MARK) {
+            recirculation_id++;
+            ovs_assert(!(recirculation_id & IPSEC_MARK));
+        }
+        if (!facet_find_by_id(ofproto, recirculation_id)) {
+            validated_recirculation_id = recirculation_id;
+            return recirculation_id;
+        }
+        recirculation_id++;
     }
-    return id++;
+
+    VLOG_WARN_RL(&rl, "Failed to allocate recirulation id after %d attempts\n",
+                 RECIRCULATION_ID_MAX_LOOP);
+    return RECIRCULATION_ID_NONE;
+}
+
+static uint32_t get_recirculation_id(void)
+{
+    ovs_assert(recirculation_id == validated_recirculation_id);
+    return recirculation_id++;
 }
 
 /* Upcall handling. */
@@ -3690,6 +3717,14 @@ static bool
 flow_miss_should_make_facet(struct ofproto_dpif *ofproto,
                             struct flow_miss *miss, uint32_t hash)
 {
+    /* If the packet is MPLS then recirculation may be used and
+     * this will not be possible with facets if there are no recirculation
+     * ids available */
+    if (eth_type_mpls(miss->flow.dl_type) &&
+        peek_recirculation_id(ofproto) == RECIRCULATION_ID_NONE) {
+        return false;
+    }
+
     if (!ofproto->governor) {
         size_t n_subfacets;
 
-- 
1.7.10.4
