From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Fri, 1 Apr 2005 09:23:22 +1000
Message-ID: <20050331232322.GA26693@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au> <20050329114926.GA14986@elte.hu> <20050330082640.GA8269@gondor.apana.org.au> <20050330170236.2bddf666.davem@davemloft.net> <20050331231922.GA26587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050331231922.GA26587@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is the version for 2.4.
 
Unfortunately my patch only closed half the race.  There is still
a chunk of code between netlink_dump_start and netlink_dump that runs
outside the cb lock which isn't protected by an sk reference.

Here is a better patch which protects the entire netlink_dump function
with a sk reference.

The other call to netlink_dump by recvmsg is safe as the open file
descriptor already holds a reference.  As such the final sock_put
in netlink_dump can be turned into a __sock_put since there is at
least one reference held by the caller.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.4/net/netlink/af_netlink.c.orig	2005-04-01 09:20:05.000000000 +1000
+++ linux-2.4/net/netlink/af_netlink.c	2005-04-01 09:21:06.000000000 +1000
@@ -981,11 +981,9 @@
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
-		sock_hold(sk);
 		spin_unlock(&sk->protinfo.af_netlink->cb_lock);
 		skb_queue_tail(&sk->receive_queue, skb);
 		sk->data_ready(sk, len);
-		sock_put(sk);
 		return 0;
 	}
 
@@ -1000,7 +998,7 @@
 	spin_unlock(&sk->protinfo.af_netlink->cb_lock);
 
 	netlink_destroy_callback(cb);
-	sock_put(sk);
+	__sock_put(sk);
 	return 0;
 }
 
@@ -1037,9 +1035,11 @@
 		return -EBUSY;
 	}
 	sk->protinfo.af_netlink->cb = cb;
+	sock_hold(sk);
 	spin_unlock(&sk->protinfo.af_netlink->cb_lock);
 
 	netlink_dump(sk);
+	sock_put(sk);
 	return 0;
 }
 

--AqsLC8rIMeq19msA--
