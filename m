From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 01/12] openvswitch: use const in some
	local vars and casts
Date: Fri, 16 May 2014 14:07:28 -0700
Message-ID: <1400274459-56304-2-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400274459-56304-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

In few functions, const formal parameters are assigned or cast to
non-const.
These changes suppress warnings if compiled with -Wcast-qual.

Signed-off-by: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow_netlink.c |  6 ++++--
 net/openvswitch/flow_table.c   | 16 +++++++++-------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 4d000ac..5517bd6 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -628,8 +628,10 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  bool *exact_5tuple
 
 		if (is_mask && exact_5tuple && *exact_5tuple) {
 			if (ipv6_key->ipv6_proto != 0xff ||
-			    !is_all_set((u8 *)ipv6_key->ipv6_src, sizeof(match->key->ipv6.addr.src)) ||
-			    !is_all_set((u8 *)ipv6_key->ipv6_dst, sizeof(match->key->ipv6.addr.dst)))
+			    !is_all_set((const u8 *)ipv6_key->ipv6_src,
+					sizeof(match->key->ipv6.addr.src)) ||
+			    !is_all_set((const u8 *)ipv6_key->ipv6_dst,
+					sizeof(match->key->ipv6.addr.dst)))
 				*exact_5tuple = false;
 		}
 	}
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 3c268b3..1ba1e0b 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -57,8 +57,10 @@ static u16 range_n_bytes(const struct sw_flow_key_range *range)
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask)
 {
-	const long *m = (long *)((u8 *)&mask->key + mask->range.start);
-	const long *s = (long *)((u8 *)src + mask->range.start);
+	const long *m = (const long *)((const u8 *)&mask->key +
+				mask->range.start);
+	const long *s = (const long *)((const u8 *)src +
+				mask->range.start);
 	long *d = (long *)((u8 *)dst + mask->range.start);
 	int i;
 
@@ -375,7 +377,7 @@ int ovs_flow_tbl_flush(struct flow_table *flow_table)
 static u32 flow_hash(const struct sw_flow_key *key, int key_start,
 		     int key_end)
 {
-	u32 *hash_key = (u32 *)((u8 *)key + key_start);
+	const u32 *hash_key = (const u32 *)((const u8 *)key + key_start);
 	int hash_u32s = (key_end - key_start) >> 2;
 
 	/* Make sure number of hash bytes are multiple of u32. */
@@ -397,8 +399,8 @@ static bool cmp_key(const struct sw_flow_key *key1,
 		    const struct sw_flow_key *key2,
 		    int key_start, int key_end)
 {
-	const long *cp1 = (long *)((u8 *)key1 + key_start);
-	const long *cp2 = (long *)((u8 *)key2 + key_start);
+	const long *cp1 = (const long *)((const u8 *)key1 + key_start);
+	const long *cp2 = (const long *)((const u8 *)key2 + key_start);
 	long diffs = 0;
 	int i;
 
@@ -513,8 +515,8 @@ static struct sw_flow_mask *mask_alloc(void)
 static bool mask_equal(const struct sw_flow_mask *a,
 		       const struct sw_flow_mask *b)
 {
-	u8 *a_ = (u8 *)&a->key + a->range.start;
-	u8 *b_ = (u8 *)&b->key + b->range.start;
+	const u8 *a_ = (const u8 *)&a->key + a->range.start;
+	const u8 *b_ = (const u8 *)&b->key + b->range.start;
 
 	return  (a->range.end == b->range.end)
 		&& (a->range.start == b->range.start)
-- 
1.9.1
