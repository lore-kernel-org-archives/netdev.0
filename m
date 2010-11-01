From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Mon, 01 Nov 2010 13:17:53 -0700
Message-ID: <1288642673.19173.8.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
	 <1288286062.11251.15.camel@localhost.localdomain>
	 <20101029081027.GB22688@redhat.com>
	 <1288366988.4110.5.camel@localhost.localdomain>
	 <20101030200603.GA19033@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101030200603.GA19033@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-10-30 at 22:06 +0200, Michael S. Tsirkin wrote:
> On Fri, Oct 29, 2010 at 08:43:08AM -0700, Shirley Ma wrote:
> > On Fri, 2010-10-29 at 10:10 +0200, Michael S. Tsirkin wrote:
> > > Hmm. I don't yet understand. We are still doing copies into the
> per-vq
> > > buffer, and the data copied is really small.  Is it about cache
> line
> > > bounces?  Could you try figuring it out?
> > 
> > per-vq buffer is much less expensive than 3 put_copy() call. I will
> > collect the profiling data to show that.
> 
> What about __put_user? Maybe the access checks are the ones
> that add the cost here? I attach patches to strip access checks:
> they are not needed as we do them on setup time already, anyway.
> Can you try them out and see if performance is improved for you
> please?
> On top of this, we will need to add some scheme to accumulate signals,
> but that is a separate issue.

Yes, moving from put_user/get_user to __put_user/__get_user does improve
the performance by removing the checking.

My concern here is whether checking only in set up would be sufficient
for security? Would be there is a case guest could corrupt the ring
later? If not, that's OK.

> > > > > 2. How about flushing out queued stuff before we exit
> > > > >    the handle_tx loop? That would address most of
> > > > >    the spec issue. 
> > > > 
> > > > The performance is almost as same as the previous patch. I will
> > > resubmit
> > > > the modified one, adding vhost_add_used_and_signal_n after
> handle_tx
> > > > loop for processing pending queue.
> > > > 
> > > > This patch was a part of modified macvtap zero copy which I
> haven't
> > > > submitted yet. I found this helped vhost TX in general. This
> pending
> > > > queue will be used by DMA done later, so I put it in vq instead
> of a
> > > > local variable in handle_tx.
> > > > 
> > > > Thanks
> > > > Shirley
> > > 
> > > BTW why do we need another array? Isn't heads field exactly what
> we
> > > need
> > > here?
> > 
> > head field is only for up to 32, the more used buffers add and
> signal
> > accumulated the better performance is from test results.
> 
> I think we should separate the used update and signalling.  Interrupts
> are expensive so I can believe accumulating even up to 100 of them
> helps. But used head copies are already prety cheap. If we cut the
> overhead by x32, that should make them almost free?

I can separate the used update and signaling to see the best
performance.

> > That's was one
> > of the reason I didn't use heads. The other reason was I used these
> > buffer for pending dma done in mavctap zero copy patch. It could be
> up
> > to vq->num in worse case.
> 
> We can always increase that, not an issue. 

Good, I will change heads up to vq->num and use it.

Thanks
Shirley

