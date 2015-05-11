From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 17:37:41 +0200
Message-ID: <20150511153741.GB2222@nanopsycho.mtl.com>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35379 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbbEKPhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:37:48 -0400
Received: by wgbhc8 with SMTP id hc8so31934589wgb.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 08:37:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 11, 2015 at 04:25:46PM CEST, nicolas.dichtel@6wind.com wrote:
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
>Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
>CC: Jiri Pirko <jiri@resnulli.us>
>Reported-by: Julien Meunier <julien.meunier@6wind.com>
>Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>---
> net/core/rtnetlink.c | 2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index 837d30b5ffed..721ca1b0e734 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -3273,6 +3273,8 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
> 	case NETDEV_BONDING_INFO:
> 		break;
> 	default:
>+		if (!dev->ifindex)
>+			break;

I don't think this is the correct way to fix this.

How ifindex can be 0 here? Ifindex is set in register_netdevice and
looking at bond_create, I don't see any call to __bond_opt_set before
that. But since it apparently is, the ordering should be changed so
register_netdevice is called first.
