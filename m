From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v3] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Tue, 12 May 2015 17:58:42 +0200
Message-ID: <20150512155842.GA2081@nanopsycho>
References: <555216DA.3020105@6wind.com>
 <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36149 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbbELP6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:58:49 -0400
Received: by wggj6 with SMTP id j6so15121371wgg.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:58:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 12, 2015 at 05:17:45PM CEST, nicolas.dichtel@6wind.com wrote:
>Before the patch, the command 'ip link add bond2 type bond mode 802.3ad'
>causes the kernel to send a rtnl message for the bond2 interface, with an
>ifindex 0.
>
>'ip monitor' shows:
>0: bond2: <BROADCAST,MULTICAST,MASTER> mtu 1500 state DOWN group default
>    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>9: bond2@NONE: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN group default
>    link/ether ea:3e:1f:53:92:7b brd ff:ff:ff:ff:ff:ff
>[snip]
>
>First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
>d4261e565000 says that it was put only to notify userspace). Hence, we can
>call directly rtmsg_ifinfo().

Please leave this notifier here. Will be needed in very near future for
LAG offloading purposes.



>Secondly, prevent in rtmsg_ifinfo() to send notifications to userspace
>about unregistered interfaces.

I'm not sure about this. Why caller of rtmsg_ifinfo don't take care of
it? Seems more logical to me.


>
>Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
>CC: Jiri Pirko <jiri@resnulli.us>
>Reported-by: Julien Meunier <julien.meunier@6wind.com>
>Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>---
>
>v3: move reg_state check in rtmsg_ifinfo()
>
>v2: check dev->reg_state instead of ifindex
>    call rtmsg_ifinfo() directly in __bond_opt_set()
>
>There is about 20 occurences of "dev->reg_state .= NETREG_REGISTERED".
>I will send a patch on net-next to introduce an helper for this when net
>will be merged with this patch in net-next.
>
> drivers/net/bonding/bond_options.c | 2 +-
> include/linux/netdevice.h          | 3 +--
> net/core/rtnetlink.c               | 3 +++
> 3 files changed, 5 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 4df28943d222..a2b72cc0e3e8 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -625,7 +625,7 @@ out:
> 	if (ret)
> 		bond_opt_error_interpret(bond, opt, ret, val);
> 	else
>-		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
>+		rtmsg_ifinfo(RTM_NEWLINK, bond->dev, 0, GFP_KERNEL);
> 
> 	return ret;
> }
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 1899c74a7127..c040d48925fd 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2069,8 +2069,7 @@ struct pcpu_sw_netstats {
> #define NETDEV_CHANGEUPPER	0x0015
> #define NETDEV_RESEND_IGMP	0x0016
> #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
>-#define NETDEV_CHANGEINFODATA	0x0018
>-#define NETDEV_BONDING_INFO	0x0019
>+#define NETDEV_BONDING_INFO	0x0018
> 
> int register_netdevice_notifier(struct notifier_block *nb);
> int unregister_netdevice_notifier(struct notifier_block *nb);
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index 837d30b5ffed..7b25f1ef3d75 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -2415,6 +2415,9 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
> {
> 	struct sk_buff *skb;
> 
>+	if (dev->reg_state != NETREG_REGISTERED)
>+		return;
>+
> 	skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
> 	if (skb)
> 		rtmsg_ifinfo_send(skb, dev, flags);
>-- 
>2.2.2
>
