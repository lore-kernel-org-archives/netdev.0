From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Thu, 11 Aug 2016 11:24:18 -0700
Message-ID: <20160811182418.GC25877@cork>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com>
 <20160809180830.GM22974@cork>
 <20160809.120636.2039586307820412288.davem@davemloft.net>
 <20160809211058.GP22974@cork>
 <20075.1470786664@famine>
 <20160810212649.GD5019@cork>
 <20160810220055.GE5019@cork>
 <935.1470877118@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, dingtianhong@huawei.com,
	zyjzyj2000@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34154 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcHKSY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 14:24:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id fi15so957489pac.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 11:24:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <935.1470877118@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 05:58:38PM -0700, Jay Vosburgh wrote:
> Jörn Engel <joern@purestorage.com> wrote:
> >On Wed, Aug 10, 2016 at 02:26:49PM -0700, Jörn Engel wrote:
> >> 
> >> Having to set one more parameter is a bit annoying.  It would have to be
> >> documented in a prominent place and people would still often miss it.
> >> So I wonder if we can make the interface a little nicer.
> >> 
> >> Options:
> >> - If there are no slaves yet and the first slave added is tun, we trust
> >>   the users to know what they are doing.  Automatically set
> >>   bond->params.fail_over_mac = BOND_FOM_KEEPMAC
> >>   Maybe do a printk to inform the user in case of a mistake.
> 
> 	I don't think this is feasible, as I don't see a reliable way to
> test for a slave being a tun device (ARPHRD_NONE is not just tun, and we
> cannot check the ops as they are not statically built into the kernel).
> I'm also not sure that heuristics are the proper way to enable this
> functionality in general.

I was looking for a slightly more generic thing than "is this device
tun?".  Something along the lines of "is this device L3 only?".  We can
always introduce a new flag and have tun set the flag.  Naïve me thought
ARPHRD_NONE might already match what I was looking for.

But if such an approach causes problems for others, it is a non-starter.

> >> - If we get an error and the slave device is tun, do a printk giving the
> >>   user enough information to find this parameter.
> 
> 	This could probably be done as a change the existing logic, e.g.,
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 1f276fa30ba6..019c1a689aae 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1443,6 +1443,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  				res = -EOPNOTSUPP;
>  				goto err_undo_flags;
>  			}
> +		} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP &&
> +			   bond->params.fail_over_mac != BOND_FOM_KEEPMAC) {
> +				netdev_err(bond_dev, "The slave device specified does not support setting the MAC address, but fail_over_mac is not set to keepmac\n");
>  		}
>  	}
>  
> 	I haven't tested this, and I'm not sure it will get all corner
> cases correct, but this should basically cover it.

Nit: Indentation is wrong (two tabs instead of one).

It should provide enough information for anyone that reads kernel messages.
Works for me.

[588380.721349] bond1: Adding slave tun0
[588380.721402] bond1: The slave device specified does not support setting the MAC address
[588380.721404] bond1: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to keepmac

Jörn
