From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/5] GRE: Use RTNL for atomic protocol
	registration.
Date: Mon,  7 Jan 2013 18:31:46 -0800
Message-ID: <1357612306-1748-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Currently gre demultiplexer uses its own spin-lock. We should
rather RTNL lock.

Suggested-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ppp/pptp.c |    4 ++++
 net/ipv4/gre.c         |   18 +++++-------------
 net/ipv4/ip_gre.c      |    4 ++++
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 162464f..672e7e3 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -673,7 +673,9 @@ static int __init pptp_init_module(void)
 	if (!callid_sock)
 		return -ENOMEM;
 
+	rtnl_lock();
 	err = gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
+	rtnl_unlock();
 	if (err) {
 		pr_err("PPTP: can't add gre protocol\n");
 		goto out_mem_free;
@@ -707,7 +709,9 @@ static void __exit pptp_exit_module(void)
 {
 	unregister_pppox_proto(PX_PROTO_PPTP);
 	proto_unregister(&pptp_sk_proto);
+	rtnl_lock();
 	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
+	rtnl_unlock();
 	vfree(callid_sock);
 }
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 0eaaf44..c0757c9 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -26,23 +26,19 @@
 
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
-static DEFINE_SPINLOCK(gre_proto_lock);
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
+	ASSERT_RTNL();
 	if (version >= GREPROTO_MAX)
 		goto err_out;
 
-	spin_lock(&gre_proto_lock);
 	if (gre_proto[version])
-		goto err_out_unlock;
+		goto err_out;
 
 	RCU_INIT_POINTER(gre_proto[version], proto);
-	spin_unlock(&gre_proto_lock);
 	return 0;
 
-err_out_unlock:
-	spin_unlock(&gre_proto_lock);
 err_out:
 	return -1;
 }
@@ -50,20 +46,16 @@ EXPORT_SYMBOL_GPL(gre_add_protocol);
 
 int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 {
+	ASSERT_RTNL();
 	if (version >= GREPROTO_MAX)
 		goto err_out;
 
-	spin_lock(&gre_proto_lock);
-	if (rcu_dereference_protected(gre_proto[version],
-			lockdep_is_held(&gre_proto_lock)) != proto)
-		goto err_out_unlock;
+	if (rtnl_dereference(gre_proto[version]) != proto)
+		goto err_out;
 	RCU_INIT_POINTER(gre_proto[version], NULL);
-	spin_unlock(&gre_proto_lock);
 	synchronize_rcu();
 	return 0;
 
-err_out_unlock:
-	spin_unlock(&gre_proto_lock);
 err_out:
 	return -1;
 }
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 303012a..05f389f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1792,7 +1792,9 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
+	rtnl_lock();
 	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	rtnl_unlock();
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		goto add_proto_failed;
@@ -1822,8 +1824,10 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
+	rtnl_lock();
 	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
+	rtnl_unlock();
 	unregister_pernet_device(&ipgre_net_ops);
 }
 
-- 
1.7.1
