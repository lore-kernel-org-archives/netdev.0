From: renzo@cs.unibo.it (Renzo Davoli)
Subject: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 10:24:01 +0100
Message-ID: <20071217092401.GC4356@cs.unibo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: garden@cs.unibo.it
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934446AbXLQJYW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inter Process Networking (PATCH):

This patch adds a new address family for inter process communication.
AF_IPN: inter process networking, i.e. multipoint,
multicast/broadcast communication among processes (and networks).

Contents of this document:

    1. What is IPN?
    2. Why IPN?
    2.1 Why IPN instead of IP Multicast?
    2.2 Why IPN instead of AF_NETLINK?
    3. How?

We've read all the comments in the previous thread about IPN and we've
tried to answer.

1. WHAT IS IPN?
---------------

IPN is a new address family designed for one-to-many, many-to-many and 
peer-to-peer communication among processes.
Berkeley sockets have been designed for client-server or point-to-point
communication; AF_UNIX does not support multicast/broadcast. AF_IPN
does, in a simple, efficient but extensible way.
IPN is an Inter Process Communication paradigm where all the processes
appear as they were connected by a networking bus.

On IPN, processes can interoperate using real networking protocols 
(e.g. ethernet) but also using application defined protocols (maybe 
just sending ascii strings, video or audio frames, etc).
IPN provides networking (in the broaden definition you can imagine) to
the processes. Processes can be ethernet nodes, run their own TCP-IP stacks
if they like (e.g. virtual machines), mount ATAonEthernet disks, etc.etc.

IPN networks can be interconnected with real networks or IPN networks
running on different computers can interoperate (can be connected by
virtual cables).

IPN is part of the Virtual Square Project (vde, lwipv6, view-os, 
umview/kmview, see wiki.virtualsquare.org).

2. WHY IPN?
-----------
Many applications can benefit from IPN.
First of all VDE (Virtual Distributed Ethernet): one service of IPN is a
kernel implementation of VDE.
IPN can be useful for applications where one or some processes feed their
data (*any kind* of data, not only networking-related messages) to several
consuming processes (maybe joining the stream at run time). IPN sockets
can be also connected to tap (tuntap) like interfaces or to real interfaces
(like "brctl addif").
There are specific ioctls to define a tap interface or grab an existing
one.

Several existing services could be implemented (and often could have extended
features) on the top of IPN:
 - kernel Ethernet bridging
 - TUN/TAP
 - MACVLAN

IPN could be used (IMHO) to provide multicast services to processes.
Audio frames or video frames could be multiplexed such that multiple
applications can use them. I think that something like Jack can be
implemented on the top of IPN. Something like a VideoJack can
provide video frames to several applications: e.g. the same image from a
camera can be viewed by xawtv, recorded and sent to a streaming service.
IPN sockets can be used wherever there is the idea of broadcasting channel 
i.e. where processes can "join (and leave) the information flow" at
runtime. IPN can be seen as "publish and subscribe".
Different delivery policies can be defined as IPN protocols (loaded 
as submodules of ipn.ko).
For instance, an ethernet switch is a policy (kvde_switch.ko: packets
are unicast delivered if the MAC address is already in the switching
hash table), we are designing an extendended switch, full of interesting
features like our userland vde_switch (with vlan/fst/manamement etc..),
and a layer3 switch, but other policies can be defined to implement the
specific requirements of other services. I feel that there is no limits
to creativity about multicast services for processes.  Userspace
services (like vde) do exist, but IPN provides a faster and unified
support.

2.1 Why IPN instead of IP Multicast?
------------------------------------
 - IPN seems to be faster than IP Multicast. (see my message to LKML
   of Dec 06).
 - IPN provides file system permission to access the communication medium,
   and it uses the file system for naming.
 - IPN does not need any tunneling or packet encapsulation, it works as a
   layer 1 virtual network.
 - IPN protocols (implemented by kernel submodules) provide forwarding
   policies: the set of receipients for each messages is computed from the
   contents of the message itself.
   Ethernet virtual switches or other routing rules for any kind of data
   can be implemented as IPN protocols.

