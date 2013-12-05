From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 0/9] vti4: prepare namespace and interfamily support.
Date: Thu, 5 Dec 2013 13:00:28 +0100
Message-ID: <20131205120028.GW31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55423 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059Ab3LEMAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 07:00:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset prepares vti4 for proper namespace and interfamily support.
It is based on the net tree because net-next is still too far behind the
mainline.

Currently the receive hook is in the middle of the decapsulation
process, some of the header pointers point still into the IPsec packet
others point already into the decapsulated packet. This makes it
very unflexible and proper namespace and interfamily support can't
be done as it is.

The patchset that implements an IPsec protocol multiplexer, so that vti
can register it's own receive path hooks. Further it makes the i_key
usable for vti and changes the vti4 code to do the following:

vti uses the IPsec protocol multiplexer to register it's
own receive side hooks for ESP and AH.

Vti does the following on receive side:

1. Do an input policy check for the IPsec packet we received.
   This is required because this packet could be already
   processed by IPsec (tunnel in tunnel or a block policy
   is present), so an inbound policy check is needed.

2. Clean the skb to not leak informations on namespace
   transitions.

3. Mark the packet with the i_key. The policy and the state
   must match this key now. Policy and state belong to the vti
   namespace and policy enforcement is done at the further layers.

4. Call the generic xfrm layer to do decryption and decapsulation.

5. Wait for a callback from the xfrm layer to properly update
   the device statistics.

On transmit side:

1. Mark the packet with the o_key. The policy and the state
   must match this key now.

2. Do a xfrm_lookup on the original packet with the mark applied.

3. Check if we got an IPsec route.

4. Clean the skb to not leak informations on namespace
   transitions.

5. Attach the dst_enty we got from the xfrm_lookup to the skb.

6. Call dst_output to do the IPsec processing.

7. Do the device statistics.

It has not much testing so far. I can setup the vti tunnels and ping through
it. That's all I tried so test carefully ;-).

I'll start to care about the ipv6 side after I've got some feedback on this.
