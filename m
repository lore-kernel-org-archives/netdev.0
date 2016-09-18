From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: XDP_TX bug report on mlx4
Date: Sun, 18 Sep 2016 19:59:43 -0400
Message-ID: <20160918235943.GA18685@gmail.com>
References: <20160916210340.4a7cdef8@redhat.com>
 <20160916191727.GA8410@gmail.com>
 <20160916212443.0eddbeb5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <rana.shahot@gmail.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34959 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755407AbcIRX7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 19:59:48 -0400
Received: by mail-pf0-f174.google.com with SMTP id z123so44440604pfz.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 16:59:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160916212443.0eddbeb5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 09:24:43PM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 16 Sep 2016 12:17:27 -0700
> Brenden Blanco <bblanco@plumgrid.com> wrote:
> 
> > On Fri, Sep 16, 2016 at 09:03:40PM +0200, Jesper Dangaard Brouer wrote:
> > > Hi Brenden,
> > > 
> > > I've discovered a bug with XDP_TX recycling of pages in the mlx4 driver.
> > > 
> > > If I increase the number of RX and TX queues/channels via ethtool cmd:
> > >  ethtool -L mlx4p1 rx 10 tx 10
> > > 
> > > Then when running the xdp2 program, which does XDP_TX, the kernel will
> > > crash with page errors, because the page refcnt goes to zero or even
> > > minus.  I've noticed pages delivered to mlx4_en_rx_recycle() can have
> > > a page refcnt of zero, which is wrong, they should always have 1 (for
> > > XDP).
> > > 
> > > Debugging it further, I find that this can happen when mlx4_en_rx_recycle()
> > > is called from mlx4_en_recycle_tx_desc().  This is the TX cleanup function,
> > > associated with TX ring queues used for XDP_TX only. No others than the
> > > XDP_TX action should be able to place packets into these TX rings
> > > which call mlx4_en_recycle_tx_desc().  
> > 
> > Sounds pretty straightforward, let me look into it.
> 
> Here is some debug info I instrumented my kernel with, and I've
> attached my minicom output with a warning and a panic.

Thanks for the info.

I've also spent this weekend trying to debug (pretty easy to reproduce),
but with no conclusive answer. I was investigating the sequence in
mlx4_en_stop_port to see if rx might still be running through the
function, on the theory that the xdp tx might race with
mlx4_en_free_tx_buf. For instance, I tried moving the napi_synchronize
loop to be just below the msleep(10). No improvement.

Unfortunately, I'm out of options, since my one test box has decided not
to reboot itself automatically, and I'll be out of email communication
(for 3 weeks) before anybody can physicially resuscitate it (tomorrow).
> 
> Enable some driver debug printks via::
>  ethtool -s mlx4p1 msglvl drv on
> 
> Debug normal situation::
> 
[...]
