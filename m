From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 9 Aug 2007 09:14:23 -0400
Message-ID: <20070809131423.GA9927@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758447AbXHINPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:15:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As recent discussions[1], and bugs[2] have shown, there is a great deal of
confusion about the expected behavior of atomic_read(), compounded by the
fact that it is not the same on all architectures.  Since users expect calls
to atomic_read() to actually perform a read, it is not desirable to allow
the compiler to optimize this away.  Requiring the use of barrier() in this
case is inefficient, since we only want to re-load the atomic_t variable,
not everything else in scope.

This patchset makes the behavior of atomic_read uniform by removing the
volatile keyword from all atomic_t and atomic64_t definitions that currently
have it, and instead explicitly casts the variable as volatile in
atomic_read().  This leaves little room for creative optimization by the
compiler, and is in keeping with the principles behind "volatile considered
harmful".

Busy-waiters should still use cpu_relax(), but fast paths may be able to
reduce their use of barrier() between some atomic_read() calls.

	-- Chris

1)	http://lkml.org/lkml/2007/7/1/52
2)	http://lkml.org/lkml/2007/8/8/122
