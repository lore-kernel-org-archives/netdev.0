From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 0/12] vti6: prepare namespace and interfamily support.
Date: Fri, 28 Feb 2014 11:31:10 +0100
Message-ID: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48984 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078AbaB1Kbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 05:31:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset prepares vti6 for proper namespace and interfamily support.

With this patchset vti6 uses a new IPsec protocol multiplexer to
register it's own receive side hooks for ESP, AH and IPCOMP exactly
like the ipv4 side does that now.

Vti6 does the following on receive side:

1. Do an input policy check for the IPsec packet we received.
   This is required because this packet could be already
   processed by IPsec (tunnel in tunnel or a block policy
   is present), so an inbound policy check is needed.

2. Mark the packet with the i_key. The policy and the state
   must match this key now. Policy and state belong to the vti
   namespace and policy enforcement is done at the further layers.

3. Call the generic xfrm layer to do decryption and decapsulation.

4. Wait for a callback from the xfrm layer to do an inbound policy check
   on the vti policy, properly clean the skb to not leak informations on
   namespace transitions and to update the device statistics.

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
