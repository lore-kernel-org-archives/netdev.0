From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: move is_le setup to the backend
Date: Tue, 12 Jan 2016 12:48:43 +0200
Message-ID: <20160112124815-mutt-send-email-mst@redhat.com>
References: <20160111143509.9601.15143.stgit@bahia.huguette.org>
 <20160112115639-mutt-send-email-mst@redhat.com>
 <20160112113100.60e6b872@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160112113100.60e6b872@bahia.huguette.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 12, 2016 at 11:31:00AM +0100, Greg Kurz wrote:
> On Tue, 12 Jan 2016 12:01:32 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Mon, Jan 11, 2016 at 03:39:38PM +0100, Greg Kurz wrote:
> > > The vq->is_le field is used to fix endianness when accessing the vring via
> > > the cpu_to_vhost16() and vhost16_to_cpu() helpers in the following cases:
> > > 
> > > 1) host is big endian and device is modern virtio
> > > 
> > > 2) host has cross-endian support and device is legacy virtio with a different
> > >    endianness than the host
> > > 
> > > Both cases rely on the VHOST_SET_FEATURES ioctl, but 2) also needs the
> > > VHOST_SET_VRING_ENDIAN ioctl to be called by userspace. Since vq->is_le
> > > is only needed when the backend is active, it was decided to set it at
> > > backend start.
> > > 
> > > This is currently done in vhost_init_used()->vhost_init_is_le() but it
> > > obfuscates the core vhost code. This patch moves the is_le setup to a
> > > dedicated function that is called from the backend code.
> > > 
> > > Note vhost_net is the only backend that can pass vq->private_data == NULL to
> > > vhost_init_used(), hence the "if (sock)" branch.
> > > 
> > > No behaviour change.
> > > 
> > > Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> > > Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> > > ---
> > > 
> > > Hi Michael,
> > > 
> > > This is a cleanup patch I had posted last year:
> > > 
> > > http://patchwork.ozlabs.org/patch/538277/
> > > 
> > > I am just reposting with Cornelia's R-b.
> > > 
> > > Cheers.
> > > 
> > > --
> > > Greg
> > > 
> > >  drivers/vhost/net.c   |    6 ++++++
> > >  drivers/vhost/scsi.c  |    3 +++
> > >  drivers/vhost/test.c  |    2 ++
> > >  drivers/vhost/vhost.c |   12 +++++++-----
> > >  drivers/vhost/vhost.h |    1 +
> > >  5 files changed, 19 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > index 9eda69e40678..d6319cb2664c 100644
> > > --- a/drivers/vhost/net.c
> > > +++ b/drivers/vhost/net.c
> > > @@ -917,6 +917,12 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
> > >  
> > >  		vhost_net_disable_vq(n, vq);
> > >  		vq->private_data = sock;
> > > +
> > > +		if (sock)
> > > +			vhost_set_is_le(vq);
> > > +		else
> > > +			vq->is_le = virtio_legacy_is_little_endian();
> > > +
> > >  		r = vhost_init_used(vq);
> > >  		if (r)
> > >  			goto err_used;  
> > 
> > This part is kind of ugly. I think it's cleaner is the generic code.
> > How about we teach vhost_set_is_le to test vq->private_data and DTRT?
> > 
> 
> You're right. I'll try that.
> 
> > > diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> > > index 29cfc57d496e..1f4f405ebba8 100644
> > > --- a/drivers/vhost/scsi.c
> > > +++ b/drivers/vhost/scsi.c
> > > @@ -1274,6 +1274,9 @@ vhost_scsi_set_endpoint(struct vhost_scsi *vs,
> > >  			vq = &vs->vqs[i].vq;
> > >  			mutex_lock(&vq->mutex);
> > >  			vq->private_data = vs_tpg;
> > > +
> > > +			vhost_set_is_le(vq);
> > > +
> > >  			vhost_init_used(vq);
> > >  			mutex_unlock(&vq->mutex);
> > >  		}
> > > diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> > > index f2882ac98726..b1c7df502211 100644
> > > --- a/drivers/vhost/test.c
> > > +++ b/drivers/vhost/test.c
> > > @@ -196,6 +196,8 @@ static long vhost_test_run(struct vhost_test *n, int test)
> > >  		oldpriv = vq->private_data;
> > >  		vq->private_data = priv;
> > >  
> > > +		vhost_set_is_le(vq);
> > > +
> > >  		r = vhost_init_used(&n->vqs[index]);
> > >  
> > >  		mutex_unlock(&vq->mutex);
> > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > index ad2146a9ab2d..e688eb801d43 100644
> > > --- a/drivers/vhost/vhost.c
> > > +++ b/drivers/vhost/vhost.c
> > > @@ -113,6 +113,12 @@ static void vhost_init_is_le(struct vhost_virtqueue *vq)
> > >  }
> > >  #endif /* CONFIG_VHOST_CROSS_ENDIAN_LEGACY */
> > >  
> > > +void vhost_set_is_le(struct vhost_virtqueue *vq)
> > > +{
> > > +	vhost_init_is_le(vq);
> > > +}
> > > +EXPORT_SYMBOL_GPL(vhost_set_is_le);
> > > +
> > >  static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
> > >  			    poll_table *pt)
> > >  {  
> > 
> > Why do we need this wrapper? Why not just export vhost_init_is_le?
> 
> This is a tentative workaround to:
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> #35: FILE: drivers/vhost/vhost.c:116:
> +EXPORT_SYMBOL_GPL(vhost_init_is_le);
> 
> Other possibility is to put the EXPORT_SYMBOL_GPL statement in both
> conditional compilation blocks. Maybe better ?

That, or ignore the warning.

> > Or rename vhost_init_is_le->vhost_set_is_le if you prefer.
> > 
> > > @@ -1156,12 +1162,8 @@ int vhost_init_used(struct vhost_virtqueue *vq)
> > >  {
> > >  	__virtio16 last_used_idx;
> > >  	int r;
> > > -	if (!vq->private_data) {
> > > -		vq->is_le = virtio_legacy_is_little_endian();
> > > +	if (!vq->private_data)
> > >  		return 0;
> > > -	}
> > > -
> > > -	vhost_init_is_le(vq);
> > >  
> > >  	r = vhost_update_used_flags(vq);
> > >  	if (r)
> > > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > > index d3f767448a72..af5d33797937 100644
> > > --- a/drivers/vhost/vhost.h
> > > +++ b/drivers/vhost/vhost.h
> > > @@ -162,6 +162,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
> > >  
> > >  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
> > >  		    unsigned int log_num, u64 len);
> > > +void vhost_set_is_le(struct vhost_virtqueue *vq);
> > >  
> > >  #define vq_err(vq, fmt, ...) do {                                  \
> > >  		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \  
> > 
