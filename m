From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: Labeled Networking Requirements and Design (formerly RE: [PATCH 01/06]
 MLSXFRM: Granular IPSec associations for use in  MLS environments)
Date: Mon, 26 Jun 2006 18:05:49 -0500
Message-ID: <44A0684D.9080904@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@tycho.nsa.gov, paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:40883 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S933256AbWFZXOZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 19:14:25 -0400
To: jmorris@namei.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What we need is a design rationale, some kind of detailed=20
> discussion of=20
> what the user requirements are and what the plan is for implementing=20
> features to meet these requirements.

The following is not extensive in a formal/theoretical sense, but hopef=
ully
addresses the need here.

Needless to say, it is hoped MLS experts and others out there would joi=
n this
discussion.

USER REQUIREMENTS:

The broad user requirements for labeled networking would be that of inf=
ormation
labeling and flow control. Specifically,

1. Data labeling:
	a. data must be labeled where it originates.
	b. data must retain that label (or its interpretation in a given domai=
n)
	   when conveyed in a trustworthy manner.

2. Flow control:
	a. data must be flow controlled at the point it is consumed.
	b. data must be flow controlled at the point it simply flows thru.

3. Data processing support:
	a. Multi-level processes: provision for a sufficiently privileged/trus=
ted
	   process (e.g. Multi-level server) to read/write data labeled at
	   different levels (specifically any/all levels within a given range)=
=2E

	   Such trusted/privileged processes would usually operate at a given
	   level but would be able to read/write data at levels other than the
	   level they are operating at, as allowed by policy.

	b. Multiple single-level processes: provision for a process (usually a
	   legacy, unmodified, untrusted) to be multi-instantiated, with each
	   process binding to the same port but running at a different level.

	   One way to support this is by providing for port polyinstantiation.

	c. Multiple multi-level processes: provision for a process to be multi=
-
	   instantiated, with each process binding to the same port but runnin=
g
	   at a different range (specifically all the levels in the range).

	   3(b) is a special case of this.

NOTE: We (TCS) have products that currently use 3(a) but not 3(b) or 3(=
c). As
such our thrust here is geared toward the former along with 1 and 2. Th=
ere is
currently an ongoing discussion about using network namespaces for port
polyinstantiation at
http://www.redhat.com/archives/redhat-lspp/2006-June/msg00156.html.

PROPOSED DESIGN:

Given the above requirements the following design is proposed:

Socket labeling (SOCK):

1. Label socket to be at the same level as the creating process unless =
the
   process is privileged and has specified a different label (R3a).

2. Create TCP child sockets with the MLS level taken from the peer
   context, relying on the existing process-to-socket sendmsg, recvmsg
   controls to protect the sockets (R3a).

On the inbound (INBND):

The following applies to traffic destined for local sockets (INPUT) as =
well as
forwarded traffic (FORWARD).


1.	Set the packet's secmark to the iptables context (R1a).

2.	If it is an ipsec packet,
	Check that data with the ipsec label can "come thru" the "pipe" as
	represented by the current secmark (iptables context) (R2b). That is,
	check to make sure the ipsec MLS label falls WITHIN the MLS range of
	the "pipe", and that the ipsec TE context can "come thru" the TE conte=
xt
	of the "pipe" per TE policy.
		Yes: Set the secmark to ipsec label (replacing iptables context
		     set in step 1) (R1b).
		No:  Drop packet.

3.	If it=92s a CIPSO packet (NetLabel),
	Check that data with the CIPSO label can "come thru" the "pipe" as
	represented by current secmark (ipsec or iptables context) (R2b).
		Yes: Set the secmark to CIPSO label (R1b).
		No:  Drop packet.

4.	INPUT ONLY: Check socket can receive the packet. That is, check to
	make sure the packet has MLS and TE read access to the packet per
	SELinux policy (R1a, R3a, R3b).

5.	FORWARD ONLY: Jump to OTBND2 below.

On the outbound (OTBND):

The following applies to locally-generated (OUTPUT) as well as forwarde=
d
(FORWARD) traffic.

