From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 17:37:49 +0200
Message-ID: <20110831173749.60649b50@alice>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
	<201108311501.39936.vladz@broadcom.com>
	<20110831155324.7554d035@alice>
	<201108311807.53767.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Vlad Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756264Ab1HaPhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:37:53 -0400
In-Reply-To: <201108311807.53767.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 18:07:53 +0300 Vlad Zolotarov wrote:
> If u want to change the implementation the way we rely on the
> dev->features in the ndo_set_features() flow, which is a semantics
> change, u'd rather change the __netdev_update_features() so that it
> sets the dev->features before ndo_set_features() call and restores it
> in case of a failure. Something like this:

...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b2e262e..474e539 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5321,7 +5321,7 @@ static u32 netdev_fix_features(struct
> net_device *dev, u32 features) 
>  int __netdev_update_features(struct net_device *dev)
>  {
> -       u32 features;
> +       u32 features, old_features;
>         int err = 0;
>  
>         ASSERT_RTNL();
> @@ -5340,19 +5340,23 @@ int __netdev_update_features(struct
> net_device *dev) netdev_dbg(dev, "Features changed: 0x%08x ->
> 0x%08x\n", dev->features, features);
>  
> +       /* Remember the original features and set the new ones */
> +       old_features = dev->features;
> +       dev->features = features;
> +
>         if (dev->netdev_ops->ndo_set_features)
> -               err = dev->netdev_ops->ndo_set_features(dev,
> features);
> +               err = dev->netdev_ops->ndo_set_features(dev);

Drivers want to know which features changed. They compare
the features argument with dev->features.
Perhaps we could pass old_features as the argument. Then we'd better
change the name of the callback to avoid confusion.

I think it's not worth changing. I could restore dev->features before
returning if bnx2x_reload_if_running() fails.

Michal
