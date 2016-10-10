From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 12:51:28 +0300
Message-ID: <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        cphealy@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010.050125.1981283393312167625.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> With this scheme, page used for Rx is completely dma_map()ed at
>> allocation time, split into two buffers, and individual buffer is
>> sync_to_cpu()ed AND PASSED TO NETWORK STACK via skb_add_rx_frag() -
>> while driver driver still uses other buffer. Later, when driver decides
>> to no longer use this page, it will dma_unmap() it completely - which on
>> archs with non-coherent caches means cache invalidation. This cache
>> invalidation will include area that is already passed elsewhere.
> 
> This should happen only if the device wrote into that piece of the
> memory which it absolutely should not.

Hmm...  I'm not about device writing to memory.


Sequence in igb driver is:

dma_map(full_page)
  <device writes here>
sync_to_cpu(half_page);
skb_add_rx_frag(skb, half_page);
napi_gro_receive(skb);
  ...
dma_unmap(full_page)

What I'm concerned about is - same area is first passed up to network
stack, and _later_ dma_unmap()ed.  Is this indeed safe?


Nikita
