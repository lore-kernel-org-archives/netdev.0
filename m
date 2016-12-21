From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: mvpp2: fix dma unmapping of TX buffers for
 fragments
Date: Wed, 21 Dec 2016 13:38:54 -0500 (EST)
Message-ID: <20161221.133854.1889950490139888874.davem@davemloft.net>
References: <1482316129-22332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        hannah@marvell.com, yehuday@marvell.com, mw@semihalf.com,
        raphael.glon@corp.ovh.com, stable@vger.kernel.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758972AbcLUSi5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:38:57 -0500
In-Reply-To: <1482316129-22332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Wed, 21 Dec 2016 11:28:49 +0100

> Since commit 71ce391dfb784 ("net: mvpp2: enable proper per-CPU TX
> buffers unmapping"), we are not correctly DMA unmapping TX buffers for
> fragments.
> 
> Indeed, the mvpp2_txq_inc_put() function only stores in the
> txq_cpu->tx_buffs[] array the physical address of the buffer to be
> DMA-unmapped when skb != NULL. In addition, when DMA-unmapping, we use
> skb_headlen(skb) to get the size to be unmapped. Both of this works fine
> for TX descriptors that are associated directly to a SKB, but not the
> ones that are used for fragments, with a NULL pointer as skb:
> 
>  - We have a NULL physical address when calling DMA unmap
>  - skb_headlen(skb) crashes because skb is NULL
> 
> This causes random crashes when fragments are used.
> 
> To solve this problem, we need to:
> 
>  - Store the physical address of the buffer to be unmapped
>    unconditionally, regardless of whether it is tied to a SKB or not.
> 
>  - Store the length of the buffer to be unmapped, which requires a new
>    field.
> 
> Instead of adding a third array to store the length of the buffer to be
> unmapped, and as suggested by David Miller, this commit refactors the
> tx_buffs[] and tx_skb[] arrays of 'struct mvpp2_txq_pcpu' into a
> separate structure 'mvpp2_txq_pcpu_buf', to which a 'size' field is
> added. Therefore, instead of having three arrays to allocate/free, we
> have a single one, which also improve data locality, reducing the
> impact on the CPU cache.
> 
> Fixes: 71ce391dfb784 ("net: mvpp2: enable proper per-CPU TX buffers unmapping")
> Reported-by: Raphael G <raphael.glon@corp.ovh.com>
> Cc: Raphael G <raphael.glon@corp.ovh.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
> Changes since v1:
>  - As requested by David Miller, move the per TX buffer fields into a
>    separate structure, 'struct mvpp2_txq_pcpu_buf', so that instead of
>    allocating three arrays, we allocate a single array.

Indeed, this looks a lot better.

Applied, thanks.
