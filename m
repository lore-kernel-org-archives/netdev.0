From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] net: Checksum offload changes - Part V
Date: Fri, 20 Jun 2014 22:13:17 -0700
Message-ID: <1403327597.16682.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406201629550.12225@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36293 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaFUFNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 01:13:21 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so4606812wgg.32
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 22:13:20 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406201629550.12225@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-20 at 16:37 -0700, Tom Herbert wrote:
> I am working on overhauling RX checksum offload. Goals of this effort
> are:
> 
> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
> - Preserve CHECKSUM_COMPLETE through encapsulation layers
> - Don't do skb_checksum more than once per packet
> - Unify GRO and non-GRO csum verification as much as possible
> - Unify the checksum functions (checksum_init)
> - Simplify code
> 
> What is in this fifth patch set:
> 
> - Added GRO checksum validation functions
> - Call the GRO validations functions from TCP and GRE gro_receive
> - Perform checksum verification in the UDP gro_receive path using
>   GRO functions and add support for gro_receive in UDP6

What kind of speed regression / code bloat comes from all these
changes ?

I see a lot of added complexity / code in GRO layer, but no performance
numbers...

__skb_gro_checksum_complete() for example calls skb_checksum() twice,
and we know this is expensive, particularly for IPv4 case where we know
the header checksum has to be 0.

GRO performance is already not very good, lot of people just disable GRO
because of it being very slow. I'd like to not give them more
incentives...

Without proper RFS support from the NIC, all encapsulated traffic tend
to land on a single RX queue, so performance of GRO layer is critical.
