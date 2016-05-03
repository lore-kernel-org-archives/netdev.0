From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH next-next 0/7] net: Cleanup IPv6 ip tunnels
Date: Mon, 2 May 2016 19:03:36 -0700
Message-ID: <CAKgT0Uft38QUh4ROsUwcsSqJPisORYDFBAnUdFnDpSeYLxw3Ug@mail.gmail.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35962 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbcECCDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 22:03:37 -0400
Received: by mail-io0-f173.google.com with SMTP id u185so11296946iod.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 19:03:37 -0700 (PDT)
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 5:12 PM, Tom Herbert <tom@herbertland.com> wrote:
> The IPv6 tunnel code is very different from IPv4 code. There is a lot
> of redundancy with the IPv4 code, particularly in the GRE tunneling.
>
> This patch set cleans up the tunnel code to make the IPv6 code look
> more like the IPv4 code and use common functions between the two
> stacks where possible.
>
> This work should make it easier to maintain and extend the IPv6 ip
> tunnels.
>
> Items in this patch set:
>   - Cleanup IPv6 tunnel receive path (ip6_tnl_rcv). Includes using
>     gro_cells and exporting ip6_tnl_rcv so the ip6_gre can call it
>   - Move GRE functions to common header file (tx functions) or
>     gre_demux.c (rx functions like gre_parse_header)
>   - Call common GRE functions from IPv6 GRE
>   - Create ip6_tnl_xmit (to be like ip_tunnel_xmit)
>
> Tested:
>   Ran super_netperf tests for TCP_RR and TCP_STREAM for:
>     - IPv4 over gre, gretap, gre6, gre6tap
>     - IPv6 over gre, gretap, gre6, gre6tap
>     - ipip
>     - ip6ip6
>     - ipip/gue
>     - IPv6 over gre/gue
>     - IPv4 over gre/gue
>
> Tom Herbert (7):
>   ipv6: Cleanup IPv6 tunnel receive path
>   gre: Move utility functions to common headers
>   gre6: Cleanup GREv6 receive path, call common GRE functions
>   ipv6: Create ip6_tnl_xmit
>   gre: Create common functions for transmit
>   ipv6: Generic tunnel cleanup
>   gre6: Cleanup GREv6 transmit path, call common GRE functions
>
>  include/net/gre.h        | 104 +++++++++++++
>  include/net/ip6_tunnel.h |  11 +-
>  net/ipv4/gre_demux.c     |  64 ++++++++
>  net/ipv4/ip_gre.c        | 199 +++---------------------
>  net/ipv6/ip6_gre.c       | 392 +++++++++--------------------------------------
>  net/ipv6/ip6_tunnel.c    | 266 +++++++++++++++++++++-----------
>  6 files changed, 452 insertions(+), 584 deletions(-)
>
> --
> 2.8.0.rc2
>

I was wondering if you have more work going on in this area or not?  I
ask because I was just going through and auditing the calls to
skb_reset_inner_headers and I think the only spot left that is calling
it without verifying that either GSO or CHECKSUM_PARTIAL is set is in
ip6_tnl_xmit.  If we can get that moved over to using
iptunnel_handle_offloads like the other functions then we should be
guaranteed that skb->encapsulation is only ever set if an offload is
requested, and that in turn guarantees that csum_start and
inner_transport_offset will always be the same value.

Thanks.

- Alex
