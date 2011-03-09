From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 08:21:44 -0800
Message-ID: <1299687704.25664.106.camel@localhost.localdomain>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <201103091009.27932.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <201103091009.27932.tahm@linux.vnet.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-03-09 at 10:09 -0600, Tom Lendacky wrote:
> > 
> > > This spread out the kick_notify but still resulted in alot of
> them.  I
> > > decided to build on the delayed Tx buffer freeing and code up an
> > > "ethtool" like coalescing patch in order to delay the kick_notify
> until
> > > there were at least 5 packets on the ring or 2000 usecs, whichever
> > > occurred first.  Here are the
> > > 
> > > results of delaying the kick_notify (average of six runs):
> > >   Txn Rate: 107,106.36 Txn/Sec, Pkt Rate: 212,796 Pkts/Sec
> > >   Exits: 102,587.28 Exits/Sec
> > >   TxCPU: 3.03%  RxCPU: 99.33%
> > > 
> > > About a 23% increase over baseline and about 52% of baremetal.
> > > 
> > > Running the perf command against the guest I noticed almost 19% of
> the
> > > time being spent in _raw_spin_lock.  Enabling lockstat in the
> guest
> > > showed alot of contention in the "irq_desc_lock_class". Pinning
> the
> > > virtio1-input interrupt to a single cpu in the guest and
> re-running the
> > > last test resulted in
> > > 
> > > tremendous gains (average of six runs):
> > >   Txn Rate: 153,696.59 Txn/Sec, Pkt Rate: 305,358 Pkgs/Sec
> > >   Exits: 62,603.37 Exits/Sec
> > >   TxCPU: 3.73%  RxCPU: 98.52%
> > > 
> > > About a 77% increase over baseline and about 74% of baremetal.
> > > 
> > > Vhost is receiving a lot of notifications for packets that are to
> be
> > > transmitted (over 60% of the packets generate a kick_notify).
> Also, it
> > > looks like vhost is sending a lot of notifications for packets it
> has
> > > received before the guest can get scheduled to disable
> notifications and
> > > begin processing the packets
> > 
> > Hmm, is this really what happens to you?  The effect would be that
> guest
> > gets an interrupt while notifications are disabled in guest, right?
> Could
> > you add a counter and check this please?
> 
> The disabling of the interrupt/notifications is done by the guest.  So
> the 
> guest has to get scheduled and handle the notification before it
> disables 
> them.  The vhost_signal routine will keep injecting an interrupt until
> this 
> happens causing the contention in the guest.  I'll try the patches you
> specify 
> below and post the results.  They look like they should take care of
> this 
> issue.

In guest TX path, the guest interrupt should be disabled in the start
since it free_old_xmit_skbs in start_xmit call, it's not necessary to
receive any send completion interrupts to handle free old skbs. Then the
interrupt is only enabled when the netif queue is full. For multiple
streams TCP_RR test, we never hit netif queue full situation, the
cat /proc/interrupts/ send completion interrupts rate is 0, right?

Shirley

