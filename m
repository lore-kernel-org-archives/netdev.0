From: John Ogness <john.ogness@linutronix.de>
Subject: Re: nonagle flags for TSQ
Date: Fri, 07 Feb 2014 17:34:54 +0100
Message-ID: <878utm3mq9.fsf@linutronix.de>
References: <87fvnv2c5k.fsf@linutronix.de>
	<1391787297.10160.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:47092 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaBGQe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 11:34:59 -0500
In-Reply-To: <1391787297.10160.50.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Fri, 07 Feb 2014 07:34:57 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 2014-02-07, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> I have a question about the use of tcp_write_xmit() in
>> net/ipv4/tcp_output.c
>> 
>> When tcp_write_xmit() is called, the nonagle flag of the tcp socket
>> is ignored and instead 0 is passed. This causes the Nagle-algorithm
>> to be used even if it should not be, which in some cases causes a
>> large delay.
>> 
>> Was there a reason that 0 was hard-coded?
>> 
>> Although current mainline code has been refactored, 0 is still
>> hard-coded for TSQ cases.
>
> Do you have any data, like exact kernel version you use, tcpdump or
> things like that ?

Yes. Provided below.

> I am not aware of TSQ being a problem for Nagle.

We are talking about a scenario where Nagle is not supposed to be used
(i.e. TCP_NODELAY is set on the socket).

Here are TCP dumps taken when initiating a gdb debug session from host
to clnt. One from a 2.6 kernel, where the delay is not present. One from
a 3.10 kernel, where a 39ms(!) delay is present. The packets are the
same except the 3.10 kernel shows an extra ACK packet (14th packet from
3.10 dump).

On 2.6 Kernel:
00:00:00.000000 IP host.51922 > clnt.10123: Flags [S], seq 2979238116, win 5840, options [mss 1460,sackOK,TS val 1988280883 ecr 0,nop,wscale 6], length 0
00:00:00.000587 IP clnt.10123 > host.51922: Flags [S.], seq 3460146061, ack 2979238117, win 5792, options [mss 1460,sackOK,TS val 4294688455 ecr 1988280883,nop,wscale 6], length 0
00:00:00.000022 IP host.51922 > clnt.10123: Flags [.], ack 1, win 92, options [nop,nop,TS val 1988280883 ecr 4294688455], length 0
00:00:00.000064 IP host.51922 > clnt.10123: Flags [P.], seq 1:15, ack 1, win 92, options [nop,nop,TS val 1988280883 ecr 4294688455], length 14
00:00:00.000507 IP clnt.10123 > host.51922: Flags [.], ack 15, win 91, options [nop,nop,TS val 4294688456 ecr 1988280883], length 0
00:00:00.000010 IP clnt.10123 > host.51922: Flags [P.], seq 1:2, ack 15, win 91, options [nop,nop,TS val 4294688456 ecr 1988280883], length 1
00:00:00.000010 IP host.51922 > clnt.10123: Flags [.], ack 2, win 92, options [nop,nop,TS val 1988280884 ecr 4294688456], length 0
00:00:00.000005 IP clnt.10123 > host.51922: Flags [P.], seq 2:94, ack 15, win 91, options [nop,nop,TS val 4294688456 ecr 1988280883], length 92
00:00:00.000006 IP host.51922 > clnt.10123: Flags [.], ack 94, win 92, options [nop,nop,TS val 1988280884 ecr 4294688456], length 0
00:00:00.000027 IP host.51922 > clnt.10123: Flags [P.], seq 15:16, ack 94, win 92, options [nop,nop,TS val 1988280884 ecr 4294688456], length 1
00:00:00.000030 IP host.51922 > clnt.10123: Flags [P.], seq 16:56, ack 94, win 92, options [nop,nop,TS val 1988280884 ecr 4294688456], length 40
00:00:00.000450 IP clnt.10123 > host.51922: Flags [.], ack 56, win 91, options [nop,nop,TS val 4294688456 ecr 1988280884], length 0
00:00:00.000010 IP clnt.10123 > host.51922: Flags [P.], seq 94:95, ack 56, win 91, options [nop,nop,TS val 4294688456 ecr 1988280884], length 1
00:00:00.000006 IP clnt.10123 > host.51922: Flags [P.], seq 95:150, ack 56, win 91, options [nop,nop,TS val 4294688456 ecr 1988280884], length 55
00:00:00.000053 IP host.51922 > clnt.10123: Flags [.], ack 150, win 92, options [nop,nop,TS val 1988280885 ecr 4294688456], length 0

