From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: controlling ARP Proxy scope?
Date: Wed, 06 Jul 2005 22:46:33 -0400
Message-ID: <3u3gb7$1o5sb5__41036.4502379254$1120705207$gmane$org@smtp05.mrf.mail.rcn.net>
References: <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net> <Pine.LNX.4.61.0507061718500.6628@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0507061718500.6628@filer.marasystems.com>
References: <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1no73u@smtp05.mrf.mail.rcn.net>
 <3u3gb7$1npg80@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 05:32 PM 7/6/05 +0200, Henrik Nordstrom wrote:
>On Wed, 6 Jul 2005, Zdenek Radouch wrote:
>
>> Well, how do I tell it that I want to proxy for all machines on the
>> 192.168.13.128/29 net attached to eth0.5, but not for any of
>> the machines on 192.168.2.0/24 attached to eth0.6 ?
>
>For whom going where?

The setup is actually quite complex.  I have a linear array of machines
communicating over a proprietary (L1 and L2) protocol.  The machines are
connected point-to-point, and they use a proprietary VLAN protocol below IP
in order to be able to control bandwidth (QoS).  One of these VLANs
(vsc1) is meant to provide external access. For purposes of redundant
access, each node has two external addresses Ai and Bi on vsc1, set up
as aliases vsc1:0 and vsc1:1.  The two addresses are meant to allow
access from the left end of the array (Ai) and from the right end of the
array (Bi),
so even in case of a line failure one could access all of the nodes.
Only the two edge nodes (left-most and right-most) are connected to
the [outside] customer network - they are connected via Ethernet
(specifically 802.1q vlans) interfaces eth0.1 or eth0.2.
Additionally, each node has multiple CPUs communicating on a private network
(Ethernet/802.1q) via interface eth0.5 or eth0.6.

You can ignore the point-to-point nature of the array interconnect - I have
designed an L2 layer that hides this, making it appear as a bus-style network
except there is no ARP (it is not needed).

So in the left-most node for example, I have the following interfaces:

eth0.1		A1/32			// connection from the customer LAN to the array (left access)

eth0.5		Private1/29		// private intra-node interconnect
vsc0		Private2/28		// private array interconnect
vsc1:0	A1/28			// public access to the array (from the left)
vsc1:1	B1/28			// public access to the array (from the right)

The routing table has, in addition to the obvious, a default route via eth0.1
to an address Ax (router attached to the left-most node).
[It is really supposed to have two rule-based routes to be able to return
the packet in the direction it came, but for some reason the ip rule command
does not work, and I have not had a chance to debug that yet].
The purpose of the proxy ARP is to proxy for the ARP-less nodes (on vsc1)
hidden behind this node, when they are accessed from the left, i.e., using
the Ai addresses, via eth0.1 which is the only public interface here.

So I turned on the proxy ARP on eth0.1.

My question was, if the proxy ARP is based on the routing table, then
how do I do I tell it that I want to proxy only for the Ai addresses, and not
for the Bi or any of the private addresses?

And the problem I was observing is that this node proxies for the Ax
address, when the requests for it are seen on eth0.1.  These are legitimate
requests of nodes out there trying to talk to the router, not
to my array.

>
>I only experienced problems when there was other IP networks on the same 
>Ethernet but not known to the box. In this case I had to enable the 
>arp_ignore sysctl to stop answering "other" ARP queries for networks not 
>defined on the same Ethernet interface.

This may actually be my problem.  The Ax address the proxy ARP wrongly
answers is not part of the eth0.1 subnet.

Regards
-Zdenek
