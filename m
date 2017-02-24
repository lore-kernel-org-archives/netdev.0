From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Fri, 24 Feb 2017 10:42:15 +0100
Message-ID: <20170224104215.4c5b3381@redhat.com>
References: <20170213195858.5215-1-edumazet@google.com>
        <20170213195858.5215-9-edumazet@google.com>
        <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
        <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com>
        <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdBXJnM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 04:43:12 -0500
In-Reply-To: <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2017 18:06:58 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2017-02-22 at 17:08 -0800, Alexander Duyck wrote:
> 
> > 
> > Right but you were talking about using both halves one after the
> > other.  If that occurs you have nothing left that you can reuse.  That
> > was what I was getting at.  If you use up both halves you end up
> > having to unmap the page.
> >   
> 
> You must have misunderstood me.

FYI, I also misunderstood you (Eric) to start with ;-)
 
> Once we use both halves of a page, we _keep_ the page, we do not unmap
> it.
> 
> We save the page pointer in a ring buffer of pages.
> Call it the 'quarantine'
> 
> When we _need_ to replenish the RX desc, we take a look at the oldest
> entry in the quarantine ring.
> 
> If page count is 1 (or pagecnt_bias if needed) -> we immediately reuse
> this saved page.
> 
> If not, _then_ we unmap and release the page.
> 
> Note that we would have received 4096 frames before looking at the page
> count, so there is high chance both halves were consumed.
> 
> To recap on x86 :
> 
> 2048 active pages would be visible by the device, because 4096 RX desc
> would contain dma addresses pointing to the 4096 halves.
> 
> And 2048 pages would be in the reserve.

I do like it, and it should work.  I like it because it solves my
concern, regarding being able to adjust the amount of
outstanding-frames independently of the RX ring size.


Do notice: driver developers have to use Alex'es new DMA API in-order
to get writable-pages, else this will violate the DMA API.  And XDP
requires writable pages.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
