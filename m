From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 20:05:38 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
 <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
 <46C30540.2070603@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47456 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010AbXHOOXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 10:23:16 -0400
In-Reply-To: <46C30540.2070603@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stefan,


On Wed, 15 Aug 2007, Stefan Richter wrote:

> On 8/15/2007 10:18 AM, Heiko Carstens wrote:
> > On Wed, Aug 15, 2007 at 02:49:03PM +0800, Herbert Xu wrote:
> >> Chris Snook <csnook@redhat.com> wrote:
> >> > 
> >> > Because atomic operations are generally used for synchronization, which requires 
> >> > volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
> >> >  Some forget to and we get bugs, because people assume that atomic_read() 
> >> > actually reads something, and atomic_write() actually writes something.  Worse, 
> >> > these are architecture-specific, even compiler version-specific bugs that are 
> >> > often difficult to track down.
> >> 
> >> I'm yet to see a single example from the current tree where
> >> this patch series is the correct solution.  So far the only
> >> example has been a buggy piece of code which has since been
> >> fixed with a cpu_relax.
> > 
> > Btw.: we still have
> > 
> > include/asm-i386/mach-es7000/mach_wakecpu.h:  while (!atomic_read(deassert));
> > include/asm-i386/mach-default/mach_wakecpu.h: while (!atomic_read(deassert));
> > 
> > Looks like they need to be fixed as well.
> 
> 
> I don't know if this here is affected:

Yes, I think it is. You're clearly expecting the read to actually happen
when you call get_hpsb_generation(). It's clearly not a busy-loop, so
cpu_relax() sounds pointless / wrong solution for this case, so I'm now
somewhat beginning to appreciate the motivation behind this series :-)

But as I said, there are ways to achieve the same goals of this series
without using "volatile".

I think I'll submit a RFC/patch or two on this myself (will also fix
the code pieces listed here).


> /* drivers/ieee1394/ieee1394_core.h */
> static inline unsigned int get_hpsb_generation(struct hpsb_host *host)
> {
> 	return atomic_read(&host->generation);
> }
> 
> /* drivers/ieee1394/nodemgr.c */
> static int nodemgr_host_thread(void *__hi)
> {
> 	[...]
> 
> 	for (;;) {
> 		[... sleep until bus reset event ...]
> 
> 		/* Pause for 1/4 second in 1/16 second intervals,
> 		 * to make sure things settle down. */
> 		g = get_hpsb_generation(host);
> 		for (i = 0; i < 4 ; i++) {
> 			if (msleep_interruptible(63) ||
> 			    kthread_should_stop())
> 				goto exit;

Totally unrelated, but this looks weird. IMHO you actually wanted:

	msleep_interruptible(63);
	if (kthread_should_stop())
		goto exit;

here, didn't you? Otherwise the thread will exit even when
kthread_should_stop() != TRUE (just because it received a signal),
and it is not good for a kthread to exit on its own if it uses
kthread_should_stop() or if some other piece of kernel code could
eventually call kthread_stop(tsk) on it.

Ok, probably the thread will never receive a signal in the first
place because it's spawned off kthreadd which ignores all signals
beforehand, but still ...

[PATCH] ieee1394: Fix kthread stopping in nodemgr_host_thread

The nodemgr host thread can exit on its own even when kthread_should_stop
is not true, on receiving a signal (might never happen in practice, as
it ignores signals). But considering kthread_stop() must not be mixed with
kthreads that can exit on their own, I think changing the code like this
is clearer. This change means the thread can cut its sleep short when
receive a signal but looking at the code around, that sounds okay (and
again, it might never actually recieve a signal in practice).

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/ieee1394/nodemgr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/ieee1394/nodemgr.c b/drivers/ieee1394/nodemgr.c
index 2ffd534..981a7da 100644
--- a/drivers/ieee1394/nodemgr.c
+++ b/drivers/ieee1394/nodemgr.c
@@ -1721,7 +1721,8 @@ static int nodemgr_host_thread(void *__hi)
 		 * to make sure things settle down. */
 		g = get_hpsb_generation(host);
 		for (i = 0; i < 4 ; i++) {
-			if (msleep_interruptible(63) || kthread_should_stop())
+			msleep_interruptible(63);
+			if (kthread_should_stop())
 				goto exit;
 
 			/* Now get the generation in which the node ID's we collect
