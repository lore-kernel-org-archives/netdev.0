From: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] vhost: add ioctl to query nregions upper limit
Date: Thu, 25 Jun 2015 18:57:12 +0200
Message-ID: <20150625185712.50aabcb4@igors-macbook-pro.local>
References: <1435153753-2686-1-git-send-email-mst@redhat.com>
	<20150624160727.2e0f542f@nial.brq.redhat.com>
	<20150624161606-mutt-send-email-mst@redhat.com>
	<20150624165229.4f8bf82b@nial.brq.redhat.com>
	<20150624170223-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150624170223-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Jun 2015 17:08:56 +0200
"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Jun 24, 2015 at 04:52:29PM +0200, Igor Mammedov wrote:
> > On Wed, 24 Jun 2015 16:17:46 +0200
> > "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > On Wed, Jun 24, 2015 at 04:07:27PM +0200, Igor Mammedov wrote:
> > > > On Wed, 24 Jun 2015 15:49:27 +0200
> > > > "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > 
> > > > > Userspace currently simply tries to give vhost as many regions
> > > > > as it happens to have, but you only have the mem table
> > > > > when you have initialized a large part of VM, so graceful
> > > > > failure is very hard to support.
> > > > > 
> > > > > The result is that userspace tends to fail catastrophically.
> > > > > 
> > > > > Instead, add a new ioctl so userspace can find out how much
> > > > > kernel supports, up front. This returns a positive value that
> > > > > we commit to.
> > > > > 
> > > > > Also, document our contract with legacy userspace: when
> > > > > running on an old kernel, you get -1 and you can assume at
> > > > > least 64 slots.  Since 0 value's left unused, let's make that
> > > > > mean that the current userspace behaviour (trial and error)
> > > > > is required, just in case we want it back.
> > > > > 
> > > > > Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > > Cc: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > > Cc: Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > > ---
> > > > >  include/uapi/linux/vhost.h | 17 ++++++++++++++++-
> > > > >  drivers/vhost/vhost.c      |  5 +++++
> > > > >  2 files changed, 21 insertions(+), 1 deletion(-)
> > > > > 
> > > > > diff --git a/include/uapi/linux/vhost.h
> > > > > b/include/uapi/linux/vhost.h index ab373191..f71fa6d 100644
> > > > > --- a/include/uapi/linux/vhost.h
> > > > > +++ b/include/uapi/linux/vhost.h
> > > > > @@ -80,7 +80,7 @@ struct vhost_memory {
> > > > >   * Allows subsequent call to VHOST_OWNER_SET to succeed. */
> > > > >  #define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
> > > > >  
> > > > > -/* Set up/modify memory layout */
> > > > > +/* Set up/modify memory layout: see also
> > > > > VHOST_GET_MEM_MAX_NREGIONS below. */ #define
> > > > > VHOST_SET_MEM_TABLE	_IOW(VHOST_VIRTIO, 0x03, struct
> > > > > vhost_memory) /* Write logging setup. */
> > > > > @@ -127,6 +127,21 @@ struct vhost_memory {
> > > > >  /* Set eventfd to signal an error */
> > > > >  #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct
> > > > > vhost_vring_file) 
> > > > > +/* Query upper limit on nregions in VHOST_SET_MEM_TABLE
> > > > > arguments.
> > > > > + * Returns:
> > > > > + * 	0 < value <= MAX_INT - gives the upper limit,
> > > > > higher values will fail
> > > > > + * 	0 - there's no static limit: try and see if it
> > > > > works
> > > > > + * 	-1 - on failure
> > > > > + */
> > > > > +#define VHOST_GET_MEM_MAX_NREGIONS   _IO(VHOST_VIRTIO, 0x23)
> > > > > +
> > > > > +/* Returned by VHOST_GET_MEM_MAX_NREGIONS to mean there's no
> > > > > static limit:
> > > > > + * try and it'll work if you are lucky. */
> > > > > +#define VHOST_MEM_MAX_NREGIONS_NONE 0
> > > > is it needed? we always have a limit,
> > > > or don't have IOCTL => -1 => old try and see way
> > > > 
> > > > > +/* We support at least as many nregions in
> > > > > VHOST_SET_MEM_TABLE:
> > > > > + * for use on legacy kernels without
> > > > > VHOST_GET_MEM_MAX_NREGIONS support. */ +#define
> > > > > VHOST_MEM_MAX_NREGIONS_DEFAULT 64
> > > > ^^^ not used below,
> > > > if it's for legacy then perhaps s/DEFAULT/LEGACY/ 
> > > 
> > > The assumption was that userspace detecting old kernels will just
> > > use 64, this means we do want a flag to get the old way.
> > > 
> > > OTOH if you won't think it's useful, let me know.
> > this header will be synced into QEMU's tree so that we could use
> > this define there, isn't it? IMHO then _LEGACY is more exact
> > description of macro.
> > 
> > As for 0 return value, -1 is just fine for detecting old kernels
> > (i.e. try and see if it works), so 0 looks unnecessary but it
> > doesn't in any way hurt either. For me limit or -1 is enough to try
> > fix userspace.
> 
> OK.
> Do you want to try now before I do v2?

I've just tried, idea to check limit is unusable in this case.
here is a link to a patch that implements it:
https://github.com/imammedo/qemu/commits/vhost_slot_limit_check

slots count is changing dynamically depending on used devices
and more importantly guest OS could change slots count during
its runtime when during managing devices it could trigger
repartitioning of current memory table as device's memory regions
mapped into address space.

That leads to 2 different values of used slots at guest startup
time and after guest booted or after hotplug.

I my case guest could be started with max 58 DIMMs coldplugged,
but after boot 3 more slots are freed and it's possible to hotadd
3 more DIMMs. That however leads to the guest that can't be migrated
to since by QEMU design all hotplugged devices should be present
at target's startup time i.e. 60 DIMMs total and that obviously
goes above vhost limit at that time.
Other issue with it is that QEMU could report only current
limit to mgmt tools, so they can't know for sure how many slots
exactly they can allow user to set when creating VM and will have to
guess or create a VM with unusable/under provisioned slots.

We have a similar limit check for kvm memslots but that is never
exercised path since we rose limit in kernel to 509 (similar issues),
over-provisioning it in about 2 times of currently possible
userspace consumption.

> 
> > > 
> > > > > +
> > > > >  /* VHOST_NET specific defines */
> > > > >  
> > > > >  /* Attach virtio net ring to a raw socket, or tap device.
> > > > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > > > index 9e8e004..3b68f9d 100644
> > > > > --- a/drivers/vhost/vhost.c
> > > > > +++ b/drivers/vhost/vhost.c
> > > > > @@ -917,6 +917,11 @@ long vhost_dev_ioctl(struct vhost_dev
> > > > > *d, unsigned int ioctl, void __user *argp) long r;
> > > > >  	int i, fd;
> > > > >  
> > > > > +	if (ioctl == VHOST_GET_MEM_MAX_NREGIONS) {
> > > > > +		r = VHOST_MEMORY_MAX_NREGIONS;
> > > > > +		goto done;
> > > > > +	}
> > > > > +
> > > > >  	/* If you are not the owner, you can become one */
> > > > >  	if (ioctl == VHOST_SET_OWNER) {
> > > > >  		r = vhost_dev_set_owner(d);
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
