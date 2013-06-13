From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 01/12] gre: Simplify gre protocol registration locking.
Date: Thu, 13 Jun 2013 11:24:11 -0700
Message-ID: <1371147851-9127-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:55051 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756774Ab3FMSYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:14 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so11671138pdj.28
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cmpxchg() for atomic protocol registration which saves
code and data space.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
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
