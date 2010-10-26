From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC][net-next-2.6 PATCH v2] 8021q: set hard_header_len when VLAN
	offload features are toggled
Date: Tue, 26 Oct 2010 14:59:33 -0700
Message-ID: <20101026215933.2339.45454.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53806 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757809Ab0JZWBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 18:01:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
This results in pskb_expand_head() being used unnecessarily.

This add a check in vlan_transfer_features  to catch the ETH_FLAG_TXVLAN
flag and set the header length. This requires drivers to add the
ETH_FLAG_TXVLAN to vlan_features.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 05b867e..825011b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -334,6 +334,16 @@ static void vlan_transfer_features(struct net_device *dev,
 	vlandev->features &= ~dev->vlan_features;
 	vlandev->features |= dev->features & dev->vlan_features;
 	vlandev->gso_max_size = dev->gso_max_size;
+
+	/* is ETH_FLAGS_TXVLAN being toggled */
+	if ((vlandev->features & ETH_FLAG_TXVLAN) ^
+	    (old_features & ETH_FLAG_TXVLAN)) {
+		if (vlandev->features & ETH_FLAG_TXVLAN)
+			vlandev->hard_header_len -= VLAN_HLEN;
+		else
+			vlandev->hard_header_len += VLAN_HLEN;
+	}
+
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif

