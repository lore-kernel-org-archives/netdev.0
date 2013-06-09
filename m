From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Sun, 9 Jun 2013 10:11:27 +0300
Message-ID: <20130609071127.GC13082@redhat.com>
References: <20130606095456.GA7865@redhat.com> <87hahar7ms.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, Dave Jones <davej@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87hahar7ms.fsf@rustcorp.com.au>
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

On Fri, Jun 07, 2013 at 11:42:43AM +0930, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > For small packets we can simplify xmit processing by linearizing buffers
> > with the header: most packets seem to have enough head room we can use
> > for this purpose.
> >
> > Since some older hypervisors (e.g. qemu before version 1.5)
> > required that header is the first s/g element,
> > we need a feature bit for this.
> 
> OK, we know this is horrible.  But I will sleep better knowing that we
> this feature need never make it into a final 1.0 spec, since it can be
> assumed at that point...

Nod. Though if we want to require this for all devices,
virtio-blk scsi command passthrough will need to change -
I sent a spec patch a while ago
	virtio-spec: add field for scsi command size
any comments on it?

> >  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
> > +	if (vi->mergeable_rx_bufs)
> > +		hdr_len = sizeof hdr->mhdr;
> > +	else
> > +		hdr_len = sizeof hdr->hdr;
> > +
> > +	can_push = vi->any_header_sg &&
> > +		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
> > +		!skb_header_cloned(skb) && skb_headroom(skb) >= hdr_len;
> 
> Idle thought: how often does this fail?

I think it's mostly doesn't fail in my testing.

It's probably a good idea to add a counter here, then
if it starts triggering we can optimize.

I think things like skb_header_cloned depend on guest config
really, e.g. tcpdump running on the interface in guest can cause this.

>  Would it suck if we copied
> headers which didn't let us prepend data?

I think it will - copies are generally best avoided,
and header is easily 1K of data.

>  Or could we bump
> dev->hard_header_len appropriately?

Needs some thought, though from experience it's a pain.


> Thanks,
> Rusty.
