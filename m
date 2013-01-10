From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: avoid owner checks on IFF_ATTACH_QUEUE
Date: Thu, 10 Jan 2013 16:19:39 +0200
Message-ID: <20130110141939.GA30557@redhat.com>
References: <20130110113108.GF13451@redhat.com>
 <50EECB43.8020405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paul Moore <pmoore@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50EECB43.8020405@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 10, 2013 at 10:08:03PM +0800, Jason Wang wrote:
> On 01/10/2013 07:31 PM, Michael S. Tsirkin wrote:
> > At the moment, we check owner when we enable queue in tun.
> > This seems redundant and will break some valid uses
> > where fd is passed around: I think TUNSETOWNER is there
> > to prevent others from attaching to a persistent device not
> > owned by them. Here the fd is already attached,
> > enabling/disabling queue is more like read/write.
> 
> It also change the number of queues of the tuntap, maybe we should limit
> this.

Number of active queues? Why does it matter?
Max number of queues is already limited by SETIFF.

> Note that if management layer does not call TUNSETOWNER, the check
> is just a nop. So if management layer want to limit the behavior, it's
> its duty to do this correctly.

The point is that management limits tun to allow SETIFF from libvirt
only, then passes the fds to qemu.

> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >
> > ---
> >
> > Note: this is unrelated to Stefan's bugfix.
> >
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index fbd106e..78e3225 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1789,10 +1792,8 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
> >  		tun = tfile->detached;
> >  		if (!tun)
> >  			ret = -EINVAL;
> > -		else if (tun_not_capable(tun))
> > -			ret = -EPERM;
> >  		else
> >  			ret = tun_attach(tun, file);
> >  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
> >  		tun = rcu_dereference_protected(tfile->tun,
> >  						lockdep_rtnl_is_held());
> 
