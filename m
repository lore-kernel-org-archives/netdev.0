From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Mon, 23 Dec 2013 21:37:04 +0200
Message-ID: <20131223193704.GC1582@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-2-git-send-email-mwdalton@google.com>
	<52B7F065.3010707@redhat.com>
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 23, 2013 at 09:27:07AM -0800, Eric Dumazet wrote:
> On Mon, 2013-12-23 at 16:12 +0800, Jason Wang wrote:
> > On 12/17/2013 08:16 AM, Michael Dalton wrote:
> > > The virtio-net driver currently uses netdev_alloc_frag() for GFP_ATOMIC
> > > mergeable rx buffer allocations. This commit migrates virtio-net to use
> > > per-receive queue page frags for GFP_ATOMIC allocation. This change unifies
> > > mergeable rx buffer memory allocation, which now will use skb_refill_frag()
> > > for both atomic and GFP-WAIT buffer allocations.
> > >
> > > To address fragmentation concerns, if after buffer allocation there
> > > is too little space left in the page frag to allocate a subsequent
> > > buffer, the remaining space is added to the current allocated buffer
> > > so that the remaining space can be used to store packet data.
> > >
> > > Signed-off-by: Michael Dalton <mwdalton@google.com>
> > > ---
> > >  drivers/net/virtio_net.c | 69 ++++++++++++++++++++++++++----------------------
> > >  1 file changed, 38 insertions(+), 31 deletions(-)
> > >
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index c51a988..d38d130 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -78,6 +78,9 @@ struct receive_queue {
> > >  	/* Chain pages by the private ptr. */
> > >  	struct page *pages;
> > >  
> > > +	/* Page frag for GFP_ATOMIC packet buffer allocation. */
> > > +	struct page_frag atomic_frag;
> > > +
> > >  	/* RX: fragments + linear part + virtio header */
> > >  	struct scatterlist sg[MAX_SKB_FRAGS + 2];
> > >  
> > > @@ -127,9 +130,9 @@ struct virtnet_info {
> > >  	struct mutex config_lock;
> > >  
> > >  	/* Page_frag for GFP_KERNEL packet buffer allocation when we run
> > > -	 * low on memory.
> > > +	 * low on memory. May sleep.
> > >  	 */
> > > -	struct page_frag alloc_frag;
> > > +	struct page_frag sleep_frag;
> > 
> > Any reason to use two different page_frag consider only
> > skb_page_frag_refill() is used?
> 
> One is used under process context, where preemption and GFP_KERNEL are
> allowed.

Yes but it is always used with napi disabled.

> One is used from softirq context and GFP_ATOMIC.

This one is used only under napi.

> You cant share a common
> page_frag.

So there isn't a conflict with respect to locking.

Is it problematic to use same page_frag with both GFP_ATOMIC and with
GFP_KERNEL? If yes why?

> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> 
