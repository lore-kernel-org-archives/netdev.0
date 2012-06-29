From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: AF_BUS socket address family
Date: Fri, 29 Jun 2012 17:45:39 +0100
Message-ID: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This series adds the bus address family (AF_BUS) it is against
net-next as of yesterday.
 
AF_BUS is a message oriented inter process communication system. 

The principle features are:

 - Reliable datagram based communication (all sockets are of type
   SOCK_SEQPACKET)

 - Multicast message delivery (one to many, unicast as a subset)

 - Strict ordering (messages are delivered to every client in the same order)

 - Ability to pass file descriptors

 - Ability to pass credentials

The basic concept is to provide a virtual bus on which multiple
processes can communicate and policy is imposed by a "bus master".

Introduction
------------

AF_BUS is based upon AF_UNIX but extended for multicast operation and
removes stream operation, responding to extensive feedback on previous
approaches we have made the implementation as isolated as
possible. There are opportunities in the future to integrate the
socket garbage collector with that of the unix socket implementation.

The impetus for creating this IPC mechanism is to replace the
underlying transport for D-Bus. The D-Bus system currently emulates this
IPC mechanism using AF_UNIX sockets in userspace and has numerous
undesirable behaviours. D-Bus is now widely deployed in many areas and
has become a de-facto IPC standard. Using this IPC mechanism as a
transport gives a significant (100% or more) improvement to throughput
with comparable improvement to latency.

This work was undertaken by Collabora for the GENIVI Alliance and we
are committed to responding to feedback promptly and intend to continue
to support this feature into the future.

Operation
---------

A bus is created by processes connecting on an AF_BUS socket. The
"bus master" binds itself instead of connecting to the NULL address.

The socket address is made up of a path component and a numeric
component. The path component is either a pathname or an abstract
socket similar to a unix socket. The numeric component is used to
uniquely identify each connection to the bus. Thus the path identifies
a specific bus and the numeric component the attachment to that bus.

The numeric component of the address is divided into two fixed parts a
prefix to identify multicast groups and a suffix which identifies the
attachment. The kernel allocates a single address in prefix 0 to each
socket upon connection.

Connections are initially limited to communicating with address the
bus master (address 0) . The bus master is responsible for making all
policy decisions around manipulating other attachments including
building multicast groups. 

It is expected that connecting clients use protocol specific messages
to communicate with the bus master to negotiate differing
configurations although a bus master might implement a fixed
behaviour.

AF_BUS itself is protocol agnostic and implements the configured
policy between attachments which allows for a bus master to leave a
bus and communication between clients to continue.

Some test code has been written [1] which demonstrates the usage of
AF_BUS.

Use with BUS_PROTO_DBUS
-----------------------

The initial aim of AF_BUS is to provide a IPC mechanism suitable for
use to provide the underlying transport for D-Bus. 

A socket created using BUS_PROTO_DBUS indicates that the messages
passed will be in the D-Bus format. The userspace libraries have been
updated to use this transport with an updated D-Bus daemon [2] as a bus
master.

The D-Bus protocol allows for multicast groups to be filtered depending
on message contents. These filters are configured by the bus master
but need to be enforced on message delivery. 

We have simply used the standard kernel netfilter mechanism to achieve
this. This is used to filter delivery to clients that may be part of a
multicast group where they are not receiving all messages according to
policy. If a client wishes to further filter its input provision has
been made to allow them to use BPF.

The kernel based IPC has several benefits for D-Bus over the userspace
emulation:

 - Context switching between userspace processes is reduced.
 - Message data copying is reduced.
 - System call overheads are reduced.
 - The userspace D-Bus daemon was subject to resource starvation,
   client contention and priority inversion.
 - Latency is reduced
 - Throughput is increased.

The tools for testing these assertions are available [3] and
consistently show a doubling in throughput and better than halving of
latency.

[1] http://cgit.collabora.com/git/user/javier/check-unix-multicast.git/log/?h=af-bus
[2] http://cgit.collabora.com/git/user/rodrigo/dbus.git/

[3] git://github.com/kanchev/dbus-ping.git
    https://github.com/kanchev/dbus-ping/blob/master/dbus-genivi-benchmarking.sh
