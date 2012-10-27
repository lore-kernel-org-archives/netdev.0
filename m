From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Fri, 26 Oct 2012 17:07:26 -0700
Message-ID: <CAGK4HS922-xSd0YQdE2kExzMci8A36v_m_GPa17FM7wMJ08n3w@mail.gmail.com>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	<alpine.LFD.2.00.1210262325480.2880@ja.ssi.bg>
	<1351287724.30380.35.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1210270111030.3241@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57090 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966897Ab2J0AH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 20:07:28 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so3117132obb.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 17:07:27 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210270111030.3241@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian,
Thanks for the review.

>
>         We have 3 general cases:
>
> 1. HTTP-kind of protocol: client sends first, server without
> TCP_DEFER_ACCEPT
>
>         Server should retransmit but anyways client will
> send packet (ACK) that will move request_sock into child socket.

In  this case, is this retransmit from server and ack from client
necessary? I believe that when client finally sends fourth packet i.e.
data, server socket (currently request_sock) can move into accept
queue and into ESTABLISHED state. So this patch just removes
the syn-ack /ack transmissions in between.


>
> 2. HTTP-kind of protocol: client sends first, server with
> TCP_DEFER_ACCEPT
>
>         Server retransmits before 3WHS to get ACK from
> client. After ACK we keep request_sock because we do not
> want to wakeup listener without data. During TCP_DEFER_ACCEPT
> period nothing is retransmitted because we have ACK from
> client. After TCP_DEFER_ACCEPT period we start retransmissions
> because the server needs such request_socks to become
> child sockets after the TCP_DEFER_ACCEPT period and because
> received ACK is the only way to create child socket.
> Server wants to accept() them.

As I mentioned, if client is sending data first, then the data packet
from client will also cause the creation of child socket.
If server sends the synack again, if client is not ready with data, it
will just send an ack back. This is a needless synack/ack.
On the other hand if client is ready with data, it will send it and
server socket will create child socket if accept queue has space.

Even with DEFER_ACCEPT sockets, if a third ack comes in without data,
it is remembered in inet_rsk(req)->acked. So,
logic is the same. If inet_rsk(req)->acked==1, it means we have
received third ack and client is in ESTABLISHED state.
So why bother resending needless synacks?


> If TCP_DEFER_ACCEPT is
> above sysctl_tcp_synack_retries there are no such
> retransmissions because server does not want to accept()
> such request_socks without data. So, servers decide
> what they want with the TCP_DEFER_ACCEPT period value.
>
> 3. SMTP-kind of protocol: server sends first,
> TCP_DEFER_ACCEPT must not be used by server.
>         3WHS is completed, there is no 4th packet from
> client. It is the server side that needs to move request_sock
> to child socket, to accept the connection and to send
> welcome message. AFAIK, child socket is created only on
> ACK. Or I'm missing something? Now the question is:

You raise a good point. As far as I can see, it looks like the
request_sock will not become a full socket
if server is the one that has to send the data first. The problem it
seems is that we always have to wait
for the client to send something to create the full socket. Since
server side already knows that TWHS has finished,
maybe we can find a way to move a request_sock to accept_queue as
space opens up without sending synack.


> how request_sock is moved into child socket if ACK is
> dropped on syn_recv_sock failure and we do not send SYN-ACK
> retransmissions to trigger ACK from client? Client does not
> plan to send new packet in short time.

Agreed. Unless I am missing something too, for cases where server
socket sends data first, the patch will break things though for
defer-sockets
it seems ok. Maybe we need another approach?

Thanks for the feedback. I will wait for suggestions as to what to do
with the patch and have another look at the code.

Regards,
Vijay
