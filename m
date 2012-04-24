From: Jiang Liu <jiang.liu@huawei.com>
Subject: Re: [PATCH v1 6/8] dmaengine: enhance network subsystem to support DMA
 device hotplug
Date: Tue, 24 Apr 2012 10:30:25 +0800
Message-ID: <4F961041.7010106@huawei.com>
References: <1335189109-4871-1-git-send-email-jiang.liu@huawei.com>
 <1335189109-4871-7-git-send-email-jiang.liu@huawei.com>
 <CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,
	Thanks for your great comments!
	gerry
On 2012-4-24 2:30, Dan Williams wrote:
> On Mon, Apr 23, 2012 at 6:51 AM, Jiang Liu<liuj97@gmail.com>  wrote:
>> Enhance network subsystem to correctly update DMA channel reference counts,
>> so it won't break DMA device hotplug logic.
>>
>> Signed-off-by: Jiang Liu<liuj97@gmail.com>
>
> This introduces an atomic action on every channel touch, which is more
> expensive than what we had previously.  There has always been a
> concern about the overhead of offload that sometimes makes ineffective
> or a loss compared to cpu copies.  In the cases where net_dma shows
> improvement this will eat into / maybe eliminate that advantage.
Good point, we should avoid pollute a shared cacheline here, otherwise
it may eat the benefits of IOAT acceleration.

>
> Take a look at where dmaengine started [1].  It was from the beginning
> going through contortions to avoid something like this.  We made it
> simpler here [2], but still kept the principle of not dirtying a
> shared cacheline on every channel touch, and certainly not locking it.
Thanks for the great background information, especially the second one.
The check-in log message as below.
 >Why?, beyond reducing complication:
 >1/ Tracking reference counts per-transaction in an efficient manner, as
 >   is currently done, requires a complicated scheme to avoid cache-line
 >   bouncing effects.
The really issue here is polluting shared cachelines here, right?
Will it help to use percpu counter instead of atomic operations here?
I will have a try to use percpu counter for reference count.
BTW, do you have any DMAEngine benchmarks so we could use them to
compare the performance difference?

 >2/ Per-transaction ref-counting gives the false impression that a
 >   dma-driver can be gracefully removed ahead of its user (net, md, or
 >   dma-slave)
 >3/ None of the in-tree dma-drivers talk to hot pluggable hardware, but
Seems the situation has changed now:)
Intel 7500 (Boxboro) chipset supports hotplug. And we are working on
a system, which adopts Boxboro chipset and supports node hotplug.
So we try to enhance the DMAEngine to support IOAT hotplug.

On the other hand, Intel next generation processor Ivybridge has
embedded IOH, so we need to support IOH/IOAT hotplug when supporting
processor hotplug.

 >   if such an engine were built one day we still would not need to >notify
 >   clients of remove events.  The driver can simply return NULL to a
 >   ->prep() request, something that is much easier for a client to 
 >handle.
Could you please help to give more explanations about "The driver can
simply return NULL to a ->prep() request", I have gotten the idea yet.

>
> If you are going to hotplug the entire IOH, then you are probably ok
> with network links going down, so could you just down the links and
> remove the driver with the existing code?
I feel it's a little risky to shut down/restart all network interfaces
for hot-removal of IOH, that may disturb the applications. And there
are also other kinds of clients, such as ASYNC_TX, seems we can't
adopt this method to reclaim DMA channels from ASYNC_TX subsystem.

>
> --
> Dan
>
> [1]: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=c13c826
> [2]: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=6f49a57a
>
> .
>
