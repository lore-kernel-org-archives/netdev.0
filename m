From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PFKEY] spirange should be in host byte order
Date: Sat, 31 Jul 2004 20:04:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731100444.GA17201@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I'm looking through the xfrm_alloc_spi stuff and noticed that the
netlink alloc_spi function takes the range in host order while the
PFKEY alloc_spi function takes them in network order.

First I thought that I stuffed up since I was the one who changed
the code in the netlink interface to take them in host order :)

But reading RFC 2367 seems to indicate otherwise.  It says that all
fields are host order unless specified otherwise.  And the spirange
fields are not specified to be network order at all.

Looking at the existing PFKEY users:

User Space
----------
Openswan - Doesn't use PFKEY for this.
Racoon - Puts zeros in there so it doesn't care.  However its test-pfkey
	 program stores things in host order.
ISAKMPD - Stores things in host order.

So the conclusion is that we can and should change our PFKEY
implementation to use host order for these fields.

This patch does exactly that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/key/af_key.c 1.64 vs edited =====
--- 1.64/net/key/af_key.c	2004-07-01 19:11:29 +10:00
+++ edited/net/key/af_key.c	2004-07-31 20:00:19 +10:00
@@ -1182,10 +1182,10 @@
 			min_spi = range->sadb_spirange_min;
 			max_spi = range->sadb_spirange_max;
 		} else {
-			min_spi = htonl(0x100);
-			max_spi = htonl(0x0fffffff);
+			min_spi = 0x100;
+			max_spi = 0x0fffffff;
 		}
-		xfrm_alloc_spi(x, min_spi, max_spi);
+		xfrm_alloc_spi(x, htonl(min_spi), htonl(max_spi));
 		if (x->id.spi)
 			resp_skb = pfkey_xfrm_state2msg(x, 0, 3);
 	}

--envbJBWh7q8WU6mo--
