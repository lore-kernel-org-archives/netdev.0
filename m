From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: vrf: performance improvements
Date: Wed, 22 Mar 2017 11:20:14 -0700 (PDT)
Message-ID: <20170322.112014.2051512482980780927.davem@davemloft.net>
References: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965486AbdCVSUQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:20:16 -0400
In-Reply-To: <1490033985-14874-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 20 Mar 2017 11:19:43 -0700

> Device based features for VRF such as qdisc, netfilter and packet
> captures are implemented by switching the dst on skbuffs to its per-VRF
> dst. This has the effect of controlling the output function which points
> a function in the VRF driver. [1] The skb proceeds down the stack with
> dst->dev pointing to the VRF device. Netfilter, qdisc and tc rules and
> network taps are evaluated based on this device. Finally, the skb makes
> it to the vrf_xmit function which resets the dst based on a FIB lookup.
> 
> The feature comes at cost - between 5 and 10% depending on test (TCP vs
> UDP, stream vs RR and IPv4 vs IPv6). The main cost is requiring a FIB
> lookup in the VRF driver for each packet sent through it. The FIB lookup
> is required because the real dst gets dropped so that the skb can
> traverse the stack with dst->dev set to the VRF device.
> 
> All of that is really driven by the qdisc and not replicating the
> processing of __dev_queue_xmit if a qdisc is set up on the device. But,
> VRF devices by default do not have a qdisc and really have no need for
> multiple Tx queues. This means the performance overhead is inflicted upon
> all users for the potential use case of a qdisc being configured.
> 
> The overhead can be avoided by checking if the default configuration
> applies to a specific VRF device before switching the dst. If a device
> does not have a qdisc, the pass through netfilter hooks and packet taps
> can be done inline without dropping the dst and thus avoiding the
> performance penalty. With this change performance overhead of VRF drops
> to neglible (difference with run-over-run variance) to 3% depending on
> test type.
 ...
> * UDP is consistently better with VRF for two reasons:
>   1. Source address selection with L3 domains is considering fewer
>      addresses since only addresses on interfaces in the domain are
>      considered for the selection. Specifically, perf-top shows
>      shows ipv6_get_saddr_eval, ipv6_dev_get_saddr and __ipv6_dev_get_saddr
>      running much lower with vrf than without.
> 
>   2. The VRF table contains all routes (i.e, there are no separate local
>      and main tables per VRF). That means ip6_pol_route_output only has 1
>      lookup for VRF where it does 2 without it (1 in the local table and 1
>      in the main table).
> 
> [1] http://netdevconf.org/1.2/papers/ahern-what-is-l3mdev-paper.pdf

Series applied, thanks David.
