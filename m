From: Jiang Liu <jiang.liu@huawei.com>
Subject: Re: [PATCH v1 6/8] dmaengine: enhance network subsystem to support DMA
 device hotplug
Date: Tue, 24 Apr 2012 11:56:10 +0800
Message-ID: <4F96245A.4080000@huawei.com>
References: <1335189109-4871-1-git-send-email-jiang.liu@huawei.com>
 <1335189109-4871-7-git-send-email-jiang.liu@huawei.com>
 <CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com>
 <4F961041.7010106@huawei.com>
 <CABE8wwvW9MUWaqSUCPMr7_yj7XGtSj+X9VE1-xWrEusZ3TMaqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jiang Liu <liuj97@gmail.com>, Vinod Koul <vinod.koul@intel.com>,
	Keping Chen <chenkeping@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-reply-to: <CABE8wwvW9MUWaqSUCPMr7_yj7XGtSj+X9VE1-xWrEusZ3TMaqQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-4-24 11:09, Dan Williams wrote:
> On Mon, Apr 23, 2012 at 7:30 PM, Jiang Liu<jiang.liu@huawei.com>  wrote:
>>> If you are going to hotplug the entire IOH, then you are probably ok
>>> with network links going down, so could you just down the links and
>>> remove the driver with the existing code?
>>
>> I feel it's a little risky to shut down/restart all network interfaces
>> for hot-removal of IOH, that may disturb the applications.
>
> I guess I'm confused... wouldn't the removal of an entire domain of
> pci devices disturb userspace applications?
Here I mean removing an IOH shouldn't affect devices under other IOHs
if possible.
With current dmaengine implementation, a DMA device/channel may be used
by clients in other PCI domains. So to safely remove a DMA device, we
need to return dmaengine_ref_count to zero by stopping all DMA clients.
For network, that means we need to stop all network interfaces, seems
a little heavy:)

>
>> And there
>> are also other kinds of clients, such as ASYNC_TX, seems we can't
>> adopt this method to reclaim DMA channels from ASYNC_TX subsystem.
>
> I say handle this like block device hotplug.  I.e. the driver stays
> loaded but the channel is put into an 'offline' state.  So the driver
> hides the fact that the hardware went away.  Similar to how you can
> remove a disk but /dev/sda sticks around until the last reference is
> gone (and the driver 'sd' sticks around until all block devices are
> gone).
Per my understanding, this mechanism could be used to stop driver from
accessing surprisingly removed devices, but it still needs a reference
count mechanism to finish the driver unbinding operation eventually.

For IOH hotplug, we need to wait for the completion of driver unbinding
operations before destroying the PCI device nodes of IOAT, so still need
reference count to track channel usage.

Another way is to notify all clients to release all channels when IOAT
device hotplug happens, but that may need heavy modification to the
DMA clients.

>
> I expect the work will be in making sure existing clients are prepared
> to handle NULL returns from ->device_prep_dma_*.  In some cases the
> channel is treated more like a cpu, so a NULL return from
> ->device_prep_dma_memcpy() has been interpreted as "device is
> temporarily busy, it is safe to try again".  We would need to change
> that to a permanent indication that the device is gone and not attempt
> retry.
Yes, some ASYNC_TX clients interpret NULL return as EBUSY and keep on
retry when doing context aware computations. Will try to investigate
on this direction.

>
> --
> Dan
>
> .
>
