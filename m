From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Sun, 12 Sep 2010 15:37:03 +0200
Message-ID: <20100912133703.GJ22982@redhat.com>
References: <1281086624-5765-8-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-9-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
 <20100906111126.GA15608@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79280489A9C9@shsmsx502.ccr.corp.intel.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79280489AA05@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D79280489AA05@shsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 11, 2010 at 03:41:14PM +0800, Xin, Xiaohui wrote:
> >>Playing with rlimit on data path, transparently to the application in this way
> >>looks strange to me, I suspect this has unexpected security implications.
> >>Further, applications may have other uses for locked memory
> >>besides mpassthru - you should not just take it because it's there.
> >>
> >>Can we have an ioctl that lets userspace configure how much
> >>memory to lock? This ioctl will decrement the rlimit and store
> >>the data in the device structure so we can do accounting
> >>internally. Put it back on close or on another ioctl.
> >Yes, we can decrement the rlimit in ioctl in one time to avoid
> >data path.
> >
> >>Need to be careful for when this operation gets called
> >>again with 0 or another small value while we have locked memory -
> >>maybe just fail with EBUSY?  or wait until it gets unlocked?
> >>Maybe 0 can be special-cased and deactivate zero-copy?.
> >>
> 
> How about we don't use a new ioctl, but just check the rlimit 
> in one MPASSTHRU_BINDDEV ioctl? If we find mp device
> break the rlimit, then we fail the bind ioctl, and thus can't do 
> zero copy any more.

Yes, and not just check, but decrement as well.
I think we should give userspace control over
how much memory we can lock and subtract from the rlimit.
It's OK to add this as a parameter to MPASSTHRU_BINDDEV.
Then increment the rlimit back on unbind and on close?

This opens up an interesting condition: process 1
calls bind, process 2 calls unbind or close.
This will increment rlimit for process 2.
Not sure how to fix this properly.

-- 
MST
