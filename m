From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Wed, 03 Oct 2012 20:35:00 -0500
Message-ID: <87sj9vxbnf.fsf@codemonkey.ws>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35127 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab2JDBfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 21:35:04 -0400
Received: by obbuo13 with SMTP id uo13so7974175obb.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 18:35:04 -0700 (PDT)
In-Reply-To: <87vces2gxq.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> writes:

> "Michael S. Tsirkin" <mst@redhat.com> writes:
>
> There's a reason I haven't done this.  I really, really dislike "my
> implemention isn't broken" feature bits.  We could have an infinite
> number of them, for each bug in each device.
>
> So my plan was to tie this assumption to the new PCI layout.  And have a
> stress-testing patch like the one below in the kernel (see my virtio-wip
> branch for stuff like this).  Turn it on at boot with
> "virtio_ring.torture" on the kernel commandline.
>
> BTW, I've fixed lguest, but my kvm here (Ubuntu precise, kvm-qemu 1.0)
> is too old.  Building the latest git now...
>
> Cheers,
> Rusty.
>
> Subject: virtio: CONFIG_VIRTIO_DEVICE_TORTURE
>
> Virtio devices are not supposed to depend on the framing of the scatter-gather
> lists, but various implementations did.  Safeguard this in future by adding
> an option to deliberately create perverse descriptors.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Ignore framing is really a bad idea.  You want backends to enforce
reasonable framing because guest's shouldn't do silly things with framing.

For instance, with virtio-blk, if you want decent performance, you
absolutely want to avoid bouncing the data.  If you're using O_DIRECT in
the host to submit I/O requests, then it's critical that all of the s/g
elements are aligned to a sector boundary and sized to a sector
boundary.

Yes, QEMU can handle if that's not the case, but it would be insanely
stupid for a guest not to do this.  This is the sort of thing that ought
to be enforced in the specification because a guest cannot perform well
if it doesn't follow these rules.

A spec isn't terribly useful if the result is guest drivers that are
slow.  There's very little to gain by not enforcing rules around framing
and there's a lot to lose if a guest frames incorrectly.

In the rare case where we want to make a framing change, we should use
feature bits like Michael is proposing.

In this case, we should simply say that with the feature bit, the vnet
header can be in the same element as the data but not allow the header
to be spread across multiple elements.

Regards,

Anthony Liguori

