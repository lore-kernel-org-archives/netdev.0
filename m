From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v2 01/12] gre: Simplify gre protocol
	registration locking.
Date: Mon, 17 Jun 2013 17:49:32 -0700
Message-ID: <1371516572-17661-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
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

Use cmpxchg() for atomic protocol registration which saves
code and data space.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/ipv4/gre.c |   40 +++++++++++++---------------------------
 1 files changed, 13 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index b2e805a..1e294d5 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -26,46 +26,32 @@
 
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
-static DEFINE_SPINLOCK(gre_proto_lock);
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
 	if (version >= GREPROTO_MAX)
-		goto err_out;
-
-	spin_lock(&gre_proto_lock);
-	if (gre_proto[version])
-		goto err_out_unlock;
-
-	RCU_INIT_POINTER(gre_proto[version], proto);
-	spin_unlock(&gre_proto_lock);
-	return 0;
+		return -EINVAL;
 
-err_out_unlock:
-	spin_unlock(&gre_proto_lock);
-err_out:
-	return -1;
+	return (cmpxchg((const struct gre_protocol **)&gre_proto[version], NULL, proto) == NULL) ?
+		0 : -EBUSY;
 }
 EXPORT_SYMBOL_GPL(gre_add_protocol);
 
 int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 {
+	int ret;
+
 	if (version >= GREPROTO_MAX)
-		goto err_out;
-
-	spin_lock(&gre_proto_lock);
-	if (rcu_dereference_protected(gre_proto[version],
-			lockdep_is_held(&gre_proto_lock)) != proto)
-		goto err_out_unlock;
-	RCU_INIT_POINTER(gre_proto[version], NULL);
-	spin_unlock(&gre_proto_lock);
+		return -EINVAL;
+
+	ret = (cmpxchg((const struct gre_protocol **)&gre_proto[version], proto, NULL) == proto) ?
+		0 : -EBUSY;
+
+	if (ret)
+		return ret;
+
 	synchronize_rcu();
 	return 0;
-
-err_out_unlock:
-	spin_unlock(&gre_proto_lock);
-err_out:
-	return -1;
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
-- 
1.7.1
