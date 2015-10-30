From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Fri, 30 Oct 2015 11:04:24 -0700
Message-ID: <5633B128.8010708@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <562A7E33.4080800@gmail.com> <562DBBC9.4000104@intel.com>
 <562E40BB.6040404@gmail.com> <5631B8CA.9040805@intel.com>
 <5631C3A7.2070900@gmail.com> <5631D9C2.2040206@intel.com>
 <56324682.5060507@gmail.com> <5632D8C8.3010101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5632D8C8.3010101@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2015 07:41 PM, Lan Tianyu wrote:
> On 2015=E5=B9=B410=E6=9C=8830=E6=97=A5 00:17, Alexander Duyck wrote:
>> On 10/29/2015 01:33 AM, Lan Tianyu wrote:
>>> On 2015=E5=B9=B410=E6=9C=8829=E6=97=A5 14:58, Alexander Duyck wrote=
:
>>>> Your code was having to do a bunch of shuffling in order to get th=
ings
>>>> set up so that you could bring the interface back up.  I would arg=
ue
>>>> that it may actually be faster at least on the bring-up to just dr=
op the
>>>> old rings and start over since it greatly reduced the complexity a=
nd the
>>>> amount of device related data that has to be moved.
>>> If give up the old ring after migration and keep DMA running before
>>> stopping VCPU, it seems we don't need to track Tx/Rx descriptor rin=
g and
>>> just make sure that all Rx buffers delivered to stack has been migr=
ated.
>>>
>>> 1) Dummy write Rx buffer before checking Rx descriptor to ensure pa=
cket
>>> migrated first.
>> Don't dummy write the Rx descriptor.  You should only really need to
>> dummy write the Rx buffer and you would do so after checking the
>> descriptor, not before.  Otherwise you risk corrupting the Rx buffer
>> because it is possible for you to read the Rx buffer, DMA occurs, an=
d
>> then you write back the Rx buffer and now you have corrupted the mem=
ory.
>>
>>> 2) Make a copy of Rx descriptor and then use the copied data to che=
ck
>>> buffer status. Not use the original descriptor because it won't be
>>> migrated and migration may happen between two access of the Rx
>>> descriptor.
>> Do not just blindly copy the Rx descriptor ring.  That is a recipe f=
or
>> disaster.  The problem is DMA has to happen in a very specific order=
 for
>> things to function correctly.  The Rx buffer has to be written and t=
hen
>> the Rx descriptor.  The problem is you will end up getting a read-ah=
ead
>> on the Rx descriptor ring regardless of which order you dirty things=
 in.
>
> Sorry, I didn't say clearly.
> I meant to copy one Rx descriptor when receive rx irq and handle Rx r=
ing.

No, I understood what you are saying.  My explanation was that it will=20
not work.

> Current code in the ixgbevf_clean_rx_irq() checks status of the Rx
> descriptor whether its Rx buffer has been populated data and then rea=
d
> the packet length from Rx descriptor to handle the Rx buffer.

That part you have correct.  However there are very explicit rules abou=
t=20
the ordering of the reads.

> My idea is to do the following three steps when receive Rx buffer in =
the
> ixgbevf_clean_rx_irq().
>
> (1) dummy write the Rx buffer first,

You cannot dummy write the Rx buffer without first being given ownershi=
p=20
of it.  In the driver this is handled in two phases. First we have to=20
read the DD bit to see if it is set.  If it is we can take ownership of=
=20
the buffer.  Second we have to either do a dma_sync_range_for_cpu or=20
dma_unmap_page call so that we can guarantee the data has been moved to=
=20
the buffer by the DMA API and that it knows it should no longer be=20
accessing it.

> (2) make a copy of its Rx descriptor

This is not advisable.  Unless you can guarantee you are going to only=20
read the descriptor after the DD bit is set you cannot guarantee that=20
you won't race with device DMA.  The problem is you could have the=20
migration occur right in the middle of (2).  If that occurs then you=20
will have valid status bits, but the rest of the descriptor would be=20
invalid data.

> (3) Check the buffer status and get length from the copy.

I believe this is the assumption that is leading you down the wrong=20
path.  You would have to read the status before you could do the copy. =
=20
You cannot do it after.

> Migration may happen every time.
> Happen between (1) and (2). If the Rx buffer has been populated data,=
 VF
> driver will not know that on the new machine because the Rx descripto=
r
> isn't migrated. But it's still safe.

