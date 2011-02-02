From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 09:10:35 -0800
Message-ID: <1296666635.25430.35.camel@localhost.localdomain>
References: <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <OFF5778D3C.84F46700-ON6525782B.00230A94-6525782B.00240890@in.ibm.com>
	 <20110202104832.GA8505@redhat.com>
	 <1296661185.25430.10.camel@localhost.localdomain>
	 <20110202154706.GA12738@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110202154706.GA12738@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-02 at 17:47 +0200, Michael S. Tsirkin wrote:
> On Wed, Feb 02, 2011 at 07:39:45AM -0800, Shirley Ma wrote:
> > On Wed, 2011-02-02 at 12:48 +0200, Michael S. Tsirkin wrote:
> > > Yes, I think doing this in the host is much simpler,
> > > just send an interrupt after there's a decent amount
> > > of space in the queue.
> > > 
> > > Having said that the simple heuristic that I coded
> > > might be a bit too simple.
> > 
> > >From the debugging out what I have seen so far (a single small
> message
> > TCP_STEAM test), I think the right approach is to patch both guest
> and
> > vhost.
> 
> One problem is slowing down the guest helps here.
> So there's a chance that just by adding complexity
> in guest driver we get a small improvement :(
> 
> We can't rely on a patched guest anyway, so
> I think it is best to test guest and host changes separately.
> 
> And I do agree something needs to be done in guest too,
> for example when vqs share an interrupt, we
> might invoke a callback when we see vq is not empty
> even though it's not requested. Probably should
> check interrupts enabled here?

Yes, I modified xmit callback something like below:

static void skb_xmit_done(struct virtqueue *svq)
{
        struct virtnet_info *vi = svq->vdev->priv;

        /* Suppress further interrupts. */
        virtqueue_disable_cb(svq);

        /* We were probably waiting for more output buffers. */
        if (netif_queue_stopped(vi->dev)) {
                free_old_xmit_skbs(vi);
                if (virtqueue_free_size(svq)  <= svq->vring.num / 2) {
                        virtqueue_enable_cb(svq);
			return;
		}
        }
	netif_wake_queue(vi->dev);
}

> > The problem I have found is a regression for single  small
> > message TCP_STEAM test. Old kernel works well for TCP_STREAM, only
> new
> > kernel has problem.
> 
> Likely new kernel is faster :)

> > For Steven's problem, it's multiple stream TCP_RR issues, the old
> guest
> > doesn't perform well, so does new guest kernel. We tested reducing
> vhost
> > signaling patch before, it didn't help the performance at all.
> > 
> > Thanks
> > Shirley
> 
> Yes, it seems unrelated to tx interrupts. 

The issue is more likely related to latency. Do you have anything in
mind on how to reduce vhost latency?

Thanks
Shirley

