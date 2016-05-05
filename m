From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Fri, 6 May 2016 00:39:32 +0300
Message-ID: <CAJ3xEMj8z617kmoc2bLMBXf7B7KSBLzqr5tLTuuXYSOA--MYMw@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
	<20160429224333.12418.13862.stgit@ahduyck-xeon-server>
	<CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
	<CAKgT0UdV2ruuRsYLmOjnqbXW0_i4QqMfo+VhuCSBqJjWrKhRdQ@mail.gmail.com>
	<CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
	<CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
	<57289C95.8030401@mellanox.com>
	<CAKgT0UeK2ss9AsxdvyDHArXXVZMZG7AL6f0iXQukSg135B64cQ@mail.gmail.com>
	<572A1A49.9020507@mellanox.com>
	<CAMt9YRqCH8Ab5vefMoQj39gJ8b-gsg2w5nJanW1srqt13bUkSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alex Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:34059 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756186AbcEEVjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 17:39:33 -0400
Received: by mail-ob0-f181.google.com with SMTP id dm5so43033635obc.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 14:39:33 -0700 (PDT)
In-Reply-To: <CAMt9YRqCH8Ab5vefMoQj39gJ8b-gsg2w5nJanW1srqt13bUkSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 7:06 PM, Alex Duyck <aduyck@mirantis.com> wrote:
> On Wed, May 4, 2016 at 8:50 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> On 5/3/2016 6:29 PM, Alexander Duyck wrote:
>>>
>>> We split the one that would be a different size off via GSO.  So we
>>> end up sending up 2 frames to the device if there is going to be one
>>> piece that doesn't quite match.  We split that one piece off via GSO.
>>> That is one of the reasons why I referred to it as partial GSO as all
>>> we are using the software segmentation code for is to make sure we
>>> have the GSO block consists of segments that are all the same size.
>>
>>
>> I see, so if somehow it happens a lot that the TCP stack sends down
>> something which once segmented ends up with the last segment being of
>> different size from the other ones we would have to call the NIC xmit
>> function twice (BTW can we use xmit_more here?)  -- which could be effecting
>> performance, I guess.
>>
>> GSO_UDP_TUNNEL_CSUM (commit  0f4f4ffa7 "net: Add GSO support for UDP tunnels
>> with checksum") came to mark "that a device is capable of computing the UDP
>> checksum in the encapsulating header of a UDP tunnel" -- and the way we use
>> it here is that we do advertize that bit towards the stack for devices whose
>> HW can **not** do that, and things work b/c of LCO (this is my
>> understanding).
>>
>> I miss something in the bigger picture here, what does this buy us? e.g vs
>> just letting this (say) vxlan tunnel use zero checksum on the outer UDP
>> packet, is that has something to do with RCO?
>
> I think the piece you are missing is GSO_PARTIAL.  Basically
> GSO_PARTIAL indicates that we can perform GSO as long as all segments
> are the same size and also allows for ignoring one level of headers.
> So in the case of ixgbe for instance we can support tunnel offloads as
> long as we allow for the inner IPv4 ID to be a fixed value which is
> identified by enabling TSO_MANGLEID.  In the case of i40e, mlx4, and
> mlx5 the key bit is that we just have to have the frames the same size
> for all segments and then we can support tunnels with outer checksum
> because the checksum has been computed once and can be applied to all
> of the segmented frames.

Yep, I think to basically follow on the PARTIAL thing, which once
advertised by i40e, mlx4 and mlx5 allow them support udp (and GRE in
i40e case) tunnels with outer checksum.

My question was what this buy us for the UDP case vs. using zero
checksum for the tunnel (outer packet), I tried to figure out if it
has something to do with the remote side, e.g for RCO or alike.
Basically, under PARTIAL, on the worst case we could have ending up
with 2x packet xmitted to the NIC - e.g if each TCP message which is
to be encapsulated by the stack and later segmented by the NIC HW is
broken to two b/c otherwise the last segmented packet will not be of
equal size as of the all the preceding ones.

Or being a bit more positive... is there an expected performance  gain
when you use MANGLEID and/or PARTIAL to enable supporting UDP tunnel
segmentation checksum offload towards the stack? what is the reason
for that gain?

As for GRE tunnel segmentation checksum offload, I saw in your i40e
patch that it made your testbed to go from 12Gbs to 20Gbs, is this b/c
the stack can not actually let the HW do the segmentation w.o checksum
offload? if not, can you help understand the source of the gain?

> Hope that helps.

yes, your notes are very helpful, thanks for sparing the time..

Or.
