From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Bpqether broken in 4.1
Date: Thu, 2 Jul 2015 23:55:54 +0200
Message-ID: <20150702215553.GB20390@linux-mips.org>
References: <20150702183836.GA20390@linux-mips.org>
 <873816e0hg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	Steven Whitehouse <swhiteho@redhat.com>,
	Richard Stearn <richard@rns-stearn.demon.co.uk>,
	f6bvp <f6bvp@free.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:41824 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27012810AbbGBV4ALbNh8 (ORCPT <rfc822;netdev@vger.kernel.org>
        + 1 other); Thu, 2 Jul 2015 23:56:00 +0200
Content-Disposition: inline
In-Reply-To: <873816e0hg.fsf@x220.int.ebiederm.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 02, 2015 at 04:03:07PM -0500, Eric W. Biederman wrote:

> > Eric's Commit 1d5da757da860a6916adbf68b09e868062b4b3b8 (ax25: Stop using
> > magic neighbour cache operations.) breaks IP traffic over the AX.25 bpqether
> > driver.
> 
> Sigh.  NETIF_F_LLTX is not set so recursion does not work :(
> 
> So we can either set NETIF_F_LLTX or just rever the offending commit.

The AX.25 stack has a sufficient number of hacks that attempts to fix
any hack is likely to cause issues somewhere else and the header and
neighbour stuff is the worst minefield.  I'm happy that your patch at
least concentrates all those hacks in the AX.25 stack itself removing
the impact from the generic networking code.

> I think either will work.  ax25 is so very weird it just abuses the
> neighbour table something awful.  It ax25 is not caching ip address to
> ax25 address translations in there, ax25 should really not be using the
> neighbour table.  Sigh.
> 
> So perhaps something like the below will be good enough.
> 
> diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
> index 63ff08a26da8..fc2be36c9425 100644
> --- a/drivers/net/hamradio/bpqether.c
> +++ b/drivers/net/hamradio/bpqether.c
> @@ -483,6 +483,7 @@ static void bpq_setup(struct net_device *dev)
>         memcpy(dev->dev_addr,  &ax25_defaddr, AX25_ADDR_LEN);
>  
>         dev->flags      = 0;
> +       dev->features   = NETIF_F_LLTX; /* Allow recursion */
>  
>  #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
>         dev->header_ops      = &ax25_header_ops;

Thanks, that restored bpqether to work.  I will cook up a patch to fix
all other AX.25 drivers.

Thanks!

  Ralf
