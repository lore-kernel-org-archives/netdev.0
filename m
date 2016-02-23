From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Tue, 23 Feb 2016 10:11:31 -0800
Message-ID: <CALx6S35ghjUf0TFMNqa8Va9BZmM9nXGy5frOv9n9ojQSfnWnEQ@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
	<CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
	<CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
	<CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
	<CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
	<CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
	<CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
	<56CC7848.2000704@solarflare.com>
	<CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<56CC94D9.4030308@hpe.com>
	<56CC9914.5010506@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hpe.com>, Jesse Gross <jesse@kernel.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37484 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbcBWSLc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:11:32 -0500
Received: by mail-ig0-f175.google.com with SMTP id z8so13965268ige.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 10:11:32 -0800 (PST)
In-Reply-To: <56CC9914.5010506@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 9:38 AM, Edward Cree <ecree@solarflare.com> wro=
te:
> On 23/02/16 17:20, Rick Jones wrote:
>> On 02/23/2016 08:47 AM, Tom Herbert wrote:
>>> Right, GRO should probably not coalesce packets with non-zero IP
>>> identifiers due to the loss of information. Besides that, RFC6848 s=
ays
>>> the IP identifier should only be set for fragmentation anyway so th=
ere
>>> shouldn't be any issue and really no need for HW TSO (or LRO) to
>>> support that.
>>
>> You sure that is RFC 6848 "Specifying Civic Address Extensions in th=
e Presence Information Data Format Location Object (PIDF-LO)" ?
> PossiblyRFC 6864 "Updated Specification of the IPv4 ID Field".

Yes RFC6864.

>> In whichever RFC that may be, is it a SHOULD or a MUST, and just how=
 many "other" stacks might be setting a non-zero IP ID on fragments wit=
h DF set?
> "The IPv4 ID field MUST NOT be used for purposes other than fragmenta=
tion
>  and reassembly."(=C2=A74.1)
> "Originating sources MAY set the IPv4 ID field of atomic datagrams to=
 any
>  value."(=C2=A74.1)
> "All devices that examine IPv4 headers MUST ignore the IPv4 ID field =
of
>  atomic datagrams."(=C2=A74.1)
> Atomic datagrams are defined by "(DF=3D=3D1)&&(MF=3D=3D0)&&(frag_offs=
et=3D=3D0)" (=C2=A74).
>
> So it's OK to coalesce packets with different identifiers, as long as=
 they
> have DFset (and aren't fragmented already).  Also, the RFC takes pain=
s to
> point out that it "does not reserve any IPv4 ID values, including 0, =
as
> distinguished" (=C2=A74.1), so one cannot rely on the ID always being=
 zero.

Right, receive side is straightforward, just ignore IP IDs. Transmit
is more interesting. Operative code is in ip_select_ident_segs. The
comment as to why non-zero IDs are sent is:

          /* This is only to work around buggy Windows95/2000
           * VJ compression implementations.  If the ID field
           * does not change, they drop every other packet in
           * a TCP stream using header compression.
           */

> --
> -Ed