2.2 Why IPN instead of AF_NETLINK?
----------------------------------
 - Netlink has been designed for user to kernel communication.
 - Netlink has many missing features to provide services similar to IPN.
 - Currently multicast seems to be allowed for root only. Access control
   should be added completely.
 - Netlink interface for user processes is not very immediate (libnl has
   been developed as a higher level solution to that).
 - Netlink already seems to suffer from "overpopulation":
   NETLINK_GENERIC has been added for "simplified netlink usage" but it
   adds yet another header and rules to be followed.
 - Netlinks is quite rigid as for message delivery guarantees: unicast
   implies lossless communication, multicast implies best-effort
   delivery.
 - Netlink does not support different forwarding policies.
We are trying to compare netlink performances with IPN.

3. HOW?
-------
The complete specifications for IPN can be found here:

http://wiki.virtualsquare.org/index.php/IPN

 - bind() creates the socket (if it does not already exist). When bind()
   succeeds, the process has the right to manage the "network".  No data
   is received or can be send if the socket is not connected (only
   get/setsockopt and ioctl work on bound unconnected sockets).

 - connect() is used to join the network. When the socket is connected
   it is possible to send/receive data. If the socket is already bound
   it is useless to specify the socket again (you can use NULL, or
   specify the same address).  connect() can be also used without
   bind(). In this case the process sends and receives data but it
   cannot manage the network (in this case the socket address
   specification is required).

 - listen() and accept() are for servers, thus they does not exist for IPN.

Examples:
1. Peer-to-Peer Communication:
Several processes run the same code:

  struct sockaddr_un sun = { .sun_family = AF_IPN, .sun_path = "/tmp/sockipn" };
  int s = socket(AF_IPN, SOCK_RAW, IPN_BROADCAST);
  err = bind(s, (struct sockaddr*) &sun, sizeof(sun));
  err = connect(s, NULL, 0);

In this case all the messages sent by each process get received by all
the other processes (IPN_BROADCAST).  The processes need to be able to
receive data when there are pending packets, e.g. by using poll/select
and event driven programming or multithreading.

2. (One or) Some senders/many receivers
The sender runs the following code:

  struct sockaddr_un sun = { .sun_family = AF_IPN, .sun_path = "/tmp/sockipn" };
  int s = socket(AF_IPN, SOCK_RAW, IPN_BROADCAST);
  err = shutdown(s, SHUT_RD);
  err = bind(s, (struct sockaddr*) &sun, sizeof(sun));
  err = connect(s, NULL, 0);

The receivers do not need to define the network, thus they skip the bind():

  struct sockaddr_un sun = { .sun_family = AF_IPN, .sun_path = "/tmp/sockipn" };
  int s = socket(AF_IPN, SOCK_RAW, IPN_BROADCAST);
  err = shutdown(s, SHUT_WR);
  err = connect(s, (struct sockaddr*) &sun, sizeof(sun));

In the previous examples processes can send and receive every kind of
data. 

When messages are ethernet packets (maybe from virtual machines), IPN
works like a Hub by using the IPN_BROADCAST protocol.  Different
protocols (delivery policies) can be specified by changing IPN_BROADCAST
with a different tag.  A IPN protocol specific submodule must have been
registered the protocol tag in advance. (e.g. when kvde_switch.ko is
loaded IPN_VDESWITCH can be used too).  The basic broadcasting protocol
IPN_BROADCAST is built-in (all the messages get delivered to all the
connected processes but the sender). 

IPN sockets use the filesystem for naming and access control. For example,

    srwxr-xr-x 1 renzo renzo 0 2007-12-04 22:28 /tmp/sockipn

An IPN socket appear in the file like a UNIX socket.  'r/w' permissions
represent the right to receive from/send data to the socket. The 'x'
permission represent the right to manage the socket.  connect()
automatically shuts down SHUT_WR or SHUT_RD if the user has not the
correspondent right.

The patch also supports the run time reconfiguration of the max # of
nodes and out of band messages for protocol log messages.

IPN provides OOB messages to notify number of senders and receivers
changes. For example it is possible to write sender programs that stop
to feed data when there are no receivers and restart as soon as a new
receiver join the network.

renzo,
Ludovico Gardenghi and the V^2 project group
