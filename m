From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 15/15] vxlan: Add new UDP encapsulation offload
 type for VXLAN-GPE
Date: Mon, 13 Jun 2016 10:50:08 -0700
Message-ID: <20160613175008.15186.76657.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33545 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423279AbcFMRuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:50:15 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so25429769pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:50:14 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fact is VXLAN with Generic Protocol Extensions cannot be supported by
the same hardware parsers as that support VXLAN.  The protocol extensions
allow for things like a Next Protocol field which in turn allows for things
other than Ethernet to be passed over the tunnel.  Most existing parsers
will not know how to interpret this.

To resolve this I am giving VXLAN-GPE its own UDP encapsulation offload
type.  This way hardware that does support GPE can simply add this type to
the switch statement for VXLAN, and if they don't support it then this will
fix any issues where headers might be interpreted incorrectly.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/vxlan.c      |   12 ++++++++++--
 include/net/udp_tunnel.h |    1 +
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 72da056abdf4..501c9e4741ed 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -622,13 +622,19 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 /* Notify netdevs that UDP port started listening */
 static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
-	udp_tunnel_notify_add_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
+	udp_tunnel_notify_add_rx_port(vs->sock,
+				      (vs->flags & VXLAN_F_GPE) ?
+				      UDP_ENC_OFFLOAD_TYPE_VXLAN_GPE :
+				      UDP_ENC_OFFLOAD_TYPE_VXLAN);
 }
 
 /* Notify netdevs that UDP port is no more listening */
 static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
-	udp_tunnel_notify_del_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
+	udp_tunnel_notify_del_rx_port(vs->sock,
+				      (vs->flags & VXLAN_F_GPE) ?
+				      UDP_ENC_OFFLOAD_TYPE_VXLAN_GPE :
+				      UDP_ENC_OFFLOAD_TYPE_VXLAN);
 }
 
 /* Add new entry to forwarding table -- assumes lock held */
@@ -2516,6 +2522,8 @@ static void vxlan_push_rx_ports(struct net_device *dev)
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist)
 			udp_tunnel_push_rx_port(dev, vs->sock,
+						(vs->flags & VXLAN_F_GPE) ?
+						UDP_ENC_OFFLOAD_TYPE_VXLAN_GPE :
 						UDP_ENC_OFFLOAD_TYPE_VXLAN);
 	}
 	spin_unlock(&vn->sock_lock);
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 9ea813740231..cc85e9e53f3d 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -88,6 +88,7 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 enum udp_enc_offloads {
 	UDP_ENC_OFFLOAD_TYPE_VXLAN,	/* RFC 7348 */
 	UDP_ENC_OFFLOAD_TYPE_GENEVE,	/* draft-ietf-nvo3-geneve */
+	UDP_ENC_OFFLOAD_TYPE_VXLAN_GPE,	/* draft-ietf-nvo3-vxlan-gpe */
 };
 
 /* Notify network devices of offloadable types */
