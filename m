From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] Netlink messages for multicast HW addr programming
Date: Thu, 21 Jan 2016 21:04:19 +0100
Message-ID: <20160121200419.GB2251@nanopsycho.orion>
References: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick Ruddy <pruddy@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37710 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbcAUUEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 15:04:23 -0500
Received: by mail-wm0-f43.google.com with SMTP id n5so98874298wmn.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 12:04:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 21, 2016 at 12:47:54PM CET, pruddy@brocade.com wrote:
>Add RTM_NEWADDR and RTM_DELADDR netlink messages to indicate
>interest in specific multicast hardware addresses. These messages
>are sent when addressed are added or deleted from the appropriate
>interface driver.
>
>Signed-off-by: Patrick Ruddy <pruddy@brocade.com>
>
>diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
>index c0548d2..a0ebadd 100644
>--- a/net/core/dev_addr_lists.c
>+++ b/net/core/dev_addr_lists.c
>@@ -12,6 +12,7 @@
>  */
> 
> #include <linux/netdevice.h>
>+#include <net/netlink.h>
> #include <linux/rtnetlink.h>
> #include <linux/export.h>
> #include <linux/list.h>
>@@ -661,6 +662,62 @@ out:
> }
> EXPORT_SYMBOL(dev_mc_add_excl);
> 
>+static int fill_addr(struct sk_buff *skb, struct net_device *dev,
>+		     const unsigned char *addr, int type)
>+{
>+	struct nlmsghdr *nlh;
>+	struct ifaddrmsg *ifm;
>+
>+	nlh = nlmsg_put(skb, 0, 0, type, sizeof(*ifm), 0);
>+	if (nlh == NULL)
>+		return -EMSGSIZE;
>+
>+	ifm = nlmsg_data(nlh);
>+	ifm->ifa_family = AF_UNSPEC;
>+	ifm->ifa_prefixlen = 0;
>+	ifm->ifa_flags = IFA_F_PERMANENT;
>+	ifm->ifa_scope = RT_SCOPE_LINK;
>+	ifm->ifa_index = dev->ifindex;
>+	if (nla_put(skb, IFA_ADDRESS, dev->addr_len, addr))
>+		goto nla_put_failure;
>+	nlmsg_end(skb, nlh);

How can userspace tell if this is a multicast addr? Also, why not add
notifications for unicast addrs so we handle both the same?
