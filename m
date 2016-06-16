From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 17/17] vxlan: Add new UDP encapsulation offload
 type for VXLAN-GPE
Date: Thu, 16 Jun 2016 12:23:19 -0700
Message-ID: <20160616192318.20872.40266.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33104 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbcFPTXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:23:20 -0400
Received: by mail-pf0-f170.google.com with SMTP id i123so18938615pfg.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:23:20 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fact is VXLAN with Generic Protocol Extensions cannot be supported by
the same hardware parsers that support VXLAN.  The protocol extensions
allow for things like a Next Protocol field which in turn allows for things
other than Ethernet to be passed over the tunnel.  Most existing parsers
will not know how to interpret this.

To resolve this I am giving VXLAN-GPE its own UDP encapsulation offload
type.  This way hardware that does support GPE can simply add this type to
the switch statement for VXLAN, and if they don't support it then this will
fix any issues where headers might be interpreted incorrectly.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/vxlan.c      |    6 ++++++
 include/net/udp_tunnel.h |    1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 31aeec967175..abb9cd2df9e9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -998,6 +998,8 @@ static bool __vxlan_sock_release_prep(struct vxlan_sock *vs)
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
 	udp_tunnel_notify_del_rx_port(vs->sock,
+				      (vs->flags & VXLAN_F_GPE) ?
+				      UDP_TUNNEL_TYPE_VXLAN_GPE :
 				      UDP_TUNNEL_TYPE_VXLAN);
 	spin_unlock(&vn->sock_lock);
 
@@ -2488,6 +2490,8 @@ static void vxlan_push_rx_ports(struct net_device *dev)
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist)
 			udp_tunnel_push_rx_port(dev, vs->sock,
+						(vs->flags & VXLAN_F_GPE) ?
+						UDP_TUNNEL_TYPE_VXLAN_GPE :
 						UDP_TUNNEL_TYPE_VXLAN);
 	}
 	spin_unlock(&vn->sock_lock);
@@ -2691,6 +2695,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	udp_tunnel_notify_add_rx_port(sock,
+				      (vs->flags & VXLAN_F_GPE) ?
+				      UDP_TUNNEL_TYPE_VXLAN_GPE :
 				      UDP_TUNNEL_TYPE_VXLAN);
 	spin_unlock(&vn->sock_lock);
 
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 1c9408a04213..02c5be037451 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -103,6 +103,7 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 enum udp_parsable_tunnel_type {
 	UDP_TUNNEL_TYPE_VXLAN,		/* RFC 7348 */
 	UDP_TUNNEL_TYPE_GENEVE,		/* draft-ietf-nvo3-geneve */
+	UDP_TUNNEL_TYPE_VXLAN_GPE,	/* draft-ietf-nvo3-vxlan-gpe */
 };
 
 struct udp_tunnel_info {
