From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 05 Jul 2004 22:25:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.222513.81999836.yoshfuji@linux-ipv6.org>
References: <20040705120610.GA5728@gondor.apana.org.au>
	<20040705.212522.126409437.yoshfuji@linux-ipv6.org>
	<20040705124511.GA17193@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: meissner@suse.de
In-Reply-To: <20040705124511.GA17193@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040705124511.GA17193@suse.de> (at Mon, 5 Jul 2004 14:45:11 +0200), Marcus Meissner <meissner@suse.de> says:

> The second hlist_empty is bad, you should be checking &tcp_ehash[i +
> tcp_ehash_size].chain ((head+tcp_ehash_size) I think).

Oops...

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/tcp_diag.c 1.15 vs edited =====
--- 1.15/net/ipv4/tcp_diag.c	2004-06-08 07:27:58 +09:00
+++ edited/net/ipv4/tcp_diag.c	2004-07-05 22:21:06 +09:00
@@ -522,9 +522,14 @@
 		if (i > s_i)
 			s_num = 0;
 
-		read_lock_bh(&head->lock);
-
 		num = 0;
+
+		if (hlist_empty(&head->chain) &&
+		    (!(r->tcpdiag_states&TCPF_TIME_WAIT) || 
+		       hlist_empty(&(head + tcp_ehash_size)->chain)))
+			continue;
+
+		read_lock_bh(&head->lock);
 		sk_for_each(sk, node, &head->chain) {
 			struct inet_opt *inet = inet_sk(sk);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
