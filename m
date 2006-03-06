From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Mon, 6 Mar 2006 11:48:06 -0800
Message-ID: <41b516cb0603061148v4f93778cs6b954bbb48bc25c6@mail.gmail.com>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	 <20060303214220.11908.75517.stgit@gitlost.site>
	 <20060304192030.GA6510@kvack.org>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752414AbWCFTsJ@vger.kernel.org>
To: "Benjamin LaHaise" <bcrl@kvack.org>
In-Reply-To: <20060304192030.GA6510@kvack.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/4/06, Benjamin LaHaise <bcrl@kvack.org> wrote:
> On Fri, Mar 03, 2006 at 01:42:20PM -0800, Chris Leech wrote:
> > +void dma_async_device_unregister(struct dma_device* device)
> > +{
> ...
> > +     kref_put(&device->refcount, dma_async_device_cleanup);
> > +     wait_for_completion(&device->done);
> > +}
>
> This looks like a bug: device is dereferenced after it is potentially
> freed.

Actually, this is where the code is waiting to make sure it's safe to
free device.  The release function for the kref completes
device->done.  Each of the devices channels holds a reference to the
device.  When a device is unregistered it's channels are removed from
the clients, which hold a reference for each outstanding transaction. 
When all the outstanding transactions complete, the channels kref goes
to 0, and the reference to the device is dropped.  When the device
kref goes to 0 the completion is set, and it's now safe to free the
memory for the device and channel structures.

I have a writeup of the locking and reference counting that I'll
finish and add in as a big comment to the code.

-Chris
