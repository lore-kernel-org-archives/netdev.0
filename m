From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 23:31:08 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040917233108.561c88d6.davem@davemloft.net>
References: <9e47339104091717215e9be08b@mail.gmail.com>
	<E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
	<9e473391040917183726113e91@mail.gmail.com>
	<20040918041627.GA12356@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jonsmirl@gmail.com, david@gibson.dropbear.id.au, akpm@osdl.org,
	trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269146AbUIRGer@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040918041627.GA12356@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org

On Sat, 18 Sep 2004 14:16:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Thanks.  The following bug is probably your problem.

Good catch on this fix, but really he's hitting the
BUG_ON() in fib_sync_down()  (I hate i386 backtraces,
it's an art to decode them properly)

So if you rmmod() a device before any routes are ever
created in ipv4, this triggers.  I didn't think this
was possible, but it is.

The fix is simple enough.

===== net/ipv4/fib_semantics.c 1.16 vs edited =====
--- 1.16/net/ipv4/fib_semantics.c	2004-09-17 11:11:04 -07:00
+++ edited/net/ipv4/fib_semantics.c	2004-09-17 23:14:44 -07:00
@@ -1040,9 +1040,7 @@
 	if (force)
 		scope = -1;
 
-	BUG_ON(!fib_info_laddrhash);
-
-	if (local) {
+	if (local && fib_info_laddrhash) {
 		unsigned int hash = fib_laddr_hashfn(local);
 		struct hlist_head *head = &fib_info_laddrhash[hash];
 		struct hlist_node *node;
