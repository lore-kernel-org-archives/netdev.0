From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Thu, 31 Mar 2005 11:10:01 +1000
Message-ID: <20050331011001.GA26715@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au> <20050329114926.GA14986@elte.hu> <20050330082640.GA8269@gondor.apana.org.au> <20050330170236.2bddf666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050330170236.2bddf666.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 30, 2005 at 05:02:36PM -0800, David S. Miller wrote:
> 
> Looks like 2.4.x needs the same fix, correct?

Indeed it does.  Here it is for 2.4.

In netlink_dump we're operating on sk after dropping the cb lock.
This is racy because the owner of the socket could close it after
we drop the cb lock.

This is possible because netlink_dump isn't always called from the
context of the process that owns the socket.  For instance, if there
is contention on rtnl then rtnetlink requests will be processed by
the process that owns the rtnl.

The solution is to hold a ref count on the socket before we drop
the cb lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I think I know why we're only seeing it now.  Without preemption
this race is very unlikely to trigger.  This plus the fact that
we now have a lot more netlink applications probably made it
just a tad more likely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.21 vs edited =====
--- 1.21/net/netlink/af_netlink.c	2005-02-17 06:21:57 +11:00
+++ edited/net/netlink/af_netlink.c	2005-03-31 11:07:40 +10:00
@@ -981,9 +981,11 @@
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
+		sock_hold(sk);
 		spin_unlock(&sk->protinfo.af_netlink->cb_lock);
 		skb_queue_tail(&sk->receive_queue, skb);
 		sk->data_ready(sk, len);
+		sock_put(sk);
 		return 0;
 	}
 

--bg08WKrSYDhXBjb5--
