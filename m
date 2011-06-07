From: David Stevens <dlstevens@us.ibm.com>
Subject: RE: Multicast IP packet routed between 2 ports nic on the same host
Date: Tue, 7 Jun 2011 10:03:55 -0700
Message-ID: <OFE40D019D.97AF66B9-ON882578A8.005A892D-882578A8.005DBD4E@us.ibm.com>
References: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>,<OF6C0FF28D.EF048A18-ON882578A7.0069A85E-882578A7.0069FF2A@us.ibm.com> <24665DDC0D7CF047BD6471A56E615EA628ABF94D@CA-OPS-MAILBOX.miranda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: BONNEAU Guy <gbonneau@miranda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44816 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755613Ab1FGRFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 13:05:47 -0400
In-Reply-To: <24665DDC0D7CF047BD6471A56E615EA628ABF94D@CA-OPS-MAILBOX.miranda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 06/07/2011 06:57:32 AM:

> From: BONNEAU Guy <gbonneau@miranda.com>
 
> Its works! Thanks a lot David! Googling for SO_BINDTODEVICE helped 
> me to get insight into my issue. This link was really useful : 
> http://codingrelic.geekhold.com/2009/10/code-snippet-sobindtodevice.html
> . However I'm still somewhat confused because I always assumed that 
> this was one of the purpose of IP_ADD_MEMBERSHIP beside joining a 
> multicast group. To constrain the multicast socket to a specific 
> "device" interface. In which case I wonder if the interface member 
> of structure ip_mreq is still relevant? Can you comment!

Guy,
        There are 2 steps in multicast delivery:

1) group membership, which is controlled by IP_ADD_MEMBERSHIP (et alia).
        This is per-interface and determines whether multicast packets
        on that interface will be delivered to the machine. If you don't
        join a group _on_that_interface_, the interface itself will drop
        the packets. This is what the interface specification in ip_mreq
        and ip_mreqn is for; if you want that group on all interfaces,
        you have to do the join on all interfaces, one at a time. If you
        don't specify an interface, it'll pick one, which isn't 
necessarily
        the one you want.
2) socket binding.
        This determines whether a particular socket receives a multicast
        packet or not. Clearly, all multicast packets that are not 
delivered
        to the machine will not be delivered to any socket, so _somebody_ 
has
        to have done a group join for sockets bound to multicast addresses
        to receive packets. However, the socket binding is entirely 
independent
        of the group membership. A binding matching the group and port 
(which
        also includes INADDR_ANY bindings) will receive matching packets
        whether or not you did a join on that socket (or a join at all) as
        long as some process on the machine has done a join on an 
interface
        that allows delivery to the machine.

In your test program, you were using the same group and port for both
instances so they will both receive the same set of packets. If any join
on any interface would allow delivery of matching packets to the machine,
they would both receive them, even if neither of your programs did the
IP_ADD_MEMBERSHIP. And if no process had done an join on an interface
with matching multicast traffic, neither of the programs would receive
anything.

                                                                +-DLS

