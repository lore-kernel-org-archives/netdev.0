From: "Bob O'Neil" <boneil@cinci.rr.com>
Subject: Linux Advice on Controlled Bridge based on MAC Address
	with Delay and Dropout
Date: Tue, 10 Feb 2009 07:51:51 -0500
Message-ID: <715C22C94C6F4903BB1603EFBE986101@ICARUS>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0033095720638696361=="
Cc: Bob.Oneil@L-3Com.com
To: <bridge@lists.linux-foundation.org>, <linux-net@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============0033095720638696361==
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_005D_01C98B54.6F338190"

This is a multi-part message in MIME format.

------=_NextPart_000_005D_01C98B54.6F338190
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

IN SHORT=20

How to I leverage what is available on the Linux Communcations Stack, =
either as part of the kernel itself  (i.e. ebtables, netbridge, tcc, =
iptables, etc.) and/or an addon module , that
allows me to implement a Linux Bridge, with the additional requirement =
of dropping out Ethernet frames (not bytes) based on a soft setting, and =
delaying frames (from 4 ms to 10 ms in 1 ms increments) in ONE direction =
only of the bridge?    This is for a i386 machine with 2 NICS that will =
need to be in promiscuous mode.


MORE DETAILS

I am trying to determine the best course of action for an =
application/script that I need to=20
compose for execution under Red Hat Linux AS 4.0, Linux Kernel v2.6.x.
=20
I have a 386 based Linux machine with two NICs that acts a bit like a =
bridge, dispatching frames=20
at the Data Link Layer (not IP, Layer 3).   On the ingress of NIC 1 =
(eth0), there will be certain=20
frames which have matching MACs that will be consumed (i.e. passed up =
the stack).   Other frames,=20
with a range of matching MAC addresses, broadcast and multicast need to =
be bridged to the other=20
NIC (call it NIC 2, or eth1).     Broadcast and Multicast also need to =
be consumed, so may have=20
two destinations, bridged between NICs and consumed from the internal =
stack.   I will need to assign
an IP address to the application so that it may act as an SNMP agent.
=20
The converse direction follows a similar pattern based on the MAC =
address, certain frames=20
matching a range of MAC address will be bridged to NIC 1 from NIC 2, =
ones which match the MAC=20
address of NIC 2 will be consumed, broadcast and multicast need to be =
both consumed and forwarded=20
to the egress of NIC 1.

The assignments of the IPs, subnets, and subnet masks is flexible.

Now here is the complication that deviates from standard Linux kernel =
behavior.   ONLY for frames forwarded/bridged from=20
NIC 1 to NIC2, there are two soft settings that dictate the forwarding =
behavior:
=20
1. Delay - this may range from say 4 ms to 15 ms.   Based on this =
setting, ingress frames on NIC 1=20
that will be forwarded on to NIC 2 need to be delayed in the process.   =
The delay timing needs to=20
be fairly precise, to the millisecond if possible, and possibly as low =
as 4 ms.
=20
2. Drop Out Percentage - ranges from 0 to 100%.   Based on this setting, =
ingress frames on NIC 1=20
will be dropped based on the percentage set.   The dropout could be a =
simple uniform dropout, so that if=20
the percentage is set to 25%, 1 in 4 frames will be dropped.

Ethernet frames forwarded in the opposite direction (eth1 to eth0) do =
not have to be delayed or dropped.

I am trying to come up with a design that is optimum, and that takes =
maximum advantage of what is=20
available in the Linux kernel (via =
NetFilter/IPTables/EBTables/TCC/bctrl, etc.) via commands.

To slow down outgoing traffic, the Tunnel Bucket Filter (TBF) seems like =
a possible command line=20
solution for the delay requirement.   However, of particular concern is =
the fact that it is byte based
rather than frame based, and it appears it may not guarantee a uniform =
pacing of frames to the
user specified delay value with fidelity.   In addition, from the =
document entitled "Linux Advanced Routing & Traffic Control HOWTO",
is the quote:

"However, due to the default 10ms timer resolution of Unix, with 10.000 =
bits average packets, we=20
are limited to 1mbit/s of peakrate!"
=20
This statement seems to suggest that the maximum precision for a delay =
would come at 10 ms=20
increments, and it is not clear if a low value, say 4 ms would be =
possible.
=20
For the dropout requirement, perhaps some form of Random Early Drops, =
although the dropping needs=20
to be percise according to a fixed percentage.   The dropping needs to =
be based probably on frames rather than bytes.

I am considering solutions composed of scripting of the Linux kernel to =
do all the work entirely, or hybrid approach
as required to supplement the Linux kernel with user code as required.

I considered using the IPTABLES -j QUEUE method to queue contents =
matching a MAC address range to=20
user land queues, where they would programatically be dropped or =
delayed.  Perhaps a better fit would be
EPTables that deals with Ethernet frames,  However, it would seem these =
might be problematic for frames=20
which have two destinations,  such as broadcast and multicast, which =
need to be both left on the internal stack and
forwarded/bridged to the other NIC.

