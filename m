From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] garp: remove last synchronize_rcu() call
Date: Thu, 12 May 2011 15:29:17 +0200
Message-ID: <1305206957.3795.21.camel@edumazet-laptop>
References: <1304948155.3342.32.camel@edumazet-laptop>
	 <4DC831B0.80107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59547 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757048Ab1ELN3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 09:29:32 -0400
Received: by wwa36 with SMTP id 36so1763974wwa.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 06:29:31 -0700 (PDT)
In-Reply-To: <4DC831B0.80107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 20:25 +0200, Patrick McHardy a =C3=A9crit :
> Am 09.05.2011 15:35, schrieb Eric Dumazet:
> > Speedup vlan dismantling in CONFIG_VLAN_8021Q_GVRP=3Dy cases,
> > by using a call_rcu() to free the memory instead of waiting with
> > expensive synchronize_rcu() [ while RTNL is held ]
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Ben Greear <greearb@candelatech.com>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> > Note: I'll take care of using kfree_rcu() when available in net-nex=
t-2.6
> >=20
>=20
> Looks good to me.
>=20

Here is a followup on this patch, thanks !


[PATCH net-next-2.6] garp: remove last synchronize_rcu() call

When removing last vlan from a device, garp_uninit_applicant() calls
synchronize_rcu() to make sure no user can still manipulate struct
garp_applicant before we free it.

Use call_rcu() instead, as a step to further net_device dismantle
optimizations.

Add the temporary garp_cleanup_module() function to make sure no pendin=
g
call_rcu() are left at module unload time [ this will be removed when
kfree_rcu() is available ]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ben Greear <greearb@candelatech.com>
---
 include/net/garp.h |    1 +
 net/802/garp.c     |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/garp.h b/include/net/garp.h
index 8cabbf08..834d8ad 100644
--- a/include/net/garp.h
+++ b/include/net/garp.h
@@ -104,6 +104,7 @@ struct garp_applicant {
 	struct sk_buff_head	queue;
 	struct sk_buff		*pdu;
 	struct rb_root		gid;
+	struct rcu_head		rcu;
 };
=20
 struct garp_port {
diff --git a/net/802/garp.c b/net/802/garp.c
index 5dbe896..f8300a8 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -603,6 +603,11 @@ err1:
 }
 EXPORT_SYMBOL_GPL(garp_init_applicant);
=20
+static void garp_app_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct garp_applicant, rcu));
+}
+
 void garp_uninit_applicant(struct net_device *dev, struct garp_applica=
tion *appl)
 {
 	struct garp_port *port =3D rtnl_dereference(dev->garp_port);
@@ -611,7 +616,6 @@ void garp_uninit_applicant(struct net_device *dev, =
struct garp_application *appl
 	ASSERT_RTNL();
=20
 	rcu_assign_pointer(port->applicants[appl->type], NULL);
-	synchronize_rcu();
=20
 	/* Delete timer and generate a final TRANSMIT_PDU event to flush out
 	 * all pending messages before the applicant is gone. */
@@ -621,7 +625,7 @@ void garp_uninit_applicant(struct net_device *dev, =
struct garp_application *appl
 	garp_queue_xmit(app);
=20
 	dev_mc_del(dev, appl->proto.group_address);
-	kfree(app);
+	call_rcu(&app->rcu, garp_app_kfree_rcu);
 	garp_release_port(dev);
 }
 EXPORT_SYMBOL_GPL(garp_uninit_applicant);
@@ -639,3 +643,9 @@ void garp_unregister_application(struct garp_applic=
ation *appl)
 	stp_proto_unregister(&appl->proto);
 }
 EXPORT_SYMBOL_GPL(garp_unregister_application);
+
+static void __exit garp_cleanup_module(void)
+{
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+}
+module_exit(garp_cleanup_module);


