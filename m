From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] cb_lock does not needs ref count on sk
Date: Fri, 1 Apr 2005 19:36:33 +1000
Message-ID: <20050401093633.GA32707@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au> <20050329114926.GA14986@elte.hu> <20050330082640.GA8269@gondor.apana.org.au> <20050330170236.2bddf666.davem@davemloft.net> <20050331231922.GA26587@gondor.apana.org.au> <20050331232322.GA26693@gondor.apana.org.au> <20050331203313.57e1c5c3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050331203313.57e1c5c3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a little optimisation for the cb_lock used by netlink_dump.
While fixing that race earlier, I noticed that the reference count
held by cb_lock is completely useless.  The reason is that in order
to obtain the protection of the reference count, you have to take
the cb_lock.  But the only way to take the cb_lock is through
dereferencing the socket.

That is, you must already possess a reference count on the socket
before you can take advantage of the reference count held by cb_lock.
As a corollary, we can remve the reference count held by the cb_lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.75 vs edited =====
--- 1.75/net/netlink/af_netlink.c	2005-04-01 16:25:14 +10:00
+++ edited/net/netlink/af_netlink.c	2005-04-01 19:30:22 +10:00
@@ -374,7 +374,6 @@
 		nlk->cb->done(nlk->cb);
 		netlink_destroy_callback(nlk->cb);
 		nlk->cb = NULL;
-		__sock_put(sk);
 	}
 	spin_unlock(&nlk->cb_lock);
 
@@ -1100,7 +1099,6 @@
 	spin_unlock(&nlk->cb_lock);
 
 	netlink_destroy_callback(cb);
-	__sock_put(sk);
 	return 0;
 }
 
@@ -1139,7 +1137,6 @@
 		return -EBUSY;
 	}
 	nlk->cb = cb;
-	sock_hold(sk);
 	spin_unlock(&nlk->cb_lock);
 
 	netlink_dump(sk);

--Nq2Wo0NMKNjxTN9z--