Whereas a pure bridge forwards on all content, I also need to maintain =
an SMNP agent, which will require that frames
matching the IP assigned to the bridge are allowed to pass up the stack =
for internal consumption.    Forwarding will
also be limited to a range of MAC addresses.   Both NICs will need to =
operate in promiscuous mode.

It is not entirely clear whether or not I can do bridging (brctl) in =
combination with ebtables/netfilter/iptables/tcc.

I may to implement some form of the Spanning Tree Protocol (STP), and =
perhaps DHCP to establish the IP for
the pseudo-bridge.

The lowest level alternative that I have considered, the one with the =
highest level of control but possible
the most custom coding, is using the  PCAPS (libpcap) frame sniffer =
technology based on the low level NDIS driver,=20
which allows me to get a callback into user land for each frame received =
by the NIC in promiscuous mode.   Using=20
this approach, I would queue or drop frames in a userland application, =
and then bridge/forward=20
them on to the other NIC based on a custom scheduler thread.   This =
would require me to queue the=20
frames in user land, but provides the highest level of control, and =
perhaps the fastest
forwarding as I would read from one NIC and bridge to the other.   I =
would also leave the frame=20
on the stack so it could have two destinations.  This technique would =
allow me to delay frames with a fairly
fine grain of precision, but does not take maximum advantage of the =
services already provided by the Linux
kernel.
=20
Interested in what design approach you think will fulfil my goals.   Any =
direction you can point=20
me in would be most appreciated.
=20
Bob O'Neil
------=_NextPart_000_005D_01C98B54.6F338190
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.6000.16788" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>IN SHORT </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>How to I leverage what is available on =
the Linux=20
Communcations Stack, either as part of the kernel itself&nbsp; (i.e. =
ebtables,=20
netbridge, tcc, iptables, etc.) and/or an addon module , =
that</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>allows me to implement a Linux Bridge, =
with the=20
additional requirement of dropping out Ethernet frames (not bytes) based =
on a=20
soft setting, and delaying frames (from 4 ms to 10 ms in 1 ms =
</FONT><FONT=20
face=3DArial size=3D2>increments) in ONE direction only of the=20
bridge?&nbsp;&nbsp;&nbsp; This is for a i386 machine with 2 NICS that =
will need=20
to be in promiscuous mode.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>MORE DETAILS</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I am trying to determine the best =
course of action=20
for an application/script that I need to </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>compose for execution under Red Hat =
Linux AS 4.0,=20
Linux Kernel v2.6.x.<BR>&nbsp;<BR>I have a 386 based Linux machine with =
two NICs=20
that acts a bit like a bridge, dispatching frames </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>at the Data Link Layer (not IP, Layer=20
3).&nbsp;&nbsp; On the ingress of NIC 1 (eth0), there will be certain=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>frames which have matching MACs that =
will be=20
consumed (i.e. passed up the stack).&nbsp;&nbsp; Other frames, =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>with a range of matching MAC addresses, =
broadcast=20
and multicast need to be bridged to the other </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>NIC (call it NIC 2, or=20
eth1).&nbsp;&nbsp;&nbsp;&nbsp; Broadcast and Multicast also need to be =
consumed,=20
so may have </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>two destinations, bridged between NICs =
and consumed=20
from the internal stack.&nbsp;&nbsp; I will need to assign</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>an IP address to the application so =
that it may act=20
as an SNMP agent.<BR>&nbsp;<BR>The converse direction follows a similar =
pattern=20
based on the MAC address, certain frames </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>matching a range of MAC address will be =
bridged to=20
NIC 1 from NIC 2, ones which match the MAC </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>address of NIC 2 will be consumed, =
broadcast and=20
multicast need to be both consumed and forwarded </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>to the egress of NIC 1.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The assignments of the IPs, subnets, =
and subnet=20
masks is flexible.</DIV>
<DIV><BR>Now here is the complication that deviates from standard Linux =
kernel=20
behavior.&nbsp;&nbsp; ONLY for frames forwarded/bridged from =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>NIC 1 to NIC2, there are two soft =
</FONT><FONT=20
face=3DArial size=3D2>settings that dictate the forwarding =
behavior:<BR>&nbsp;<BR>1.=20
Delay - this may range from say 4 ms to 15 ms.&nbsp;&nbsp; Based on this =

setting, ingress frames on NIC 1 </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>that will be forwarded on to NIC 2 need =
to be=20
delayed in the process.&nbsp;&nbsp; The delay timing needs to =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>be fairly precise, to the millisecond =
if possible,=20
and possibly as low as 4 ms.<BR>&nbsp;<BR>2. Drop Out Percentage - =
ranges from 0=20
to 100%.&nbsp;&nbsp; Based on this setting, ingress frames on NIC 1=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>will be dropped based on the percentage =

