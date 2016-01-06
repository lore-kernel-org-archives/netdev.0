From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 2/2] geneve: break dependency to network drivers
Date: Wed, 6 Jan 2016 10:00:21 -0800
Message-ID: <CAEh+42j2w6t7+WNN9y0k6M5Ld+14B2txCkfLw6zwrR04+i8Xqw@mail.gmail.com>
References: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org> <1452094903-12934-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55652 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605AbcAFSAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 13:00:38 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id DF1CA20148
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:00:37 +0000 (UTC)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CC14A2011E
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:00:36 +0000 (UTC)
Received: by mail-qk0-f177.google.com with SMTP id q19so99891161qke.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 10:00:36 -0800 (PST)
In-Reply-To: <1452094903-12934-3-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 7:41 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 24b077a32c1c9c..548925d1571cb1 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> +static int geneve_notifier(struct notifier_block *unused,
> +                          unsigned long event, void *ptr)
> +{
> +       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> +
> +       switch (event) {
> +       case NETDEV_REFRESH_OFFLOAD_VXLAN:
> +               geneve_notify_refresh_netdev(dev);

Presumably this should be NETDEV_REFRESH_OFFLOAD_GENEVE, not VXLAN.
However, rather than having a notifier for each protocol, it seems
like it might be cleaner to just have a single one that triggers for
all protocols and drivers that don't have the corresponding NDO
wouldn't get called, similar to what happens when the port gets added
in the first place.

> diff --git a/include/net/geneve.h b/include/net/geneve.h
> index e6c23dc765f7ec..36245115143652 100644
> --- a/include/net/geneve.h
> +++ b/include/net/geneve.h
[...]
>  static inline void geneve_get_rx_port(struct net_device *netdev)
>  {
> +       call_netdevice_notifiers(NETDEV_REFRESH_OFFLOAD_GENEVE, netdev);
>  }

Unfortunately, I don't think that we can assume that RTNL is held
here. It actually is for the drivers that implement Geneve at this
point but not in all cases for VXLAN. For example, ixgbe refreshes the
offloads in a service task in addition to when it is opened. There's
only a couple instances of things like this, so I guess it's probably
not too hard to through and make sure that we hold RTNL in those
cases.
