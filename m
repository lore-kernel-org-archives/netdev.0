From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Mon, 2 May 2016 08:41:16 -0700
Message-ID: <CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
	<20160429224333.12418.13862.stgit@ahduyck-xeon-server>
	<CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
	<CAKgT0UdV2ruuRsYLmOjnqbXW0_i4QqMfo+VhuCSBqJjWrKhRdQ@mail.gmail.com>
	<CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35777 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbcEBPlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 11:41:17 -0400
Received: by mail-io0-f176.google.com with SMTP id d62so171492140iof.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 08:41:16 -0700 (PDT)
In-Reply-To: <CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 12:19 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, May 2, 2016 at 5:25 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Sun, May 1, 2016 at 1:35 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>> This patch assumes that the mlx4 hardware will ignore existing IPv4/v6
>>>> header fields for length and checksum as well as the length and checksum
>>>> fields for outer UDP headers.
>
>>> I see now the above text appearing in bunch of similar commit of
>>> yours, specifically to Intel drivers and mlx5... could you please
>>> elaborate a bit more what you mean here and what are the practical
>>> consequences of that characteristics?
>
>>> I got that right NETIF_F_GSO_UDP_TUNNEL_CSUM means that the HW can do
>>> segmentation for TCP packets encapsulated by UDP tunnel e.g VXLAN
>>> where the outer checksum is not zero. AFAIK, any other outer checksum
>>> value can't correctly be a constant... are you assuming here  RCO or
>>> LCO?
>
>> Actually it is really easy for outer UDP checksum to be constant as
>> long as we keep the length of all segments constant.  This all ties
>> back into LCO.  As long as the fields between the start of the UDP
>> header and the start of the TCP header are either constant, as in the
>> case of IPv6, or have their own checksum as in the case of IPv4 we
>> will end up with the checksum of the outer header being constant.
>
> cool. I would love seeing this documented somewhere, either in the
> change log if you do a respin or on some kernel networking
> documentation, is that part of the LCO documentation?

I have some documentation in
Documentation/networking/segmentation-offloads.txt.  Feel free to
review it and provide any additional feedback and/or patches you
believe it needs.  To me it made sense but I already understood how
all this stuff worked.

>> So in effect as long as we can trust the hardware to segment every
>> frame to the specified size and that it won't insert any extra data
>> anywhere in that region that we aren't expecting we can guarantee that
>> each frame will have the same checksum for the outer UDP header.
>
> Wow, that is really cool, thanks for taking the time and explaining it over.
>
> Just one more piece to clarify... in the general case (e.g inner
> packet size 1.5k...64k), the last segment would not have the same
> length as the other segments, what happens on that case?

Actually in the case of GSO partial we have go through the software
segmentation code and trim off any last bit that doesn't match the MSS
of the rest of the frame.  That way you end up with one frame that has
some number of MSS sized chunks, and then one remainder if there is a
frame that would be a different size.

- Alex
