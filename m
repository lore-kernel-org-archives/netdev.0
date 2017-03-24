From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] i40e: correctly honor the mask fields for ETHTOOL_SRXCLSRLINS
Date: Thu, 23 Mar 2017 22:14:23 -0700
Message-ID: <20170324051432.79216-2-jeffrey.t.kirsher@intel.com>
References: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53066 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751406AbdCXFOh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 01:14:37 -0400
In-Reply-To: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The current implementation of .set_rxnfc does not properly read the mask
field for filter entries. This results in incorrect driver behavior, as
we do not reject filters which have masks set to ignore some fields. The
current implementation simply assumes that every part of the tuple or
"input set" is specified. This results in filters not behaving as
expected, and not working correctly.

As a first step in supporting some partial filters, add code which
checks the mask fields and rejects any filters which do not have an
acceptable mask. For now, we just assume that all fields must be set.

This will get the driver one step towards allowing some partial filters.
At a minimum, the ethtool commands which previously installed filters
that would not function will now return a non-zero exit code indicating
failure instead.

We should now be meeting the minimum requirements of the .set_rxnfc API,
by ensuring that all filters we program have a valid mask value for each
field.

Finally, add code to report the mask correctly so that the ethtool
command properly reports the mask to the user.

Note that the typecast to (__be16) when checking source and destination
port masks is required because the ~ bitwise negation operator does not
correctly handle variables other than integer size.

Change-Id: Ia020149e07c87aa3fcec7b2283621b887ef0546f
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 83 ++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1c3805b4fcf3..ac8d5cf720aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2409,6 +2409,12 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 	fsp->h_u.tcp_ip4_spec.ip4src = rule->dst_ip;
 	fsp->h_u.tcp_ip4_spec.ip4dst = rule->src_ip;
 
+	/* Set the mask fields */
+	fsp->m_u.tcp_ip4_spec.psrc = htons(0xFFFF);
+	fsp->m_u.tcp_ip4_spec.pdst = htons(0xFFFF);
+	fsp->m_u.tcp_ip4_spec.ip4src = htonl(0xFFFFFFFF);
+	fsp->m_u.tcp_ip4_spec.ip4dst = htonl(0xFFFFFFFF);
+
 	if (rule->dest_ctl == I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET)
 		fsp->ring_cookie = RX_CLS_FLOW_DISC;
 	else
@@ -2718,6 +2724,79 @@ static int i40e_del_fdir_entry(struct i40e_vsi *vsi,
 }
 
 /**
+ * i40e_check_fdir_input_set - Check that a given rx_flow_spec mask is valid
+ * @fsp: pointer to Rx flow specification
+ *
+ * Ensures that a given ethtool_rx_flow_spec has a valid mask.
+ **/
+static int i40e_check_fdir_input_set(struct ethtool_rx_flow_spec *fsp)
+{
+	struct ethtool_tcpip4_spec *tcp_ip4_spec;
+	struct ethtool_usrip4_spec *usr_ip4_spec;
+
+	/* Verify the provided mask is valid. */
+	switch (fsp->flow_type & ~FLOW_EXT) {
+	case SCTP_V4_FLOW:
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		tcp_ip4_spec = &fsp->m_u.tcp_ip4_spec;
+
+		/* IPv4 source address */
+		if (!tcp_ip4_spec->ip4src || ~tcp_ip4_spec->ip4src)
+			return -EOPNOTSUPP;
+
+		/* IPv4 destination address */
+		if (!tcp_ip4_spec->ip4dst || ~tcp_ip4_spec->ip4dst)
+			return -EOPNOTSUPP;
+
+		/* L4 source port */
+		if (!tcp_ip4_spec->psrc || (__be16)~tcp_ip4_spec->psrc)
+			return -EOPNOTSUPP;
+
+		/* L4 destination port */
+		if (!tcp_ip4_spec->pdst || (__be16)~tcp_ip4_spec->pdst)
+			return -EOPNOTSUPP;
+
+		/* Filtering on Type of Service is not supported. */
+		if (tcp_ip4_spec->tos)
+			return -EOPNOTSUPP;
+
+		break;
+	case IP_USER_FLOW:
+		usr_ip4_spec = &fsp->m_u.usr_ip4_spec;
+
+		/* IPv4 source address */
+		if (!usr_ip4_spec->ip4src || ~usr_ip4_spec->ip4src)
+			return -EOPNOTSUPP;
+
+		/* IPv4 destination address */
+		if (!usr_ip4_spec->ip4dst || ~usr_ip4_spec->ip4dst)
+			return -EOPNOTSUPP;
+
+		/* First 4 bytes of L4 header */
+		if (!usr_ip4_spec->l4_4_bytes || ~usr_ip4_spec->l4_4_bytes)
+			return -EOPNOTSUPP;
+
+		/* Filtering on Type of Service is not supported. */
+		if (usr_ip4_spec->tos)
+			return -EOPNOTSUPP;
+
+		/* IP version does not have a mask field. */
+		if (usr_ip4_spec->ip_ver)
+			return -EINVAL;
+
+		/* L4 protocol doesn't have a mask field. */
+		if (usr_ip4_spec->proto)
+			return -EINVAL;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+/**
  * i40e_add_fdir_ethtool - Add/Remove Flow Director filters
  * @vsi: pointer to the targeted VSI
  * @cmd: command to get or set RX flow classification rules
@@ -2757,6 +2836,10 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	if (fsp->flow_type & FLOW_MAC_EXT)
 		return -EINVAL;
 
+	ret = i40e_check_fdir_input_set(fsp);
+	if (ret)
+		return ret;
+
 	if (fsp->location >= (pf->hw.func_caps.fd_filters_best_effort +
 			      pf->hw.func_caps.fd_filters_guaranteed)) {
 		return -EINVAL;
-- 
2.12.0
