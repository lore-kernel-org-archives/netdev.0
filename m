From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Fri, 19 Feb 2016 13:53:05 -0800
Message-ID: <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54112 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030331AbcBSVxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:53:22 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id CDA09204B0
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:53:21 +0000 (UTC)
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 35E1B20504
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:53:20 +0000 (UTC)
Received: by mail-qk0-f175.google.com with SMTP id x1so36321562qkc.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 13:53:20 -0800 (PST)
In-Reply-To: <20160219191806.15687.37621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 11:26 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch series makes it so that we enable the outer Tx checksum for IPv4
> tunnels by default.  This makes the behavior consistent with how we were
> handling this for IPv6.  In addition I have updated the internal flags for
> these tunnels so that we use a ZERO_CSUM_TX flag for IPv4 which should
> match up will with the ZERO_CSUM6_TX flag which was already in use for
> IPv6.
>
> For most network devices this should be a net gain in terms of performance
> as having the outer header checksum present allows for devices to report
> CHECKSUM_UNNECESSARY which we can then convert to CHECKSUM_COMPLETE in order
> to determine if the inner header checksum is valid.
>
> Below is some data I collected with ixgbe with an X540 that demonstrates
> this.  I located two PFs connected back to back in two different name
> spaces and then setup a pair of tunnels on each, one with checksum enabled
> and one without.
>
> Recv   Send    Send                          Utilization
> Socket Socket  Message  Elapsed              Send
> Size   Size    Size     Time     Throughput  local
> bytes  bytes   bytes    secs.    10^6bits/s  % S
>
> noudpcsum:
>  87380  16384  16384    30.00      8898.67   12.80
> udpcsum:
>  87380  16384  16384    30.00      9088.47   5.69
>
> The one spot where this may cause a performance regression is if the
> environment contains devices that can parse the inner headers and a device
> supports NETIF_F_GSO_UDP_TUNNEL but not NETIF_F_GSO_UDP_TUNNEL_CSUM.  In
> the case of such a device we have to fall back to using GSO to segment the
> tunnel instead of TSO and as a result we may take a performance hit as seen
> below with i40e.

Do you have any numbers from 40G links? Obviously, at 10G the links
are basically saturated and while I can see a difference in the
utilization rate, I suspect that the change will be much more apparent
at higher speeds.

I'm concerned about the drop in performance for devices that currently
support offloads (almost none of which expose
NETIF_F_GSO_UDP_TUNNEL_CSUM as a feature). Presumably the people that
care most about tunnel performance are the ones that already have
these NICs and will be the most impacted by the drop.

My hope is that we can continue to use TSO on devices that only
support NETIF_F_GSO_UDP_TUNNEL. The main problem is that the UDP
length field may vary across segments. However, in practice this is
the only on the final segment and only in cases where the total length
is not a multiple of the MSS. If we could detect cases where those
conditions are met, we could continue to use TSO with the UDP checksum
field pre-populated. A possible step even further would be to break
off the final segment into a separate packet to make things conform if
necessary. This would avoid a performance regression and I think make
this more palatable to a lot of people.

> I also haven't investigated the effect this will have on OVS.  However I
> suspect the impact should be minimal as the worst case scenario should be
> that Tx checksumming will become enabled by default which should be
> consistent with the existing behavior for IPv6.

I don't think that it should cause any problems.
