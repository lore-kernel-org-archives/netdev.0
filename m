From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Mon, 16 Aug 2004 13:14:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816031456.GA8493@gondor.apana.org.au>
References: <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040815190823.654bf2d5.davem@redhat.com> <20040816024329.GA8127@gondor.apana.org.au> <20040815200838.1f971350.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815200838.1f971350.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 15, 2004 at 08:08:38PM -0700, David S. Miller wrote:
> On Mon, 16 Aug 2004 12:43:30 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > It will return zero if there is no in_dev at all.  Perhaps what
> > we should do is get inet_select_addr() to get the address from
> > other devices in that case as well?
> 
> It does that now, look at how it iterates over dev_base's
> list.

But not if __in_dev_get() == NULL.  The following patch should
express that more clearly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/devinet.c 1.38 vs edited =====
--- 1.38/net/ipv4/devinet.c	2004-08-14 14:50:31 +10:00
+++ edited/net/ipv4/devinet.c	2004-08-16 13:13:44 +10:00
@@ -780,7 +780,7 @@
 	rcu_read_lock();
 	in_dev = __in_dev_get(dev);
 	if (!in_dev)
-		goto out_unlock_inetdev;
+		goto no_in_dev;
 
 	for_primary_ifa(in_dev) {
 		if (ifa->ifa_scope > scope)
@@ -792,6 +792,7 @@
 		if (!addr)
 			addr = ifa->ifa_local;
 	} endfor_ifa(in_dev);
+no_in_dev:
 	rcu_read_unlock();
 
 	if (addr)
@@ -817,7 +818,6 @@
 	}
 out_unlock_both:
 	read_unlock(&dev_base_lock);
-out_unlock_inetdev:
 	rcu_read_unlock();
 out:
 	return addr;

--DocE+STaALJfprDB--
