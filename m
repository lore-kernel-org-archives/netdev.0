From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 05 Jul 2004 21:25:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.212522.126409437.yoshfuji@linux-ipv6.org>
References: <E1BhRda-0001Rs-00@gondolin.me.apana.org.au>
	<20040705113555.GA28665@suse.de>
	<20040705120610.GA5728@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, meissner@suse.de
In-Reply-To: <20040705120610.GA5728@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040705120610.GA5728@gondor.apana.org.au> (at Mon, 5 Jul 2004 22:06:10 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Mon, Jul 05, 2004 at 01:35:55PM +0200, Marcus Meissner wrote:
> > 
> > Oh, and NETLINK+TCP_DIAG seems to have the same readlock contention problem,
> > see tcpdiag_dump().
> 
> Then you wouldn't mind adding this optimisation for tcp_diag as well,
> right? :)

here it is. :-)

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/tcp_diag.c 1.15 vs edited =====
--- 1.15/net/ipv4/tcp_diag.c	2004-06-08 07:27:58 +09:00
+++ edited/net/ipv4/tcp_diag.c	2004-07-05 21:18:17 +09:00
@@ -522,9 +522,13 @@
 		if (i > s_i)
 			s_num = 0;
 
-		read_lock_bh(&head->lock);
-
 		num = 0;
+
+		if (hlist_empty(&head->chain) &&
+		    (!(r->tcpdiag_states&TCPF_TIME_WAIT) || hlist_empty(&head->chain)))
+			continue;
+
+		read_lock_bh(&head->lock);
 		sk_for_each(sk, node, &head->chain) {
 			struct inet_opt *inet = inet_sk(sk);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
