From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Tue, 07 Feb 2012 14:33:46 -0800
Message-ID: <20120207223346.21320.89370.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29525 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755861Ab2BGWvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 17:51:52 -0500
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id q17MXkMU021349
	for <netdev@vger.kernel.org>; Tue, 7 Feb 2012 14:33:46 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a 256 bit filter to allow the user to filter which VFs' info will
get displayed during the dump info request.  This is to fix a bug in
which a an info dump request on a device with many VFs would overflow
the recvmsg buffer which is allocated to max(8192, PAGE_SIZE).  A
complimentary patch to the iproute2 ip tool will allow the user to
set/clear individual VF filters.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/if_link.h   |    6 ++++++
 include/linux/netdevice.h |    2 ++
 net/core/rtnetlink.c      |   40 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..052c240 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -280,6 +280,7 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
+	IFLA_VF_INFOFILTER,	/* Filter vfinfo on dumps */
 	__IFLA_VF_MAX,
 };
 
@@ -305,6 +306,11 @@ struct ifla_vf_spoofchk {
 	__u32 vf;
 	__u32 setting;
 };
+
+struct ifla_vf_infofilter {
+	__u32 vf;
+	__u32 filter;
+};
 #ifdef __KERNEL__
 
 /* We don't want this structure exposed to user space */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..dd30b5d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1298,6 +1298,8 @@ struct net_device {
 
 	/* group the device belongs to */
 	int group;
+	/* VF info display filter - Number of VFs max is 256 */
+	unsigned long show_vfinfo_filter[BITS_TO_LONGS(256)];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 39aa20b..4fd78dd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -727,9 +727,13 @@ static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
 static inline int rtnl_vfinfo_size(const struct net_device *dev)
 {
 	if (dev->dev.parent && dev_is_pci(dev->dev.parent)) {
-
-		int num_vfs = dev_num_vf(dev->dev.parent);
+		int j;
+		int num_vfs = 0;
 		size_t size = nla_total_size(sizeof(struct nlattr));
+		for (j = 0; j < 256; j++) {
+			if (test_bit(j, dev->show_vfinfo_filter))
+				num_vfs++;
+		}
 		size += nla_total_size(num_vfs * sizeof(struct nlattr));
 		size += num_vfs *
 			(nla_total_size(sizeof(struct ifla_vf_mac)) +
@@ -876,6 +880,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
+	u32 num_vf_filters_set = 0;
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -941,10 +946,18 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
-	if (dev->dev.parent)
-		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+	if (dev->dev.parent) {
+		int j;
+		for (j = 0; j < 256; j++) {
+			if (test_bit(j, dev->show_vfinfo_filter))
+				num_vf_filters_set++;
+		}
+		if (num_vf_filters_set)
+			NLA_PUT_U32(skb, IFLA_NUM_VF, num_vf_filters_set);
+	}
 
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
+	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent &&
+			num_vf_filters_set) {
 		int i;
 
 		struct nlattr *vfinfo, *vf;
@@ -960,6 +973,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 
+			if (!test_bit(i, dev->show_vfinfo_filter))
+				continue;
+
 			/*
 			 * Not all SR-IOV capable drivers support the
 			 * spoofcheck query.  Preset to -1 so the user
@@ -1234,6 +1250,20 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							       ivs->setting);
 			break;
 		}
+		case IFLA_VF_INFOFILTER: {
+			struct ifla_vf_infofilter *ivf;
+			ivf = nla_data(vf);
+			if (ivf->vf < dev_num_vf(dev->dev.parent)) {
+				if (ivf->filter)
+					set_bit(ivf->vf,
+						dev->show_vfinfo_filter);
+			else
+					clear_bit(ivf->vf,
+						dev->show_vfinfo_filter);
+				err = 0;
+			}
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
