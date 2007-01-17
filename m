From: Dmitry Mishin <dim@openvz.org>
Subject: [PATCH 4/12] L2 network namespace (v3): devinet sysctl's checks
Date: Wed, 17 Jan 2007 19:01:57 +0300
Message-ID: <200701171901.57990.dim@openvz.org>
References: <200701171851.14734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alexey@sw.ru, saw@sw.ru, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:42685 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932524AbXAQQEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 11:04:21 -0500
To: containers@lists.osdl.org
In-Reply-To: <200701171851.14734.dim@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch prohibits sysctl's registrations for devices, initialized in non-init
network namespace. This is required due to absense of the sysctl virtualization.

Signed-off-by: Dmitry Mishin <dim@openvz.org>

---
 net/ipv4/devinet.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

--- linux-2.6.20-rc4-mm1.net_ns.orig/net/ipv4/devinet.c
+++ linux-2.6.20-rc4-mm1.net_ns/net/ipv4/devinet.c
@@ -160,15 +160,17 @@ struct in_device *inetdev_init(struct ne
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+	if (current_net_ns == &init_net_ns)
+		neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
+				NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 #endif
 
 	/* Account for reference dev->ip_ptr (below) */
 	in_dev_hold(in_dev);
 
 #ifdef CONFIG_SYSCTL
-	devinet_sysctl_register(in_dev, &in_dev->cnf);
+	if (current_net_ns == &init_net_ns)
+		devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
 	ip_mc_init_dev(in_dev);
 	if (dev->flags & IFF_UP)
@@ -211,13 +213,15 @@ static void inetdev_destroy(struct in_de
 	}
 
 #ifdef CONFIG_SYSCTL
-	devinet_sysctl_unregister(&in_dev->cnf);
+	if (current_net_ns == &init_net_ns)
+		devinet_sysctl_unregister(&in_dev->cnf);
 #endif
 
 	dev->ip_ptr = NULL;
 
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(in_dev->arp_parms);
+	if (current_net_ns == &init_net_ns)
+		neigh_sysctl_unregister(in_dev->arp_parms);
 #endif
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
 	arp_ifdown(dev);
@@ -1105,11 +1109,13 @@ static int inetdev_event(struct notifier
 		inetdev_changename(dev, in_dev);
 
 #ifdef CONFIG_SYSCTL
-		devinet_sysctl_unregister(&in_dev->cnf);
-		neigh_sysctl_unregister(in_dev->arp_parms);
-		neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-				      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
-		devinet_sysctl_register(in_dev, &in_dev->cnf);
+		if (current_net_ns == &init_net_ns) {
+			devinet_sysctl_unregister(&in_dev->cnf);
+			neigh_sysctl_unregister(in_dev->arp_parms);
+			neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
+					      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+			devinet_sysctl_register(in_dev, &in_dev->cnf);
+		}
 #endif
 		break;
 	}
