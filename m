From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Fri, 26 Mar 2010 12:33:07 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003261231410.30253@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home>
 <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home> <20100322185310.GA20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322185310.GA20695@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a pgm.7 manpage describing how the socket API could look like for
a PGM implementation.

I dumped the RM_* based socket options from the other OS since most of the
options were unusable.



.\" This man page is Copyright (C) 2010 Christoph Lameter <cl@linux-foundation.org>.
.\" Permission is granted to distribute possibly modified copies
.\" of this page provided the header is included verbatim,
.\" and in case of nontrivial modification author and date
.\" of the modification is added to the header.
.\"
.TH PGM  7 2010-08-01 "Linux" "Linux Programmer's Manual"
.SH NAME
pgm \- Pragmatic General Multicast Protocol Support for IPv4
.SH SYNOPSIS
.B #include <sys/socket.h>
.br
.B #include <netinet/in.h>
.br
.B #include <linux/pgm.h>
.sp
.B pgm_socket = socket(AF_INET, SOCK_RDM, IPPROTO_PGM);
.br
.B pgm_socket = socket(AF_INET, SOCK_RDM, IPPROTO_UDP);
.SH DESCRIPTION
This is an implementation of the Pragmatic General Multicast Protocol
described in RFC\ 3028.
PGM implements a connection oriented, Reliable Datagram Messaging
(thus SOCK_RDM) protocol. Packets are delivered in order even though the
network may
have reordered, duplicated or dropped packets. Receivers may ask for
retransmission of missed packets (NAK). Transmitters do not keep receiver
state so that an individual sender is able to interact with an unlimited
number of receivers.
The recovery mechanism of PGM can limit the scalability of PGM if too
many receivers are NAKing. Therefore measures exist at various layers
to reduce the potential repair volume that a transmitter may have to
deal with.

PGM supports two variants. The first one is the
.B native PGM protocol
which uses its own IP protocol implementation at the same level as TCP and UDP.
Native PGM supports NAK suppression ("assist") by network elements (Cisco,
Juniper and other commercially available routers have support for PGM) which
is an important measure to reduce the NAK volume in case of packet loss during
multicast replication of messages in the network. Routers can consolidate
multiple NAKs from downstream into a single upstream and are also able to
use
.B FEC
(Forward Error Correction) to directly provide repair data without having to
forward NAKs to a transmitter.

The second variant is
.B PGM over UDP.
UDP is used as a transport protocol
instead of IP. PGM over UDP does
.B not
support assist from network elements and
therefore has limited support for NAK suppression. PGM over UDP mainly exists
because of the lack of kernel based PGM implementations. Using raw sockets
for packet creation and packet reception is inefficient and slow. User space
based PGM implementation typically are restricted to a single stream or multiple
stream in the same process since the in kernel multiplexing available for TCP
and UDP does not exist.
PGM over UDP allows the use of UDP port multiplexing instead which allows for]
efficient operation of multiple streams on a single system even if the
OS has no native support for PGM.

Creation of a PGM socket will lead to an unconnected socket. A sender must connect
to a multicast address to be able to send messages. A receiver needs to
bind to the multicast address and port number of interest and then listen
to the socket. The receiver can accept a connection when PGM traffic is
received on the chosen PGM multicast address and port. It is then
possible to receive datagrams on the PGM socket.

When
.BR connect (2)
is called on the socket, the multicast destination address is set and
datagrams can then be sent using
.BR send (2)
or
.BR write (2).
It is not possible to send to other destinations than the single multicast
address connected to. Note that the the send operations will cause the
application to be throttled if the maximum transmission rate is exceeded.
Throttling can be avoided by setting the socket to non blocking mode or
using MSG_DONTWAIT.

In order to receive packets, the socket needs to be bound to a multicast
address first by using
.BR bind (2).

All receive operations return only one packet.
When the packet is smaller than the passed buffer, only that much
data is returned; when it is bigger, the packet is truncated and the
.B MSG_TRUNC
flag is set.
.B MSG_WAITALL
is not supported.

