From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] garp: remove one synchronize_rcu() call
Date: Mon, 09 May 2011 15:35:55 +0200
Message-ID: <1304948155.3342.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61564 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab1EINf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 09:35:59 -0400
Received: by wya21 with SMTP id 21so3872244wya.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 06:35:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup vlan dismantling in CONFIG_VLAN_8021Q_GVRP=y cases,
by using a call_rcu() to free the memory instead of waiting with
expensive synchronize_rcu() [ while RTNL is held ]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
Note: I'll take care of using kfree_rcu() when available in net-next-2.6

 include/net/garp.h |    1 +
 net/802/garp.c     |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/garp.h b/include/net/garp.h
index f4c2959..8cabbf08 100644
--- a/include/net/garp.h
+++ b/include/net/garp.h
@@ -108,6 +108,7 @@ struct garp_applicant {
 
 struct garp_port {
 	struct garp_applicant __rcu	*applicants[GARP_APPLICATION_MAX + 1];
+	struct rcu_head			rcu;
 };
 
 extern int	garp_register_application(struct garp_application *app);
diff --git a/net/802/garp.c b/net/802/garp.c
index c1df2da..5dbe896 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -544,6 +544,11 @@ static int garp_init_port(struct net_device *dev)
 	return 0;
 }
 
+static void garp_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct garp_port, rcu));
+}
+
 static void garp_release_port(struct net_device *dev)
 {
 	struct garp_port *port = rtnl_dereference(dev->garp_port);
@@ -554,8 +559,7 @@ static void garp_release_port(struct net_device *dev)
 			return;
 	}
 	rcu_assign_pointer(dev->garp_port, NULL);
-	synchronize_rcu();
-	kfree(port);
+	call_rcu(&port->rcu, garp_kfree_rcu);
 }
 
 int garp_init_applicant(struct net_device *dev, struct garp_application *appl)


