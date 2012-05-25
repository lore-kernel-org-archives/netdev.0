From: Earl Chew <echew@ixiacom.com>
Subject: Inadvertently sending a Christmas Tree TCP packet
Date: Fri, 25 May 2012 15:15:26 -0700
Message-ID: <4FC0047E.9070907@ixiacom.com>
References: <4FBFCFCA.2090501@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:26653
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756213Ab2EYWPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 18:15:35 -0400
In-Reply-To: <4FBFCFCA.2090501@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had previously observed the following behaviour captured from WireShark:

16220	111.075627	10.64.33.43	10.128.163.100	TCP	59253 > exec [SYN] Seq=0 Win=65535 Len=0 MSS=1460 WS=2
16222	0.203210	10.128.163.100	10.64.33.43	TCP	exec > 59253 [SYN, ACK] Seq=0 Ack=1 Win=5840 Len=0 MSS=1250 WS=7
16223	0.000032	10.64.33.43	10.128.163.100	TCP	59253 > exec [ACK] Seq=1 Ack=1 Win=65532 Len=0
... snip ...
16237	0.000319	10.128.163.100	10.64.33.43	TCP	exec > 59253 [FIN, PSH, ACK, URG] Seq=31 Ack=30 Win=5888 Urg=1 Len=1
16240	1.114085	10.128.163.100	10.64.33.43	TCP	[TCP Retransmission] exec > 59253 [FIN, PSH, ACK, URG] Seq=31 Ack=30 Win=5888 Urg=1 Len=1


These packets were sent from an application running on Linux 2.6.18. 

The receiver has become confused, and the so the Linux sender retransmits at packet 16240,
and continues retransmitting. In this case, the application code at the receiver is blocked
indefinitely trying to read a socket that seemingly has (URG) data and yet at the same time
doesn't have any more data (FIN).

Looking at the 2.6.18 source code for tcp_output.c, I see code at tcp_send_fin()
that is attaching FIN to the packet.

The code in 3.4 seems fairly much the same:


/* Send a fin.  The caller locks the socket for us.  This cannot be
 * allowed to fail queueing a FIN frame under any circumstances.
 */
void tcp_send_fin(struct sock *sk)
{
	struct tcp_sock *tp = tcp_sk(sk);
	struct sk_buff *skb = tcp_write_queue_tail(sk);
	int mss_now;

	/* Optimization, tack on the FIN if we have a queue of
	 * unsent frames.  But be careful about outgoing SACKS
	 * and IP options.
	 */
	mss_now = tcp_current_mss(sk);

	if (tcp_send_head(sk) != NULL) {
		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_FIN;
		TCP_SKB_CB(skb)->end_seq++;
		tp->write_seq++;
	} else {



The comment block says to be careful about IP options, but
the code doesn't appear to worry too much.

Is something like:

	if (tcp_send_head(sk) != NULL &&
		TCP_SKB_CB(skb)->tcp_flags == 0)

more appropriate ?


Earl
