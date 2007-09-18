From: Samo Pogacnik <samo_pogacnik@t-2.net>
Subject: network functionality - SACIP
Date: Wed, 19 Sep 2007 00:06:49 +0200
Message-ID: <1190153209.2366.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from md2.t-2.net ([84.255.209.81]:4631 "EHLO md2.t-2.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbXIRWBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 18:01:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I want to introduce a new network functionality, where established 
network connections could be preserved after the IP address change
of one or both endpoints of communication.

A general document (not yet finished) about SACIP (Session Aware Change
of IP) and the patch are available at:

http://84.255.254.67/sacip-0.1-en.pdf
http://84.255.254.67/patch-linux-2.6.19-sacip

Short implementation description:
---------------------------------
To be able to preserve established network connections based on inet
sockets without the need to modify applications, three things had to
be done:
1. Extension of inet socket structure by additional pairs for rcv_saddr
   and daddr fields and two indexes referring to currently active values
   of both additional pairs.
2. Modifications of the role of original rcv_saddr and daddr parameters
   to stay bound to the upper socket layer only. Their use in the IP
   layer is being replaced by currently active values from newly added
   pairs. On IP address change only IP layer bound parameters get
   changed.
3. Notification about changed IP has been implemented using a separate
   ICMP message, sent for every established socket related to the
   changed IP address. 

Current functionality is the most basic one, so that the implementation 
would be as simple as possible. So, it covers only ipv4, it does not 
address network address translation in the communication path (see 
doc.), it does not address security aspects. Implementation also does 
not allow loosing old address before notifying about IP change at one 
endpoint and does not enable the use of another network interface by 
setting new IP address.

What can it do then? Well, No additional configuration tool has been 
implemented for this, so features of the ip tool (from iproute2 package)
had been used. First by adding a new address to existing interface and
then by deletion of the first primary address, sacip functionality gets
called. And if new address has been added as a secondary address, then 
the promote secondaries kernel feature has to be enabled as well to 
activate sacip functionality by deletion of the primary address.

After the deletion of the first primary address, all tcp established 
sockets as well as all udp and raw sockets are checked, if their
current active source address correspond to old/deleted ip address.
For each socket found an ICMP message containing only new primary
address is sent to the currently active destination address of a socket.
After that new source addres get assigned as currently active on a
local endpoint. 

On receipt of a sacip ICMP message, remote side also checks its
sockets, if their current active destination address equals to the
source address of the ip packet header carrying the sacip icmp message.
Found sockets get assigned new ip address (received in the icmp message)
as current active destination address, afterwards.

After that communication continues using newly assigned ip address, but
the application (telnet for instance) operates as if old address would
still be assigned.

Testing environment:
--------------------
Currently, there are two test set-ups possible. First set-up needs
at least two nodes, and the second possibility is to use special 
loopback network device "snull" (from Linux Device Drivers book) on a 
single node, but in that case additional sacip kernel configuration 
option has to be enabled.
I was able to test both set-ups, but with a very limited set of 
applications. So mostly telnet was used (interactively or by echoing 
some output in a tight loop on remote side, just to generate one way 
stream). Udp NFS on the other hand also did not show any problems, 
except that access rights for new address of a client had to be 
administrated as well.

Security:
---------
I am aware that malicious sacip icmp messages easily break established
connections in current implementation. That is why no original IP 
address is being sent within the sacip icmp message payload (so it is 
a little harder to generate a fake sacip icmp). But that also limits 
functionality, when we'd like to change IP address, after the old 
network looses access.
If some secrets could be exchanged after connection establishment in 
some standard way to identify established sessions on both ends, most 
security concerns could be solved, imho (suggestions are most welcome). 

Possible future:
----------------
1. All missing features (look above).
2. If security would be covered well, research in the direction of
   possible connection transfer to another node would be interesting
   (especially for tcp).

About the patch:
----------------
The appended patch is for kernel 2.6.19 and all changes are directly
in lined under conditional config macros, so that not a single line of
original code would be changed, if sacip stays not configured. 

Any suggestions to separate added code are welcome as well as any other
comments or criticism, regarding the patch and functionality.

regards, Samo




