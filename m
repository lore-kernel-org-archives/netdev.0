From: "ithilgore.ryu.L@gmail.com" <ithilgore.ryu.l@gmail.com>
Subject: FIN_WAIT1 state without FIN (active close)
Date: Thu, 25 Dec 2008 04:52:25 +0200
Message-ID: <4952F569.3040701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:43321 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbYLYC7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 21:59:25 -0500
Received: by ewy10 with SMTP id 10so3482531ewy.13
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2008 18:59:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings.

I have been experimenting with the Linux network stack and just came
across the following: a host being in the FIN_WAIT1 state (as shown by
netstat) but without ever having sent a FIN (active close).

The triggering of the above went like this: host A blocks incoming
access from host B, crafts a SYN packet, sends it to a specific
listening port on host B(say 80), listens for the synack response from
host B (through a sniffer), and completes tha 3way handshake by sending
the 3rd segment along with an http GET request (the ack and the GET
request are on the same packet since tcp allows this kind of piggybacking).
At this time, host B tries sending the reply to the GET request. This is
where netstat shows the state of the connection in host B as FIN_WAIT1.
No FIN packet, however, has ever leaved the wire, neither from host B
nor from host A. Shouldn't the state be TCP_ESTABLISHED?

I looked at the net/ipv4/tcp.c and some relevant tcp* files and came
across something that might be have some connection to the above.
However this is from function "void tcp_close(struct sock *sk, long
timeout)" which is only called afaik if the application calls close().
Additionally, inspecting the code of tcp.c I saw that the only way to
make a transition to state TCP_FIN_WAIT1 is to send a FIN with
tcp_send_fin().


tcp.c:
void tcp_close(struct sock *sk, long timeout)
{
	...


	} else if (tcp_close_state(sk)) {
		/* We FIN if the application ate all the data before
		 * zapping the connection.
		 */

		/* RED-PEN. Formally speaking, we have broken TCP state
		 * machine. State transitions:
		 *
		 * TCP_ESTABLISHED -> TCP_FIN_WAIT1
		 * TCP_SYN_RECV	-> TCP_FIN_WAIT1 (forget it, it's impossible)
		 * TCP_CLOSE_WAIT -> TCP_LAST_ACK
		 *
		 * are legal only when FIN has been sent (i.e. in window),
		 * rather than queued out of window. Purists blame.
		 *
		 * F.e. "RFC state" is ESTABLISHED,
		 * if Linux state is FIN-WAIT-1, but FIN is still not sent.
		 *
		 * The visible declinations are that sometimes
		 * we enter time-wait state, when it is not required really
		 * (harmless), do not send active resets, when they are
		 * required by specs (TCP_ESTABLISHED, TCP_CLOSE_WAIT, when
		 * they look as CLOSING or LAST_ACK for Linux)
		 * Probably, I missed some more holelets.
		 * 						--ANK
		 */
		tcp_send_fin(sk);
	}


Of course, I might (or rather must) have missed something. Also, if I
remember correctly (I had checked this some time ago), the *BSD network
stack makes the transition to TCP_ESTABLISHED as expected.

--
ithilgore




