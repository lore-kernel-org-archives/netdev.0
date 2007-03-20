From: Joy Latten <latten@austin.ibm.com>
Subject: Possible solution to those doubly created SAs in ipsec
Date: Tue, 20 Mar 2007 17:32:38 -0600
Message-ID: <1174433558.3085.236.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, eparis@redhat.com, herbert@gondor.apana.org.au,
	vyekkirala@TrustedCS.com, jmorris@namei.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:57080 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXCTXtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 19:49:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2KNn1Xj023956
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 19:49:01 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2KNn1gK225380
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 19:49:01 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2KNn0Xj012983
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 19:49:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A while back I reported that I sometimes saw double and triple 
SAs being created. The patch to check for protocol when deleting
larval SA removed one obstacle in that I no longer see triple SAs. 
Now, once in a while double SAs. I think I have figured out the
second obstacle.

The initiator installs his SAs into the kernel before the responder.
As soon as they are installed, the blocked packet (which started
the ACQUIRE) is sent. By this time the responder has installed his
inbound SA(s) and so the newly arrived ipsec packet can be processed.
In the case of tcp connections and a ping, a response may be 
warranted, and thus an outgoing packet results. 

>From what I can tell of the log file below, sometimes, this
might happen before the responder has completed installing 
the outbound SAs. In the log file, the outbound AH has been added, 
but not the outbound ESP, which is the one the outgoing packet 
looks for first. Thus resulting in a second acquire. 

I think this becomes more problematic when using both AH AND ESP, 
rather than just using ESP with authentication. With the latter, 
only one SA needed thus reducing the latency in installing the 
SAs before incoming packet arrives.     

So far, the only solution I can think of besides mandating all 
userspace key daemons do SA maintenance is to perhaps add larval 
SAs for both directions when adding the SPI. Currently, responder 
does GETSPI for one way and initiator for opposite. When GETSPI is
called, larval SA is created containing the SPI, but it is only 
for one direction. Perhaps we can add a larval SA (no SPI) for 
opposite direction to act as a placeholder indicating ACQUIRE 
occurring, since SAs are created for both directions during an ACQUIRE.
The initiator may have larval SA from GETSPI and larval SA from the
ACQUIRE depending that GETSPI is in opposite direction of ACQUIRE.
Calling __find_acq_core() should ensure we don't create duplicate 
larval SAs. Also, should IKE negotiations return error, larval SAs
should expire. They also should be removed when we do the
xfrm_state_add() and xfrm_state_update() to add the new SAs.

If this is not a good idea or there is a better way to do this, please
let me know. I wanted to ask before coding and testing in case
there is a better solution and I won't have wasted time.

Regards,
Joy  

mylogfile (it has been cut and pasted, so irrelevant sections left out)

2007-03-20 13:39:04: DEBUG: pfkey UPDATE succeeded: AH/Transport 
x.x.x.210[0]->x.x.x.55[0] spi=203125341(0xc1b725d) 

2007-03-20 13:39:04: INFO: IPsec-SA established: AH/Transport
x.x.x.210[0]->x.x.x.55[0] spi=203125341(0xc1b725d)

2007-03-20 13:39:04: DEBUG: pfkey UPDATE succeeded: ESP/Transport
x.x.x.210[0]->x.x.x.55[0] spi=157349023(0x960f49f)

2007-03-20 13:39:04: INFO: IPsec-SA established: ESP/Transport
x.x.x.210[0]->x.x.x.55[0] spi=157349023(0x960f49f)

2007-03-20 13:39:04: DEBUG: ===

2007-03-20 13:39:04: DEBUG: get pfkey ADD message

2007-03-20 13:39:04: INFO: IPsec-SA established: AH/Transport
x.x.x.55[0]->x.x.x.x.210[0] spi=196161037(0xbb12e0d)

2007-03-20 13:39:04: DEBUG: ===

2007-03-20 13:39:04: DEBUG: get pfkey ACQUIRE message

2007-03-20 13:39:04: DEBUG: call pfkey_send_getspi

2007-03-20 13:39:04: DEBUG: pfkey GETSPI sent: AH/Transport
x.x.x.210[0]->x.x.x.55[0]

2007-03-20 13:39:04: DEBUG: call pfkey_send_getspi

2007-03-20 13:39:04: DEBUG: pfkey GETSPI sent: ESP/Transport
x.x.x.210[0]->x.x.x.55[0]

2007-03-20 13:39:04: DEBUG: pfkey getspi sent.

2007-03-20 13:39:04: DEBUG: get pfkey ADD message

2007-03-20 13:39:04: INFO: IPsec-SA established: ESP/Transport
x.x.x.55[0]->x.x.x.210[0] spi=241180149(0xe601df5)



