From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] i386: Fix a couple busy loops in mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 16:34:57 -0400
Message-ID: <46CF40F1.2060403@redhat.com>
References: <46C2350A.1010807@redhat.com> <alpine.LFD.0.999.0708241812110.20322@enigma.security.iitk.ac.in> <Pine.LNX.4.64.0708241005360.20501@schroedinger.engr.sgi.com> <200708242126.58305.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Satyam Sharma <satyam@infradead.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org,
	Nick Piggin <nickpiggin@yahoo.com.au>
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbXHXUgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 16:36:39 -0400
In-Reply-To: <200708242126.58305.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Vlasenko wrote:
> On Friday 24 August 2007 18:06, Christoph Lameter wrote:
>> On Fri, 24 Aug 2007, Satyam Sharma wrote:
>>> But if people do seem to have a mixed / confused notion of atomicity
>>> and barriers, and if there's consensus, then as I'd said earlier, I
>>> have no issues in going with the consensus (eg. having API variants).
>>> Linus would be more difficult to convince, however, I suspect :-)
>> The confusion may be the result of us having barrier semantics in
>> atomic_read. If we take that out then we may avoid future confusions.
> 
> I think better name may help. Nuke atomic_read() altogether.
> 
> n = atomic_value(x);	// doesnt hint as strongly at reading as "atomic_read"
> n = atomic_fetch(x);	// yes, we _do_ touch RAM
> n = atomic_read_uncached(x); // or this
> 
> How does that sound?

atomic_value() vs. atomic_fetch() should be rather unambiguous. 
atomic_read_uncached() begs the question of precisely which cache we are 
avoiding, and could itself cause confusion.

So, if I were writing atomic.h from scratch, knowing what I know now, I think 
I'd use atomic_value() and atomic_fetch().  The problem is that there are a lot 
of existing users of atomic_read(), and we can't write a script to correctly 
guess their intent.  I'm not sure auditing all uses of atomic_read() is really 
worth the comparatively miniscule benefits.

We could play it safe and convert them all to atomic_fetch(), or we could 
acknowledge that changing the semantics 8 months ago was not at all disastrous, 
and make them all atomic_value(), allowing people to use atomic_fetch() where 
they really care.

	-- Chris
