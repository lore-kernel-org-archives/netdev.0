From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Subject: [PATCH] Structure icmp6hdr (IPv6/ICMPv6) with bug in the bitfields!
Date: Tue, 14 Oct 2008 12:06:20 +0100
Message-ID: <159769323.20081014120620@net.ipl.pt>
Reply-To: Pedro Ribeiro <pribeiro-bulk-reply@isel.ipl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.net.ipl.pt ([192.104.48.14]:51310 "EHLO
	smtp-out1.net.ipl.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202AbYJNLiq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 07:38:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst, let-me say sorry for the long text, i think is needed for
context.

My name is Pedro Ribeiro and I=92m the operations coordinator at
IPLNet, a network that interconnects all the schools belonging to the
Polytechnic Institute of Lisbon (IPL) and in addition I=92m also a
teacher of network engineering at ISEL (a local university).

In the majority of the network segments of our infrastructure, we
have dual stack connectivity with IPv4/IPv6. In the last months, we
have upgraded most of the infrastructure, specially targeting IPv6
performance leaving most of the segments with an =93old/slow router=94 =
and
a =93new/fast=94 router as possible default gateways.
In the course of validating the changes, we have done some tests with
IPv6 and some of them were really disappointing with no gains at all.

While investigating the cause of that, I have seen that our main
Linux servers were using the =93wrong=94 default gateway, the =93old/sl=
ow=94
one. This behaviour is inconsistent with the configuration of the
routers; the =93new/fast=94 is sending the router advertisements
announcing himself as default gateway with MEDIUM (default) preference
and the =93old/slow=94 announcing himself as LOW preference.

Deep analysis in the sources of Linux revealed that the value of
=93pref=94 passed to rt6_add_dflt_router(...) in the file net/ipv6/rout=
e.c
isn=92t consistent with the one sent by the routers and observed with
wireshark. Seeking the roots of the problem I=92ve detected a bug in th=
e
definitions of the bitfield that includes the router preference in the
router advertisement message that are resulting in retrieving the
wrong bits from the structure defined in =93include/linux/icmpv6.h=94. =
The
struct is the base one from ICMPv6 (icmp6hdr) and was lacking the bit
field =93home_agent=94 between =93router_pref=94 and =93other=94 and th=
e reserved
bits are only 3, not 4 as in the structure (according to RFC4191)

=46ollows a =93diff=94 with the changes I=92ve made to correct this pro=
blem
(I=92ve made it against kernel 2.6.23, but I=92ve confirmed that the
problem still exists in 2.6.25)

--- /usr/src/linux-2.6.23-gentoo-r9orig/include/linux/icmpv6.h      200=
7-10-09 21:31:38.000000000 +0100
+++ /usr/src/linux-2.6.23-gentoo-r9/include/linux/icmpv6.h      2008-10=
-13 17:42:56.000000000 +0100
@@ -40,16 +40,18 @@
                 struct icmpv6_nd_ra {
                        __u8            hop_limit;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-                       __u8            reserved:4,
+                       __u8            reserved:3,
                                        router_pref:2,
+                                       home_agent:1,
                                        other:1,
                                        managed:1;
=20
 #elif defined(__BIG_ENDIAN_BITFIELD)
                        __u8            managed:1,
                                        other:1,
+                                       home_agent:1,
                                        router_pref:2,
-                                       reserved:4;
+                                       reserved:3;
 #else
 #error "Please fix <asm/byteorder.h>"
 #endif

Even after this fix, the problem of deterministic and preference
aware default route selection, remains. I have not figured until now
how the preference affects the selection, maybe it is a missing
feature.

I am sorry to say it (I am not a Windows fan), but the behaviour
observed in Windows Vista is in this matter consistent with the one I
was expecting from the reading of the RFCs.

Developers on this area please clarify me this subject; does the
preference present in the RAs is supposed to influence the decision?
In addition, what is the criterion for selecting the default route in
the presence of multiple candidates with the same preference?
Best Regards to all the Linux community!

--=20
Best regards,

=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-
Pedro Ribeiro
IPLNet - Rede de dados e comunica=E7=F5es
Instituto Polit=E9cnico de Lisboa (IPL)
Mail: mailto:pribeiro AT net.ipl.pt
VoIP: sip:pribeiro AT net.ipl.pt
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-

