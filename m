From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v3 2/3] if_link: Add VF multicast promiscuous
	control
Date: Wed, 8 Apr 2015 05:37:53 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CD61@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
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

This controls the permission to enter VF multicast promiscuous mode.
The administrator will dedicatedly allow multicast promiscuous per VF.

When the VF is under multicast promiscuous mode, all multicast packets are
sent to the VF.

Don't allow VF multicast promiscuous if the VM isn't fully trusted.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 include/linux/if_link.h      |  1 +
 include/linux/netdevice.h    |  3 +++
 include/uapi/linux/if_link.h |  6 ++++++
 net/core/rtnetlink.c         | 19 +++++++++++++++++--
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index da49299..df212f4 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -15,5 +15,6 @@ struct ifla_vf_info {
 	__u32 min_tx_rate;
 	__u32 max_tx_rate;
 	__u32 rss_query_en;
+	__u32 mc_promisc;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fc4da22..a444e1d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -873,6 +873,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
  *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_set_vf_mc_promisc)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
@@ -1094,6 +1095,8 @@ struct net_device_ops {
 						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
+	int			(*ndo_set_vf_mc_promisc)(struct net_device *dev,
+							 int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d9cd192..44c3bbe 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -468,6 +468,7 @@ enum {
 	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
 				 * on/off switch
 				 */
+	IFLA_VF_MC_PROMISC,	/* Multicast Promiscuous allow/disallow */
 	__IFLA_VF_MAX,
 };
 
@@ -517,6 +518,11 @@ struct ifla_vf_rss_query_en {
 	__u32 setting;
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
index 74431d6..f247bf2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,7 +819,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
-			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
+			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
+			 nla_total_size(sizeof(struct ifla_vf_mc_promisc)));
 		return size;
 	} else
 		return 0;
@@ -1134,6 +1135,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
 			struct ifla_vf_rss_query_en vf_rss_query_en;
+			struct ifla_vf_mc_promisc vf_mc_promisc;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1143,6 +1145,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 */
 			ivi.spoofchk = -1;
 			ivi.rss_query_en = -1;
+			ivi.mc_promisc = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
 			/* The default value for VF link state is "auto"
 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
@@ -1156,7 +1159,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
 				vf_linkstate.vf =
-				vf_rss_query_en.vf = ivi.vf;
+				vf_rss_query_en.vf =
+				vf_mc_promisc.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
@@ -1167,6 +1171,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf_rss_query_en.setting = ivi.rss_query_en;
+			vf_mc_promisc.setting = ivi.mc_promisc;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -1520,6 +1525,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							    ivrssq_en->setting);
 			break;
 		}
+		case IFLA_VF_MC_PROMISC: {
+			struct ifla_vf_mc_promisc *ivm;
+
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
2.1.0

------------------------------------------------------------------------------
BPM Camp - Free Virtual Workshop May 6th at 10am PDT/1PM EDT
Develop your own process in accordance with the BPMN 2 standard
Learn Process modeling best practices with Bonita BPM through live exercises
http://www.bonitasoft.com/be-part-of-it/events/bpm-camp-virtual- event?utm_
source=Sourceforge_BPM_Camp_5_6_15&utm_medium=email&utm_campaign=VA_SF
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
