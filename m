From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 05 Nov 2004 15:53:55 +0900 (JST)
Message-ID: <20041105.155355.110780816.yoshfuji@linux-ipv6.org>
References: <20041022075947.GA15795@xi.wantstofly.org>
	<1099577717.1039.155.camel@jzny.localdomain>
	<20041104221801.584c8f11.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, buytenh@wantstofly.org, jgarzik@pobox.com,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20041104221801.584c8f11.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041104221801.584c8f11.davem@davemloft.net> (at Thu, 4 Nov 2004 22:18:01 -0800), "David S. Miller" <davem@davemloft.net> says:

> > > 	00012c0d <udpv6_sendmsg>	(god, that's one big function btw)
> 
> The last one is the most interesting.  The only dst_release() call
> that occurs in udpv6_sendmsg() is when xfrm_lookup() returns
> an error.  The semantics of that function are a complete mess
> (when it errors, it sometimes releases the DST, sometimes does not)
> and I'll fix that up.

Oh,yes, something like this?

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/udp.c 1.76 vs edited =====
--- 1.76/net/ipv6/udp.c	2004-10-26 11:47:26 +09:00
+++ edited/net/ipv6/udp.c	2004-11-05 15:42:00 +09:00
@@ -631,7 +631,7 @@
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi *fl = &inet->cork.fl;
-	struct dst_entry *dst;
+	struct dst_entry *dst = NULL;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
 	int hlimit = -1;
@@ -797,10 +797,8 @@
 	if (final_p)
 		ipv6_addr_copy(&fl->fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
-		dst_release(dst);
+	if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0)
 		goto out;
-	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl->fl6_dst))
@@ -846,6 +844,7 @@
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
 out:
+	dst_release(dst);
 	fl6_sock_release(flowlabel);
 	if (!err) {
 		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
