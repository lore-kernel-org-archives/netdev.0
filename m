From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Wed, 11 Mar 2009 13:17:54 +0100
Message-ID: <49B7ABF2.5040803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"David S. Miller" <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53841 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbZCKMSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 08:18:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Windows XP platforms, with RFC1323 enabled, send a SYN packet with NULL tsval.

12:56:56.989615 IP 192.168.4.20.3554 > 192.168.20.110.ssh: S 2907491202:2907491202(0) win 64512 <mss 1460,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK>

linux tcp stack correctly implements RFC1323 and ignores this timestamp option, sending
a SYN+ACK answer without timestamp option.

I was wondering what could happen if I patch linux to accept this RFC violation, in
hope to get timestamps on TCP flows to customers (slow and congestioned links, but long living tcp sessions)

I got :

12:58:01.266978 IP 192.168.4.20.3579 > 192.168.20.110.ssh: S 1532083461:1532083461(0) win 64512 <mss 1460,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK>
12:58:01.267015 IP 192.168.20.110.ssh > 192.168.4.20.3579: S 3467339386:3467339386(0) ack 1532083462 win 5792 <mss 1460,nop,nop,timestamp 4294950269 0,nop,wscale 6>
12:58:01.268968 IP 192.168.4.20.3579 > 192.168.20.110.ssh: . ack 1 win 64512 <nop,nop,timestamp 60498 4294950269>
12:58:01.276664 IP 192.168.20.110.ssh > 192.168.4.20.3579: P 1:24(23) ack 1 win 91 <nop,nop,timestamp 4294950279 60498>
12:58:01.288914 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 1:29(28) ack 24 win 64489 <nop,nop,timestamp 60498 4294950279>
12:58:01.288966 IP 192.168.20.110.ssh > 192.168.4.20.3579: . ack 29 win 91 <nop,nop,timestamp 4294950291 60498>
12:58:01.289266 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 29:541(512) ack 24 win 64489 <nop,nop,timestamp 60498 4294950279>
12:58:01.289278 IP 192.168.20.110.ssh > 192.168.4.20.3579: . ack 541 win 108 <nop,nop,timestamp 4294950292 60498>
12:58:01.289283 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 541:645(104) ack 24 win 64489 <nop,nop,timestamp 60498 4294950279>
12:58:01.289290 IP 192.168.20.110.ssh > 192.168.4.20.3579: . ack 645 win 108 <nop,nop,timestamp 4294950292 60498>
12:58:01.290007 IP 192.168.20.110.ssh > 192.168.4.20.3579: P 24:664(640) ack 645 win 108 <nop,nop,timestamp 4294950292 60498>
12:58:01.294770 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 645:661(16) ack 664 win 63849 <nop,nop,timestamp 60498 4294950292>
12:58:01.297546 IP 192.168.20.110.ssh > 192.168.4.20.3579: P 664:944(280) ack 661 win 108 <nop,nop,timestamp 4294950300 60498>
12:58:01.331144 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 661:933(272) ack 944 win 63569 <nop,nop,timestamp 60499 4294950300>
12:58:01.350655 IP 192.168.20.110.ssh > 192.168.4.20.3579: P 944:1536(592) ack 933 win 124 <nop,nop,timestamp 4294950353 60499>
12:58:01.384974 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 933:949(16) ack 1536 win 64512 <nop,nop,timestamp 60499 4294950353>
12:58:01.385002 IP 192.168.4.20.3579 > 192.168.20.110.ssh: P 949:1001(52) ack 1536 win 64512 <nop,nop,timestamp 60499 4294950353>


So apparently WindowsXP sends a NULL tsval in SYN packet, then subsequent packets get a real value (60498) in this case.

This seems to work on other OS as well, so is the following patch considered evil ?
Do we have security concerns or only risking windows client to have slightly wrong rtt estimation
at the begining of the tcp session ?

Thanks a lot

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cf74c41..4a55854 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1226,15 +1226,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
-	if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
-		/* Some OSes (unknown ones, but I see them on web server, which
-		 * contains information interesting only for windows'
-		 * users) do not send their stamp in SYN. It is easy case.
-		 * We simply do not advertise TS support.
-		 */
-		tmp_opt.saw_tstamp = 0;
-		tmp_opt.tstamp_ok  = 0;
-	}
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 
 	tcp_openreq_init(req, &tmp_opt, skb);
