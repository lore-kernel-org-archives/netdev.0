From: David Miller <davem@davemloft.net>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 07:57:31 -0400 (EDT)
Message-ID: <20161010.075731.2449861168238706.davem@davemloft.net>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
        <20161010.050125.1981283393312167625.davem@davemloft.net>
        <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        cphealy@gmail.com
To: nikita.yoush@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon, 10 Oct 2016 12:51:28 +0300

> Hmm...  I'm not about device writing to memory.

This absolutely is about whether the device wrote into the
area or not.

> Sequence in igb driver is:
> 
> dma_map(full_page)
>   <device writes here>
> sync_to_cpu(half_page);
> skb_add_rx_frag(skb, half_page);
> napi_gro_receive(skb);
>   ...
> dma_unmap(full_page)
> 
> What I'm concerned about is - same area is first passed up to network
> stack, and _later_ dma_unmap()ed.  Is this indeed safe?

dma_unmap() should never write anything unless the device has
meanwhile written to that chunk of memory.

If the device made no intervening writes into the area, dma_unmap()
should not cause any data to be written to that area, period.

In your example above, consider the case where the device never
writes into the memory area after sync_to_cpu().  In that case
there is nothing that dma_unmap() can possibly write.  All the
data has been synced, and no device writes into the memory are
have occurred.
