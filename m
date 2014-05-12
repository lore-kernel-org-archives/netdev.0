From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Mon, 12 May 2014 08:21:26 -0400
Message-ID: <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, jpa@google.com,
	David Miller <davem@davemloft.net>, ja@ssi.bg,
	hannes@stressinduktion.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:54793 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbaELMV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 08:21:28 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so7427065lbi.33
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 05:21:26 -0700 (PDT)
In-Reply-To: <1399657021-26082-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I havent read your patch, but the description triggers
some questions in my mind - what is the relationship
between this proposal and the current linux vrf implementation
(which afaik is done using network namespaces)?  Multiple
IP routing tables seems to be motivated by forwarding-policy,
isn't your use-case really a VRF one?

--Sowmini

On Fri, May 9, 2014 at 1:36 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> Mark-based routing (ip rule fwmark 17 lookup 100) combined with
> either iptables marking (iptables -j MARK --set-mark 17) or
> application-based marking (the SO_MARK setsockopt) are a good
> way to deal with connecting simultaneously to multiple networks.
>
> Each network can be given a routing table, and ip rules can
> be configured to make different fwmarks select different
> networks. Applications can select networks them by setting
> appropriate socket marks, and iptables rules can be used to
> handle non-aware applications, enforce policy, etc.
>
> This patch series improves functionality when mark-based routing
> is used in this way. Current behaviour has the following
> limitations:
>
> 1. Kernel-originated replies that are not associated with a
>    socket always use a mark of zero. This means that, for
>    example, when the kernel sends a ping reply or a TCP reset,
>    it does not send it on the network from which it received the
>    original packet.
> 2. Path MTU discovery, which is triggered by incoming packets,
>    does not always work correctly, because the routing lookups it
>    uses to clone routes do not take the fwmark into account and
>    thus can happen in the wrong routing table.
> 3. Application-based marking works well for outbound connections,
>    but does not work well for incoming connections. Marking a
>    listening socket causes that socket to only accept
>    connections from a given network, and sockets that are
>    returned by accept() are not marked (and are thus not routed
>    correctly).
>
> #1 and #2 are addressed by a new net.ipv[46].fwmark_reflect
> sysctl. This causes route lookups for kernel-generated replies
> and PMTUD to use the fwmark of the packet that caused them.
>
> #3 is addressed by a new net.ipv4.tcp_fwmark_accept sysctl,
> which causes TCP sockets returned by accept() to be marked with
> the same mark that sent the intial SYN packet.
>
> Lorenzo Colitti (3):
>   net: add a sysctl to reflect the fwmark on replies
>   net: Use fwmark reflection in PMTU discovery.
>   net: support marking accepting TCP sockets
>
>  include/net/inet_sock.h          | 10 ++++++++++
>  include/net/ip.h                 |  3 +++
>  include/net/ipv6.h               |  3 +++
>  include/net/netns/ipv4.h         |  3 +++
>  include/net/netns/ipv6.h         |  1 +
>  net/ipv4/icmp.c                  | 11 +++++++++--
>  net/ipv4/inet_connection_sock.c  |  6 ++++--
>  net/ipv4/ip_output.c             |  3 ++-
>  net/ipv4/route.c                 |  7 +++++++
>  net/ipv4/syncookies.c            |  3 ++-
>  net/ipv4/sysctl_net_ipv4.c       | 14 ++++++++++++++
>  net/ipv4/tcp_ipv4.c              |  1 +
>  net/ipv6/icmp.c                  |  6 ++++++
>  net/ipv6/inet6_connection_sock.c |  2 +-
>  net/ipv6/route.c                 |  2 +-
>  net/ipv6/syncookies.c            |  4 +++-
>  net/ipv6/sysctl_net_ipv6.c       |  7 +++++++
>  net/ipv6/tcp_ipv6.c              |  2 ++
>  18 files changed, 79 insertions(+), 9 deletions(-)
>
> --
> 1.9.1.423.g4596e3a
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
