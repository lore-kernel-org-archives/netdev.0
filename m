From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Mon, 6 Feb 2012 04:41:13 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
	<10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
 <20120203.192933.510206531351047222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"steweg@ynet.sk" <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120203.192933.510206531351047222.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Friday, February 03, 2012 4:30 PM
> To: steweg@ynet.sk
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around
> the skb buff size issue
> 
> From: Stefan Gula <steweg@ynet.sk>
> Date: Fri, 3 Feb 2012 15:24:21 +0100 (CET)
> 
> > From: Stefan Gula <steweg@gmail.com>
> >
> > Adding new rtnetlink ops and command for getting more information about
> > network devices, which are not able to fit inside predefined SKB
> structures
> > (e.g. PAGE_SIZE limit). DEVDUMP command allows to call specific device
> driver
> > code for complete handling this netlink message. Useful if devices
> needed to
> > list some addition dynamic structures like hlists and doesn't require to
> have
> > complete set of codes for it new PF families.
> >
> > Signed-off-by: Stefan Gula <steweg@gmail.com>
> 
> This is not how we're going to fix this.  I already stated the desired
> way to fix this, which is to make the existing dump request have a way
> for the requestor to enable extended parts of the device dump.
> 
> This is just like netlink diag socket dumps, where the dump request
> specifies what the user wants to see.
> 
> In this case we'd add a netlink attribute to the dump request which
> is just a u32 bitmask or similar.
> 
> The Intel engineer who added the VF dump support said he would work on
> this fix so why don't you just wait patiently for him to do the work?

The patch below is what I've got so far.  Right now the bit mask array is global so if you enable display of VF (n) on one interface it will enable display of the same VF on other interfaces.  I intend to move the bit mask array into the net_device structure so we can set the display mask for each interface independently.

The command to set the filter mask is "set only", I see no reason to add it to the info dump.  If other folks see it differently then I can do that too.

Anyway, it will allow the user to control which VFs are getting displayed during the info dump.  They all default to off so initially no VF info gets displayed.

I've also whipped up a patch for the iproute2 ip command.  It'll work like this:

'ip link set <dev> vf (n) filter [on|off]'

So if you have 128 VFs on the device you could enable info dumps for arbitrary VFs, e.g. VFs 3, 9, 16, 21, and 31.  Only the info for those VFs would display.  This method has the advantage of not breaking scripts which parse the current VF info display.  Of course, one could also script up something to sequentially enable the display of a single VF, dump the info for it, and then move on to the next.

Before I go much further on this let me know if this is the right track or not.

Thanks,

- Greg

---

 include/linux/if_link.h |    6 ++++++
 net/core/rtnetlink.c    |   30 +++++++++++++++++++++++++++---
 2 files changed, 33 insertions(+), 3 deletions(-)


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
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index af1da12..8c0c8c1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -62,6 +62,9 @@ struct rtnl_link {
 static DEFINE_MUTEX(rtnl_mutex);
 static u16 min_ifinfo_dump_size;
 
+/* VF info display filter - Number of VFs max is 256 */
+static unsigned long show_vfinfo_filter[256 / sizeof(unsigned long)];
+
 void rtnl_lock(void)
 {
 	mutex_lock(&rtnl_mutex);
@@ -876,6 +879,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
+	u32 num_vf_filters_set = 0;
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -941,10 +945,18 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
-	if (dev->dev.parent)
-		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+	if (dev->dev.parent) {
+		int j;
+		for (j = 0; j < 256; j++) {
+			if (test_bit(j, show_vfinfo_filter))
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
@@ -960,6 +972,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 
+			if (!test_bit(i, show_vfinfo_filter))
+				continue;
+
 			/*
 			 * Not all SR-IOV capable drivers support the
 			 * spoofcheck query.  Preset to -1 so the user
@@ -1234,6 +1249,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							       ivs->setting);
 			break;
 		}
+		case IFLA_VF_INFOFILTER: {
+			 struct ifla_vf_infofilter *ivf;
+			 ivf = nla_data(vf);
+			 if (ivf->filter)
+				 set_bit(ivf->vf, show_vfinfo_filter);
+			 else
+				 clear_bit(ivf->vf, show_vfinfo_filter);
+			 break;
+		}
 		default:
 			err = -EINVAL;
 			break;



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
