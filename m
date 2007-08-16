From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 13:23:06 +1000
Message-ID: <18115.49946.522011.832468@cargo.ozlabs.ibm.com>
References: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
	<18115.35524.56393.347841@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
	<20070816003948.GY9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
	<20070816005348.GA9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com>
	<20070816011414.GC9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
	<20070816020851.GA30809@gondor.apana.org.au>
	<Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
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
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49983 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641AbXHPDXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 23:23:19 -0400
In-Reply-To: <Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter writes:

> > But I have to say that I still don't know of a single place
> > where one would actually use the volatile variant.
> 
> I suspect that what you say is true after we have looked at all callers.

It seems that there could be a lot of places where atomic_t is used in
a non-atomic fashion, and that those uses are either buggy, or there
is some lock held at the time which guarantees that other CPUs aren't
changing the value.  In both cases there is no point in using
atomic_t; we might as well just use an ordinary int.

In particular, atomic_read seems to lend itself to buggy uses.  People
seem to do things like:

	atomic_add(&v, something);
	if (atomic_read(&v) > something_else) ...

and expect that there is some relationship between the value that the
atomic_add stored and the value that the atomic_read will return,
which there isn't.  People seem to think that using atomic_t magically
gets rid of races.  It doesn't.

I'd go so far as to say that anywhere where you want a non-"volatile"
atomic_read, either your code is buggy, or else an int would work just
as well.

Paul.

