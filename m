From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] packet: fix use-after-free in
 prb_retire_rx_blk_timer_expired()
Date: Mon, 24 Jul 2017 17:33:39 -0700 (PDT)
Message-ID: <20170724.173339.1901009068070082994.davem@davemloft.net>
References: <20170724170732.4905-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.levin@verizon.com,
        davej@codemonkey.org.uk, liujian56@huawei.com,
        dingtianhong@huawei.com, willemdebruijn.kernel@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752577AbdGYAdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:33:40 -0400
In-Reply-To: <20170724170732.4905-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 24 Jul 2017 10:07:32 -0700

> There are multiple reports showing we have a use-after-free in
> the timer prb_retire_rx_blk_timer_expired(), where we use struct
> tpacket_kbdq_core::pkbdq, a pg_vec, after it gets freed by
> free_pg_vec().
> 
> The interesting part is it is not freed via packet_release() but
> via packet_setsockopt(), which means we are not closing the socket.
> Looking into the big and fat function packet_set_ring(), this could
> happen if we satisfy the following conditions:
> 
> 1. closing == 0, not on packet_release() path
> 2. req->tp_block_nr == 0, we don't allocate a new pg_vec
> 3. rx_ring->pg_vec is already set as V3, which means we already called
>    packet_set_ring() wtih req->tp_block_nr > 0 previously
> 4. req->tp_frame_nr == 0, pass sanity check
> 5. po->mapped == 0, never called mmap()
> 
> In this scenario we are clearing the old rx_ring->pg_vec, so we need
> to free this pg_vec, but we don't stop the timer on this path because
> of closing==0.
> 
> The timer has to be stopped as long as we need to free pg_vec, therefore
> the check on closing!=0 is wrong, we should check pg_vec!=NULL instead.
> 
> Thanks to liujian for testing different fixes.
> 
> Reported-by: alexander.levin@verizon.com
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Reported-by: liujian (CE) <liujian56@huawei.com>
> Tested-by: liujian (CE) <liujian56@huawei.com>
> Cc: Ding Tianhong <dingtianhong@huawei.com>
> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks!
