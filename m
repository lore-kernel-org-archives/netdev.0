From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet
 WQE (Striding RQ)
Date: Tue, 19 Apr 2016 18:25:32 +0200
Message-ID: <20160419182532.423d3c05@redhat.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
	<1460928725-18741-6-git-send-email-saeedm@mellanox.com>
	<1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
	<1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
	<1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed
 Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz
 <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>,
        Tariq Toukan
 <tariqt@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Achiad
 Shochat <achiad@mellanox.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        linux-mm <linux-mm@kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Apr 2016 07:17:13 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-04-18 at 16:05 +0300, Saeed Mahameed wrote:
> > On Mon, Apr 18, 2016 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> > > On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:
> > >  
> > >>
> > >> If really you need to allocate physically contiguous memory, have you
> > >> considered converting the order-5 pages into 32 order-0 ones ?  
> > >
> > > Search for split_page() call sites for examples.
> > >
> > >  
> > 
> > Thanks Eric, we are already evaluating split_page as we speak.
> > 
> > We did look but could not find any specific alloc_pages API that
> > allocates many physically contiguous pages with order0 ! so we assume
> > it is ok to use split_page.  
> 
> Note: I have no idea of split_page() performance :

Maybe Mel knows?  And maybe Mel have an opinion about if this is a good
or bad approach, e.g. will this approach stress the page allocator in a
bad way?

> Buddy page allocator has to aggregate pages into order-5, then we would
> undo the work, touching 32 cache lines.
> 
> You might first benchmark a simple loop doing 
> 
> loop 10,000,000 times
>  Order-5 allocation
>  split into 32 order-0
>  free 32 pages
> 
> 
> Another idea would be to have a way to control max number of order-5
> pages that a port would be using.
> 
> Since driver always own a ref on a order-5 pages, idea would be to
> maintain a circular ring of up to XXX such pages, so that we can detect
> an abnormal use and fallback to order-0 immediately.

That is part of my idea with my page-pool proposal.  In the page-pool I
want to have some watermark counter that can block/stop the OOM issue at
this RX ring level.

See slide 12 of presentation:
http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
