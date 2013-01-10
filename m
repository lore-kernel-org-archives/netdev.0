From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 3.8-rc] tuntap: refuse to re-attach to different
 tun_struct
Date: Thu, 10 Jan 2013 12:53:12 +0100
Message-ID: <20130110115312.GC30885@stefanha-thinkpad.redhat.com>
References: <1357804788-19976-1-git-send-email-stefanha@redhat.com>
 <20130110102319.GB13451@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130110102319.GB13451@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 10, 2013 at 12:23:19PM +0200, Michael S. Tsirkin wrote:
> On Thu, Jan 10, 2013 at 08:59:48AM +0100, Stefan Hajnoczi wrote:
> > Multiqueue tun devices support detaching a tun_file from its tun_struct
> > and re-attaching at a later point in time.  This allows users to disable
> > a specific queue temporarily.
> > 
> > ioctl(TUNSETIFF) allows the user to specify the network interface to
> > attach by name.  This means the user can attempt to attach to interface
> > "B" after detaching from interface "A".
> > 
> > The driver is not designed to support this so check we are re-attaching
> > to the right tun_struct.  Failure to do so may lead to oops.
> > 
> > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > ---
> > This fix is for 3.8-rc.
> > 
> >  drivers/net/tun.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index fbd106e..cf6da6e 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -491,6 +491,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
> >  	err = -EINVAL;
> >  	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
> >  		goto out;
> > +	if (tfile->detached && tun != tfile->detached)
> > +		goto out;
> >  
> >  	err = -EBUSY;
> >  	if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
> > -- 
> > 1.8.0.2
> 
> 
> I agree this is a bug but even with this patch, we still allow:
> 
> SETIFF
> SETQUEUE (DISABLED)
> SETIFF
> 
> Originally the rule always was that repeated setiff calls fail with
> EINVAL. We broke that when we set tun to NULL.  It's probably worth
> preserving that, even if queue is disabled.  Applying something like the below
> instead will address this concern, won't it?

Sounds good.

Stefan
