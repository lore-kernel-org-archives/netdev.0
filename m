From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 12 Jul 2013 07:04:45 -0700
Message-ID: <1373637885.10804.7.camel@edumazet-glaptop>
References: <20130708160421.GA9763@order.stressinduktion.org>
	 <20130711.165726.2168148122875413191.davem@davemloft.net>
	 <20130712084145.GJ27468@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:65525 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964823Ab3GLOEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 10:04:47 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so8598757pdj.31
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 07:04:46 -0700 (PDT)
In-Reply-To: <20130712084145.GJ27468@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-12 at 10:41 +0200, Florian Westphal wrote:

> The main difference to what linux does is to avoid encoding the 'count'
> value (Linux doesn't reseed secret[], and relies on count to detect old
> cookies).
> 
> Not having the counter frees up space to encode tcp options in the cookie
> instead of the timestamp.

But still wscale and sack options are disabled.

lpq83:~# echo 0 >/proc/sys/net/ipv4/tcp_timestamps
lpq83:~# tcpdump -p -n -s 0 -i eth4

07:03:37.337563 IP 7.7.7.84.64131 > 7.7.7.83.22: S 1523884225:1523884225(0) win 29200 <mss 1460,sackOK,timestamp 74412758 0,nop,wscale 6>
07:03:37.337588 IP 7.7.7.83.22 > 7.7.7.84.64131: S 572330188:572330188(0) ack 1523884226 win 29200 <mss 1460>
07:03:37.337647 IP 7.7.7.84.64131 > 7.7.7.83.22: . ack 1 win 29200


BTW, following patch allows to test more easily syncookies behavior.

If sysctl_tcp_syncookies is set to 2, we always use syncookies.

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 35675e4..590659e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1462,7 +1462,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * limitations, they conserve resources and peer is
 	 * evidently real one.
 	 */
-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+	if ((sysctl_tcp_syncookies == 2 ||
+	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
 		if (!want_cookie)
 			goto drop;
