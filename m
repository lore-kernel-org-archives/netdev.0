From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network drivers
Date: Wed, 6 Jan 2016 16:18:30 -0800
Message-ID: <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org> <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:47109 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbcAGASr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 19:18:47 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 00F652015E
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 00:18:46 +0000 (UTC)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1C36D20108
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 00:18:45 +0000 (UTC)
Received: by mail-qg0-f50.google.com with SMTP id b35so186335931qge.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 16:18:45 -0800 (PST)
In-Reply-To: <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 3:39 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/geneve.c | 30 +++++++++++++++++++++++++++---
>  include/net/geneve.h |  7 +++----
>  2 files changed, 30 insertions(+), 7 deletions(-)

Thanks a lot for going through all the drivers! You found more things
than I thought. I noticed just a couple new things with this version
but overall I think it is a good direction.

> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 24b077a32c1c9c..5b8d728b1204be 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1110,7 +1110,7 @@ static struct device_type geneve_type = {
>   * supply the listening GENEVE udp ports. Callers are expected
>   * to implement the ndo_add_geneve_port.
>   */
> -void geneve_get_rx_port(struct net_device *dev)
> +static void geneve_notify_refresh_netdev(struct net_device *dev)
>  {
>         struct net *net = dev_net(dev);
>         struct geneve_net *gn = net_generic(net, geneve_net_id);

Both this function and the corresponding one in VXLAN assume that the
add port NDO is implemented and blindly dereference the pointer. Now
that all protocols get refreshed at the same time, we should check
first. There's also a comment above the function that says this, which
we can remove now.

I also think we can update the comments in netdevice.h for the
VXLAN/Geneve add/remove NDOs to say that they are protected by RTNL.

> diff --git a/include/net/geneve.h b/include/net/geneve.h
> index e6c23dc765f7ec..7d52077b72faa3 100644
> --- a/include/net/geneve.h
> +++ b/include/net/geneve.h
> -#if IS_ENABLED(CONFIG_GENEVE)
> -void geneve_get_rx_port(struct net_device *netdev);
> -#else
>  static inline void geneve_get_rx_port(struct net_device *netdev)
>  {
> +       call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
>  }
> -#endif

I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
into a single generic function. For drivers that support both, they
now have two calls to get notified for all offloaded ports. This
actually can cause problems related to duplicates, similar to what you
feared before.
