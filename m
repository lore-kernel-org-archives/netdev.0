From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP  encapsulation mode
Date: Thu, 18 Dec 2008 22:04:53 +1100
Message-ID: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
References: <1229596531.10402.121.camel@martin>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: martin@strongswan.org (Martin Willi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751411AbYLRLFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 06:05:06 -0500
In-Reply-To: <1229596531.10402.121.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Willi <martin@strongswan.org> wrote:
> 
>> This can't work as ESP relies on this check.  Now that it's gone
>> ESP may touch a UDP header which doesn't exist.
> 
> Hm, this worked perfectly fine in my tests...

Well if you setup an SA with encap != NULL, then send it an
unencapsulated ESP packet it'll try to access the UDP header
(to check for address/port changes) which isn't there.

>> ... when your addresses change
>> you have to renegotiate with the other side to ensure that this
>> isn't some kind of an attack.  Afterwards you have to recreate
>> the SAs at which point you can easily set the encapsulation to
>> whatever it should be.
> 
> Such address changes are recorded in the IKEv2 daemon and addresses are
> updated through MOBIKE (RFC4555). Each peer updates its SA using the new
> address. 

I know.  The point is when such an address change occurs you need
to recreate the kernel SAs anyway, in which case you can reset the
encapsulation status to what it should be.

> This is a perfectly valid use case. MOBIKE allows you roam your SAs
> between different networks, NATed or not. In our implementation, we
> switch UDP encapsulation strictly on and off depending on the new NAT
> situation. However, other implementations don't [1].

You didn't understand me correctly.  Of course the peer is allowed
to change addresses.  The point is that after such an address
change occurs, we must replace the existing SAs with a new set of
SAs (otherwise the communication breaks down), at which point you
can set the NAT-T encapsulation status to what it should be.

> It is a requirement for MOBIKE enabled peers to accept UDP encapsulated
> packets in any case (see discussion [2]), and it is currently discussed
> to add this requirement to the revised IKEv2 core standard [3]:

I have absolutely no qualms about that.  But this has nothing to
do with the kernel.  What they were discussing in [2] is that the
IKE manager must be willing to negotiate SAs with/without UDP
encapsulation if NAT is not detected.  The kernel only gets involved
once the negotiation is complete at which point you have agreed
with the other side whether UDP encapsulation is to be used.

Once this negotiation is complete, neither the other side nor us can
unilaterally change the UDP encapsulation status without performing
a new negotiation.  So there is absolutely no need to handle this
in the kernel.

>> o  Implementations MUST process received UDP-encapsulated ESP packets
>>       even when no NAT was detected.
> 
> The fact that there is not NAT between peers is no guarantee that the
> peer will not use UDP encapsulation.

Which is fine.  The kernel is perfectly able to perform ESP-over-UDP
without your patch.  What it doesn't do is automatically switch
from UDP encapsulation to without UDP encapsulation, or vice versa
without key manager instructions.

> I don't see any reason to drop ESP packets because of the used UDP
> encapsulation mode. What's the point of doing so?

For a start, you've introduced a bug in the ESP code as it may try
access a non-existant UDP header and then interpret that as an
address change which will generate bogus events to your daemon.
This will happen on every packet if you move from with encapsulation
to without encapsulation.

More importantly, you've failed to demonstrate why you need this
in the first place.  None of the URLs you've quoted tells us that
the kernel needs to handle an SA switching between with encap and
without encap without the key manager telling it to do so.
 
> [1]https://lists.strongswan.org/pipermail/users/2008-December/002936.html

Right that's what led to this patch.

Reading this it seems that there is either a bug in strongswan or
in its peer.  IKE or IKEv2 is supposed to negotiate UDP encapsulation
explicitly.  So either we did negotiate to use UDP encapsulation,
and Strongswan ignored it (it's buggy), or we didn't and the peer
still chose to use it (the peer is buggy).

In either case it's a serious bug in the key manager.  I don't see
why we should work around such brokenness in the kernel.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
