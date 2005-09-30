From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Fri, 30 Sep 2005 10:27:19 +1000
Message-ID: <20050930002719.GC21062__14479.1445964531$1128040297$gmane$org@gondor.apana.org.au>
References: <200509292330.j8TNUSmH019572@rastaban.cs.pdx.edu> <20050930002346.GP8177@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suzanne Wood <suzannew@cs.pdx.edu>, Robert.Olsson@data.slu.se,
        davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050930002346.GP8177@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 05:23:46PM -0700, Paul E. McKenney wrote:
> 
> Is there any case where __in_dev_get() might be called without
> needing to be wrapped with rcu_dereference()?  If so, then I
> agree (FWIW, given my meagre knowledge of Linux networking).

Yes.  All paths that call __in_dev_get() under the rtnl do not
need rcu_dereference (or any RCU at all) since the rtnl prevents
any ip_ptr modification from occuring.

> However, rcu_dereference() only generates a memory barrier on DEC
> Alpha, so there is normally no penalty for using it in the NULL-pointer
> case.  So, when using rcu_dereference() unconditionally simplifies
> the code, it may make sense to "just do it".

Here is what the code would look like:

	rcu_read_lock();
	in_dev = dev->ip_ptr;
	if (in_dev) {
		in_dev = rcu_dereference(in_dev);
		atomic_inc(&in_dev->refcnt);
	}
	rcu_read_unlock();
	return in_dev;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
