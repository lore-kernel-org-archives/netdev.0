From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] AF_RAW: Augment raw_send_hdrinc to expand skb to fit
 iphdr->ihl (v2)
Date: Wed, 28 Oct 2009 22:01:08 +0100
Message-ID: <4AE8B114.6050504@gmail.com>
References: <20091028173955.GB7422@hmsreliant.think-freely.org> <4AE889B5.4040301@gmail.com> <20091028185947.GA12675@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52786 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbZJ1VBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 17:01:11 -0400
In-Reply-To: <20091028185947.GA12675@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
>=20
>> I believe we should drop the request, since padding it is not what w=
as expected by user.
>=20
> Yeah, I had a feeling.  Ok, version 2, this time drop the invalid fra=
me and
> report it to user space, instead of expanding it:
>=20
>=20
>     Augment raw_send_hdrinc to correct for incorrect ip header length=
 values
>    =20
>     A series of oopses was reported to me recently.  Apparently when =
using AF_RAW
>     sockets to send data to peers that were reachable via ipsec encap=
sulation,
>     people could panic or BUG halt their systems.
>    =20
>     I've tracked the problem down to user space sending an invalid ip=
 header over an
>     AF_RAW socket with IP_HDRINCL set to 1.
>    =20
>     Basically what happens is that userspace sends down an ip frame t=
hat includes
>     only the header (no data), but sets the ip header ihl value to a =
large number,
>     one that is larger than the total amount of data passed to the se=
ndmsg call.  In
>     raw_send_hdrincl, we allocate an skb based on the size of the dat=
a in the msghdr
>     that was passed in, but assume the data is all valid.  Later duri=
ng ipsec
>     encapsulation, xfrm4_tranport_output moves the entire frame back =
in the skbuff
>     to provide headroom for the ipsec headers.  During this operation=
, the
>     skb->transport_header is repointed to a spot computed by
>     skb->network_header + the ip header length (ihl).  Since so littl=
e data was
>     passed in relative to the value of ihl provided by the raw socket=
, we point
>     transport header to an unknown location, resulting in various cra=
shes.
>    =20
>     This fix for this is pretty straightforward, simply validate the =
value of of
>     iph->ihl when sending over a raw socket.  If (iph->ihl*4U) > user=
 data buffer
>     size, drop the frame and return -EINVAL.  I just confirmed this f=
ixes the
>     reported crashes.
>    =20
>     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

