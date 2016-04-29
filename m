From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH V2 2/2] vhost: device IOTLB API
Date: Fri, 29 Apr 2016 12:44:07 +0800
Message-ID: <5722E697.1060600@redhat.com>
References: <1458873274-13961-1-git-send-email-jasowang@redhat.com>
	<1458873274-13961-3-git-send-email-jasowang@redhat.com>
	<20160427143057-mutt-send-email-mst@redhat.com>
	<5721AF9C.9030209@redhat.com>
	<20160428173543-mutt-send-email-mst@redhat.com>
	<5722B511.6060401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5722B511.6060401@redhat.com>
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



On 04/29/2016 09:12 AM, Jason Wang wrote:
> On 04/28/2016 10:43 PM, Michael S. Tsirkin wrote:
>> > On Thu, Apr 28, 2016 at 02:37:16PM +0800, Jason Wang wrote:
>>> >>
>>> >> On 04/27/2016 07:45 PM, Michael S. Tsirkin wrote:
>>>> >>> On Fri, Mar 25, 2016 at 10:34:34AM +0800, Jason Wang wrote:
>>>>> >>>> This patch tries to implement an device IOTLB for vhost. This could be
>>>>> >>>> used with for co-operation with userspace(qemu) implementation of DMA
>>>>> >>>> remapping.
>>>>> >>>>
>>>>> >>>> The idea is simple. When vhost meets an IOTLB miss, it will request
>>>>> >>>> the assistance of userspace to do the translation, this is done
>>>>> >>>> through:
>>>>> >>>>
>>>>> >>>> - Fill the translation request in a preset userspace address (This
>>>>> >>>>   address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
>>>>> >>>> - Notify userspace through eventfd (This eventfd was set through ioctl
>>>>> >>>>   VHOST_SET_IOTLB_FD).
>>>> >>> Why use an eventfd for this?
>>> >> The aim is to implement the API all through ioctls.
>>> >>
>>>> >>>  We use them for interrupts because
>>>> >>> that happens to be what kvm wants, but here - why don't we
>>>> >>> just add a generic support for reading out events
>>>> >>> on the vhost fd itself?
>>> >> I've considered this approach, but what's the advantages of this? I mean
>>> >> looks like all other ioctls could be done through vhost fd
>>> >> reading/writing too.
>> > read/write have a non-blocking flag.
>> >
>> > It's not useful for other ioctls but it's useful here.
>> >
> Ok, this looks better.
>
>>>>> >>>> - device IOTLB were started and stopped through VHOST_RUN_IOTLB ioctl
>>>>> >>>>
>>>>> >>>> When userspace finishes the translation, it will update the vhost
>>>>> >>>> IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
>>>>> >>>> snooping the IOTLB invalidation of IOMMU IOTLB and use
>>>>> >>>> VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.
>>>> >>> There's one problem here, and that is that VQs still do not undergo
>>>> >>> translation.  In theory VQ could be mapped in such a way
>>>> >>> that it's not contigious in userspace memory.
>>> >> I'm not sure I get the issue, current vhost API support setting
>>> >> desc_user_addr, used_user_addr and avail_user_addr independently. So
>>> >> looks ok? If not, looks not a problem to device IOTLB API itself.
>> > The problem is that addresses are all HVA.
>> >
>> > Without an iommu, we ask for them to be contigious and
>> > since bus address == GPA, this means contigious GPA =>
>> > contigious HVA. With an IOMMU you can map contigious
>> > bus address but non contigious GPA and non contigious HVA.
> Yes, so the issue is we should not reuse VHOST_SET_VRING_ADDR and invent
> a new ioctl to set bus addr (guest iova). The access the VQ through
> device IOTLB too.

Note that userspace has checked for this and fallback to userspace if it
detects non contiguous GPA. Consider this happens rare, I'm not sure we
should handle this.

>
>> >
>> > Another concern: what if guest changes the GPA while keeping bus address
>> > constant? Normal devices will work because they only use
>> > bus addresses, but virtio will break.
> If we access VQ through device IOTLB too, this could be solved.
>

I don't see a reason why guest want change GPA during DMA. Even if it
can, it needs lots of other synchronization.
