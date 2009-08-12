From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 12 Aug 2009 20:31:04 +0300
Message-ID: <20090812173104.GB29966@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <20090810185340.GC13924@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812171921.GC24151@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754645AbZHLRdJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090812171921.GC24151@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2009 at 10:19:22AM -0700, Ira W. Snyder wrote:
> On Wed, Aug 12, 2009 at 07:03:22PM +0200, Arnd Bergmann wrote:
> > On Monday 10 August 2009, Michael S. Tsirkin wrote:
> > 
> > > +struct workqueue_struct *vhost_workqueue;
> > 
> > [nitpicking] This could be static. 
> > 
> > > +/* The virtqueue structure describes a queue attached to a device. */
> > > +struct vhost_virtqueue {
> > > +	struct vhost_dev *dev;
> > > +
> > > +	/* The actual ring of buffers. */
> > > +	struct mutex mutex;
> > > +	unsigned int num;
> > > +	struct vring_desc __user *desc;
> > > +	struct vring_avail __user *avail;
> > > +	struct vring_used __user *used;
> > > +	struct file *kick;
> > > +	struct file *call;
> > > +	struct file *error;
> > > +	struct eventfd_ctx *call_ctx;
> > > +	struct eventfd_ctx *error_ctx;
> > > +
> > > +	struct vhost_poll poll;
> > > +
> > > +	/* The routine to call when the Guest pings us, or timeout. */
> > > +	work_func_t handle_kick;
> > > +
> > > +	/* Last available index we saw. */
> > > +	u16 last_avail_idx;
> > > +
> > > +	/* Last index we used. */
> > > +	u16 last_used_idx;
> > > +
> > > +	/* Outstanding buffers */
> > > +	unsigned int inflight;
> > > +
> > > +	/* Is this blocked? */
> > > +	bool blocked;
> > > +
> > > +	struct iovec iov[VHOST_NET_MAX_SG];
> > > +
> > > +} ____cacheline_aligned;
> > 
> > We discussed this before, and I still think this could be directly derived
> > from struct virtqueue, in the same way that vring_virtqueue is derived from
> > struct virtqueue. That would make it possible for simple device drivers
> > to use the same driver in both host and guest, similar to how Ira Snyder
> > used virtqueues to make virtio_net run between two hosts running the
> > same code [1].
> > 
> > Ideally, I guess you should be able to even make virtio_net work in the
> > host if you do that, but that could bring other complexities.
> 
> I have no comments about the vhost code itself, I haven't reviewed it.
> 
> It might be interesting to try using a virtio-net in the host kernel to
> communicate with the virtio-net running in the guest kernel. The lack of
> a management interface is the biggest problem you will face (setting MAC
> addresses, negotiating features, etc. doesn't work intuitively).

That was one of the reasons I decided to move most of code out to
userspace. My kernel driver only handles datapath,
it's much smaller than virtio net.

> Getting
> the network interfaces talking is relatively easy.
> 
> Ira

Tried this, but
- guest memory isn't pinned, so copy_to_user
  to access it, errors need to be handled in a sane way
- used/available roles are reversed
- kick/interrupt roles are reversed

So most of the code then looks like

	if (host) {
	} else {
	}
	return


The only common part is walking the descriptor list,
but that's like 10 lines of code.

At which point it's better to keep host/guest code separate, IMO.

-- 
MST
