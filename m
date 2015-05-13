From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v4] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Wed, 13 May 2015 14:24:18 +0200
Message-ID: <20150513122418.GA2138@nanopsycho.mtl.com>
References: <20150512161402.GC2081@nanopsycho>
 <1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36586 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934103AbbEMMY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 08:24:26 -0400
Received: by wgbhc8 with SMTP id hc8so8124231wgb.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 05:24:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 13, 2015 at 02:19:42PM CEST, nicolas.dichtel@6wind.com wrote:
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
>The patch fixes the spotted bug by checking in bond driver if the interface
>is registered before calling the notifier chain.
>It also adds a check in rtmsg_ifinfo() to prevent this kind of bug in the
>future.
>
>Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
>CC: Jiri Pirko <jiri@resnulli.us>
>Reported-by: Julien Meunier <julien.meunier@6wind.com>
>Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>---
>
>v4: keep the call to the notifier chain
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
> net/core/rtnetlink.c               | 3 +++
> 2 files changed, 4 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 4df28943d222..e8d3c1d35453 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -624,7 +624,7 @@ int __bond_opt_set(struct bonding *bond,
> out:
> 	if (ret)
> 		bond_opt_error_interpret(bond, opt, ret, val);
>-	else
>+	else if (bond->dev->reg_state == NETREG_REGISTERED)
> 		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
> 
> 	return ret;
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

This is redundant now that you check it in __bond_opt_set.

Sorry to be a pain Nicolas :/
