From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] Netlink messages for multicast HW addr programming
Date: Sat, 23 Jan 2016 08:53:31 +0100
Message-ID: <20160123075331.GA2193@nanopsycho.orion>
References: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
 <20160121200419.GB2251@nanopsycho.orion>
 <1453474315.20378.7.camel@brocade.com>
 <20160122150508.GD2211@nanopsycho.orion>
 <1453477775.20378.15.camel@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stapleton <dstaplet@Brocade.com>,
	Olufemi Komolafe <okomolaf@Brocade.com>,
	Stephen Hemminger <shemming@Brocade.com>
To: Patrick Ruddy <pruddy@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33525 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcAWHxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 02:53:34 -0500
Received: by mail-wm0-f66.google.com with SMTP id u188so1838334wmu.0
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 23:53:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1453477775.20378.15.camel@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 22, 2016 at 04:49:36PM CET, pruddy@Brocade.com wrote:
>On Fri, 2016-01-22 at 16:05 +0100, Jiri Pirko wrote:
>> Fri, Jan 22, 2016 at 03:51:55PM CET, pruddy@Brocade.com wrote:
>> >On Thu, 2016-01-21 at 21:04 +0100, Jiri Pirko wrote:
>> >> Thu, Jan 21, 2016 at 12:47:54PM CET, pruddy@brocade.com wrote:
>> >> >Add RTM_NEWADDR and RTM_DELADDR netlink messages to indicate
>> >> >interest in specific multicast hardware addresses. These messages
>> >> >are sent when addressed are added or deleted from the appropriate
>> >> >interface driver.
>> >> >
>> >> >Signed-off-by: Patrick Ruddy <pruddy@brocade.com>
>> >> >
>> >> >diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
>> >> >index c0548d2..a0ebadd 100644
>> >> >--- a/net/core/dev_addr_lists.c
>> >> >+++ b/net/core/dev_addr_lists.c
>> >> >@@ -12,6 +12,7 @@
>> >> >  */
>> >> > 
>> >> > #include <linux/netdevice.h>
>> >> >+#include <net/netlink.h>
>> >> > #include <linux/rtnetlink.h>
>> >> > #include <linux/export.h>
>> >> > #include <linux/list.h>
>> >> >@@ -661,6 +662,62 @@ out:
>> >> > }
>> >> > EXPORT_SYMBOL(dev_mc_add_excl);
>> >> > 
>> >> >+static int fill_addr(struct sk_buff *skb, struct net_device *dev,
>> >> >+		     const unsigned char *addr, int type)
>> >> >+{
>> >> >+	struct nlmsghdr *nlh;
>> >> >+	struct ifaddrmsg *ifm;
>> >> >+
>> >> >+	nlh = nlmsg_put(skb, 0, 0, type, sizeof(*ifm), 0);
>> >> >+	if (nlh == NULL)
>> >> >+		return -EMSGSIZE;
>> >> >+
>> >> >+	ifm = nlmsg_data(nlh);
>> >> >+	ifm->ifa_family = AF_UNSPEC;
>> >> >+	ifm->ifa_prefixlen = 0;
>> >> >+	ifm->ifa_flags = IFA_F_PERMANENT;
>> >> >+	ifm->ifa_scope = RT_SCOPE_LINK;
>> >> >+	ifm->ifa_index = dev->ifindex;
>> >> >+	if (nla_put(skb, IFA_ADDRESS, dev->addr_len, addr))
>> >> >+		goto nla_put_failure;
>> >> >+	nlmsg_end(skb, nlh);
>> >> 
>> >> How can userspace tell if this is a multicast addr? Also, why not add
>> >> notifications for unicast addrs so we handle both the same?
>> >
>> >I am only using this RTM_NEW/DELADDR AF_UNSPEC message for multicast
>> >addresses. I understand that the unicast addresses are notified in the
>> >RTM_NEW/DELLINK.
>> 
>> dev->dev_addr is notified by that. UC addresses do not have any
>> notification now.
>It is the multicast MAC address (ie the multicast equivalent of the
>dev_addr) that we are notifying here right? Not L3 addresses.

I know :)

For example if kernel code calls dev_uc_add or dev_uc_del, thise
addresses are not notified to the userspace. All I'm saying is, if you
add notification for dev_mc_add and dev_mc_del, add it for uc variants
as well. Then you have to distinguish mc and uc in the netlink message.

>
>-pr
>
