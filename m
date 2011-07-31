From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC net-next] virtio_net: refill buffer right after
	being used
Date: Sat, 30 Jul 2011 22:16:15 -0700
Message-ID: <1312089375.23194.11.camel@localhost.localdomain>
References: <1311979448.24300.28.camel@localhost.localdomain>
	<1311980131.24300.30.camel@localhost.localdomain>
	<CAGTjWtCsgcf664HJ_prmcRyUzLcSSKhjfbaM0KnsxhDJo6k7Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.osdl.org, netdev@vger.kernel.org, kvm@vger.kernel.org,
        mst@redhat.com
To: Mike Waychison <mikew@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGTjWtCsgcf664HJ_prmcRyUzLcSSKhjfbaM0KnsxhDJo6k7Fg@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-29 at 16:58 -0700, Mike Waychison wrote:
> On Fri, Jul 29, 2011 at 3:55 PM, Shirley Ma <mashirle@us.ibm.com>
> wrote:
> > Resubmit it with a typo fix.
> >
> > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > ---
> >
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 0c7321c..c8201d4 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -429,6 +429,22 @@ static int add_recvbuf_mergeable(struct
> virtnet_info *vi, gfp_t gfp)
> >        return err;
> >  }
> >
> > +static int fill_one(struct virtnet_info *vi, gfp_t gfp)
> > +{
> > +       int err;
> > +
> > +       if (vi->mergeable_rx_bufs)
> > +               err = add_recvbuf_mergeable(vi, gfp);
> > +       else if (vi->big_packets)
> > +               err = add_recvbuf_big(vi, gfp);
> > +       else
> > +               err = add_recvbuf_small(vi, gfp);
> > +
> > +       if (err >= 0)
> > +               ++vi->num;
> > +       return err;
> > +}
> > +
> >  /* Returns false if we couldn't fill entirely (OOM). */
> >  static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
> >  {
> > @@ -436,17 +452,10 @@ static bool try_fill_recv(struct virtnet_info
> *vi, gfp_t gfp)
> >        bool oom;
> >
> >        do {
> > -               if (vi->mergeable_rx_bufs)
> > -                       err = add_recvbuf_mergeable(vi, gfp);
> > -               else if (vi->big_packets)
> > -                       err = add_recvbuf_big(vi, gfp);
> > -               else
> > -                       err = add_recvbuf_small(vi, gfp);
> > -
> > +               err = fill_one(vi, gfp);
> >                oom = err == -ENOMEM;
> >                if (err < 0)
> >                        break;
> > -               ++vi->num;
> >        } while (err > 0);
> >        if (unlikely(vi->num > vi->max))
> >                vi->max = vi->num;
> > @@ -506,13 +515,13 @@ again:
> >                receive_buf(vi->dev, buf, len);
> >                --vi->num;
> >                received++;
> > -       }
> > -
> > -       if (vi->num < vi->max / 2) {
> > -               if (!try_fill_recv(vi, GFP_ATOMIC))
> > +               if (fill_one(vi, GFP_ATOMIC) < 0)
> >                        schedule_delayed_work(&vi->refill, 0);
> >        }
> >
> > +       /* notify buffers are refilled */
> > +       virtqueue_kick(vi->rvq);
> > +
> 
> How does this reduce latency?   We are doing the same amount of work
> in both cases, and in both cases the newly available buffers are not
> visible to the device until the virtqueue_kick..

It averages the latency between each receive by filling only one set of
buffers vs. either none buffers or 1/2 ring size buffers fill between
receives.

> 
> >        /* Out of packets? */
> >        if (received < budget) {
> >                napi_complete(napi);
> >
> >
> > -- 
