From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 22:36:12 +0100
Message-ID: <20140402213612.GN11670@casper.infradead.org>
References: <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
 <20140402192915.GB3301@tuxdriver.com>
 <20140402130437.24885fd8@nehalam.linuxnetplumber.net>
 <20140402202318.GC2844@minipsycho.orion>
 <20140402203830.GE3301@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46811 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933165AbaDBVgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 17:36:18 -0400
Content-Disposition: inline
In-Reply-To: <20140402203830.GE3301@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/14 at 04:38pm, John W. Linville wrote:
> On Wed, Apr 02, 2014 at 10:23:18PM +0200, Jiri Pirko wrote:
> > Wed, Apr 02, 2014 at 10:04:37PM CEST, stephen@networkplumber.org wrote:
> > >On Wed, 2 Apr 2014 15:29:15 -0400
> > >"John W. Linville" <linville@tuxdriver.com> wrote:
> > >
> > >> I've seen the 'ethtool -S' example before and I guess it is valid.
> > >> Still, is it worth the confusion of having a mostly useless/unique
> > >> netdev just to reuse an ethtool ioctl?  Maybe, I guess...?
> > >
> > >ethtool is actually the most worthless part of the API.
> > >It can't be monitored, is ioctl based but and the statistics are device
> > >dependent making them useless for monitoring applications.
> > 
> > Has anyone actually been thinking about converting ethtool functionality
> > to netlink as well? I did some time ago. Most of it should be easy (more or less)
> > to do I believe.
> 
> Seems like a good idea...but only if you promise to have it primarily
> accessed by a tool with a 2-letter name! :-)

I have a semi complete patch rotting on my system ;-) Attaching
below if somebody wants to continue working on it. The
challenging bit is that Netlink typically guarantees atomic
operations in terms of requests, either all or none of the
requested changes are applied. This is not compatible with the
ethtool_ops as implemented by the drivers where each driver
verifies the input data per setting.


diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6a850a..e461775 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -1200,4 +1200,31 @@ enum ethtool_reset_flags {
 };
 #define ETH_RESET_SHARED_SHIFT	16
 
+enum {
+	IFLA_ETHTOOL_UNSPEC,
+	IFLA_ETHTOOL_SETTINGS,
+	IFLA_ETHTOOL_DRVINFO,
+	__IFLA_ETHTOOL_MAX,
+};
+
+#define IFLA_ETHTOOL_MAX (__IFLA_ETHTOOL_MAX - 1)
+
+enum {
+	IFLA_ET_DRVINFO_UNSPEC,
+	IFLA_ET_DRVINFO_NAME,
+	IFLA_ET_DRVINFO_VERSION,
+	IFLA_ET_DRVINFO_FW_VERSION,
+	IFLA_ET_DRVINFO_BUS_INFO,
+	__IFLA_ET_DRVINFO_MAX,
+};
+
+#define IFLA_ET_DRVINFO_MAX (__IFLA_ET_DRVINFO_MAX - 1)
+
+#ifdef __KERNEL__
+
+extern size_t ethtool_nlattr_size(const struct net_device *);
+extern int ethtool_fill_nlattr(struct sk_buff *, struct net_device *);
+
+#endif /* __KERNEL__ */
+
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 0ee969a..f3ad6dd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,7 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_ETHTOOL,
 	__IFLA_MAX
 };
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..088e4e9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/sched.h>
+#include <net/netlink.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -2164,3 +2165,137 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 
 	return rc;
 }
