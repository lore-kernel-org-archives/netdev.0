From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] net: phy: micrel: fix crash when statistic requested
 for KSZ9031 phy
Date: Thu, 13 Apr 2017 21:36:08 +0200
Message-ID: <20170413193608.GE26229@lunn.ch>
References: <20170413191127.5406-1-grygorii.strashko@ti.com>
 <f14be9f1-1460-57a4-c255-94894ec50dcc@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f14be9f1-1460-57a4-c255-94894ec50dcc@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 10:28:09PM +0300, Sergei Shtylyov wrote:
> On 04/13/2017 10:11 PM, Grygorii Strashko wrote:
> 
> >Now the command:
> >	ethtool --phy-statistics eth0
> >will cause system crash with meassage "Unable to handle kernel NULL pointer
> >dereference at virtual address 00000010" from:
> >
> > (kszphy_get_stats) from [<c069f1d8>] (ethtool_get_phy_stats+0xd8/0x210)
> > (ethtool_get_phy_stats) from [<c06a0738>] (dev_ethtool+0x5b8/0x228c)
> > (dev_ethtool) from [<c06b5484>] (dev_ioctl+0x3fc/0x964)
> > (dev_ioctl) from [<c0679f7c>] (sock_ioctl+0x170/0x2c0)
> > (sock_ioctl) from [<c02419d4>] (do_vfs_ioctl+0xa8/0x95c)
> > (do_vfs_ioctl) from [<c02422c4>] (SyS_ioctl+0x3c/0x64)
> > (SyS_ioctl) from [<c0107d60>] (ret_fast_syscall+0x0/0x44)
> >
> >The reason: phy_driver structure for KSZ9031 phy has no .probe() callback
> >defined. As result, struct phy_device *phydev->priv pointer will not be
> >initializes (null).
> >This issue will affect also following phys:
> > KSZ8795, KSZ886X, KSZ8873MLL, KSZ9031, KSZ9021, KSZ8061, KS8737
> >
> >Fix it by:
> >- adding .probe() = kszphy_probe() callback to KSZ9031, KSZ9021
> >phys. The kszphy_probe() can be re-used as it doesn't do any phy specific
> >settings.
> >- removing statistic callbacks from other phys (KSZ8795, KSZ886X,
> >KSZ8873MLL, KSZ8061, KS8737) as they doesn't have corresponding
> >statistic counters.
> 
>    Not sure how the 2nd change fixes the reported issue. It looks
> like a material for a separate patch...

There are two different cases here:

1) The hardware supports the stats. So a probe function is needed, but
is missing.

2) The hardware does not support the stats, so there should not be
stats ops.

The same crash will happen, independent of which one of the above is
true. You need to fix them both, to stop it crashing.

      Andrew
