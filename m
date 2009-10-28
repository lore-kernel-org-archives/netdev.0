From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] AF_RAW: Augment raw_send_hdrinc to expand skb to fit
 iphdr->ihl
Date: Wed, 28 Oct 2009 19:13:09 +0100
Message-ID: <4AE889B5.4040301@gmail.com>
References: <20091028173955.GB7422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51639 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbZJ1SNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:13:20 -0400
In-Reply-To: <20091028173955.GB7422@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Augment raw_send_hdrinc to correct for incorrect ip header length val=
ues
>=20
> A series of oopses was reported to me recently.  Apparently when usin=
g AF_RAW
> sockets to send data to peers that were reachable via ipsec encapsula=
tion,
> people could panic or BUG halt their systems.
>=20
> I've tracked the problem down to user space sending an invalid ip hea=
der over an
> AF_RAW socket with IP_HDRINCL set to 1.
>=20
> Basically what happens is that userspace sends down an ip frame that =
includes
> only the header (no data), but sets the ip header ihl value to a larg=
e number,
> one that is larger than the total amount of data passed to the sendms=
g call.  In
> raw_send_hdrincl, we allocate an skb based on the size of the data in=
 the msghdr
> that was passed in, but assume the data is all valid.  Later during i=
psec
> encapsulation, xfrm4_tranport_output moves the entire frame back in t=
he skbuff
> to provide headroom for the ipsec headers.  During this operation, th=
e
> skb->transport_header is repointed to a spot computed by
> skb->network_header + the ip header length (ihl).  Since so little da=
ta was
> passed in relative to the value of ihl provided by the raw socket, we=
 point
> transport header to an unknown location, resulting in various crashes=
=2E
>=20
> So, what to do about this?  My first thought was to simply return -EI=
NVAL, and
> let user space sort it out.  I'm still thinking that might be the bes=
t way, but
> I thought I'd try this first, just in case someone has reason to try =
to
> send such a bogus frame through the kernel.  This solution simply che=
cks the
> value of ihl in raw_send_hdrinc and expands the skb to fit, filling t=
he new
> space with  IPOPT_NOOP options.  I've confirmed that it fixes the cra=
shes that
> were reported.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20

Thanks a lot for this detailed info, I wish everything could be explain=
ed like this !

I believe we should drop the request, since padding it is not what was =
expected by user.
