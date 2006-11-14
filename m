From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] iflink: Convert IPv6's RTM_GETLINK to use the new netlink api
Date: Tue, 14 Nov 2006 15:27:14 +0100
Message-ID: <20061114142714.GR8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42174 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965862AbWKNO0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 09:26:54 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By replacing the current method of exporting the device configuration
which included allocating a temporary buffer, copying ipv6_devconf
into it and copying that buffer into the message with a method that
uses nla_reserve() allowing to copy the device configuration directly
into the skb data buffer, a GFP_ATOMIC allocation could be removed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/ipv6/addrconf.c
===================================================================
--- net-2.6.20.orig/net/ipv6/addrconf.c	2006-11-14 11:52:24.000000000 +0100
+++ net-2.6.20/net/ipv6/addrconf.c	2006-11-14 12:51:56.000000000 +0100
@@ -3360,6 +3360,8 @@
 static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
 				__s32 *array, int bytes)
 {
+	BUG_ON(bytes < (DEVCONF_MAX * 4));
+
 	memset(array, 0, bytes);
 	array[DEVCONF_FORWARDING] = cnf->forwarding;
 	array[DEVCONF_HOPLIMIT] = cnf->hop_limit;
@@ -3409,66 +3411,59 @@
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
-	struct net_device	*dev = idev->dev;
-	__s32			*array = NULL;
-	struct ifinfomsg	*r;
-	struct nlmsghdr 	*nlh;
-	unsigned char		*b = skb->tail;
-	struct rtattr		*subattr;
-	__u32			mtu = dev->mtu;
-	struct ifla_cacheinfo	ci;
-
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
-	r = NLMSG_DATA(nlh);
-	r->ifi_family = AF_INET6;
-	r->__ifi_pad = 0;
-	r->ifi_type = dev->type;
-	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev_get_flags(dev);
-	r->ifi_change = 0;
+	struct net_device *dev = idev->dev;
+	struct nlattr *conf;
+	struct ifinfomsg *hdr;
+	struct nlmsghdr *nlh;
+	void *protoinfo;
+	struct ifla_cacheinfo ci;
+
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	hdr = nlmsg_data(nlh);
+	hdr->ifi_family = AF_INET6;
+	hdr->__ifi_pad = 0;
+	hdr->ifi_type = dev->type;
+	hdr->ifi_index = dev->ifindex;
+	hdr->ifi_flags = dev_get_flags(dev);
+	hdr->ifi_change = 0;
 
-	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 
 	if (dev->addr_len)
-		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
+		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 
-	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
+	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
 	if (dev->ifindex != dev->iflink)
-		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
-			
-	subattr = (struct rtattr*)skb->tail;
+		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
 
-	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
+	protoinfo = nla_nest_start(skb, IFLA_PROTINFO);
+	if (protoinfo == NULL)
+		goto nla_put_failure;
 
-	/* return the device flags */
-	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
+	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
 
-	/* return interface cacheinfo */
 	ci.max_reasm_len = IPV6_MAXPLEN;
 	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
 		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
 	ci.reachable_time = idev->nd_parms->reachable_time;
 	ci.retrans_time = idev->nd_parms->retrans_time;
-	RTA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
-	
-	/* return the device sysctl params */
-	if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_ATOMIC)) == NULL)
-		goto rtattr_failure;
-	ipv6_store_devconf(&idev->cnf, array, DEVCONF_MAX * sizeof(*array));
-	RTA_PUT(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(*array), array);
+	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
+
+	conf = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
+	if (conf == NULL)
+		goto nla_put_failure;
+	ipv6_store_devconf(&idev->cnf, nla_data(conf), nla_len(conf));
 
 	/* XXX - Statistics/MC not implemented */
-	subattr->rta_len = skb->tail - (u8*)subattr;
 
-	nlh->nlmsg_len = skb->tail - b;
-	kfree(array);
-	return skb->len;
+	nla_nest_end(skb, protoinfo);
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	kfree(array);
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
