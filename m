From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Fix BUG when appending destination options headers
Date: Tue, 08 Jul 2003 22:18:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708.221834.127574909.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Thomas Graf <tgr@reeler.org>, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch fixes BUG when pushing IPv6 destination options over an
IPv6 raw socket.  Patch is based on one from Thomas Graf <tgr@reeler.org>.

Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.32
diff -u -r1.32 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	1 Jul 2003 00:57:19 -0000	1.32
+++ linux-2.5/net/ipv6/ip6_output.c	8 Jul 2003 11:55:33 -0000
@@ -1239,7 +1239,6 @@
 			memcpy(np->cork.opt, opt, opt->tot_len);
 			inet->cork.flags |= IPCORK_OPT;
 			/* need source address above miyazawa*/
-			exthdrlen += opt->opt_flen ? opt->opt_flen : 0;
 		}
 		dst_hold(&rt->u.dst);
 		np->cork.rt = rt;
@@ -1252,6 +1251,7 @@
 			length += exthdrlen;
 			transhdrlen += exthdrlen;
 		}
+		exthdrlen += opt ? opt->opt_flen : 0;
 	} else {
 		rt = np->cork.rt;
 		if (inet->cork.flags & IPCORK_OPT)
Index: linux-2.5/net/ipv6/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/raw.c,v
retrieving revision 1.32
diff -u -r1.32 raw.c
--- linux-2.5/net/ipv6/raw.c	7 Jul 2003 02:28:36 -0000	1.32
+++ linux-2.5/net/ipv6/raw.c	8 Jul 2003 11:55:33 -0000
@@ -624,6 +624,7 @@
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
+		opt->tot_len = sizeof(struct ipv6_txoptions);
 
 		err = datagram_send_ctl(msg, &fl, opt, &hlimit);
 		if (err < 0) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