set.&nbsp;&nbsp; The dropout could be a simple uniform dropout, so that =
if=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the percentage is set to 25%, 1 in 4 =
frames will be=20
dropped.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Ethernet frames forwarded in the =
opposite direction=20
(eth1 to eth0) do not have to be delayed or dropped.</DIV>
<DIV><BR>I am trying to come up with a design that is optimum, and that =
takes=20
maximum advantage of&nbsp;what is </DIV>
<DIV>available in the&nbsp;Linux </FONT><FONT face=3DArial =
size=3D2>kernel (via=20
NetFilter/IPTables/EBTables/TCC/bctrl, etc.) via commands.<BR><BR>To =
slow down=20
outgoing traffic, the Tunnel Bucket Filter (TBF) seems like a possible =
command=20
line </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>solution for the delay =
requirement.&nbsp;&nbsp;=20
However, of particular concern is&nbsp;the fact that it is byte=20
based</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>rather than frame based, and =
it&nbsp;appears it may=20
not guarantee a uniform pacing of frames to the</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>user specified delay value with=20
fidelity.&nbsp;&nbsp; In addition, from the document&nbsp;entitled =
"Linux=20
Advanced Routing &amp; Traffic Control HOWTO",</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>is the quote:</FONT></DIV><FONT =
face=3DArial size=3D2>
<DIV><BR>"However, due to the default 10ms timer resolution of Unix, =
with 10.000=20
bits average packets, we </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>are limited to 1mbit/s of=20
peakrate!"<BR>&nbsp;<BR>This statement seems to suggest that the maximum =

precision for a delay would come at 10 ms </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>increments, and it is not clear if a =
low value, say=20
4 ms would be possible.<BR>&nbsp;<BR>For the dropout requirement, =
perhaps some=20
form of Random Early Drops, although the dropping needs </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>to be percise according to a fixed=20
percentage.&nbsp;&nbsp; The dropping needs to be based probably on =
frames rather=20
than bytes.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I am considering solutions composed of =
scripting of=20
the Linux kernel to do all the work entirely,&nbsp;or hybrid=20
approach</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>as required to </FONT><FONT =
face=3DArial=20
size=3D2>supplement the Linux kernel with user code as =
required.</FONT></DIV><FONT=20
face=3DArial size=3D2>
<DIV><BR>I considered using the IPTABLES -j QUEUE method to queue =
contents=20
matching a MAC address range to </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>user land queues, where they would =
programatically=20
be dropped or delayed.&nbsp; Perhaps a better fit would be</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>EPTables that deals with Ethernet =
frames,&nbsp;=20
However, it would seem these might be problematic for frames =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>which have two destinations,&nbsp; =
</FONT><FONT=20
face=3DArial size=3D2>such as broadcast and multicast, which need to be =
both left on=20
the internal stack and<BR>forwarded/bridged to the other =
NIC.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Whereas a pure bridge forwards on all =
content, I=20
also need to maintain an SMNP agent, which will require that =
frames</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>matching the IP assigned to the bridge =
are allowed=20
to pass up the stack for internal consumption.&nbsp;&nbsp;&nbsp; =
Forwarding=20
will</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>also be limited to a range of MAC=20
addresses.&nbsp;&nbsp; Both NICs will need to operate in promiscuous=20
mode.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>It is not entirely clear whether or not =
I can do=20
bridging (brctl) in combination with=20
ebtables/netfilter/iptables/tcc.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I may to implement some form of the =
Spanning Tree=20
Protocol (STP), and perhaps DHCP to establish the IP for</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the pseudo-bridge.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2><BR>The lowest level&nbsp;alternative =
that I have=20
considered, the one with the highest level of control but =
possible</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the most custom coding, is using =
the&nbsp;=20
</FONT><FONT face=3DArial size=3D2>PCAPS (libpcap) frame sniffer =
technology based on=20
the low level NDIS driver, </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>which allows me to get a callback into =
user land=20
for each frame received by the NIC in promiscuous mode.&nbsp;&nbsp; =
Using=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>this approach, I would queue or drop =
frames in a=20
userland application, and then bridge/forward </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>them on to the other NIC based on a =
custom=20
scheduler thread.&nbsp;&nbsp; This would require me to queue the =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>frames in user land, but provides the =
highest level=20
of control, and perhaps the fastest<BR>forwarding as I would read from =
one NIC=20
and bridge to the other.&nbsp;&nbsp; I would also leave the frame =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>on the stack so it could have two=20
destinations.&nbsp; This technique would allow me to delay frames with a =

fairly</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>fine grain of precision, but does not =
take maximum=20
advantage of the services already provided by the Linux</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>kernel.<BR>&nbsp;<BR>Interested in what =
design=20
approach you think will fulfil my goals.&nbsp;&nbsp; Any direction you =
can point=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>me in would be most =
appreciated.<BR>&nbsp;<BR>Bob=20
O'Neil</FONT></DIV></BODY></HTML>

------=_NextPart_000_005D_01C98B54.6F338190--


--===============0033095720638696361==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============0033095720638696361==--
