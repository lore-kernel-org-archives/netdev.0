From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 20:20:50 +0000
Message-ID: <56CCBF22.6020904@solarflare.com>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
 <56CC94D9.4030308@hpe.com> <56CC9914.5010506@solarflare.com>
 <20160223.130826.608797488173024832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <rick.jones2@hpe.com>, <tom@herbertland.com>, <jesse@kernel.org>,
	<aduyck@mirantis.com>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:13609 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753817AbcBWUaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 15:30:23 -0500
In-Reply-To: <20160223.130826.608797488173024832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/16 18:08, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Tue, 23 Feb 2016 17:38:28 +0000
>
>> "The IPv4 ID field MUST NOT be used for purposes other than fragment=
ation
>>  and reassembly."(=C2=A74.1)
>> "Originating sources MAY set the IPv4 ID field of atomic datagrams t=
o any
>>  value."(=C2=A74.1)
>> "All devices that examine IPv4 headers MUST ignore the IPv4 ID field=
 of
>>  atomic datagrams."(=C2=A74.1)
>> Atomic datagrams are defined by "(DF=3D=3D1)&&(MF=3D=3D0)&&(frag_off=
set=3D=3D0)" (=C2=A74).
>>
>> So it's OK to coalesce packets with different identifiers, as long a=
s they
>> have DFset (and aren't fragmented already).  Also, the RFC takes pai=
ns to
>> point out that it "does not reserve any IPv4 ID values, including 0,=
 as
>> distinguished" (=C2=A74.1), so one cannot rely on the ID always bein=
g zero.
> Just a reminder that a very long time ago we tried setting the IP ID
> field to zero for DF packets, and this broke SLHC because that expect=
s
> a monotonically increasing IP ID field.
If I'm reading it right, Linux's SLHC implementation can cope [1] with
unchanging IP IDs (or IDs that do something other than increment), whic=
h it
encodes with the NEW_I bit.  RFC1144 supports this, remarking "note tha=
t it
may be zero or negative" (=C2=A73.2.3) of the ID delta.  So VJ implemen=
tations that
can't handle it really are buggy, not just exhibiting a difference of o=
pinion.

So it seems like the problem case is where some sort of SLIP gateway li=
es
between a Linux system (say, a webserver sending with TSO) and a buggy =
client;
in that case, even if the client can't be fixed it seems like the gatew=
ay
could be (either to send NEW_I or just lie about the incoming IP IDs an=
d claim
they're incrementing - the latter is entirely safe for a DF packet).

[ I really hope we can figure out a way not to change IP IDs, because I=
 think
an inverted version of Tom's generic TSO could also work as a generic h=
/w GRO
accelerator.  In its simplest form, the hardware just remembers the pre=
vious
packet, then gives us the length of the common prefix.  If that ends fo=
ur bytes
into a TCP header, then the packet is a candidate for GRO; otherwise no=
t.  I
haven't worked out all the details yet, but it's clear that non-constan=
t IP IDs
would cause problems.  (If it's only the innermost IP ID that's changin=
g, we
can probably still cope, but the performance gain will be less and the
implementation could start to get ugly.) ]
