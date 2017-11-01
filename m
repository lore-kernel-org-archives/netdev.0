From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] vhost_net: conditionally enable tx polling
Date: Wed, 1 Nov 2017 17:03:37 +0200
Message-ID: <20171101165953-mutt-send-email-mst@kernel.org>
References: <1509445640-4085-1-git-send-email-jasowang@redhat.com>
 <20171031182637-mutt-send-email-mst@kernel.org>
 <c69accc4-4a35-0501-8a99-ab7821365cd8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Matthew Rosato <mjrosato@linux.vnet.ibm.com>, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, Wei Xu <wexu@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c69accc4-4a35-0501-8a99-ab7821365cd8@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2017 at 08:51:36PM +0800, Jason Wang wrote:
> 
> 
> On 2017年11月01日 00:36, Michael S. Tsirkin wrote:
> > On Tue, Oct 31, 2017 at 06:27:20PM +0800, Jason Wang wrote:
> > > We always poll tx for socket, this is sub optimal since:
> > > 
> > > - we only want to be notified when sndbuf is available
> > > - this will slightly increase the waitqueue traversing time and more
> > >    important, vhost could not benefit from commit
> > >    commit 9e641bdcfa4e
> > >    ("net-tun: restructure tun_do_read for better sleep/wakeup efficiency")
> > >    even if we've stopped rx polling during handle_rx() since tx poll
> > >    were still left in the waitqueue.
> > > 
> > > Pktgen from a remote host to VM over mlx4 shows 5.5% improvements on
> > > rx PPS. (from 1.27Mpps to 1.34Mpps)
> > > 
> > > Cc: Wei Xu <wexu@redhat.com>
> > > Cc: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
> > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > ---
> > Now that vhost_poll_stop happens on data path
> > a lot, I'd say
> >          if (poll->wqh)
> > there should be unlikely().
> 
> It has been there since 8241a1e466cd ("vhost_net: stop polling socket during
> rx processing"). So it will be used for rx path too which unlikely() does
> not work as well as the case in tx.

Worth testing, does not have to block this patch.

> 
> > 
> > 
> > >   drivers/vhost/net.c | 11 ++++++++---
> > >   1 file changed, 8 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > index 68677d9..286c3e4 100644
> > > --- a/drivers/vhost/net.c
> > > +++ b/drivers/vhost/net.c
> > > @@ -471,6 +471,7 @@ static void handle_tx(struct vhost_net *net)
> > >   		goto out;
> > >   	vhost_disable_notify(&net->dev, vq);
> > > +	vhost_net_disable_vq(net, vq);
> > >   	hdr_size = nvq->vhost_hlen;
> > >   	zcopy = nvq->ubufs;
> > > @@ -556,6 +557,8 @@ static void handle_tx(struct vhost_net *net)
> > >   					% UIO_MAXIOV;
> > >   			}
> > >   			vhost_discard_vq_desc(vq, 1);
> > > +			if (err == -EAGAIN)
> > > +				vhost_net_enable_vq(net, vq);
> > >   			break;
> > >   		}
> > >   		if (err != len)
> > I would probably just enable it unconditionally here. Why not?
> > 
> 
> I thought we only care about the case of tun_sock_write_space() and for the
> errors other than -EAGAIN, they have nothing to do with polling.

We could thinkably get ENOMEM I guess. If we miss a code things
get stuck - It's just easier not to add extra code IMHO.

> > > @@ -1145,9 +1148,11 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
> > >   		r = vhost_vq_init_access(vq);
> > >   		if (r)
> > >   			goto err_used;
> > > -		r = vhost_net_enable_vq(n, vq);
> > > -		if (r)
> > > -			goto err_used;
> > > +		if (index == VHOST_NET_VQ_RX) {
> > > +			r = vhost_net_enable_vq(n, vq);
> > > +			if (r)
> > > +				goto err_used;
> > > +		}
> > >   		oldubufs = nvq->ubufs;
> > >   		nvq->ubufs = ubufs;
> > This last chunk seems questionable. If queue has stuff in it
> > when we connect the backend, we'll miss a wakeup.
> > I suspect this can happen during migration.
> 
> Unless qemu pass a tap which s already had pending tx packets.
> 
> I can remove this chuck, but if guest does not transmit any packet, rx can't
> benefit from this.
> 
> Thanks

Not sure I understand the last sentence. vhost will stay
polling the socket - why is that a problem?


> > 
> > 
> > > -- 
> > > 2.7.4
> 
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
