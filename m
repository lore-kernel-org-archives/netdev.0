From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Sun, 31 Jan 2016 16:24:00 -0800
Message-ID: <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36000 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824AbcBAAYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 19:24:02 -0500
Received: by mail-pf0-f181.google.com with SMTP id n128so72734668pfn.3
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 16:24:01 -0800 (PST)
In-Reply-To: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-01-31 at 13:37 -0800, Tom Herbert wrote:
> Call get_unaligned_be32 when we access 32-bit fields in
> __skb_flow_dissect. At the beginning check for unlikely case of
> 1-byte aligned packet.
> 
> Note that flow_dissector may be asked to parse packet unaligned
> fields in two instances:
> 
> 1) Packet from a driver which is aligned to Ethernet header
>    (2-byte alignment)
> 2) Parsing inner headers of a received GRE-TEB packet
> 
> Testing: Ran super_netperf tests did not see a regression. This was on
> x86 which does not have problems with unaligned data.

But this test is absolutely useless, what about testing arches that
actually care ?

I am told all these MIPS based boxes have already not enough cpu power.

It is sad, because none of them use the drivers that might call flow
dissection (mlx4 and 4 intel drivers)

So I would rather fix the cases where flow dissection called from
eth_get_headlen() with non aligned stuff.

And maybe restrict GRE-TEB to platforms with
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y, since otherwise we need to add
these unaligned macros in thousands of places in our stacks.
