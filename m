From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ethtool: remove phys_id from ethtool_ops
Date: Fri, 8 Apr 2011 17:08:30 -0700
Message-ID: <20110408170830.3ab079e8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54065 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757983Ab1DIAId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 20:08:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hold this patch until after the Intel and Qlogic driver
changes are merged into net-next. Patches have been submitted
but still waiting for vendor.

After that all the upstream kernel drivers now use phys_id, 
and the old ethtool_ops interface (phys_id) can be removed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/ethtool.h	2011-04-08 16:59:55.691452941 -0700
+++ b/include/linux/ethtool.h	2011-04-08 17:00:26.135748450 -0700
@@ -767,12 +767,6 @@ bool ethtool_invalid_flags(struct net_de
  *	the indicator accordingly.  Finally, it is called with the argument
  *	%ETHTOOL_ID_INACTIVE and must deactivate the indicator.  Returns a
  *	negative error code or zero.
- * @phys_id: Deprecated in favour of @set_phys_id.
- *	Identify the physical device, e.g. by flashing an LED
- *	attached to it until interrupted by a signal or the given time
- *	(in seconds) elapses.  If the given time is zero, use a default
- *	time limit.  Returns a negative error code or zero.  Being
- *	interrupted by a signal is not an error.
  * @get_ethtool_stats: Return extended statistics about the device.
  *	This is only useful if the device maintains statistics not
  *	included in &struct rtnl_link_stats64.
@@ -858,7 +852,6 @@ struct ethtool_ops {
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*set_phys_id)(struct net_device *, enum ethtool_phys_id_state);
-	int	(*phys_id)(struct net_device *, u32);
 	void	(*get_ethtool_stats)(struct net_device *,
 				     struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
--- a/net/core/ethtool.c	2011-04-08 17:00:33.259817585 -0700
+++ b/net/core/ethtool.c	2011-04-08 17:01:01.620092913 -0700
@@ -1623,7 +1623,7 @@ static int ethtool_phys_id(struct net_de
 	static bool busy;
 	int rc;
 
-	if (!dev->ethtool_ops->set_phys_id && !dev->ethtool_ops->phys_id)
+	if (!dev->ethtool_ops->set_phys_id)
 		return -EOPNOTSUPP;
 
 	if (busy)
@@ -1632,10 +1632,6 @@ static int ethtool_phys_id(struct net_de
 	if (copy_from_user(&id, useraddr, sizeof(id)))
 		return -EFAULT;
 
-	if (!dev->ethtool_ops->set_phys_id)
-		/* Do it the old way */
-		return dev->ethtool_ops->phys_id(dev, id.data);
-
 	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
 	if (rc && rc != -EINVAL)
 		return rc;

