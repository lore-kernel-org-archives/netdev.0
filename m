From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 1/5] be2net: Implement ndo_gso_check()
Date: Tue,  4 Nov 2014 13:56:38 -0800
Message-ID: <1415138202-1197-2-git-send-email-joestringer@nicira.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog033.obsmtp.com ([74.125.150.107]:34204 "HELO
	na6sys009bog033.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751325AbaKDWCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 17:02:39 -0500
Received: by mail-pd0-f178.google.com with SMTP id fp1so14588534pdb.9
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 14:02:36 -0800 (PST)
In-Reply-To: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_gso_check() was recently introduced to allow NICs to report the
offloading support that they have on a per-skb basis. Add an
implementation for this driver which checks for something that looks
like VXLAN.

Implementation shamelessly stolen from Tom Herbert:
http://thread.gmane.org/gmane.linux.network/332428/focus=333111

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9a18e79..bd52b8d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4423,6 +4423,17 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 }
 #endif
 
+static bool be_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
+	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	     skb->inner_protocol != htons(ETH_P_TEB) ||
+	     skb_inner_mac_header(skb) - skb_transport_header(skb) != 16))
+		return false;
+
+	return true;
+}
+
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -4451,6 +4462,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_add_vxlan_port	= be_add_vxlan_port,
 	.ndo_del_vxlan_port	= be_del_vxlan_port,
 #endif
+	.ndo_gso_check		= be_gso_check,
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.7.10.4
