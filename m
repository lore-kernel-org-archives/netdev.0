From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Mon, 28 Nov 2016 13:32:21 -0800
Message-ID: <CAKgT0Ue3f0hUnCvwBupqmhBE_bbxZUO7ODXsz2cbHrPu5gAqyA@mail.gmail.com>
References: <20161125120947.142c3af5@canb.auug.org.au> <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
 <20161125134520.68ca0969@canb.auug.org.au> <alpine.DEB.2.20.1611250503250.22094@aurora.sdinet.de>
 <20161127142340.3a5c197e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
        Eli Cooper <elicooper@gmx.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34829 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbcK1VcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:32:23 -0500
Received: by mail-io0-f180.google.com with SMTP id a124so254709246ioe.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:32:23 -0800 (PST)
In-Reply-To: <20161127142340.3a5c197e@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2016 at 7:23 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi Sven-Haegar,
>
> On Fri, 25 Nov 2016 05:06:53 +0100 (CET) Sven-Haegar Koch <haegar@sdinet.de> wrote:
>>
>> Somehow this problem description really reminds me of a report on
>> netdev a bit ago, which the following patch fixed:
>>
>> commit 9ee6c5dc816aa8256257f2cd4008a9291ec7e985
>> Author: Lance Richardson <lrichard@redhat.com>
>> Date:   Wed Nov 2 16:36:17 2016 -0400
>>
>>     ipv4: allow local fragmentation in ip_finish_output_gso()
>>
>>     Some configurations (e.g. geneve interface with default
>>     MTU of 1500 over an ethernet interface with 1500 MTU) result
>>     in the transmission of packets that exceed the configured MTU.
>>     While this should be considered to be a "bad" configuration,
>>     it is still allowed and should not result in the sending
>>     of packets that exceed the configured MTU.
>>
>> Could this be related?
>>
>> I suppose it would be difficult to test this patch on this machine?
>
> The kernel I am running on is based on 4.7.8, so the above patch
> doesn't come close to applying. Most fo what it is reverting was
> introduced in commit 359ebda25aa0 ("net/ipv4: Introduce IPSKB_FRAG_SEGS
> bit to inet_skb_parm.flags") in v4.8-rc1.

So I think I have this root caused.  The problem seems to be the fact
that I chose to use lco_csum when trying to cancel out the inner IP
header from the checksum and it turns out that the transport offset is
never updated in the case of these tunnels.

For now a workaround is to just set tx-gso-partial to off on the
interface the tunnel is running over and you should be able to pass
traffic without any issues.

I have a patch for igb/igbvf that should be out in the next hour or so
which should address it.

Thanks.

- Alex
