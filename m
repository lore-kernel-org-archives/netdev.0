From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: Fix use-after-free on `ifconfig eth0 down`
Date: Tue, 06 Jun 2017 16:03:49 -0400 (EDT)
Message-ID: <20170606.160349.487724164652595332.davem@davemloft.net>
References: <20170605220810.3933-1-erosca@de.adit-jv.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
        kazuya.mizuguchi.ks@renesas.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: erosca@de.adit-jv.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFUDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:03:51 -0400
In-Reply-To: <20170605220810.3933-1-erosca@de.adit-jv.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugeniu Rosca <erosca@de.adit-jv.com>
Date: Tue, 6 Jun 2017 00:08:10 +0200

> Commit a47b70ea86bd ("ravb: unmap descriptors when freeing rings") has
> introduced the issue seen in [1] reproduced on H3ULCB board.
> 
> Fix this by relocating the RX skb ringbuffer free operation, so that
> swiotlb page unmapping can be done first. Freeing of aligned TX buffers
> is not relevant to the issue seen in [1]. Still, reposition TX free
> calls as well, to have all kfree() operations performed consistently
> _after_ dma_unmap_*()/dma_free_*().
> 
> [1] Console screenshot with the problem reproduced:
> 
> salvator-x login: root
> root@salvator-x:~# ifconfig eth0 up
> Micrel KSZ9031 Gigabit PHY e6800000.ethernet-ffffffff:00: \
>        attached PHY driver [Micrel KSZ9031 Gigabit PHY]   \
>        (mii_bus:phy_addr=e6800000.ethernet-ffffffff:00, irq=235)
> IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> root@salvator-x:~#
> root@salvator-x:~# ifconfig eth0 down
> ==================================================================
> BUG: KASAN: use-after-free in swiotlb_tbl_unmap_single+0xc4/0x35c
...
> ==================================================================
> Disabling lock debugging due to kernel taint
> root@salvator-x:~#
> 
> Fixes: a47b70ea86bd ("ravb: unmap descriptors when freeing rings")
> Signed-off-by: Eugeniu Rosca <erosca@de.adit-jv.com>

Applied and queued up for -stable, thanks.
