From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: Scaling Max IP address limitation
Date: Sun, 24 Jun 2007 15:08:37 -0400
Message-ID: <D6003DDE-0C36-437B-B70A-D422DFE153D0@mac.com>
References: <467EA7C1.4080006@rossove.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: djones@rossove.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756825AbXFXTIz@vger.kernel.org>
In-Reply-To: <467EA7C1.4080006@rossove.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jun 24, 2007, at 13:20:01, David Jones wrote:
> Hi, I am trying to add multiple IP addresses ( v6 ) to my FC7 box  
> on eth0. But I am hitting a max limit of 4000 IP address . Seems  
> like there is a limiting variable in linux kernel (which one? )  
> that prevents from adding more IP addresses than 4096. What do I  
> need to change in Linux kernel  ( and then recompile ) to be able  
> to add more IP addresses than 4K addresses per system? ..

Do you really need that many IP addresses?  When somebody finally  
gets around to implementing REDIRECT support for ip6tables then you  
could just redirect them all to the same port on the local system.   
Then with a happy little getsockopt() you can find out the original  
IP address for use in whatever application you are running.  That's  
likely to be a thousand times more efficient than binary searching  
through 5000+ mostly-sequential IP addresses per received packet.

<Unrelated wishful thinking>
I keep having hopeful dreams that one day netfilter will grow support  
for cross-protocol NAT (IE: NAT a TCPv4 connection over TCPv6 to the  
IPv6-only local web server, or vice versa).  It would seem that would  
require a merged "xtables" program.

Having routing table operations, IPsec transformations, etc just be  
another step in the firewall rules would also be useful.  It would be  
handy to be able to "-j ROUTE", then "-j IPSEC", then "-j ROUTE"  
again, to re-route the now-encapsulated IPsec packets to their proper  
destination.  That would also eliminate the sort-of-hacky problems  
with destination network interface in the bridging code: "-j BRIDGE"  
might be another step in the process, and conceivably you could have  
independent bridge MAC tables too.  You'd probably also want "-j  
BRIDGE_TEST" and "-j ROUTE_TEST" to compute the output network  
interface without actually modifying the addresses.

That would also appear to get rid of the need for all tables other  
than "filter" and all predefined chains other than "INPUT" and  
"OUTPUT".  Default rules would be these:
nettables -A INPUT -j CONNTRACK
nettables -A INPUT -j LOCALMATCH
nettables -A INPUT --for-this-host -j ACCEPT
nettables -A INPUT -j OUTPUT
nettables -A OUTPUT -j ROUTE
nettables -A OUTPUT -j TRANSMIT

Forwarded packets would be sent right into the OUTPUT chain from the  
INPUT chain by appropriate rules.  Instead of turning off  
ip_forwarding in /proc/sys, you could just change the "-j OUTPUT" in  
the INPUT chain to "-j ACCEPT", and it would be impossible to forward  
packets.  I can't see any functionality that we have today which a  
mechanism like this wouldn't support, aside from the fact that it  
hands the admin a loaded nuclear missile aimed at their foot  
(Flushing the INPUT chain would basically be analogous to committing  
network suicide, although there exist other ways to do that with  
netfilter today.
</Unrelated wishful thinking>

Cheers,
Kyle Moffett
