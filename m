From: linas@austin.ibm.com (Linas Vepstas)
Subject: NAPI wait before enabling irq's [was Re: [Cbe-oss-dev] Spider DMA wrongness]
Date: Thu, 14 Dec 2006 14:54:32 -0600
Message-ID: <20061214205432.GA4329@austin.ibm.com>
References: <OFBF8BBD4B.0E5AEA34-ON8725721F.005D5313-8625721F.005EAC5D@us.ibm.com> <1162931892.28571.497.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James K Lewis <jklewis@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	"cbe-oss-dev@ozlabs.org" <cbe-oss-dev@ozlabs.org>,
	cbe-oss-dev-bounces+jklewis=us.ibm.com@ozlabs.org,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:45799 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932637AbWLNUyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:54:39 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEKsXJf027491
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 15:54:33 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEKsXM5225996
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 15:54:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEKsWXr006458
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 15:54:33 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1162931892.28571.497.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 07:38:12AM +1100, Benjamin Herrenschmidt wrote:
> 
> What about Linas patches to do interrupt mitigation with NAPI polling ?
> That didn't end up working ?

It seems to be "working as designed", which is different than "working
as naively expected".

For large packets: 
-- a packet comes in
-- rx interrupt generated
-- rx interrupts turned off
-- tcp poll function runs, receives packet
-- completes all work before next packet has arrived, 
   so interupts are turned back on.
-- go to start

This results in a high number of interrupts, and a high cpu usage.
We were able to prove that napi works by stalling in the poll function
just long enough to allow the next packet to arrive.  In this case, 
napi works great, and number of irqs is vastly reduced. 

Unfortunately, I could not figure out any simple way of turning this
into acceptable code.  I can't just wait a little bit before turning 
on interrupts.  Some network apps, such as netpipe, want to receive 
something before sending the next thing. Without the interrupt, the
packet just sits there, and the OS doesn't realize (until milliseconds
later) that there's a packet that can be handled.  This is a variant
of the so-called "rotting packet" discussed in the napi docs.

What is needed is for the tcp stack to wait for 
  1500Bytes / (1Gbit/sec) = 12 microsecs
and then poll again. If there are *still* no new packets, then and
only then do we re-enable interrupts. This would require a new napi.
Presuming the network stack folks find it even remotely acceptable.

--linas

