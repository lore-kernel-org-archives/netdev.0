From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 09 Aug 2007 10:53:14 -0400
Message-ID: <46BB2A5A.5090006@redhat.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940208AbXHIOyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:54:08 -0400
In-Reply-To: <20070809143255.GA8424@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> Why not the same access-once semantics for atomic_set() as
> for atomic_read()?  As this patch stands, it might introduce
> architecture-specific compiler-induced bugs due to the fact that
> atomic_set() used to imply volatile behavior but no longer does.

When we make the volatile cast in atomic_read(), we're casting an rvalue to 
volatile.  This unambiguously tells the compiler that we want to re-load that 
register from memory.  What's "volatile behavior" for an lvalue?  A write to an 
lvalue already implies an eventual write to memory, so this would be a no-op. 
Maybe you'll write to the register a few times before flushing it to memory, but 
it will happen eventually.  With an rvalue, there's no guarantee that it will 
*ever* load from memory, which is what volatile fixes.

I think what you have in mind is LOCK_PREFIX behavior, which is not the purpose 
of atomic_set.  We use LOCK_PREFIX in the inline assembly for the atomic_* 
operations that read, modify, and write a value, only because it is necessary to 
perform that entire transaction atomically.

	-- Chris
