From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Thu, 13 Aug 2009 14:40:42 +0200
Message-ID: <4A8409CA.70200@nets.rwth-aachen.de>
References: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
 <20090812.145549.228391386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "slot.daniel@gmail.com" <slot.daniel@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:37382 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbZHMMlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 08:41:17 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOB00F56F8TT6C0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 13 Aug 2009 14:41:17 +0200 (CEST)
In-reply-to: <20090812.145549.228391386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:
> From: Daniel Slot <slot.daniel@gmail.com>
> Date: Wed, 12 Aug 2009 20:47:44 +0200
>=20
>> RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
>> In the absence of explicit congestion notification from the network,=
 TCP
>> uses loss as an indication of congestion.
>> One of the ways TCP detects loss is using the arrival of three dupli=
cate
>> acknowledgments.
>> However, this heuristic is not always correct,
>> notably in the case when network paths reorder segments (for whateve=
r
>> reason), resulting in degraded performance.
>=20
> Linux's TCP stack already has sophisticated reordering detection.=E4


Hmm, sophisticated? Sorry, it seemed pretty rudimental/random to me.

=46irstly, tp->reordering never shrinks for a given connection
unless an RTO occurs. If that happens tp->reordering is reset to sysctl=
_tcp_reordering
(but it was initialized with a potentially different value from destina=
tion cache).
Why?

Secondly, it simply disables FACK? Disabling FACK completely may (or no=
t) be
the correct solution, if reordering is present. But why don't reenable =
=46ACK
after no more reordering is detected? It won't even get re-enabled if a=
n RTO occurs.
It seems even more strange that tp->reordering is used in FACK paths, t=
oo.
So if one sets a high sysctl_tcp_reordering, because one expects reorde=
ring,
tcp_update_reordering will probably NOT disable FACK, but instead FACK =
will
be used with a high tp->reordering value.

Thirdly, in most cases it will only
trigger if spurious retransmits already happened. If it triggers in adv=
ance (due to
SACK logic, the updated reordering metric will be IMO one to small, lea=
ding again
to a spurios retransmit, if a reordering event with the same length wil=
l happen again)
IOW it will mostly only reduce the damage to congestion control, but wi=
ll send out
spurious packets nevertheless.

In my point of view, on should at least build some EWMA or histogram, o=
r build some
whatever statistcs to measure detected reordering and based on this mea=
surement,
adjust the dupthresh (or max_burst, or whatever). Off course, there is =
always
the question of how much better such an sophisticated statistic will wo=
rk,
than the current very pragmatic solution...

Please correct me if I'm wrong or just too stupid to understand this st=
uff.
(very likely;-)

>=20
>> TCP-NCR is designed to mitigate this degraded performance by increas=
ing the
>> number of duplicate acknowledgments required to trigger loss recover=
y,
>> based on the current state of the connection, in an effort to better
>> disambiguate true segment loss from segment reordering.
>=20
> We already have code in the stack which tries to detect packet
> reordering with a high level of sophistication.

On the contrary RFC 4653 does not even try to detect reordering. It sim=
ply
delays the congestion response in a way which seems very straightforwar=
d.
Of course there is the negative impact of increased latency. (Loss reco=
very
takes longer). However, for large ftp/http transfers, who cares about l=
atency?

There must be some logic in the kernel to detect applications which are
doing bulk transfers for the buffer autotuning, what about enabling RFC=
 4653
in case such an application is detected?

Daniel, I would assume RFC 4653 would simply work with FACK, at least i=
f
there is no reordering present?

Best regards,
Arnd


--=20
Dipl.-Inform. Arnd Hannemann
RWTH Aachen University
Dept. of Computer Science, Informatik 4
Ahornstr. 55, D-52074 Aachen, Germany
Phone: (+49 241) 80-21423 Fax: (+49 241) 80-22220
