From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v1 6/8] dmaengine: enhance network subsystem to support
 DMA device hotplug
Date: Mon, 23 Apr 2012 20:09:40 -0700
Message-ID: <CABE8wwvW9MUWaqSUCPMr7_yj7XGtSj+X9VE1-xWrEusZ3TMaqQ@mail.gmail.com>
References: <1335189109-4871-1-git-send-email-jiang.liu@huawei.com>
	<1335189109-4871-7-git-send-email-jiang.liu@huawei.com>
	<CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com>
	<4F961041.7010106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jiang Liu <liuj97@gmail.com>, Vinod Koul <vinod.koul@intel.com>,
	Keping Chen <chenkeping@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiang Liu <jiang.liu@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4F961041.7010106@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 23, 2012 at 7:30 PM, Jiang Liu <jiang.liu@huawei.com> wrote:
>> If you are going to hotplug the entire IOH, then you are probably ok
>> with network links going down, so could you just down the links and
>> remove the driver with the existing code?
>
> I feel it's a little risky to shut down/restart all network interfaces
> for hot-removal of IOH, that may disturb the applications.

I guess I'm confused... wouldn't the removal of an entire domain of
pci devices disturb userspace applications?

> And there
> are also other kinds of clients, such as ASYNC_TX, seems we can't
> adopt this method to reclaim DMA channels from ASYNC_TX subsystem.

I say handle this like block device hotplug.  I.e. the driver stays
loaded but the channel is put into an 'offline' state.  So the driver
hides the fact that the hardware went away.  Similar to how you can
remove a disk but /dev/sda sticks around until the last reference is
gone (and the driver 'sd' sticks around until all block devices are
gone).

I expect the work will be in making sure existing clients are prepared
to handle NULL returns from ->device_prep_dma_*.  In some cases the
channel is treated more like a cpu, so a NULL return from
->device_prep_dma_memcpy() has been interpreted as "device is
temporarily busy, it is safe to try again".  We would need to change
that to a permanent indication that the device is gone and not attempt
retry.

--
Dan
