From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Wed, 30 Mar 2005 18:26:40 +1000
Message-ID: <20050330082640.GA8269@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au> <20050329114926.GA14986@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20050329114926.GA14986@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 29, 2005 at 01:49:26PM +0200, Ingo Molnar wrote:
> 
> (i guess the debug message should be extended to do a dump_stack() so 
> that we see which process does?)

Never mind.  I think I've found what it is.  The only thing I can't
figure out is why we're only seeing it now when this bug has been
around since day one.

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

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.72 vs edited =====
--- 1.72/net/netlink/af_netlink.c	2005-03-23 14:17:09 +11:00
+++ edited/net/netlink/af_netlink.c	2005-03-30 16:24:27 +10:00
@@ -1080,9 +1080,11 @@
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
+		sock_hold(sk);
 		spin_unlock(&nlk->cb_lock);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, len);
+		sock_put(sk);
 		return 0;
 	}
 

--7JfCtLOvnd9MIVvH--
