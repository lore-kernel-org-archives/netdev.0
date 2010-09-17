From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Fri, 17 Sep 2010 11:16:16 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792B8CAA04F9@shsmsx502.ccr.corp.intel.com>
References: <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
 <20100906111126.GA15608@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79280489A9C9@shsmsx502.ccr.corp.intel.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79280489AA05@shsmsx502.ccr.corp.intel.com>
 <20100912133703.GJ22982@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792B8C815365@shsmsx502.ccr.corp.intel.com>
 <20100915112811.GB29267@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100915112811.GB29267@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Michael S. Tsirkin [mailto:mst@redhat.com]
>Sent: Wednesday, September 15, 2010 7:28 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>
>On Wed, Sep 15, 2010 at 11:13:44AM +0800, Xin, Xiaohui wrote:
>> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
>> >Sent: Sunday, September 12, 2010 9:37 PM
>> >To: Xin, Xiaohui
>> >Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>> >mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>> >jdike@linux.intel.com
>> >Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>> >
>> >On Sat, Sep 11, 2010 at 03:41:14PM +0800, Xin, Xiaohui wrote:
>> >> >>Playing with rlimit on data path, transparently to the application in this way
>> >> >>looks strange to me, I suspect this has unexpected security implications.
>> >> >>Further, applications may have other uses for locked memory
>> >> >>besides mpassthru - you should not just take it because it's there.
>> >> >>
>> >> >>Can we have an ioctl that lets userspace configure how much
>> >> >>memory to lock? This ioctl will decrement the rlimit and store
>> >> >>the data in the device structure so we can do accounting
>> >> >>internally. Put it back on close or on another ioctl.
>> >> >Yes, we can decrement the rlimit in ioctl in one time to avoid
>> >> >data path.
>> >> >
>> >> >>Need to be careful for when this operation gets called
>> >> >>again with 0 or another small value while we have locked memory -
>> >> >>maybe just fail with EBUSY?  or wait until it gets unlocked?
>> >> >>Maybe 0 can be special-cased and deactivate zero-copy?.
>> >> >>
>> >>
>> >> How about we don't use a new ioctl, but just check the rlimit
>> >> in one MPASSTHRU_BINDDEV ioctl? If we find mp device
>> >> break the rlimit, then we fail the bind ioctl, and thus can't do
>> >> zero copy any more.
>> >
>> >Yes, and not just check, but decrement as well.
>> >I think we should give userspace control over
>> >how much memory we can lock and subtract from the rlimit.
>> >It's OK to add this as a parameter to MPASSTHRU_BINDDEV.
>> >Then increment the rlimit back on unbind and on close?
>> >
>> >This opens up an interesting condition: process 1
>> >calls bind, process 2 calls unbind or close.
>> >This will increment rlimit for process 2.
>> >Not sure how to fix this properly.
>> >
>> I can't too, can we do any synchronous operations on rlimit stuff?
>> I quite suspect in it.
>>
>> >--
>> >MST
>
>Here's what infiniband does: simply pass the amount of memory userspace
>wants you to lock on an ioctl, and verify that either you have
>CAP_IPC_LOCK or this number does not exceed the current rlimit.  (must
>be on ioctl, not on open, as we likely want the fd passed around between
>processes), but do not decrement rlimit.  Use this on following
>operations.  Be careful if this can be changed while operations are in
>progress.
>
>This does mean that the effective amount of memory that userspace can
>lock is doubled, but at least it is not unlimited, and we sidestep all
>other issues such as userspace running out of lockable memory simply by
>virtue of using the driver.
>

What I have done in mp device is almost the same as it. The difference is that
I do not check the capability, and I use my own parameter ctor->pages instead
of mm->locked_vm.

So currently, 1) add the capability check 2) use mm->locked_vm 3) add
an ioctl for userspace to configure how much memory can lock.
 
>--
>MST
