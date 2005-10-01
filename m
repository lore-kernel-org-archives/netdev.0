From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Sat, 1 Oct 2005 17:12:48 +1000
Message-ID: <20051001071248.GA15990__40390.3182167143$1128151036$gmane$org@gondor.apana.org.au>
References: <200510010656.j916ufhT007410@rastaban.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Suzanne Wood <suzannew@cs.pdx.edu>
Content-Disposition: inline
In-Reply-To: <200510010656.j916ufhT007410@rastaban.cs.pdx.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 30, 2005 at 11:56:41PM -0700, Suzanne Wood wrote:
> 
> But it is interesting to have discarded what was developed yesterday
> to minimize rcu_dereference impact:
>
> >> ----- Original message  -----
> >> From: Herbert Xu <herbert@gondor.apana.org.au>
> >> Date: Fri, 30 Sep 2005 11:19:07 +1000
> >> 
> >> On Thu, Sep 29, 2005 at 06:16:03PM -0700, Paul E. McKenney wrote:
> >>> 
> >>> OK, how about this instead?
> >>> 
> >>> rcu_read_lock();
> >>> in_dev = dev->ip_ptr;
> >>> if (in_dev) {
> >>> atomic_inc(&rcu_dereference(in_dev)->refcnt);
> >>> }
> >>> rcu_read_unlock();
> >>> return in_dev;
> >> 
> >> Looks great. 
> 
> while adding a function call level by wrapping  __in_dev_get_rcu
> with in_dev_get as suggested here.

It might look different, but it should compile to the same result.
GCC should be smart enough to combine the two branches and produce a
memory barrier only when in_dev is not NULL.
 
> The other thing I'd hoped to address in pktgen.c was 
> removing the __in_dev_put() which decrements refcnt 
> while __in_dev_get_rcu() does not increment.

Well spotted.

Here is a patch on top of the last one to fix this bogus decrement.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1673,7 +1673,6 @@ static void pktgen_setup_inject(struct p
 					pkt_dev->saddr_min = in_dev->ifa_list->ifa_address;
 					pkt_dev->saddr_max = pkt_dev->saddr_min;
 				}
-				__in_dev_put(in_dev);	
 			}
 			rcu_read_unlock();
 		}

--2fHTh5uZTiUOsy+g--
