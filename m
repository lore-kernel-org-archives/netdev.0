From: Jan Olderdissen <jan@ixiacom.com>
Subject: RE: [PATCH 2.6.5] Re: Fw: Stack sends SYN/ACKs even though accept
	 queue is full
Date: Fri, 14 May 2004 16:11:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627ACEA@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: akpm@osdl.org, netdev@oss.sgi.com, Thomas Ameling
	 <tameling@ixiacom.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>,
        Nivedita Singhvi
	 <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

> I really haven't seen a convincing argument yet to change the behavior
> here, I think it's sane but I'm ready to be convinced otherwise :-)

Upon further reflection, I've convinced myself that the current algorithm is
more broken than I thought - at least in some situations.

Let's review the status quo in tcp_v4_conn_request(): Incoming SYNs are
dropped if

1. The synq is full, or
2. The accept queue is full AND the number of "young" entries in the synq is
greater than 1.

If the SYN is not dropped, a synq entry is allocated, marked "young", and a
SYN/ACK is sent. Entries one the synq "age" on their first timeout.

In previous posts in this thread I suggested removing the condition dealing
with "young" entries because this allows the synq to grow even though there
is no room in the accept queue. The symptom this causes is a sequence like
this:

C -> S SYN
S -> C SYN/ACK
C -> S ACK # if the acceptq is still full at this point, this ack is dropped
C -> S data1 # this is also dropped
C -> S data2 # this is also dropped
C -> S data3 # this is also dropped
S -> C SYN/ACK
C -> S ACK # if the acceptq is still full at this point, this ack is dropped
C -> S data1 # this is also dropped
C -> S data2 # this is also dropped
C -> S data3 # this is also dropped

and so forth until timeout. The client thinks the connection is up and
bandwidth is wasted.

Nivedita was very helpful in providing a patch for this. It works inasmuch
it fixes the problem for the case where the acceptq is full.

Sadly, I missed the second condition under which SYNs can go on the synq
without room on the acceptq being available. If the acceptq is almost full
and the server receives a burst of SYNs, the server will accept and SYN/ACK
_all_ SYNs that fit in the synq. I've tested this condition using an Ixia
400T chassis with an ALM1000T8 load module. Using three of the eight test
ports (each has a PowerPC 750 processor and gigE interface) to hammer on a
fourth test port configured as a server, the synq quickly outgrew the
acceptq in length. Obviously, most of the entries on the synq were in the
unhappy mode described above as there was no way the server could keep up
with the clients.

Ultimately, I propose that the concept of SYN/ACKing a connection that we
don't have room for in the acceptq is evil and should be replaced by a
mechanism that remembers SYNs but doesn't SYN/ACK right away if there is no
room on the acceptq. This provides the benefit of keeping the packet traces
sane as well as keeping around warm connections to be SYN/ACKed as soon as
the acceptq starts emptying.

I therefore suggest the following algorithm:

Three queues are used: 

synq1: holds connections that have sent a SYN but have not been SYN/ACKed
synq2: holds connections that have been SYN/ACKed
acceptq: holds connections that have completed 3-way handshake

When a SYN comes in, the following pseudo code is executed:

if (len(synq1)+len(synq2) > MAX_SYNQ) goto drop;
if (len(synq2)+len(acceptq) < MAX_ACCEPTQ) {
    send_synack();
    synq2.add (new_connection);
} else {
    synq1.add (new_connection);
}

When an ACK is received, the following code is executed:

synq2.remove (connection);
acceptq.add (connection);

When an entry has been removed from the acceptq by the app, the following
code is executed:

int max_synack = MAX_ACCEPTQ - len(acceptq) - len(synq2);
while (max_synack-- && len(synq1)) {
    # move connection from synq1 to synq2 and send SYN/ACK
    send_synack();
    connection = synq1.pop();
    synq2.add (connection);
}

Notes:

- MAX_ACCEPTQ is shorthand for the socket specific accept queue length.

Jan
