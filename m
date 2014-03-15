From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v3] net: phy: fix uninitalized WOL parameters in phy_ethtool_get_wol
Date: Sat, 15 Mar 2014 11:01:10 +0100
Message-ID: <532424E6.3000706@gmail.com>
References: <1394484661-4554-2-git-send-email-sebastian.hesselbarth@gmail.com> <1394578975-12588-1-git-send-email-sebastian.hesselbarth@gmail.com> <20140313.153832.967564223480298567.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, ben@decadent.org.uk, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:43167 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894AbaCOKBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 06:01:16 -0400
In-Reply-To: <20140313.153832.967564223480298567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2014 08:38 PM, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Wed, 12 Mar 2014 00:02:55 +0100
[...]
>> To fix this, always zero relevant fields of struct ethtool_wolinfo
>> regardless of .get_wol callback availability.
[...]
> I'm starting to see this situation more clearly now, especially with
> Ben's most recent commentary.
>
> The basic notion is that one must do ethtool ops are designed such that
> the top-level execution context in net/core/ethtool.c takes care of
> initializing the structure.
>
> In this case, we're referring specifically to ethtool_get_wol(), which
> runs any time ETHTOOL_GWOL is requested.
>
> Therefore no ethtool_ops->get_wol() implementation should duplicate
> this work, that goes for all of such cases which invoke the function
> we are talking about here, phy_ethtool_get_wol().
>
> So the first change is definitely to remove:
>
> 	wol->supported = 0;
> 	wol->wolopts = 0;
>
> from:
>
> drivers/net/ethernet/marvell/mv643xx_eth.c:mv643xx_eth_get_wol()
> drivers/net/ethernet/ti/cpsw.c:cpsw_get_wol()
>
[...]
>
> Finally, purge the spurious clears in phydev_ops->get_wol(), namely
> in at803x_get_wol() and m88e1318_get_wol().

David,

I was preparing cleanups for mv643xx_eth, cpsw, at803x, and mv88e1318.

Out of curiosity, I did a

git grep "wol->" drivers/net/ | grep "= 0" | wc -l
29

and found some other "spurious clears" ;)

I can go that road and remove/rework all those clears. Some are really
easy, some would require some more rework (e.g. e1000).

Of course, a lot of those drivers then will need a Tested-by, as I
don't have the HW available.

> So, to reiterate, OPS never have to be mindful of initializing the
> ethtool result with zeros.  However, anyone who calls into OPS
> directly must provide said expected state.

Sebastian
