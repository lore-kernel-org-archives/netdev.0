From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 12:11:32 +0300
Message-ID: <20130619091132.GA2816@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
 <1371623518.3252.267.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371623518.3252.267.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 18, 2013 at 11:31:58PM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 13:40 +0800, Jason Wang wrote:
> > Currently, we use kcalloc to allocate rx/tx queues for a net device which could
> > be easily lead to a high order memory allocation request when initializing a
> > multiqueue net device. We can simply avoid this by switching to use flex array
> > which always allocate at order zero.
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > ---
> >  include/linux/netdevice.h |   13 ++++++----
> >  net/core/dev.c            |   57 ++++++++++++++++++++++++++++++++------------
> >  net/core/net-sysfs.c      |   15 +++++++----
> >  3 files changed, 58 insertions(+), 27 deletions(-)
> > 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 09b4188..c0b5d04 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -32,6 +32,7 @@
> >  #include <linux/atomic.h>
> >  #include <asm/cache.h>
> >  #include <asm/byteorder.h>
> > +#include <linux/flex_array.h>
> >  
> >  #include <linux/percpu.h>
> >  #include <linux/rculist.h>
> > @@ -1230,7 +1231,7 @@ struct net_device {
> >  
> > 
> >  #ifdef CONFIG_RPS
> > -	struct netdev_rx_queue	*_rx;
> > +	struct flex_array	*_rx;
> >  
> >  	/* Number of RX queues allocated at register_netdev() time */
> >  	unsigned int		num_rx_queues;
> > @@ -1250,7 +1251,7 @@ struct net_device {
> >  /*
> >   * Cache lines mostly used on transmit path
> >   */
> > -	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
> > +	struct flex_array	*_tx ____cacheline_aligned_in_smp;
> >  
> 
> Using flex_array and adding overhead in this super critical part of
> network stack, only to avoid order-1 allocations done in GFP_KERNEL
> context is simply insane.
> 
> We can revisit this in 2050 if we ever need order-4 allocations or so,
> and still use 4K pages.
> 
> 

Well KVM supports up to 160 VCPUs on x86.

Creating a queue per CPU is very reasonable, and
assuming cache line size of 64 bytes, netdev_queue seems to be 320
bytes, that's 320*160 = 51200. So 12.5 pages, order-4 allocation.
I agree most people don't have such systems yet, but
they do exist.

We can cut the size of netdev_queue, moving out kobj - which
does not seem to be used on data path to a separate structure.
It's 64 byte in size so exactly 256 bytes.
That will get us an order-3 allocation, and there's
some padding there so we won't immediately increase it
the moment we add some fields.

Comments on this idea?

Instead of always using a flex array, we could have
+	struct netdev_queue     *_tx; /* Used with small # of queues */
+#ifdef CONFIG_NETDEV_HUGE_NUMBER_OR_QUEUES
+	struct flex_array     *_tx_large; /* Used with large # of queues */
+#endif

And fix wrappers to use _tx if not NULL, otherwise _tx_large.

If configured in, it's an extra branch on data path but probably less
costly than the extra indirection.

-- 
MST
