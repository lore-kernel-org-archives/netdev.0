From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Fri, 1 Apr 2005 09:19:22 +1000
Message-ID: <20050331231922.GA26587@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au> <20050329114926.GA14986@elte.hu> <20050330082640.GA8269@gondor.apana.org.au> <20050330170236.2bddf666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050330170236.2bddf666.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

On Wed, Mar 30, 2005 at 05:02:36PM -0800, David S. Miller wrote:
> On Wed, 30 Mar 2005 18:26:40 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > The solution is to hold a ref count on the socket before we drop
> > the cb lock.
> 
> Applied, thanks Herbert.

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

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.73 vs edited =====
--- 1.73/net/netlink/af_netlink.c	2005-03-31 10:58:04 +10:00
+++ edited/net/netlink/af_netlink.c	2005-04-01 09:06:20 +10:00
@@ -1080,11 +1080,9 @@
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
-		sock_hold(sk);
 		spin_unlock(&nlk->cb_lock);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, len);
-		sock_put(sk);
 		return 0;
 	}
 
@@ -1099,7 +1097,7 @@
 	spin_unlock(&nlk->cb_lock);
 
 	netlink_destroy_callback(cb);
-	sock_put(sk);
+	__sock_put(sk);
 	return 0;
 }
 
@@ -1138,9 +1136,11 @@
 		return -EBUSY;
 	}
 	nlk->cb = cb;
+	sock_hold(sk);
 	spin_unlock(&nlk->cb_lock);
 
 	netlink_dump(sk);
+	sock_put(sk);
 	return 0;
 }
 

--CE+1k2dSO48ffgeK--
