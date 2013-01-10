From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: avoid owner checks on IFF_ATTACH_QUEUE
Date: Thu, 10 Jan 2013 17:10:37 +0200
Message-ID: <20130110151037.GD30731@redhat.com>
References: <20130110113108.GF13451@redhat.com>
 <50EECB43.8020405@redhat.com>
 <20130110141939.GA30557@redhat.com>
 <50EECFC8.9020402@redhat.com>
 <20130110144138.GA30731@redhat.com>
 <50EED495.4040405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paul Moore <pmoore@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50EED495.4040405@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 10, 2013 at 10:47:49PM +0800, Jason Wang wrote:
> On 01/10/2013 10:41 PM, Michael S. Tsirkin wrote:
> > On Thu, Jan 10, 2013 at 10:27:20PM +0800, Jason Wang wrote:
> >> On 01/10/2013 10:19 PM, Michael S. Tsirkin wrote:
> >>> On Thu, Jan 10, 2013 at 10:08:03PM +0800, Jason Wang wrote:
> >>>> On 01/10/2013 07:31 PM, Michael S. Tsirkin wrote:
> >>>>> At the moment, we check owner when we enable queue in tun.
> >>>>> This seems redundant and will break some valid uses
> >>>>> where fd is passed around: I think TUNSETOWNER is there
> >>>>> to prevent others from attaching to a persistent device not
> >>>>> owned by them. Here the fd is already attached,
> >>>>> enabling/disabling queue is more like read/write.
> >>>> It also change the number of queues of the tuntap, maybe we should limit
> >>>> this.
> >>> Number of active queues? Why does it matter?
> >>> Max number of queues is already limited by SETIFF.
> >> Yes the number of active(real) queues in the kernel net device and this
> >> changing may introduce other events such uevent.
> > How can it trigger a uevent?
> 
> netif_set_real_num_{tx|rx}_queues() will update the queue kobjects which
> may trigger an uevent.

Look SETOWNER is a tool intended mostly for persistent taps,
where you give a specific user the rights to attach to
specific taps but not others.

The uevent issue is preventing a DOS by a uevent flood?
Then it applies to persistent and non persistent as one.
So if one cares about this one should use an LSM
or we can add a separate capability to limit this if we
care enough.

> >
> >> With this patch, even
> >> if a owner is set for tap, every user could change the number of real
> >> queues which I don't think is not expected. Without this patch, we can
> >> limit a user that just do read and write.
> > In the end if you want very fine tuned security policy you have to
> > use an LSM.
> >
> > Here we are talking about the expected usage without an LSM.
> > There, enabling/disabling queues is just an optimization:
> > if an application wants to process data from a single thread
> > it's better off getting it through a single fd.
> > Having to channel threading changes through a priveledged
> > proxy would be very awkward.
> 
> Yes, but we have something similar like bridge-helper in qemu which
> create devices through a privileged proxy.

This only happens on startup. Threading changes can happen
at any time.

> >>>> Note that if management layer does not call TUNSETOWNER, the check
> >>>> is just a nop. So if management layer want to limit the behavior, it's
> >>>> its duty to do this correctly.
> >>> The point is that management limits tun to allow SETIFF from libvirt
> >>> only, then passes the fds to qemu.
> >> Yes, but looks like libvirt does not call TUNSETOWNER before passing it
> >> to qemu, so we're ok even without this patch. And if libvirt want to do
> >> this, it can just call TUNSETOWNER to the user of qemu.
> > No, that would allow qemu to do SETIFF which we don't want.
> 
> True, I was wrong.
> >
> >>>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >>>>>
> >>>>> ---
> >>>>>
> >>>>> Note: this is unrelated to Stefan's bugfix.
> >>>>>
> >>>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>>>> index fbd106e..78e3225 100644
> >>>>> --- a/drivers/net/tun.c
> >>>>> +++ b/drivers/net/tun.c
> >>>>> @@ -1789,10 +1792,8 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
> >>>>>  		tun = tfile->detached;
> >>>>>  		if (!tun)
> >>>>>  			ret = -EINVAL;
> >>>>> -		else if (tun_not_capable(tun))
> >>>>> -			ret = -EPERM;
> >>>>>  		else
> >>>>>  			ret = tun_attach(tun, file);
> >>>>>  	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
> >>>>>  		tun = rcu_dereference_protected(tfile->tun,
> >>>>>  						lockdep_rtnl_is_held());
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
