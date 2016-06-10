From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 1/2] ovs/vxlan: fix rtnl notifications on iface deletion
Date: Fri, 10 Jun 2016 10:50:35 -0700
Message-ID: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:47156 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbcFJRuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 13:50:40 -0400
Received: from mfilter37-d.gandi.net (mfilter37-d.gandi.net [217.70.178.168])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id A2357FB886
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:50:38 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter37-d.gandi.net (mfilter37-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 38I54coUO9gW for <netdev@vger.kernel.org>;
	Fri, 10 Jun 2016 19:50:37 +0200 (CEST)
Received: from mail-it0-f54.google.com (mail-it0-f54.google.com [209.85.214.54])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 31F60FB881
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:50:37 +0200 (CEST)
Received: by mail-it0-f54.google.com with SMTP id h190so1405778ith.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 10:50:37 -0700 (PDT)
In-Reply-To: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 2:32 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> The function vxlan_dev_create() (only used by ovs) never calls
> rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
> never set to RTNL_LINK_INITIALIZED.
> During the deletion phase, the function rollback_registered_many() sends
> a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.
>
> Fixes: dcc38c033b32 ("openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN")
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  drivers/net/vxlan.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index f999db2f97b4..f7669d60b3f7 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2972,6 +2972,12 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
>                 return ERR_PTR(err);
>         }
>
> +       err = rtnl_configure_link(dev, NULL);
> +       if (err < 0) {
> +               free_netdev(dev);
> +               return ERR_PTR(err);
> +       }
> +
Patch looks good except the error handling code. earlier call to
vxlan_dev_configure() registers the net-device  and add the device to
vxlan device list. it needs to be undone before freeing the device.
