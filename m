From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Tue, 15 Jun 2010 11:39:26 +0200
Message-ID: <20100615113926.30d0cd01@dhcp-lab-109.englab.brq.redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
	<20100603034312.5305.61000.sendpatchset@localhost.localdomain>
	<1275568622.2870.89.camel@localhost>
	<4C085D45.6040001@redhat.com>
	<1275661552.2095.13.camel@achroite.uk.solarflarecom.com>
	<4C0F5D97.5030605@redhat.com>
	<20100609104950.GB2599@dhcp-lab-161.englab.brq.redhat.com>
	<4C173F87.7000704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	herbert.xu@redhat.com, nhorman@redhat.com, davem@davemloft.net
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab0FOJjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 05:39:36 -0400
In-Reply-To: <4C173F87.7000704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jun 2010 16:53:27 +0800
Cong Wang <amwang@redhat.com> wrote:

> > If so, it's better to stop device before modify LRO settings. I suggest
> > something like that in mlx4_ethtool_op_set_flags:
> >
> > if (!!(data&  ETH_FLAG_LRO) != !!(dev->features&  NETIF_F_LRO)) {
>
> What does this line mean? This is to ignore all other flags, right?

Yes, plus check if we are really changing current settings.
 
> > 	/* Need to toggle LRO */
> >
> > 	if (netdev_running(dev)) {
> >                 mutex_lock(&mdev->state_lock);
> >                 mlx4_en_stop_port(dev);
> >                 rc = mlx4_en_start_port(dev);
> >                 if (rc)
> >                         en_err(priv, "Failed to restart port\n");
> > 	}
> >
> > 	dev->features ^= NETIF_F_LRO;
> >
> > 	if (netdev_running(dev))
> >                 mutex_unlock(&mdev->state_lock);
> > }
> >
> 
> I don't think mdev->state_lock is used to protect dev->feature.
> rtnl_lock is. I think switching to mlx4_ethtool_op_set_flags()
> from the default one has already solved this.

Ahh, you have right, may intention was use it to stop and start
port. Code rather should look like below:

	if (netdev_running(dev)) {
		mutex_lock(&mdev->state_lock);
		mlx4_en_stop_port(dev);
	}

	dev->features ^= NETIF_F_LRO;

	if (netdev_running(dev)) {
		rc = mlx4_en_start_port(dev);
		mutex_unlock(&mdev->state_lock);
 		if (rc)
		en_err(priv, "Failed to restart port\n");
	}

Stanislaw
