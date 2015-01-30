From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH 2/3] if_link: Add VF multicast promiscuous
	control
Date: Fri, 30 Jan 2015 11:37:40 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E190AC@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Add netlink directives and ndo entry to allow VF multicast promiscuous mode.

The administrator wants to allow dedicatedly multicast promiscuous per VF.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 include/linux/if_link.h      |  1 +
 include/linux/netdevice.h    |  3 +++
 include/uapi/linux/if_link.h |  6 ++++++
 net/core/rtnetlink.c         | 18 ++++++++++++++++--
 4 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 119130e..bc29ddf 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -14,5 +14,6 @@ struct ifla_vf_info {
 	__u32 linkstate;
 	__u32 min_tx_rate;
 	__u32 max_tx_rate;
+	__u32 mc_promisc;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 52fd8e8..12e88a7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -868,6 +868,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
  *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_set_vf_mc_promisc)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
@@ -1084,6 +1085,8 @@ struct net_device_ops {
 						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
+	int			(*ndo_set_vf_mc_promisc)(struct net_device *dev,
+							 int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7d0d2d..a476aea 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -454,6 +454,7 @@ enum {
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
 	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
+	IFLA_VF_MC_PROMISC,	/* Multicast Promiscuous allow/disallow */
 	__IFLA_VF_MAX,
 };
 
@@ -498,6 +499,11 @@ struct ifla_vf_link_state {
 	__u32 link_state;
 };
 
+struct ifla_vf_mc_promisc {
+	__u32 vf;
+	__u32 setting;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9cf6fe9..5992245 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -807,7 +807,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
-			 nla_total_size(sizeof(struct ifla_vf_link_state)));
+			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
+			 nla_total_size(sizeof(struct ifla_vf_mc_promisc)));
 		return size;
 	} else
 		return 0;
@@ -1099,6 +1100,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
+			struct ifla_vf_mc_promisc vf_mc_promisc;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1107,6 +1109,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 * report anything.
 			 */
 			ivi.spoofchk = -1;
+			ivi.mc_promisc = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
 			/* The default value for VF link state is "auto"
 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
@@ -1119,7 +1122,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				vf_rate.vf =
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
-				vf_linkstate.vf = ivi.vf;
+				vf_linkstate.vf =
+				vf_mc_promisc.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
@@ -1128,6 +1132,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_rate.min_tx_rate = ivi.min_tx_rate;
 			vf_rate.max_tx_rate = ivi.max_tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
+			vf_mc_promisc.setting = ivi.mc_promisc;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
@@ -1461,6 +1466,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 								 ivl->link_state);
 			break;
 		}
+		case IFLA_VF_MC_PROMISC: {
+			struct ifla_vf_mc_promisc *ivm;
+			ivm = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_mc_promisc)
+				err = ops->ndo_set_vf_mc_promisc(dev, ivm->vf,
+								 ivm->setting);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
1.9.0

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
