From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH V2 2/2] vhost: device IOTLB API
Date: Thu, 28 Apr 2016 17:43:34 +0300
Message-ID: <20160428173543-mutt-send-email-mst@redhat.com>
References: <1458873274-13961-1-git-send-email-jasowang@redhat.com>
	<1458873274-13961-3-git-send-email-jasowang@redhat.com>
	<20160427143057-mutt-send-email-mst@redhat.com>
	<5721AF9C.9030209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <5721AF9C.9030209@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 02:37:16PM +0800, Jason Wang wrote:
> 
> 
> On 04/27/2016 07:45 PM, Michael S. Tsirkin wrote:
> > On Fri, Mar 25, 2016 at 10:34:34AM +0800, Jason Wang wrote:
> >> This patch tries to implement an device IOTLB for vhost. This could be
> >> used with for co-operation with userspace(qemu) implementation of DMA
> >> remapping.
> >>
> >> The idea is simple. When vhost meets an IOTLB miss, it will request
> >> the assistance of userspace to do the translation, this is done
> >> through:
> >>
> >> - Fill the translation request in a preset userspace address (This
> >>   address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
> >> - Notify userspace through eventfd (This eventfd was set through ioctl
> >>   VHOST_SET_IOTLB_FD).
> > Why use an eventfd for this?
> 
> The aim is to implement the API all through ioctls.
> 
> >  We use them for interrupts because
> > that happens to be what kvm wants, but here - why don't we
> > just add a generic support for reading out events
> > on the vhost fd itself?
> 
> I've considered this approach, but what's the advantages of this? I mean
> looks like all other ioctls could be done through vhost fd
> reading/writing too.

read/write have a non-blocking flag.

It's not useful for other ioctls but it's useful here.


> >
> >> - device IOTLB were started and stopped through VHOST_RUN_IOTLB ioctl
> >>
> >> When userspace finishes the translation, it will update the vhost
> >> IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
> >> snooping the IOTLB invalidation of IOMMU IOTLB and use
> >> VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.
> > There's one problem here, and that is that VQs still do not undergo
> > translation.  In theory VQ could be mapped in such a way
> > that it's not contigious in userspace memory.
> 
> I'm not sure I get the issue, current vhost API support setting
> desc_user_addr, used_user_addr and avail_user_addr independently. So
> looks ok? If not, looks not a problem to device IOTLB API itself.

The problem is that addresses are all HVA.

Without an iommu, we ask for them to be contigious and
since bus address == GPA, this means contigious GPA =>
contigious HVA. With an IOMMU you can map contigious
bus address but non contigious GPA and non contigious HVA.

Another concern: what if guest changes the GPA while keeping bus address
constant? Normal devices will work because they only use
bus addresses, but virtio will break.



> >
> >
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> > What limits amount of entries that kernel keeps around?
> 
> It depends on guest working set I think. Looking at
> http://dpdk.org/doc/guides/linux_gsg/sys_reqs.html:
> 
> - For 2MB page size in guest, it suggests hugepages=1024
> - For 1GB page size, it suggests a hugepages=4
> 
> So I choose 2048 to make sure it can cover this.

4K page size is rather common, too.

> > Do we want at least a mod parameter for this?
> 
> Maybe.
> 
> >
> >> ---
> >>  drivers/vhost/net.c        |   6 +-
> >>  drivers/vhost/vhost.c      | 301 +++++++++++++++++++++++++++++++++++++++------
> >>  drivers/vhost/vhost.h      |  17 ++-
> >>  fs/eventfd.c               |   3 +-
> >>  include/uapi/linux/vhost.h |  35 ++++++
> >>  5 files changed, 320 insertions(+), 42 deletions(-)
> >>
> 
> [...]
> 
> >> +struct vhost_iotlb_entry {
> >> +	__u64 iova;
> >> +	__u64 size;
> >> +	__u64 userspace_addr;
> > Alignment requirements?
> 
> The API does not require any alignment. Will add a comment for this.
> 
> >
> >> +	struct {
> >> +#define VHOST_ACCESS_RO      0x1
> >> +#define VHOST_ACCESS_WO      0x2
> >> +#define VHOST_ACCESS_RW      0x3
> >> +		__u8  perm;
> >> +#define VHOST_IOTLB_MISS           1
> >> +#define VHOST_IOTLB_UPDATE         2
> >> +#define VHOST_IOTLB_INVALIDATE     3
> >> +		__u8  type;
> >> +#define VHOST_IOTLB_INVALID        0x1
> >> +#define VHOST_IOTLB_VALID          0x2
> >> +		__u8  valid;
> > why do we need this flag?
> 
> Useless, will remove.
> 
> >
> >> +		__u8  u8_padding;
> >> +		__u32 padding;
> >> +	} flags;
> >> +};
> >> +
> >> +struct vhost_vring_iotlb_entry {
> >> +	unsigned int index;
> >> +	__u64 userspace_addr;
> >> +};
> >> +
> >>  struct vhost_memory_region {
> >>  	__u64 guest_phys_addr;
> >>  	__u64 memory_size; /* bytes */
> >> @@ -127,6 +153,15 @@ struct vhost_memory {
> >>  /* Set eventfd to signal an error */
> >>  #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
> >>  
> >> +/* IOTLB */
> >> +/* Specify an eventfd file descriptor to signle on IOTLB miss */
> > typo
> 
> Will fix it.
> 
> >
> >> +#define VHOST_SET_VRING_IOTLB_CALL _IOW(VHOST_VIRTIO, 0x23, struct      \
> >> +                                        vhost_vring_file)
> >> +#define VHOST_SET_VRING_IOTLB_REQUEST _IOW(VHOST_VIRTIO, 0x25, struct   \
> >> +                                           vhost_vring_iotlb_entry)
> >> +#define VHOST_UPDATE_IOTLB _IOW(VHOST_VIRTIO, 0x24, struct vhost_iotlb_entry)
> >> +#define VHOST_RUN_IOTLB _IOW(VHOST_VIRTIO, 0x26, int)
> >> +
> > Is the assumption that userspace must dedicate a thread to running the iotlb? 
> > I dislike this one.
> > Please support asynchronous APIs at least optionally to make
> > userspace make its own threading decisions.
> 
> Nope, my qemu patches does not use a dedicated thread. This API is used
> to start or top DMAR according to e.g whether guest enable DMAR for
> intel IOMMU.

I see. Seems rather confusing - do we need to start/stop it
while device is running?


> >
> >>  /* VHOST_NET specific defines */
> >>  
> >>  /* Attach virtio net ring to a raw socket, or tap device.
> > Don't we need a feature bit for this?
> 
> Yes we need it. The feature bit is not considered in this patch and
> looks like it was still under discussion. After we finalize it, I will add.
> 
> > Are we short on feature bits? If yes maybe it's time to add
> > something like PROTOCOL_FEATURES that we have in vhost-user.
> >
> 
> I believe it can just work like VERSION_1, or is there anything I missed?

VERSION_1 is a virtio feature though. This one would be backend specific
...


-- 
MST
