From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 13:48:32 +1000
Message-ID: <18115.51472.408193.332905@cargo.ozlabs.ibm.com>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
	<20070816005348.GA9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com>
	<20070816011414.GC9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
	<20070816020851.GA30809@gondor.apana.org.au>
	<Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com>
	<18115.49946.522011.832468@cargo.ozlabs.ibm.com>
	<20070816033343.GA31844@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Satyam Sharma <satyam@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52759 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755719AbXHPDsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 23:48:39 -0400
In-Reply-To: <20070816033343.GA31844@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> If you're referring to the code in sk_stream_mem_schedule
> then it's working as intended.  The atomicity guarantees

You mean it's intended that *sk->sk_prot->memory_pressure can end up
as 1 when sk->sk_prot->memory_allocated is small (less than
->sysctl_mem[0]), or as 0 when ->memory_allocated is large (greater
than ->sysctl_mem[2])?  Because that's the effect of the current code.
If so I wonder why you bother computing it.

> that the atomic_add/atomic_sub won't be seen in parts by
> other readers.
> 
> We certainly do not need to see other atomic_add/atomic_sub
> operations immediately.
> 
> If you're referring to another code snippet please cite.
> 
> > I'd go so far as to say that anywhere where you want a non-"volatile"
> > atomic_read, either your code is buggy, or else an int would work just
> > as well.
> 
> An int won't work here because += and -= do not have the
> atomicity guarantees that atomic_add/atomic_sub do.  In
> particular, this may cause an atomic_read on another CPU
> to give a bogus reading.

The point is that guaranteeing the atomicity of the increment or
decrement does not suffice to make the code race-free.  In this case
the race arises from the fact that reading ->memory_allocated and
setting *->memory_pressure are separate operations.  To make that code
work properly you need a lock.  And once you have the lock an ordinary
int would suffice for ->memory_allocated.

Paul.