1.	OUTPUT ONLY:
	a. Set secmark of the packet to the label of the socket unless its a
	   datagram, the process is privileged and is allowed to specify
	   a different label for the datagram per policy (R1a, R3a, R3c).

	b. If there's no real socket to take the label from, and this packet i=
s
	   in response to a received packet, use the level from the received
	   packet, taking the TE portion of the context from the pseudo-socket
	   on whose behalf the packet is being sent.

2.	If using CIPSO, set the option derived from Secmark (R1a). Drop pack=
et
	if a valid CIPSO option can't be derived.

3.	If using IPSec (packet secmark must fall within the range of a xfrm
	policy rule), choose a matching SA (again packet label must fall withi=
n
	the range for the security association) (R2b, R1b). Set the secmark to
	ipsec label (replacing the label it was set to in step 1).

4.	In the POSTROUTING chain of the mangle table:
	a. Determine the iptables context per the iptables POSTROUTING
	   policy chain in the mangle table. But it WON=92T go into the secmar=
k
	   of the packet like it currently does.
	b. Check that the packet can "pass thru" the "pipe" as represented by
	   the iptables context (R2b). That is, the secmark's MLS label must
	   fall WITHIN the MLS range of the "pipe", and the secmark's TE conte=
xt
	   can "pass thru" the TE context of the "pipe" per TE policy.

		NOTE: This means that data may not necessarily have the
		ability to go out by itself, just that it can go in an ipsec
		pipe and that pipe can go out.  You can have traffic that is
	        only allowed to leave via ipsec this way. data_t can not go ou=
t
 		of iface_t, but it can go into ipsec_pipe_t, which can go out
		of iface_t.
=09

User API (UAPI):

1. IPSec xfrms:
	a. Specify labels with xfrm policy, association rules.
	b. Specify label as part of acquire messages to IKE daemons
	   so the label can be made a part of the negotiation process.

2. Socket labeling:
	a. Specify label to be used for sockets to be created.

3. Datagram labeling:
	a. Specify label for a datagram being written.


OUTSTANDING ITEMS (ITEM):

1. Support for granular IPSec associations (INBND2, OTBND3).

2. Use level from incoming packet for outgoing packet when no real sock=
et
   present (OTBND1b).

3. TCP child sockets (SOCK2).

4. Checks against iptables context on outbound (OTBND4).

5. Socket labeling (UAPI2).

6. CIPSO (NetLabel) and other legacy labeling mechanisms.

7. Datagram labeling (UAPI3).

8. Port polyinstantiation (INBND4a).



ARCHITECTURAL DIRECTIONS:

Interaction with containers/network namespaces:

I have only cursorily glanced at containers and network namespaces, but
intuitively speaking, they could be defined to operate at different MLS
ranges and meet the above requirements in terms of handling data
that falls within those ranges.

Example:

Container/namespace A: Unclassified to Confidential
Container/namespace B: Secret to Top Secret

If a packet were to arrive with the label Confidential, it would need t=
o be
"routed" to container A. Similarly, a packet labeled Secret would be ro=
uted
to namespace B. This would be satisfy Requirement 3c (R3c for short) .

Also, a packet labeled Secret must NOT be allowed to be sent from Conta=
iner A,
but must be allowed from B, meeting Requirement 2.b (R2b for short).


GAME PLAN FOR PATCHES:

1. Patch for ITEM1, ITEM2, ITEM3 (being worked by TCS) should be out in=
 a few
   days.

2. Patch for ITEM4.

3. Patch for ITEM5 has already been done by Eric Paris and is being con=
sidered
   for upstreaming.

4. Patch for ITEM6: Paul Moore has done a "NetLabel" patch for this and=
 the
   patch is currently under review upstream.

5. Patch for ITEM7: TCS currently have no plans to design and implement=
 this.

6. Patch for ITEM8: There's currently an ongoing discussion about possi=
bly
   using network namespaces for this purpose. TCS have no plans to work=
 on this
   at the current time.
