From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 15:53:04 +0200
Message-ID: <46C30540.2070603@s5r6.in-berlin.de>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>, satyam@infradead.org,
	clameter@sgi.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:38301 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521AbXHONxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 09:53:06 -0400
In-Reply-To: <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/15/2007 10:18 AM, Heiko Carstens wrote:
> On Wed, Aug 15, 2007 at 02:49:03PM +0800, Herbert Xu wrote:
>> Chris Snook <csnook@redhat.com> wrote:
>> > 
>> > Because atomic operations are generally used for synchronization, which requires 
>> > volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
>> >  Some forget to and we get bugs, because people assume that atomic_read() 
>> > actually reads something, and atomic_write() actually writes something.  Worse, 
>> > these are architecture-specific, even compiler version-specific bugs that are 
>> > often difficult to track down.
>> 
>> I'm yet to see a single example from the current tree where
>> this patch series is the correct solution.  So far the only
>> example has been a buggy piece of code which has since been
>> fixed with a cpu_relax.
> 
> Btw.: we still have
> 
> include/asm-i386/mach-es7000/mach_wakecpu.h:  while (!atomic_read(deassert));
> include/asm-i386/mach-default/mach_wakecpu.h: while (!atomic_read(deassert));
> 
> Looks like they need to be fixed as well.


I don't know if this here is affected:

/* drivers/ieee1394/ieee1394_core.h */
static inline unsigned int get_hpsb_generation(struct hpsb_host *host)
{
	return atomic_read(&host->generation);
}

/* drivers/ieee1394/nodemgr.c */
static int nodemgr_host_thread(void *__hi)
{
	[...]

	for (;;) {
		[... sleep until bus reset event ...]

		/* Pause for 1/4 second in 1/16 second intervals,
		 * to make sure things settle down. */
		g = get_hpsb_generation(host);
		for (i = 0; i < 4 ; i++) {
			if (msleep_interruptible(63) ||
			    kthread_should_stop())
				goto exit;

	/* Now get the generation in which the node ID's we collect
	 * are valid.  During the bus scan we will use this generation
	 * for the read transactions, so that if another reset occurs
	 * during the scan the transactions will fail instead of
	 * returning bogus data. */

			generation = get_hpsb_generation(host);

	/* If we get a reset before we are done waiting, then
	 * start the waiting over again */

			if (generation != g)
				g = generation, i = 0;
		}

		[... scan bus, using generation ...]

	}
exit:
[...]
}



-- 
Stefan Richter
-=====-=-=== =--- -====
http://arcgraph.de/sr/
