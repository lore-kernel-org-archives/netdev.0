From: "Jordi Ros" <jros@xiran.com>
Subject: RE: TCP IP Offloading Interface
Date: Mon, 14 Jul 2003 22:42:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C34A93.F094F44C"
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: <linux-kernel@vger.kernel.org>, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>, <davem@redhat.com>, <alan@storlinksemi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C34A93.F094F44C
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

David,

TCP offloading does not necessarily need to be the goal but a MUST if =
one wants to build a performance-scalable architecture. This vision is =
in fact introduced by Mogul in his paper. He writes: "Therefore, =
offloading the transport layer becomes valuable not for its own sake, =
but rather because that allows offloading of the RDMA [...]".

> TOE is evil, read this:

> http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul.pdf

> TOE is exactly suboptimal for the very things performance

> matters, high connection rates.

It is important to understand as well that as Mogul presents, RDMA is =
just one good example, but not the only one. Note that you can change =
the word RDMA in Mogul's quote by the following two words and still the =
same argument applies: Encryption and Direct Path.

1) Encryption: Apostolopoulos et al ("Securing Electronic Commerce: =
Reducing the SSL Overhead," IEEE Network Magazine, July/August 2000) =
proved that overheads due to software encryption can make the servers =
slower by two orders of magnitude. Because SSL runs on top of the =
transport protocol, if you want to do SSL in HW then you are better off =
having the transport offloaded and embedding your SSL asic on the board =
(this is exactly the same argument that Mogul presents on the case of =
RDMA). Assuming an encryption asic that can run at wire speed, this =
would mean about 100 times performance improvement, not just 2 or 3 =
times.

2) Direct Path (tm) from network to storage. Current architecture =
requires a complete round trip to the kernel-user space in order to =
retrieve data from the storage and dump it back to the network. The =
router guys already know what it is to design an architecture based on =
the separation of control plane and data plane. Now, does today's server =
architecture do any separation? the answer is no. This is what Xiran =
Labs (www.xiran.com) has designed. The server is accelerated by =
providing a Direct Path from storage to network (data plane) using an =
asic board that has: (1) network interface + (2) storage interface + (3) =
PCI interface + (4) intelligence. The control plane runs at the host =
side and interfaces with the board through the pci interface. The data =
plane runs in the direct path on the asic board completely bypassing the =
host. All the data is transported in zero copy, directly from storage to =
network, using asic engines that perform optimized tasks (such as tcp =
segmentation or checksumming, among others). There is no interrupts to =
the host. The efficiency, in terms of bits per cycle, is today 6 times =
superior compared to current architecture (see =
www.ipv6-es.com/03/documents/xiran/xiran_ipv6_paper.pdf). As an example, =
there are two well defined applications for Direct Path. Video streaming =
and ISCSI. The reason why they are well defined is because both require =
the transport of massive amount of data (data plane). In both cases one =
can show an important improve in performance.

TOE is believed to not provide performance. I may agree that TOE by =
itself may not, but TOE as a means to deliver some other technology =
(e.g. RDMA, encryption or Direct Path) it does optimize (in some =
instance dramatically) the overall performance. Let me show you the =
numbers in our Direct Path technology.=20

We have partnered with Real Networks to build the concept of control =
plane and data plane separation in their Helix platform. The system in =
fact runs on a Redhat linux box. The data plane (RTP) runs on the Direct =
Path board and completely bypasses the host (whether it is udp based or =
tcp, the data plane connections are routed through the board directly to =
storage). The control plane (RTCP) runs on the host (the tcp connection =
is routed to the host). While a Linux box that uses a regular nic card =
can deliver 300 Mbps of video streaming out of storage at 90% CPU host =
utilization, by changing in the same system the regular nic card with a =
Direct Path board we can get 600 Mbps with only 3% CPU host utilization. =
The reason is because the direct path is completely zero copy, and it =
provides hw accelerated functions. As for scalability, by using 'n' =
direct path boards in the same system, you get n times the throughput =
and a utilization of n*3% at the host CPU side because the system can =
scale (since each direct path board is physically isolated from each =
other). This technology has been presented in several conferences and is =
in alpha phase as we speak.

