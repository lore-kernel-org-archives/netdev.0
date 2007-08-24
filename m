From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 24 Aug 2007 21:21:21 +0100
Message-ID: <200708242121.22534.vda.linux@googlemail.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <200708241350.45061.vda.linux@googlemail.com> <Pine.LNX.4.64.0708241009120.20501@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.228]:27567 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXHXUVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:21:33 -0400
Received: by hu-out-0506.google.com with SMTP id 19so624934hue
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 13:21:31 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0708241009120.20501@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 August 2007 18:15, Christoph Lameter wrote:
> On Fri, 24 Aug 2007, Denys Vlasenko wrote:
> > On Thursday 16 August 2007 00:22, Paul Mackerras wrote:
> > > Satyam Sharma writes:
> > > In the kernel we use atomic variables in precisely those situations
> > > where a variable is potentially accessed concurrently by multiple
> > > CPUs, and where each CPU needs to see updates done by other CPUs in a
> > > timely fashion.  That is what they are for.  Therefore the compiler
> > > must not cache values of atomic variables in registers; each
> > > atomic_read must result in a load and each atomic_set must result in a
> > > store.  Anything else will just lead to subtle bugs.
> >
> > Amen.
>
> A "timely" fashion? One cannot rely on something like that when coding.
> The visibility of updates is insured by barriers and not by some fuzzy
> notion of "timeliness".

But here you do have some notion of time:

	while (atomic_read(&x))
		continue;

"continue when other CPU(s) decrement it down to zero".
If "read" includes an insn which accesses RAM, you will
see "new" value sometime after other CPU decrements it.
"Sometime after" is on the order of nanoseconds here.
It is a valid concept of time, right?

The whole confusion is about whether atomic_read implies
"read from RAM" or not. I am in a camp which thinks it does.
You are in an opposite one.

We just need a less ambiguous name.

What about this:

/**
 * atomic_read - read atomic variable
 * @v: pointer of type atomic_t
 *
 * Atomically reads the value of @v.
 * No compiler barrier implied.
 */
#define atomic_read(v)          ((v)->counter)

+/**
+ * atomic_read_uncached - read atomic variable from memory
+ * @v: pointer of type atomic_t
+ *
+ * Atomically reads the value of @v. This is guaranteed to emit an insn
+ * which accesses memory, atomically. No ordering guarantees!
+ */
+#define atomic_read_uncached(v)  asm_or_volatile_ptr_magic(v)

I was thinking of s/atomic_read/atomic_get/ too, but it implies "taking"
atomic a-la get_cpu()...
--
vda
