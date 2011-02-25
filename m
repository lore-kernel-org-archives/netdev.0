From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 10/10] [RFC] ixgbe: Add support for using the
	same fields as ntuple in nfc
Date: Fri, 25 Feb 2011 15:33:31 -0800
Message-ID: <20110225233331.7920.22212.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8721 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933047Ab1BYXdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:31 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to make use of the NTUPLE_FLOW_EXT to allow the
network flow classifier interface to support the same type of options in
terms of VLAN and User-defined as the ntuple interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a91e8db..494e1bf 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2388,6 +2388,13 @@ static int ixgbe_get_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	fsp->m_u.tcp_ip4_spec.ip4src = mask->formatted.src_ip[0];
 	fsp->h_u.tcp_ip4_spec.ip4dst = rule->filter.formatted.dst_ip[0];
 	fsp->m_u.tcp_ip4_spec.ip4dst = mask->formatted.dst_ip[0];
+	fsp->h_u.ntuple_spec.vlan_tci = rule->filter.formatted.vlan_id;
+	fsp->m_u.ntuple_spec.vlan_tci = mask->formatted.vlan_id;
+	fsp->h_u.ntuple_spec.vlan_etype = rule->filter.formatted.flex_bytes;
+	fsp->m_u.ntuple_spec.vlan_etype = mask->formatted.flex_bytes;
+	*(u8 *)fsp->h_u.ntuple_spec.data = rule->filter.formatted.vm_pool;
+	*(u8 *)fsp->m_u.ntuple_spec.data = mask->formatted.vm_pool;
+	fsp->flow_type_ext = NTUPLE_FLOW_EXT;
 
 	/* record action */
 	if (rule->action == IXGBE_FDIR_DROP_QUEUE)
@@ -2603,6 +2610,18 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	input->filter.formatted.dst_port = fsp->h_u.tcp_ip4_spec.pdst;
 	mask.formatted.dst_port = fsp->m_u.tcp_ip4_spec.pdst;
 
+	if (fsp->flow_type_ext == NTUPLE_FLOW_EXT) {
+		input->filter.formatted.vm_pool =
+				*(unsigned char *)fsp->h_u.ntuple_spec.data;
+		mask.formatted.vm_pool =
+				*(unsigned char *)fsp->m_u.ntuple_spec.data;
+		input->filter.formatted.vlan_id = fsp->h_u.ntuple_spec.vlan_tci;
+		mask.formatted.vlan_id = fsp->m_u.ntuple_spec.vlan_tci;
+		input->filter.formatted.flex_bytes =
+						fsp->h_u.ntuple_spec.vlan_etype;
+		mask.formatted.flex_bytes = fsp->m_u.ntuple_spec.vlan_etype;
+	}
+
 	/* determine if we need to drop or route the packet */
 	if (fsp->ring_cookie == RX_CLS_FLOW_DISC)
 		input->action = IXGBE_FDIR_DROP_QUEUE;

