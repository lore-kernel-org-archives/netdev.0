From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 03 Jan 2011 10:54:29 +0100
Message-ID: <1294048469.20187.13.camel@wall-e>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
	 <1294008917.18963.3.camel@wall-e>
	 <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
	 <1294045732.19666.6.camel@wall-e>
	 <1294046867.2892.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <jj@chaosbits.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294046867.2892.101.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 03.01.2011, 10:27 +0100 schrieb Eric Dumazet:
> Le lundi 03 janvier 2011 =E0 10:08 +0100, Stefani Seibold a =E9crit :
>=20
> > This will not work for two reasons:
> >=20
> > - First there is no way to detect a dead connection. A connection c=
an
> > stay for a very long time without data transfer.
> >=20
> > - Second it will not save against a attack where all communication =
slots
> > will be eaten by an attacker and then new valid connections will be=
 not
> > handled.
> >=20
> > The only thing what is possible to make an ioctl call which allows =
the
> > user land client to cancel connections.=20
> >=20
> > But this will be in my opinion dead code, because white lists of tr=
usted
> > address must be fostered and this will make the upgrading of a
> > infrastructure to complicate.
> >=20
> >=20
>=20
> Yep, and as UDP messages can easily spoofed, this means you need more
> than a list of trusted addresses. You also need to encapsulate the th=
ing
> in an secured layer.
>=20
> Stefani, your implementation has very litle chance being added in
> standard kernel, because it is not correctly layered, or documented.
>=20
> Copying hundred (thousand ?) of lines from existing code only shows
> there is a design error in your proposal. It means every time we have=
 to
> make a change in this code, we'll have to do it twice.
>=20

I copied about 400 of 3000 lines with was heavy modified to need my
needs. And i use only document features of the linux IP stack. So it is
normal to have duplicate code for the basics.

How can you do a routing, how can you determinate the MTU of the route.
This are basics. Look into other code how this things will be handled i=
s
in my opinion the right way, since there a no function provide to do
this.

Otherwise you can say the same about all the filesystem or PCI
drvivers , which do also a lot in the same way. But since this is the
way to do it, it is the right way.

> SUNRPC uses UDP/TCP sockets, and use callbacks to existing UDP/TCP co=
de,
> maybe you should take a look to implement an UDPCP stack in kernel.
>=20

I have looked around the whole LINUX source code, also in the SUNRPC
sockets and i did not found anything which meet my needs.

> For instance, a pure socket API seems not the correct choice for UDPC=
P,
> since a transmit should give a report to user, of frame being
> delivered/aknowledged or not to/by the remote side ?
>=20

This will be done through the error queue. The user client will receive
the unhandled packets back.

> With send(), this means you have only one message in transit, no
> asynchronous handling.
>=20

No, the messages will be queued. You can have more than a messages in
the send queue.

> At least you forgot to document the API, and restrictions.
>=20

API documentation is still there, i can these provide under
Documentation/udpcp.txt if you like.

Here is the API documentation:

Socket interface programming manual

The socket interface is a derivate of the UDP sockets. All setsockopt()=
,
getsockopt() and ioctl() kernel system calls  which are valid for UDP
sockets should work on UDPCP sockets. There are some extensions to the
sockopt and ioctl interface for the UDPCP sockets.

Include the C header file <net/udpcp.h> to use the UDPCP socket options
and ioctl calls.

A UDPCP can be opened with socket(PF_INET, SOCK_DGRAM, PF_UDPCP). All
operation which are valid for UDP sockets can also performed with UDPCP
sockets.

sockopt

The setsockopt and getsockopt are defined as following:

int getsockopt(int sockfd, int level, int optname, void *optval,
socklen_t *optlen);

int setsockopt(int sockfd, int level, int optname, const void *optval,
socklen_t optlen);

The level parameter for the UDPCP socket is SOL_UDPCP, where the
following options are defined:

UDPCP_OPT_TRANSFER_MODE - set default transfer mode. The optval is one
of the following:

UDPCP_NOACK - no ACK for the transmitted message is requiered

UDPCP_ACK - a ACK for each transmitted message fragment is requiered

UDPCP_SINGLE_ACK - only a ACK for the last transmitted message fragment
is requiered

UDPCP_OPT_CHECKSUM_MODE - set the default checksum mode. The optval is
one of the following:

UDPCP_NOCHECKSUM - no checksum for the transmitted message is required

UDPCP_CHECKSUM - a checksum test for the transmitted message is require=
d

UDPCP_OPT_TX_TIMEOUT - the timeout for a awaited ACK in milliseconds.

The optval should between >=3D 1 and max. UDPCP_MAX_WAIT_SEC * 1000

UDPCP_OPT_RX_TIMEOUT - timeout for a outstanding incoming message
fragment in milliseconds.

The optval should between >=3D 1 and max. UDPCP_MAX_WAIT_SEC * 1000

UDPCP_OPT_MAXTRY - the number of tries to send a message fragment.

The optval should between >=3D 1 and <=3D 10

UDPCP_OPT_OUTSTANDING_ACKS: the number of outstanding acks.

The optval should between >=3D1 and <=3D 255

All optlen parameters are int's. There the optlen should be
sizeof(optlen).

The values UDPCP_NOACK, UDPCP_ACK, UDPCP_SINGLE_ACK, UDPCP_NOCHECKSUM
and

UDPCP_CHECKSUM can also passed as control message with sendmsg(). For
details look at the manual page for sendmsg().

ioctl interface

The ioctl function call is defined as

int ioctl(int d, int request, ...)

=46or UDPCP sockets there are the following request commands defined:

UDPCP_IOCTL_GET_STATISTICS

This command returns the statistics of the socket in a struct
udpcp_statistics. The address of this struct must be passed as third
argument.

UDPCP_IOCTL_RESET_STATISTICS

This command resets the statistics of the socket

UDPCP_IOCTL_SYNC=20

This command waits until all message fragments are transmitted. If the
third argument is not zero, this is the max. timeout value in
milliseconds, otherwise this call can block indefinitely.
