From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 21:03:16 +0200
Message-ID: <20101006190316.GB14825@redhat.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
 <20100919124443.GJ7350@redhat.com>
 <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com>
 <20101005182323.GA25852@redhat.com>
 <OF806283F6.38268772-ON652577B4.005E805A-652577B4.00611B1C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, herbert@gondor.hengli.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF806283F6.38268772-ON652577B4.005E805A-652577B4.00611B1C@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 06, 2010 at 11:13:31PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 10/05/2010 11:53:23 PM:
> 
> > > > Any idea where does this come from?
> > > > Do you see more TX interrupts? RX interrupts? Exits?
> > > > Do interrupts bounce more between guest CPUs?
> > > > 4. Identify reasons for single netperf BW regression.
> > >
> > > After testing various combinations of #txqs, #vhosts, #netperf
> > > sessions, I think the drop for 1 stream is due to TX and RX for
> > > a flow being processed on different cpus.
> >
> > Right. Can we fix it?
> 
> I am not sure how to. My initial patch had one thread but gave
> small gains and ran into limitations once number of sessions
> became large.

Sure. We will need multiple RX queues, and have a single
thread handle a TX and RX pair. Then we need to make sure packets
from a given flow on TX land on the same thread on RX.
As flows can be hashed differently, for this to work we'll have to
expose this info in host/guest interface.
But since multiqueue implies host/guest ABI changes anyway,
this point is moot.

BTW, an interesting approach could be using bonding
and multiple virtio-net interfaces.
What are the disadvantages of such a setup?  One advantage
is it can be made to work in existing guests.

> > >  I did two more tests:
> > >     1. Pin vhosts to same CPU:
> > >         - BW drop is much lower for 1 stream case (- 5 to -8% range)
> > >         - But performance is not so high for more sessions.
> > >     2. Changed vhost to be single threaded:
> > >           - No degradation for 1 session, and improvement for upto
> > >          8, sometimes 16 streams (5-12%).
> > >           - BW degrades after that, all the way till 128 netperf
> sessions.
> > >           - But overall CPU utilization improves.
> > >             Summary of the entire run (for 1-128 sessions):
> > >                 txq=4:  BW: (-2.3)      CPU: (-16.5)    RCPU: (-5.3)
> > >                 txq=16: BW: (-1.9)      CPU: (-24.9)    RCPU: (-9.6)
> > >
> > > I don't see any reasons mentioned above.  However, for higher
> > > number of netperf sessions, I see a big increase in retransmissions:
> >
> > Hmm, ok, and do you see any errors?
> 
> I haven't seen any in any statistics, messages, etc.

Herbert, could you help out debugging this increase in retransmissions
please?  Older mail on netdev in this thread has some numbers that seem
to imply that we start hitting retransmissions much more as # of flows
goes up.

> Also no
> retranmissions for txq=1.

While it's nice that we have this parameter, the need to choose between
single stream and multi stream performance when you start the vm makes
this patch much less interesting IMHO.


-- 
MST
