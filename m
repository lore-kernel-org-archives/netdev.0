From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 14:12:09 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143B020@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2572 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S1751676AbWD0VMZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 17:12:25 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, johnpol@2ka.mipt.ru
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 27 Apr 2006 15:51:26 +0400
> 
>> There are some caveats here found while developing zero-copy sniffer
>> [1]. Project's goal was to remap skbs into userspace in real-time.
>> While absolute numbers (posted to netdev@) were really high, it is
>> only applicable to read-only application. As was shown in IOAT
>> thread, data must be warmed in caches, so reading from mapped area
>> will be as fast as memcpy() (read+write), and copy_to_user()
>> actually almost equal to memcpy() (benchmarks were posted to
>> netdev@). And we must add remapping overhead.
> 
> Yes, all of these issues are related quite strongly.  Thanks
> for making the connection explicit.
> 
> But, the mapping overhead is zero for this net channel stuff,
> at least as it is implemented and designed by Kelly.  Ring
> buffer is setup ahead of time into the user's address space,
> and a ring of buffers into that area are given to the networking card.
> 
> We remember the translations here, so no get_user_pages() on
> each transfer and garbage like that.  And yes this all harks
> back to the issues that are discussed in Chapter 5 of
> Networking Algorithmics.
> But the core thing to understand is that by defining a new
> API and setting up the buffer pool ahead of time, we avoid all of the
> get_user_pages() overhead while retaining full kernel/user protection.
> 
> Evgeniy, the difference between this and your work is that
> you did not have an intelligent piece of hardware that could
> be told to recognize flows, and only put packets for a
> specific flow into that's flow's buffer pool.
> 
>> If we want to dma data from nic into premapped userspace area, this
>> will strike with message sizes/misalignment/slow read and so on, so
>> preallocation has even more problems.
> 
> I do not really think this is an issue, we put the full
> packet into user space and teach it where the offset is to
> the actual data.
> We'll do the same things we do today to try and get the data
> area aligned.  User can do whatever is logical and relevant
> on his end to deal with strange cases.
> 
> In fact we can specify that card has to take some care to get
> data area of packet aligned on say an 8 byte boundary or
> something like that.  When we don't have hardware assist, we
> are going to be doing copies.
> 
>> This change also requires significant changes in application, at
>> least until recv/send are changed, which is not the best thing to do.
> 
> This is exactly the point, we can only do a good job and
> receive zero copy if we can change the interfaces, and that's
> exactly what we're doing here.
> 
>> I do think that significant win in VJ's tests belongs not to
>> remapping and cache-oriented changes, but to move all protocol
>> processing into process' context.
> 
> I partly disagree.  The biggest win is eliminating all of the
> control overhead (all of "softint RX + protocol demux + IP
> route lookup + socket lookup" is turned into single flow
> demux), and the SMP safe data structure which makes it
> realistic enough to always move the bulk of the packet work
> to the socket's home cpu.
> 
> I do not think userspace protocol implementation buys enough
> to justify it.  We have to do the protection switch in and
> out of kernel space anyways, so why not still do the
> protected protocol processing work in the kernel?  It is
> still being done on the user's behalf, contributes to his
> time slice, and avoids all of the terrible issues of
> userspace protocol implementations.
> 
> So in my mind, the optimal situation from both a protection
> preservation and also a performance perspective is net
> channels to kernel socket protocol processing, buffers DMA'd
> directly into userspace if hardware assist is present.
> 

Having a ring that is already flow qualified is indeed the
most important savings, and worth pursuing even if reaching
consensus on how to safely enable user-mode L4 processing.
The latter *can* be a big advantage when the L4 processing
can be done based on a user-mode call from an already
scheduled process. But the benefit is not there for a process
that needs to be woken up each time it receives a short request.

So the real issue is when there is an intelligent device that
uses hardware packet classification to place the packet in
the correct ring. We don't want to bypass packet filtering,
but it would be terribly wasteful to reclassify the packet.
Intelligent NICs will have packet classification capabilities
to support RDMA and iSCSI. Those capabilities should be available
to benefit SOCK_STREAM and SOCK_DGRAM users as well without it
being a choice of either turning all stack control over to
the NIC or ignorign all NIC capabilities beyound pretending
to be a dumb Ethernet NIC.

For example, counting packets within an approved connection
is a valid goal that the final solution should support. But
would a simple count be sufficient, or do we truly need the
full flexibility currently found in netfilter?

Obviously all of this does not need to be resolved in full
detail, but there should be some sense of the direction so
that data structures can be designed properly. My assumption
is that each input ring has a matching output ring, and that
the output ring cannot be used to send packets that would
not be matched by the reverse rule for the paired input ring.
So the information that supports enforcing that rule needs
to be stored somewhere other than the ring itself.

