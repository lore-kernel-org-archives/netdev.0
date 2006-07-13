From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH]NET: Add ECN support for TSO
Date: Thu, 13 Jul 2006 10:26:40 -0700
Message-ID: <000801c6a6a1$812c08d0$4710100a@pc.s2io.com>
References: <20060708.133223.35527292.davem@davemloft.net>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>,
	<steve.arden@neterion.com>, <Dan.Reader@neterion.com>,
	<leonid.grossman@neterion.com>, <ananda.raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:2444 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1030258AbWGMR11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 13:27:27 -0400
To: "'David Miller'" <davem@davemloft.net>, <mchan@broadcom.com>
In-Reply-To: <20060708.133223.35527292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave/Michael,
Replicating NS bit(from super segment) across all segments looks fine.

But one of the issues is the random/pseudo-random generation of
ECT code points on each of these segments. The hardware will need to
be capable of generating this, and I guess should be able to verify this
against the NS bit received as part of ACK for that packet.

Following are couple of schemes proposed by our team. Please comment.

Option A)

If we were to permit ourselves to somewhat break the spirit of RFC3540
without breaking the letter, we could come up a fairly easy enhancement
to TSO... I think it would be acceptable to set ECT(0) on all packets
except one (I would suggest the last, but an argument could be made for
the first).  That one would have either ECT(0) or ECT(1) set as per a
field in the TxD (for example).

That would give us a method that works with ECN nonces (ECT(0) doesn't
increment the sum).  Unfortunately, it would give us a relative increase
in the number of packets being sent with ECT(0) (the random generation
should see a 50-50 distribution between ECT (0) and (1); we would be
skewing it toward (0) by whatever the proportion of packets to TSO
operations is).  So, a connection using ECN nonces and TSO would be less
robust than one not using TSO.

But it wouldn't be broken...

########

Option B)

The hardware could randomly generate either ECN codepoint on all packets
of a TSO operation except the last.  It would keep a local NS value for
the operation and, in the last packet, set either ECT(0) or ECT(1) as
necessary to generate a NS value equal to that specified in the
descriptor.

That way we would keep a much more equal distribution.  It comes at the
cost of a random value generator in the hardware but we could get by
with something extremely basic (e.g. lsb of the internal clock at the
point the packet is generated) if "perfect" randomness is not required.

The limitation with this scheme is that the sender can't verify the NS
from any returned ACK that falls inside a TSO operation (it can only be
checked at TSO endpoints and on non-TSO transmissions).

Ravi


-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Saturday, July 08, 2006 1:32 PM
To: mchan@broadcom.com
Cc: ravinandan.arakali@neterion.com; herbert@gondor.apana.org.au;
netdev@vger.kernel.org
Subject: Re: [PATCH]NET: Add ECN support for TSO


From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 7 Jul 2006 18:01:34 -0700

> However, Large Receive Offload will be a different story.  If
> packets are accumulated in the hardware and presented to the stack
> as one large packet, the stack will not be able to calculate the
> cumulative NS correctly.  Unless the hardware calculates the partial
> NS over the LRO packet and puts it in the SKB when handing over the
> packet.

This is correct, LRO hardware would need to do something to make sure
the nonce parity works out.
