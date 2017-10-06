From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] RCU: introduce noref debug
Date: Fri, 6 Oct 2017 06:34:36 -0700
Message-ID: <20171006133436.GY3521@linux.vnet.ibm.com>
References: <cover.1507294365.git.pabeni@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33678 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752188AbdJFNel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 09:34:41 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v96DT2wG117930
        for <netdev@vger.kernel.org>; Fri, 6 Oct 2017 09:34:40 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2deapeghc2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 09:34:40 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Fri, 6 Oct 2017 09:34:39 -0400
Content-Disposition: inline
In-Reply-To: <cover.1507294365.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 06, 2017 at 02:57:45PM +0200, Paolo Abeni wrote:
> The networking subsystem is currently using some kind of long-lived
> RCU-protected, references to avoid the overhead of full book-keeping.
> 
> Such references - skb_dst() noref - are stored inside the skbs and can be
> moved across relevant slices of the network stack, with the users
> being in charge of properly clearing the relevant skb - or properly refcount
> the related dst references - before the skb escapes the RCU section.
> 
> We currently don't have any deterministic debug infrastructure to check
> the dst noref usages - and the introduction of others noref artifact is
> currently under discussion.
> 
> This series tries to tackle the above introducing an RCU debug infrastructure
> aimed at spotting incorrect noref pointer usage, in patch one. The
> infrastructure is small and must be explicitly enabled via a newly introduced
> build option.
> 
> Patch two uses such infrastructure to track dst noref usage in the networking
> stack.
> 
> Patch 3 and 4 are bugfixes for small buglet found running this infrastructure
> on basic scenarios.

This patchset does not look like it handles rcu_read_lock() nesting.
For example, given code like this:

	void foo(void)
	{
		rcu_read_lock();
		rcu_track_noref(&key2, &noref2, true);
		do_something();
		rcu_track_noref(&key2, &noref2, false);
		rcu_read_unlock();
	}

	void bar(void)
	{
		rcu_read_lock();
		rcu_track_noref(&key1, &noref1, true);
		do_something_more();
		foo();
		do_something_else();
		rcu_track_noref(&key1, &noref1, false);
		rcu_read_unlock();
	}

	void grill(void)
	{
		foo();
	}

It looks like foo()'s rcu_read_unlock() will complain about key1.
You could remove foo()'s rcu_read_lock() and rcu_read_unlock(), but
that will break the call from grill().

Or am I missing something subtle here?  Given patch 3/4, I suspect not...

							Thanx, Paul

> Paolo Abeni (4):
>   rcu: introduce noref debug
>   net: use RCU noref infrastructure to track dst noref
>   ipv4: drop unneeded and misleading RCU lock in ip_route_input_noref()
>   tcp: avoid noref dst leak on input path
> 
>  include/linux/rcupdate.h | 11 ++++++
>  include/linux/skbuff.h   |  1 +
>  include/net/dst.h        |  5 +++
>  kernel/rcu/Kconfig.debug | 15 ++++++++
>  kernel/rcu/Makefile      |  1 +
>  kernel/rcu/noref_debug.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/route.c         |  7 +---
>  net/ipv4/tcp_input.c     |  5 ++-
>  8 files changed, 127 insertions(+), 7 deletions(-)
>  create mode 100644 kernel/rcu/noref_debug.c
> 
> -- 
> 2.13.6
> 
