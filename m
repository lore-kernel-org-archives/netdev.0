From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv4 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 12:58:04 -0700
Message-ID: <20140318125804.341cebbb@nehalam.linuxnetplumber.net>
References: <201403181931.s2IJVLPA016342@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41053 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbaCRT6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 15:58:09 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so7773911pad.16
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 12:58:08 -0700 (PDT)
In-Reply-To: <201403181931.s2IJVLPA016342@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2014 15:31:21 -0400
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> 	The VXLAN neigh_reduce() code is completely non-functional since
> check-in. Specific errors:
> 
> 1) The original code drops all packets with a multicast destination address,
> 	even though neighbor solicitations are sent to the solicited-node
> 	address, a multicast address. The code after this check was never run.
> 2) The neighbor table lookup used the IPv6 header destination, which is the
> 	solicited node address, rather than the target address from the
> 	neighbor solicitation. So neighbor lookups would always fail if it
> 	got this far. Also for L3MISSes.
> 3) The code calls ndisc_send_na(), which does a send on the tunnel device.
> 	The context for neigh_reduce() is the transmit path, vxlan_xmit(),
> 	where the host or a bridge-attached neighbor is trying to transmit
> 	a neighbor solicitation. To respond to it, the tunnel endpoint needs
> 	to do a *receive* of the appropriate neighbor advertisement. Doing a
> 	send, would only try to send the advertisement, encapsulated, to the
> 	remote destinations in the fdb -- hosts that definitely did not do the
> 	corresponding solicitation.
> 4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
> 	isrouter flag in the advertisement. This has nothing to do with whether
> 	or not the target is a router, and generally won't be set since the
> 	tunnel endpoint is bridging, not routing, traffic.
> 
> 	The patch below creates a proxy neighbor advertisement to respond to
> neighbor solicitions as intended, providing proper IPv6 support for neighbor
> reduction.
> 
> Changes since v3:
> 	- code cleanup suggested by Brian Haley
> Changes since v2:
> 	- code cleanup suggested by Stephen Hemminger and Daniel Baluta
> Changes since v1:
> 	- reworked code to be structurally similar to arp_reduce()
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Minor checkpatch nits.

WARNING: 'Signed-off-by:' is the preferred signature form
#94: 
Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

ERROR: trailing whitespace
#182: FILE: drivers/net/vxlan.c:1417:
+^I^I&pip6->daddr, sizeof(*na)+olen, IPPROTO_ICMPV6, $

total: 1 errors, 3 warnings, 157 lines checked
