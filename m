From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Tue, 1 Feb 2011 23:24:11 +0200
Message-ID: <20110201212411.GD30770@redhat.com>
References: <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
 <20110127200548.GE5228@redhat.com>
 <20110127.130240.104065182.davem@davemloft.net>
 <1296163838.1640.53.camel@localhost.localdomain>
 <20110128121616.GA8374@redhat.com>
 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
 <1296594585.26937.817.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1296594585.26937.817.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2011 at 01:09:45PM -0800, Shirley Ma wrote:
> On Mon, 2011-01-31 at 17:30 -0800, Sridhar Samudrala wrote:
> > Yes. It definitely should be 'out'. 'in' should be 0 in the tx path.
> > 
> > I tried a simpler version of this patch without any tunables by
> > delaying the signaling until we come out of the for loop.
> > It definitely reduced the number of vmexits significantly for small
> > message
> > guest to host stream test and the throughput went up a little.
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 9b3ca10..5f9fae9 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -197,7 +197,7 @@ static void handle_tx(struct vhost_net *net)
> >                 if (err != len)
> >                         pr_debug("Truncated TX packet: "
> >                                  " len %d != %zd\n", err, len);
> > -               vhost_add_used_and_signal(&net->dev, vq, head, 0);
> > +               vhost_add_used(vq, head, 0);
> >                 total_len += len;
> >                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> >                         vhost_poll_queue(&vq->poll);
> > @@ -205,6 +205,8 @@ static void handle_tx(struct vhost_net *net)
> >                 }
> >         }
> > 
> > +       if (total_len > 0)
> > +               vhost_signal(&net->dev, vq);
> >         mutex_unlock(&vq->mutex);
> >  }
> 
> Reducing the signaling will reduce the CPU utilization by reducing VM
> exits. 
> 
> The small message BW is a problem we have seen faster guest/slow vhost,
> even I increased VHOST_NET_WEIGHT times, it didn't help that much for
> BW. For large message size, vhost is able to process all packets on
> time. I played around with guest/host codes, I only see huge BW
> improvement by dropping packets on guest side so far.
> 
> Thanks
> Shirley


My theory is that the issue is not signalling.
Rather, our queue fills up, then host handles
one packet and sends an interrupt, and we
immediately wake the queue. So the vq
once it gets full, stays full.

If you try my patch with bufs threshold set to e.g.
half the vq, what we will do is send interrupt after we have processed
half the vq.  So host has half the vq to go, and guest has half the vq
to fill.

See?

-- 
MST
