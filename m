From: Yang Zhang <yang.zhang.wz@gmail.com>
Subject: Re: [PATCH RFC] vhost: basic device IOTLB support
Date: Tue, 5 Jan 2016 11:18:16 +0800
Message-ID: <568B35F8.7080302@gmail.com>
References: <1451546025-15955-1-git-send-email-jasowang@redhat.com>
	<5689CD59.6030900@gmail.com> <568A0FA6.8080804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <568A0FA6.8080804@redhat.com>
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

On 2016/1/4 14:22, Jason Wang wrote:
>
>
> On 01/04/2016 09:39 AM, Yang Zhang wrote:
>> On 2015/12/31 15:13, Jason Wang wrote:
>>> This patch tries to implement an device IOTLB for vhost. This could be
>>> used with for co-operation with userspace(qemu) implementation of
>>> iommu for a secure DMA environment in guest.
>>>
>>> The idea is simple. When vhost meets an IOTLB miss, it will request
>>> the assistance of userspace to do the translation, this is done
>>> through:
>>>
>>> - Fill the translation request in a preset userspace address (This
>>>     address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
>>> - Notify userspace through eventfd (This eventfd was set through ioctl
>>>     VHOST_SET_IOTLB_FD).
>>>
>>> When userspace finishes the translation, it will update the vhost
>>> IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
>>> snooping the IOTLB invalidation of IOMMU IOTLB and use
>>> VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.
>>
>> Is there any performance data shows the difference with IOTLB supporting?
>
> Basic testing show it was slower than without IOTLB.
>
>> I doubt we may see performance decrease since the flush code path is
>> longer than before.
>>
>
> Yes, it also depend on the TLB hit rate.
>
> If lots of dynamic mappings and unmappings are used in guest (e.g normal
> Linux driver). This method should be much more slower since:
>
> - lots of invalidation and its path is slow.
> - the hit rate is low and the high price of userspace assisted address
> translation.
> - limitation of userspace IOMMU/IOTLB implementation (qemu's vtd
> emulation simply empty all entries when it's full).
>
> Another method is to implement kernel IOMMU (e.g vtd). But I'm not sure
> vhost is the best place to do this, since vhost should be architecture
> independent. Maybe we'd better to do it in kvm or have a pv IOMMU
> implementation in vhost.

Actually, i have the kernel IOMMU(virtual vtd) patch which can pass 
though the physical device to L2 guest on hand. But it is just a draft 
patch which was written several years ago. If there is real requirement 
for it, I can rebase it and send out it for review.

>
> Another side, if fixed mappings were used in guest, (e.g dpdk in guest).
> We have the possibility to have 100% hit rate with almost no
> invalidation, the performance penalty should be ignorable, this should
> be the main use case for this patch.
>
> The patch is just a prototype for discussion. Any other ideas are welcomed.
>
> Thanks
>


-- 
best regards
yang
