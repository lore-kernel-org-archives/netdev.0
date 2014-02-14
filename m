From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v4 0/12] vti4: prepare namespace and interfamily support.
Date: Fri, 14 Feb 2014 09:30:08 +0100
Message-ID: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39150 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbaBNIay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 03:30:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I decided to do a RFC v4 patchset because there accumulated enough
fixes during some 'real life' tests. The changelog is below.

This patchset prepares vti4 for proper namespace and interfamily support.

Currently the receive hook is in the middle of the decapsulation
process, some of the header pointers point still into the IPsec packet
others point already into the decapsulated packet. This makes it
very unflexible and proper namespace and interfamily support can't
be done as it is.

The patchset that implements an IPsec protocol multiplexer, so that vti
can register it's own receive path hooks. Further it makes the i_key
usable for vti and changes the vti code to do the following:

vti uses the IPsec protocol multiplexer to register it's
own receive side hooks for ESP, AH and IPCOMP.

Vti does the following on receive side:

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


Changes from v1:

- Rebased to current net-next.
- Fix a rcu lockdep complaint in xfrm protocol registration/deregistration.
- Fix usage of a ipv4 specific callback handler in generic code.
- Use skb_scrub_packet() to clear the skb in vti_rcv(), suggested by
  Nicolas Dichtel.
- Add support for IPCOMP.
- Support inter address family tunneling.

Changes from v2:

- Rebased to current net-next.
- Check for matching tunnel endpoints of the xfrm state and
  the vti interface.
- Use a own error handler to not create dependencies to the
  generic IPsec protocol handlers.
- Change the receive path to do the namespace transition after
  decapsulation. With this the xfrm lookups are done in the outer
  namespace for xmit and receive, thanks to Christophe Gouault
  for pointing this out.
- Enable namespace changing of vti devices.

Changes from v3:

- Do a inbound policy check to enforce vti input policies after
  decapsulating. Thanks to Christophe Gouault for reporting this issue.
- Drop vti tunneled packets that match on transport mode states.
- Initialize the vti related fields on the skb control buffer in any case.
- Add a separate handler for udp encapsulated packets to route these packets
  into vti if needed.
- Transport mode can return positive values on input, so let er receive handlers
  return an explicit error value instead of a positive number when the handler
  is not responsible.

I'd take this into the ipsec-next tree if noone has further
suggestions or objections.
