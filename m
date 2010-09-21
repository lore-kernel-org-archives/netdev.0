From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Tue, 21 Sep 2010 15:14:22 +0200
Message-ID: <20100921131421.GA10439@redhat.com>
References: <20100915112811.GB29267@redhat.com>
 <1284970128-7343-1-git-send-email-xiaohui.xin@intel.com>
 <20100920113643.GB23898@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792B8CAA0F6A@shsmsx502.ccr.corp.intel.com>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D792B8CAA0F6A@shsmsx502.ccr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2010 at 09:39:31AM +0800, Xin, Xiaohui wrote:
> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
> >Sent: Monday, September 20, 2010 7:37 PM
> >To: Xin, Xiaohui
> >Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
> >mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
> >jdike@linux.intel.com
> >Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
> >
> >On Mon, Sep 20, 2010 at 04:08:48PM +0800, xiaohui.xin@intel.com wrote:
> >> From: Xin Xiaohui <xiaohui.xin@intel.com>
> >>
> >> ---
> >> Michael,
> >> I have move the ioctl to configure the locked memory to vhost
> >
> >It's ok to move this to vhost but vhost does not
> >know how much memory is needed by the backend.
> 
> I think the backend here you mean is mp device.
> Actually, the memory needed is related to vq->num to run zero-copy
> smoothly.
> That means mp device did not know it but vhost did.

Well, this might be so if you insist on locking
all posted buffers immediately. However, let's assume I have a
very large ring and prepost a ton of RX buffers:
there's no need to lock all of them directly:

if we have buffers A and B, we can lock A, pass it
to hardware, and when A is consumed unlock A, lock B
and pass it to hardware.


It's not really critical. But note we can always have userspace
tell MP device all it wants to know, after all.

> And the rlimt stuff is per process, we use current pointer to set
> and check the rlimit, the operations should be in the same process.

Well no, the ring is handled from the kernel thread: we switch the mm to
point to the owner task so copy from/to user and friends work, but you
can't access the rlimit etc.

> Now the check operations are in vhost process, as mp_recvmsg() or
> mp_sendmsg() are called by vhost.

Hmm, what do you mean by the check operations?
send/recv are data path operations, they shouldn't
do any checks, should they?

> So set operations should be in
> vhost process too, it's natural.
> 
> >So I think we'll need another ioctl in the backend
> >to tell userspace how much memory is needed?
> >
> Except vhost tells it to mp device, mp did not know
> how much memory is needed to run zero-copy smoothly.
> Is userspace interested about the memory mp is needed?

Couldn't parse this last question.
I think userspace generally does want control over
how much memory we'll lock. We should not just lock
as much as we can.

-- 
MST