>
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 8d5bddb..930a4ea 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -5,6 +5,15 @@ config VIRTIO
>  	  bus, such as CONFIG_VIRTIO_PCI, CONFIG_VIRTIO_MMIO, CONFIG_LGUEST,
>  	  CONFIG_RPMSG or CONFIG_S390_GUEST.
>  
> +config VIRTIO_DEVICE_TORTURE
> +	bool "Virtio device torture tests"
> +	depends on VIRTIO && DEBUG_KERNEL
> +	help
> +	  This makes the virtio_ring implementation creatively change
> +	  the format of requests to make sure that devices are
> +	  properly implemented.  This will make your virtual machine
> +	  slow *and* unreliable!  Say N.
> +
>  menu "Virtio drivers"
>  
>  config VIRTIO_PCI
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index e639584..8893753 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -124,6 +124,149 @@ struct vring_virtqueue
>  
>  #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
>  
> +#ifdef CONFIG_VIRTIO_DEVICE_TORTURE
> +static bool torture;
> +module_param(torture, bool, 0644);
> +
> +struct torture {
> +	unsigned int orig_out, orig_in;
> +	void *orig_data;
> +	struct scatterlist sg[4];
> +	struct scatterlist orig_sg[];
> +};
> +
> +static size_t tot_len(struct scatterlist sg[], unsigned num)
> +{
> +	size_t len, i;
> +
> +	for (len = 0, i = 0; i < num; i++)
> +		len += sg[i].length;
> +
> +	return len;
> +}
> +
> +static void copy_sg_data(const struct scatterlist *dst, unsigned dnum,
> +			 const struct scatterlist *src, unsigned snum)
> +{
> +	unsigned len;
> +	struct scatterlist s, d;
> +
> +	s = *src;
> +	d = *dst;
> +
> +	while (snum && dnum) {
> +		len = min(s.length, d.length);
> +		memcpy(sg_virt(&d), sg_virt(&s), len);
> +		d.offset += len;
> +		d.length -= len;
> +		s.offset += len;
> +		s.length -= len;
> +		if (!s.length) {
> +			BUG_ON(snum == 0);
> +			src++;
> +			snum--;
> +			s = *src;
> +		}
> +		if (!d.length) {
> +			BUG_ON(dnum == 0);
> +			dst++;
> +			dnum--;
> +			d = *dst;
> +		}
> +	}
> +}
> +
> +static bool torture_replace(struct scatterlist **sg,
> +			     unsigned int *out,
> +			     unsigned int *in,
> +			     void **data,
> +			     gfp_t gfp)
> +{
> +	static size_t seed;
> +	struct torture *t;
> +	size_t outlen, inlen, ourseed, len1;
> +	void *buf;
> +
> +	if (!torture)
> +		return true;
> +
> +	outlen = tot_len(*sg, *out);
> +	inlen = tot_len(*sg + *out, *in);
> +
> +	/* This will break horribly on large block requests. */
> +	t = kmalloc(sizeof(*t) + (*out + *in) * sizeof(t->orig_sg[1])
> +		    + outlen + 1 + inlen + 1, gfp);
> +	if (!t)
> +		return false;
> +
> +	sg_init_table(t->sg, 4);
> +	buf = &t->orig_sg[*out + *in];
> +
> +	memcpy(t->orig_sg, *sg, sizeof(**sg) * (*out + *in));
> +	t->orig_out = *out;
> +	t->orig_in = *in;
> +	t->orig_data = *data;
> +	*data = t;
> +
> +	ourseed = ACCESS_ONCE(seed);
> +	seed++;
> +
> +	*sg = t->sg;
> +	if (outlen) {
> +		/* Split outbuf into two parts, one byte apart. */
> +		*out = 2;
> +		len1 = ourseed % (outlen + 1);
> +		sg_set_buf(&t->sg[0], buf, len1);
> +		buf += len1 + 1;
> +		sg_set_buf(&t->sg[1], buf, outlen - len1);
> +		buf += outlen - len1;
> +		copy_sg_data(t->sg, *out, t->orig_sg, t->orig_out);
> +	}
> +
> +	if (inlen) {
> +		/* Split inbuf into two parts, one byte apart. */
> +		*in = 2;
> +		len1 = ourseed % (inlen + 1);
> +		sg_set_buf(&t->sg[*out], buf, len1);
> +		buf += len1 + 1;
> +		sg_set_buf(&t->sg[*out + 1], buf, inlen - len1);
> +		buf += inlen - len1;
> +	}
> +	return true;
> +}
> +
> +static void *torture_done(struct torture *t)
> +{
> +	void *data;
> +
> +	if (!torture)
> +		return t;
> +
> +	if (t->orig_in)
> +		copy_sg_data(t->orig_sg + t->orig_out, t->orig_in,
> +			     t->sg + (t->orig_out ? 2 : 0), 2);
> +
> +	data = t->orig_data;
> +	kfree(t);
> +	return data;
> +}
> +
> +#else
> +static bool torture_replace(struct scatterlist **sg,
> +			     unsigned int *out,
> +			     unsigned int *in,
> +			     void **data,
> +			     gfp_t gfp)
> +{
> +	return true;
> +}
> +
> +static void *torture_done(void *data)
> +{
> +	return data;
> +}
> +#endif /* CONFIG_VIRTIO_DEVICE_TORTURE */
> +
>  /* Set up an indirect table of descriptors and add it to the queue. */
>  static int vring_add_indirect(struct vring_virtqueue *vq,
>  			      struct scatterlist sg[],
> @@ -213,6 +356,9 @@ int virtqueue_add_buf(struct virtqueue *_vq,
>  
>  	BUG_ON(data == NULL);
>  
> +	if (!torture_replace(&sg, &out, &in, &data, gfp))
> +		return -ENOMEM;
> +
>  #ifdef DEBUG
>  	{
>  		ktime_t now = ktime_get();
> @@ -246,6 +392,7 @@ int virtqueue_add_buf(struct virtqueue *_vq,
>  		if (out)
>  			vq->notify(&vq->vq);
>  		END_USE(vq);
> +		torture_done(data);
>  		return -ENOSPC;
>  	}
>  
> @@ -476,7 +623,7 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
>  #endif
>  
>  	END_USE(vq);
> -	return ret;
> +	return torture_done(ret);
>  }
>  EXPORT_SYMBOL_GPL(virtqueue_get_buf);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