Note that Microsoft is considering TOE under its Scalable Networking =
Program. To keep linux competitive, I would encourage a healthy =
discussion on this matter. Again, TOE is not the goal but the means to =
deliver important technologies for the next generation of servers. This =
will be critical as the backbone of the Internet goes to all optical =
networks while the servers stay at the electronic domain. As shown by =
McKeown, "Circuit Switching in the Core", the line capacity of the =
optical fibers is doubling every 7 months while the processing CPU =
capacity (Moore's law) can only double every 18 months.=20

jordi

=20

=20

-----Original Message-----

From: linux-net-owner@vger.kernel.org

[mailto:linux-net-owner@vger.kernel.org]On Behalf Of David S. Miller

Sent: Sunday, July 13, 2003 12:48 AM

To: Alan Shih

Cc: linux-kernel@vger.kernel.org; linux-net@vger.kernel.org;

netdev@oss.sgi.com

Subject: Re: TCP IP Offloading Interface

=20

Your return is also absolutely questionable. Servers "serve" data

and we offload all of the send side TCP processing that can

reasonably be done (segmentation, checksumming).

I've never seen an impartial benchmark showing that TCP send

side performance goes up as a result of using TOE vs. the usual

segmentation + checksum offloading offered today.

On receive side, clever RX buffer flipping tricks are the way

to go and require no protocol changes and nothing gross like

TOE or weird buffer ownership protocols like RDMA requires.

I've made postings showing how such a scheme can work using a limited

flow cache on the networking card. I don't have a reference handy,

but I suppose someone else does.

And finally, this discussion belongs on the "networking" lists.

Nearly all of the "networking" developers don't have time to sift

through linux-kernel every day.

-

To unsubscribe from this list: send the line "unsubscribe linux-net" in

the body of a message to majordomo@vger.kernel.org

More majordomo info at http://vger.kernel.org/majordomo-info.html

=20

=20

=20



PROPRIETARY-CONFIDENTIAL INFORMATION INCLUDED

This electronic transmission, and any documents attached hereto, may =
contain confidential, proprietary and/or legally privileged information. =
The information is intended only for use by the recipient named above. =
If you received this electronic message in error, please notify the =
sender and delete the electronic message. Any disclosure, copying, =
distribution, or use of the contents of information received in error is =
strictly prohibited, and violators will be pursued legally. 
------_=_NextPart_001_01C34A93.F094F44C
Content-Type: text/html;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 =
Transitional//EN"><HTML><HEAD><META HTTP-EQUIV=3D"Content-Type" =
CONTENT=3D"text/html; charset=3Dutf-8"></HEAD><BODY><FONT =
COLOR=3DBLACK><DIV><FONT size=3D2>=0A=
<P>David,</P>=0A=
<P>TCP offloading does not necessarily need to be the goal but a MUST if =
one =0A=
wants to build a performance-scalable architecture. This vision is in =
fact =0A=
introduced by Mogul in his paper. He writes: "Therefore, offloading the =0A=
transport layer becomes valuable not for its own sake, but rather =
because that =0A=
allows offloading of the RDMA [...]".</P>=0A=
<P>&gt; TOE is evil, read this:</P>=0A=
<P>&gt; =0A=
http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul.pdf</P>=0A=
<P>&gt; TOE is exactly suboptimal for the very things performance</P>=0A=
<P>&gt; matters, high connection rates.</P>=0A=
<P>It is important to understand as well that as Mogul presents, RDMA is =
just =0A=
one good example, but not the only one. Note that you can change the =
word RDMA =0A=
in Mogul's quote by the following two words and still the same argument =
applies: =0A=
Encryption and Direct Path.</P>=0A=
<P>1) Encryption: Apostolopoulos et al ("Securing Electronic Commerce: =
Reducing =0A=
the SSL Overhead," IEEE Network Magazine, July/August 2000) proved that =0A=
overheads due to software encryption can make the servers slower by two =
orders =0A=
of magnitude. Because SSL runs on top of the transport protocol, if you =
want to =0A=
do SSL in HW then you are better off having the transport offloaded and =0A=
embedding your SSL asic on the board (this is exactly the same argument =
that =0A=
Mogul presents on the case of RDMA). Assuming an encryption asic that =
can run at =0A=
wire speed, this would mean about 100 times performance improvement, not =
just 2 =0A=
or 3 times.</P>=0A=
<P>2) Direct Path (tm) from network to storage. Current architecture =
requires a =0A=
complete round trip to the kernel-user space in order to retrieve data =
from the =0A=
storage and dump it back to the network. The router guys already know =
what it is =0A=
to design an architecture based on the separation of control plane and =
data =0A=
plane. Now, does today's server architecture do any separation? the =
answer is =0A=
no. This is what Xiran Labs (www.xiran.com) has designed. The server is =0A=
accelerated by providing a Direct Path from storage to network (data =
plane) =0A=
using an asic board that has: (1) network interface + (2) storage =
interface + =0A=
(3) PCI interface + (4) intelligence. The control plane runs at the host =
side =0A=
and interfaces with the board through the pci interface. The data plane =
runs in =0A=
the direct path on the asic board completely bypassing the host. All the =
data is =0A=
transported in zero copy, directly from storage to network, using asic =
engines =0A=
that perform optimized tasks (such as tcp segmentation or checksumming, =
among =0A=
others). There is no interrupts to the host. The efficiency, in terms of =
bits =0A=
per cycle, is today 6 times superior compared to current architecture =
(see =0A=
www.ipv6-es.com/03/documents/xiran/xiran_ipv6_paper.pdf). As an example, =
there =0A=
are two well defined applications for Direct Path. Video streaming and =
ISCSI. =0A=
The reason why they are well defined is because both require the =
transport of =0A=
massive amount of data (data plane). In both cases one can show an =
important =0A=
improve in performance.</P>=0A=
<P>TOE is believed to not provide performance. I may agree that TOE by =
itself =0A=
may not, but TOE as a means to deliver some other technology (e.g. RDMA, =0A=
encryption or Direct Path) it does optimize (in some instance =
dramatically) the =0A=
overall performance. Let me show you the numbers in our Direct Path =
technology. =0A=
</P>=0A=
<P>We have partnered with Real Networks to build the concept of control =
plane =0A=
and data plane separation in their Helix platform. The system in fact =
runs on a =0A=
Redhat linux box. The data plane (RTP) runs on the Direct Path board and =0A=
completely bypasses the host (whether it is udp based or tcp, the data =
plane =0A=
connections are routed through the board directly to storage). The =
control plane =0A=
(RTCP) runs on the host (the tcp connection is routed to the host). =
While a =0A=
Linux box that uses a regular nic card can deliver 300 Mbps of video =
streaming =0A=
out of storage at 90% CPU host utilization, by changing in the same =
system the =0A=
regular nic card with a Direct Path board we can get 600 Mbps with only =
3% CPU =0A=
host utilization. The reason is because the direct path is completely =
zero copy, =0A=
and it provides hw accelerated functions. As for scalability, by using =
'n' =0A=
direct path boards in the same system, you get n times the throughput =
and a =0A=
utilization of n*3% at the host CPU side because the system can scale =
(since =0A=
each direct path board is physically isolated from each other). This =
technology =0A=
has been presented in several conferences and is in alpha phase as we =
speak.</P>=0A=
<P>Note that Microsoft is considering TOE under its Scalable Networking =
Program. =0A=
To keep linux competitive, I would encourage a healthy discussion on =
this =0A=
matter. Again, TOE is not the goal but the means to deliver important =0A=
technologies for the next generation of servers. This will be critical =
as the =0A=
backbone of the Internet goes to all optical networks while the servers =
stay at =0A=
the electronic domain. As shown by McKeown, "Circuit Switching in the =
Core", the =0A=
line capacity of the optical fibers is doubling every 7 months while the =0A=
processing CPU capacity (Moore's law) can only double every 18 months. =
</P>=0A=
<P>jordi</P>=0A=
<P>&nbsp;</P>=0A=
<P>&nbsp;</P><FONT size=3D2>=0A=
<P>-----Original Message-----</P>=0A=
<P>From: linux-net-owner@vger.kernel.org</P>=0A=
<P>[mailto:linux-net-owner@vger.kernel.org]On Behalf Of David S. =
Miller</P>=0A=
<P>Sent: Sunday, July 13, 2003 12:48 AM</P>=0A=
<P>To: Alan Shih</P>=0A=
<P>Cc: linux-kernel@vger.kernel.org; linux-net@vger.kernel.org;</P>=0A=
<P>netdev@oss.sgi.com</P>=0A=
<P>Subject: Re: TCP IP Offloading Interface</P></FONT><FONT size=3D2>=0A=
<P>&nbsp;</P>=0A=
<P>Your return is also absolutely questionable. Servers "serve" data</P>=0A=
<P>and we offload all of the send side TCP processing that can</P>=0A=
<P>reasonably be done (segmentation, checksumming).</P>=0A=
<P>I've never seen an impartial benchmark showing that TCP send</P>=0A=
<P>side performance goes up as a result of using TOE vs. the usual</P>=0A=
<P>segmentation + checksum offloading offered today.</P>=0A=
<P>On receive side, clever RX buffer flipping tricks are the way</P>=0A=
<P>to go and require no protocol changes and nothing gross like</P>=0A=
<P>TOE or weird buffer ownership protocols like RDMA requires.</P>=0A=
<P>I've made postings showing how such a scheme can work using a =
limited</P>=0A=
<P>flow cache on the networking card. I don't have a reference handy,</P>=0A=
<P>but I suppose someone else does.</P>=0A=
<P>And finally, this discussion belongs on the "networking" lists.</P>=0A=
<P>Nearly all of the "networking" developers don't have time to sift</P>=0A=
<P>through linux-kernel every day.</P>=0A=
<P>-</P>=0A=
<P>To unsubscribe from this list: send the line "unsubscribe linux-net" =
in</P>=0A=
<P>the body of a message to majordomo@vger.kernel.org</P>=0A=
<P>More majordomo info at http://vger.kernel.org/majordomo-info.html</P>=0A=
<P>&nbsp;</P></FONT>=0A=
<P>&nbsp;</P>=0A=
<P>&nbsp;</P></FONT></DIV><BR><P><FONT =
size=3D2><U>PROPRIETARY-CONFIDENTIAL INFORMATION =
INCLUDED</U><BR><BR>This electronic transmission, and any documents =
attached hereto, may contain confidential, proprietary and/or legally =
privileged information. The information is intended only for use by the =
recipient named above. If you received this electronic message in error, =
please notify the sender and delete the electronic message. Any =
disclosure, copying, distribution, or use of the contents of information =
received in error is strictly prohibited, and violators will be pursued =
legally. </FONT></P></BODY></HTML>
------_=_NextPart_001_01C34A93.F094F44C--
