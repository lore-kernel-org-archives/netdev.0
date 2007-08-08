From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Thu, 9 Aug 2007 00:27:03 +0200
Message-ID: <20070808222703.GA11359@osiris.ibm.com>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com> <20070808.032131.35507346.davem@davemloft.net> <20070808102835.GC14530@osiris.boeblingen.de.ibm.com> <46BA30DC.20207@redhat.com> <20070808143115.de539511.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, andi@firstfloor.org,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:48577 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbXHHW1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 18:27:06 -0400
Content-Disposition: inline
In-Reply-To: <20070808143115.de539511.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 02:31:15PM -0700, Andrew Morton wrote:
> On Wed, 08 Aug 2007 17:08:44 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
> > Heiko Carstens wrote:
> > > On Wed, Aug 08, 2007 at 03:21:31AM -0700, David Miller wrote:
> > >> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > >> Date: Wed, 8 Aug 2007 11:33:00 +0200
> > >>
> > >>> Just saw this while grepping for atomic_reads in a while loops.
> > >>> Maybe we should re-add the volatile to atomic_t. Not sure.
> > >> I think whatever the choice, it should be done consistently
> > >> on every architecture.
> > >>
> > >> It's just asking for trouble if your arch does it differently from
> > >> every other.
> > > 
> > > Well..currently it's i386/x86_64 and s390 which have no volatile
> > > in atomic_t. And yes, of course I agree it should be consistent
> > > across all architectures. But it isn't.
> > 
> > Based on recent discussion, it's pretty clear that there's a lot of 
> > confusion about this.  A lot of people (myself included, until I thought 
> > about it long and hard) will reasonably assume that calling 
> > atomic_read() will actually read the value from memory.  Leaving out the 
> > volatile declaration seems like a pessimization to me.  If you force 
> > people to use barrier() everywhere they're working with atomic_t, it 
> > will force re-reads of all the non-atomic data in use as well, which 
> > will cause more memory fetches of things that generally don't need 
> > barrier().  That and it's a bug waiting to happen.
> > 
> > Andi -- your thoughts on the matter?
> 
> I'm not Andi, but this not-Andi thinks that permitting the compiler to cache
> the results of atomic_read() is dumb.

Ok, how about this:

Subject: [PATCH] Add 'volatile' to atomic_t again.

From: Heiko Carstens <heiko.carstens@de.ibm.com>

This basically reverts f9e9dcb38f5106fa8cdac04a9e967d5487f1cd20 which
removed 'volatile' from atomic_t for i386/x86_64. Reason for this
is to make sure that code like
while (atomic_read(&whatever));
continues to work.
Otherwise the compiler might generate code that will loop forever.
Also this makes sure atomic_t is the same across all architectures.

Cc: Andi Kleen <ak@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

s390 patch will go in via Martin if this is accepted.

 include/asm-i386/atomic.h   |    2 +-
 include/asm-x86_64/atomic.h |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/include/asm-i386/atomic.h
===================================================================
--- linux-2.6.orig/include/asm-i386/atomic.h
+++ linux-2.6/include/asm-i386/atomic.h
@@ -15,7 +15,7 @@
  * on us. We need to use _exactly_ the address the user gave us,
  * not some alias that contains the same information.
  */
-typedef struct { int counter; } atomic_t;
+typedef struct { volatile int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
Index: linux-2.6/include/asm-x86_64/atomic.h
===================================================================
--- linux-2.6.orig/include/asm-x86_64/atomic.h
+++ linux-2.6/include/asm-x86_64/atomic.h
@@ -22,7 +22,7 @@
  * on us. We need to use _exactly_ the address the user gave us,
  * not some alias that contains the same information.
  */
-typedef struct { int counter; } atomic_t;
+typedef struct { volatile int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