The part I think you are not getting is that DMA can occur between (1)=20
and (2).  So if for example you were doing your dummy write while DMA=20
was occurring you pull in your value, DMA occurs, you write your value=20
and now you have corrupted an Rx frame by writing stale data back into =
it.

> Happen between (2) and (3). The copy will be migrated to new machine
> and Rx buffer is migrated firstly. If there is data in the Rx buffer,
> VF driver still can handle the buffer without migrating Rx descriptor=
=2E
>
> The next buffers will be ignored since we don't migrate Rx descriptor
> for them. Their status will be not completed on the new machine.

You have kind of lost me on this part.  Why do you believe there=20
statuses will not be completed?  How are you going to prevent the Rx=20
descriptor ring from being migrated as it will be a dirty page by the=20
virtue of the fact that it is a bidirectional DMA mapping where the Rx=20
path provides new buffers and writes those addresses in while the devic=
e=20
is writing back the status bits and length back.  This is kind of what =
I=20
was getting at.  The Rx descriptor ring will show up as one of the=20
dirtiest spots on the driver since it is constantly being overwritten b=
y=20
the CPU in ixgbevf_alloc_rx_buffers.

Anyway we are kind of getting side tracked and I really think the=20
solution you have proposed is kind of a dead-end.

What we have to do is come up with a solution that can deal with the=20
fact that you are racing against two different entities.  You have to=20
avoid racing with the device, while at the same time you have to avoid=20
racing with the dirty page migration code.  There are essentially 2=20
problems you have to solve.

1.  Rx pages handed off to the stack must be marked as dirty.  For now=20
your code seemed to address this via this snippet below from patch 12/1=
2:

> @@ -946,15 +949,17 @@ static struct sk_buff *ixgbevf_fetch_rx_buffer(=
struct ixgbevf_ring *rx_ring,
>   {
>   	struct ixgbevf_rx_buffer *rx_buffer;
>   	struct page *page;
> +	u8 *page_addr;
>  =20
>   	rx_buffer =3D &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
>   	page =3D rx_buffer->page;
>   	prefetchw(page);
>  =20
> -	if (likely(!skb)) {
> -		void *page_addr =3D page_address(page) +
> -				  rx_buffer->page_offset;
> +	/* Mark page dirty */
> +	page_addr =3D page_address(page) + rx_buffer->page_offset;
> +	*page_addr =3D *page_addr;
>  =20
> +	if (likely(!skb)) {
>   		/* prefetch first cache line of first page */
>   		prefetch(page_addr);
>   #if L1_CACHE_BYTES < 128

It will work for now as a proof of concept, but I really would prefer t=
o=20
see a solution that is driver agnostic.  Maybe something that could tak=
e=20
care of it in the DMA API.  For example if you were to use=20
"swiotlb=3Dforce" in the guest this code wouldn't even be necessary sin=
ce=20
that forces bounce buffers which would mean your DMA mappings are dirty=
=20
pages anyway.

2.  How to deal with a device that might be in the middle of an=20
interrupt routine when you decide to migrate.  This is the bit I think=20
you might be focusing on a bit too much, and the current solutions you=20
have proposed will result in Rx data corruption in the generic case eve=
n=20
without migration.  There are essentially 2 possible solutions that you=
=20
could explore.

2a.  Have a VF device that is aware something is taking place and have=20
it yield via something like a PCI hot-plug pause request.  I don't know=
=20
if the Linux kernel supports something like that now since pause suppor=
t=20
in the OS is optional in the PCI hot-plug specification, but essentiall=
y=20
it would be a request to do a PM suspend.  You would issue a hot-plug=20
pause and know when it is completed by the fact that the PCI Bus Master=
=20
bit is cleared in the VF.  Then you complete the migration and in the=20
new guest you could issue a hot-plug event to restart operation.

2b.  Come up with some sort of pseudo IOMMU interface the VF has to use=
=20
to map DMA, and provide an interface to quiesce the devices attached to=
=20
the VM so that DMA can no longer occur.  Once you have disabled bus=20
mastering on the VF you could then go through and migrate all DMA mappe=
d=20
pages.  As far as resuming on the other side you would somehow need to=20
poke the VF to get it to realize the rings are no longer initialized an=
d=20
the mailbox is out-of-sync.  Once that happens the VF could reset and=20
resume operation.
