From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 22/24] rcu: Suppress sparse warnings for
 rcu_dereference_raw()
Date: Tue, 5 Jul 2016 14:32:44 -0700
Message-ID: <20160705213244.GA12384@linux.vnet.ibm.com>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
 <146772448920.21657.6989233498278959646.stgit@warthog.procyon.org.uk>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49427 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755599AbcGEVcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:32:39 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65LNoEK094719
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2016 17:32:39 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 240g6es7ju-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 17:32:39 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 5 Jul 2016 17:32:38 -0400
Content-Disposition: inline
In-Reply-To: <146772448920.21657.6989233498278959646.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2016 at 02:14:49PM +0100, David Howells wrote:
> From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Data structures that are used both with and without RCU protection
> are difficult to write in a sparse-clean manner.  If you mark the
> relevant pointers with __rcu, sparse will complain about all non-RCU
> uses, but if you don't mark those pointers, sparse will complain about
> all RCU uses.
> 
> This commit therefore suppresses sparse warnings for rcu_dereference_raw(),
> allowing mixed-protection data structures to avoid these warnings.
> 
> Reported-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

This would normally be my cue to give an Acked-by to an RCU patch, but
it already has my Signed-off-by.  So this is just to confirm that I agree
that keeping this patch with the other patches that depend on it is the
right thing to do.  ;-)

							Thanx, Paul

> ---
> 
>  include/linux/rcupdate.h |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 5f1533e3d032..85830e6c797b 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -611,6 +611,12 @@ static inline void rcu_preempt_sleep_check(void)
>  	rcu_dereference_sparse(p, space); \
>  	((typeof(*p) __force __kernel *)(p)); \
>  })
> +#define rcu_dereference_raw(p) \
> +({ \
> +	/* Dependency order vs. p above. */ \
> +	typeof(p) ________p1 = lockless_dereference(p); \
> +	((typeof(*p) __force __kernel *)(________p1)); \
> +})
> 
>  /**
>   * RCU_INITIALIZER() - statically initialize an RCU-protected global variable
> @@ -729,8 +735,6 @@ static inline void rcu_preempt_sleep_check(void)
>  	__rcu_dereference_check((p), (c) || rcu_read_lock_sched_held(), \
>  				__rcu)
> 
> -#define rcu_dereference_raw(p) rcu_dereference_check(p, 1) /*@@@ needed? @@@*/
> -
>  /*
>   * The tracing infrastructure traces RCU (we want that), but unfortunately
>   * some of the RCU checks causes tracing to lock up the system.
> 
