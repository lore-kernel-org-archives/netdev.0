From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] net/core: Order-3 frag allocator causes SWIOTLB bouncing
 under Xen
Date: Wed, 4 Sep 2013 17:11:10 -0400
Message-ID: <20130904211110.GA17758@phenom.dumpdata.com>
References: <1378327638-23956-1-git-send-email-zoltan.kiss@citrix.com>
 <1378328440.7360.124.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizefan@huawei.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	malcolm.crossley@citrix.com, david.vrabel@citrix.com,
	xen-devel@lists.xen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378328440.7360.124.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 04, 2013 at 02:00:40PM -0700, Eric Dumazet wrote:
> On Wed, 2013-09-04 at 21:47 +0100, Zoltan Kiss wrote:
> > THIS PATCH IS NOT INTENDED TO BE UPSTREAMED, IT HAS ONLY INFORMING PURPOSES!
> > 
> > I've noticed a performance regression with upstream kernels when used as Dom0
> > under Xen. The classic kernel can utilize the whole bandwidth of a 10G NIC
> > (ca. 9.3 Gbps), but upstream can reach only ca. 7 Gbps. I found that it
> > happens because SWIOTLB has to do double buffering. The per task frag
> > allocator introduced in 5640f7 creates 32 kb frags, which are not contiguous
> > in mfn space.
> > This patch provides a workaround by going back to the old way. The possible
> > ideas came up to solve this:
> > 
> > * make sure Dom0 memory is contiguous: it sounds trivial, but doesn't work with
> > driver domains, and there are lots of situations where this is not possible.
> > * use PVH Dom0: so we will have IOMMU. In the future sometime.
> > * use IOMMU with PV Dom0: this seems to happen earlier.
> > 
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > ---
> >  net/core/sock.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 2c097c5..854a0ea 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1812,7 +1812,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
> >  EXPORT_SYMBOL(sock_alloc_send_skb);
> >  
> >  /* On 32bit arches, an skb frag is limited to 2^15 */
> > -#define SKB_FRAG_PAGE_ORDER	get_order(32768)
> > +#define SKB_FRAG_PAGE_ORDER	get_order(4096)
> >  
> 
> Well, this hack is not new...
> 
> We have dev->gso_max_size and dev->gso_max_segs
> 
> We also have in net-next sk_pacing_rate and dynamic TSO sizing.
> 
> Maybe you could add proper infrastructure to deal with Xen limitations.

I think Ian posted at some point an sysctl patch for that (more for
debugging that anything else). And it kind
of stalled: http://lists.xen.org/archives/html/xen-devel/2012-10/msg01832.html

Is that what you mean by proper infrastructure ?

Oh wait, did you mean via dev and not the whole system wide sysctl?

> 
> 
> 
