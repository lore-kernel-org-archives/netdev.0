From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] net: reduce cycles spend on ICMP replies that
 gets rate limited
Date: Sat, 7 Jan 2017 11:31:33 +0100
Message-ID: <20170107113133.227f3c29@redhat.com>
References: <20170106173907.32104.52294.stgit@firesoul>
        <1483731621.9712.31.camel@edumazet-glaptop3.roam.corp.google.com>
        <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170106.221042.1641025960219244932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, brouer@redhat.com,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932379AbdAGKbi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 05:31:38 -0500
In-Reply-To: <20170106.221042.1641025960219244932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Jan 2017 22:10:42 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> BTW Eric, you asked about kmalloc() allocation, you were CC:'d in the
> patch which did this :-)
> 
> commit 9a99d4a50cb8ce516adf0f2436138d4c8e6e4535
> Author: Cong Wang <amwang@redhat.com>
> Date:   Sun Jun 2 15:00:52 2013 +0000
> 
>     icmp: avoid allocating large struct on stack
>     
>     struct icmp_bxm is a large struct, reduce stack usage
>     by allocating it on heap.
>     
>     Cc: Eric Dumazet <eric.dumazet@gmail.com>
>     Cc: Joe Perches <joe@perches.com>
>     Cc: David S. Miller <davem@davemloft.net>
>     Signed-off-by: Cong Wang <amwang@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Did a quick revert, and tested again.  It is not the major bottleneck,
but we do save something.  The major bottleneck is still the call to
__ip_route_output_key_hash (invoked by icmp_route_lookup).

Single flow improvement from 1719182 pps to 1783368 pps.
 - 64186 pps
 - (1/1783368-1/1719182)*10^9 = -20.93 nanosec
   * 4GHz approx = 20.93*4 = 83.72 cycles

The optimal SLUB fast-path on this machine is 54 cycles(tsc) 13.557 ns,
thus the saving is actually higher than expected.  But low compared to
avoiding the icmp_route_lookup.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
