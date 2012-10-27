From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 11:43:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210271011040.1628@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com> <alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg> <1351287724.30380.35.camel@edumazet-glaptop> <alpine.LFD.2.00.1210270111030.3241@ja.ssi.bg>
 <CAGK4HS922-xSd0YQdE2kExzMci8A36v_m_GPa17FM7wMJ08n3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34327 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712Ab2J0IhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2012 04:37:09 -0400
In-Reply-To: <CAGK4HS922-xSd0YQdE2kExzMci8A36v_m_GPa17FM7wMJ08n3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 26 Oct 2012, Vijay Subramanian wrote:

> Julian,
> Thanks for the review.
> 
> >
> >         We have 3 general cases:
> >
> > 1. HTTP-kind of protocol: client sends first, server without
> > TCP_DEFER_ACCEPT
> >
> >         Server should retransmit but anyways client will
> > send packet (ACK) that will move request_sock into child socket.
> 
> In  this case, is this retransmit from server and ack from client
> necessary? I believe that when client finally sends fourth packet i.e.
> data, server socket (currently request_sock) can move into accept
> queue and into ESTABLISHED state. So this patch just removes
> the syn-ack /ack transmissions in between.

	I agree that we have the right to stop SYN-ACK
retransmits but only if there is a mechanism that converts
request_sock into child socket and wakeups listener when
there is space for new child. For case 1 this patch works
because it is client's job to talk first. But patch can not
differentiate case 1 from case 3 where child is not created.

> > 2. HTTP-kind of protocol: client sends first, server with
> > TCP_DEFER_ACCEPT
> >
> >         Server retransmits before 3WHS to get ACK from
> > client. After ACK we keep request_sock because we do not
> > want to wakeup listener without data. During TCP_DEFER_ACCEPT
> > period nothing is retransmitted because we have ACK from
> > client. After TCP_DEFER_ACCEPT period we start retransmissions
> > because the server needs such request_socks to become
> > child sockets after the TCP_DEFER_ACCEPT period and because
> > received ACK is the only way to create child socket.
> > Server wants to accept() them.
> 
> As I mentioned, if client is sending data first, then the data packet
> from client will also cause the creation of child socket.
> If server sends the synack again, if client is not ready with data, it
> will just send an ack back. This is a needless synack/ack.

	Indeed, here TCP_DEFER_ACCEPT can also benefit from such 
mechanism to convert requests to childs. In this case, child must
appear after the TCP_DEFER_ACCEPT period (in case no data
is received). So, this mechanism should work depending on
the TCP_DEFER_ACCEPT period. We can stop such retransmits
only when new mechanism is implemented.

> On the other hand if client is ready with data, it will send it and
> server socket will create child socket if accept queue has space.
> 
> Even with DEFER_ACCEPT sockets, if a third ack comes in without data,
> it is remembered in inet_rsk(req)->acked. So,
> logic is the same. If inet_rsk(req)->acked==1, it means we have
> received third ack and client is in ESTABLISHED state.
> So why bother resending needless synacks?

	Only to trigger ACK that will create child. We
just want the child after the TCP_DEFER_ACCEPT period has
expired. Retransmits are the current mechanism to
create child, they are not goal. The goal is to create child.

> > If TCP_DEFER_ACCEPT is
> > above sysctl_tcp_synack_retries there are no such
> > retransmissions because server does not want to accept()
> > such request_socks without data. So, servers decide
> > what they want with the TCP_DEFER_ACCEPT period value.
> >
> > 3. SMTP-kind of protocol: server sends first,
> > TCP_DEFER_ACCEPT must not be used by server.
> >         3WHS is completed, there is no 4th packet from
> > client. It is the server side that needs to move request_sock
> > to child socket, to accept the connection and to send
> > welcome message. AFAIK, child socket is created only on
> > ACK. Or I'm missing something? Now the question is:
> 
> You raise a good point. As far as I can see, it looks like the
> request_sock will not become a full socket
> if server is the one that has to send the data first. The problem it
> seems is that we always have to wait
> for the client to send something to create the full socket. Since
> server side already knows that TWHS has finished,
> maybe we can find a way to move a request_sock to accept_queue as
> space opens up without sending synack.

	I'm not sure if that is possible, may be ACK comes
with more data that is not saved in request_sock, even
payload. It is lost. From time to time we get new fields
into struct request_sock but I don't know if we have
everything that is needed to create child, I doubt it.

> > how request_sock is moved into child socket if ACK is
> > dropped on syn_recv_sock failure and we do not send SYN-ACK
> > retransmissions to trigger ACK from client? Client does not
> > plan to send new packet in short time.
> 
> Agreed. Unless I am missing something too, for cases where server
> socket sends data first, the patch will break things though for
> defer-sockets
> it seems ok. Maybe we need another approach?

	The effect of current patch is:

- case 1: saves retransmits, that is good

- case 2: server can not accept child after TCP_DEFER_ACCEPT
period, clients can hate your service. 3WHS is complete
and it is expected longer timers to apply, say 15mins,
while server uses SYN_RECV state timeouts which are
shorter. Client can get RST if data is delayed above
that timers. Without the patch, we will trigger new ACK
from client and new child can enter established state.
TCP_DEFER_ACCEPT period is just an optimization that
avoids wakeups without data for a period but server
still has the following options:

	- send SYN-ACK, on ACK create child and send FIN
	- send SYN-ACK, on ACK create child and wait 15mins for data
	- expire them as request_socks if they do not send data,
	later send RST on delayed data from client

	With the patch we do not have a way to accept childs.
	You restrict server using TCP_DEFER_ACCEPT to
	shorter timeout to get client data because we
	are left only with the option to expire request_socks,
	server can prefer small SYN-ACK retry count but
	long timeout for client data.

- case 3: no welcome, client aborts

> Thanks for the feedback. I will wait for suggestions as to what to do
> with the patch and have another look at the code.

	I'll think on this problem but my knowledge in this
area is limited. May be the TCP gurus know better what can
be done. My guess is that child creation on ACK is mandatory,
especially when ACK comes with payload.

> Regards,
> Vijay

Regards

--
Julian Anastasov <ja@ssi.bg>
