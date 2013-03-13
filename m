From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/6] GRE: Use RTNL for atomic protocol registration.
Date: Wed, 13 Mar 2013 15:48:27 -0700
Message-ID: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:40930 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755609Ab3CMWtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:49:06 -0400
Received: by mail-pb0-f70.google.com with SMTP id un1so2779213pbc.9
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:49:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently gre demultiplexer uses its own spin-lock. We should
rather RTNL lock.

Suggested-by: Stephen Hemminger <--cc stephen@networkplumber.org>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/ppp/pptp.c |    4 ++++
 net/ipv4/gre.c         |   18 +++++-------------
 net/ipv4/ip_gre.c      |    6 ++++++
 3 files changed, 15 insertions(+), 13 deletions(-)

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
index 7a4c710..fbaf33d 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -26,7 +26,6 @@
 
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
-static DEFINE_SPINLOCK(gre_proto_lock);
 struct gre_base_hdr {
 	__be16 flags;
 	__be16 protocol;
@@ -35,19 +34,16 @@ struct gre_base_hdr {
 
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
@@ -55,20 +51,16 @@ EXPORT_SYMBOL_GPL(gre_add_protocol);
 
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
index a13a097..99cf2b4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1852,7 +1852,9 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
+	rtnl_lock();
 	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	rtnl_unlock();
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		goto add_proto_failed;
@@ -1872,7 +1874,9 @@ out:
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
+	rtnl_lock();
 	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	rtnl_unlock();
 add_proto_failed:
 	unregister_pernet_device(&ipgre_net_ops);
 	goto out;
@@ -1882,8 +1886,10 @@ static void __exit ipgre_fini(void)
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
