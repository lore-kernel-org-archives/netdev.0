From: san@google.com (San Mehat)
Subject: (unknown)
Date: Thu, 18 Aug 2011 15:07:32 -0700 (PDT)
Message-ID: <20110818220732.459185C80B@san.sea.corp.google.com>
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: davem@davemloft.net, mst@redhat.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:44477 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab1HRWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 18:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TL;DR
-----
In this RFC we propose the introduction of the concept of hardware socket
offload to the Linux kernel. Patches will accompany this RFC in a few days,
but we felt we had enough on the design to solicit constructive discussion
from the community at-large.

BACKGROUND
----------
Many applications within enterprise organizations suitable for virtualization
neither require nor desire a connection to the full internal Ethernet+IP
network.  Rather, some specific socket connections -- for processing HTTP
requests, making database queries, or interacting with storage -- are needed,
and IP networking in the application may typically be discouraged for
applications that do not sit on the edge of the network. Furthermore, removing
the application's need to understand where its inputs come from / go to within
the networking fabric can make save/restore/migration of a virtualized
application substantially easier - especially in large clusters and on fabrics
which can't handle IP re-assignment.

REQUIREMENTS
------------
 * Allow VM connectivity to internal resources without requiring additional
   network resources (IPs, VLANs, etc).
 * Easy authentication of network streams from a trusted domain (vmm).
 * Protect host-kernel & network-fabric from direct exposure to untrusted
   packet data-structures.
 * Support for multiple distributions of Linux.
 * Minimal third-party software maintenance burden.
 * To be able to co-exist with the existing network stack and ethernet virtual
   devices in the event that an applications specific requirements cannot be
   met by this design.

DESIGN
------
The Berkeley sockets coprocessor is a virtual PCI device which has the ability
to offload socket activity from an unmodified application at the BSD sockets
layer (Layer 4).  Offloaded socket requests bypass the local operating systems
networking stack entirely via the card and are relayed into the VMM
(Virtual Machine Manager) for processing. The VMM then passes the request to a
socket backend for handling. The difference between a socket backend and a
traditional VM ethernet backend is that the socket backend receives layer 4
socket (STREAM/DGRAM) requests instead of a multiplexed stream of layer 2
packets (ethernet) that must be interpreted by the host. This technique also
improves security isolation as the guest is no longer constructing packets which
are evaluated by the host or underlying network fabric; packet construction
happens in the host.

Lastly, pushing socket processing back into the host allows for host-side
control of the network protocols used, which limits the potential congestion
problems that can arise when various guests are using their own congestion
control algorithms.

================================================================================

           +-----------------------------------------------------------------+
           |                                                                 |
  guest    |                      unmodified application                     |
userspace  +-----------------------------------------------------------------+
           |                         unmodified libc                         |
           +-----------------------------------------------------------------+
                            |                             / \
                            |                              |
=========================== | ============================ | ===================
                            |                              |
                           \ /                             |
                 +------------------------------------------------------+
                 |                       socket core                    |
                 +----+============+------------------------------------+
                      |    INET    |                   |         / \
  guest               +-----+------+                   |          |
  kernel              | TCP | UDP  |                   |          |
                      +-----+------+                   | L4 reqs  |
                      |   NETDEV   |                   |          |
                      +------------+                   |          |
                      | virtio_net |                  \ /         |
                      +------------+               +------------------+
                          |   / \                  |    hw_socket     |
                          |    |                   +------------------+
                          |    |                   |  virtio_socket   |
                          |    |                   +------------------+
                          |    |                        |       / \
========================= | == | ====================== | ====== | =============
                         \ /   |                       \ /       |
  host           +---------------------+        +------------------------+
userspace        |  virito net device  |        |  virtio socket device  |
  (vmm)          +---------------------+        +------------------------+
                 |  ethernet backend   |        |     socket backend     |
                 +---------------------+        +------------------------+
                        |     / \                      |        / \
                 L2     |      |                       |         |     L4
               packets  |      |                      \ /        |  requests
                        |      |                +-----------------------+
                        |      |                |    Socket Handlers    |
                        |      |                +-----------------------+
                        |      |                       |        / \
