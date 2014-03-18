From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCHv4 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 22:13:08 +0200
Message-ID: <CAJZOPZ+b=VbRkczaTwysT_DW0y_YX-0rt17T4iqs5JoJGx2KCg@mail.gmail.com>
References: <201403181931.s2IJVLPA016342@lab1.dls>
	<20140318125804.341cebbb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40480 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281AbaCRUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 16:13:08 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so7592178pdi.35
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 13:13:08 -0700 (PDT)
In-Reply-To: <20140318125804.341cebbb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014, Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Tue, 18 Mar 2014 15:31:21 -0400
> David L Stevens <dlstevens@us.ibm.com> wrote:
>
>>
>>       The VXLAN neigh_reduce() code is completely non-functional since
>> check-in. Specific errors:
>>
>> 1) The original code drops all packets with a multicast destination address,
>>       even though neighbor solicitations are sent to the solicited-node
>>       address, a multicast address. The code after this check was never run.
>> 2) The neighbor table lookup used the IPv6 header destination, which is the
>>       solicited node address, rather than the target address from the
>>       neighbor solicitation. So neighbor lookups would always fail if it
>>       got this far. Also for L3MISSes.
>> 3) The code calls ndisc_send_na(), which does a send on the tunnel device.
>>       The context for neigh_reduce() is the transmit path, vxlan_xmit(),
>>       where the host or a bridge-attached neighbor is trying to transmit
>>       a neighbor solicitation. To respond to it, the tunnel endpoint needs
>>       to do a *receive* of the appropriate neighbor advertisement. Doing a
>>       send, would only try to send the advertisement, encapsulated, to the
>>       remote destinations in the fdb -- hosts that definitely did not do the
>>       corresponding solicitation.
>> 4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
>>       isrouter flag in the advertisement. This has nothing to do with whether
>>       or not the target is a router, and generally won't be set since the
>>       tunnel endpoint is bridging, not routing, traffic.
>>
>>       The patch below creates a proxy neighbor advertisement to respond to
>> neighbor solicitions as intended, providing proper IPv6 support for neighbor
>> reduction.
>>
>> Changes since v3:
>>       - code cleanup suggested by Brian Haley
>> Changes since v2:
>>       - code cleanup suggested by Stephen Hemminger and Daniel Baluta
>> Changes since v1:
>>       - reworked code to be structurally similar to arp_reduce()

David, if you generate the patch with git format-patch it will also
produce a ---- line below the signature, I don't think we need to
carry the revision history for the future generations, so you just put
it there and when the maintainer picks the patch git am strips these
lines

> Minor checkpatch nits.
>
> WARNING: 'Signed-off-by:' is the preferred signature form
> #94:
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>
>
> ERROR: trailing whitespace
> #182: FILE: drivers/net/vxlan.c:1417:
> +^I^I&pip6->daddr, sizeof(*na)+olen, IPPROTO_ICMPV6, $
>
> total: 1 errors, 3 warnings, 157 lines checked

I would highly recommend to use the --strict flag so if you have also
CHECK: comments they can (need) be addressed as well.
