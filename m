From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 3/4] net/802: add __rcu annotations
Date: Mon, 25 Oct 2010 09:32:36 +0200
Message-ID: <1287991956.2658.5384.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61410 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab0JYHcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 03:32:45 -0400
Received: by wwe15 with SMTP id 15so3171005wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:32:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(struct net_device)->garp_port is rcu protected :
(struct garp_port)->applicants is rcu protected :

add __rcu annotation and proper rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 +-
 include/net/garp.h        |    2 +-
 net/802/garp.c            |   18 +++++++++---------
 net/802/stp.c             |    4 ++--
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4722d4a..b72d5a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1072,7 +1072,7 @@ struct net_device {
 		struct pcpu_dstats __percpu	*dstats; /* dummy stats */
 	};
 	/* GARP */
-	struct garp_port	*garp_port;
+	struct garp_port __rcu	*garp_port;
 
 	/* class/net/name entry */
 	struct device		dev;
diff --git a/include/net/garp.h b/include/net/garp.h
index 825f172..f4c2959 100644
--- a/include/net/garp.h
+++ b/include/net/garp.h
@@ -107,7 +107,7 @@ struct garp_applicant {
 };
 
 struct garp_port {
-	struct garp_applicant	*applicants[GARP_APPLICATION_MAX + 1];
+	struct garp_applicant __rcu	*applicants[GARP_APPLICATION_MAX + 1];
 };
 
 extern int	garp_register_application(struct garp_application *app);
diff --git a/net/802/garp.c b/net/802/garp.c
index 941f2a3..c1df2da 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -346,8 +346,8 @@ int garp_request_join(const struct net_device *dev,
 		      const struct garp_application *appl,
 		      const void *data, u8 len, u8 type)
 {
-	struct garp_port *port = dev->garp_port;
-	struct garp_applicant *app = port->applicants[appl->type];
+	struct garp_port *port = rtnl_dereference(dev->garp_port);
+	struct garp_applicant *app = rtnl_dereference(port->applicants[appl->type]);
 	struct garp_attr *attr;
 
 	spin_lock_bh(&app->lock);
@@ -366,8 +366,8 @@ void garp_request_leave(const struct net_device *dev,
 			const struct garp_application *appl,
 			const void *data, u8 len, u8 type)
 {
-	struct garp_port *port = dev->garp_port;
-	struct garp_applicant *app = port->applicants[appl->type];
+	struct garp_port *port = rtnl_dereference(dev->garp_port);
+	struct garp_applicant *app = rtnl_dereference(port->applicants[appl->type]);
 	struct garp_attr *attr;
 
 	spin_lock_bh(&app->lock);
@@ -546,11 +546,11 @@ static int garp_init_port(struct net_device *dev)
 
 static void garp_release_port(struct net_device *dev)
 {
-	struct garp_port *port = dev->garp_port;
+	struct garp_port *port = rtnl_dereference(dev->garp_port);
 	unsigned int i;
 
 	for (i = 0; i <= GARP_APPLICATION_MAX; i++) {
-		if (port->applicants[i])
+		if (rtnl_dereference(port->applicants[i]))
 			return;
 	}
 	rcu_assign_pointer(dev->garp_port, NULL);
@@ -565,7 +565,7 @@ int garp_init_applicant(struct net_device *dev, struct garp_application *appl)
 
 	ASSERT_RTNL();
 
-	if (!dev->garp_port) {
+	if (!rtnl_dereference(dev->garp_port)) {
 		err = garp_init_port(dev);
 		if (err < 0)
 			goto err1;
@@ -601,8 +601,8 @@ EXPORT_SYMBOL_GPL(garp_init_applicant);
 
 void garp_uninit_applicant(struct net_device *dev, struct garp_application *appl)
 {
-	struct garp_port *port = dev->garp_port;
-	struct garp_applicant *app = port->applicants[appl->type];
+	struct garp_port *port = rtnl_dereference(dev->garp_port);
+	struct garp_applicant *app = rtnl_dereference(port->applicants[appl->type]);
 
 	ASSERT_RTNL();
 
diff --git a/net/802/stp.c b/net/802/stp.c
index 53c8f77..978c30b 100644
--- a/net/802/stp.c
+++ b/net/802/stp.c
@@ -21,8 +21,8 @@
 #define GARP_ADDR_MAX	0x2F
 #define GARP_ADDR_RANGE	(GARP_ADDR_MAX - GARP_ADDR_MIN)
 
-static const struct stp_proto *garp_protos[GARP_ADDR_RANGE + 1] __read_mostly;
-static const struct stp_proto *stp_proto __read_mostly;
+static const struct stp_proto __rcu *garp_protos[GARP_ADDR_RANGE + 1] __read_mostly;
+static const struct stp_proto __rcu *stp_proto __read_mostly;
 
 static struct llc_sap *sap __read_mostly;
 static unsigned int sap_registered;


