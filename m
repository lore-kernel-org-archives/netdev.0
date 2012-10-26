From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 01:52:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210270111030.3241@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>  <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg> <1351287724.30380.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57036 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab2JZWqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 18:46:10 -0400
In-Reply-To: <1351287724.30380.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 26 Oct 2012, Eric Dumazet wrote:

> On Sat, 2012-10-27 at 00:30 +0300, Julian Anastasov wrote:
> > 
> > 	Wait a minute, this can cause problem at least
> > for the TCP_DEFER_ACCEPT mode. It is supposed to timeout
> > in SYN_RECV state if after silence period (no retransmissions)
> > and some final retransmissions (until max_retries) client
> > still does not send data - the request should be expired
> > without notifying the listener.
> > 
> > 	So, the logic in syn_ack_recalc() was tuned to resend
> > after the TCP_DEFER_ACCEPT period. This patch stops such
> > resends after TCP_DEFER_ACCEPT period. May be the change
> > should be in syn_ack_recalc() without hurting TCP_DEFER_ACCEPT?
> > 
> > 	Lets analyze the default case without TCP_DEFER_ACCEPT.
> > 
> > 	Think for protocols like SMTP where server sends
> > welcome message. This patch stops SYN-ACK resends, client
> > sends one ACK (which server drops) and enters EST state.
> > Client is waiting for welcome message in EST state while
> > server is waiting silently for ACK message to create child
> > socket. No progress, may but timeout error in client.
> > 
> > 	Is the patch safe for such case? Is there a logic
> > that creates child socket from request if the dropped ACK
> > was the last message from client? It must not do it for
> > TCP_DEFER_ACCEPT.
> 
> 
> I see no impact with TCP_DEFER_ACCEPT handling.
> 
> TCP_DEFER_ACCEPT is quite different from this stuff
> 
> The 3WHS is completed, and the socket is ready.
> 
> But its not delivered to the accept() (listener) until we receive a DATA
> frame (or defer timeout elapsed)
> 
> We dont resend SYNACK messages for them. We just wait the 4th packet.

	We have 3 general cases:

1. HTTP-kind of protocol: client sends first, server without
TCP_DEFER_ACCEPT

	Server should retransmit but anyways client will
send packet (ACK) that will move request_sock into child socket.

2. HTTP-kind of protocol: client sends first, server with
TCP_DEFER_ACCEPT

	Server retransmits before 3WHS to get ACK from
client. After ACK we keep request_sock because we do not
want to wakeup listener without data. During TCP_DEFER_ACCEPT
period nothing is retransmitted because we have ACK from
client. After TCP_DEFER_ACCEPT period we start retransmissions
because the server needs such request_socks to become
child sockets after the TCP_DEFER_ACCEPT period and because
received ACK is the only way to create child socket.
Server wants to accept() them. If TCP_DEFER_ACCEPT is
above sysctl_tcp_synack_retries there are no such
retransmissions because server does not want to accept()
such request_socks without data. So, servers decide
what they want with the TCP_DEFER_ACCEPT period value.

3. SMTP-kind of protocol: server sends first,
TCP_DEFER_ACCEPT must not be used by server.

	3WHS is completed, there is no 4th packet from
client. It is the server side that needs to move request_sock
to child socket, to accept the connection and to send
welcome message. AFAIK, child socket is created only on
ACK. Or I'm missing something? Now the question is:
how request_sock is moved into child socket if ACK is
dropped on syn_recv_sock failure and we do not send SYN-ACK 
retransmissions to trigger ACK from client? Client does not
plan to send new packet in short time.

Regards

--
Julian Anastasov <ja@ssi.bg>
