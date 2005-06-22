From: Donald Becker <becker@scyld.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 17:08:23 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com>
References: <20050621223436.GG14251@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050621223436.GG14251@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Jun 2005, Andi Kleen wrote:

> > While much has changed since then, the same basic parameters remain
> >    - cache line size
> 
> In 96 we had 32 byte cache lines. These days 64-128 are common,
> with some 256 byte cache line systems around.

Good point.
I believe that the most common line size is 64 bytes for L1 cache.

Most L2 caches that have larger line sizes still fill only 64 byte 
blocks unless prefetching is triggered.  (Feel free to correct me with 
non-obscure CPUs and relevant cases.  For instance, I know that on the 
Itanium the 128 byte line L2 cache is used as L1, but only for FPU 
fetches.  That doesn't count.)
 
The implication here is that as soon as we look at the first byte of the 
MAC address, we have read in 64 bytes.  That's a whole minimum-size 
EThernet frame.

> >    - frame header size (MAC+IP+ProtocolHeader)
> 
> In 96 people tended to not use time stamps.

Ehh, not a big difference.
 
> >    - hot cache lines from copying or type classification
> Not sure what you mean with that.

See the comment above. We decide if a packet is multicast vs. unicast, IP 
vs. other at approximately interrupt/"rx_copybreak" time.  Very few NIC 
provide this info in status bits, so we end up looking at the packet 
header.  That read moves the previously known-uncached data (after all, it 
was just came in from a bus write) into the L1 cache for the CPU handling 
the device.  Once it's there, the copy is almost free.

[[ Background: Yes, the allocating the new skbuff is very expensive.  But 
we can either allocate a new, correctly-sized skbuff to copy into, or 
allocate a new full-sized skbuff to replace the one we will send to the Rx 
queue.  ]] 
 
> >    - cold memory lines from PCI writes
> 
> I suspect in '96 chipsets also didn't do as aggressive prefetching
> as they do today.

Prefetching helps linear read bandwidth, but we shouldn't be triggering 
it.  And I claim that cache line prefetching only restores the relative
balance between L1/L2 caches, otherwise the long L2 cache lines would be 
very expensive with bump-read-bump-read with linear scans through memory.

-- 
Donald Becker				becker@scyld.com
Scyld Software	 			Scyld Beowulf cluster systems
914 Bay Ridge Road, Suite 220		www.scyld.com
Annapolis MD 21403			410-990-9993
