From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 2/2] ovs/gre: fix rtnl notifications on iface deletion
Date: Fri, 10 Jun 2016 10:50:49 -0700
Message-ID: <CAOrHB_C67L7vs_KvAzixaWe9_ZLjB+wuiBt0fBy0ix1gSUw=ww@mail.gmail.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com> <1465551147-17185-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:42042 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbcFJRuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 13:50:54 -0400
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 032B2C5A51
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:50:53 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id OMfyClNxs2Po for <netdev@vger.kernel.org>;
	Fri, 10 Jun 2016 19:50:51 +0200 (CEST)
Received: from mail-it0-f48.google.com (mail-it0-f48.google.com [209.85.214.48])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 5B5A4C5A54
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:50:51 +0200 (CEST)
Received: by mail-it0-f48.google.com with SMTP id e5so1442845ith.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 10:50:51 -0700 (PDT)
In-Reply-To: <1465551147-17185-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 2:32 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> The function gretap_fb_dev_create() (only used by ovs) never calls
> rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
> never set to RTNL_LINK_INITIALIZED.
> During the deletion phase, the function rollback_registered_many() sends
> a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.
>
> Fixes: b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of vport")
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv4/ip_gre.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 4d2025f7ec57..c6a46ee87a3a 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1146,6 +1146,10 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
>         if (err)
>                 goto out;
>
> +       err = rtnl_configure_link(dev, NULL);
> +       if (err < 0)
> +               goto out;
> +

As the first patch, similar issue exist here. But existing error
handling code already is buggy.

>         return dev;
>  out:
>         free_netdev(dev);
> --
> 2.4.2
>
