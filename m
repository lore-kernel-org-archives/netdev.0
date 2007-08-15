From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 15:08:43 +0200
Message-ID: <46C2FADB.7020407@s5r6.in-berlin.de>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
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
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:38172 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbXHONIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 09:08:45 -0400
In-Reply-To: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> On Wed, 15 Aug 2007, Stefan Richter wrote:
>> Doesn't "atomic WRT all processors" require volatility?
> 
> No, it definitely doesn't. Why should it?
> 
> "Atomic w.r.t. all processors" is just your normal, simple "atomicity"
> for SMP systems (ensure that that object is modified / set / replaced
> in main memory atomically) and has nothing to do with "volatile"
> behaviour.
> 
> "Volatile behaviour" itself isn't consistently defined (at least
> definitely not consistently implemented in various gcc versions across
> platforms), but it is /expected/ to mean something like: "ensure that
> every such access actually goes all the way to memory, and is not
> re-ordered w.r.t. to other accesses, as far as the compiler can take
> care of these". The last "as far as compiler can take care" disclaimer
> comes about due to CPUs doing their own re-ordering nowadays.
> 
> For example (say on i386):

[...]

> In (A) the compiler optimized "a = 10;" away, but the actual store
> of the final value "20" to "a" was still "atomic". (B) and (C) also
> exhibit "volatile" behaviour apart from the "atomicity".
> 
> But as others replied, it seems some callers out there depend upon
> atomic ops exhibiting "volatile" behaviour as well, so that answers
> my initial question, actually. I haven't looked at the code Paul
> pointed me at, but I wonder if that "forget(x)" macro would help
> those cases. I'd wish to avoid the "volatile" primitive, personally.

So, looking at load instead of store, understand I correctly that in
your opinion

	int b;

	b = atomic_read(&a);
	if (b)
		do_something_time_consuming();

	b = atomic_read(&a);
	if (b)
		do_something_more();

should be changed to explicitly forget(&a) after
do_something_time_consuming?

If so, how about the following:

static inline void A(atomic_t *a)
{
	int b = atomic_read(a);
	if (b)
		do_something_time_consuming();
}

static inline void B(atomic_t *a)
{
	int b = atomic_read(a);
	if (b)
		do_something_more();
}

static void C(atomic_t *a)
{
	A(a);
	B(b);
}

Would this need forget(a) after A(a)?

(Is the latter actually answered in C99 or is it compiler-dependent?)
-- 
Stefan Richter
-=====-=-=== =--- -====
http://arcgraph.de/sr/
