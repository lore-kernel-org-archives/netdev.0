From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] Fix multicast bind/autobind race
Date: Tue, 15 Mar 2005 18:19:09 +1100
Message-ID: <20050315071909.GA5458@gondor.apana.org.au>
References: <20050314094420.GA15349@gondor.apana.org.au> <20050314212845.6a7fd240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050314212845.6a7fd240.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 14, 2005 at 09:28:45PM -0800, David S. Miller wrote:
> 
> I suspect a 2.4.x version is necessary as well.  Could you cook
> one up for me?  Thanks.

Sure, here it is.
 
netlink_autobind has always set nlk_sk(sk)->groups to zero.  This is
unnecessary because sk_alloc already zeroes the entire structure.
Since a socket can only be bound once netlink_autobind doesn't need
to zero groups at all.

This had been safe until I added mc_list.  Now it is possible for
netlink_bind to race against netlink_autobind running on the same
socket on another CPU.  The result would be a socket that's on
mc_list with groups set to zero.  This socket will be left on the
list even after it is destroyed.

The fix is to remove the zeroing in netlink_autobind.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.21 vs edited =====
--- 1.21/net/netlink/af_netlink.c	2005-02-17 06:21:57 +11:00
+++ edited/net/netlink/af_netlink.c	2005-03-15 18:17:55 +11:00
@@ -450,7 +450,6 @@
 	err = netlink_insert(sk, pid);
 	if (err == -EADDRINUSE)
 		goto retry;
-	sk->protinfo.af_netlink->groups = 0;
 	return 0;
 }
 

--C7zPtVaVf+AK4Oqc--
