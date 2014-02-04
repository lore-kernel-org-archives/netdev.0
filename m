From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH RFC v3 0/12] vti4: prepare namespace and interfamily support.
Date: Tue, 04 Feb 2014 12:05:06 +0100
Message-ID: <52F0C962.5080804@6wind.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com> <52E8DE2C.7060706@6wind.com> <20140130095610.GR31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:40172 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbaBDLFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 06:05:10 -0500
Received: by mail-we0-f180.google.com with SMTP id u57so3886949wes.39
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 03:05:09 -0800 (PST)
In-Reply-To: <20140130095610.GR31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2014 10:56 AM, Steffen Klassert wrote:
> On Wed, Jan 29, 2014 at 11:55:40AM +0100, Christophe Gouault wrote:
> [...]
>> => there is no check that the forward vti security policy was
>> enforced.
>>
>
> Yes, that's true and this is a real problem. If we want to support
> namespace transitions with vti, we can't know if a packet is going
> to be forwarded or locally received in the other namespace. This means
> that we don't know if we should enforce a input or a forward policy.
>
> All we can do here, is to enforce a input policy before we do the
> namespace transition in the receive path. The patch below (on top
> of the vti patchset) should do this.

Hi Steffen, and thank you for the patch.

I tested it within a single netns, then with cross-netns. Both work as
follows:

- all the vti SPs and SAs must be created in the "outer" netns.
- only outbound and inbound vti policies are taken into account, not
   forward vti policies.

in output:

- a global SPD lookup is performed before entering the vti
   interface (in the inner netns). It can be bypassed by adding a policy
   such as:

    ip xfrm policy add dir out mark 0 dev vti1

- then a vti SPD lookup is performed with the vti interface (in the
   outer netns).

in input:

- a global inbound policy check is done (in the outer netns)
   on the IPsec packet by the vti interface.
- then the packet is decrypted.
- then a vti inbound policy check is done on the decrypted packet
   (in the outer netns).
- then the packet device is set to the vti interface and its netns
   is changed to the inner netns.
- finally, a global inbound/forward policy check is done on the
   plaintext packet (without security context), as if it has just arrived
   in plaintext from the network.

> But this has the implication that forward policies do not make
> much sense in combination with vti. This is a bit contrary to
> traditional xfrm processing. But on the other hand, we receive
> plaintext packets from the vti device so we should not check
> for any IPsec processing that happened before we received the
> packets via the vti device.

Unfortunately, the inbound/forward policy checks do not take the inbound
interface into account (__xfrm_decode_session does not properly fill in
the iif field of the flowi), so in the last global policy check, there
is no way of differentiating a plaintext packet directly received from
the network from a plaintext packet that was processed by a vti interface.

Intuitively, I would like to do the same as in output: add a policy that
accepts packets received via a vti interface, and only check more
closely other packets directly received from the network.

Best Regards,
Christophe.
