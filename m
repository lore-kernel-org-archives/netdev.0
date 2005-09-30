From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Thu, 29 Sep 2005 17:36:42 -0700
Message-ID: <20050930003642.GQ8177__10481.4627826729$1128040812$gmane$org@us.ibm.com>
References: <200509292330.j8TNUSmH019572@rastaban.cs.pdx.edu> <20050930002346.GP8177@us.ibm.com> <20050930002719.GC21062@gondor.apana.org.au>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suzanne Wood <suzannew@cs.pdx.edu>, Robert.Olsson@data.slu.se,
        davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050930002719.GC21062@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2005 at 10:27:19AM +1000, Herbert Xu wrote:
> On Thu, Sep 29, 2005 at 05:23:46PM -0700, Paul E. McKenney wrote:
> > 
> > Is there any case where __in_dev_get() might be called without
> > needing to be wrapped with rcu_dereference()?  If so, then I
> > agree (FWIW, given my meagre knowledge of Linux networking).
> 
> Yes.  All paths that call __in_dev_get() under the rtnl do not
> need rcu_dereference (or any RCU at all) since the rtnl prevents
> any ip_ptr modification from occuring.
> 
> > However, rcu_dereference() only generates a memory barrier on DEC
> > Alpha, so there is normally no penalty for using it in the NULL-pointer
> > case.  So, when using rcu_dereference() unconditionally simplifies
> > the code, it may make sense to "just do it".
> 
> Here is what the code would look like:
> 
> 	rcu_read_lock();
> 	in_dev = dev->ip_ptr;
> 	if (in_dev) {
> 		in_dev = rcu_dereference(in_dev);
> 		atomic_inc(&in_dev->refcnt);
> 	}
> 	rcu_read_unlock();
> 	return in_dev;

How about:

	rcu_read_lock();
	in_dev = dev->ip_ptr;
	if (rcu_dereference(in_dev)) {
		atomic_inc(&in_dev->refcnt);
	}
	rcu_read_unlock();
	return in_dev;

Admittedly only saves one line, but...

							Thanx, Paul
