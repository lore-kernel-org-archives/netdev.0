From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 8/8] ethtool: Remove ethtool_ops::set_rx_ntuple
 operation
Date: Tue, 3 Jan 2012 22:07:59 +0000
Message-ID: <1325628479.2832.45.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56160 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754957Ab2ACWID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:08:03 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All implementations have been converted to implement set_rxnfc
instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    4 ---
 net/core/ethtool.c      |   55 -----------------------------------------------
 2 files changed, 0 insertions(+), 59 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index d901714..da5b2de 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -859,8 +859,6 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @reset: Reset (part of) the device, as specified by a bitmask of
  *	flags from &enum ethtool_reset_flags.  Returns a negative
  *	error code or zero.
- * @set_rx_ntuple: Set an RX n-tuple rule.  Returns a negative error code
- *	or zero.
  * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
  *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
@@ -929,8 +927,6 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
-	int	(*set_rx_ntuple)(struct net_device *,
-				 struct ethtool_rx_ntuple *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
 	int	(*get_rxfh_indir)(struct net_device *, u32 *);
 	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e88b80d..921aa2b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -631,58 +631,6 @@ out:
 	return ret;
 }
 
-/*
- * ethtool does not (or did not) set masks for flow parameters that are
- * not specified, so if both value and mask are 0 then this must be
- * treated as equivalent to a mask with all bits set.  Implement that
- * here rather than in drivers.
- */
-static void rx_ntuple_fix_masks(struct ethtool_rx_ntuple_flow_spec *fs)
-{
-	struct ethtool_tcpip4_spec *entry = &fs->h_u.tcp_ip4_spec;
-	struct ethtool_tcpip4_spec *mask = &fs->m_u.tcp_ip4_spec;
-
-	if (fs->flow_type != TCP_V4_FLOW &&
-	    fs->flow_type != UDP_V4_FLOW &&
-	    fs->flow_type != SCTP_V4_FLOW)
-		return;
-
-	if (!(entry->ip4src | mask->ip4src))
-		mask->ip4src = htonl(0xffffffff);
-	if (!(entry->ip4dst | mask->ip4dst))
-		mask->ip4dst = htonl(0xffffffff);
-	if (!(entry->psrc | mask->psrc))
-		mask->psrc = htons(0xffff);
-	if (!(entry->pdst | mask->pdst))
-		mask->pdst = htons(0xffff);
-	if (!(entry->tos | mask->tos))
-		mask->tos = 0xff;
-	if (!(fs->vlan_tag | fs->vlan_tag_mask))
-		fs->vlan_tag_mask = 0xffff;
-	if (!(fs->data | fs->data_mask))
-		fs->data_mask = 0xffffffffffffffffULL;
-}
-
-static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
-						    void __user *useraddr)
-{
-	struct ethtool_rx_ntuple cmd;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
-
-	if (!ops->set_rx_ntuple)
-		return -EOPNOTSUPP;
-
-	if (!(dev->features & NETIF_F_NTUPLE))
-		return -EINVAL;
-
-	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
-		return -EFAULT;
-
-	rx_ntuple_fix_masks(&cmd.fs);
-
-	return ops->set_rx_ntuple(dev, &cmd);
-}
-
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
@@ -1495,9 +1443,6 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_RESET:
 		rc = ethtool_reset(dev, useraddr);
 		break;
-	case ETHTOOL_SRXNTUPLE:
-		rc = ethtool_set_rx_ntuple(dev, useraddr);
-		break;
 	case ETHTOOL_GSSET_INFO:
 		rc = ethtool_get_sset_info(dev, useraddr);
 		break;
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
