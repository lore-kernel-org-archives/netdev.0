From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in ip_rcv
Date: Fri, 6 May 2005 07:44:53 +1000
Message-ID: <20050505214453.GA29853@gondor.apana.org.au>
References: <20050505101542.GB7916@krispykreme> <E1DTeis-0005gu-00@gondolin.me.apana.org.au> <20050505130904.GA16593@krispykreme> <20050505112624.3ffd7f3d.davem@davemloft.net> <20050505213740.GB29526@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050505213740.GB29526@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 06, 2005 at 07:37:40AM +1000, herbert wrote:
> 
> Could we delay the call of dev_add_pack(&ip_packet_type) until
> the very end of inet_init? That way we're guaranteed to not
> receive anything until it's ready.

This patch should do the trick.

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

===== net/ipv4/af_inet.c 1.86 vs edited =====
--- 1.86/net/ipv4/af_inet.c	2005-03-27 09:04:35 +10:00
+++ edited/net/ipv4/af_inet.c	2005-05-06 07:41:44 +10:00
@@ -1010,6 +1010,15 @@
 static int ipv4_proc_init(void);
 extern void ipfrag_init(void);
 
+/*
+ *	IP protocol layer initialiser
+ */
+
+static struct packet_type ip_packet_type = {
+	.type = __constant_htons(ETH_P_IP),
+	.func = ip_rcv,
+};
+
 static int __init inet_init(void)
 {
 	struct sk_buff *dummy_skb;
@@ -1102,6 +1111,8 @@
 	ipv4_proc_init();
 
 	ipfrag_init();
+
+	dev_add_pack(&ip_packet_type);
 
 	rc = 0;
 out:
===== net/ipv4/ip_output.c 1.82 vs edited =====
--- 1.82/net/ipv4/ip_output.c	2005-03-24 07:17:35 +11:00
+++ edited/net/ipv4/ip_output.c	2005-05-06 07:41:29 +10:00
@@ -1323,23 +1323,8 @@
 	ip_rt_put(rt);
 }
 
-/*
- *	IP protocol layer initialiser
- */
-
-static struct packet_type ip_packet_type = {
-	.type = __constant_htons(ETH_P_IP),
-	.func = ip_rcv,
-};
-
-/*
- *	IP registers the packet type and then calls the subprotocol initialisers
- */
-
 void __init ip_init(void)
 {
-	dev_add_pack(&ip_packet_type);
-
 	ip_rt_init();
 	inet_initpeers();
 

--C7zPtVaVf+AK4Oqc--