Some IP options may be sent or received using the socket options described in
.BR ip (7).
However, multicast join and leave operations are not supported.
See
.BR ip (7).

By default, Linux PGM does path MTU (Maximum Transmission Unit) discovery.
This means the kernel
will keep track of the MTU to a specific target IP address and return
.B EMSGSIZE
when a PGM packet write exceeds it.
When this happens, the application should decrease the packet size.
Path MTU discovery can be also turned off using the
.B IP_MTU_DISCOVER
socket option or the
.I /proc/sys/net/ipv4/ip_no_pmtu_disc
file; see
.BR ip (7)
for details.
When turned off, PGM will fragment outgoing PGM packets
that exceed the interface MTU.
However, disabling it is not recommended
for performance and reliability reasons.
.SS "Address Format"
PGM supports IPv4 and IPv6 but Linux currently only supports IPv4. The
.I sockaddr_in
address format described in
.BR ip (7)
is used.
.SS "Error Handling"
All fatal errors will be passed to the user as an error return even
when the socket is not connected.
This includes asynchronous errors
received from the network.
You may get an error for an earlier packet
that was sent on the same socket.

When the
.B IP_RECVERR
option is enabled, all errors are stored in the socket error queue,
and can be received by
.BR recvmsg (2)
with the
.B MSG_ERRQUEUE
flag set.
.SS /proc interfaces
System-wide PGM parameter settings can be accessed by files in the directory
.IR /proc/sys/net/ipv4/ .
.TP
.IR pgm_mem " "
This is a vector of three integers governing the number
of pages allowed for queueing by all PGM sockets.
.RS
.TP 10
.I min
Below this number of pages, PGM is not bothered about its
memory appetite.
When the amount of memory allocated by PGM exceeds
this number, PGM starts to moderate memory usage.
.TP
.I pressure
This value was introduced to follow the format of
.IR tcp_mem
(see
.BR tcp (7)).
.TP
.I max
Number of pages allowed for queueing by all PGM sockets.
.RE
.IP
Defaults values for these three items are
calculated at boot time from the amount of available memory.
.TP
.IR pgm_window_size_default " (integer; default value: 10 MB)"
Default size, in bytes, of receive and transmit windows used by PGM sockets.
Each PGM socket is able to use the size for the receiving data window,
even if total pages of PGM sockets exceed pgm_mem pressure.
.TP
.IR pgm_window_msec_default " (integer; default value: 2000)"
Default time for packets to keep in the transmit and receive windows.
Each PGM socket is able to use the time period to resend data,
even if total pages of PGM sockets exceed
.I pgm_mem
pressure.
.TP
.IR pgm_ambient_spm_msecs " (integer; default value 15 seconds)"
Unconditional heartbeat sent by PGM transmitters to periodically notify receivers
about the stream status.
.TP
.IR pgm_spm_list_usec " (integers; default value: 1000 1000 4000 8000 16000 32000 64000 1280000 256000 1000000 2000000 8000000) "
Intervals for successive SPM heatbearts for the case that the connection goes idle. Initial SPMs are rapid to allow for
fast discovery of a missed packet and then back off until the unconditional heartbeat limit is reached.
.TP
.IR pgm_transmitter_rate_kbps "(integer; default value: 56)"
Default limit on the rate of traffic produced by a single transmitter.
The rate is an overall maximum of repair and original data. The limit
is set low because transmitters can do a lot of harm to the network
(especially WAN links) if they sent at high rates. It it advisable to
be careful when increasing the rate.
.TP
.IR pgm_transmitter_repair_rate_kpbs  "(integer; default value 30) "
Default limit on the amount of repair data sent by a single transmitter
.TP
.IR pgm_transmitter_nak_ignore_after_rdata_msec "(integer; default 50)"
Period during which to ignore receiver NAKs after repair data was sent
(is usually set to correlate to the maximum WAN delay seen).  This is
used to avoid useless additional repair data while NAK / repair data
is in flight.
.TP
.IR pgm_crybaby_rate_kbps " (integer; default 20)"
Maximum rate of repair traffic to a single receiver. A single receiver may
be slow and not able to keep up. Therefore it may continually ask for repairs (Thus
.B crybaby).
This parameter allows to limit the impact that continual repair traffic by the crybaby and
typically causes the crybaby to get so far out of sync that the receiver will finally have
to give up since messages for which repair is needed have been expired on the transmitter side.
Note that the transmitters do not keep track of the receivers. Crybaby detection is an
opportunitic heuristic method.
.TP
.IR pgm_fec_proactive_packets  " (integer; default 0 )"
The number of parity packets to insert in each sequence of
.B pgm_fec_group_size
packets. FEC (Forward Error Correction) is another means to reduce NAK
traffic in configurations with a large number of receivers. Receivers
(and network elements) will be able to reconstruct missed packets on their
own without resorting to NAKs. However, if too many packets are missed and
recover is not possible then NAKs will still be sent.
.TP
.IR pgm_fec_group_size	" (integer; default 16)"
Defines a unit of packets for which FEC parity packets are created.
.TP
.IR pgm_nak_retries " (integer; default 20)"
The number of recovery attempts to make for a single message before giving up.
.TP
.IR pgm_naks_per_sec " (integer; default 50)"
The maximum number of NAKs to send per second.
.IR pgm_debug " (integer; default 0)"
Allows enabling diagnostics for PGM interaction on the network.
If set to one then PGM will log all recovery activities/
If set to two then PGM will additionally log SPMs and SPMR and connection setup and teardown.
If set to three then PGM will log all activities in the syslog.

