From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier
 to network flow classifier
Date: Sat, 26 Feb 2011 01:00:48 +0000
Message-ID: <1298682048.3555.18.camel@localhost>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	 <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31388 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab1BZBAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 20:00:52 -0500
In-Reply-To: <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-25 at 15:32 -0800, Alexander Duyck wrote:
> This change is meant to add an ntuple define type to the rx network flow
> classification specifiers.  The idea is to allow ntuple to be displayed and
> possibly configured via the network flow classification interface.  To do
> this I added a ntuple_flow_spec_ext to the lsit of supported filters, and
> added a flow_type_ext value to the structure in an unused hole within the
> ethtool_rx_flow_spec structure.

There's a hole there on 64-bit architectures.  Unfortunately, on i386
and other architectures where u64 is not 64-bit-aligned, there isn't.
We actually need to add compat handling for the commands that use it.

Also, we don't want these flags to be ignored by older kernel versions
and drivers - they should reject specs that they don't understand.  So
any extension flags need to be added to flow_type.

> Due to the fact that the flow specifier structures are only 4 byte aligned
> instead of 8 I had to break the user data field into 2 sections.  In
> addition I added the vlan ethertype field since this is what ixgbe was
> using the user-data for currently and it allows for the fields to stay 4
> byte aligned while occupying space at the end of the flow_spec.
>
> In order to guarantee byte ordering I also thought it best to keep all
> fields in the flow_spec area a big endian value, as such I added vlan, vlan
> ethertype, and data as big endian values.

It's not important that byte order is consistent across architectures.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  include/linux/ethtool.h |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index aac3e2e..3d1f8e0 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -378,10 +378,25 @@ struct ethtool_usrip4_spec {
>  };
>  
>  /**
> + * struct ethtool_ntuple_spec_ext - flow spec extension for ntuple in nfc
> + * @unused: space unused by extension
> + * @vlan_etype: EtherType for vlan tagged packet to match
> + * @vlan_tci: VLAN tag to match
> + * @data: Driver-dependent data to match
> + */
> +struct ethtool_ntuple_spec_ext {
> +	__be32	unused[15];
> +	__be16	vlan_etype;
> +	__be16	vlan_tci;
> +	__be32	data[2];
> +};
[...]

This is a really nasty way to reclaim space in the union.

Let's name the union, shrink it and insert the extra fields that way:

--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -377,27 +377,43 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+union ethtool_flow_union {
+	struct ethtool_tcpip4_spec		tcp_ip4_spec;
+	struct ethtool_tcpip4_spec		udp_ip4_spec;
+	struct ethtool_tcpip4_spec		sctp_ip4_spec;
+	struct ethtool_ah_espip4_spec		ah_ip4_spec;
+	struct ethtool_ah_espip4_spec		esp_ip4_spec;
+	struct ethtool_usrip4_spec		usr_ip4_spec;
+	struct ethhdr				ether_spec;
+	__u8					hdata[52];
+};
+
+struct ethtool_flow_ext {
+	__be16	vlan_etype;
+	__be16	vlan_tci;
+	__be32	data[2];
+	__u32	reserved[2];
+};
+
 /**
  * struct ethtool_rx_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow fields to match (dependent on @flow_type)
+ * @h_ext: Additional fields to match
  * @m_u: Masks for flow field bits to be ignored
+ * @m_ext: Masks for additional field bits to be ignored.
+ *	Note, all additional fields must be ignored unless @flow_type
+ *	includes the %FLOW_EXT flag.
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
  * @location: Index of filter in hardware table
  */
 struct ethtool_rx_flow_spec {
 	__u32		flow_type;
-	union {
-		struct ethtool_tcpip4_spec		tcp_ip4_spec;
-		struct ethtool_tcpip4_spec		udp_ip4_spec;
-		struct ethtool_tcpip4_spec		sctp_ip4_spec;
-		struct ethtool_ah_espip4_spec		ah_ip4_spec;
-		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_usrip4_spec		usr_ip4_spec;
-		struct ethhdr				ether_spec;
-		__u8					hdata[72];
-	} h_u, m_u;
+	union ethtool_flow_union h_u;
+	struct ethtool_flow_ext h_ext;
+	union ethtool_flow_union m_u;
+	struct ethtool_flow_ext m_ext;
 	__u64		ring_cookie;
 	__u32		location;
 };
@@ -954,6 +970,8 @@ struct ethtool_ops {
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
+/* Flag to enable additional fields in struct ethtool_rx_flow_spec */
+#define	FLOW_EXT	0x80000000
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
---

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

