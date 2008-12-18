From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 03/13] dmaengine: up-level reference counting to the
 module level
Date: Thu, 18 Dec 2008 14:26:00 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C984F5D@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D70C8F3405@irsmsx504.ger.corp.intel.com>
 <e9c3a7c20812151412va63c2ceob7d57ea91a8c208@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25898 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbYLRO1G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 09:27:06 -0500
In-Reply-To: <e9c3a7c20812151412va63c2ceob7d57ea91a8c208@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> On Fri, Dec 12, 2008 at 7:28 AM, Sosnowski, Maciej
> <maciej.sosnowski@intel.com> wrote:
>> Dan,
>>
>> General concern I see about this change is that it makes impossible
>> to rmmod ioatdma in case of NET_DMA enabled.
>> This is a specific case of situation when client is permanently
>> registered in dmaengine,
>> making it impossible to rmmod any device with "public" channels.
>> Ioatdma is just an example here.
>> However in ioatdma case it would be problematic now to switch
>> between CPU and DMA copy modes.
>> It seems that the only way to disable DMA after loading ioatdma
>> would be raising tcp_dma_copybreak to some high enough value to
>> direct all buffers to CPU copy path.
>> This way is yet rather more like hacking than "normal" usage way
>> (like "rmmod ioatdma" used so far).
>>
>
> Hi Maciej,
>
> I have been waiting for you to point this out because I believe it
> shows where more work is needed in net_dma.  The problem with net_dma
> is that it never says "I am done with dma channels".  The result was
> the old/complicated per-operation reference counting in dmaengine that
> lead to the, now deleted, comment for ioat_remove():
>
> /*
>  * It is unsafe to remove this module: if removed while a requested
>  * dma is outstanding, esp. from tcp, it is possible to hang while
>  * waiting for something that will never finish.  However, if you're
>  * feeling lucky, this usually works just fine.
>  */
>
> This also required the complexity of each client needing to handle
> asynchronous channel removal events.  In all other cases in the kernel
> a module is pinned as long as it has users, so dmaengine was backwards
> in this regard.
>
> Putting the end-node principal to work here means that the
> complexity/effort of determining when net_dma is done with channels
> should reside in net_dma, not dmaengine.  Since we cannot hook into a
> "rmmod net" event to drop the dmaengine reference we will need some
> out-of-band signal to enable "rmmod ioatdma" like detecting
> network-idle, or having an explicit "dma disable" sysctl.

Hi Dan,
I agree that net_dma needs to be modified
so that it releases dma channels if not used.
However in the mean time, as long as net_dma is not ready to do this,
the problem of "rmmod ioatdma" in the redesigned dmaengine remains...

>
>> Another issue I find problematic in this solution is that _any_
>> client
>> declaring its presence in dmaengine causes holding reference for
>> _all_ channels (and blocking them), does not matter if they are used
>> or not.
>> I agree with Guennadi's doubts here.
>> Why not at least hold a reference only for channels with
>> capabilities matching client's ones?
>>
>
> All channels share the same parent module, so taking a reference on
> one will always involve blocking all channels.

This is true for channels of the same device/module.
However, if we have two different devices with different capabilities,
should they both be blocked by single client?
For example, what is use of blocking channels of device
with DMA_MEMCPY capabilities only
by a client interested in DMA_XOR or DMA_MEMSET?

Thanks,
Maciej
