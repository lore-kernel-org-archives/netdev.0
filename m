From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Fix multicast bind/autobind race
Date: Mon, 14 Mar 2005 20:44:20 +1100
Message-ID: <20050314094420.GA15349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

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

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.70 vs edited =====
--- 1.70/net/netlink/af_netlink.c	2005-02-09 15:09:15 +11:00
+++ edited/net/netlink/af_netlink.c	2005-03-14 20:28:59 +11:00
@@ -430,7 +430,6 @@
 	err = netlink_insert(sk, pid);
 	if (err == -EADDRINUSE)
 		goto retry;
-	nlk_sk(sk)->groups = 0;
 	return 0;
 }
 

--oyUTqETQ0mS9luUI--
