From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] ethtool: Remove unimplemented flow
 specification types
Date: Tue, 14 Sep 2010 20:13:08 +0100
Message-ID: <1284491588.2289.8.camel@achroite.uk.solarflarecom.com>
References: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Santwona Behera <santwona.behera@sun.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17788 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab0INTNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 15:13:11 -0400
In-Reply-To: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ethtool_rawip4_spec and struct ethtool_ether_spec are neither
commented nor used by any driver, so remove them.  Adjust padding in
the user-visible unions that included these structures.

Fix references to struct ethtool_rawip4_spec in
ethtool_get_rx_ntuple(), which should use struct ethtool_usrip4_spec.

struct ethtool_usrip4_spec cannot hold IPv6 host addresses and there
is no separate structure that can, so remove ETH_RX_NFC_IP6 and the
reference to it in niu.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.

Ben.

 drivers/net/niu.c       |   19 +++++--------------
 include/linux/ethtool.h |   21 ++-------------------
 net/core/ethtool.c      |    8 ++++----
 3 files changed, 11 insertions(+), 37 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 8e1859c..e36a838 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7462,10 +7462,12 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 	if (fsp->flow_type == IP_USER_FLOW) {
 		int i;
 		int add_usr_cls = 0;
-		int ipv6 = 0;
 		struct ethtool_usrip4_spec *uspec = &fsp->h_u.usr_ip4_spec;
 		struct ethtool_usrip4_spec *umask = &fsp->m_u.usr_ip4_spec;
 
+		if (uspec->ip_ver != ETH_RX_NFC_IP4)
+			return -EINVAL;
+
 		niu_lock_parent(np, flags);
 
 		for (i = 0; i < NIU_L3_PROG_CLS; i++) {
@@ -7494,9 +7496,7 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 				default:
 					break;
 				}
-				if (uspec->ip_ver == ETH_RX_NFC_IP6)
-					ipv6 = 1;
-				ret = tcam_user_ip_class_set(np, class, ipv6,
+				ret = tcam_user_ip_class_set(np, class, 0,
 							     uspec->proto,
 							     uspec->tos,
 							     umask->tos);
@@ -7553,16 +7553,7 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 		ret = -EINVAL;
 		goto out;
 	case IP_USER_FLOW:
-		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
-			niu_get_tcamkey_from_ip4fs(fsp, tp, l2_rdc_table,
-						   class);
-		} else {
-			/* Not yet implemented */
-			netdev_info(np->dev, "niu%d: In %s(): usr flow for IPv6 not implemented\n",
-				    parent->index, __func__);
-			ret = -EINVAL;
-			goto out;
-		}
+		niu_get_tcamkey_from_ip4fs(fsp, tp, l2_rdc_table, class);
 		break;
 	default:
 		netdev_info(np->dev, "niu%d: In %s(): Unknown flow type %d\n",
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 4b3ba05..d64e246 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -353,20 +353,7 @@ struct ethtool_ah_espip4_spec {
 	__u8    tos;
 };
 
-struct ethtool_rawip4_spec {
-	__be32	ip4src;
-	__be32	ip4dst;
-	__u8	hdata[64];
-};
-
-struct ethtool_ether_spec {
-	__be16	ether_type;
-	__u8	frame_size;
-	__u8	eframe[16];
-};
-
 #define	ETH_RX_NFC_IP4	1
-#define	ETH_RX_NFC_IP6	2
 
 /**
  * struct ethtool_usrip4_spec - general flow specification for IPv4
@@ -403,10 +390,8 @@ struct ethtool_rx_flow_spec {
 		struct ethtool_tcpip4_spec		sctp_ip4_spec;
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_rawip4_spec		raw_ip4_spec;
-		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
-		__u8					hdata[64];
+		__u8					hdata[72];
 	} h_u, m_u;
 	__u64		ring_cookie;
 	__u32		location;
@@ -496,10 +481,8 @@ struct ethtool_rx_ntuple_flow_spec {
 		struct ethtool_tcpip4_spec		sctp_ip4_spec;
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_rawip4_spec		raw_ip4_spec;
-		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
-		__u8					hdata[64];
+		__u8					hdata[72];
 	} h_u, m_u;
 
 	__u16	        vlan_tag;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 970eb98..fcd62757 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -673,19 +673,19 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 			break;
 		case IP_USER_FLOW:
 			sprintf(p, "\tSrc IP addr: 0x%x\n",
-				fsc->fs.h_u.raw_ip4_spec.ip4src);
+				fsc->fs.h_u.usr_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tSrc IP mask: 0x%x\n",
-				fsc->fs.m_u.raw_ip4_spec.ip4src);
+				fsc->fs.m_u.usr_ip4_spec.ip4src);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP addr: 0x%x\n",
-				fsc->fs.h_u.raw_ip4_spec.ip4dst);
+				fsc->fs.h_u.usr_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			sprintf(p, "\tDest IP mask: 0x%x\n",
-				fsc->fs.m_u.raw_ip4_spec.ip4dst);
+				fsc->fs.m_u.usr_ip4_spec.ip4dst);
 			p += ETH_GSTRING_LEN;
 			num_strings++;
 			break;
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

