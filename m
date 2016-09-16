From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: XDP_TX bug report on mlx4
Date: Fri, 16 Sep 2016 12:17:27 -0700
Message-ID: <20160916191727.GA8410@gmail.com>
References: <20160916210340.4a7cdef8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <rana.shahot@gmail.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35409 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964904AbcIPTRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:17:30 -0400
Received: by mail-pa0-f54.google.com with SMTP id oz2so24047363pac.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:17:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160916210340.4a7cdef8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 09:03:40PM +0200, Jesper Dangaard Brouer wrote:
> Hi Brenden,
> 
> I've discovered a bug with XDP_TX recycling of pages in the mlx4 driver.
> 
> If I increase the number of RX and TX queues/channels via ethtool cmd:
>  ethtool -L mlx4p1 rx 10 tx 10
> 
> Then when running the xdp2 program, which does XDP_TX, the kernel will
> crash with page errors, because the page refcnt goes to zero or even
> minus.  I've noticed pages delivered to mlx4_en_rx_recycle() can have
> a page refcnt of zero, which is wrong, they should always have 1 (for
> XDP).
> 
> Debugging it further, I find that this can happen when mlx4_en_rx_recycle()
> is called from mlx4_en_recycle_tx_desc().  This is the TX cleanup function,
> associated with TX ring queues used for XDP_TX only. No others than the
> XDP_TX action should be able to place packets into these TX rings
> which call mlx4_en_recycle_tx_desc().

Sounds pretty straightforward, let me look into it.
> 
> Do you have any idea of what could be going wrong in this case?
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> 
