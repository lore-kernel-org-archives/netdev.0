From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCHv3 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 10:36:01 -0700
Message-ID: <CAHA+R7N0-Ffb325JciRH3Y6MwcpymxWLEtsu45t5HoarAccR4g@mail.gmail.com>
References: <201403181620.s2IGKHcW028664@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>, netdev <netdev@vger.kernel.org>
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:57805 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbaCRRgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:36:04 -0400
Received: by mail-la0-f52.google.com with SMTP id ec20so5097322lab.11
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:36:02 -0700 (PDT)
In-Reply-To: <201403181620.s2IGKHcW028664@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 9:20 AM, David L Stevens <dlstevens@us.ibm.com> wrote:
>
>         The VXLAN neigh_reduce() code is completely non-functional since
> check-in. Specific errors:
>
> 1) The original code drops all packets with a multicast destination address,
>         even though neighbor solicitations are sent to the solicited-node
>         address, a multicast address. The code after this check was never run.
> 2) The neighbor table lookup used the IPv6 header destination, which is the
>         solicited node address, rather than the target address from the
>         neighbor solicitation. So neighbor lookups would always fail if it
>         got this far. Also for L3MISSes.
> 3) The code calls ndisc_send_na(), which does a send on the tunnel device.
>         The context for neigh_reduce() is the transmit path, vxlan_xmit(),
>         where the host or a bridge-attached neighbor is trying to transmit
>         a neighbor solicitation. To respond to it, the tunnel endpoint needs
>         to do a *receive* of the appropriate neighbor advertisement. Doing a
>         send, would only try to send the advertisement, encapsulated, to the
>         remote destinations in the fdb -- hosts that definitely did not do the
>         corresponding solicitation.
> 4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
>         isrouter flag in the advertisement. This has nothing to do with whether
>         or not the target is a router, and generally won't be set since the
>         tunnel endpoint is bridging, not routing, traffic.
>
>         The patch below creates a proxy neighbor advertisement to respond to
> neighbor solicitions as intended, providing proper IPv6 support for neighbor
> reduction.
>
> Changes since v2:
>
> - code cleanup suggested by Stephen Hemminger and Daniel Baluta
>
> Changes since v1:
>
> - reworked code to be structurally similar to arp_reduce() per Dave Miller
>
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

I thought ipv6_stub->ndisc_send_na can be removed, but it is being
used by other driver. So your patch looks good to me:

Reviewed-by: Cong Wang <cwang@twopensource.com>
