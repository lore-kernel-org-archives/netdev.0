From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Thu, 1 Jul 2004 09:01:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630230147.GA6136@gondor.apana.org.au>
References: <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au> <20040630112751.GA31160@gondor.apana.org.au> <20040630120045.GA7973@ms2.inr.ac.ru> <20040630120828.GA31498@gondor.apana.org.au> <20040630121420.GA8183@ms2.inr.ac.ru> <20040630124050.GA1619@gondor.apana.org.au> <20040630153606.3493581b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040630153606.3493581b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 30, 2004 at 03:36:06PM -0700, David S. Miller wrote:
> 
> Why don't you combine the two "ERR_PTR(-ECONNREFUSED)" tests
> into one test like:
> 
> 	if ((nlk->pid == 0 && !nlk->data_ready) ||
> 	    (sock->sk_state == NELTINK_CONNECTED &&
> 	     nlk->dst_pid != nlk_sk(ssk)->pid)) {
> 		sock_put(sock);
> 		return ERR_PTR(-ECONNREFUSED);
> 	}
> 
> so we don't have two copies of the "sock_put(); return ERR_PTR()"
> thing emitted by the compiler?

Well at least under i386, gcc (3.3.4) is smart enough to merge these
common exit paths.

But yes we could merge them.  What about the following incremental
patch?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- work-2.6/net/netlink/af_netlink.c.orig	2004-07-01 08:56:55.000000000 +1000
+++ work-2.6/net/netlink/af_netlink.c	2004-07-01 08:59:14.000000000 +1000
@@ -425,21 +425,23 @@
 
 	sock = netlink_lookup(protocol, pid);
 	if (!sock)
-		return ERR_PTR(-ECONNREFUSED);
+		goto err;
 
 	/* Don't bother queuing skb if kernel socket has no input function */
 	nlk = nlk_sk(sock);
-	if (nlk->pid == 0 && !nlk->data_ready) {
-		sock_put(sock);
-		return ERR_PTR(-ECONNREFUSED);
-	}
+	if (nlk->pid == 0 && !nlk->data_ready)
+		goto err_sock;
 
 	if (sock->sk_state == NETLINK_CONNECTED &&
-	    nlk->dst_pid != nlk_sk(ssk)->pid) {
-		sock_put(sock);
-		return ERR_PTR(-ECONNREFUSED);
-	}
+	    nlk->dst_pid != nlk_sk(ssk)->pid)
+		goto err_sock;
+
 	return sock;
+
+err_sock:
+	sock_put(sock);
+err:
+	return ERR_PTR(-ECONNREFUSED);
 }
 
 struct sock *netlink_getsockbyfilp(struct file *filp)

--8t9RHnE3ZwKMSgU+--
