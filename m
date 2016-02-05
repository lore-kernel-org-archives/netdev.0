From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 1/2] ethtool: support notifying drivers when user requests default rxfh table
Date: Fri,  5 Feb 2016 12:30:20 -0800
Message-ID: <1454704221-14238-2-git-send-email-jacob.e.keller@intel.com>
References: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	Dave Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22173 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600AbcBEUab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 15:30:31 -0500
In-Reply-To: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, userspace ethtool supports requesting the default indirection
table by passing 0 as the indir_size. However, ops->set_rxfh does not
distinguish between user requesting default via indir_size=0 and user
requesting explicitly settings which are equivalent of the default.

This causes problems because other driver changes such as number of
channels (queues) should fail when they will not work with other current
settings such as the indirection table.

If there is no way to indicate when the driver is in default RSS table
state compared to user set states, then we wouldn't ever allow changing
the number of queues at all. To fix this, drivers must be able to
distinguish between requested settings and the configured defaults.

We can't use a value of NULL to the *indir pointer as this is already
used to indicate no change to the indirection table. Instead, implement
a new callback ops->reset_rxfh_indir which is used whenever the user
requests size of zero. This has lower impact than adding a new flag and
can be implemented by drivers as necessary.

In this way we have the following scenarios now:

(a) driver is in default configuration, and is free to change RSS
settings as necessary due to other changes such as number of queues.
This makes sense since we can essentially consider this as "RSS
indirection has not been configured". This is the default state of a new
device. In this state, I think the reasonable default is "Always RSS to
all enabled queues".

(b) user has requested RSS indirection settings, should change the
driver state to "RSS indirection table has been configured". Now if the
user requests a change in the number of queues, we can properly indicate
an error when these settings would conflict with the requested RSS
indirection table.

(c) The user can request default settings via the {GS}RXFH operations
and the driver will get a clear indication that it should reset to the
default "RSS indirection table has not been configured" mode. In this
way it will be able to then change the number of queues and go about
business.

If we don't have a way to properly indicate that we've reset to default
then we are not able to implement the proposed behavior, so this patch
adds a new method to properly indicate that we have reset to the default
indirection table.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Dave Miller <davem@davemloft.net>
---
This is an alternative proposal to my previous patch. I do not believe
it is possible to obtain desired behavior without this patch, as it is
not possible for the driver to distinguish default settings from user
configured RSS table. If we don't do that, then the user will never be
able to reduce the number of queues without first modifying the RSS
redirection table, which seems wrong to me.

 include/linux/ethtool.h | 3 +++
 net/core/ethtool.c      | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c4ebac..700ac5658d34 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -186,6 +186,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  *	will remain unchanged.
  *	Returns a negative error code or zero. An error code must be returned
  *	if at least one unsupported change was requested.
+ * @reset_rxfh_indir: Reset the contents of the RX flow hash indirection table
+ * 	to driver defaults. Returns a negative error code or zero.
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code or
  *	zero.
@@ -262,6 +264,7 @@ struct ethtool_ops {
 			    u8 *hfunc);
 	int	(*set_rxfh)(struct net_device *, const u32 *indir,
 			    const u8 *key, const u8 hfunc);
+	int	(*reset_rxfh_indir)(struct net_device *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index daf04709dd3c..4c6a1c2b8b61 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -725,7 +725,13 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	if (ret)
 		goto out;
 
+	/* user_size == 0 means reset the indir table to default. */
 	if (user_size == 0) {
+		if (ops->reset_rxfh_indir) {
+			err = ops->reset_rxfh_indir(dev);
+			goto out;
+		}
+
 		for (i = 0; i < dev_size; i++)
 			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
 	} else {
@@ -880,6 +886,8 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
 						  rxfh.indir_size);
 		if (ret)
 			goto out;
+	} else if (rxfh.indir_size == 0 && ops->reset_rxfh_indir) {
+		ret = ops->reset_rxfh_indir(dev);
 	} else if (rxfh.indir_size == 0) {
 		indir = (u32 *)rss_config;
 		for (i = 0; i < dev_indir_size; i++)
-- 
2.7.0.236.gda096a0.dirty