======================= | ==== | ===================== | ======= | =============
                        |      |                       |         |
   host                \ /     |                      \ /        |
  kernel

================================================================================

One of the most appealing aspects of this design (to application developers) is
that this approach can be completely transparent to the application, provided
we're able to intercept the application's socket requests in such a way that we
do not impact performance in a negative fashion, yet retain the API semantics
the application expects. In the event that this design is not suitable for an
application, the virtual machine may be also fitted with a normal virtual
ethernet device in addition to the co-processor (as shown in the diagram above).

Since we wish to allow these paravirtualized sockets to coexist peacefully with
the existing Linux socket system, we've chosen to introduce the idea that a
socket can at some point transition from being managed by the O/S socket system
to a more enlightened 'hardware assisted' socket. The transition is managed by
a 'socket coprocessor' component which intercepts and gets first right of
refusal on handling certain global socket calls (connect, sendto, bind, etc...).
In this initial design, the policy on whether to transition a socket or not is
made by the virtual hardware, although we understand that further measurement
into operation latency is warranted.

In the event the determination is made to transition a socket to hw-assisted
mode, the socket is marked as being assisted by hardware, and all socket
operations are offloaded to hardware.

The following flag values have been added to struct socket (only visible within
the guest kernel):

 * SOCK_HWASSIST
    Indicates socket operations are handled by hardware

In order to support a variety of socket address families, addresses are
converted from their native socket family to an opaque string. Our initial
design formats these strings as URIs. The currently supported conversions are:

+-----------------------------------------------------------------------------+
|   Domain   |      Type     |	URI example conversion                        |
|  AF_INET   |	SOCK_STREAM  |	tcp://x.x.x.x:yyyy                            |
|  AF_INET   |	SOCK_DGRAM   |	udp://x.x.x.x:yyyy                            |
|  AF_INET6  |	SOCK_STREAM  |	tcp6://aaaa:b:cccc:d:eeee:ffff:gggg:hhhh/ii   |
|  AF_INET6  |	SOCK_DGRAM   |	udp6://aaaa:b:cccc:d:eeee:ffff:gggg:hhhh/ii   |
|  AF_IPX    |	SOCK_DGRAM   |	ipx://xxxxxxxx.yyyyyyyyyy.zzzz                |
+-----------------------------------------------------------------------------+

In order for the socket coprocessor to take control of a socket, hooks must be
added to the socket core. Our initial implementation hooks a number of functions
in the socket-core (too many), and after consideration we feel we can reduce it
down considerably by managing the socket 'ops' pointers.

ALTERNATIVE STRATEGIES
----------------------

An alternative strategy for providing similar functionality involves either
modifying glibc or using LD_PRELOAD tricks to intercept socket calls. We were
forced to rule this out due to the complexity (and fragility) involved with
attempting to maintain a general solution compatible accross various
distributions where platform-libraries differ.

CAVEATS
-------

 * We're currently hooked into too many socket calls. We should be able to
   reduce the number of hooks to 3 (__sock_create(), sys_connect(), sys_bind()).

 * Our 'hw_socket' component should be folded into a netdev so we can leverage
   NAPI.

 * We don't handle SOCK_SEQPACKET, SOCK_RAW, SOCK_RDM, or SOCK_PACKET sockets.

 * We don't currently have support for /proc/net. Our current plan is to
   add '/proc/net/hwsock' (filename TBD) and add support for these sockets
   to the net-tools packages (netstat & friends), rather than muck around with
   plumbing hardware-assisted socket info into '/proc/net/tcp' and
   '/proc/net/udp'.

 * We don't currently have SOCK_DGRAM support implemented (work in progress)

 * We have insufficient integration testing in place (work in progress)