On 3.10 Kernel:
00:00:00.000000 IP host.56618 > clnt.10123: Flags [S], seq 315694752, win 5840, options [mss 1460,sackOK,TS val 1987836230 ecr 0,nop,wscale 6], length 0
00:00:00.000267 IP clnt.10123 > host.56618: Flags [S.], seq 469364385, ack 315694753, win 14480, options [mss 1460,sackOK,TS val 6070753 ecr 1987836230,nop,wscale 7], length 0
00:00:00.000022 IP host.56618 > clnt.10123: Flags [.], ack 1, win 92, options [nop,nop,TS val 1987836231 ecr 6070753], length 0
00:00:00.000071 IP host.56618 > clnt.10123: Flags [P.], seq 1:15, ack 1, win 92, options [nop,nop,TS val 1987836231 ecr 6070753], length 14
00:00:00.000501 IP clnt.10123 > host.56618: Flags [.], ack 15, win 114, options [nop,nop,TS val 6070753 ecr 1987836231], length 0
00:00:00.000011 IP clnt.10123 > host.56618: Flags [P.], seq 1:2, ack 15, win 114, options [nop,nop,TS val 6070753 ecr 1987836231], length 1
00:00:00.000007 IP host.56618 > clnt.10123: Flags [.], ack 2, win 92, options [nop,nop,TS val 1987836231 ecr 6070753], length 0
00:00:00.000502 IP clnt.10123 > host.56618: Flags [P.], seq 2:94, ack 15, win 114, options [nop,nop,TS val 6070753 ecr 1987836231], length 92
00:00:00.000008 IP host.56618 > clnt.10123: Flags [.], ack 94, win 92, options [nop,nop,TS val 1987836232 ecr 6070753], length 0
00:00:00.000022 IP host.56618 > clnt.10123: Flags [P.], seq 15:16, ack 94, win 92, options [nop,nop,TS val 1987836232 ecr 6070753], length 1
00:00:00.000030 IP host.56618 > clnt.10123: Flags [P.], seq 16:56, ack 94, win 92, options [nop,nop,TS val 1987836232 ecr 6070753], length 40
00:00:00.000507 IP clnt.10123 > host.56618: Flags [.], ack 56, win 114, options [nop,nop,TS val 6070753 ecr 1987836232], length 0
00:00:00.000009 IP clnt.10123 > host.56618: Flags [P.], seq 94:95, ack 56, win 114, options [nop,nop,TS val 6070753 ecr 1987836232], length 1
00:00:00.039314 IP host.56618 > clnt.10123: Flags [.], ack 95, win 92, options [nop,nop,TS val 1987836272 ecr 6070753], length 0
00:00:00.000502 IP clnt.10123 > host.56618: Flags [P.], seq 95:150, ack 56, win 114, options [nop,nop,TS val 6070757 ecr 1987836272], length 55
00:00:00.000031 IP host.56618 > clnt.10123: Flags [.], ack 150, win 92, options [nop,nop,TS val 1987836272 ecr 6070757], length 0


Using the following patch fixed the problem, but maybe there was a
reason why it wasn't implemented like this in the first place?


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 03d26b8..9408a0d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -697,8 +697,11 @@ static void tcp_tsq_handler(struct sock *sk)
 {
 	if ((1 << sk->sk_state) &
 	    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_CLOSING |
-	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK))
-		tcp_write_xmit(sk, tcp_current_mss(sk), 0, 0, GFP_ATOMIC);
+	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		tcp_write_xmit(sk, tcp_current_mss(sk), tp->nonagle, 0,
+			       GFP_ATOMIC);
+	}
 }
 /*
  * One tasklet per cpu tries to send more skbs.


John Ogness
