From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH RFC v3 0/12] vti4: prepare namespace and interfamily support.
Date: Wed, 29 Jan 2014 11:55:40 +0100
Message-ID: <52E8DE2C.7060706@6wind.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:38798 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaA2Kzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 05:55:45 -0500
Received: by mail-wg0-f49.google.com with SMTP id a1so3078654wgh.4
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 02:55:44 -0800 (PST)
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2014 11:29 AM, Steffen Klassert wrote:
> This patchset prepares vti4 for proper namespace and interfamily support.
>
> Currently the receive hook is in the middle of the decapsulation
> process, some of the header pointers point still into the IPsec packet
> others point already into the decapsulated packet. This makes it
> very unflexible and proper namespace and interfamily support can't
> be done as it is.
>
> The patchset that implements an IPsec protocol multiplexer, so that vti
> can register it's own receive path hooks. Further it makes the i_key
> usable for vti and changes the vti code to do the following:
>
> vti uses the IPsec protocol multiplexer to register it's
> own receive side hooks for ESP, AH and IPCOMP.
>
> Vti does the following on receive side:
>
> 1. Do an input policy check for the IPsec packet we received.
>     This is required because this packet could be already
>     processed by IPsec (tunnel in tunnel or a block policy
>     is present), so an inbound policy check is needed.
>
> 2. Mark the packet with the i_key. The policy and the state
>     must match this key now. Policy and state belong to the vti
>     namespace and policy enforcement is done at the further layers.

Hi Steffen,

I did some tests, and it seems there is no inbound policy check against
a vti SP after the ipsec decryption:

To confirm the problem, I added some logs in the kernel to track the
outbound SPD lookup and inbound policy check.

I tested a ping from HostL(10.22.1.1) to HostR(10.24.1.201), that must
be encapsulated via a vti interface (vti1, mark 1, ifindex 8) between
IPsecVTI(10.23.1.101) and HostR(10.23.1.201).

. 10.22.1.0/24 10.23.1.0/24 10.24.1.0/24
. (HostL) ------------(IPsecVTI)============(HostR)------------
. .1 .101 .201

Here is the trace:

(1) xfrm_lookup: oif=8 mark=0 saddr=10.22.1.1 daddr=10.24.1.201
(2) xfrm_lookup: oif=8 mark=1 saddr=10.22.1.1 daddr=10.24.1.201
(3) vti_rcv: found tunnel vti1
(4) __xfrm_policy_check: dir=0 iif=0 mark=0 saddr=10.23.1.201
daddr=10.23.1.101 skb->sp->len=0
(5) __xfrm_policy_check: dir=2 iif=0 mark=0 saddr=10.24.1.201
daddr=10.22.1.1 skb->sp->len=0

And the analysis:

- A first SPD lookup is done before entering vti1 in (1), seeking for
a "global SP".
- A second SPD lookup is done after entering vti1 in (2), with mark 1,
seeking for a "vti SP"
- the icmp request is encapsulated and sent to HostR
- the esp-encrypted icmp reply is received, the packet enters vti1
and an inbound policy check is performed on the ESP packet itself in
(4), with mark 0, seeking for a "global SP".
- the packet is decrypted and its mark set to 1, but no vti inbound
policy check is done. Then the skb mark and secpath are reset by
skb_scrub_params (called by vti_rcv_cb).
- Then only an inbound policy check is performed on the icmp
reply in (5), seeking for a "global SP". It is considered a plaintext
packet, with no mark or secpath.

=> there is no check that the forward vti security policy was
enforced.

Best Regards,
Christophe.

>
> 3. Call the generic xfrm layer to do decryption and decapsulation.
>
> 4. Wait for a callback from the xfrm layer to properly clean the skb to
>     not leak informations on namespace transitions and to update the device
>     statistics.
>
> On transmit side:
>
> 1. Mark the packet with the o_key. The policy and the state
>     must match this key now.
>
> 2. Do a xfrm_lookup on the original packet with the mark applied.
>
> 3. Check if we got an IPsec route.
>
> 4. Clean the skb to not leak informations on namespace
>     transitions.
>
> 5. Attach the dst_enty we got from the xfrm_lookup to the skb.
>
> 6. Call dst_output to do the IPsec processing.
>
> 7. Do the device statistics.
>
>
> Changes from v1:
>
> - Rebased to current net-next.
> - Fix a rcu lockdep complaint in xfrm protocol registration/deregistration.
> - Fix usage of a ipv4 specific callback handler in generic code.
> - Use skb_scrub_packet() to clear the skb in vti_rcv(), suggested by
>    Nicolas Dichtel.
> - Add support for IPCOMP.
> - Support inter address family tunneling.
>
> Changes from v2:
>
> - Rebased to current net-next.
> - Check for matching tunnel endpoints of the xfrm state and
>    the vti interface.
> - Use a own error handler to not create dependencies to the
>    generic IPsec protocol handlers.
> - Change the receive path to do the namespace transition after
>    decapsulation. With this the xfrm lookups are done in the outer
>    namespace for xmit and receive, thanks to Christophe Gouault
>    for pointing this out.
> - Enable namespace changing of vti devices.
>
> I'd take this into the ipsec-next tree after the merge window closes
> if noone has further suggestions or objections.
>
