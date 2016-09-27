From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Tue, 27 Sep 2016 07:42:13 -0400 (EDT)
Message-ID: <20160927.074213.1911582699641824555.davem@davemloft.net>
References: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932192AbcI0LmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 07:42:16 -0400
In-Reply-To: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 24 Sep 2016 12:58:30 -0700

> This reverts commit 62469c76007e ("net: ethernet: bcmgenet: use phydev
> from struct net_device") because it causes GENETv1/2/3 adapters to
> expose the following behavior after an ifconfig down/up sequence:
> 
> PING fainelli-linux (10.112.156.244): 56 data bytes
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.352 ms
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.472 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.496 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.517 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.536 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.557 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=752.448 ms (DUP!)
> 
> This was previously fixed by commit 5dbebbb44a6a ("net: bcmgenet:
> Software reset EPHY after power on") but the commit we are reverting was
> essentially making this previous commit void, here is why.
> 
> Without commit 62469c76007e we would have the following scenario after
> an ifconfig down then up sequence:
> 
> - bcmgenet_open() calls bcmgenet_power_up() to make sure the PHY is
>   initialized *before* we get to initialize the UniMAC, this is
>   critical to ensure the PHY is in a correct state, priv->phydev is
>   valid, this code executes fine
> 
> - second time from bcmgenet_mii_probe(), through the normal
>   phy_init_hw() call (which arguably could be optimized out)
> 
> Everything is fine in that case. With commit 62469c76007e, we would have
> the following scenario to happen after an ifconfig down then up
> sequence:
> 
> - bcmgenet_close() calls phy_disonnect() which makes dev->phydev become
>   NULL
> 
> - when bcmgenet_open() executes again and calls bcmgenet_mii_reset() from
>   bcmgenet_power_up() to initialize the internal PHY, the NULL check
>   becomes true, so we do not reset the PHY, yet we keep going on and
>   initialize the UniMAC, causing MAC activity to occur
> 
> - we call bcmgenet_mii_reset() from bcmgenet_mii_probe(), but this is
>   too late, the PHY is botched, and causes the above bogus pings/packets
>   transmission/reception to occur
> 
> Reported-by: Jaedon Shin <jaedon.shin@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable.