+
+/**************************************************************************
+ *
+ * Ethtool Netlink Implementation
+ *
+ **************************************************************************/
+
+static size_t settings_size(const struct net_device *dev)
+{
+	if (dev->ethtool_ops && dev->ethtool_ops->get_settings)
+		return nla_total_size(sizeof(struct ethtool_cmd));
+	else
+		return 0;
+}
+
+static int settings_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
+	int err;
+
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+		return 0;
+
+	err = dev->ethtool_ops->get_settings(dev, &cmd);
+	if (err < 0)
+		return err;
+
+	return nla_put(skb, IFLA_ETHTOOL_SETTINGS, sizeof(cmd), &cmd);
+}
+
+static size_t drvinfo_size(const struct net_device *dev)
+{
+	if ((dev->ethtool_ops && dev->ethtool_ops->get_drvinfo) ||
+	    (dev->dev.parent && dev->dev.parent->driver)) {
+		size_t size;
+
+		size = nla_total_size(32);	/* IFLA_ET_DRVINFO_NAME */
+		size += nla_total_size(32);	/* IFLA_ET_DRVINFO_VERSION */
+		/* IFLA_ET_DRVINFO_FW_VERSION */
+		size += nla_total_size(ETHTOOL_FWVERS_LEN);
+		/* IFLA_ET_DRVINFO_BUS_INFO */
+		size += nla_total_size(ETHTOOL_BUSINFO_LEN);
+
+		return nla_total_size(size); /* IFLA_ETHTOOL_DRVINFO */
+	}
+
+	return 0;
+}
+
+static int drvinfo_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_drvinfo info;
+	struct nlattr *attr;
+
+	info.cmd = ETHTOOL_GDRVINFO;
+	if (ops && ops->get_drvinfo) {
+		ops->get_drvinfo(dev, &info);
+	} else if (dev->dev.parent && dev->dev.parent->driver) {
+		strlcpy(info.bus_info, dev_name(dev->dev.parent),
+			sizeof(info.bus_info));
+		strlcpy(info.driver, dev->dev.parent->driver->name,
+			sizeof(info.driver));
+	} else
+		return 0;
+
+	if (!(attr = nla_nest_start(skb, IFLA_ETHTOOL_DRVINFO)))
+		return -EMSGSIZE;
+
+	if (info.driver[0])
+		NLA_PUT_STRING(skb, IFLA_ET_DRVINFO_NAME, info.driver);
+
+	if (info.version[0])
+		NLA_PUT_STRING(skb, IFLA_ET_DRVINFO_VERSION, info.version);
+
+	if (info.fw_version[0])
+		NLA_PUT_STRING(skb, IFLA_ET_DRVINFO_FW_VERSION,
+			       info.fw_version);
+
+	if (info.bus_info[0])
+		NLA_PUT_STRING(skb, IFLA_ET_DRVINFO_BUS_INFO, info.bus_info);
+
+	nla_nest_end(skb, attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, attr);
+	return -EMSGSIZE;
+}
+
+static const struct {
+	int (*fill)(struct sk_buff *, struct net_device *);
+	size_t (*size)(const struct net_device *);
+} nl_ops[IFLA_ETHTOOL_MAX+1] = {
+	[IFLA_ETHTOOL_SETTINGS] = { .fill	= settings_fill,
+				    .size	= settings_size, },
+	[IFLA_ETHTOOL_DRVINFO] = {  .fill	= drvinfo_fill,
+				    .size	= drvinfo_size, },
+};
+
+size_t ethtool_nlattr_size(const struct net_device *dev)
+{
+	size_t size = 0;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(nl_ops); i++)
+		if (nl_ops[i].size)
+			size += nl_ops[i].size(dev);
+
+	/* IFLA_ETHTOOL */
+	return nla_total_size(size);
+}
+
+int ethtool_fill_nlattr(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nlattr *attr;
+	int err, i;
+
+	if (!(attr = nla_nest_start(skb, IFLA_ETHTOOL)))
+		return -EMSGSIZE;
+
+	for (i = 0; i < ARRAY_SIZE(nl_ops); i++) {
+		if (nl_ops[i].fill)
+			if ((err = nl_ops[i].fill(skb, dev)) < 0)
+				goto nla_put_failure;
+	}
+	
+	nla_nest_end(skb, attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, attr);
+	return err;
+}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index abd936d..684a0e1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -42,6 +42,7 @@
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -761,7 +762,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + ethtool_nlattr_size(dev); /* IFLA_ETHTOOL */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -989,6 +991,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	nla_nest_end(skb, af_spec);
 
+	if (ethtool_fill_nlattr(skb, dev) < 0)
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
