From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Wed, 28 Nov 2007 16:02:29 -0600
Message-ID: <cccedfc60711281402m397a37d2mda83645211633202@mail.gmail.com>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	 <20071115082600.GA2366@ff.dom.local>
	 <20071115102005.0cf46f9a@freepuppy.rosehill> <473CD1F6.9030709@o2.pl>
	 <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
	 <20071115203508.4ad025f2@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:21213 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758701AbXK1WCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:02:54 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1574419nfb
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2007 14:02:30 -0800 (PST)
In-Reply-To: <20071115203508.4ad025f2@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a reminder: the following fix should (IMO) be considered for
2.6.24. The first patch does indeed fix the OOPS on MTU however
subsequent MTU changes still OOPS. The below fixes that. I've been
using both patches for over a week and they work just great. I noticed
that the first fix made 2.6.24 but this one hadn't -  I just want to
try to make sure 2.6.24 doesn't make things /worse/ for via-velocity
owners instead of better.

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Does this fix the problem.
>
> Note: reading the code the driver has other problems (besides crappy
> style). It does pci_map_single()/unmap in a way that doesn't account
> correctly for the padding that was added.
>
> --- a/drivers/net/via-velocity.c        2007-11-15 20:11:12.000000000 -0800
> +++ b/drivers/net/via-velocity.c        2007-11-15 20:32:14.000000000 -0800
> @@ -1242,6 +1242,9 @@ static int velocity_rx_refill(struct vel
>  static int velocity_init_rd_ring(struct velocity_info *vptr)
>  {
>         int ret;
> +       int mtu = vptr->dev->mtu;
> +
> +       vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
>
>         vptr->rd_info = kcalloc(vptr->options.numrx,
>                                 sizeof(struct velocity_rd_info), GFP_KERNEL);
> @@ -1898,8 +1901,6 @@ static int velocity_open(struct net_devi
>         struct velocity_info *vptr = netdev_priv(dev);
>         int ret;
>
> -       vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
> -
>         ret = velocity_init_rings(vptr);
>         if (ret < 0)
>                 goto out;
> @@ -1978,12 +1979,6 @@ static int velocity_change_mtu(struct ne
>                 velocity_free_rd_ring(vptr);
>
>                 dev->mtu = new_mtu;
> -               if (new_mtu > 8192)
> -                       vptr->rx_buf_sz = 9 * 1024;
> -               else if (new_mtu > 4096)
> -                       vptr->rx_buf_sz = 8192;
> -               else
> -                       vptr->rx_buf_sz = 4 * 1024;
>
>                 ret = velocity_init_rd_ring(vptr);
>                 if (ret < 0)

-- 
Jon
