From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Trivial kmalloc failure checks
Date: Tue, 9 Mar 2004 13:36:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403091331570.5760-100000@linux-009047018241>
References: <20040113232009.008a57a7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040113232009.008a57a7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

A couple of checks for memory allocation failures.

Thanks,

- KK

diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv4/esp4.c linux-2.6.4-rc2-bk5/net/ipv4/esp4.c
--- linux-2.6.4-rc2-bk5.org/net/ipv4/esp4.c	2004-03-09 13:11:15.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv4/esp4.c	2004-03-09 13:29:44.000000000 -0800
@@ -518,6 +518,8 @@
 	esp->conf.padlen = 0;
 	if (esp->conf.ivlen) {
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
+		if (unlikely(esp->conf.ivec == NULL))
+			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv4/ip_output.c linux-2.6.4-rc2-bk5/net/ipv4/ip_output.c
--- linux-2.6.4-rc2-bk5.org/net/ipv4/ip_output.c	2004-03-09 13:18:50.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv4/ip_output.c	2004-03-09 13:20:10.000000000 -0800
@@ -761,8 +761,11 @@
 		 */
 		opt = ipc->opt;
 		if (opt) {
-			if (inet->cork.opt == NULL)
+			if (inet->cork.opt == NULL) {
 				inet->cork.opt = kmalloc(sizeof(struct ip_options) + 40, sk->sk_allocation);
+				if (unlikely(inet->cork.opt == NULL))
+					return -ENOBUFS;
+			}
 			memcpy(inet->cork.opt, opt, sizeof(struct ip_options)+opt->optlen);
 			inet->cork.flags |= IPCORK_OPT;
 			inet->cork.addr = ipc->addr;
diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv6/esp6.c linux-2.6.4-rc2-bk5/net/ipv6/esp6.c
--- linux-2.6.4-rc2-bk5.org/net/ipv6/esp6.c	2004-03-09 13:10:42.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv6/esp6.c	2004-03-09 13:30:03.000000000 -0800
@@ -422,6 +422,8 @@
 	esp->conf.padlen = 0;
 	if (esp->conf.ivlen) {
 		esp->conf.ivec = kmalloc(esp->conf.ivlen, GFP_KERNEL);
+		if (unlikely(esp->conf.ivec == NULL))
+			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv6/ip6_output.c linux-2.6.4-rc2-bk5/net/ipv6/ip6_output.c
--- linux-2.6.4-rc2-bk5.org/net/ipv6/ip6_output.c	2004-03-09 13:10:42.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv6/ip6_output.c	2004-03-09 13:20:29.000000000 -0800
@@ -816,9 +816,12 @@
 		 * setup for corking
 		 */
 		if (opt) {
-			if (np->cork.opt == NULL)
+			if (np->cork.opt == NULL) {
 				np->cork.opt = kmalloc(opt->tot_len,
 						       sk->sk_allocation);
+				if (unlikely(np->cork.opt == NULL))
+					return -ENOBUFS;
+			}
 			memcpy(np->cork.opt, opt, opt->tot_len);
 			inet->cork.flags |= IPCORK_OPT;
 			/* need source address above miyazawa*/
