From: Donald Becker <becker@scyld.com>
Subject: RE: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Fri, 12 Sep 2003 11:29:00 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309121003430.1442-100000@beotest.scyld.com>
References: <1063370664.1028.85.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Feldman, Scott" <scott.feldman@intel.com>,
   Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
   <ricardoz@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1063370664.1028.85.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Sep 2003, jamal wrote:
> On Fri, 2003-09-12 at 01:13, Feldman, Scott wrote:
> > > Feldman, Scott wrote:
> > > > * Change the default number of Tx descriptors from 256 to 1024.
> > > >   Data from [ricardoz@us.ibm.com] shows it's easy to overrun
> > > >   the Tx desc queue.
> > > 
> > > You're just wasting memory.
> > 
> > 256 descriptors does sound like enough, but what about the fragmented
> > skb case?  MAX_SKB_FRAGS is (64K/4K + 2) = 18, and each fragment gets
> > mapped to one descriptor.
..
> Ok, i overlooked the frags part.
> Donald Becker is the man behind setting the # of descriptors to either
> 32 or 64 for 10/100. I think i saw some email from him once on how he
> reached the conclusion to choose those numbers.

The number varies between 10 and 16 skbuffs for 100Mbps, with a typical
Tx descriptor ring of 16 elements.

I spent much time instrumenting and measuring the behavior of the
drivers.  I found that with 100Mbps, between four and seven Tx skbuffs
were sufficient to keep the hardware Tx queue from emptying while there
were still packets in the software Tx queue.  Adding more neither
avoided gaps nor obviously improved the overall cache miss count.

With early Gb cards, Yellowfins, the numbers didn't increase nearly as
much as I expected.  I concluded:
  - At the time we were CPU limited generating tinygrams, thus the queue
    connection performance only mattered for full sized packets.
  - Increasing the link speed does not increase the tinygram series length 
    A series of tinygram are worst-case for the queue connection, since
    the hardware can dispatch them almost as quickly as the queue fills.
    But we don't get more tinygrams in a row with a faster link.

I could write extensively about the other parameters and designs that I
(mostly) confirmed and (occasionally) discoved.  They would be easy to
attack as being based on old hardware, but I believe that relative
numbers have changed little.  And I haven't seen any well-considered
analysis that would indicate 1000 driver queue entries is significantly
better than 20 in general purpose use.

> Note, this was before zero copy tx and skb frags.

[[ Grumble about mbufs and designing for a PDP omitted. ]]

Most users will see unfragmented skbuffs.
Even with fragmented skbuffs, you should average fewer than 2 frags per
skbuff.  With 9KB jumbo frames that might increase slightly.  Has anyone
measured more?  Or measured at all?

Remember the purpose of the driver (hardware) Tx queue.
It should be the minimum size consistent with
  Keeping the wire busy(1) when we have queued packets
  Cache locality(2) when queueing Tx packets
  Allowing interrupt mitigation
It is *not* supposed to act as an additional buffer in the system.
Unlike the queue layer, it cannot be changed dynamically, classify
packets, re-order based on priority or do any of the future clever
improvements possible with the general-purpose, device-independent
software queue. 

(1) A short gap with atypical traffic is entirely acceptable

(2) Cache locality isn't important because we need local performance.  It's
    important to minimize cache line displacement for the rest of the
    system, especially the application.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
914 Bay Ridge Road, Suite 220		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
