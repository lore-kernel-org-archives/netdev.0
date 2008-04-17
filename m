From: James Chapman <jchapman@katalix.com>
Subject: RFC: Adding L2TPv3 support
Date: Thu, 17 Apr 2008 18:02:51 +0100
Message-ID: <480782BB.8000305@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:52620 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757830AbYDQRvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 13:51:55 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=[192.168.1.10])
	by s36.avahost.net with esmtpa (Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1JmVsx-0001uP-1N
	for netdev@vger.kernel.org; Thu, 17 Apr 2008 10:18:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm considering adding L2TPv3 support into the kernel. If anyone has 
comments on the proposal below or is already working on L2TPv3, please 
let me know.

First, some background.

The existing pppol2tp driver implements L2TPv2 (rfc2661). L2TPv2 is a 
protocol for tunneling PPP packets over UDP. The kernel driver 
implements only the datapath; the L2TP control protocol is implemented 
in userspace.

L2TPv3 (rfc3931) changes the protocol to allow different frame types to 
be passed over an L2TP tunnel by moving the PPP-specific parts of the 
protocol out of the core L2TP packet headers. Each frame type is known 
as a pseudowire type. Ethernet, HDLC, Frame Relay and ATM pseudowires 
for L2TP are defined in separate RFC standards. A PPP over L2TPv3 RFC 
(providing similar functionality to L2TPv2) is currently in draft 
status. Another change for L2TPv3 is that it can be carried directly 
over IP with no UDP header (UDP is optional). It is also possible to 
create static unmanaged L2TPv3 tunnels manually without a control 
protocol (userspace daemon) to manage them.

I propose to implement L2TPv3 as follows.

1. Split the existing pppol2tp driver to separate the L2TP protocol 
implementation from PPP. This would provide core L2TP support on which 
L2TP pseudowire drivers can be built. The updated pppol2tp part of the 
driver will contain only the PPP code and will call in to the new L2TP 
core. No new functionality will be added. Existing L2TPv2 userspace 
applications would need no changes: L2TPv2 support would be provided by 
two kernel modules instead of one.

2. Add L2TPv3 protocol support. Some fields of the L2TP protocol header 
are changed which needs to be handled in the kernel datapath. Both 
L2TPv2 and L2TPv3 will be supported, with care taken to allow for 
L2TPv2/L2TPv3 migration as documented in rfc3931. Note that this won't 
provide PPP over L2TPv3 support without more work because changes are 
needed in the PPP sockaddr structure. See later.

3. Implement a new driver for L2TP ethernet pseudowires. Each tunnel 
(actually a session in L2TP terminology) will present an ethernet 
net_device which can be managed using standard tools. If only IP frames 
are passed over the tunnel, the interface can be given IP addresses of 
itself and its peer. If non-IP frames are to be passed over the tunnel, 
the interface can be added to a bridge. All L2TP datapath protocol 
functions are handled by the L2TP core driver developed previously. 
Netlink will be used to manage the tunnels. A patch to iproute2-utils 
will add new commands to support static, unmanaged ethernet tunnels.

4. Add ethernet VLAN support. L2TPv3 defines a separate pseudowire type 
for VLANs. Add netlink attributes and iproute2 command parameters as 
necessary.

5. Add PPPoL2TPv3 support when the RFC becomes a standard.

6. Add network namespace support.

7. Add ATM pseudowire support if there is demand for it. I'm hopeful I 
can borrow a pair of ATM NICs to do this. Requirements are unclear at 
this time - there are several pseudowire types defined for ATM for 
various ATM encapsulation modes.

The existing L2TPv2 driver uses AF_PPPOX sockets. All parameters of the 
tunnel/session are passed using AF_PPPOX sockets via connect() and 
setsockopt() calls. The sockaddr structure identifies the tunnel_id, 
session_id and UDP socket (created by a userspace L2TP daemon) for the 
driver to use. L2TPv3 changes the tunnel_id and session_id parameters 
from 16-bit to 32-bit values and adds some more config options. This 
would take the size of a new sockaddr structure beyond that available in 
AF_PPPOX sockets. I propose to reuse the pppol2tp sockaddr structure for 
L2TPv3 PPP pseudowire support, retaining backwards compatibility with 
L2TPv2, but for L2TPv3 use it only to pass tunnel_id, session_id and 
socket file descriptor to the kernel. Additional L2TPv3 parameters will 
be configured using the netlink interface that was implemented in step 2 
above. Thus a userspace daemon that implements PPP over L2TPv2 and 
L2TPv3 would need to use the netlink interface and AF_PPPOX sockets.

For the netlink interface implementation, I plan to use the 
NETLINK_GENERIC family.

My gut feel is that it is probably not worthwhile submitting any patches 
for this until steps 1-3 above are implemented because I won't be 
confident that the generic L2TP core driver API will be right until I 
have something real implemented against it (i.e. ethernet pseudowire). 
After that, features can be added and submitted incrementally.

Any comments?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