.SS "Socket Options"
To set or get a PGM socket option, call
.BR getsockopt (2)
to read or
.BR setsockopt (2)
to write the option with the option level argument set to
.BR IPPROTO_PGM .
.TP
.BR PGM_TRANSMITTER_CONFIG
This option is used to set up parameters for the transmitter before
connecting to a multicast address. The option cannot be used on a
connected SOCK_RDM socket. It is recommended to first get the
configuration data (which will contain the configured OS defaults) and
then modify individual fields as needed.
.sp
.in +4n
.nf
struct pgm_transmitter_config {
        int rate_kbyte;                         /* Maximum rate per second */
        int window_msecs;                       /* Window maximum packet age  */
        int window_kbytes;                      /* Window maximum size in kbytes */
        int ambient_spm_msecs;                  /* Unconditional SPM */
        int spm_msecs[12];                       /* Idle SPM backoff */
        int repeat_nak_ignore_msecs;            /* How long to skip nacks after sending rdata */
        int repair_rate_kbyte;                  /* Max permitted rate of repair traffic */
        int crybaby_rate_kbyte;                 /* Max rate of repair traffic to individual receiver */
        int transmit_only:1;                    /* If set do not process feedback from receivers */
        int fec:1;                              /* Enable forward error correction */
        int fec_parity:1;                       /* Respond to parity repair packet requests */
        int fec_packets_per_group;              /* Maximum number of packets for a group. */
        int fec_proactive_packets;              /* Number of proactive packets per group. */
        int fec_group_size;                     /* Number of packets to be treated as a group. Power of two */
}
.fi
.TP
.BR PGM_TRANSMITTER_STATISTICS
Retrieves transmitter statistics.
.sp
.in +4n
.nf
struct pgm_transmitter_stats {
        u64     bytes_received;
        u64     data_send;
        u64     naks_received;
        u64     naks_too_late;                  /* NAKs received after receive window advanced */
        u64     naks_outstanding;               /* Number of NAKs awaiting response */
        u64     naks_after_rdata;               /* Number of NAKs after RDATA sequences were sent which were ignored */
        u64     rdata_packets;                  /* Repair data */
        u64     odata_packets;                  /* Original data */
        u32     first_seqid;                    /* Oldest sequence id in window */
        u32     last_seqid;                     /* Newest sequence id in window */
};
fi
.TP
.BR PGM_RECEIVER_CONFIG
Used to setup receiver parameters before accepting a connection.
The option cannot be used a on a connected SOCK_RDM socket.
.sp
.in +4n
.nf
struct pgm_receiver_config {
        int window_msecs;                       /* Receive window maximum age (per transmitter) */
        int window_kbyte;                       /* Receive window maximum size (per transmitter) */
        int nak_retries;                        /* Nak retries before giving up */
        int nak_ncf_retries;                    /* Nak retries after NCF before giving up */
        int nak_backoff_interval;               /* time to backoff on NAK failure */
        int naks_per_sec;                       /* Limit on the naks per second */
        int peer_timeout;                       /* Discard peer if silent for this time period */
        int spmr_timeout;                       /* Abort connection if no SPMR response */
        int receive_only:1;                     /* Never send data to sender */
}
.fi
.TP
.BR PGM_RECEIVER_STATISTICS
Retrieves receiver statistics.
.sp
.in +4n
.nf
struct pgm_receiver_stats {
        u64     bytes_received;                 /* Total bytes received */
        u64     data_received                   /* Useful data bytes received */
        u64     odata_packets;                  /* Number of ODATA (original) sequences */
        u64     rdata_packets;                  /* Number of RDATA (repair) sequences */
        u64     odata_duplicates;               /* Duplicate ODATA */
        u64     rdata_duplicates;               /* Duplicate RDATA */
        u32     first_seqid;                    /* First buffered sequence id (first transmitter) */
        u32     last_seqid;                     /* Last buffered sequence id (first transmitter) */
        u32     first_naked_seqid;              /* First sequence id that was naked */
        u64     pending_naks;                   /* Outstanding naks */
        u64     pending_ncfs;                   /* Outstanding ncfs */
        u64     naks_sent;
        u64     parity_naks_sent;
        u32     active_transmitters;            /* Number of transmitters */
};
.fi
.SS Ioctls
These ioctls can be accessed using
.BR ioctl (2).
The correct syntax is:
.PP
.RS
.nf
.BI int " value";
.IB error " = ioctl(" pgm_socket ", " ioctl_type ", &" value ");"
.fi
.RE
.TP
.BR FIONREAD " (" SIOCINQ )
Gets a pointer to an integer as argument.
Returns the size of the next pending datagram in the integer in bytes,
or 0 when no datagram is pending.
.TP
.BR TIOCOUTQ " (" SIOCOUTQ )
Returns the number of data bytes in the local send queue.
.PP
In addition all ioctls documented in
.BR ip (7)
and
.BR socket (7)
are supported.
.SH ERRORS
All errors documented for
.BR socket (7)
or
.BR ip (7)
may be returned by a send or receive on a PGM socket.
.TP
.B ECONNREFUSED
The socket was not associated with a multicast address. For a receiver
this may mean that no PGM traffic was detected on the given port. The
address specified may not be a valid multicast address.
.TP
.B NOTCONN
Socket is not connected.
.TP
.B EISCONN
Socket is already connected.
.TP
.B ECONNABORTED
Receiver was not able to keep up. Connection was
torn down.
.\" .SH CREDITS
.\" This man page was written by Christoph Lameter.
.SH "SEE ALSO"
.BR ip (7),
.BR raw (7),
.BR socket (7),
.BR udp (7)

RFC\ 3028 for the Pragmatic General Multicast protocol.
.br
RFC\ 1122 for the host requirements.
.br
RFC\ 1191 for a description of path MTU discovery.
.SH COLOPHON
This page is part of release 3.xx of the Linux
.I man-pages
project.
A description of the project,
and information about reporting bugs,
can be found at
http://www.kernel.org/doc/man-pages/.
