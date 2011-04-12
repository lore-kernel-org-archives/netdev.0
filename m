From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Tue, 12 Apr 2011 23:01:12 +0300
Message-ID: <20110412200112.GA19729@redhat.com>
References: <20110127.130240.104065182.davem@davemloft.net>
 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
 <20110202044222.GC3818@redhat.com>
 <201102091107.20270.rusty@rustcorp.com.au>
 <1299621444.25664.77.camel@localhost.localdomain>
 <1299637278.13202.61.camel@localhost.localdomain>
 <87fwqv4udl.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, Shirley Ma <mashirle@us.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, borntraeger@de.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179Ab1DLUBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 16:01:48 -0400
Content-Disposition: inline
In-Reply-To: <87fwqv4udl.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 12:19:42PM +1030, Rusty Russell wrote:
> Here's an old patch where I played with implementing this:

...

> 
> virtio: put last_used and last_avail index into ring itself.
> 
> Generally, the other end of the virtio ring doesn't need to see where
> you're up to in consuming the ring.  However, to completely understand
> what's going on from the outside, this information must be exposed.
> For example, if you want to save and restore a virtio_ring, but you're
> not the consumer because the kernel is using it directly.
> 
> Fortunately, we have room to expand:

This seems to be true for x86 kvm and lguest but is it true
for s390?

        err = vmem_add_mapping(config->address,
                               vring_size(config->num,
                                          KVM_S390_VIRTIO_RING_ALIGN));
        if (err)
                goto out;
                
        vq = vring_new_virtqueue(config->num, KVM_S390_VIRTIO_RING_ALIGN,
                                 vdev, (void *) config->address,
                                 kvm_notify, callback, name);
        if (!vq) {
                err = -ENOMEM;
                goto unmap;
        }
        


> the ring is always a whole number
> of pages and there's hundreds of bytes of padding after the avail ring
> and the used ring, whatever the number of descriptors (which must be a
> power of 2).
> 
> We add a feature bit so the guest can tell the host that it's writing
> out the current value there, if it wants to use that.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---

....

> --- a/include/linux/virtio_ring.h
> +++ b/include/linux/virtio_ring.h
> @@ -29,6 +29,9 @@
>  /* We support indirect buffer descriptors */
>  #define VIRTIO_RING_F_INDIRECT_DESC	28
>  
> +/* We publish our last-seen used index at the end of the avail ring. */
> +#define VIRTIO_RING_F_PUBLISH_INDICES	29
> +
>  /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
>  struct vring_desc
>  {
> @@ -87,6 +90,7 @@ struct vring {
>   *	__u16 avail_flags;
>   *	__u16 avail_idx;
>   *	__u16 available[num];
> + *	__u16 last_used_idx;
>   *
>   *	// Padding to the next align boundary.
>   *	char pad[];
> @@ -95,6 +99,7 @@ struct vring {
>   *	__u16 used_flags;
>   *	__u16 used_idx;
>   *	struct vring_used_elem used[num];
> + *	__u16 last_avail_idx;
>   * };
>   */
>  static inline void vring_init(struct vring *vr, unsigned int num, void *p,
> @@ -111,9 +116,14 @@ static inline unsigned vring_size(unsign
>  {
>  	return ((sizeof(struct vring_desc) * num + sizeof(__u16) * (2 + num)
>  		 + align - 1) & ~(align - 1))
> -		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num;
> +		+ sizeof(__u16) * 2 + sizeof(struct vring_used_elem) * num + 2;
>  }
>  
> +/* We publish the last-seen used index at the end of the available ring, and
> + * vice-versa.  These are at the end for backwards compatibility. */
> +#define vring_last_used(vr) ((vr)->avail->ring[(vr)->num])
> +#define vring_last_avail(vr) (*(__u16 *)&(vr)->used->ring[(vr)->num])
> +

Will this last bit work on s390?
If I understand correctly the memory is allocated by host there?

>  #ifdef __KERNEL__
>  #include <linux/irqreturn.h>
>  struct virtio_device;
