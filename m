From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Fix dst leak in ipv6_add_addr
Date: Sat, 6 Nov 2004 15:41:21 +1100
Message-ID: <20041106044121.GA16397@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Found another error-path dst leak.  If the idev->dead check is
triggered in ipv6_add_addr the rt entry will leak.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/addrconf.c 1.115 vs edited =====
--- 1.115/net/ipv6/addrconf.c	2004-10-26 14:11:35 +10:00
+++ edited/net/ipv6/addrconf.c	2004-11-06 15:37:54 +11:00
@@ -484,7 +484,7 @@
 	      int scope, unsigned flags)
 {
 	struct inet6_ifaddr *ifa = NULL;
-	struct rt6_info *rt;
+	struct rt6_info *rt = NULL;
 	int hash;
 	static spinlock_t lock = SPIN_LOCK_UNLOCKED;
 	int err = 0;
@@ -572,6 +572,10 @@
 	if (unlikely(err == 0))
 		notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
 	else {
+		if (rt) {
+			dst_release(&rt->u.dst);
+			dst_free(&rt->u.dst);
+		}
 		kfree(ifa);
 		ifa = ERR_PTR(err);
 	}

--gKMricLos+KVdGMg--
